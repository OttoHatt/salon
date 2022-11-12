--[=[
	@class BaseScreen

	Backing screen for all game UI.
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")

local BaseScreen = setmetatable({}, BasicPane)
BaseScreen.ClassName = "BaseScreen"
BaseScreen.__index = BaseScreen

function BaseScreen.new(obj)
	local self = setmetatable(BasicPane.new(obj), BaseScreen)

	self._scaleValue = Instance.new("NumberValue")
	self._scaleValue.Value = 1
	self._maid:GiveTask(self._scaleValue)

	self._strokeColor = Instance.new("Color3Value")
	self._strokeColor.Value = Color3.fromHex("#1A1A1A")
	self._maid:GiveTask(self._strokeColor)

	self._displayNameValue = Instance.new("StringValue")
	self._displayNameValue.Value = "MenuScreen"
	self._maid:GiveTask(self._displayNameValue)

	return self
end

function BaseScreen:SetDisplayName(name: string)
	self._displayNameValue.Value = name
end

function BaseScreen:SetScale(scale: number)
	self._scaleValue.Value = scale
end

function BaseScreen:_renderBase(props)
	local PANEL_PADDING = 64

	local scaleSpring = Blend.Spring(
		Blend.Computed(BasicPaneUtils.observeVisible(self), function(isVisible)
			return if isVisible then 1  else 0.7
		end),
		30,
		.4
	)
	local rotationSpring = Blend.Spring(
		Blend.Computed(BasicPaneUtils.observeVisible(self), function(isVisible)
			return if isVisible then 0  else math.random(-4, 4)
		end),
		30,
		.4
	)

	return Blend.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = Blend.Computed(props.ContentsSize, function(size: Vector2)
			return (if size then UDim2.fromOffset(size.X, size.Y) else UDim2.new()) + UDim2.fromOffset(PANEL_PADDING*2, PANEL_PADDING*2)
		end),
		BackgroundTransparency = 1,
		Visible = Blend.Computed(scaleSpring, function(scale)
			return scale > 0.8
		end),
		[Blend.Children] = {
			Blend.New("UIScale")({
				Scale = self._scaleValue,
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.one/2,
				Rotation = rotationSpring,
				[Blend.Children] = {
					Blend.New("UIScale")({
						Scale = scaleSpring,
					}),
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 32),
					}),
					Blend.New("UIStroke")({
						Color = self._strokeColor,
						Thickness = 12,
					}),
					Blend.New("TextLabel")({
						Text = self._displayNameValue,
						Font = Enum.Font.FredokaOne,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						Position = UDim2.new(0.03, 0, -0.02, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						TextSize = 55,
						TextColor3 = Color3.new(1, 1, 1),
						[Blend.Children] = {
							Blend.New("UIStroke")({
								Color = self._strokeColor,
								Thickness = 5,
							}),
							Blend.New("UIGradient")({
								Rotation = 45,
								Color = ColorSequence.new(Color3.fromHex("#f5f7fa"), Color3.fromHex("#c3cfe2")),
							}),
						},
					}),
					Blend.New("ImageButton")({
						Image = "",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Size = UDim2.fromOffset(32,32),
						Position = UDim2.new(0.98, 0, 0, 0),
						AnchorPoint = Vector2.one / 2,
						[Blend.OnEvent("Activated")] = function()
							self:SetVisible(false)
						end,
						[Blend.Children] = {
							Blend.New("UIAspectRatioConstraint")({}),
							Blend.New("UICorner")({
								CornerRadius = UDim.new(0, 999),
							}),
							[Blend.Children] = {
								Blend.New("UIStroke")({
									Color = self._strokeColor,
									Thickness = 6,
								}),
							},
							Blend.New("ImageLabel")({
								Active = false,
								Image = "rbxassetid://10256708536",
								BackgroundTransparency = 1,
								Size = UDim2.new(1.2, 0, 1.2, 0),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								AnchorPoint = Vector2.one / 2,
							}),
						},
					}),
					Blend.New("Frame")({
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						[Blend.Children] = {
							Blend.New("UIPadding")({
								PaddingTop = UDim.new(0, PANEL_PADDING),
								PaddingBottom = UDim.new(0, PANEL_PADDING),
								PaddingLeft = UDim.new(0, PANEL_PADDING),
								PaddingRight = UDim.new(0, PANEL_PADDING),
							}),
							props[Blend.Children],
						},
					}),
				},
			}),
		},
	})
end

return BaseScreen
