--[=[
	@class PlayerCurrencyUtils

	Utils for working with player currencies.
]=]

local require = require(script.Parent.loader).load(script)

local PlayerCurrencyConstants = require("PlayerCurrencyConstants")
local String = require("String")
local RxBinderUtils = require("RxBinderUtils")
local BinderUtils = require("BinderUtils")
local Binder = require("Binder")
local RxStateStackUtils = require("RxStateStackUtils")

local PlayerCurrencyUtils = {}

function PlayerCurrencyUtils.create(binder)
	assert(Binder.isBinder(binder), "No binder")

	local playerCurrency = Instance.new("Folder")
	playerCurrency.Name = PlayerCurrencyConstants.PLAYER_CURRENCY_NAME
	playerCurrency.Archivable = false

	binder:Bind(playerCurrency)

	return playerCurrency
end

function PlayerCurrencyUtils.observePlayerCurrencyBrio(binder, player)
	assert(Binder.isBinder(binder), "No binder")
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return RxBinderUtils.observeBoundChildClassBrio(binder, player)
end

function PlayerCurrencyUtils.observePlayerCurrency(binder, player)
	return RxBinderUtils.observeBoundChildClassBrio(binder, player):Pipe({
		RxStateStackUtils.topOfStack()
	})
end

function PlayerCurrencyUtils.getPlayerCurrency(binder, player)
	assert(Binder.isBinder(binder), "No binder")
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Bad player")

	return BinderUtils.findFirstChild(binder, player)
end

function PlayerCurrencyUtils.getAttributeName(currencyName)
	assert(type(currencyName) == "string", "Bad currencyName")

	return PlayerCurrencyConstants.CURRENCY_ATTRIBUTE_PREFIX .. currencyName
end

function PlayerCurrencyUtils.getCurrencyName(attributeName)
	assert(type(attributeName) == "string", "Bad attributeName")

	attributeName = String.removePrefix(attributeName, PlayerCurrencyConstants.CURRENCY_ATTRIBUTE_PREFIX)
	return attributeName
end

function PlayerCurrencyUtils.isCurrencyAttribute(attributeName)
	assert(type(attributeName) == "string", "Bad attributeName")

	return String.startsWith(attributeName, PlayerCurrencyConstants.CURRENCY_ATTRIBUTE_PREFIX)
end


return PlayerCurrencyUtils