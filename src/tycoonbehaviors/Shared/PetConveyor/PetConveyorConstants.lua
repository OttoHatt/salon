--[=[
	@class PetConveyorConstants

	Constants for the pet conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.deepReadonly({
	PATH_POINTS_FOLDER_NAME = "PathPoints"
})
