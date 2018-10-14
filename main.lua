setmetatable(_G, {__newindex = function (t, k, v)
   rawset(t, k, v)
   print(([[Created global "%s" with value "%s"]]):format(k, v))
  end}
)

require "extendedMath"

local Neuron = loadfile("Neuron.lua")()
local GUI = require "GUI.GUI"




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
local leftClickActions = loadfile( "leftClickActions.lua")(Neuron)
local selectedAction = 1

--Memory Profiler
local lastMemory = 0


local Canvas = love.graphics.newCanvas(800, 600)


local trainableButton = GUI:createButton(250, 0, "Trainable", 75, 25)
trainableButton.onPress = function(self)
	selectedAction = 1
end

local inverseButton = GUI:createButton(250, 25, "Inverse", 75, 25)
inverseButton.onPress = function(self)
	selectedAction = 2
end

local digitalButton = GUI:createButton(250, 50, "Digital", 75, 25)
digitalButton.onPress = function(self)
	selectedAction = 3
end

local activableButton = GUI:createButton(325, 0, "Activable", 75, 25)
activableButton.onPress = function(self)
	selectedAction = 4
end

local emitterButton = GUI:createButton(325, 25, "Emitter", 75, 25)
emitterButton.onPress = function(self)
	selectedAction = 5
end

local receiverButton = GUI:createButton(325, 50, "Receiver", 75, 25)
receiverButton.onPress = function(self)
	selectedAction = 6
end

local changeValueButton = GUI:createButton(400, 0, "Change V", 75, 25)
changeValueButton.onPress = function(self)
	selectedAction = 7
end

local emitterButton = GUI:createButton(400, 25, "Instantaneous", 75, 25)
emitterButton.onPress = function(self)
	selectedAction = 8
end




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
		if not GUI:mousepressed(x, y, button) then
			leftClickActions[selectedAction].onClick(x, y)
		end
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