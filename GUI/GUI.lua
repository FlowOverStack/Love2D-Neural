local Button = require "GUI.Button"

local GUI = {
	buttons = {}
}

function GUI:createButton(x, y, text, w, h)
	local button = Button:new()

	button:setPosition(x, y)
	button:setText(text)
	button:setDimensions(w, h)
	
	table.insert(self.buttons, button)
	return button
end

function GUI:draw()
	for i, v in ipairs(self.buttons) do
		v:draw()
	end
end

function GUI:mousepressed(x, y, button)
	local touchedButton = false
	if button == 1 then
		for i, v in ipairs(self.buttons) do
			local bx, by = v:getPosition()
			local w, h = v:getDimensions()
			
			if bx < x and x < bx+w and
			by < y and y < by+h then
				v:onPress()
				touchedButton = true
			end
		end
	end
	
	return touchedButton
end

return GUI