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

--also for creature birth
function Creature:__init()
	self.id = id
	self.x = 10
	self.y = 10
end

function Creature:getLifeStats()
	return maxHeat, minHeat, maxWater, minWater
end

function Creature:getPosition()
	return self.x, self.y
end
