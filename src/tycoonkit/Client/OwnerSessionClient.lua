--[=[
	@class OwnerSessionClient

	Owner session! (but on the client this time wow)
]=]

local require = require(script.Parent.loader).load(script)

local PromiseRemoteEventMixin = require("PromiseRemoteEventMixin")
local OwnerSessionBase = require("OwnerSessionBase")
local OwnerSessionConstants = require("OwnerSessionConstants")
local RxInstanceUtils = require("RxInstanceUtils")
local RxBinderUtils = require("RxBinderUtils")
local RxBrioUtils = require("RxBrioUtils")
local TycoonBindersClient = require("TycoonBindersClient")
local Rx = require("Rx")

local OwnerSessionClient = setmetatable({}, OwnerSessionBase)
OwnerSessionClient.ClassName = "OwnerSessionClient"
OwnerSessionClient.__index = OwnerSessionClient

PromiseRemoteEventMixin:Add(OwnerSessionClient, OwnerSessionConstants.REMOTE_EVENT_NAME)

function OwnerSessionClient.new(obj, serviceBag)
	local self = setmetatable(OwnerSessionBase.new(obj, serviceBag), OwnerSessionClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersClient)

	return self
end

function OwnerSessionClient:AttemptBuyBuildable(name: string)
	self:PromiseRemoteEvent():Then(function(remote: RemoteEvent)
		remote:FireServer(OwnerSessionConstants.REQUEST_BUILD, name)
	end)
end

function OwnerSessionClient:ObserveBuildableClassBrio(name: string)
	-- TODO: Hack, this will break if there's an instance accidentally named the same as a buildable!

	return RxInstanceUtils.observeLastNamedChildBrio(self._obj, "Folder", name):Pipe({
		RxBrioUtils.switchMapBrio(function(model: Model)
			return RxBinderUtils.observeBoundClassBrio(self._tycoonBinders.Buildable, model)
		end)
	})
end

function OwnerSessionClient:ObserveBuildableExists(name: string)
	return self:ObserveBuildableClassBrio(name):Pipe({
		Rx.defaultsToNil,
		RxBrioUtils.flattenToValueAndNil,
		Rx.map(function(class)
			return class ~= nil
		end),
	})
end

return OwnerSessionClient
