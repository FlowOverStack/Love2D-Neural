local Neuron = ...

return {
	{
		name = "Trainable" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Trainable")
		end
	},
	{
		name = "Inverse" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Inverse")
		end
	},
	{
		name = "Digital" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Digital")
		end
	},
	{
		name = "Activable" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Activable")
		end
	},
	{
		name = "Emitter" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Emitter")
		end
	},	
	{
		name = "Receiver" ,
		onClick = function(x, y)
			local mx=math.middle(x/16)*16
			local my=math.middle(y/16)*16
			Neuron:createCell(mx, my, "Receiver")
		end
	},
	{
		name = "Change Value - Binary" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					cell.value = cell.value == 1 and 0 or 1
				end
			end
		end
	},
	{
		name = "Set instantaneous" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					cell.instantaneous = not cell.instantaneous
				end
			end
		end
	},
	{
		name = "Set volatility" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					io.write("Insert volatility: ")
					cell.volatility = tonumber(receiveText())
				end
			end
		end
	},
	{
		name = "Set activation" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					if cell.activation then
						io.write("Insert activation: ")
						cell.activation = tonumber(receiveText())
					end
				end
			end
		end
	},
	{
		name = "Set cell for dynamic activation" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) and selectedCell ~= 0 and cell.activation then --checks if Digital
					cell.cellForActivation = selectedCell
					selectedCell = 0
				end
			end
		end
	},
	{
		name = "Set channel" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					if cell.channel then
						io.write("Insert channel: ")
						cell.channel = tonumber(receiveText())
					end
				end
			end
		end
	},
	{
		name = "Set strength" ,
		onClick = function(x, y)
			for cellPosition, cell in ipairs(Neuron.cells) do
				if math.isInsideRadius(x, y, cell.x, cell.y, 16) then
					if #cell.axons > 0 then
						print("Connections available:")
						for position, value in ipairs(cell.axons) do
							io.write(value.connectedTo.."  ")
						end
						print()
						
						print("Select connection:")
						local selectedConnection = tonumber(receiveText())
						local selectedConnectionPosition = 0
						
						for position, value in ipairs(cell.axons) do
							if value.connectedTo == selectedConnection then
								selectedConnectionPosition = position
							end
						end
						
						if selectedConnectionPosition ~= 0 then
							io.write("Insert strength: (0 <= x <= 1 ")
							cell.axons[selectedConnectionPosition].strength = tonumber(receiveText())*#Neuron.cells[cell.axons[selectedConnectionPosition].connectedTo].dendrites
						else
							print("Connection not found")
						end
					end
				end
			end
		end
	},
	{
		name = "Create note" ,
		onClick = function(x, y)
			io.write("Write text:")
			Note:create(x, y, receiveText())
		end
	},
	{
		name = "Change note" ,
		onClick = function(x, y)
			for position, value in ipairs(Note.notes) do
				if x>value.x-16 and x<value.x and
				y>value.y and y<value.y+16 then
					io.write("Write text:")
					value.text = receiveText()
				end
			end
		end
	},
	{
		name = "Delete note" ,
		onClick = function(x, y)
			for position, value in ipairs(Note.notes) do
				if x>value.x-16 and x<value.x and
				y>value.y and y<value.y+16 then
					Note:delete(position)
					break
				end
			end
		end
	}
}