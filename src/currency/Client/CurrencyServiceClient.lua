--[=[
	@class CurrencyServiceClient

	Currencies on the client.
]=]

local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")

local PlayerCurrencyUtils = require("PlayerCurrencyUtils")
local CurrencyBindersClient = require("CurrencyBindersClient")

local CurrencyServiceClient = {}

function CurrencyServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Internal.
	self._serviceBag:GetService(require("CurrencyDiscoveryService"))
	self._binders = self._serviceBag:GetService(CurrencyBindersClient)
end

function CurrencyServiceClient:ObserveLocalPlayerCurrencyBrio()
	return self:ObservePlayerCurrencyBrio(Players.LocalPlayer)
end

function CurrencyServiceClient:ObservePlayerCurrencyBrio(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return PlayerCurrencyUtils.observePlayerCurrencyBrio(self._binders.PlayerCurrency, player)
end

function CurrencyServiceClient:GetPlayerCurrency(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return PlayerCurrencyUtils.getPlayerCurrency(self._binders.PlayerCurrency, player)
end

return CurrencyServiceClient