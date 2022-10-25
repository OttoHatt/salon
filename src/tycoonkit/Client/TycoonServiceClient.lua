--[=[
	@class TycoonServiceClient

	Wooooooooooooooooooooooooo!
]=]

local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")

local TycoonBindersClient = require("TycoonBindersClient")

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

return TycoonServiceClient
