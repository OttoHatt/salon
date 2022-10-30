--[=[
	@class MovingPetUtils

	Utils for working with moving pets.
]=]

local require = require(script.Parent.loader).load(script)

local LinkUtils = require("LinkUtils")

local MovingPetUtils = {}

function MovingPetUtils.instantiateWithModel(binder, conveyor: Folder, visualModel: Model, cuteName: string, initialValue: number)
	assert(typeof(conveyor) == "Instance", "Bad conveyor")
	assert(typeof(visualModel) == "Instance" and visualModel:IsA("Model"), "Bad visual model")
	assert(typeof(cuteName) == "string", "Bad cuteName")
	assert(typeof(initialValue) == "number", "Bad initialValue")

	local movingPet = Instance.new("Folder")

	movingPet.Name = "MovingPet"
	movingPet.Archivable = false

	movingPet:SetAttribute("CuteName", cuteName)
	movingPet:SetAttribute("Value", initialValue)
	movingPet:SetAttribute("SpawnTime", workspace:GetServerTimeNow())
	LinkUtils.createLink("Model", movingPet, visualModel)

	movingPet.Parent = conveyor
	binder:Bind(movingPet)

	return movingPet
end

function MovingPetUtils.promiseModel(maid, movingPet: Folder): Model
	return LinkUtils.promiseLinkValue(maid, "Model", movingPet)
end

function MovingPetUtils.getValue(movingPet: Folder): number
	return movingPet:GetAttribute("Value")
end

function MovingPetUtils.getCuteName(movingPet: Folder): string
	return movingPet:GetAttribute("CuteName")
end

function MovingPetUtils.getSpawnTime(movingPet: Folder): number
	return movingPet:GetAttribute("SpawnTime")
end

return MovingPetUtils