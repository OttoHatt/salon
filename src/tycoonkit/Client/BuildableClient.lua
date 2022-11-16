--[=[
	@class BuildableClient

	Ok! (pt. 2).
]=]

local require = require(script.Parent.loader).load(script)

local TycoonTemplateBuildableUtils = require("TycoonTemplateBuildableUtils")
local RxLinkUtils = require("RxLinkUtils")
local BaseObject = require("BaseObject")
local TycoonBindersClient = require("TycoonBindersClient")
local Maid = require("Maid")
local Spring = require("Spring")
local QFrame = require("QFrame")
local StepUtils = require("StepUtils")

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

		local childrenToAnimate = clone:GetDescendants()

		-- TODO: HACK! Split this out, shouldn't reference binders like this. Feels eeky.
		-- TODO: Only create buttons for the tycoon's owner / session player.
		local unlocksFolder = clone:FindFirstChild("Unlocks")
		if unlocksFolder then
			for _, button: BasePart in unlocksFolder:GetChildren() do
				self._tycoonBinders.BuyButton:BindClient(button)
			end
		end

		-- Animate!
		-- TODO: Fix and cleanup, this code sucks!!!
		-- TODO: Provide a safe method for buildables to query their world position, without using parts directly.
		-- As those positions could be affected by an animation!
		for _, part in childrenToAnimate do
			if part:IsA("BasePart") then
				self:_animatePart(part)
			end
		end
	end))

	return self
end

local RANDOM = Random.new()

function BuildableClient:_animatePart(part: BasePart)
	local maid = Maid.new()

	local function randomLean()
		-- TODO: Normal distribution.
		local RANGE = math.pi / 16 / 2 / 2
		return CFrame.Angles(
			RANDOM:NextNumber(-RANGE, RANGE),
			RANDOM:NextNumber(-RANGE, RANGE),
			RANDOM:NextNumber(-RANGE, RANGE)
		)
	end

	local RAISE_HEIGHT = 20
	local MAX_ANIM_TIME = 4

	local cfSpring = Spring.new(
		QFrame.fromCFrameClosestTo(
			part.CFrame * randomLean() + Vector3.new(0, RANDOM:NextNumber() * RAISE_HEIGHT, 0),
			QFrame.new()
		)
	)
	cfSpring.Target = QFrame.fromCFrameClosestTo(part.CFrame, cfSpring.Position)
	cfSpring.Speed = 9

	local transparencySpring = Spring.new(1)
	transparencySpring.Target = part.Transparency
	transparencySpring.Speed = 14

	local motor = Instance.new("Motor6D")
	motor.Part0 = part
	motor.Part1 = workspace.Terrain
	motor.Transform = part.CFrame:Inverse()
	motor.Archivable = false
	motor.Parent = part

	local startTime = os.clock()

	local startAnimation, stopAnimation = StepUtils.bindToRenderStep(function()
		motor.Transform = cfSpring.Position:toCFrame():Inverse()
		part.Transparency = transparencySpring.Position

		local stillAnimating = (os.clock() - startTime) <= MAX_ANIM_TIME
		if not stillAnimating then
			maid:DoCleaning()
		end

		return stillAnimating
	end)
	startAnimation()

	local intendsToBeAnchored = part.Anchored
	part.Anchored = false

	maid:GiveTask(function()
		-- Re-anchor.
		part.Anchored = intendsToBeAnchored
		-- Stop the animation!
		stopAnimation()
		-- Snap to intended positions.
		part.Transparency = transparencySpring.Target
		part.CFrame = cfSpring.Target:toCFrame()
		-- Cleanup motor.
		motor:Destroy()
	end)

end

return BuildableClient
