--[=[
	@class TycoonBindersClient

	Tycoon binders on the client.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(function(self, serviceBag)
--[=[
	@prop BuyButton Binder<BuyButton>
	@within TycoonBindersClient
]=]
	self:Add(Binder.new("BuyButton", require("BuyButton"), serviceBag))
--[=[
	@prop Buildable Binder<BuildableClient>
	@within TycoonBindersClient
]=]
	self:Add(Binder.new("Buildable", require("BuildableClient"), serviceBag))
--[=[
	@prop OwnerSession Binder<OwnerSessionClient>
	@within TycoonBindersClient
]=]
	self:Add(Binder.new("OwnerSession", require("OwnerSessionClient"), serviceBag))
end)