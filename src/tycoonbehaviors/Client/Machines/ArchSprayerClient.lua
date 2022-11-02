--[=[
	@class ArchSprayerClient

	Woohoo!
]=]

local require = require(script.Parent.loader).load(script)

local SPRAYER_ON_TIME = 1

local RxBrioUtils = require("RxBrioUtils")
local BehaviorBase = require("BehaviorBase")
local BehaviorBindersClient = require("BehaviorBindersClient")
local RxInstanceUtils = require("RxInstanceUtils")
local RxBinderUtils = require("RxBinderUtils")
local Blend = require("Blend")
local cancellableDelay = require("cancellableDelay")

local ArchSprayerClient = setmetatable({}, BehaviorBase)
ArchSprayerClient.ClassName = "ArchSprayerClient"
ArchSprayerClient.__index = ArchSprayerClient

function ArchSprayerClient.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), ArchSprayerClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._behaviorBinders = serviceBag:GetService(BehaviorBindersClient)

	self._sprayersActive = Instance.new("BoolValue")
	self._sprayersActive.Value = false
	self._maid:GiveTask(self._sprayersActive)

	self._maid:GiveTask(self:_observeUpgraderClassBrio():Subscribe(function(brio)
		local maid = brio:ToMaid()
		local upgraderClass = brio:GetValue()

		maid:GiveTask(upgraderClass.Upgraded:Connect(function()
			self._sprayersActive.Value = true
			maid._delay = cancellableDelay(SPRAYER_ON_TIME, function()
				self._sprayersActive.Value = false
			end)
		end))
		maid:GiveTask(function()
			self._sprayersActive.Value = false
		end)
	end))

	self._maid:GiveTask(self:_observeSprayerParticleEmitterBrio():Subscribe(function(brio)
		local maid = brio:ToMaid()
		local emitter: ParticleEmitter = brio:GetValue()

		maid:GiveTask(Blend.mount(emitter, {
			Enabled = self._sprayersActive,
		}))
	end))

	return self
end

function ArchSprayerClient:_observeUpgraderClassBrio()
	-- TODO: Move to a base class!!!!
	return RxBinderUtils.observeBoundClassBrio(self._behaviorBinders.PetUpgrader, self._obj)
end

function ArchSprayerClient:_observeSprayerParticleEmitterBrio()
	return self:ObserveModelBrio():Pipe({
		RxBrioUtils.switchMapBrio(function(model: Model)
			return RxInstanceUtils.observeChildrenOfNameBrio(model, "BasePart", "Sprayer")
		end),
		RxBrioUtils.flatMapBrio(function(part: BasePart)
			return RxInstanceUtils.observeChildrenOfClassBrio(part, "ParticleEmitter")
		end),
	})
end

return ArchSprayerClient
