--[=[
	@class TycoonTemplateBuildableUtils

	Utils for working with........ nevermind.
]=]

local require = require(script.Parent.loader).load(script)

local LinkUtils = require("LinkUtils")
local TycoonTemplateUtils = require("TycoonTemplateUtils")

local TycoonTemplateBuildableUtils = {}

function TycoonTemplateBuildableUtils.instantiateFromTemplateServer(
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

	LinkUtils.createLink("Source", buildable, buildableTemplate)

	buildable.Parent = session
	buildableBinder:Bind(buildable)

	return buildable
end

function TycoonTemplateBuildableUtils.getTemplateOffset(buildableTemplate: Model): CFrame
	-- TODO: Ugly reach-around parenting hacks!
	local root = TycoonTemplateUtils.getRoot(buildableTemplate.Parent)
	return root:ToObjectSpace(buildableTemplate:GetPivot())
end

return TycoonTemplateBuildableUtils
