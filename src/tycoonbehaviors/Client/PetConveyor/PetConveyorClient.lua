--[=[
	@class PetConveyorClient

	Pet conveyor!
]=]

local require = require(script.Parent.loader).load(script)

local DEBUG_DRAW = true

local BehaviorBase = require("BehaviorBase")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local Draw = require("Draw")
local ConveyorLineUtils = require("ConveyorLineUtils")
local Rx = require("Rx")
local PetConveyorConstants = require("PetConveyorConstants")

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
			return RxInstanceUtils.observeLastNamedChildBrio(
				model,
				"Folder",
				PetConveyorConstants.PATH_POINTS_FOLDER_NAME
			)
		end),
		RxBrioUtils.switchMapBrio(function(pathPoints: Folder)
			return RxInstanceUtils.observeChildrenBrio(pathPoints)
		end),
		RxBrioUtils.reduceToAliveList(),
		Rx.throttleDefer(),
		RxBrioUtils.map(ConveyorLineUtils.adorneesToPointArray),
		Rx.cache(),
	})
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
end

return PetConveyorClient
