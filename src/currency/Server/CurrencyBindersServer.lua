--[=[
	@class CurrencyBindersServer

	Assigns currency onto a player.
]=]

local require = require(script.Parent.loader).load(script)

local BinderProvider = require("BinderProvider")
local Binder = require("Binder")
local PlayerBinder = require("PlayerBinder")

return BinderProvider.new(function(self, serviceBag)
--[=[
	@prop PlayerHasCurrency Binder<PlayerHasCurrency>
	@within CurrencyBindersServer
]=]
	self:Add(PlayerBinder.new("PlayerHasCurrency", require("PlayerHasCurrency"), serviceBag))
	self:Add(Binder.new("PlayerCurrency", require("PlayerCurrency"), serviceBag))
end)