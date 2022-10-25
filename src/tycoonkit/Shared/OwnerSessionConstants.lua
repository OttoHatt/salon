--[=[
	@class OwnerSessionConstants

	[OwnerSession] constants.
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

return Table.deepReadonly({
	REMOTE_EVENT_NAME = "OwnerSessionRemoteEvent",

	REQUEST_BUILD = "RequestBuild",
	REQUEST_RESET_DATA = "ReqestResetData"
})