--[=[
	@class CurrencyBindersClient

	Currency on the client.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")

return BinderProvider.new(script.Name, function(self, serviceBag)
--[=[
	@prop PlayerCurrency Binder<PlayerCurrencyClient>
	@within CurrencyBindersClient
]=]
	self:Add(Binder.new("PlayerCurrency", require("PlayerCurrencyClient"), serviceBag))
end)