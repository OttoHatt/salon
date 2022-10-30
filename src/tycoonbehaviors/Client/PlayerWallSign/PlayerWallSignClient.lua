--[=[
	@class PlayerWallSignClient

	Player wall sign!
]=]

local require = require(script.Parent.loader).load(script)

local BehaviorBase = require("BehaviorBase")
local RxInstanceUtils = require("RxInstanceUtils")
local RxBrioUtils = require("RxBrioUtils")
local BinderUtils = require("BinderUtils")
local TycoonBindersClient = require("TycoonBindersClient")
local Blend = require("Blend")

local PlayerWallSignClient = setmetatable({}, BehaviorBase)
PlayerWallSignClient.ClassName = "PlayerWallSignClient"
PlayerWallSignClient.__index = PlayerWallSignClient

function PlayerWallSignClient.new(obj, serviceBag)
	local self = setmetatable(BehaviorBase.new(obj, serviceBag), PlayerWallSignClient)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._tycoonBinders = serviceBag:GetService(TycoonBindersClient)

	self._maid:GiveTask(self:_observeTextLabelBrio():Subscribe(function(brio)
		local textLabel = brio:GetValue()
		local maid = brio:ToMaid()

		local player: Player = self:GetOwnerSession():GetPlayer()

		maid:GiveTask(Blend.mount(textLabel, {
			Text = Blend.Computed(RxInstanceUtils.observeProperty(player, "DisplayName"), function(name: string)
				-- TODO: LocalizedPluralUtils? :P
				name = name:upper()
				if name:sub(-1) == "S" then
					return name .. "'"
				else
					return name .. "'S"
				end
			end),
		}))
	end))

	return self
end

function PlayerWallSignClient:_observeTextLabelBrio()
	return self:ObserveModelBrio():Pipe({
		RxBrioUtils.switchMapBrio(function(model: Model)
			return RxInstanceUtils.observeLastNamedChildBrio(model, "BasePart", "PlayerName")
		end),
		RxBrioUtils.switchMapBrio(function(part: BasePart)
			return RxInstanceUtils.observeChildrenOfClassBrio(part, "SurfaceGui")
		end),
		RxBrioUtils.switchMapBrio(function(surfaceGui: SurfaceGuiBase)
			return RxInstanceUtils.observeChildrenOfClassBrio(surfaceGui, "TextLabel")
		end),
	})
end

function PlayerWallSignClient:GetOwnerSession()
	-- TODO: Make this into a generic util! Should go under the base class!
	return BinderUtils.findFirstAncestor(self._tycoonBinders.OwnerSession, self._obj)
end

return PlayerWallSignClient
