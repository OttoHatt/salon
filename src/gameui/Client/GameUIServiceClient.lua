--[=[
	@class GameUIServiceClient

	Woohoo!
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GameScalingUtils = require("GameScalingUtils")
local SidebarPanel = require("SidebarPanel")
local SidebarButton = require("SidebarButton")
local GameScreenProvider = require("GameScreenProvider")

local GameUIServiceClient = {}

function GameUIServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()
end

function GameUIServiceClient:Start()
	do
		local maid = Maid.new()
		self._maid:GiveTask(maid)

		local screenGui: ScreenGui = GameScreenProvider:Get("SIDEBAR")
		screenGui.IgnoreGuiInset = true
		maid:GiveTask(screenGui)

		maid:GiveTask(GameScalingUtils.renderDialogPadding({
			ScreenGui = screenGui,
			Parent = screenGui,
		}):Subscribe())

		local sidebar = SidebarPanel.new()
		sidebar.Gui.Position = UDim2.new(0, 0, 0.5, 0)
		sidebar.Gui.Parent = screenGui
		sidebar:Show()
		maid:GiveTask(GameScalingUtils.observeUIScale(screenGui):Subscribe(function(scale)
			-- TODO: Is modifying the scale like this bad? It feels like an anti-pattern.
			local newScale = scale * (0.75)
			sidebar:SetScale(newScale)
		end))
		maid:GiveTask(sidebar)

		do
			local button = SidebarButton.new()
			button:SetDisplayName("Shop")
			button:SetIcon("rbxassetid://10256727756")
			maid:GiveTask(sidebar:AddSidebarButton(button))
			maid:GiveTask(button)
		end
		do
			local button = SidebarButton.new()
			button:SetDisplayName("Settings")
			button:SetIcon("rbxassetid://10256718116")
			maid:GiveTask(sidebar:AddSidebarButton(button))
			maid:GiveTask(button)
		end
	end
end

function GameUIServiceClient:Destroy()
	self._maid:DoCleaning()
end

return GameUIServiceClient
