--[=[
	@class OwnerSessionBase

	Inheritence is bad, m'kay?
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local LinkUtils = require("LinkUtils")
local RxLinkUtils = require("RxLinkUtils")

local OwnerSessionBase = setmetatable({}, BaseObject)
OwnerSessionBase.ClassName = "OwnerSessionBase"
OwnerSessionBase.__index = OwnerSessionBase

function OwnerSessionBase.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), OwnerSessionBase)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	return self
end

function OwnerSessionBase:ObserveOwnerBrio()
	return RxLinkUtils.observeLinkValueBrio("Player", self._obj)
end

function OwnerSessionBase:GetPlayer(): Player
	return LinkUtils.getLinkValue("Player", self._obj)
end

function OwnerSessionBase:GetBuildableByName(name: string)
	return self._obj:FindFirstChild(name)
end

function OwnerSessionBase:IsBuildableBuilt(name: string): boolean
	return self:GetBuildableByName(name) ~= nil
end

return OwnerSessionBase