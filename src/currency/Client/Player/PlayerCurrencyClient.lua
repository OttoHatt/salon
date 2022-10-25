--[=[
	@class PlayerCurrencyClient

	Player currency on the client.
]=]

local require = require(script.Parent.loader).load(script)

local PlayerCurrencyBase = require("PlayerCurrencyBase")

local PlayerCurrencyClient = setmetatable({}, PlayerCurrencyBase)
PlayerCurrencyClient.ClassName = "PlayerCurrencyClient"
PlayerCurrencyClient.__index = PlayerCurrencyClient

function PlayerCurrencyClient.new(obj, serviceBag)
	local self = setmetatable(PlayerCurrencyBase.new(obj, serviceBag), PlayerCurrencyClient)

	return self
end

return PlayerCurrencyClient