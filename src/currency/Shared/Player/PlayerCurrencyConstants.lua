--[=[
	@class PlayerCurrencyConstants
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.readonly({
	CURRENCY_ATTRIBUTE_PREFIX = "Currency_";
	PLAYER_CURRENCY_NAME = "PlayerCurrency";
})