--Math functions
function math.middle(v)
	local d = math.fmod(v,1)
	if d <= 0.5 then
		return math.floor(v)
	else
		return math.ceil(v)
	end
end

function math.isInsideRadius(x, y, centerX, centerY, radius)
	return ( (x-centerX)^2 + (y-centerY)^2 ) ^0.5 < radius
end