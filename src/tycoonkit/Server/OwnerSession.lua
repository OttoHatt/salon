--[=[
	@class OwnerSession

	Ownership session of a tycoon!
]=]

local require = require(script.Parent.loader).load(script)

local DATASTORE_SUB_KEY = "Session"
local DATASTORE_KEY_BUILT = "BuiltBuildables"

local OwnerSessionBase = require("OwnerSessionBase")
local TycoonTemplateUtils = require("TycoonTemplateUtils")
local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")
local TycoonBindersServer = require("TycoonBindersServer")
local OwnerSessionConstants = require("OwnerSessionConstants")
local PlayerDataStoreService = require("PlayerDataStoreService")
local ObservableSet = require("ObservableSet")

local OwnerSession = setmetatable({}, OwnerSessionBase)
OwnerSession.ClassName = "OwnerSession"
OwnerSession.__index = OwnerSession

function OwnerSession.new(obj, serviceBag)
	local self = setmetatable(OwnerSessionBase.new(obj, serviceBag), OwnerSession)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = self._serviceBag:GetService(TycoonBindersServer)
	self._playerDataStoreService = self._serviceBag:GetService(PlayerDataStoreService)

	self._cframe = self._obj.Parent.CFrame

	-- Remoting.
	self._remoteEvent = Instance.new("RemoteEvent")
	self._remoteEvent.Name = OwnerSessionConstants.REMOTE_EVENT_NAME
	self._remoteEvent.Archivable = false
	self._remoteEvent.Parent = self._obj
	self._maid:GiveTask(self._remoteEvent)
	self._maid:GiveTask(self._remoteEvent.OnServerEvent:Connect(function(...)
		self:_handleRequest(...)
	end))

	-- Save/load buildables!
	-- TODO: Split into separate container.
	self._buildableSet = ObservableSet.new()
	self._maid:GiveTask(self._buildableSet)

	self._maid:GivePromise(self:_promiseDataStore()):Then(function(dataStore)
		return dataStore
			:Load(DATASTORE_KEY_BUILT, {})
			:Then(function(initialValue: { string })
				local function updateFromValue(built: { string })
					-- TODO: There *must* be a cleaner way of doing this.

					-- Get all saved buildables, copy it into the set.
					for _, uuid in built do
						self._buildableSet:Add(uuid)
					end
				end

				-- First-time update.
				updateFromValue(initialValue)
				self:_addDefaultBuildables()
			end)
			:Then(function()
				-- Then, when the set changes, copy back into the key.
				-- Hopefully this doesn't trigger some weird recursive update loop thing.
				local function updateSaved()
					dataStore:Store(DATASTORE_KEY_BUILT, self._buildableSet:GetList())
				end
				self._maid:GiveTask(self._buildableSet.ItemAdded:Connect(updateSaved))
				self._maid:GiveTask(self._buildableSet.ItemRemoved:Connect(updateSaved))
			end)
	end)

	self._maid:GivePromise(TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		-- Create all buildables!
		self._maid:GiveTask(self._buildableSet:ObserveItemsBrio():Subscribe(function(brio)
			local buildableName: string = brio:GetValue()
			local maid = brio:ToMaid()

			local template = TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate, buildableName)
			if not template then
				warn(("[OwnerSession] Buildable '%s' is missing its template!"):format(buildableName))
				return
			end

			maid:GiveTask(
				TycoonTemplateBuildableUtils.instantiateFromTemplate(self._tycoonBinders.Buildable, self._obj, template)
			)
		end))
	end))

	return self
end

function OwnerSession:_addDefaultBuildables()
	-- TODO: THIS SUCKS AND BREAKS THE ELEGANCE OF THE ORIGINAL CODE!!!!

	-- Insert all of our default buildables into the set.
	-- TODO: Make this cleaner. Don't save default buildables?????
	self._maid:GivePromise(TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		for _, buildableTemplate in TycoonTemplateUtils.getBuildableTemplates(tycoonTemplate) do
			if TycoonTemplateBuildableUtils.doesStartUnlocked(buildableTemplate) then
				self._buildableSet:Add(buildableTemplate.Name)
			end
		end
	end))
end

function OwnerSession:InsertBuildable(buildableName: string)
	TycoonTemplateUtils.promiseTemplate():Then(function(tycoonTemplate: Folder)
		-- Check that the template is valid *before* we add it!
		local template = TycoonTemplateUtils.getBuildableTemplateByName(tycoonTemplate, buildableName)
		if not template then
			return
		end

		self._buildableSet:Add(buildableName)
	end)
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
		local buildableName: string = ...
		if typeof(buildableName) ~= "string" then
			return
		end

		self:InsertBuildable(buildableName)
	elseif requestType == OwnerSessionConstants.REQUEST_RESET_DATA then
		-- TODO: Should we empty the DataStore, or empty the data structures???
		for _, item in self._buildableSet:GetList() do
			self._buildableSet:Remove(item)
		end
		self:_addDefaultBuildables()
	end
end

function OwnerSession:_promiseDataStore()
	return self._playerDataStoreService:PromiseDataStore(self:GetPlayer()):Then(function(store)
		return store:GetSubStore(DATASTORE_SUB_KEY)
	end)
end

return OwnerSession
