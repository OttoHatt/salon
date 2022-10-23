--[=[
	@class TycoonSpawn

	Wow!
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")

local TycoonSpawn = setmetatable({}, BaseObject)
TycoonSpawn.ClassName = "TycoonSpawn"
TycoonSpawn.__index = TycoonSpawn

function TycoonSpawn.new(obj)
	local self = setmetatable(BaseObject.new(obj), TycoonSpawn)

	

	return self
end

return TycoonSpawn