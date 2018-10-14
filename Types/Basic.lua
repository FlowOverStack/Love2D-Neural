local Basic = {
	--Graphical variables
	x = 100,
	y = 100,
	colors = {
		red = 1,
		green = 1,
		blue = 1
	},
	
	--Neuron variables
	value=0,
	target=0,
	activation=0.7,
	volatility=0.5,
	sum=0,
	instantaneous = false,
	
	--Variables for updates
	alreadyUpdated=false,
	forceUpdate=false,
	bypassDendrites = false,
	
	--Tables for conections
	dendrites={},

	axons={}
}

--Functions
function Basic:new(x, y, o)
	local o = o or {}
	setmetatable(o, {__index = self})
	o.x = x
	o.y = y
	o.dendrites = {}
	o.axons = {}
	return o
end

function Basic:draw(drawValue)	
	if not self.instantaneous then
		--Back of cell
		love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
		love.graphics.circle("fill", self.x, self.y, 16)
		
		--Front of cell
		love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
		love.graphics.circle("line", self.x, self.y, 16)
	else
		--Back of cell
		love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
		love.graphics.rectangle("fill", self.x-16, self.y-16, 32, 32)
		
		--Front of cell
		love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
		love.graphics.rectangle("line", self.x-16, self.y-16, 32, 32)
	end
	--Show values
	if drawValue then
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(string.format("%.2f",self.value), math.modf(self.x)-16, math.modf(self.y)-8, 32, "center")
	end	
	
	love.graphics.setColor(1, 1, 1)
end

function Basic:update(dt)

end
return Basic

