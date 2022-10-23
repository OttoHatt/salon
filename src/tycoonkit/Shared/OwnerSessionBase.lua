--[=[
	@class OwnerSessionBase

	Inheritence is bad, m'kay?
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")

local OwnerSessionBase = setmetatable({}, BaseObject)
OwnerSessionBase.ClassName = "OwnerSessionBase"
OwnerSessionBase.__index = OwnerSessionBase

function OwnerSessionBase.new(obj, serviceBag)
	local self = setmetatable(BaseObject.new(obj), OwnerSessionBase)

	self._serviceBag = assert(serviceBag, "No serviceBag")

	return self
end

function OwnerSessionBase:IsBuildableBuilt(name: string): boolean
	return self._obj:FindFirstChild(name) ~= nil
end

return OwnerSessionBase