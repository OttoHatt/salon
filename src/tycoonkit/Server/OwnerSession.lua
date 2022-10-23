--[=[
	@class OwnerSession

	Ownership session of a tycoon!
]=]

local require = require(script.Parent.loader).load(script)

local OwnerSessionBase = require("OwnerSessionBase")
local TycoonTemplateUtils = require("TycoonTemplateUtils")
local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")
local TycoonBindersServer = require("TycoonBindersServer")
local OwnerSessionConstants = require("OwnerSessionConstants")
local LinkUtils = require("LinkUtils")

local OwnerSession = setmetatable({}, OwnerSessionBase)
OwnerSession.ClassName = "OwnerSession"
OwnerSession.__index = OwnerSession

function OwnerSession.new(obj, serviceBag)
	local self = setmetatable(OwnerSessionBase.new(obj, serviceBag), OwnerSession)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersServer)

	self._cframe = self._obj.Parent.CFrame

	self._maid:GiveTask(TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		-- HACK: Spawn in all automatically owned buildables.
		for _, buildableTemplate in TycoonTemplateUtils.getBuildableTemplates(tycoonTemplate) do
			if buildableTemplate:GetAttribute("StartUnlocked") ~= true then
				-- TODO: HACK!!!!!
				-- Replace with a proper utils call. Maybe some kind of template interface.
				continue
			end
			self:InstantiateBuildable(buildableTemplate)
		end
	end))

	-- Remoting.
	self._remoteEvent = Instance.new("RemoteEvent")
	self._remoteEvent.Name = OwnerSessionConstants.REMOTE_EVENT_NAME
	self._remoteEvent.Archivable = false
	self._remoteEvent.Parent = self._obj
	self._maid:GiveTask(self._remoteEvent)
	self._maid:GiveTask(self._remoteEvent.OnServerEvent:Connect(function(...)
		self:_handleRequest(...)
	end))

	return self
end

function OwnerSession:GetPlayer(): Player
	return LinkUtils.getLinkValue("Player", self._obj)
end

function OwnerSession:InstantiateBuildable(template: Model)
	self._maid:GiveTask(
		TycoonTemplateBuildableUtils.instantiateFromTemplateServer(self._tycoonBinders.Buildable, self._obj, template)
	)
end

function OwnerSession:_handleRequest(player: Player, requestType: string, ...)
	-- TODO: VALIDATION WITH t!

	if player ~= self:GetPlayer() then
		return
	end
	if typeof(requestType) ~= "string" then
		return
	end

	if requestType == OwnerSessionConstants.REQUEST_BUILD then
		self:_handleRequestBuild(...)
	end
end

function OwnerSession:_handleRequestBuild(buildableName: string)
	if typeof(buildableName) ~= "string" then
		return
	end

	self._maid:GiveTask(TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		local template = TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate, buildableName)
		if not template then
			return
		end

		if not self:IsBuildableBuilt(template.Name) then
			self:InstantiateBuildable(template)
		end
	end))
end

return OwnerSession
