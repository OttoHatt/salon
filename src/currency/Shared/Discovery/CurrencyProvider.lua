--[=[
	Provides currency templates. See [TemplateProvider].
	@class AnimationProvider
]=]

local require = require(script.Parent.loader).load(script)

local TaggedTemplateProvider = require("TaggedTemplateProvider")

return TaggedTemplateProvider.new("CurrencyContainer")