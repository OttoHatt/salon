--[=[
	@class AnimatedPetModelClient

	Animated pet models on the client! Cute stuff.
]=]

local require = require(script.Parent.loader).load(script)

local DEBUG_DRAW = false

local MAX_LOOK_ANGLE = math.rad(100)
local IGNORE_LOOK_ANGLE = math.rad(140)
local IGNORE_DISTANCE = 25

local LOOK_SPEED = 7

local NECK_BONE_NAME = "Cat Chubby Head"

local RunService = game:GetService("RunService")

local BaseObject = require("BaseObject")
local AnimationProvider = require("AnimationProvider")
local promiseChild = require("promiseChild")
local RxBrioUtils = require("RxBrioUtils")
local AttributeValue = require("AttributeValue")
local Draw = require("Draw")
local Maid = require("Maid")
local FocalPointUtils = require("FocalPointUtils")
local Spring = require("Spring")
local cancellableDelay = require("cancellableDelay")

local AnimatedPetModelClient = setmetatable({}, BaseObject)
AnimatedPetModelClient.ClassName = "AnimatedPetModelClient"
AnimatedPetModelClient.__index = AnimatedPetModelClient

function AnimatedPetModelClient.new(obj: Model, serviceBag)
	local self = setmetatable(BaseObject.new(obj), AnimatedPetModelClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._animationProvider = self._serviceBag:GetService(AnimationProvider)

	self._actionValue = AttributeValue.new(self._obj, "Action", "Idle")

	self._animationController = Instance.new("AnimationController")
	self._animationController.Archivable = false
	self._animationController.Parent = self._obj
	self._maid:GiveTask(self._animationController)

	self._animator = Instance.new("Animator")
	self._animator.Archivable = false
	self._animator.Parent = self._animationController
	self._maid:GiveTask(self._animator)

	-- Play default idle animation as a base layer.
	self:_promisePlayAnimation("Idle", Enum.AnimationPriority.Idle, 1, 1, true)

	local lookSpring = Spring.new(0)
	lookSpring.Speed = LOOK_SPEED

	-- TODO: BAD! This shouldn't be fixed, the name should be set per model.
	local bone: Bone = obj:FindFirstChild(NECK_BONE_NAME, true)
	self._maid:GiveTask(RunService.RenderStepped:Connect(function()
		local transform = bone.TransformedWorldCFrame

		local focalPoint = FocalPointUtils.getFocalPoint()
		local focalUnit = (focalPoint - transform.Position).Unit

		local focalDistance = (focalPoint - transform.Position).Magnitude

		if DEBUG_DRAW then
			local maid = Maid.new()
			self._maid._drawMaid = maid
			maid:GiveTask(Draw.vector(transform.Position, transform.UpVector, Color3.new(1, 0, 0), self._obj))
			maid:GiveTask(Draw.vector(transform.Position, focalUnit, Color3.new(0, 1, 0), self._obj))
		end

		local yaw = 0

		if focalDistance < IGNORE_DISTANCE then
			local relativeVec = transform:VectorToObjectSpace(focalUnit)
			local testYaw = math.atan2(relativeVec.Z, relativeVec.Y)
			if math.abs(testYaw) < IGNORE_LOOK_ANGLE then
				yaw = math.clamp(testYaw, -MAX_LOOK_ANGLE, MAX_LOOK_ANGLE)
			end
		end

		lookSpring.Target = yaw
		bone.Transform *= CFrame.fromAxisAngle(Vector3.xAxis, lookSpring.Position)
	end))

	return self
end

function AnimatedPetModelClient:PlaySpecialAnimation()
	self:_promisePlayAnimation("Special", Enum.AnimationPriority.Action, 0.7, 1.2, false)
	self._obj:FindFirstChild("SpecialSound"):Play()
end

function AnimatedPetModelClient:SetAnimation(name: string)
	self._actionValue.Value = name
end

local random = Random.new()

function AnimatedPetModelClient:_promisePlayAnimation(
	action: string,
	priority: Enum.AnimationPriority,
	fadeTime: number,
	speed: number,
	looped: boolean
)
	return self:_promiseAnimationFromActionName(action):Then(function(animation: Animation)
		local maid = Maid.new()
		self._maid[action] = maid

		local track: AnimationTrack = self._animator:LoadAnimation(animation)
		maid:GiveTask(track)

		-- Start the track at some random position through the animation, to prevent pets syncing up!
		-- TODO: Animations don't load immediately! First few pets will be unanimated.
		-- Check '.length > 0'.
		track.Looped = looped
		track.Priority = priority
		track.TimePosition = random:NextNumber(0, track.Length)

		track:Play(fadeTime, 1, speed)
		if not looped then
			maid:GiveTask(cancellableDelay(track.Length - fadeTime, function()
				track:Stop(fadeTime)
			end))
		end
	end)
end

function AnimatedPetModelClient:_promiseAnimationFromActionName(action: string)
	return self:_promiseAnimationConfig():Then(function(config: Configuration)
		local animationName = config:GetAttribute(action)
		if typeof(animationName) ~= "string" then
			warn(("[AnimatedPetModelClient] Animation name '%s' missing map!"):format(action))
			return
		end

		local animation: Animation = self._animationProvider:Get(animationName)
		if not animation then
			warn(("[AnimatedPetModelClient] Animation instance '%s' is missing!"):format(animationName))
			return
		end

		return animation
	end)
end

function AnimatedPetModelClient:_observeActionNameBrio()
	return self._actionValue:Observe():Pipe({ RxBrioUtils.switchToBrio })
end

function AnimatedPetModelClient:_promiseAnimationConfig()
	return promiseChild(self._obj, "Animations")
end

return AnimatedPetModelClient
