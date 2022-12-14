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
local CurrencyServiceClient = require("CurrencyServiceClient")
local TycoonTemplateUtils = require("TycoonTemplateUtils")
local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")

local OwnerSessionClient = setmetatable({}, OwnerSessionBase)
OwnerSessionClient.ClassName = "OwnerSessionClient"
OwnerSessionClient.__index = OwnerSessionClient

PromiseRemoteEventMixin:Add(OwnerSessionClient, OwnerSessionConstants.REMOTE_EVENT_NAME)

function OwnerSessionClient.new(obj, serviceBag)
	local self = setmetatable(OwnerSessionBase.new(obj, serviceBag), OwnerSessionClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersClient)
	self._currencyService = self._serviceBag:GetService(CurrencyServiceClient)

	return self
end

function OwnerSessionClient:PromiseCanBuyBuildable(name: string)
	return TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		-- TODO: Unify this logic between server/client.
		-- Currently some weirdness due to with CurrencyService needing a server/client implementation.
		local template = TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate, name)
		if not template then
			return
		end

		local price = TycoonTemplateBuildableUtils.getPrice(template)
		local currency = self:GetPlayerCurrency():GetValue("Coins")

		return currency >= price
	end)
end

function OwnerSessionClient:AttemptBuyBuildable(name: string)
	self:PromiseCanBuyBuildable(name):Then(function(canBuy)
		if canBuy then
			return self:PromiseRemoteEvent():Then(function(remote: RemoteEvent)
				remote:FireServer(OwnerSessionConstants.REQUEST_BUILD, name)
			end)
		end
	end)
end

function OwnerSessionClient:ObserveBuildableClassBrio(name: string)
	-- TODO: Hack, this will break if there's an instance accidentally named the same as a buildable!

	return RxInstanceUtils.observeLastNamedChildBrio(self._obj, "Folder", name):Pipe({
		RxBrioUtils.switchMapBrio(function(model: Model)
			return RxBinderUtils.observeBoundClassBrio(self._tycoonBinders.Buildable, model)
		end),
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

function OwnerSessionClient:AskToResetData()
	-- TODO: MOVE DATA TO A SEPARATE CLASS THIS IS UGLY AND SAD!!!! D:
	self:PromiseRemoteEvent():Then(function(remote: RemoteEvent)
		remote:FireServer(OwnerSessionConstants.REQUEST_RESET_DATA)
	end)
end

function OwnerSessionClient:GetPlayerCurrency()
	return self._currencyService:GetPlayerCurrency(self:GetPlayer())
end

return OwnerSessionClient
