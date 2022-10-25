--[=[
	@class CurrencyAsideServiceClient

	Creates and manages an aside for the player.
]=]

local require = require(script.Parent.loader).load(script)

local CurrencyAsideScreenProvider = require("CurrencyAsideScreenProvider")
local CurrencyDiscoveryService = require("CurrencyDiscoveryService")
local CurrencyAsideList = require("CurrencyAsideList")
local GameScalingUtils = require("GameScalingUtils")
local CurrencyAside = require("CurrencyAside")
local CurrencyServiceClient = require("CurrencyServiceClient")
local Maid = require("Maid")

local CurrencyAsideServiceClient = {}

function CurrencyAsideServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._discoveryService = self._serviceBag:GetService(CurrencyDiscoveryService)
	self._currencyService = self._serviceBag:GetService(CurrencyServiceClient)

	self._maid = Maid.new()
end

function CurrencyAsideServiceClient:_handlePlayerCurrency(brio)
	local playerCurrency = brio:GetValue()
	local maid = brio:ToMaid()

	local screenGui = CurrencyAsideScreenProvider:Get("CurrencyAsideCounters")

	local asideList = CurrencyAsideList.new(self._serviceBag)
	maid:GiveTask(asideList)

	for _, info in self._discoveryService:GetAll() do
		local aside = CurrencyAside.new()
		aside:SetIcon(info:GetIcon())
		maid:GiveTask(playerCurrency:ObserveValue(info:GetKeyName(), 0):Subscribe(function(amount)
			aside:SetCount(amount)
		end))
		maid:GiveTask(GameScalingUtils.observeUIScale(screenGui):Subscribe(function(scale)
			aside:SetScale(scale)
		end))
		maid:GiveTask(asideList:AddAside(aside))
		maid:GiveTask(aside)
	end

	maid:GiveTask(GameScalingUtils.renderDialogPadding({
		ScreenGui = screenGui,
		Parent = screenGui,
	}):Subscribe())

	asideList.Gui.Parent = screenGui
	asideList:Show()
end

function CurrencyAsideServiceClient:Start()
	self._maid:GiveTask(self._currencyService:ObserveLocalPlayerCurrencyBrio():Subscribe(function(brio)
		self:_handlePlayerCurrency(brio)
	end))
end

function CurrencyAsideServiceClient:Destroy()
	self._maid:DoCleaning()
end

return CurrencyAsideServiceClient
