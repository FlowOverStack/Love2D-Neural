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
end

function GUI:draw()
	for i, v in ipairs(self.buttons) do
		v:draw()
	end
end

return GUI