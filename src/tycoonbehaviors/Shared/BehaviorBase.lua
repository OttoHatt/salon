--[=[
	@class BehaviorBase

	Base class for all tycoon behaviors.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local RxInstanceUtils = require("RxInstanceUtils")
local RxBrioUtils = require("RxBrioUtils")
local LinkUtils = require("LinkUtils")

local BehaviorBase = setmetatable({}, BaseObject)
BehaviorBase.ClassName = "BehaviorBase"
BehaviorBase.__index = BehaviorBase

function BehaviorBase.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), BehaviorBase)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	return self
end

function BehaviorBase:ObserveModelBrio()
	return RxInstanceUtils.observeChildrenOfClassBrio(self._obj, "Model"):Pipe({
		RxBrioUtils.onlyLastBrioSurvives(),
	})
end

function BehaviorBase:PromiseBuildableTemplate(maid)
	return LinkUtils.promiseLinkValue(maid, "Source", self._obj)
end

return BehaviorBase
