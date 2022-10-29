--[=[
	@class MovingPetConstants

	Constants for moving pets.
	This mostly involves constants surrounding the timing of the animations.
	These are exposed to the server as we may need to use them to calculate the longetivity of pets.
	Since we'll want to send a rough timeframe of when pets exist to the client, so that they're destroyed simultaneously.
]=]

local require = require(script.Parent.loader).load(script)

local Table = require("Table")

local CONSTANTS = {
	TIME_FRAME_MOVING = 2.5,
	TIME_FRAME_STILL = 1,
	MOVE_DISTANCE = 16,
}

-- TODO: Illegal?
CONSTANTS.TOTAL_CYCLE_DURATION = CONSTANTS.TIME_FRAME_MOVING + CONSTANTS.TIME_FRAME_STILL

return Table.deepReadonly(CONSTANTS)