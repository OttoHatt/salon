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
local ConveyorLineUtils = require("ConveyorLineUtils")
local cancellableDelay = require("cancellableDelay")
local Maid = require("Maid")
local PetConveyorConstants = require("PetConveyorConstants")

local PetConveyor = setmetatable({}, BehaviorBase)
PetConveyor.ClassName = "PetConveyor"
PetConveyor.__index = PetConveyor

function PetConveyor.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetConveyor)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._behaviorBinders = self._serviceBag:GetService(BehaviorBindersServer)

	-- TODO: Schedule destruction on the server *and* client.
	-- There will be some latency in when the destroy command is sent and recieved.
	-- This means that for a brief second, pets will move *beyond* the conveyor before disappearing.
	-- This could look quite goofy, especially if players have a high ping.

	-- TODO: REMOVE!
	-- Spawn pets occasionally.
	self._maid:GivePromise(self:PromiseConveyorModelLength():Then(function(conveyorLength: number)
		local petLifetime = MovingPetConstants.TOTAL_CYCLE_DURATION
			* (conveyorLength / MovingPetConstants.MOVE_DISTANCE)

		self._maid:GiveTask(Rx.timer(2, MovingPetConstants.TOTAL_CYCLE_DURATION):Subscribe(function()
			local maid = Maid.new()

			-- Destroy the pet after a set time.
			-- Hopefully PETA is ok with this...
			local cleanupIndex = self._maid:GiveTask(maid)
			maid:GiveTask(cancellableDelay(petLifetime, function()
				self._maid[cleanupIndex] = nil
			end))

			maid:GiveTask(
				MovingPetUtils.instantiateWithModel(
					self._behaviorBinders.MovingPet,
					self._obj,
					game.ReplicatedStorage.Assets.Cat,
					"Kitty",
					100
				)
			)
		end))
	end))

	return self
end

function PetConveyor:PromiseConveyorModelLength()
	return self:PromiseBuildableTemplate(self._maid):Then(function(buildableTemplate: Model)
		local pointArray = ConveyorLineUtils.adorneesToPointArray(
			buildableTemplate:FindFirstChild(PetConveyorConstants.PATH_POINTS_FOLDER_NAME):GetChildren()
		)
		return ConveyorLineUtils.getLengthOfPointArray(pointArray)
	end)
end

return PetConveyor
