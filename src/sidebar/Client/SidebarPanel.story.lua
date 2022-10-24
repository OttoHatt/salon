local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local SidebarPanel = require("SidebarPanel")
local StoryBarUtils = require("StoryBarUtils")
local StoryBarPaneUtils = require("StoryBarPaneUtils")
local SidebarButton = require("SidebarButton")

return function(target)
	local maid = Maid.new()

	local sidebar = SidebarPanel.new()
	sidebar.Gui.Position = UDim2.new(0, 16, 0.5, 0)
	sidebar.Gui.Parent = target
	sidebar:SetScale(1)
	maid:GiveTask(sidebar)

	do
		local button = SidebarButton.new()
		button:SetDisplayName("Shop")
		button:SetIcon("rbxassetid://10256727756")
		maid:GiveTask(button)
		maid:GiveTask(sidebar:AddSidebarButton(button))
	end
	do
		local button = SidebarButton.new()
		button:SetDisplayName("Codes")
		button:SetIcon("rbxassetid://10256738707")
		maid:GiveTask(button)
		maid:GiveTask(sidebar:AddSidebarButton(button))
	end
	do
		local button = SidebarButton.new()
		button:SetDisplayName("Settings")
		button:SetIcon("rbxassetid://10256718116")
		maid:GiveTask(button)
		maid:GiveTask(sidebar:AddSidebarButton(button))
	end

	-- Bind UI visiblity to switch.
	local bar = StoryBarUtils.createStoryBar(maid, target)
	StoryBarPaneUtils.makeVisibleSwitch(bar, sidebar)

	return function()
		maid:DoCleaning()
	end
end