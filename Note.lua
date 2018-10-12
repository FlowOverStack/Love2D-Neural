Note = {
	notes = {}
}

function Note:create(x, y, text)
	table.insert(self.notes, {x = x, y= y, text = love.graphics.newText(love.graphics.getFont(), text)})
end

function Note:delete(position)
	if self.notes[position] then
		table.remove(self.notes, position)
	end
end

function Note:draw()
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.push()
	love.graphics.translate(Neuron.camera:getTranslation())
	for position, value in ipairs(self.notes) do
		love.graphics.draw(value.text, math.modf(value.x), math.modf(value.y))
	end
	love.graphics.pop()
end


