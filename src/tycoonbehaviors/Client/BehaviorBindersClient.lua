--[=[
	@class BehaviorBindersClient

	Provides functionality to tycoon buildables via binders.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(function(self, serviceBag)
--[=[
	@prop PetConveyor Binder<PetConveyorClient>
	@within BehaviorBindersClient
]=]
	self:Add(Binder.new("PetConveyor", require("PetConveyorClient"), serviceBag))
--[=[
	@prop MovingPet Binder<MovingPetClient>
	@within BehaviorBindersClient
]=]
	self:Add(Binder.new("MovingPet", require("MovingPetClient"), serviceBag))
end)