--[=[
	@class TycoonServiceClient

	Wooooooooooooooooooooooooo!
]=]

local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")

local TycoonBindersClient = require("TycoonBindersClient")
local Promise = require("Promise")
local Maid = require("Maid")
local RxBinderUtils = require("RxBinderUtils")
local RxBrioUtils = require("RxBrioUtils")

local TycoonServiceClient = {}

function TycoonServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Internal.
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersClient)
end

function TycoonServiceClient:Start() end

function TycoonServiceClient:GetLocallyOwnedSession()
	for _, session in self._tycoonBinders.OwnerSession:GetAll() do
		if session:GetPlayer() == Players.LocalPlayer then
			return session
		end
	end
end

function TycoonServiceClient:PromiseLocallyOwnedSession()
	local session = self:GetLocallyOwnedSession()
	if session then
		return Promise.resolved(session)
	end

	local promise = Promise.new()
	local maid = Maid.new()

	promise:Finally(function()
		maid:DoCleaning()
	end)

	-- This is overkill! :P
	maid:GiveTask(RxBinderUtils.observeAllBrio(self._tycoonBinders.OwnerSession)
		:Pipe({
			RxBrioUtils.flatMapBrio(function(thisSession)
				return thisSession:ObserveOwnerBrio():Pipe({
					RxBrioUtils.where(function(owner: Player)
						return owner == Players.LocalPlayer
					end),
					RxBrioUtils.map(function()
						return thisSession
					end),
				})
			end),
		})
		:Subscribe(function(brio)
			promise:Resolve(brio:GetValue())
		end))

	return promise
end

return TycoonServiceClient
