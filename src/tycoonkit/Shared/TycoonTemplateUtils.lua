--[=[
	@class TycoonTemplateUtils

	Utils for working with tycoon templates.
]=]

local require = require(script.Parent.loader).load(script)

local promiseChild = require("promiseChild")

local TycoonTemplateUtils = {}

function TycoonTemplateUtils.getRoot(tycoonTemplate: Folder): CFrame
	-- TODO: Refactor.
	local root: BasePart = tycoonTemplate:FindFirstChild("Root")
	return assert(root, "No tycoon root!").CFrame
end

function TycoonTemplateUtils.getBuildableTemplates(tycoonTemplate: Folder): {Folder}
	return tycoonTemplate:GetChildren()
end

function TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate: Folder, name: string): Model?
	return tycoonTemplate:FindFirstChild(name)
end

function TycoonTemplateUtils.promiseTemplate()
	return promiseChild(workspace, "Template")
end

return TycoonTemplateUtils