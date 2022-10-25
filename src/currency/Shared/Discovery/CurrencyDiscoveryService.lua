--[=[
	@class CurrencyDiscoveryService

	Gets and caches currencies.
]=]

local require = require(script.Parent.loader).load(script)

local CurrencyConfig = require("CurrencyConfig")
local CurrencyProvider = require("CurrencyProvider")
local Table = require("Table")

local CurrencyDiscoveryService = {}

function CurrencyDiscoveryService:Init(serviceBag)
	assert(not self._initialized, "Already initialized!")
	self:_ensureIntitialization()

	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Internal.
	self._currencyProvider = self._serviceBag:GetService(CurrencyProvider)
end

function CurrencyDiscoveryService:_ensureIntitialization()
	if not self._initialized then
		self._initialized = true

		self._cache = {}
	end
end

function CurrencyDiscoveryService:GetConfig(name: string)
	local config = self._currencyProvider:Get(name)
	assert(config, ("[CurrencyDiscovery] Invalid currency %q!"):format(tostring(name)))

	return self:GetCurrencyConfigFromInstance(config)
end

function CurrencyDiscoveryService:GetCurrencyConfigFromInstance(instance: Configuration)
	assert(typeof(instance) == "Instance", "Bad instance")
	self:_ensureIntitialization()

	local keyName = instance.Name

	if not self._cache[keyName] then
		self._cache[keyName] = CurrencyConfig.new(instance)
	end

	return self._cache[keyName]
end

function CurrencyDiscoveryService:GetAll()
	self:_ensureIntitialization()

	for _, config: Configuration in self._currencyProvider:GetAll() do
		self:GetCurrencyConfigFromInstance(config)
	end

	return Table.toList(self._cache)
end

return CurrencyDiscoveryService
