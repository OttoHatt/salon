--[=[
	@class TycoonService

	Tycoon service! Money!! I am literally Mr Krabs.
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local TycoonBindersServer = require("TycoonBindersServer")
local TycoonSpawnUtils = require("TycoonSpawnUtils")
local RxPlayerUtils = require("RxPlayerUtils")

local TycoonService = {}

function TycoonService:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Internal.
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersServer)

	self._maid = Maid.new()
end

function TycoonService:Start()
	self._maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
		local player: Player = brio:GetValue()
		local maid = brio:ToMaid()

		local vacantTycoon: Folder =
			TycoonSpawnUtils.findVacantTycoon(self._tycoonBinders.TycoonSpawn, self._tycoonBinders.OwnerSession)
		assert(vacantTycoon, "[TycoonService] Couldn't get tycoon spawn! Server over capacity?????")

		maid:GiveTask(TycoonSpawnUtils.createOwnSession(self._tycoonBinders.OwnerSession, vacantTycoon, player))
	end))
end

function TycoonService:Destroy()
	self._maid:DoCleaning()
end

return TycoonService
