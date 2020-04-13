require("classlib")

--relevant constant values
function protect(tbl)
	return setmetatable({}, {
		__index = tbl,
		__newindex = function(t, key, value)
			error("attempting to change constant " .. tostring(key) .. " to " .. tostring(value), 2)
		end
	})
end

blktype = {
	empty 	= 1,
	stone 	= 2,
	sand	= 3,
	lava 	= 4
}

blktype = protect(blktype)

plantMaxHeat = 85
plantMinHeat = 5
plantMaxWater = 100
plantMinWater = 5


--class define
class "Block"-- : extends(classlib)
{
--vars
	id = -1,
	hp = 100, maxhp = 100,
	timer = 0, maxTimer = 60,
	canSpread = false,
	heat = 0, water = 0, plantLife = 0, steam = 0,
--make sure to include all above in copy func

	moveX = function(self, addx)
				--self.x = self.x + addx
			end,
			
	moveY = function(self, addy)
			--self.y = self.y + addy
			end,
			
	runTimer = function(self, speed, delatTime)
				timer = timer + (speed * delatTime)
				if timer > maxTimer then
					timer = 0
					--cycled = true
				end
			end,
			
	resetId = function (self, newid)
				self.id = newid
			end
}
function Block:__init(newId)
	self.id = newId
	self.timer = 0
	self.maxTimer = 0
	self.canSpread = false
	self.heat = 0
	self.water = 0
	self.plantLife = 0
	self.steam = 0
	hp = 100
	maxhp = 100
end

function Block:copy(target)
	target.id = self.id
	target.timer = self.timer
	target.maxTimer = self.maxTimer
	target.canSpread = self.canSpread
	target.heat = self.heat
	target.water = self.water
	target.plantLife = self.plantLife
	target.steam = self.steam
	target.hp = self.hp
	target.maxhp = self.maxhp
end

function Block:defineType()
	if self.id == blktype.lava then
		plantLife = 0
		if self.heat > 100 then
			self.canSpread = true
		end
	end
	
	if self.plantLife > 0 then --if plant life exists at all
		self.plantLife = self.plantLife + Block:calcPlantSurvival(self.heat, self.water) --calculate its survival	
		if self.plantLife > 200 then
			self.plantLife = 200
		end
	else if self.id ~= 0 and self.id ~= 4 and self.water > 5 and self.heat > 5 and love.math.random(1, 1000) == 2 then
		--self.plantLife = 1
	end end
end

function Block:calcPlantSurvival(heat, water)
	ht = (plantMaxHeat - heat) + (heat - plantMinHeat)
	wt = (plantMaxWater - water) + (water - plantMinWater)
	if ht > 10 then
		ht = 10
	end
	if wt > 10 then
		wt = 10
	end
	
	if wt < ht then
		return wt
	else 
		return ht
	end
end

function Block:interact(neighbour)
	--share values
	if self.id == blktype.empty then
		neighbour.heat, self.heat = self:fastShare(neighbour.heat, self.heat)
		neighbour.water, self.water = self:fastShare(neighbour.water, self.water)
	else if self.id == blktype.sand then
		neighbour.heat, self.heat = self:mediumShare(neighbour.heat, self.heat)
		neighbour.water, self.water = self:mediumShare(neighbour.water, self.water)
	else if self.id == blktype.stone then
		neighbour.heat, self.heat = self:slowShare(neighbour.heat, self.heat)
		neighbour.water, self.water = self:slowShare(neighbour.water, self.water)
	else if self.id == blktype.lava then
		if neighbour.id == blktype.lava then
			neighbour.heat, self.heat = self:fastShare(neighbour.heat, self.heat)
			neighbour.water, self.water = self:fastShare(neighbour.water, self.water)
		else
			neighbour.heat, self.heat = self:mediumShare(neighbour.heat, self.heat)
			neighbour.water, self.water = self:mediumShare(neighbour.water, self.water)
			if self.canSpread then
				neighbour.id = 4 --lava
			end
		end
		
		if self.water > 0 then
			self:evaporateWater()
		end
	end end end end
	
	if self.plantLife > 5 and neighbour.id ~= 0 and neighbour.id ~= 4 then
		neighbour.plantLife, self.plantLife = self:mediumShare(neighbour.plantLife, self.plantLife)
	end
	
	self:checkValues()
end

function Block:evaporateWater()
	if self.water > 10 and self.heat > 109 then
		self.water = self.water - 10
		self.steam = self.steam + 10
		self.heat = self.heat - 10
	else if self.water > 0 and self.heat > 99 then
		self.water = self.water - 2
		self.steam = self.steam + 2
		self.heat = self.heat - 2
	else if self.water > 0 and self.heat > 1 then
		self.water = self.water - 1
		self.steam = self.steam + 1
		self.heat = self.heat - 1
	end end end
end

function Block:condensateWater()
	
end

function Block:checkValues()
	--if self.heat > 200 then
	--	self.heat = 200
	--end
	
	--if self.water > 200 then
	--	self.water = 200
	--end

	if self.id == blktype.sand then
		if self.hp <= 0 then
			self.id = 0 --empty
			self.hp = self.maxhp
		else if self.water > 60 then
			self.hp = self.hp - (self.water / 30)
		end end
		
	else if self.id == blktype.stone then
		if self.hp <= 0 then
			self.id = 3 --sand
			self.hp = self.maxhp
		else if self.water > 30 then
			self.hp = self.hp - (self.water / 30)
		
		if self.heat > 80 then
			self.id = 4 --lava
	end end end end end
	
	if self.id == blktype.lava then
		if self.heat < 80 then
			self.id = 2 --stone
		else if self.heat > 120 then
			self.spread = true
		end end
	end
end

function Block:fastShare(v1, v2)
	return self:valueShare(v1, v2, 20, 10)
end

function Block:mediumShare(v1, v2)
	return self:valueShare(v1, v2, 10, 5)
end

function Block:slowShare(v1, v2)
	return self:valueShare(v1, v2, 2, 1)
end

function Block:valueShare(v1, v2, check, spd)
	if v1 > v2 + check then
		v1 = v1 - spd
		v2 = v2 + spd
	else if v2 > v1 + check then
		v2 = v2 - spd
		v1 = v1 + spd
	end end
	return v1, v2
end

function Block:shareValX2(v1, v2)
	v1 = (v1 + v2) / 2
	return v1, v1
end

function Block:shareVal(v1, v2)
	return (v1 + v2) / 2
end

function Block:resetAfterUpdate()
	self.canSpread = false
end


--constants = {
--	x = 1,
--	y = 2,
--}
--constants = protect(constants)