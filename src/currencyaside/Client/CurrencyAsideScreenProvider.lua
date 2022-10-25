--[=[
	@class CurrencyAsideScreenProvider

	Depths used for currency asides.
]=]

local require = require(script.Parent.loader).load(script)

local GenericScreenGuiProvider = require("GenericScreenGuiProvider")

return GenericScreenGuiProvider.new({
	CurrencyAsideCounters = 100,
})
