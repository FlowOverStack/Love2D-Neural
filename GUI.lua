GUI = {
	defaultButton = {
		type = "bt",
		x=0,
		y=0,
		width=100,
		height=50,
		text="Default",
		isVisible=true,
		onPress = function () print("Default button pressed") end,
		onHover =  function () print("Default button hovered") end,
		onRelease = function () print("Default button released") end,
		onDestroy = function(self) object = nil print(#GUI.buttons) print(#GUI.panels) end,
		imageReleased  = love.graphics.newImage("images/defaultbuttonreleased.png"),
		imagePressed  = love.graphics.newImage("images/defaultbuttonpressed.png"),
	},
	
	defaultPanel = {
		type = "pn",
		x=0,
		y=0,
		width=100,
		height=50,
		text="Default",
		isVisible=true,
		alignment="center",
		offsetX = 0,
		offsetY = 0,
		--image=
		onDestroy = function(self) object = nil print(#GUI.buttons) print(#GUI.panels) end,
	
	
	},

	buttons = {},
	panels = {}
}

function GUI.createButton(buttonTable)
	table.insert(GUI.buttons,{})
	setmetatable(GUI.buttons[#GUI.buttons], {__index = GUI.defaultButton})
	for i,v in pairs(buttonTable) do
		GUI.buttons[#GUI.buttons][i] = v
	end
	GUI.buttons[#GUI.buttons].position = #GUI.buttons
	return GUI.buttons[#GUI.buttons]
end

function GUI.createPanel(panelTable)
	table.insert(GUI.panels,{})
	setmetatable(GUI.panels[#GUI.panels], {__index = GUI.defaultPanel})
	for i,v in pairs(panelTable) do
		GUI.panels[#GUI.panels][i] = v
	end
	GUI.panels[#GUI.panels].position = #GUI.panels
	return GUI.panels[#GUI.panels]
end


function GUI.destroy(object)
	if object.type == "bt" then
		table.remove(GUI.buttons,object.position)
	elseif object.type == "pn" then
		table.remove(GUI.panels,object.position)
	end
end

function GUI.clear()
	GUI.buttons = {}
	GUI.panels = {}
end

function GUI.draw(offsetX,offsetY,scaleX,scaleY)
	offsetX = offsetX and offsetX or 0
	offsetY = offsetY and offsetY or 0
	scaleX = scaleX and scaleX or 1
	scaleY = scaleY and scaleY or 1
	love.graphics.push()
	love.graphics.translate(offsetX,offsetY)
	
	for i,v in ipairs(GUI.panels) do
		if (v.isVisible) then
			if v.alignment == "center" then
				love.graphics.printf(v.text,v.x,v.y+(v.height/2)-8,v.width,"center")
			end
		end
	end
	
	
	for i,v in ipairs(GUI.buttons) do
		if (v.isVisible) then
			if love.mouse.isDown(1) then
				local x=love.mouse.getX()
				local y=love.mouse.getY()
				if x>= (v.x+offsetX)*scaleX
				and y >= (v.y +offsetY)*scaleY
				and x <= (v.x+v.width+offsetX)*scaleX 
				and y <= (v.y+v.height+offsetY)*scaleY  then
					love.graphics.draw(v.imagePressed,v.x,v.y,0,v.width/v.imagePressed:getWidth(),v.height/v.imagePressed:getHeight())
				else
					love.graphics.draw(v.imageReleased,v.x,v.y,0,v.width/v.imageReleased:getWidth(),v.height/v.imageReleased:getHeight())
				end
			else
				love.graphics.draw(v.imageReleased,v.x,v.y,0,v.width/v.imageReleased:getWidth(),v.height/v.imageReleased:getHeight())
				
			end
			love.graphics.printf(v.text,v.x,v.y+(v.height/2)-8,v.width,"center")
		end
	end
	
	love.graphics.pop()
end

function GUI.mousepressed(x,y,button,offsetX,offsetY,scaleX,scaleY)
	offsetX = offsetX and offsetX or 0 
	offsetY = offsetY and offsetY or 0
	scaleX = scaleX and scaleX or 1
	scaleY = scaleY and scaleY or 1
	if button == 1 then
		for i,v in pairs(GUI.buttons) do
			if x>= (v.x+offsetX)*scaleX
			and y >= (v.y +offsetY)*scaleY
			and x <= (v.x+v.width+offsetX)*scaleX 
			and y <= (v.y+v.height+offsetY)*scaleY 
			and v.isVisible then
				v.onPress()
				break
			end
		end
	end
end

function GUI.mousereleased(x,y,button,offsetX,offsetY,scaleX,scaleY)
	offsetX = offsetX and offsetX or 0 
	offsetY = offsetY and offsetY or 0
	scaleX = scaleX and scaleX or 1
	scaleY = scaleY and scaleY or 1
	if button == 1 then
		for i,v in pairs(GUI.buttons) do
			if x>= (v.x+offsetX)*scaleX
			and y >= (v.y +offsetY)*scaleY
			and x <= (v.x+v.width+offsetX)*scaleX 
			and y <= (v.y+v.height+offsetY)*scaleY 
			and v.isVisible then
				v.onRelease()
				break
			end
		end
	end
end