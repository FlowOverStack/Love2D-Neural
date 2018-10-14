local Basic = loadfile("Types/Basic.lua")()

local Trainable = Basic:new(0, 0, {
	--Specific Variables
	colors = {
		red = 1,
		green = 1,
		blue = 1
	}
})

Basic = nil

--Functions
function Trainable:new(x, y)
	local o = {}
	setmetatable(o, {__index = self})
	
	o.dendrites = {}
	o.axons = {}
	o.x = x
	o.y = y
	o.colors = self.colors
	return o
end
	
function Trainable:update(dt)
	self.target = self.sum/#self.dendrites --Average of dendrites values
	if self.instantaneous then
		self.value = self.target 
	end
end

return Trainable
