local Basic = loadfile("Types/Basic.lua")()

local Inverse = Basic:new(0, 0, {
		--Specific Variables
		colors = {
			red = 1,
			green = 1,
			blue = 0
		}
	})
	
Basic = nil

--Functions
function Inverse:new(x, y)
	local o = {}
	setmetatable(o, {__index = self})
	
	o.dendrites = {}
	o.axons = {}
	o.x = x
	o.y = y
	o.colors = self.colors
	return o
end

function Inverse:update()
	self.target = 1-self.sum/#self.dendrites --Average of dendrites values
	if self.instantaneous then
		self.value = self.target 
	end
end

return Inverse
