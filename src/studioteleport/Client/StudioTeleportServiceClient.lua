--[=[
	@class StudioTeleportServiceClient

	Teleport around in Studio. Makes testing easier!
]=]

local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local HumanoidTeleportUtils = require("HumanoidTeleportUtils")
local CharacterUtils = require("CharacterUtils")
local Maid = require("Maid")

local StudioTeleportServiceClient = {}

function StudioTeleportServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()
end

function StudioTeleportServiceClient:Start()
	if not RunService:IsStudio() then
		return
	end

	self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Q then
			local humanoid: Humanoid = CharacterUtils.getPlayerHumanoid(Players.LocalPlayer)
			local rootPart: BasePart = CharacterUtils.getPlayerRootPart(Players.LocalPlayer)
			if not (humanoid and rootPart) then
				return
			end

			local camera = workspace.CurrentCamera
			local mouseLocation = UserInputService:GetMouseLocation()

			local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

			local result = workspace:Raycast(ray.Origin, ray.Direction.Unit * 1024, nil)
			if result then
				HumanoidTeleportUtils.teleportRootPart(humanoid, rootPart, result.Position)
			end
		end
	end))
end

function StudioTeleportServiceClient:Destroy()
	self._maid:DoCleaning()
end

return StudioTeleportServiceClient
