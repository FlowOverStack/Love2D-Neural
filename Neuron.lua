local Connection = require "Connection"

Neuron = {
	types = {},
	updateOrder = {},
	camera = require "Camera"
}

Neuron.camera:start()


--Hyperbolic Tangent as default Sigmoid Function
function Neuron.tanh(value, target, factor, tnh)
	return value + math.tanh(target - value) * factor
end

--Start Neuron graph
function Neuron:new()
	self.cells = {}
	self.channels = {}
	return self.cells, self.channels
end

--Require a new cell type by file name
--(Must be inside /Types)
function Neuron:addCellType(name)
	local t = require("types."..name)
	package.loaded[name] = nil
	self.types[name] = t
end

--Create a cell at graph
function Neuron:createCell(x, y, cellType)
	--Create basic cell
	if self.types[cellType] then
		table.insert(self.cells, self.types[cellType]:new(x, y))
		self:doOrderUpdate()
	end
end

--Clear all basic connections of a cell
function Neuron:clearConnections(cell)
	--Remove references of cells of axons connections
	for i, v in ipairs(cell.axons) do
		for j, w in ipairs(v.connectedTo.dendrites) do
			if w.connectedTo == cell then
				table.remove(v.connectedTo.dendrites, j)
			end
		end
	end
	
	--Remove references of cells of dendrites connections
	for i, v in ipairs(cell.dendrites) do
		for j, w in ipairs(v.connectedTo.axons) do
			if w.connectedTo == cell then
				table.remove(v.connectedTo.axons, j)
			end
		end
	end

	self:doOrderUpdate()
end

--Delete a neuron of this graph
function Neuron:deleteNeuron(cell)
	self:clearConnections(cell)
	
	for i, v in ipairs(self.cells) do
		if v == cell then
			table.remove(self.cells, i)
			break
		end
	end
	
	self:doOrderUpdate()
end

function Neuron:connect(emitter, receiver)
	--Check if it makes a loop with the next cell
	for position, cell in ipairs(emitter.axons) do
		if cell.connectedTo == receiver then
			return false
		end
	end
	
	--Check if it makes a loop with the next cell
	for position, cell in ipairs(receiver.dendrites) do
		if cell.connectedTo == emitter then
			return false
		end
	end
	
	--Check if it loops with itself
	if emitter == receiver then
		return false
	end
	
	--Insert Neurons
	table.insert(emitter.axons, Connection:new(receiver, 1))
	table.insert(receiver.dendrites, Connection:new(emitter, 1))
	
	self:doOrderUpdate()
end

--Drawing Functions

--Recursive function, draw connections forward of a cell
function Neuron:showAxons(cell, depth, fullDepth)
	if not fullDepth then
		fullDepth = depth	
	end
	
	if depth > 0 then
		for i, v in ipairs(cell.axons) do
			self:showAxons(v.connectedTo, depth-1, fullDepth)
			love.graphics.setColor(1, 1-(depth/fullDepth), 1-(depth/fullDepth))
			love.graphics.line(cell.x, cell.y, v.connectedTo.x, v.connectedTo.y)
		end
	end
end

--Recursive function, draw connections backwards of a cell
function Neuron:showDendrites(cell, depth, fullDepth)
	if not fullDepth then
		fullDepth = depth	
	end
	
	if depth > 0 then
		for i, v in ipairs(cell.dendrites) do
			self:showDendrites(v.connectedTo, depth-1, fullDepth)
			love.graphics.setColor(1-(depth/fullDepth), 1, 1-(depth/fullDepth))
			love.graphics.line(cell.x, cell.y, v.connectedTo.x, v.connectedTo.y)
		end
	end
end

function Neuron:draw(drawValue)
	love.graphics.setColor(1, 1, 1)
	
	
	love.graphics.push()
	love.graphics.translate(self.camera:getTranslation())
	--Draw conections lines
	for cellPosition, cell in ipairs(self.cells) do
		local cellX = cell.x
		local cellY = cell.y
		local connectedX 
		local connectedY
		for position, value in ipairs(cell.axons) do
			local connectedX = value.connectedTo.x
			local connectedY = value.connectedTo.y
			--Ensure line is visible
			if self.camera:isVisible(cellX, cellY, 
			math.abs(cellX-connectedX), math.abs(cellY-connectedY)) then
				love.graphics.line(cell.x, cell.y, value.connectedTo.x, value.connectedTo.y)
			end
		end
	end
	
	--Draw Cells
	for cellPosition, cell in ipairs(self.cells) do
		--Ensure cell is visible
		if self.camera:isVisible(cell.x, cell.y, 16, 16) then
			cell:draw(drawValue, self)
		end
	end
	love.graphics.pop()
end



--Recursive function
--Do order starting at dendriteless cells and going backwards
function Neuron:backUpdate(cell)
	if not cell.alreadyUpdated then
		if #cell.dendrites == 0 then
			table.insert(self.updateOrder, cell)
			cell.alreadyUpdated = true
		else
			for i, v in ipairs(cell.dendrites) do
				if not v.alreadyUpdated then
					Neuron:backUpdate(v.connectedTo)
				end
			end
			
			table.insert(self.updateOrder, cell)
			cell.alreadyUpdated = true
		end
	end
end

--Update order of updates
function Neuron:doOrderUpdate()
	self.updateOrder = {} 
	
	--TODO Add loop resolution
	
	for cellPosition, cell in ipairs(self.cells) do
		if #cell.axons == 0 then
		 	self:backUpdate(cell)
		end
	end
	
	for cellPosition, cell in ipairs(self.cells) do
		cell.alreadyUpdated = false
	end
end

--Frame update
function Neuron:update(dt)
	for position, cell in ipairs (self.updateOrder) do
		--Update sum of next cells
		for t, value in ipairs (cell.axons) do
			value.connectedTo.sum = value.connectedTo.sum + cell.value
		end
		
		--Call neuron update function
		if #cell.dendrites == 0 then
			if not cell.bypassDendrites then
				cell.target = cell.value
			else
				cell:update(self)
			end
		else
			cell:update(self)
		end
		
		cell.sum = 0 
	end
	
	--
	for cellPosition, cell in ipairs(self.cells) do
		if not cell.instantaneous then
			if cell.equation then
				cell.equation(cell.value, cell.target ,cell.volatility*dt)
			else
				cell.value = self.tanh(cell.value, cell.target ,cell.volatility*dt)
			end
		end
		cell.alreadyUpdated = false
	end
end