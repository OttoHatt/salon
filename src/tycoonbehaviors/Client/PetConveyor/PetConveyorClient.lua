--[=[
	@class PetConveyorClient

	Pet conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DEBUG_DRAW = true
local PATH_POINTS_FOLDER_NAME = "PathPoints"

local BehaviorBase = require("BehaviorBase")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local Draw = require("Draw")
local ConveyorLineUtils = require("ConveyorLineUtils")
local Spring = require("Spring")

local PetConveyorClient = setmetatable({}, BehaviorBase)
PetConveyorClient.ClassName = "PetConveyorClient"
PetConveyorClient.__index = PetConveyorClient

function PetConveyorClient.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetConveyorClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid:GiveTask(self:ObserveOrderedPathPointsBrio():Subscribe(function(brio)
		self:_handlePathBrio(brio)
	end))

	return self
end

function PetConveyorClient:ObserveOrderedPathPointsBrio()
	return self:ObserveModelBrio():Pipe({
		RxBrioUtils.switchMapBrio(function(model: Model)
			return RxInstanceUtils.observeLastNamedChildBrio(model, "Folder", PATH_POINTS_FOLDER_NAME)
		end),
		RxBrioUtils.switchMapBrio(function(pathPoints: Folder)
			return RxInstanceUtils.observeChildrenBrio(pathPoints)
		end),
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.map(ConveyorLineUtils.adorneesToPointArray),
	})
end

local function getCatModel(): Model
	-- TODO: TEMPORARY!!!!!!!!!!!!!!!!!!!
	return ReplicatedStorage.Assets.Cat
end

function PetConveyorClient:_handlePathBrio(brio)
	local maid = brio:ToMaid()
	local list = brio:GetValue()

	-- Debug.
	if DEBUG_DRAW then
		for i = 1, #list - 1 do
			local p0 = list[i].Position
			local p1 = list[i + 1].Position

			maid:GiveTask(Draw.vector(p0, p1 - p0, BrickColor.random().Color))
		end
		for i, point in ipairs(list) do
			maid:GiveTask(Draw.labelledPoint(point.Position, i))
		end
	end

	-- Draw pets moving across the path.
	-- Temporary!
	local spring
	local totalTime = 0

	local catModel = getCatModel():Clone()
	catModel.Parent = workspace.CurrentCamera

	maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
		totalTime += dt

		local targetPos = ConveyorLineUtils.getPositionByDistanceIntoPointArray(list, totalTime * 16)
		if not spring then
			spring = Spring.new(targetPos)
			spring.Speed = 16
		end

		if targetPos then
			spring.Target = targetPos
		end
		catModel:PivotTo(CFrame.new(spring.Position) * CFrame.fromAxisAngle(Vector3.yAxis, totalTime))
	end))
end

return PetConveyorClient
