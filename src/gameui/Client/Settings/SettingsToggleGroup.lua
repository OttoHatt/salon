--[=[
	@class SettingsToggleGroup

	Settings toggle group!
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local SettingsToggle = require("SettingsToggle")
local ObservableList = require("ObservableList")
local Blend = require("Blend")
local RxBrioUtils = require("RxBrioUtils")
local BasicPaneUtils = require("BasicPaneUtils")
local cancellableDelay = require("cancellableDelay")

local SettingsToggleGroup = setmetatable({}, BasicPane)
SettingsToggleGroup.ClassName = "SettingsToggleGroup"
SettingsToggleGroup.__index = SettingsToggleGroup

function SettingsToggleGroup.new(obj)
	local self = setmetatable(BasicPane.new(obj), SettingsToggleGroup)

	self._widthValue = Instance.new("NumberValue")
	self._maid:GiveTask(self._widthValue.Changed:Connect(function()
		self:_updateLayout()
	end))
	self._maid:GiveTask(self._widthValue)

	self._sizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._sizeValue)

	self._togglesList = ObservableList.new()
	self._maid:GiveTask(self._togglesList)

	self._maid:GiveTask(self._togglesList:ObserveItemsBrio():Subscribe(function(brio)
		local toggle, key = brio:GetValue()
		local maid = brio:ToMaid()

		maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
			local index = self._togglesList:GetIndexByKey(key)

			maid._visibleDelay = cancellableDelay(if isVisible then (index - 1) * 0.02 else 0, function()
				toggle:SetVisible(isVisible)
			end)
		end))
	end))

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsToggleGroup:_updateLayout()
	local panelWidth = self._widthValue.Value
	if panelWidth <= 0 then
		-- Invalid width, can't calculate.
		return
	end

	local TOGGLE_ASPECT_RATIO = 11
	local TOGGLE_PADDING = 8

	local toggleHeight = panelWidth / TOGGLE_ASPECT_RATIO
	local height = 0

	for i, toggle in self._togglesList:GetList() do
		if i > 1 then
			height += TOGGLE_PADDING
		end
		toggle.Gui.Size = UDim2.fromOffset(panelWidth, toggleHeight)
		toggle.Gui.Position = UDim2.fromOffset(0, height)
		height += toggleHeight
	end

	self._sizeValue.Value = Vector3.new(panelWidth, height, 0)
end

function SettingsToggleGroup:SetWidth(width: number)
	self._widthValue.Value = width
end

function SettingsToggleGroup:RegisterToggle(name: string, defaultValue: boolean)
	-- TODO: Allow destruction by consumers.

	local toggle = SettingsToggle.new(defaultValue)
	toggle:SetName(name)
	self._maid:GiveTask(toggle)
	self._maid:GiveTask(self._togglesList:Add(toggle))

	self:_updateLayout()

	return toggle
end

function SettingsToggleGroup:GetSizeValue()
	return self._sizeValue
end

function SettingsToggleGroup:_render()
	return Blend.New("Frame")({
		Size = Blend.Computed(self._sizeValue, function(size: Vector3)
			return UDim2.fromOffset(size.X, size.Y)
		end),
		BackgroundTransparency = 1,
		[Blend.Children] = {
			self._togglesList:ObserveItemsBrio():Pipe({
				RxBrioUtils.map(function(class)
					return class.Gui
				end),
			}),
		},
	})
end

return SettingsToggleGroup
