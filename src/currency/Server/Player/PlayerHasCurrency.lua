--[=[
	@class PlayerHasCurrency

	Currency provider. Mostly copied from Quenty's settings stuff.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local PlayerCurrencyUtils = require("PlayerCurrencyUtils")
local CurrencyBindersServer = require("CurrencyBindersServer")
local PlayerDataStoreService = require("PlayerDataStoreService")

local PlayerHasCurrency = setmetatable({}, BaseObject)
PlayerHasCurrency.ClassName = "PlayerHasCurrency"
PlayerHasCurrency.__index = PlayerHasCurrency

function PlayerHasCurrency.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), PlayerHasCurrency)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._currencyBindersServer = self._serviceBag:GetService(CurrencyBindersServer)
	self._playerDataStoreService = self._serviceBag:GetService(PlayerDataStoreService)

	self:_promiseLoadCurrency()

	return self
end

function PlayerHasCurrency:_promiseLoadCurrency()
	self._currencies = PlayerCurrencyUtils.create(self._currencyBindersServer.PlayerCurrency)
	self._maid:GiveTask(self._currencies)

	self._maid:GivePromise(self._playerDataStoreService:PromiseDataStore(self._obj))
		:Then(function(dataStore)
			-- Ensure we've fully loaded before we parent.
			-- This should ensure the cache is mostly instant.

			local subStore = dataStore:GetSubStore("currency")

			return dataStore:Load("currency", {})
				:Then(function(currency)
					for currencyName, value in pairs(currency) do
						local attributeName = PlayerCurrencyUtils.getAttributeName(currencyName)
						self._currencies:SetAttribute(attributeName, value)
					end

					self._maid:GiveTask(self._currencies.AttributeChanged:Connect(function(attributeName)
						self:_handleAttributeChanged(subStore, attributeName)
					end))
				end)
		end)
		:Catch(function(err)
			warn(("[PlayerHasCurrency] - Failed to load currencies for player. %s"):format(tostring(err)))
		end)
		:Finally(function()
			-- Parent anyway...
			self._currencies.Parent = self._obj
		end)
end

function PlayerHasCurrency:_handleAttributeChanged(subStore, attributeName)
	if not PlayerCurrencyUtils.isCurrencyAttribute(attributeName) then
		return
	end

	-- Write the new value.
	local currencyName = PlayerCurrencyUtils.getCurrencyName(attributeName)
	local newValue = self._currencies:GetAttribute(attributeName)
	subStore:Store(currencyName, newValue)
end

return PlayerHasCurrency