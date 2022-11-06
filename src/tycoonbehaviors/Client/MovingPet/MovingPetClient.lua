--[=[
	@class MovingPet

	Moving pet on the client.
	This is the model that will travel along the conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local DEBUG_DRAW = false

local RunService = game:GetService("RunService")

local BaseObject = require("BaseObject")
local RxBinderUtils = require("RxBinderUtils")
local BehaviorBindersClient = require("BehaviorBindersClient")
local RxBrioUtils = require("RxBrioUtils")
local MovingPetUtils = require("MovingPetUtils")
local ConveyorLineUtils = require("ConveyorLineUtils")
local Math = require("Math")
local MovingPetConstants = require("MovingPetConstants")
local Draw = require("Draw")

local MovingPet = setmetatable({}, BaseObject)
MovingPet.ClassName = "MovingPet"
MovingPet.__index = MovingPet

-- https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua
-- Terrible. D:
-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)
local function inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * math.pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

function MovingPet.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), MovingPet)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._behaviorBinders = self._serviceBag:GetService(BehaviorBindersClient)

	self._maid:GiveTask(RxBinderUtils.observeBoundParentClassBrio(self._behaviorBinders.PetConveyor, self._obj)
		:Pipe({
			RxBrioUtils.switchMapBrio(function(petConveyor)
				return petConveyor:ObserveOrderedPathPointsBrio()
			end),
		})
		:Subscribe(function(brio)
			self:_handlePathPointsBrio(brio)
		end))

	return self
end

function MovingPet:_handlePathPointsBrio(brio)
	-- Calculate time offset for our animation.
	-- We cache this once at the start, as the server clock is prone to drift.
	-- This will result in cleaner-looking animations.
	local clockOffset = workspace:GetServerTimeNow() - MovingPetUtils.getSpawnTime(self._obj)

	local orderedPathPoints = brio:GetValue()
	local topMaid = brio:ToMaid()

	topMaid:GivePromise(MovingPetUtils.promiseModel(topMaid, self._obj)):Then(function(template: Model)
		local petModel = template:Clone()
		petModel.Parent = self._obj

		-- Bind animations! :)
		self._behaviorBinders.AnimatedPetModel:BindClient(template)

		-- Draw pets moving across the path.
		-- Temporary!
		local totalTime = clockOffset

		topMaid:GiveTask(RunService.RenderStepped:Connect(function(dt)
			totalTime += dt

			-- Calculate our cycle.
			local timeFrame = totalTime % MovingPetConstants.TOTAL_CYCLE_DURATION

			-- TODO: WHICH GOES FIRST?
			if timeFrame <= MovingPetConstants.TIME_FRAME_MOVING then
				-- We spend time moving first.
				local rawFac = Math.map(timeFrame, 0, MovingPetConstants.TIME_FRAME_MOVING, 0, 1)
				local lerpedFac = inOutQuad(rawFac, 0, 1, 1)

				local cycleCount = math.floor(totalTime / MovingPetConstants.TOTAL_CYCLE_DURATION)

				local point = ConveyorLineUtils.getPositionByDistanceIntoPointArray(
					orderedPathPoints,
					MovingPetConstants.MOVE_DISTANCE * (cycleCount + lerpedFac)
				)
				petModel:PivotTo(CFrame.new(point))
			else
				-- We spend time still next.
				-- Do nothing! :P
				return
			end
		end))

		if DEBUG_DRAW then
			topMaid:GiveTask(MovingPetUtils.observeValueBrio(self._obj):Subscribe(function(valueBrio)
				local value = valueBrio:GetValue()
				local maid = valueBrio:ToMaid()

				maid:GiveTask(Draw.text(petModel, "$" .. value, Color3.fromRGB(36, 94, 181)))
			end))
		end
	end)
end

return MovingPet
