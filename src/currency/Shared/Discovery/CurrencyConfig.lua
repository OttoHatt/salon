--[=[
	@class CurrencyConfig

	Wrapper over a currency config instance.
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")

local CurrencyConfig = setmetatable({}, BaseObject)
CurrencyConfig.ClassName = "CurrencyConfig"
CurrencyConfig.__index = CurrencyConfig

function CurrencyConfig.new(obj: Instance)
	local self = setmetatable(BaseObject.new(obj), CurrencyConfig)

	self._keyName = obj.Name -- Internal named used for datastores and identification.

	self._displayName = obj:GetAttribute("DisplayName")
	assert(typeof(self._displayName) == "string", "Bad DisplayName")

	self._defaultValue = obj:GetAttribute("DefaultValue")
	assert(typeof(self._defaultValue) == "number", "Bad DefaultValue")

	self._icon = obj:GetAttribute("Icon")
	assert(typeof(self._icon) == "string", "Bad Icon")

	return self
end

function CurrencyConfig:GetKeyName(): string
	return self._keyName
end

function CurrencyConfig:GetDisplayName(): string
	return self._displayName
end

function CurrencyConfig:GetDefaultValue(): number
	return self._defaultValue
end

function CurrencyConfig:GetIcon(): string
	return self._icon
end

return CurrencyConfig
