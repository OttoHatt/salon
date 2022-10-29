--[=[
	@class PetConveyor

	Pet conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local BehaviorBase = require("BehaviorBase")
local Rx = require("Rx")
local MovingPetUtils = require("MovingPetUtils")
local BehaviorBindersServer = require("BehaviorBindersServer")
local MovingPetConstants = require("MovingPetConstants")

local PetConveyor = setmetatable({}, BehaviorBase)
PetConveyor.ClassName = "PetConveyor"
PetConveyor.__index = PetConveyor

function PetConveyor.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetConveyor)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._behaviorBinders = self._serviceBag:GetService(BehaviorBindersServer)

	-- TODO: REMOVE!
	-- Spawn pets occasionally.
	self._maid:GiveTask(Rx.timer(2, MovingPetConstants.TOTAL_CYCLE_DURATION):Subscribe(function()
		MovingPetUtils.instantiateWithModel(
			self._behaviorBinders.MovingPet,
			self._obj,
			game.ReplicatedStorage.Assets.Cat,
			"Kitty",
			100
		)
	end))

	return self
end

return PetConveyor