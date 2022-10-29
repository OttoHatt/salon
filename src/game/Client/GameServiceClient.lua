--[=[
	@class GameServiceClient

	Ok!
]=]

local require = require(script.Parent.loader).load(script)

local SoundscapeServiceClient = require("SoundscapeServiceClient")
local TycoonServiceClient = require("TycoonServiceClient")
local StudioTeleportServiceClient = require("StudioTeleportServiceClient")
local GameUIServiceClient = require("GameUIServiceClient")
local CurrencyServiceClient = require("CurrencyServiceClient")
local BehaviorBindersClient = require("BehaviorBindersClient")

local GameServiceClient = {}

function GameServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External.
	self._serviceBag:GetService(SoundscapeServiceClient)
	self._serviceBag:GetService(TycoonServiceClient)
	self._serviceBag:GetService(StudioTeleportServiceClient)
	self._serviceBag:GetService(CurrencyServiceClient)
	self._serviceBag:GetService(GameUIServiceClient)
	self._serviceBag:GetService(BehaviorBindersClient)
end

function GameServiceClient:Start()
	
end

return GameServiceClient