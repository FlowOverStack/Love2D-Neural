setmetatable(_G, {__newindex = function (t, k, v)
   rawset(t, k, v)
   print(([[Created global "%s" with value "%s"]]):format(k, v))
  end}
)

require "extendedMath"

local Neuron = require "Neuron"
local GUI = require "GUI.GUI"


GUI:createButton(0, 0, "Create", 100, 100)
--require "Note"

--TODO Redo this file

Neuron:new()
Neuron:addCellType("Basic")
Neuron:addCellType("Trainable")
Neuron:addCellType("Inverse")
Neuron:addCellType("Activable")
Neuron:addCellType("Digital")

--Neuron:addCellType("Emitter")
--Neuron:addCellType("Receiver")

local selectedCell = 0
love.window.setTitle("5.3")

local isSeeAxonsEnabled = true
local isSeeDendritesEnabled = true
local drawValues = false

local scaleX = 1
local scaleY = 1

love.mouse.getScaledX = function () return love.mouse.getX()/scaleX  end
love.mouse.getScaledY = function () return love.mouse.getY()/scaleY  end

camera = {
	x = 0,
	y = 0,
	speed = 100
}

local text = ""
local function receiveText()
	local t = text
	text = ""
	return t
end

--Tools
leftClickActions = {
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
local selectedAction = 1

--Memory Profiler
local lastMemory = 0


local Canvas = love.graphics.newCanvas(800, 600)







--Love2d Callback Functions
function love.draw()
	love.graphics.scale(scaleX, scaleY)
	
	
	local lgPrint = love.graphics.print 
	local lgPrintf = love.graphics.printf

	love.graphics.setColor(1,1,1)
	lgPrint(leftClickActions[selectedAction].name, 0, 0)
	lgPrint(("Memory used by Lua: %.2f KB/s: %.2f"):format(collectgarbage("count"), collectgarbage("count")-lastMemory), 0, 16)
	lgPrint(("FPS: %d"):format(love.timer.getFPS()), 0, 32)
	lgPrint(("Camera X: %f Y: %f"):format(Neuron.camera.x, Neuron.camera.y), 0, 48)
	lgPrint(text, 0, 64)

	--Memory Profiler
	lastMemory = collectgarbage("count")
	
	--Modules functions
	love.graphics.setCanvas(Canvas)		
	love.graphics.clear()
	Neuron:draw(drawValues)

	love.graphics.setCanvas()
	love.graphics.draw(Canvas, 0, 0)
	
	--Draw incomplete connection

	
	--Highlight cell below mouse
	--Axons
	love.graphics.setColor(1,0, 0)
	for cellPosition, cell in ipairs(Neuron.cells) do
		if math.isInsideRadius(love.mouse.getScaledX()+Neuron.camera.x, love.mouse.getScaledY()+Neuron.camera.y, cell.x, cell.y, 16) then
			
			if isSeeAxonsEnabled then
				Neuron:showAxons(cell, 5)
			end
			
			if isSeeDendritesEnabled then
				love.graphics.setColor(0, 1, 0)
				Neuron:showDendrites(cell, 5)
			end
			
			if not drawValues then
				love.graphics.push()
				love.graphics.translate(Neuron.camera:getTranslation())
				cell:draw(true, Neuron)
				love.graphics.pop()
			end
			
			love.graphics.setColor(0, 1, 1)
			lgPrintf(string.format("%.2f", cell.volatility), cell.x-Neuron.camera.x-16, cell.y-Neuron.camera.y+16, 32, "center")
		end
	end
	
	if selectedCell ~= 0 then
		love.graphics.line(Neuron.cells[selectedCell].x-Neuron.camera.x, Neuron.cells[selectedCell].y-Neuron.camera.y , love.mouse.getScaledX(), love.mouse.getScaledY())
	end
	
	GUI:draw()
end

function love.update(dt)
	Neuron:update(dt)
	
	
	--change camera position
	local speed = 100
	if love.keyboard.isDown("up") then
		Neuron.camera.y = Neuron.camera.y - speed*dt
	elseif love.keyboard.isDown("down") then
		Neuron.camera.y = Neuron.camera.y + speed*dt
	end
	
	if love.keyboard.isDown("left") then
		Neuron.camera.x = Neuron.camera.x - speed*dt
	elseif love.keyboard.isDown("right") then
		Neuron.camera.x = Neuron.camera.x + speed*dt
	end
end

function love.keypressed(key)
	if key == "a" then
		isSeeAxonsEnabled = not isSeeAxonsEnabled
	elseif key=="s" then
		isSeeDendritesEnabled = not isSeeDendritesEnabled
	end
	
	if key == "backspace" then
		text = string.sub(text, 1, string.len(text)-1)
	end
end

function love.textinput(t)
	text = text..t
end

function love.mousepressed(x, y, button)
	x = x/scaleX
	y = y/scaleY

	local offsetX = x+Neuron.camera.x
	local offsetY = y+Neuron.camera.y

	--Create Cell
	if button == 1 then
		leftClickActions[selectedAction].onClick(offsetX, offsetY)
		selectedCell = 0 --Comment for cellphones
	--Create Connection
	elseif button == 2 then 
		for cellPosition, cell in ipairs(Neuron.cells) do
			if math.isInsideRadius(offsetX, offsetY, cell.x, cell.y, 16) then --The snapping is not used
				if selectedCell == 0 then
					selectedCell = cellPosition
					return true
				else
					Neuron:connect(Neuron.cells[selectedCell], Neuron.cells[cellPosition]) 
					selectedCell = 0
					return true
				end
			end
		end
		
		
	--Delete Cell
	elseif button == 3 then 
		for cellPosition, cell in ipairs(Neuron.cells) do
			if math.isInsideRadius(offsetX, offsetY, cell.x, cell.y, 16) then --The snapping is not used
				Neuron:deleteNeuron(cell)
				if cellPosition == selectedCell then
					selectedCell = 0
					break
				end
			end
		end		
	end
end




function love.wheelmoved(x, y)
	if y < 0 then
		selectedAction = selectedAction < #leftClickActions and selectedAction+1 or 1
	elseif y > 0 then
		selectedAction = selectedAction > 1 and selectedAction-1 or #leftClickActions
	end
end