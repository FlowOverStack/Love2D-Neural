local Digital = Basic:new(0, 0, {
		--Specific Variables
		activation = 0.75,
		cellForActivation = -1, --No cell
		
		colors = {
			red = 0,
			green = 1,
			blue = 0
		},
	})

--Functions
function Digital:draw(drawValues, neuronModule)	
	--Back of cell
	love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
	love.graphics.rectangle("fill", self.x-16, self.y-16, 32, 32)
	
	--Front of cell
	love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
	love.graphics.rectangle("line", self.x-16, self.y-16, 32, 32)
	--Show values
	if drawValues then
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(string.format("%.2f", self.activation), math.modf(self.x)-16, math.modf(self.y)-32, 32, "center")
		love.graphics.printf(string.format("%.2f", self.value), math.modf(self.x)-16, math.modf(self.y)-8, 32, "center")

	end
	
	--Draw line of dynamic activation
	if self.cellForActivation > -1 and neuronModule.cells[self.cellForActivation] then
		love.graphics.setColor(0, 0.9, 0.9)
		love.graphics.line(self.x, self.y, neuronModule.cells[self.cellForActivation].x, neuronModule.cells[self.cellForActivation].y)
	end
end

		
function Digital:update(neuronModule)
	--If activation is connected to a cell then the activation becomes dependent of the value of the cell
	--It allows the creation of dynamic gates
	if self.cellForActivation > -1 and neuronModule.cells[self.cellForActivation] then
		self.activation = neuronModule.cells[self.cellForActivation].value
	end
	
	if self.sum/#self.dendrites >= self.activation then
		self.target = 1
		self.value = self.target
	else
		self.target = 0
		self.value = self.target
	end
end


return Digital
