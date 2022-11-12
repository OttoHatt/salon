--[=[
	@class SettingsButton

	Clicky button?
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local ButtonHighlightModel = require("ButtonHighlightModel")
local Signal = require("Signal")

local SettingsButton = setmetatable({}, BasicPane)
SettingsButton.ClassName = "SettingsButton"
SettingsButton.__index = SettingsButton

function SettingsButton.new(obj)
	local self = setmetatable(BasicPane.new(obj), SettingsButton)

	self._textValue = Instance.new("StringValue")
	self._textValue.Value = "Button"
	self._maid:GiveTask(self._textValue)

	self._buttonModel = ButtonHighlightModel.new()
	self._maid:GiveTask(self._buttonModel)

	self._widthValue = Instance.new("NumberValue")
	self._maid:GiveTask(self._widthValue.Changed:Connect(function()
		self:_updateLayout()
	end))
	self._maid:GiveTask(self._widthValue)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	self.Activated = Signal.new()
	self._maid:GiveTask(self.Activated)

	self:_updateLayout()

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsButton:GetSizeValue()
	return self._sizeValue
end

function SettingsButton:_updateLayout()
	local panelWidth = self._widthValue.Value
	if panelWidth <= 0 then
		-- Invalid width, can't calculate.
		return
	end

	local BUTTON_ASPECT_RATIO = 11
	local height = panelWidth / BUTTON_ASPECT_RATIO

	self._sizeValue.Value = Vector3.new(panelWidth, height, 0)
end

function SettingsButton:SetWidth(width: number)
	self._widthValue.Value = width
end

function SettingsButton:SetName(name: string)
	self._textValue.Value = name
end

function SettingsButton:_render()
	return Blend.New("Frame")({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = BrickColor.random().Color,
		[Blend.Children] = {
			Blend.New("UIAspectRatioConstraint")({
				AspectRatio = 11,
			}),
			Blend.New("TextButton")({
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, -4),
				BackgroundColor3 = Color3.new(0.760784, 0.760784, 0.760784),
				[Blend.OnEvent("Activated")] = function()
					self.Activated:Fire()
				end,
				[Blend.Instance] = function(button: Instance)
					self._buttonModel:SetButton(button)
				end,
				[Blend.Children] = {
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 999),
					}),
					Blend.New("UIPadding")({
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					}),
					Blend.New("TextLabel")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Text = self._textValue,
						TextXAlignment = Enum.TextXAlignment.Center,
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
			}),
		},
	})
end

return SettingsButton
