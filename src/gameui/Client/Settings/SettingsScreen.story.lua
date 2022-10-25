local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local StoryBarUtils = require("StoryBarUtils")
local StoryBarPaneUtils = require("StoryBarPaneUtils")
local SettingsScreen = require("SettingsScreen")

return function(target)
	local maid = Maid.new()

	local settingsScreen = SettingsScreen.new()
	settingsScreen.Gui.Parent = target
	settingsScreen:Show()
	maid:GiveTask(settingsScreen)

	-- Bind UI visiblity to switch.
	local bar = StoryBarUtils.createStoryBar(maid, target)
	StoryBarPaneUtils.makeVisibleSwitch(bar, settingsScreen)

	return function()
		maid:DoCleaning()
	end
end