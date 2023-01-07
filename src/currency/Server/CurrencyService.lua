--[=[
	@class CurrencyService

	Provides easy access to player currency on the server.
]=]

local require = require(script.Parent.loader).load(script)

local PlayerCurrencyUtils = require("PlayerCurrencyUtils")
local CurrencyBindersServer = require("CurrencyBindersServer")

local CurrencyService = {}

function CurrencyService:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External.
	self._serviceBag:GetService(require("PlayerDataStoreService"))
	self._serviceBag:GetService(require("CurrencyBindersServer"))

	-- Internal.
	self._serviceBag:GetService(require("CurrencyDiscoveryService"))
	self._binders = self._serviceBag:GetService(CurrencyBindersServer)
end

function CurrencyService:GetPlayerCurrency(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return PlayerCurrencyUtils.getPlayerCurrency(self._binders.PlayerCurrency, player)
end

function CurrencyService:ObservePlayerCurrencyBrio(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return PlayerCurrencyUtils.observePlayerCurrencyBrio(self._binders.PlayerCurrency, player)
end

return CurrencyService
