--[=[
	@class Buildable

	Ok!
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")

local Buildable = setmetatable({}, BaseObject)
Buildable.ClassName = "Buildable"
Buildable.__index = Buildable

function Buildable.new(obj)
	local self = setmetatable(BaseObject.new(obj), Buildable)

	

	return self
end

return Buildable