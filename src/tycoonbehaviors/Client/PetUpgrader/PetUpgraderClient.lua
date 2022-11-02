--[=[
	@class PetUpgraderClient

	Wow!
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Signal = require("Signal")
local RxInstanceUtils = require("RxInstanceUtils")

local PetUpgraderClient = setmetatable({}, BaseObject)
PetUpgraderClient.ClassName = "PetUpgraderClient"
PetUpgraderClient.__index = PetUpgraderClient

function PetUpgraderClient.new(obj)
	local self = setmetatable(BaseObject.new(obj), PetUpgraderClient)

	self.Upgraded = Signal.new()
	self._maid:GiveTask(self.Upgraded)

	self._maid:GiveTask(
		RxInstanceUtils.observeLastNamedChildBrio(self._obj, "RemoteEvent", "RemoteEvent"):Subscribe(function(brio)
			local remote: RemoteEvent = brio:GetValue()
			local maid = brio:ToMaid()

			maid:GiveTask(remote.OnClientEvent:Connect(function()
				self.Upgraded:Fire()
			end))
		end)
	)

	return self
end

return PetUpgraderClient
