--[=[
	@class GameUIServiceClient

	Woohoo!
]=]

-- TODO: This whole class is horrible and needs to be separated in the near future.

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GameScalingUtils = require("GameScalingUtils")
local SidebarPanel = require("SidebarPanel")
local SidebarButton = require("SidebarButton")
local GameScreenProvider = require("GameScreenProvider")
local SettingsScreen = require("SettingsScreen")
local CurrencyAside = require("CurrencyAside")
local CurrencyAsideList = require("CurrencyAsideList")
local CurrencyDiscoveryService = require("CurrencyDiscoveryService")
local CurrencyServiceClient = require("CurrencyServiceClient")

local GameUIServiceClient = {}

function GameUIServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()

	self._currencyDiscoveryService = serviceBag:GetService(CurrencyDiscoveryService)
	self._currencyServiceClient = serviceBag:GetService(CurrencyServiceClient)
end

local function makePaddedScreenGui(maid, name: string): ScreenGui
	-- TODO: This sucks.
	local screenGui: ScreenGui = GameScreenProvider:Get(name)
	screenGui.IgnoreGuiInset = true
	maid:GiveTask(screenGui)

	maid:GiveTask(GameScalingUtils.renderDialogPadding({
		ScreenGui = screenGui,
		Parent = screenGui,
	}):Subscribe())

	return screenGui
end

function GameUIServiceClient:Start()
	do
		local maid = Maid.new()
		self._maid:GiveTask(maid)

		local screenGui = makePaddedScreenGui(maid, "SIDEBAR")

		local sidebar = SidebarPanel.new()
		sidebar.Gui.Position = UDim2.new(0, 0, 0.5, 0)
		sidebar.Gui.Parent = screenGui
		sidebar:Show()
		maid:GiveTask(GameScalingUtils.observeUIScale(screenGui):Subscribe(function(scale)
			sidebar:SetScale(scale * 0.75)
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

			-- TODO: Move this!
			local settingsScreen = SettingsScreen.new()
			settingsScreen.Gui.Parent = screenGui
			maid:GiveTask(settingsScreen.PressedResetData:Connect(function()
				-- TODO: Move this!!!!!!
				local tycoonServiceClient = self._serviceBag:GetService(require("TycoonServiceClient"))
				local session = tycoonServiceClient:GetLocallyOwnedSession()
				session:AskToResetData()
			end))
			maid:GiveTask(settingsScreen)
			maid:GiveTask(button:ObserveIsChosen():Subscribe(function(isChosen)
				settingsScreen:SetVisible(isChosen)
			end))
		end
	end
	do
		local topMaid = Maid.new()
		self._maid:GiveTask(topMaid)

		local screenGui = makePaddedScreenGui(topMaid, "CURRENCY")

		local currencyAsideList = CurrencyAsideList.new()
		currencyAsideList.Gui.Position = UDim2.new(1, 0, 0.5, 0)
		currencyAsideList.Gui.AnchorPoint = Vector2.new(1, 0.5)
		currencyAsideList.Gui.Parent = screenGui
		topMaid:GiveTask(GameScalingUtils.observeUIScale(screenGui):Subscribe(function(scale)
			currencyAsideList:SetScale(scale)
		end))
		currencyAsideList:Show()
		topMaid:GiveTask(currencyAsideList)

		topMaid:GiveTask(self._currencyServiceClient:ObserveLocalPlayerCurrencyBrio():Subscribe(function(brio)
			local currency = brio:GetValue()
			local maid = brio:ToMaid()

			for _, configClass in self._currencyDiscoveryService:GetAll() do
				local aside = CurrencyAside.new()
				aside:SetIcon(configClass:GetIcon())
				maid:GiveTask(
					currency
						:ObserveValue(configClass:GetKeyName(), configClass:GetDefaultValue())
						:Subscribe(function(value: number)
							aside:SetCount(value)
						end)
				)
				maid:GiveTask(currencyAsideList:AddAside(aside))
				maid:GiveTask(aside)
			end
		end))
	end
end

function GameUIServiceClient:Destroy()
	self._maid:DoCleaning()
end

return GameUIServiceClient
