--[=[
	@class ConveyorLineUtils

	Utils for working with conveyor lines.
]=]

local require = require(script.Parent.loader).load(script)

local ATTRIBUTE_ADORNEE_INDEX = "Index"

local AdorneeUtils = require("AdorneeUtils")
local Math = require("Math")

local ConveyorLineUtils = {}

--[=[
	Sort points on the line by ascending index.
]=]
function ConveyorLineUtils.sortPointArray(pointList: { Instance })
	table.sort(pointList, function(a, b)
		return a.Index < b.Index
	end)
	return pointList
end

--[=[
	Given a list of adorness, turn them into an array of struct-likes holding info about each point.
]=]
function ConveyorLineUtils.adorneesToPointArray(adorneeList: { Instance }): { table }
	local out = {}

	-- Create points.
	for _, adornee: Instance in adorneeList do
		table.insert(out, {
			Index = adornee:GetAttribute(ATTRIBUTE_ADORNEE_INDEX),
			Position = AdorneeUtils.getCenter(adornee),
		})
	end

	ConveyorLineUtils.sortPointArray(out)

	-- Go through each point, summing the distance.
	-- We can use this later for animations.
	-- Luckily, this should also account for the conveyor expanding, if we need that.
	if #out > 0 then
		-- TODO: Clean this up, should be probably be a 'do' loop lol.

		local distance = 0
		local lastPosition = out[1].Position
		out[1].Distance = distance

		for i = 2, #out do
			local point = out[i]
			distance += (lastPosition - point.Position).Magnitude
			lastPosition = point.Position
			point.Distance = distance
		end
	end

	return out
end

--[=[
	Find a position along the point array path at the specified distance from the start.
	This is very useful for animations!
]=]
function ConveyorLineUtils.getPositionByDistanceIntoPointArray(pointList: { table }, distance: number): Vector3?
	-- TODO: Use a binary search.

	for i = 2, #pointList do
		local point = pointList[i]
		if point.Distance < distance then
			continue
		end

		local prevPoint = pointList[i - 1]

		local facFromPrevToCurrent = Math.map(distance, prevPoint.Distance, point.Distance, 0, 1)
		return prevPoint.Position:Lerp(point.Position, facFromPrevToCurrent)
	end
end

return ConveyorLineUtils
