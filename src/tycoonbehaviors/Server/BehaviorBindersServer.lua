--[=[
	@class BehaviorBindersServer

	Provides functionality to tycoon buildables via binders.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(function(self, serviceBag)
--[=[
	@prop PetConveyor Binder<PetConveyor>
	@within BehaviorBindersServer
]=]
	self:Add(Binder.new("PetConveyor", require("PetConveyor"), serviceBag))
end)