local Camera = {}

Camera.x = 0 					--X position
Camera.y = 0					--Y position
Camera.screenWidth = 800		--Screen width
Camera.screenHeight = 600		--Screen height
Camera.scale = 1				--Scale (screen pixel/image pixel)


function Camera:start(w, h)
	if not w and not h then
		w, h = love.graphics.getDimensions()
	end
	self.screenWidth = w
	self.screenHeight = h
end

--Set position
function Camera:setPosition(x, y)
	self.x = x
	self.y = y
end

--Get camera real position
function Camera:getPosition()
	return self.x, self.y
end

--Translate position by an vector
function Camera:translate(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

--Callback for window resize
function Camera:resize(width, height)
	self.screenWidth = width
	self.screenHeight = height
end

--Change scale
function Camera:setScale(scale)
	self.scale = scale
end

--Get scale
function Camera:getScale()
	return self.scale
end

--Get translation vector for use with a love.graphics.translate
function Camera:getTranslation()
	return math.floor(-self.x*self.scale), math.floor(-self.y*self.scale)
end

--Check if is visible
function Camera:isVisible(x, y, width, height)
	return 	x+width>=self.x and
			x<=self.x+self.screenWidth/self.scale and
			y+height>=self.y and
			y<=self.y+self.screenHeight/self.scale
end
return Camera