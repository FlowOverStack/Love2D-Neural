return 
	{
		--Specific Variables
		channel = 1,
		bypassDendrites = true,
		colors = {
			red = 0,
			green = 0,
			blue = 0
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
			love.graphics.setColor(1,1,1)
			love.graphics.printf(string.format("%.2f",self.value), math.modf(self.x)-16, math.modf(self.y)-8, 32, "center")
		end,
		
		update = function(self, instance)
			if instance.channels[self.channel] then
				self.target = instance.channels[self.channel]
				self.value = self.target
			else
				self.target = 0
				self.value = self.target
			end
		end
	}