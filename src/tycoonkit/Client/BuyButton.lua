--[=[
	@class BuyButton

	Buy buttons woo hooooooo
	Spend some money

	Ported from 'hotel'.
]=]

local require = require(script.Parent.loader).load(script)

local SOUND_BUTTON_ON = "rbxassetid://10066942189"
local SOUND_BUTTON_OFF = "rbxassetid://10066936758"

local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local Blend = require("Blend")
local BaseObject = require("BaseObject")
local CharacterUtils = require("CharacterUtils")
local BinderUtils = require("BinderUtils")
local ObservableSet = require("ObservableSet")
local Rx = require("Rx")
local Maid = require("Maid")
local ValueObject = require("ValueObject")
local TycoonBindersClient = require("TycoonBindersClient")
local RxInstanceUtils = require("RxInstanceUtils")
local TycoonTemplateUtils = require("TycoonTemplateUtils")
local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")
local NumberLocalizationUtils = require("NumberLocalizationUtils")

local BuyButton = setmetatable({}, BaseObject)
BuyButton.ClassName = "BuyButton"
BuyButton.__index = BuyButton

function BuyButton.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), BuyButton)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersClient)

	self._touchingPartsSet = ObservableSet.new()
	self._maid:GiveTask(self._touchingPartsSet)

	self._maid:GiveTask(
		self:GetOwnerSession():ObserveBuildableExists(self:GetTargetBuildableName()):Subscribe(function(exists)
			self:_handleTargetBuilt(exists)
		end)
	)

	return self
end

function BuyButton:Buy()
	self:GetOwnerSession():AttemptBuyBuildable(self:GetTargetBuildableName())
end

function BuyButton:GetTargetBuildableName()
	-- lol!
	return self._obj.Name
end

function BuyButton:PromiseTemplate()
	-- TODO: Ew!!
	return TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		return TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate, self:GetTargetBuildableName())
	end)
end

function BuyButton:GetOwnerSession()
	-- TODO: Genericise this!!!!
	return BinderUtils.findFirstAncestor(self._tycoonBinders.OwnerSession, self._obj)
end

function BuyButton:_handleTargetBuilt(isBuilt: boolean)
	if not isBuilt then
		local maid = Maid.new()

		local depressedValue = ValueObject.fromObservable(self:_observeDepressed())
		maid:GiveTask(depressedValue)

		local BUTTON_HEIGHT = 0.4
		local BUTTON_RISE_HEIGHT = 0.3
		local BUTTON_FLUSH_HEIGHT = 0.045

		local baseCFrame = self._obj.CFrame:ToWorldSpace(
			CFrame.new(0, self._obj.Size.Y * -0.5 + (BUTTON_HEIGHT / 2), 0)
		) * CFrame.Angles(0, 0, -math.pi / 2)

		-- Render a model when we haven't built our target yet!
		maid._model = Blend.New("Folder")({
			Name = "Button",
			Parent = self._obj,
			[Blend.Children] = {
				-- Base.
				Blend.New("Part")({
					Anchored = true,
					BrickColor = BrickColor.new(149),
					Material = Enum.Material.SmoothPlastic,
					CanTouch = false,
					CFrame = baseCFrame,
					Size = Vector3.new(BUTTON_HEIGHT, 3.5, 3.5),
					Shape = Enum.PartType.Cylinder,
					[Blend.Children] = {
						Blend.New("Sound")({
							SoundId = SOUND_BUTTON_ON,
							Volume = 0.7,
							[Blend.Attached(function(sound: Sound)
								return depressedValue.Changed:Connect(function(isDepressed)
									if isDepressed then
										sound:Play()
									else
										sound:Stop()
									end
								end)
							end)] = true,
						}),
						Blend.New("Sound")({
							SoundId = SOUND_BUTTON_OFF,
							Volume = 0.7,
							[Blend.Attached(function(sound: Sound)
								return depressedValue.Changed:Connect(function(isDepressed)
									if not isDepressed then
										sound:Play()
									else
										sound:Stop()
									end
								end)
							end)] = true,
						}),
					},
				}),
				-- Moving part.
				Blend.New("Part")({
					Anchored = true,
					BrickColor = BrickColor.Red(),
					Material = Enum.Material.SmoothPlastic,
					CanTouch = false,
					CanCollide = false,
					CanQuery = false,
					CFrame = Blend.Computed(
						Blend.Spring(
							Blend.Computed(self:_observeDepressed(), function(depressed)
								local offset = if depressed then BUTTON_FLUSH_HEIGHT else BUTTON_RISE_HEIGHT
								return baseCFrame.Position + Vector3.new(0, offset, 0)
							end),
							28,
							0.5
						),
						function(origin: Vector3)
							return CFrame.new(origin) * baseCFrame.Rotation
						end
					),
					Size = Vector3.new(BUTTON_HEIGHT, 2.6, 2.6),
					Shape = Enum.PartType.Cylinder,
					[Blend.Children] = {
						-- Label.
						if self:GetOwnerSession():GetPlayer() == Players.LocalPlayer
							then Blend.New("BillboardGui")({
								Size = UDim2.new(4, 0, 4, 0),
								StudsOffsetWorldSpace = Vector3.new(-3, 0, 0),
								ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
								MaxDistance = 128,
								[Blend.Attached(function(instance: BillboardGui)
									return RxInstanceUtils.observeProperty(instance, "Parent")
										:Subscribe(function(parent: Instance)
											instance.Adornee = parent
										end)
								end)] = true,
								[Blend.Children] = {
									Blend.New("UIListLayout")({
										Padding = UDim.new(0, 0),
										FillDirection = Enum.FillDirection.Vertical,
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Bottom,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
									}),
									-- Price.
									Blend.New("TextLabel")({
										BackgroundTransparency = 2,
										Font = Enum.Font.FredokaOne,
										LayoutOrder = 2,
										Size = UDim2.new(1, 0, 0.25, 0),
										Text = self:PromiseTemplate():Then(function(template: Folder)
											if not template then
												return "$???"
											end
											local price = TycoonTemplateBuildableUtils.getPrice(template)
											return "$"
												.. NumberLocalizationUtils.localize(
													price,
													LocalizationService.SystemLocaleId
												)
										end),
										TextScaled = true,
										TextWrapped = true,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextYAlignment = Enum.TextYAlignment.Center,
										TextColor3 = Color3.fromHex("#41bf6b"),
										[Blend.Children] = {
											-- Blend.New("UIStroke")({
											-- 	Thickness = 2,
											-- 	Color = Color3.fromRGB(161, 255, 177),
											-- }),
										},
									}),
									-- Name.
									Blend.New("TextLabel")({
										BackgroundTransparency = 1,
										Font = Enum.Font.FredokaOne,
										LayoutOrder = 1,
										Size = UDim2.new(2.5, 0, 0.3, 0),
										Text = self:PromiseTemplate():Then(function(template: Folder)
											return if template
												then TycoonTemplateBuildableUtils.getDisplayName(template)
												else "???"
										end),
										TextScaled = true,
										TextSize = 28,
										TextWrapped = true,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextYAlignment = Enum.TextYAlignment.Bottom,
									}),
								},
							})
							else nil,
					},
				}),
				-- Trigger part.
				Blend.New("Part")({
					Anchored = true,
					Transparency = 1,
					CanTouch = true,
					CanCollide = false,
					CFrame = baseCFrame,
					Size = Vector3.new(BUTTON_HEIGHT + BUTTON_RISE_HEIGHT * 2, 2.6, 2.6),
					Shape = Enum.PartType.Cylinder,
					[Blend.OnEvent("Touched")] = function(part: BasePart)
						-- TODO: Ensure that only our owner can buy from here!!!!
						-- We'll want to support editing permissions in future; friends building on other people's plots.
						-- For now, we'll allow one owner...

						-- Reject hats, capes, etc.
						if part.Parent and part.Parent:IsA("Accessory") then
							return
						end

						local player = CharacterUtils.getPlayerFromCharacter(part)
						if player then
							self._touchingPartsSet:Add(part)
							self:Buy()
						end
					end,
					[Blend.OnEvent("TouchEnded")] = function(part: BasePart)
						self._touchingPartsSet:Remove(part)
					end,
				}),
			},
		}):Subscribe()

		self._maid._model = maid
	else
		self._maid._model = nil
	end
end

function BuyButton:_observeDepressed()
	return self._touchingPartsSet:ObserveCount():Pipe({
		Rx.map(function(count)
			return count > 0
		end),
		Rx.distinct(),
	})
end

return BuyButton
