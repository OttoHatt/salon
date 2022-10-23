--[=[
	@class TycoonBindersServer

	Tycoon binders on the server.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(function(self, serviceBag)
--[=[
	@prop TycoonSpawn Binder<TycoonSpawn>
	@within TycoonBindersServer
]=]
	self:Add(Binder.new("TycoonSpawn", require("TycoonSpawn"), serviceBag))
--[=[
	@prop OwnerSession Binder<OwnerSession>
	@within TycoonBindersServer
]=]
	self:Add(Binder.new("OwnerSession", require("OwnerSession"), serviceBag))
--[=[
	@prop Buildable Binder<Buildable>
	@within TycoonBindersServer
]=]
	self:Add(Binder.new("Buildable", require("Buildable"), serviceBag))
end)