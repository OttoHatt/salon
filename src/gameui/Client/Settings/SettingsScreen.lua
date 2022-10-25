--[=[
	@class SettingsScreen

	Settings screen.
]=]

local require = require(script.Parent.loader).load(script)

local BaseScreen = require("BaseScreen")
local Blend = require("Blend")
local Signal = require("Signal")

local SettingsScreen = setmetatable({}, BaseScreen)
SettingsScreen.ClassName = "SettingsScreen"
SettingsScreen.__index = SettingsScreen

function SettingsScreen.new(obj)
	local self = setmetatable(BaseScreen.new(obj), SettingsScreen)

	self:SetDisplayName("Settings")

	self.PressedResetData = Signal.new()
	self._maid:GiveTask(self.PressedResetData)

	self._maid:GiveTask(self:_render():Subscribe(function(gui)
		self.Gui = gui
	end))

	return self
end

function SettingsScreen:_render()
	return self:_renderBase({
		[Blend.Children] = {
			Blend.New("TextButton")({
				BackgroundColor3 = Color3.new(1, 0, 0),
				BackgroundTransparency = 0,
				Size = UDim2.new(0, 100, 0, 40),
				Text = "Reset data",
				[Blend.OnEvent("Activated")] = function()
					self.PressedResetData:Fire()
				end,
			}),
		},
	})
end

return SettingsScreen
