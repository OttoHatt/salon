--[=[
	@class PetConveyor

	Pet conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local BehaviorBase = require("BehaviorBase")

local PetConveyor = setmetatable({}, BehaviorBase)
PetConveyor.ClassName = "PetConveyor"
PetConveyor.__index = PetConveyor

function PetConveyor.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetConveyor)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	return self
end

return PetConveyor