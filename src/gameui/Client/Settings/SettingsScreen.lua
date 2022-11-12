--[=[
	@class SettingsScreen

	Settings screen.
]=]

local require = require(script.Parent.loader).load(script)

local BaseScreen = require("BaseScreen")
local Blend = require("Blend")
local Signal = require("Signal")
local SettingsToggleGroup = require("SettingsToggleGroup")
local BasicPaneUtils = require("BasicPaneUtils")

local SettingsScreen = setmetatable({}, BaseScreen)
SettingsScreen.ClassName = "SettingsScreen"
SettingsScreen.__index = SettingsScreen

function SettingsScreen.new(obj)
	local self = setmetatable(BaseScreen.new(obj), SettingsScreen)

	self:SetDisplayName("Settings")

	self.PressedResetData = Signal.new()
	self._maid:GiveTask(self.PressedResetData)

	self._toggleGroup = SettingsToggleGroup.new()
	self._toggleGroup:RegisterToggle("Music", true)
	self._toggleGroup:RegisterToggle("Extra Speed", false)
	self._maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
		self._toggleGroup:SetVisible(isVisible)
	end))
	self._maid:GiveTask(self._toggleGroup)

	self._contentsSizeValue = Instance.new("Vector3Value")
	self._maid:GiveTask(self._contentsSizeValue)

	self:_updateLayout()

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsScreen:_updateLayout()
	local PANEL_WIDTH = 400

	local height = 0

	self._toggleGroup:SetWidth(PANEL_WIDTH)
	height += self._toggleGroup.Gui.Size.Y.Offset

	self._contentsSizeValue.Value = Vector3.new(PANEL_WIDTH, height)
end

function SettingsScreen:_render()
	return self:_renderBase({
		ContentsSize = self._contentsSizeValue,
		[Blend.Children] = {
			Blend.New"UIListLayout" {
				Padding = UDim.new(0, 16)
			},
			self._toggleGroup.Gui,
			Blend.New("TextButton")({
				BackgroundColor3 = Color3.new(1, 0, 0),
				BackgroundTransparency = .9,
				Size = UDim2.new(0, 100, 0, 40),
				[Blend.OnEvent("Activated")] = function()
					self.PressedResetData:Fire()
				end,
			}),
		},
	})
end

return SettingsScreen
