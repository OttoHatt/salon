--[=[
	@class GameServiceServer

	Ok!
]=]

local require = require(script.Parent.loader).load(script)

local GameServiceServer = {}

function GameServiceServer:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External.
	self._serviceBag:GetService(require("HideBindersServer"))
	self._serviceBag:GetService(require("CurrencyService"))
	self._serviceBag:GetService(require("TycoonService"))
	self._serviceBag:GetService(require("MovingPetModelProvider"))
	self._serviceBag:GetService(require("BehaviorBindersServer"))
end

function GameServiceServer:Start() end

return GameServiceServer
