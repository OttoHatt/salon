--[=[
	@class MovingPetServiceClient

	Manages moving pets, in this case, stroking them... :P
]=]

local require = require(script.Parent.loader).load(script)

local PET_INTERACT_DISTANCE = 32

local UserInputService = game:GetService("UserInputService")
local BehaviorBindersClient = require("BehaviorBindersClient")
local TycoonServiceClient = require("TycoonServiceClient")
local BinderUtils = require("BinderUtils")

local Maid = require("Maid")
local InputObjectRayUtils = require("InputObjectRayUtils")

local MovingPetServiceClient = {}

function MovingPetServiceClient:Init(serviceBag)
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()

	self._tycoonService = serviceBag:GetService(TycoonServiceClient)
	self._behaviorBinders = self._serviceBag:GetService(BehaviorBindersClient)
end

function MovingPetServiceClient:Start()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	self._maid:GivePromise(self._tycoonService:PromiseLocallyOwnedSession():Then(function(session)
		-- TODO: Accessing private 'obj' field is a code smell!
		raycastParams.FilterDescendantsInstances = { session._obj }
	end))

	self._maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObj: InputObject, gameProcessed)
		if gameProcessed then
			return
		end

		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
			local ray = InputObjectRayUtils.cameraRayFromViewportPosition(
				inputObj.Position,
				PET_INTERACT_DISTANCE,
				workspace.CurrentCamera
			)

			local result = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			if not result then
				return
			end

			local class = BinderUtils.findFirstAncestor(self._behaviorBinders.AnimatedPetModel, result.Instance)
			if not class then
				return
			end

			class:PlaySpecialAnimation()
		end
	end))
end

return MovingPetServiceClient
