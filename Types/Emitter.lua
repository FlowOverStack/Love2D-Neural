return 
	{
		--Specific Variables
		channel = 1,
		colors = {
			red = 1,
			green = 1,
			blue = 1
		},
		--Functions
		draw = function (self)	
			--Back of cell
			love.graphics.setColor(1-self.value, self.value, 0, 1) --Gradient red to green
			love.graphics.rectangle("fill", self.x-16, self.y-16, 32, 32)
			
			--Front of cell
			love.graphics.setColor(self.colors.red, self.colors.green, self.colors.blue)
			love.graphics.rectangle("line", self.x-16, self.y-16, 32, 32)
			--Show values
			love.graphics.setColor(1, 1, 1)
			love.graphics.printf(string.format("%.2f",self.value), math.modf(self.x)-16, math.modf(self.y)-8, 32, "center")
		end,
		
		update = function(self, instance)
			self.target = self.sum/#self.dendrites
			self.value = self.target
			instance.channels[self.channel] = self.value 
		end
	}