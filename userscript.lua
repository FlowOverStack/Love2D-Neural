function love.draw()
	Neuron:draw(800, 600, camera.x, camera.y)
	Note:draw(800, 600, camera.x, camera.y)
	GUI.draw()
end

function love.update(dt)
	Neuron:update(dt)
	
	--change camera position
	if love.keyboard.isDown("up") then
		camera.y = camera.y - camera.speed*dt
	elseif love.keyboard.isDown("down") then
		camera.y = camera.y + camera.speed*dt
	end
	
	if love.keyboard.isDown("left") then
		camera.x = camera.x - camera.speed*dt
	elseif love.keyboard.isDown("right") then
		camera.x = camera.x + camera.speed*dt
	end
	
	Neuron.cells[1].value = love.mouse.getX()/800
end

function love.mousepressed()

end

function love.mousereleased()

end