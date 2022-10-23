--[=[
	@class TycoonServiceClient

	Wooooooooooooooooooooooooo!
]=]

local require = require(script.Parent.loader).load(script)

local TycoonBindersClient = require("TycoonBindersClient")

local TycoonServiceClient = {}

function TycoonServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Internal.
	self._serviceBag:GetService(TycoonBindersClient)
end

function TycoonServiceClient:Start() end

return TycoonServiceClient
