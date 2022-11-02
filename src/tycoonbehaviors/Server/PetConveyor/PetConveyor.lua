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
local TycoonBindersServer = require("TycoonBindersServer")
local BinderUtils = require("BinderUtils")
local ObservableList = require("ObservableList")
local Signal = require("Signal")

local PetConveyor = setmetatable({}, BehaviorBase)
PetConveyor.ClassName = "PetConveyor"
PetConveyor.__index = PetConveyor

function PetConveyor.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetConveyor)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._behaviorBinders = self._serviceBag:GetService(BehaviorBindersServer)
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersServer)

	self.CycleStarted = Signal.new()
	self._maid:GiveTask(self.CycleStarted)

	self.CycleResting = Signal.new()
	self._maid:GiveTask(self.CycleResting)

	self._movingPetsList = ObservableList.new()
	self._maid:GiveTask(self._movingPetsList)

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

			-- Create pet!
			local movingPet = MovingPetUtils.instantiateWithModel(
				self._behaviorBinders.MovingPet,
				self._obj,
				game.ReplicatedStorage.Assets.Cat,
				"Kitty",
				100
			)
			maid:GiveTask(movingPet)
			maid:GiveTask(self._movingPetsList:Add(movingPet))

			-- Destroy the pet after a set time.
			-- Hopefully PETA is ok with this...
			local cleanupIndex = self._maid:GiveTask(maid)
			maid:GiveTask(cancellableDelay(petLifetime, function()
				-- Add value of the pet!
				-- Note that this looks bad, but it will be modified as the pet travels along the conveyor belt.
				-- We should find a clearer way of signalling this.
				-- Maybe some kind of 'mutated' modifier price on top of the template's value?
				local petValue = MovingPetUtils.getValue(movingPet)

				-- Cleanup.
				self._maid[cleanupIndex] = nil

				-- Do this after cleaning incase it throws.
				self:GetOwnerSession():GetPlayerCurrency():IncrementValue("Coins", petValue)
			end))

			-- Cycle started..?
			self.CycleStarted:Fire()
			-- Cycle rested..?
			maid:GiveTask(cancellableDelay(MovingPetConstants.TIME_FRAME_MOVING, function()
				self.CycleResting:Fire()
			end))
		end))
	end))

	self._maid:GiveTask(self:PromiseConveyorPointArray():Then(function(pointArray)
		self._maid:GiveTask(self.CycleResting:Connect(function()
			-- Hmmm...
			local allPets = self._movingPetsList:GetList()

			-- Add slight offset over totalTime to account for clock drift on the client.
			local serverTimeNow = workspace:GetServerTimeNow() + 0.03

			-- Find pet closest to each node.
			for _, movingPetInstance in allPets do
				local clockOffset = serverTimeNow - MovingPetUtils.getSpawnTime(movingPetInstance)
				local cycleCount = math.ceil(clockOffset / MovingPetConstants.TOTAL_CYCLE_DURATION)

				local movingPetPosition = ConveyorLineUtils.getPositionByDistanceIntoPointArray(
					pointArray,
					MovingPetConstants.MOVE_DISTANCE * cycleCount
				)

				-- Find a node within a reasonable range.
				local targetNode
				for _, node in pointArray do
					if (node.Position - movingPetPosition).Magnitude < 1 then
						targetNode = node
						break
					end
				end

				if targetNode and targetNode.LinkedUpgrader then
					local targetBuildable = self:GetOwnerSession():GetBuildableByName(targetNode.LinkedUpgrader)
					local upgraderClass = self._behaviorBinders.PetUpgrader:Get(targetBuildable)
					if upgraderClass then
						upgraderClass:Upgrade(movingPetInstance)
					end
				end
			end
		end))
	end))

	return self
end

function PetConveyor:PromiseConveyorPointArray()
	return self:PromiseBuildableTemplate(self._maid):Then(function(buildableTemplate: Model)
		return ConveyorLineUtils.adorneesToPointArray(
			buildableTemplate:FindFirstChild(PetConveyorConstants.PATH_POINTS_FOLDER_NAME):GetChildren()
		)
	end)
end

function PetConveyor:PromiseConveyorModelLength()
	return self:PromiseConveyorPointArray():Then(function(pointArray)
		return ConveyorLineUtils.getLengthOfPointArray(pointArray)
	end)
end

function PetConveyor:GetAllUpgraders()
	-- TODO: DON'T DIRECTLY REFERNCE THE PARENT!!!!
	return BinderUtils.getChildren(self._behaviorBinders.PetUpgrader, self._obj.Parent)
end

function PetConveyor:GetOwnerSession()
	-- TODO: Make this into a generic util! Should go under the base class!
	return BinderUtils.findFirstAncestor(self._tycoonBinders.OwnerSession, self._obj)
end

return PetConveyor
