--[=[
	@class BuildableClient

	Ok! (pt. 2).
]=]

local require = require(script.Parent.loader).load(script)

local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")
local RxLinkUtils = require("RxLinkUtils")
local BaseObject = require("BaseObject")
local TycoonBindersClient = require("TycoonBindersClient")

local BuildableClient = setmetatable({}, BaseObject)
BuildableClient.ClassName = "BuildableClient"
BuildableClient.__index = BuildableClient

function BuildableClient.new(obj: Folder, serviceBag)
	local self = setmetatable(BaseObject.new(obj), BuildableClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersClient)

	self._maid:GiveTask(RxLinkUtils.observeLinkValueBrio("Source", obj):Subscribe(function(brio)
		-- TODO: Play a cute building animation!! Something straight out of a LEGO game.
		-- https://twitter.com/Aristozal/status/1580920992985010176
		-- Also disable this effect on low graphics settings.

		local buildableTemplate: Model = brio:GetValue()
		local maid = brio:ToMaid()

		local offset = TycoonTemplateBuildableUtils.getTemplateOffset(buildableTemplate)
		-- TODO: Huge hack, we shouldn't reach up the datamodel like this.
		-- We need to use a util, or a binder to search upwards for our spawn.
		local newPivot = self._obj:FindFirstAncestorWhichIsA("BasePart").CFrame:ToWorldSpace(offset)

		local clone = buildableTemplate:Clone()
		clone.Name = "ClonedTemplate"
		clone.Archivable = false
		clone:PivotTo(newPivot)
		clone.Parent = self._obj
		maid:GiveTask(clone)

		-- TODO: HACK! Split this out, shouldn't reference binders like this. Feels eeky.
		-- TODO: Only create buttons for the tycoon's owner / session player.
		local unlocksFolder = clone:FindFirstChild("Unlocks")
		if unlocksFolder then
			for _, button: BasePart in unlocksFolder:GetChildren() do
				self._tycoonBinders.BuyButton:BindClient(button)
			end
		end
	end))

	return self
end

return BuildableClient
