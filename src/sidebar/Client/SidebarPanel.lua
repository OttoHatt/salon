--[=[
	@class SidebarPanel

	Sidebar!
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local ObservableList = require("ObservableList")
local Blend = require("Blend")
local RxBrioUtils = require("RxBrioUtils")
local SidebarButton = require("SidebarButton")
local BasicPaneUtils = require("BasicPaneUtils")
local cancellableDelay = require("cancellableDelay")

local SidebarPanel = setmetatable({}, BasicPane)
SidebarPanel.ClassName = "SidebarPanel"
SidebarPanel.__index = SidebarPanel

function SidebarPanel.new(obj)
	local self = setmetatable(BasicPane.new(obj), SidebarPanel)

	self._scaleValue = Instance.new("NumberValue")
	self._scaleValue.Value = 1
	self._maid:GiveTask(self._scaleValue)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	self._children = ObservableList.new()
	self._maid:GiveTask(self._children)

	do
		local function update()
			self:_updateLayout()
		end

		update()
		self._maid:GiveTask(self._children.ItemAdded:Connect(update))
		self._maid:GiveTask(self._children.ItemRemoved:Connect(update))
	end

	self._maid:GiveTask(self._children:ObserveItemsBrio():Subscribe(function(brio)
		local item, key = brio:GetValue()
		local maid = brio:ToMaid()

		maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
			-- Use our index in the list to determine our delay in appearing!
			local index = self._children:GetIndexByKey(key)
			maid._delay = cancellableDelay(index * 0.04, function()
				item:SetVisible(isVisible)
			end)
		end))
		maid:GiveTask(item.Activated:Connect(function()
			-- Toggle ourselves!
			item:SetIsChosen(not item:GetIsChosen())
			-- Deselect all others.
			for _, otherItem in self._children:GetList() do
				if otherItem ~= item then
					otherItem:SetIsChosen(false)
				end
			end
		end))
	end))

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SidebarPanel:_updateLayout()
	local V_PADDING = 32

	local width = 0
	local height = 0

	for i, child: GuiBase in self._children:GetList() do
		if i > 1 then
			height += V_PADDING
		end

		child.Gui.Position = UDim2.fromOffset(0, height)

		local childDim: Vector3 = child:GetSizeValue().Value
		width = math.max(width, childDim.X)
		height += childDim.Y
	end

	self._sizeValue.Value = Vector3.new(width, height, 0)
end

function SidebarPanel:GetSizeValue(): Vector3Value
	return self._sizeValue
end

function SidebarPanel:SetScale(scale: number)
	self._scaleValue.Value = scale
end

function SidebarPanel:AddSidebarButton(class)
	assert(SidebarButton.isSidebarButton(class), "Bad SidebarButton instance")

	return self._children:Add(class)
end

function SidebarPanel:_render()
	return Blend.New("Frame")({
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Size = Blend.Computed(self._sizeValue, function(size: Vector3)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		[Blend.Children] = {
			Blend.New("UIScale")({
				Scale = self._scaleValue,
			}),
			self._children:ObserveItemsBrio():Pipe({
				RxBrioUtils.map(function(class)
					return class.Gui
				end),
			}),
		},
	})
end

return SidebarPanel
