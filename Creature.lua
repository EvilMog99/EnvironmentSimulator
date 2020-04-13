require("classlib")
--creature class

--class define
class "Creature"-- : extends(classlib)
{
	id, 
	x, y, --for x and y whole numbers are considered grid positions, decimals are their location in those blocks
	maxHeat, minHeat, maxWater, minWater,
	walkSpeed, runSpeed,
	
	
	
	
	
}

function Creature:__init(id)
	self.id = id
	self.x = 10
	self.y = 10
	if id == 1 then -- shrimp
		self.walkSpeed = 10
		self.runSpeed = 15
		self.maxHeat = 50
		self.minHeat = 2
		self.maxWater = 180
		self.minWater = 10
	elseif id == 2 then -- herbFish
		self.walkSpeed = 12
		self.runSpeed = 15
		self.maxHeat = 80
		self.minHeat = 20
		self.maxWater = 200
		self.minWater = 20
	elseif id == 3 then -- herbFish
		self.walkSpeed = 15
		self.runSpeed = 15
		self.maxHeat = 80
		self.minHeat = 20
		self.maxWater = 200
		self.minWater = 20
	else -- nothing recognised
	
	end
end

function Creature:getLifeStats()
	return maxHeat, minHeat, maxWater, minWater
end

function Creature:getPosition()
	return self.x, self.y
end
