--[=[
	@class SidebarButton

	Sidebar button!
]=]

local require = require(script.Parent.loader).load(script)

local ICON_SIZE = 128

local ButtonHighlightModel = require("ButtonHighlightModel")
local BasicPane = require("BasicPane")
local Blend = require("Blend")
local Signal = require("Signal")
local BasicPaneUtils = require("BasicPaneUtils")

local SidebarButton = setmetatable({}, BasicPane)
SidebarButton.ClassName = "SidebarButton"
SidebarButton.__index = SidebarButton

function SidebarButton.new(obj)
	local self = setmetatable(BasicPane.new(obj), SidebarButton)

	self.Activated = Signal.new()
	self._maid:GiveTask(self.Activated)

	self._scaleValue = Instance.new("NumberValue")
	self._scaleValue.Value = 1
	self._maid:GiveTask(self._scaleValue)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(Blend.mount(self._sizeValue, {
		Value = Blend.Computed(self._scaleValue, function(scale: number)
			return Vector3.new(ICON_SIZE, ICON_SIZE, 0) * scale
		end),
	}))
	self._maid:GiveTask(self._sizeValue)

	self._iconValue = Instance.new("StringValue")
	self._iconValue.Value = "rbxassetid://10256726537"
	self._maid:GiveTask(self._iconValue)

	self._displayNameValue = Instance.new("StringValue")
	self._displayNameValue.Value = "SidebarButton"
	self._maid:GiveTask(self._displayNameValue)

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

function SidebarButton.isSidebarButton(class)
	return class and getmetatable(class) == SidebarButton
end

function SidebarButton:SetDisplayName(name: string)
	self._displayNameValue.Value = name
end

function SidebarButton:SetIcon(icon: string)
	self._iconValue.Value = icon
end

function SidebarButton:GetSizeValue(): Vector3Value
	return self._sizeValue
end

function SidebarButton:SetScale(scale: number)
	self._scaleValue.Value = scale
end

function SidebarButton:SetIsChosen(chosen: boolean)
	self._buttonModel:SetIsChoosen(chosen)
end

function SidebarButton:GetIsChosen()
	return self._buttonModel.IsChoosen.Value
end

function SidebarButton:ObserveIsChosen()
	return Blend.toPropertyObservable(self._buttonModel.IsChoosen)
end

function SidebarButton:_render()
	local scaleSpring = Blend.Spring(
		Blend.Computed(
			BasicPaneUtils.observeVisible(self),
			self._buttonModel.IsChoosen,
			self._buttonModel.IsHighlighted,
			function(visible, chosen, highlighted)
				if not visible then
					return 0
				elseif chosen then
					return 0.9
				elseif highlighted then
					return 1.02
				else
					return 1
				end
			end
		),
		35,
		0.5
	)

	local rotationSpring = Blend.Spring(
		Blend.Computed(self._buttonModel.IsChoosen, self._buttonModel.IsHighlighted, function(chosen, highlighted)
			if highlighted and not chosen then
				return math.random(-3, 3)
			else
				return 0
			end
		end),
		20,
		0.3
	)

	return Blend.New("ImageButton")({
		Image = "",
		Size = UDim2.fromOffset(ICON_SIZE, ICON_SIZE),
		BackgroundTransparency = 1,
		Visible = Blend.Computed(scaleSpring, function(scale)
			return scale > 0.5
		end),
		[Blend.OnEvent("Activated")] = function()
			self.Activated:Fire()
		end,
		[Blend.Instance] = function(instance: Instance)
			self._buttonModel:SetButton(instance)
		end,
		[Blend.Children] = {
			Blend.New("UIScale")({
				Scale = self._scaleValue,
			}),
			Blend.New("Frame")({
				Size = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.one / 2,
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = rotationSpring,
				[Blend.Children] = {
					Blend.New("UIScale")({
						Scale = scaleSpring,
					}),
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 16),
					}),
					Blend.New("UIStroke")({
						Thickness = 6,
						Color = self._strokeColor,
					}),
					Blend.New("UIGradient")({
						Rotation = 45,
						Color = ColorSequence.new(Color3.fromHex("#f5f7fa"), Color3.fromHex("#c3cfe2")),
					}),
					Blend.New("Frame")({
						Size = UDim2.new(1, 01, 1, 0),
						BackgroundTransparency = 1,
						[Blend.Children] = {
							Blend.New("UIPadding")({
								PaddingTop = UDim.new(0, 16),
								PaddingBottom = UDim.new(0, 16),
								PaddingLeft = UDim.new(0, 16),
								PaddingRight = UDim.new(0, 16),
							}),
							Blend.New("ImageLabel")({
								Image = self._iconValue,
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
							}),
						},
					}),
					Blend.New("TextLabel")({
						Text = self._displayNameValue,
						Font = Enum.Font.FredokaOne,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						Position = UDim2.new(0.5, 0, 1, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						TextSize = 28,
						TextColor3 = Color3.new(1, 1, 1),
						[Blend.Children] = {
							Blend.New("UIStroke")({
								Color = self._strokeColor,
								Thickness = 4,
							}),
						},
					}),
				},
			}),
		},
	})
end

return SidebarButton
