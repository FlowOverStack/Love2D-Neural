local Activable = Basic:new(0, 0, {
		--Specific Variables
		activation = 0.75,
		cellForActivation = -1, --No cell
		
		colors = {
			red = 0,
			green = 0,
			blue = 1
		}
	})
	
--Functions
function Activable:new(x, y)
	local o = {}
	setmetatable(o, {__index = self})
	
	o.dendrites = {}
	o.axons = {}
	o.x = x
	o.y = y
	o.colors = self.colors
	return o
end
		
--Functions
function Activable:draw(drawValues, neuronModule)	
	--Back of cell
	if not self.instantaneous then
		love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
		love.graphics.circle("fill", self.x, self.y, 16)
		
		--Front of cell
		love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
		love.graphics.circle("line", self.x, self.y, 16)
	else
		--Back of cell
		love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
		love.graphics.rectangle("fill", self.x-16, self.y-16, 32, 32)
		
		--Front of cell
		love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
		love.graphics.rectangle("line", self.x-16, self.y-16, 32, 32)
	end
	--Show values
	if drawValues then
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(string.format("%.2f", self.activation), math.modf(self.x)-16, math.modf(self.y)-32, 32, "center")
		love.graphics.printf(string.format("%.2f", self.value), math.modf(self.x)-16, math.modf(self.y)-8, 32, "center")
		if self.cellForActivation > -1 and neuronModule.cells[self.cellForActivation] then
			love.graphics.setColor(0, 0.9, 0.9)
			love.graphics.line(self.x, self.y, neuronModule.cells[self.cellForActivation].x, neuronModule.cells[self.cellForActivation].y)
		end
	end
end

		
function Activable:update(neuronModule)
	--If activation is connected to a cell then the cell value becomes dependent of the value of the cell
	
	local valueOfCellForActivation = 0
	if self.cellForActivation > -1 and neuronModule.cells[self.cellForActivation] then
		valueOfCellForActivation = neuronModule.cells[self.cellForActivation].value
	end
	
	--If is bigger than activation the cell works like a Trainable
	if valueOfCellForActivation >= self.activation then
		self.target = self.sum/#self.dendrites
		if self.instantaneous then
			self.value = self.target 
		end
	--Else cell mantains the last value when activated
	else
		self.target = self.value
	end
end

return Activable