local Connection = require "Connection"

Neuron = {
	types = {},
	updateOrder = {},
	camera = require "Camera"
}

Neuron.camera:start()




--Hyperbolic Tangent as Sigmoid Function
function Neuron.tanh(value, target, factor, tnh)
	return value + tnh(target - value) * factor
end



--Create Table with Neurons
function Neuron.create(self)
	self.cells = {}
	self.channels = {}
	return self.cells, self.channels
end

function Neuron.addCellType(self, name)
	local t = require("types."..name)
	package.loaded[name] = nil
	self.types[name] = t
end

function Neuron.createCell(self, x, y, cellType)
	--Create basic cell
	if self.types[cellType] then
		table.insert(self.cells, self.types[cellType]:new(x, y))
		
		self:doOrderUpdate()
	end
end

--Broken
function Neuron.clearConnections(self, cell)
	for position, value in ipairs(self.cells[cell].axons) do
		print(value.connectedTo)
		for tablePosition = 1, #self.cells[value.connectedTo].dendrites,-1 do --Remove connection on connected cells
			if self.cells[value.connectedTo].dendrites[tablePosition].connectedTo == cell then
				table.remove(self.cells[value.connectedTo].dendrites, tablePosition)
			end
		end
	end
	
	for position, value in ipairs(self.cells[cell].dendrites) do
		print(value.connectedTo)
		for tablePosition = 1, #self.cells[value.connectedTo].axons,-1 do --Remove connection on connected cells
			if self.cells[value.connectedTo].axons[tablePosition].connectedTo == cell then
				table.remove(self.cells[value.connectedTo].axons, tablePosition)
			end
		end
	end
	
	self.cells[cell].axons = {}
	self.cells[cell].dendrites = {}
	self:doOrderUpdate()
end

function Neuron.deleteNeuron(self, cell)
	Neuron.channels = {} --Clean table of channels as it will be refilled at update
	collectgarbage("collect") --Force Garbage Collection	
	table.remove(self.cells, cell) 
	
	for cellPosition, cellTable in ipairs(self.cells) do
		for position, value in ipairs(cellTable.axons) do
			if  value.connectedTo==cell then --If is the removed cell, is marked to be removed	
				Neuron.cells[cellPosition].axons[position].connectedTo=-1
			elseif  value.connectedTo>cell then --If the position is bigger than  the removed cell, it got down on the table
				Neuron.cells[cellPosition].axons[position].connectedTo = Neuron.cells[cellPosition].axons[position].connectedTo - 1
			end
		end
		
		for position, value in ipairs(cellTable.dendrites) do
			if  value.connectedTo==cell then --If is the removed cell, is marked to be removed
				Neuron.cells[cellPosition].dendrites[position].connectedTo=-1
			elseif  value.connectedTo>cell then --If the position is bigger than  the removed cell, it got down on the table
				Neuron.cells[cellPosition].dendrites[position].connectedTo = Neuron.cells[cellPosition].dendrites[position].connectedTo - 1
			end
		end
	
		--For use in Digital
		if cellTable.cellForActivation ~= -1 and cellTable.cellForActivation then --If is the removed cell, remove dependency
			if cellTable.cellForActivation == cell then
				cellTable.cellForActivation = -1
			elseif cellTable.cellForActivation > cell then --If the position is bigger than  the removed cell, it got down on the table
				cellTable.cellForActivation =  cellTable.cellForActivation - 1
			end
		end
		
		--Remove marked conections
		for position = #cellTable.axons,1,-1 do
			if cellTable.axons[position].connectedTo==-1 then
				table.remove(Neuron.cells[cellPosition].axons, position)
			end
		end
		
		for position = #cellTable.dendrites, 1, -1 do
			if cellTable.dendrites[position].connectedTo == -1 then
				table.remove(Neuron.cells[cellPosition].dendrites, position)
			end
		end
	end
	self:doOrderUpdate()
end

function Neuron.connect(self, emitter, receiver)

	--Check if it makes a loop with itself
	for position, cell in ipairs(self.cells[emitter].axons) do
		if cell.connectedTo == receiver then
			return false
		end
	end

	for position, cell in ipairs(self.cells[receiver].dendrites) do
		if cell.connectedTo == emitter then
			return false
		end
	end

	if emitter == receiver then
		return false
	end
	
	--Insert Neurons
	table.insert(self.cells[emitter].axons, {connectedTo = receiver, strength = 1})
	table.insert(self.cells[receiver].dendrites, {connectedTo = emitter, strength = 1})

	--Update order of update	
	self:doOrderUpdate()
end

--Drawing Functions
function Neuron.showAxons(self, cell, isFirst)
	if isFirst == nil then
		isFirst = true
	end
	
	local selfX = self.cells[cell].x
	local selfY = self.cells[cell].y
	local connectedX 
	local connectedY
	
	--Translate Graphical Axis 
	if #self.cells[cell].axons > 0 then
		for position, value in ipairs(self.cells[cell].axons) do
			local connectedX = self.cells[value.connectedTo].x
			local connectedY = self.cells[value.connectedTo].y
	
			--Ensure line is visible
			if self.camera:isVisible(self.cells[cell].x, self.cells[cell].y,
			math.abs(selfX-connectedX), math.abs(selfY-connectedY)) then
				love.graphics.push()
				love.graphics.translate(self.camera:getTranslation())
				if isFirst then
					--Draw connection
					love.graphics.setColor(1,0,0)
					love.graphics.line(self.cells[cell].x, self.cells[cell].y, self.cells[value.connectedTo].x, self.cells[value.connectedTo].y)
					
					--Print strength
					love.graphics.setColor(1, 1, 1)
					love.graphics.printf(string.format("%.2f",(value.strength/#self.cells[value.connectedTo].dendrites)*100).."%", (self.cells[value.connectedTo].x+self.cells[cell].x)/2-40, (self.cells[value.connectedTo].y+self.cells[cell].y)/2, 80, "center")
					love.graphics.pop()
					self.showAxons(self, value.connectedTo, false)
				elseif not self.cells[cell].forceUpdate then
					--Draw connection
					love.graphics.setColor(1, 0, 0)
					love.graphics.line(self.cells[cell].x, self.cells[cell].y, self.cells[value.connectedTo].x, self.cells[value.connectedTo].y)
					love.graphics.pop()
					self.showAxons(self, value.connectedTo, false)
				else
					love.graphics.pop()
				end
			end
		end	
	end
end

function Neuron.showDendrites(self, cell, isFirst)
	if isFirst == nil then
		isFirst = true
	end
	
	--Translate Graphical Axis 
	local selfX = self.cells[cell].x
	local selfY = self.cells[cell].y
	local connectedX 
	local connectedY
	
	if #self.cells[cell].dendrites > 0 then
		for position, value in ipairs(self.cells[cell].dendrites) do
			local connectedX = self.cells[value.connectedTo].x
			local connectedY = self.cells[value.connectedTo].y
	
	
			--Ensure line is visible
			if self.camera:isVisible(self.cells[cell].x, self.cells[cell].y, 
			math.abs(selfX-connectedX), math.abs(selfY-connectedY)) then
				love.graphics.push()
				love.graphics.translate(self.camera:getTranslation())
				if isFirst then
					--Draw connection
					love.graphics.line(selfX, selfY, connectedX, connectedY)
					love.graphics.pop()
					self.showDendrites(self, value.connectedTo, false)
				elseif not Neuron.cells[cell].forceUpdate then
					--Draw connection
					love.graphics.line(selfX, selfY, connectedX, connectedY)
					love.graphics.pop()
					self.showDendrites(self, value.connectedTo, false)
				else
					love.graphics.pop()
				end
			end
		end	
	end
end

function Neuron:draw(drawValue)
	love.graphics.setColor(1, 1, 1)
	
	--Perfomance Related
	local drawLine = love.graphics.line
	
	
	love.graphics.push()
	love.graphics.translate(self.camera:getTranslation())
	--Draw conections lines
	for cellPosition, cell in ipairs(self.cells) do
		local cellX = cell.x
		local cellY = cell.y
		local connectedX 
		local connectedY
		for position, value in ipairs(cell.axons) do
			local connectedX = self.cells[value.connectedTo].x
			local connectedY = self.cells[value.connectedTo].y
			--Ensure line is visible
			if self.camera:isVisible(cellX, cellY, 
			math.abs(cellX-connectedX), math.abs(cellY-connectedY)) then
				drawLine(cell.x, cell.y, self.cells[value.connectedTo].x, self.cells[value.connectedTo].y)
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

--Updates
function Neuron.doOrderUpdate(self)
	self.updateOrder = {}
	--Update sums
	local updatedAll
	repeat --Repeat until all are updated
		updatedAll=true
		for cellPosition, cell in ipairs(self.cells) do
			if not cell.alreadyUpdated then
				if #cell.dendrites == 0 then --Update dentriteless cells
					table.insert(self.updateOrder, cellPosition)				
					cell.alreadyUpdated=true
				else
					if not cell.forceUpdate then --If update is not critical
						local canBeUpdated = true 
						for position, value in ipairs(cell.dendrites) do --Checks if can be updated
							if not self.cells[value.connectedTo].alreadyUpdated then --Check if cells before the actual cell on the chain are already updated
								canBeUpdated = false
							end
						end
						if canBeUpdated then
							table.insert(self.updateOrder, cellPosition)
							cell.alreadyUpdated = true
						end
					else
						table.insert(self.updateOrder, cellPosition)
						cell.alreadyUpdated = true
					end
				end
				updatedAll = false
			end
		end
	until updatedAll
	
	for cellPosition, cell in ipairs(self.cells) do
		cell.alreadyUpdated = false
	end
end

function Neuron.update(self, dt)
	for position, cell in ipairs (self.updateOrder) do
		for t, value in ipairs (self.cells[cell].axons) do
			self.cells[value.connectedTo].sum = self.cells[value.connectedTo].sum + (self.cells[cell].value * value.strength)
		end
		
		if #self.cells[cell].dendrites == 0 then
			if not self.cells[cell].bypassDendrites then
				self.cells[cell].target = self.cells[cell].value
			else --Do cell update function even with zero dendrites
				self.cells[cell]:update(self)
			end
		else
			self.cells[cell]:update(self)
		end
		
		self.cells[cell].sum = 0 
	end
	
	for cellPosition, cell in ipairs(self.cells) do
		if not cell.instantaneous then
			local tnh = math.tanh
			cell.value = self.tanh(cell.value, cell.target ,cell.volatility*dt, tnh)
		end
		cell.alreadyUpdated = false
	end
end

function Neuron.oldUpdate(self, dt)

	--Update sums
	local updatedAll
	repeat --Repeat until all are updated
		updatedAll=true
		for cellPosition, cell in ipairs(self.cells) do
			if not cell.alreadyUpdated then
				if #cell.dendrites == 0 then --Update dentriteless cells
					if not cell.bypassDendrites then
						cell.target = cell.value
					else --Do cell update function even with zero dendrites
						cell:update(self)
					end
					
					cell.alreadyUpdated=true
					for position, value in ipairs(cell.axons) do --Update the sums of the next cells on the chain
						self.cells[value.connectedTo].sum = self.cells[value.connectedTo].sum + (cell.value * value.strength)
					end
				else
					if not cell.forceUpdate then --If update is not critical
						local canBeUpdated = true 
						for position, value in ipairs(cell.dendrites) do --Checks if can be updated
							if not self.cells[value.connectedTo].alreadyUpdated then --Check if cells before the actual cell on the chain are already updated
								canBeUpdated = false
							end
						end
						if canBeUpdated then
							cell:update(self)
							cell.sum = 0
							cell.alreadyUpdated = true
							for position, value in ipairs(cell.axons) do--Update the sums of the next cells on the chain
								self.cells[value.connectedTo].sum = self.cells[value.connectedTo].sum + (cell.value * value.strength)
							end
						end
					else
						cell:update(self)
						cell.sum = 0
						cell.alreadyUpdated = true
						for position, value in ipairs(cell.axons) do--Update the sums of the next cells on the chain
							self.cells[value.connectedTo].sum = self.cells[value.connectedTo].sum + (cell.value * value.strength)
						end
					end
				end
				updatedAll = false
			end
			

		end
	until updatedAll
	
	--Update neurons values
	for cellPosition, cell in ipairs(self.cells) do
		if not cell.instantaneous then
			cell.value = self.tanh(cell.value, cell.target ,cell.volatility*dt)
		end
		cell.alreadyUpdated = false
	end
end


