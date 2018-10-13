local Connection = {
	connectedTo = nil, --Connected to which cell
	strength = 1 --Strength of connection (1 == 100%)
}


function Connection:new(cell, strength, o)
	local o = o or {}
	
	setmetatable(o, {__index = self})
	
	o.connectedTo = cell
	o.strength = strength or 1
	
	return o
end

function Connection:setStrength(strength)
	self.strength = strength
end

function Connection:getStrength()
	return self.strength
end

function Connection:getCell()
	return self.cell
end

return Connection