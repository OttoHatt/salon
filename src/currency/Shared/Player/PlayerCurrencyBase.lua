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

function PlayerCurrencyBase:GetValue(currencyName)
	assert(type(currencyName) == "string", "Bad currencyName")

	local config = self._currencyDiscoveryService:GetConfig(currencyName)
	assert(config, ("Bad currencyName %s!"):format(tostring(currencyName)))

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	-- self:EnsureInitialized(currencyName, defaultValue)

	local value = self._obj:GetAttribute(attributeName)
	if value == nil then
		return config:GetDefaultValue()
	end

	return value
end

function PlayerCurrencyBase:SetValue(currencyName, value)
	assert(type(currencyName) == "string", "Bad currencyName")

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	self._obj:SetAttribute(attributeName, value)
end

function PlayerCurrencyBase:IncrementValue(currencyName, toAdd)
	assert(type(currencyName) == "string", "Bad currencyName")

	local currentValue = self:GetValue(currencyName)
	self:SetValue(currencyName, currentValue + toAdd)
end

function PlayerCurrencyBase:ObserveValue(currencyName)
	assert(type(currencyName) == "string", "Bad currencyName")

	local config = self._currencyDiscoveryService:GetConfig(currencyName)
	assert(config, ("Bad currencyName %s!"):format(tostring(currencyName)))

	local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)

	-- self:EnsureInitialized(currencyName, defaultValue)

	return RxAttributeUtils.observeAttribute(self._obj, attributeName, config:GetDefaultValue())
end

return PlayerCurrencyBase
