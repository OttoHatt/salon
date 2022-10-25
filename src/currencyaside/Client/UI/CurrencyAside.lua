--[=[
	@class CurrencyAside

	Pane displaying a currency icon and count.
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local BasicPaneUtils = require("BasicPaneUtils")
local Rx = require("Rx")
local SpringObject = require("SpringObject")

local CurrencyAside = setmetatable({}, BasicPane)
CurrencyAside.ClassName = "CurrencyAside"
CurrencyAside.__index = CurrencyAside

function CurrencyAside.new()
	local self = setmetatable(BasicPane.new(), CurrencyAside)

	self._rawSize = Vector3.new(150, 50)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	self._scaleValue = Instance.new("NumberValue")
	self._scaleValue.Value = 1
	self._maid:GiveTask(self._scaleValue)

	self._iconValue = Instance.new("StringValue")
	self._iconValue.Value = "rbxassetid://10256721063"
	self._maid:GiveTask(self._iconValue)

	self._countValue = Instance.new("IntValue")
	self._countValue.Value = 0
	self._maid:GiveTask(self._countValue)

	self._knockSpring = SpringObject.new(0, 30, 0.4)
	self._maid:GiveTask(self._knockSpring)
	self._maid:GiveTask(self._countValue.Changed:Connect(function()
		self._knockSpring:Impulse(900)
	end))

	self._strokeColor = Instance.new("Color3Value")
	self._strokeColor.Value = Color3.fromHex("#1A1A1A")
	self._maid:GiveTask(self._strokeColor)

	self._maid:GiveTask(Blend.mount(self._sizeValue, {
		Value = Blend.Computed(self._rawSize, self._scaleValue, function(rawSize: Vector3, scale: number)
			return rawSize * scale
		end),
	}))

	self._maid:GiveTask(self:_render():Subscribe(function(gui: Instance)
		self.Gui = gui
	end))

	return self
end

function CurrencyAside:GetSizeValue()
	return self._sizeValue
end

function CurrencyAside:SetIcon(icon: string)
	assert(typeof(icon) == "string", "Bad icon")
	self._iconValue.Value = icon
end

function CurrencyAside:SetCount(count: number)
	self._countValue.Value = count
end

function CurrencyAside:SetScale(scale: number)
	self._scaleValue.Value = scale
end

function CurrencyAside:_render()
	local percentVisible = BasicPaneUtils.observePercentVisible(self)
	local transparency = BasicPaneUtils.toTransparency(percentVisible)

	local rawScaleSpring = Blend.Computed(
		self._scaleValue,
		Blend.Spring(percentVisible, 40, 0.7),
		function(scale: number, visible: number)
			return scale * visible
		end
	)
	local snappedScaleSpring = Blend.Computed(rawScaleSpring, self._scaleValue, function(value, target)
		return if math.abs(value - target) < 0.01 then target else value
	end)

	local rotationGoal = Blend.Computed(transparency, function(visible)
		return 10 * visible
	end)
	local rawRotation = Blend.Spring(rotationGoal, 40, 0.6)
	local snappedRotationSpring = Blend.Computed(rawRotation, rotationGoal, function(value, target)
		return if math.abs(value - target) < 0.5 then target else value
	end)

	-- Lag the count so that we can play a cute animation *before* we update the numbers.
	local laggedCount = Blend.toNumberObservable(self._countValue):Pipe({
		Rx.delay(0.07),
		Rx.defaultsTo(self._countValue.Value),
	})

	return Blend.New("Frame")({
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Size = Blend.Computed(self._rawSize, function(size: Vector3)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		Visible = Blend.Computed(snappedScaleSpring, function(value)
			return value > 0.1
		end),
		[Blend.Children] = {
			Blend.New("Frame")({
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = Blend.AccelTween(transparency, 200),
				Position = Blend.Computed(self._knockSpring:ObserveRenderStepped(), function(knock: number)
					return UDim2.new(1, 0, 0.5, knock)
				end),
				Size = UDim2.new(1, 0, 1, 0),
				Rotation = snappedRotationSpring,
				[Blend.Children] = {
					Blend.New("UIScale")({
						Scale = snappedScaleSpring,
					}),
					Blend.New("UIStroke")({
						Color = self._strokeColor,
						Thickness = 4,
					}),
					Blend.New("UIPadding")({
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),
					Blend.New("UIGradient")({
						Rotation = 90 - 15,
						Color = ColorSequence.new(Color3.fromHex("#f5f7fa"), Color3.fromHex("#c3cfe2")),
					}),
					Blend.New("TextLabel")({
						AnchorPoint = Vector2.new(0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = Blend.Computed(Blend.Spring(laggedCount, 20), function(decimal)
							return math.floor(decimal + 0.5)
						end),
						TextXAlignment = Enum.TextXAlignment.Right,
						TextSize = 30,
						Font = Enum.Font.FredokaOne,
						TextColor3 = self._strokeColor,
					}),
					Blend.New("UICorner")({
						CornerRadius = UDim.new(0, 8),
					}),
					Blend.New("ImageLabel")({
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = self._iconValue,
						[Blend.Children] = {
							Blend.New("UIAspectRatioConstraint")({}),
						},
					}),
				},
			}),
		},
	})
end

return CurrencyAside
