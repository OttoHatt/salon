--[=[
	@class GameScreenProvider
]=]

local require = require(script.Parent.loader).load(script)

local GenericScreenGuiProvider = require("GenericScreenGuiProvider")

return GenericScreenGuiProvider.new({
	SIDEBAR = 1,
	MENU = 2,
})
