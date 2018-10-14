local Button = {
	x = 0,
	y = 0,
	textImage = nil,
	text = "",
	width = 100,
	height = 50
}

function Button:new(o)
	local o = o or {}
	setmetatable(o, {__index = self})
	return o
end

function Button:onPress()

end

function Button:onHover()

end

function Button:onRelease()

end

function Button:draw()
	local x, y = self:getPosition()
	local w, h = self:getDimensions()
	love.graphics.push()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", x, y, w, h)
	love.graphics.draw(self.textImage, x, y)
	love.graphics.pop()
end

function Button:setText(text, font)
	font = font or love.graphics.getFont()
	self.textImage = love.graphics.newText(font, text)
	self.text = text
end

function Button:getText()
	return self.text
end

function Button:setPosition(x, y)
	self.x = x
	self.y = y
end

function Button:getPosition()
	return self.x, self.y
end

function Button:setDimensions(w, h)
	self.w = w
	self.h = h
end

function Button:getDimensions()
	return self.w, self.h
end

return Button