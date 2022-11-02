--[=[
	@class PetUpgrader

	WOw!
]=]

local require = require(script.Parent.loader).load(script)

local BehaviorBase = require("BehaviorBase")

local PetUpgrader = setmetatable({}, BehaviorBase)
PetUpgrader.ClassName = "PetUpgrader"
PetUpgrader.__index = PetUpgrader

function PetUpgrader.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PetUpgrader)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- TODO: Deprecate this, and instead simulate on the client!!
	self._remoteEvent = Instance.new("RemoteEvent")
	self._remoteEvent.Archivable = false
	self._remoteEvent.Parent = self._obj

	return self
end

function PetUpgrader:Upgrade(movingPetInstance: Instance)
	movingPetInstance:SetAttribute("Value", movingPetInstance:GetAttribute("Value") * 2)
	self._remoteEvent:FireAllClients()
end

return PetUpgrader
