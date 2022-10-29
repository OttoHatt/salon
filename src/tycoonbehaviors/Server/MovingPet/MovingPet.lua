--[=[
	@class MovingPet

	Moving pet on the server.
	This will hold the pet's value, FX, lifetime, etc.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")

local MovingPet = setmetatable({}, BaseObject)
MovingPet.ClassName = "MovingPet"
MovingPet.__index = MovingPet

function MovingPet.new(obj)
	local self = setmetatable(BaseObject.new(obj), MovingPet)

	

	return self
end

return MovingPet