require("classlib")
--creature class

--animalId - Where it can live - Represented by: Body Colour
--  1 = Invertebrate		- Light Blue/purple
--  2 = Fish				- Orange
--  3 = Amfibian			- Yellow
--  4 = Reptile				- Light Green
--  5 = Bird				- Grey
--  6 = Mammal				- Brown

--foodA/B - What it can eat - Represented by: 
-- -4 = seaAnt
-- -3 = seaPlant
-- -2 = landPlant
-- -1 = landAnt
--  0 = nothing
--  1 = Invertebrate
--  2 = Fish
--  3 = Amfibian
--  4 = Reptile
--  5 = Bird
--  6 = Mammal

--attackA/B - Attack mechanism - Represented by: 
--	0 = nothing
--  1 = Hoover		- Eats whatever it finds		- Short Body Feelers

--birthSize/maxSize - Upper and Lower bounds of a creature's size
--currentSize - btween upper and lower bounds

--class define
class "Creature"-- : extends(classlib)
{
	animalId = 0, 
	x = 0, y = 0, --for x and y whole numbers are considered grid positions, decimals are their location in those blocks
	foodA = 0, foodB = 0,
	foodMin = 0, foodMax = 0, foodCurrent = 0,
	attackA = 0, attackB = 0, 
	birthSize = 0, maxSize = 0, 
	currentSize = 0, 
	
	moveX = 0, moveY = 0,
	maxHeat = 0, minHeat = 0, maxWater = 0, minWater = 0,
	maxSpeed = 0,
	hp = 0, maxHp = 0,
	visionDis = 0,
	
	checkTimer = 0, checkTimerMax = 0,
	targetX = 0, targetY = 0,
	currentSpeedMultiplier = 0,
}

--also for creature birth
function Creature:__init(id, x, y, foodA, foodB, attackA, attackB, birthSize, maxSize)
	self.animalId = id
	self.x = x
	self.y = y
	self.foodA = foodA
	self.foodB = foodB
	self.foodMin = 10
	self.foodMax = 200
	self.foodCurrent = 50
	self.attackA = attackA
	self.attackB = attackB
	self.birthSize = birthSize
	self.currentSize = birthSize
	self.maxSize = maxSize
	
	
	self.maxHp = 50
	self.hp = self.maxHp
	self.visionDis = 5
	self.moveX = 0
	self.moveY = 0
	self.maxSpeed = 0.2
	self.checkTimer = -2
	self.checkTimerMax = 10
	self.targetX = x
	self.targetY = y
	self.currentSpeedMultiplier = 1
end

function Creature:getLifeStats()
	return maxHeat, minHeat, maxWater, minWater
end

function Creature:getPosition()
	return self.x, self.y
end

function Creature:changeHp(val)
	self.hp = self.hp + val
	if self.hp <= 0 then
		self.hp = 0
	elseif self.hp > self.maxHp then
		self.hp = self.maxHp
	end
end

function Creature:isHungry()
	if self.foodCurrent < (self.foodMin + ((self.foodMax - self.foodMin) * 0.5)) then
		return true
	end
	
	return false
end

function Creature:updateSpeed()
	if self:isHungry() then
		self.currentSpeedMultiplier = 1
	end
	
	self.currentSpeedMultiplier = 0.5
end

function Creature:testIsFood(blk)
	--test for planktondddddddddddddddd
	if (self.foodA == -4 or self.foodB == -4) and blk.seaAntLife > 0 then
		return blk.seaAntLife
	--test for coral
	elseif (self.foodA == -3 or self.foodB == -3) and blk.seaPlantLife > 0 then
		return blk.seaPlantLife
	--test for plants
	elseif (self.foodA == -2 or self.foodB == -2) and blk.landPlantLife > 0 then
		return blk.landPlantLife
	--test for ants
	elseif (self.foodA == -1 or self.foodB == -1) and blk.landAntLife > 0 then
		return blk.landAntLife
	end
	
	return 0
end

function Creature:eatFood(blk)
	if (self.foodA == -4 or self.foodB == -4) and blk.seaAntLife > 20 then
		blk.seaAntLife = blk.seaAntLife - 10
		self.foodCurrent = self.foodCurrent + 10
	elseif (self.foodA == -3 or self.foodB == -3) and blk.seaPlantLife > 20 then
		blk.seaPlantLife = blk.seaPlantLife - 10
		self.foodCurrent = self.foodCurrent + 10
	elseif (self.foodA == -2 or self.foodB == -2) and blk.landPlantLife > 20 then
		blk.landPlantLife = blk.landPlantLife - 10
		self.foodCurrent = self.foodCurrent + 10
	elseif (self.foodA == -1 or self.foodB == -1) and blk.landAntLife > 20 then
		blk.landAntLife = blk.landAntLife - 10
		self.foodCurrent = self.foodCurrent + 10
	else
		self.checkTimer = -2 --allow creature to look for next place to move to
	end
end

function Creature:reproduce()
	
end

function Creature:update()
	
end
