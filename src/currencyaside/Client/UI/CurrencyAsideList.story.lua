local require = require(game:GetService("ServerScriptService"):FindFirstChild("LoaderUtils", true).Parent).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local StoryBarUtils = require("StoryBarUtils")
local StoryBarPaneUtils = require("StoryBarPaneUtils")
local CurrencyAsideList = require("CurrencyAsideList")
local CurrencyDiscoveryService = require("CurrencyDiscoveryService")
local CurrencyAside = require("CurrencyAside")
local CurrencyProvider = require("CurrencyProvider")
local GameScalingUtils = require("GameScalingUtils")
local Rx = require("Rx")

return function(target)
	local maid = Maid.new()

	local serviceBag = ServiceBag.new()
	maid:GiveTask(serviceBag)

	maid:GiveTask(GameScalingUtils.renderDialogPadding({
		Parent = target,
		ScreenGui = target,
	}):Subscribe())

	local asideList = CurrencyAsideList.new(serviceBag)
	asideList.Gui.Position = UDim2.new(1, 0, 0.5, 0)
	asideList.Gui.Parent = target
	maid:GiveTask(asideList)

	for _, configInstance: Configuration in serviceBag:GetService(CurrencyProvider):GetAll() do
		local configClass =
			serviceBag:GetService(CurrencyDiscoveryService):GetCurrencyConfigFromInstance(configInstance)
		local aside = CurrencyAside.new()
		aside:SetScale(1.5)
		aside:SetIcon(configClass:GetIcon())
		maid:GiveTask(aside)
		maid:GiveTask(Rx.timer(math.random(), 4):Subscribe(function()
			aside:SetCount(math.floor(math.random() * 10000))
		end))
		maid:GiveTask(asideList:AddAside(aside))
	end

	local bar = StoryBarUtils.createStoryBar(maid, target)
	StoryBarPaneUtils.makeVisibleSwitch(bar, asideList)

	return function()
		maid:DoCleaning()
	end
end
