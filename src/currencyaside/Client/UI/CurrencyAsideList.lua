--[=[
	@class CurrencyAsideList

	Organises CurrencyAsides
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local ObservableList = require("ObservableList")
local RxBrioUtils = require("RxBrioUtils")
local BasicPaneUtils = require("BasicPaneUtils")
local cancellableDelay = require("cancellableDelay")

local CurrencyAsideList = setmetatable({}, BasicPane)
CurrencyAsideList.ClassName = "CurrencyAsideList"
CurrencyAsideList.__index = CurrencyAsideList

function CurrencyAsideList.new()
	local self = setmetatable(BasicPane.new(), CurrencyAsideList)

	self._children = ObservableList.new()
	self._maid:GiveTask(self._children)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	local function update()
		self:_recalculateLayout()
	end
	update()

	self._maid:GiveTask(self:_render():Subscribe(function(gui: Instance)
		self.Gui = gui
	end))

	self._maid:GiveTask(self._children.ItemAdded:Connect(update))
	self._maid:GiveTask(self._children.ItemRemoved:Connect(update))

	self._maid:GiveTask(self._children:ObserveItemsBrio():Subscribe(function(brio)
		local item, key = brio:GetValue()
		local maid = brio:ToMaid()

		maid:GiveTask(item:GetSizeValue().Changed:Connect(update))
		maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
			local index = self._children:GetIndexByKey(key)

			maid._delay = cancellableDelay((index - 1) * 0.02, function()
				item:SetVisible(isVisible)
			end)
		end))
	end))

	return self
end

function CurrencyAsideList:_recalculateLayout()
	local ASIDE_V_PADDING = 16

	local width = 0
	for _, child in self._children:GetList() do
		local childSize: Vector3 = child:GetSizeValue().Value
		width = math.max(childSize.X, width)
	end

	local height = 0
	for i, child in self._children:GetList() do
		if i > 1 then
			height += ASIDE_V_PADDING
		end

		child.Gui.Position = UDim2.fromOffset(width, height)

		local childSize: Vector3 = child:GetSizeValue().Value
		height += childSize.Y
	end

	self._sizeValue.Value = Vector3.new(width, height, 0)
end

function CurrencyAsideList:AddAside(currencyAside)
	return self._children:Add(currencyAside)
end

function CurrencyAsideList:GetSizeValue()
	return self._sizeValue
end

function CurrencyAsideList:_render()
	return Blend.New("Frame")({
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = Blend.Computed(self._sizeValue, function(size: Vector3)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		[Blend.Children] = {
			self._children:ObserveItemsBrio():Pipe({
				RxBrioUtils.map(function(class)
					return class.Gui
				end),
			}),
		},
	})
end

return CurrencyAsideList
