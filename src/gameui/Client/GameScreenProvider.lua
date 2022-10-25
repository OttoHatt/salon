--[=[
	@class GameScreenProvider
]=]

local require = require(script.Parent.loader).load(script)

local GenericScreenGuiProvider = require("GenericScreenGuiProvider")

return GenericScreenGuiProvider.new({
	SIDEBAR = 1,
	CURRENCY = 2,
	MENU = 2,
})
