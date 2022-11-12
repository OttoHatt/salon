--[=[
	@class SettingsToggle

	Settings toggle!
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local ButtonHighlightModel = require("ButtonHighlightModel")

local SettingsToggle = setmetatable({}, BasicPane)
SettingsToggle.ClassName = "SettingsToggle"
SettingsToggle.__index = SettingsToggle

function SettingsToggle.new(defaultValue: boolean)
	local self = setmetatable(BasicPane.new(), SettingsToggle)

	self._stateValue = Instance.new("BoolValue")
	self._stateValue.Value = if defaultValue ~= nil then defaultValue else false
	self._maid:GiveTask(self._stateValue)

	self._textValue = Instance.new("StringValue")
	self._textValue.Value = "Toggle Switch"
	self._maid:GiveTask(self._textValue)

	self._strokeColor = Instance.new("Color3Value")
	self._strokeColor.Value = Color3.fromHex("#1A1A1A")
	self._maid:GiveTask(self._strokeColor)

	self._buttonModel = ButtonHighlightModel.new()
	self._maid:GiveTask(self._buttonModel)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsToggle:SetState(value: boolean)
	self._stateValue.Value = value
end

function SettingsToggle:SetName(name: string)
	self._textValue.Value = name
end

function SettingsToggle:_render()
	local springPosition = Blend.Spring(
		Blend.Computed(self._stateValue, function(state)
			return if state then 1 else 0
		end),
		30,
		0.8
	)
	local scaleSpring = Blend.Spring(
		Blend.Computed(self._buttonModel.IsPressed, function(isPressed)
			return if isPressed then 0.7 else 1
		end),
		40,
		.4
	)

	return Blend.New("Frame")({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 0, 0),
		[Blend.Children] = {
			Blend.New("UIAspectRatioConstraint")({
				AspectRatio = 9,
			}),
			Blend.New("TextButton")({
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, -4),
				BackgroundColor3 = Blend.Computed(self._stateValue, function(state)
					return if state then Color3.fromRGB(97, 232, 133) else Color3.fromRGB(232, 97, 97)
				end),
				Text = "",
				[Blend.Instance] = function(button: Instance)
					self._buttonModel:SetButton(button)
				end,
				[Blend.OnEvent("Activated")] = function()
					self._stateValue.Value = not self._stateValue.Value
				end,
				[Blend.Children] = {
					Blend.New"UIAspectRatioConstraint" {
						AspectRatio = 2,
					},
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 999),
					}),
					Blend.New("UIPadding")({
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),
					Blend.New("Frame")({
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						AnchorPoint = Blend.Computed(springPosition, function(fac)
							return Vector2.new(fac, 0)
						end),
						Position = Blend.Computed(springPosition, function(fac)
							return UDim2.new(fac, 0, 0, 0)
						end),
						[Blend.Children] = {
							Blend.New("Frame")({
								Size = UDim2.new(1, 0, 1, 0),
								AnchorPoint = Vector2.one / 2,
								BackgroundColor3 = Color3.new(1, 1, 1),
								Position = UDim2.fromScale(0.5, 0.5),
								[Blend.Children] = {
									Blend.New("UIScale")({
										Scale = scaleSpring,
									}),
									Blend.New("UICorner")({
										CornerRadius = UDim.new(0, 999),
									}),
								},
							}),

							Blend.New("UIAspectRatioConstraint")({
								AspectRatio = 1,
							}),
						},
					}),
				},
			}),
			Blend.New("TextLabel")({
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Text = self._textValue,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new(
					"rbxasset://fonts/families/FredokaOne.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextWrapped = true,
			}),
		},
	})
end

return SettingsToggle
