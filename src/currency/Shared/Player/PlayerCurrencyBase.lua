--[=[
	@class PlayerCurrencyBase

	Currency object underneath players
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local PlayerCurrencyUtils = require("PlayerCurrencyUtils")
local RxAttributeUtils = require("RxAttributeUtils")
local CurrencyDiscoveryService = require("CurrencyDiscoveryService")

local PlayerCurrencyBase = setmetatable({}, BaseObject)
PlayerCurrencyBase.ClassName = "PlayerCurrencyBase"
PlayerCurrencyBase.__index = PlayerCurrencyBase

function PlayerCurrencyBase.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), PlayerCurrencyBase)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._currencyDiscoveryService = serviceBag:GetService(CurrencyDiscoveryService)

	return self
end

function PlayerCurrencyBase:GetValue(currencyName, defaultValue)
	assert(type(currencyName) == "string", "Bad currencyName")
	assert(defaultValue ~= nil, "defaultValue cannot be nil")

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	-- self:EnsureInitialized(currencyName, defaultValue)

	local value = self._obj:GetAttribute(attributeName)
	if value == nil then
		return defaultValue
	end

	return value
end

function PlayerCurrencyBase:SetValue(currencyName, value)
	assert(type(currencyName) == "string", "Bad currencyName")

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	self._obj:SetAttribute(attributeName, value)
end

function PlayerCurrencyBase:ObserveValue(currencyName, defaultValue)
	assert(type(currencyName) == "string", "Bad currencyName")
	assert(defaultValue ~= nil, "defaultValue cannot be nil")

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	-- self:EnsureInitialized(currencyName, defaultValue)

	return RxAttributeUtils.observeAttribute(self._obj, attributeName, defaultValue)
end

return PlayerCurrencyBase