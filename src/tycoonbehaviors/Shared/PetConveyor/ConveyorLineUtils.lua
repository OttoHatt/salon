--[=[
	@class ConveyorLineUtils

	Utils for working with conveyor lines.
]=]

--- @type ConveyorPoint { Index: number, Position: Vector3, Distance: number }
--- @within ConveyorLineUtils

local require = require(script.Parent.loader).load(script)

local ATTRIBUTE_ADORNEE_INDEX = "Index"

local AdorneeUtils = require("AdorneeUtils")
local Math = require("Math")

local ConveyorLineUtils = {}

--[=[
	Given a list of adorness, turn them into an array of struct-likes holding info about each point.

	@param adorneeList {Instance}
	@return {ConveyorPoint}
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
	Sort points on the line by ascending index.

	@param pointList {ConveyorPoint}
	@return {ConveyorPoint}
]=]
function ConveyorLineUtils.sortPointArray(pointList: { table })
	table.sort(pointList, function(a, b)
		return a.Index < b.Index
	end)
	return pointList
end

--[=[
	Find a position along the point array path at the specified distance from the start.
	This is very useful for animations!

	@param pointList {ConveyorPoint}
	@param distance number
	@return Vector3
]=]
function ConveyorLineUtils.getPositionByDistanceIntoPointArray(pointList: { table }, distance: number): Vector3?
	-- TODO: Use a binary search to find the minimum point to our target distance.

	for i = 2, #pointList do
		local point = pointList[i]
		if point.Distance < distance then
			continue
		end

		local prevPoint = pointList[i - 1]

		-- Given the past and current distance of the point, find the factor we're at between them.
		-- Use this to lerp the positions, allowing us to transition between the points.
		-- TODO: Support for curved and upwards conveyors w/ cubics.
		local facFromPrevToCurrent = Math.map(distance, prevPoint.Distance, point.Distance, 0, 1)
		return prevPoint.Position:Lerp(point.Position, facFromPrevToCurrent)
	end

	-- If we got this far, then we must be at the end of the array.
	-- Extrapolate the points outward.
	if #pointList >= 2 then
		local p0 = pointList[#pointList-1].Position
		local p1 = pointList[#pointList].Position

		return p0 + (p1-p0) * ((distance - pointList[#pointList-1].Distance) / (p1-p0).Magnitude)
	end
end

--[=[
	Get the length of a point array by checking the last element.

	@param pointList {ConveyorPoint}
	@return {ConveyorPoint}
]=]
function ConveyorLineUtils.getLengthOfPointArray(pointList: { table }): number?
	if #pointList > 1 then
		return pointList[#pointList].Distance
	end
end

return ConveyorLineUtils
