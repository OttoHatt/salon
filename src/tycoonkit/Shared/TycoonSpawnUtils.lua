--[=[
	@class TycoonSpawnUtils

	Utils for working with spawned tycoons.
]=]

local require = require(script.Parent.loader).load(script)

local CollectionService = game:GetService("CollectionService")

local LinkUtils = require("LinkUtils")
local BinderUtils = require("BinderUtils")

local TycoonSpawnUtils = {}

function TycoonSpawnUtils.createOwnSession(sessionBinder, tycoon: Folder, player: Player): Folder
	local session = Instance.new("Folder")
	session.Name = "OwnSession"
	session.Archivable = false

	LinkUtils.createLink("Player", session, player)

	session.Parent = tycoon
	sessionBinder:Bind(session)

	return session
end

function TycoonSpawnUtils.getVacantTycoons(tycoonBinder, sessionBinder): {Folder}
	local vacant = {}

	for _, tycoon: Folder in CollectionService:GetTagged(tycoonBinder:GetTag()) do
		if not BinderUtils.findFirstChild(sessionBinder, tycoon) then
			table.insert(vacant, tycoon)
		end
	end

	return vacant
end

function TycoonSpawnUtils.findVacantTycoon(tycoonBinder, sessionBinder): Folder?
	local list = TycoonSpawnUtils.getVacantTycoons(tycoonBinder, sessionBinder)

	if #list > 0 then
		return list[math.random(1, #list)]
	end
end

return TycoonSpawnUtils