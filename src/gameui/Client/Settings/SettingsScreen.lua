--[=[
	@class SettingsScreen

	Settings screen.
]=]

local require = require(script.Parent.loader).load(script)

local BaseScreen = require("BaseScreen")
local Blend = require("Blend")
local SettingsToggleGroup = require("SettingsToggleGroup")
local BasicPaneUtils = require("BasicPaneUtils")
local SettingsButton = require("SettingsButton")

local SettingsScreen = setmetatable({}, BaseScreen)
SettingsScreen.ClassName = "SettingsScreen"
SettingsScreen.__index = SettingsScreen

function SettingsScreen.new(obj)
	local self = setmetatable(BaseScreen.new(obj), SettingsScreen)

	self:SetDisplayName("Settings")

	self._toggleGroup = SettingsToggleGroup.new()
	self._toggleGroup:RegisterToggle("Music", true)
	self._toggleGroup:RegisterToggle("Extra speed", false)
	self._toggleGroup:RegisterToggle("Pet animations", true)
	self._toggleGroup:RegisterToggle("Screenspace FX", true)
	self._maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
		self._toggleGroup:SetVisible(isVisible)
	end))
	self._maid:GiveTask(self._toggleGroup)

	self._resetButton = SettingsButton.new()
	self._resetButton:SetName("Reset Data")
	self._maid:GiveTask(self._resetButton)
	self.PressedResetData = self._resetButton.Activated

	self._contentsSizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._contentsSizeValue)

	self:_updateLayout()

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsScreen:_updateLayout()
	local PANEL_WIDTH = 450

	local height = 0

	self._toggleGroup:SetWidth(PANEL_WIDTH)
	height += self._toggleGroup:GetSizeValue().Value.Y

	height += 32

	self._resetButton:SetWidth(PANEL_WIDTH)
	self._resetButton.Gui.Position = UDim2.fromOffset(0, height)
	height += self._resetButton:GetSizeValue().Value.Y

	self._contentsSizeValue.Value = Vector3.new(PANEL_WIDTH, height)
end

function SettingsScreen:_render()
	return self:_renderBase({
		ContentsSize = self._contentsSizeValue,
		[Blend.Children] = {
			self._toggleGroup.Gui,
			self._resetButton.Gui,
		},
	})
end

return SettingsScreen
