require("classlib")
--creature class

--animalId - Where it can live - Represented by: Body Colour
--  1 = Invertebrate		- Light Blue
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
	animalId, 
	x, y, --for x and y whole numbers are considered grid positions, decimals are their location in those blocks
	foodA, foodB,
	foodMin, foodMax, foodCurrent,
	attackA, attackB, 
	birthSize, maxSize, 
	currentSize, 
	
	moveX, moveY,
	maxHeat, minHeat, maxWater, minWater,
	maxSpeed,
	hp, maxHp,
	visionDis,
	
	checkTimer, checkTimerMax,
	targetX, targetY,
}

--also for creature birth
function Creature:__init(id, x, y, foodA, foodB, attackA, attackB, birthSize, maxSize)
	self.animalId = id
	self.x = x
	self.y = y
	self.foodA = foodA
	self.foodB = foodB
	self.foodMin = 5
	self.foodMax = 200
	self.foodCurrent = 100
	self.attackA = attackA
	self.attackB = attackB
	self.birthSize = birthSize
	self.currentSize = birthSize
	self.maxSize = maxSize
	
	
	self.maxHp = 100
	self.hp = self.maxHp
	self.visionDis = 5
	self.moveX = 0
	self.moveY = 0
	self.maxSpeed = 1
	self.checkTimer = 0
	self.checkTimerMax = 10
	self.targetX = x
	self.targetY = y
end

function Creature:getLifeStats()
	return maxHeat, minHeat, maxWater, minWater
end

function Creature:getPosition()
	return self.x, self.y
end

function Creature:update()
	
end
