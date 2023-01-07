--[=[
	@class PlayerCurrency

	Player currency on the server.
]=]

local require = require(script.Parent.loader).load(script)

local PlayerCurrencyBase = require("PlayerCurrencyBase")

local PlayerCurrency = setmetatable({}, PlayerCurrencyBase)
PlayerCurrency.ClassName = "PlayerCurrency"
PlayerCurrency.__index = PlayerCurrency

function PlayerCurrency.new(obj, serviceBag)
	local self = setmetatable(PlayerCurrencyBase.new(obj, serviceBag), PlayerCurrency)

	return self
end

return PlayerCurrency
