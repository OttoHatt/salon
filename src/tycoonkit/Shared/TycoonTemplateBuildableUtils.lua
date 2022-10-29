--[=[
	@class TycoonTemplateBuildableUtils

	Utils for working with........ nevermind.
]=]

local require = require(script.Parent.loader).load(script)

local TEMPLATE_BEHAVIOR_NAME = "Behavior"

local CollectionService = game:GetService("CollectionService")

local LinkUtils = require("LinkUtils")
local TycoonTemplateUtils = require("TycoonTemplateUtils")

local TycoonTemplateBuildableUtils = {}

function TycoonTemplateBuildableUtils.instantiateFromTemplate(
	buildableBinder,
	session: Folder,
	buildableTemplate: Folder
): Folder
	assert(typeof(session) == "Instance", "Bad session")
	assert(typeof(buildableTemplate) == "Instance", "Bad buildableTemplate")

	-- TODO: We shouldn't use names to identify buildables!!!!!!
	-- In future, add some stupid random prefix / UUID to buildables so we break our code.
	local buildable = Instance.new("Folder")
	buildable.Name = buildableTemplate.Name
	buildable.Archivable = false

	-- Link back to our template.
	LinkUtils.createLink("Source", buildable, buildableTemplate)

	buildable.Parent = session
	buildableBinder:Bind(buildable)

	-- Bind all assigned behaviors to this buildable.
	for _, behavior: string in TycoonTemplateBuildableUtils.getBehaviors(buildableTemplate) do
		CollectionService:AddTag(buildable, behavior)
	end

	return buildable
end

function TycoonTemplateBuildableUtils.getBehaviors(buildableTemplate: Model): { string }
	local behaviors = {}

	for _, child: Instance in buildableTemplate:GetChildren() do
		if child:IsA("StringValue") and child.Name == TEMPLATE_BEHAVIOR_NAME then
			table.insert(behaviors, child.Value)
		end
	end

	return behaviors
end

function TycoonTemplateBuildableUtils.getTemplateOffset(buildableTemplate: Model): CFrame
	-- TODO: Ugly reach-around parenting hacks!
	local root = TycoonTemplateUtils.getRoot(buildableTemplate.Parent)
	return root:ToObjectSpace(buildableTemplate:GetPivot())
end

function TycoonTemplateBuildableUtils.doesStartUnlocked(buildableTemplate: Model)
	return buildableTemplate:GetAttribute("StartUnlocked") == true
end

function TycoonTemplateBuildableUtils.getPrice(buildableTemplate: Model): number
	return buildableTemplate:GetAttribute("Price") or 0
end

function TycoonTemplateBuildableUtils.getDisplayName(buildableTemplate: Model): string
	return buildableTemplate:GetAttribute("DisplayName") or buildableTemplate.Name
end

return TycoonTemplateBuildableUtils
