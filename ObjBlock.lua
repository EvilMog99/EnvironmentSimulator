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

landPlantMaxHeat = 65
landPlantMinHeat = 10
landPlantMaxWater = 90
landPlantMinWater = 5

seaPlantMaxHeat = 60
seaPlantMinHeat = -1
seaPlantMaxWater = 250
seaPlantMinWater = 10

fishMaxHeat = 100
fishMinHeat = 5
fishMaxWater = 200
fishMinWater = 5


--class define
class "Block"-- : extends(classlib)
{
--vars
	id = -1,
	hp = 100, maxhp = 100,
	timer = 0, maxTimer = 60,
	canSpread = false,
	heat = 0, water = 0, landPlantLife = 0, seaPlantLife = 0, fishLife = 0, steam = 0,
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
	self.landPlantLife = 0
	self.seaPlantLife = 0
	self.fishLife = 0
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
	target.landPlantLife = self.landPlantLife
	target.seaPlantLife = self.seaPlantLife
	target.fishLife = self.fishLife
	target.steam = self.steam
	target.hp = self.hp
	target.maxhp = self.maxhp
end

function Block:defineType()
	if self.id == blktype.lava then
		--self.landPlantLife = 0
		--self.seaPlantLife = 0
		--self.fishLife = 0
		if self.heat > 100 then
			self.canSpread = true
		end
	end
	
	--for land plant life
	if self.landPlantLife > 0 then --if plant life exists at all
		self.landPlantLife = self.landPlantLife + Block:calcPlantSurvival(self.heat, self.water, landPlantMaxHeat, landPlantMinHeat, landPlantMaxWater, landPlantMinWater) --calculate its survival	
		if self.id == 0 or self.id == 4 then
			self.landPlantLife = self.landPlantLife - 2
		end
		
		if self.landPlantLife > 200 then
			self.landPlantLife = 200
		end
	else if self.id ~= 0 and self.id ~= 4 and self.water > landPlantMinWater and self.heat > landPlantMinHeat and love.math.random(1, 1000000) == 2 then
		self.landPlantLife = 1
	end end
	
	--for sea plant life
	if self.seaPlantLife > 0 then --if plant life exists at all
		self.seaPlantLife = self.seaPlantLife + (Block:calcPlantSurvival(self.heat, self.water, seaPlantMaxHeat, seaPlantMinHeat, seaPlantMaxWater, seaPlantMinWater) * 1) --calculate its survival	
		if self.id ~= 0 then
			self.seaPlantLife = self.seaPlantLife - 3
		end
		
		if self.seaPlantLife > 200 then
			self.seaPlantLife = 200
		end
	else if self.id == 0 and self.water > seaPlantMinWater and self.heat > seaPlantMinHeat and love.math.random(1, 1000000) == 2 then
		self.seaPlantLife = 1
	end end
	
	--for fish life
	if self.fishLife > 0 then --if plant life exists at all
		self.fishLife = self.fishLife + Block:calcPlantSurvival(self.heat, self.water, fishMaxHeat, fishMinHeat, fishMaxWater, fishMinWater) --calculate its survival	
		if self.id ~= 0 then
			self.seaPlantLife = self.seaPlantLife - 2
		end
		
		if self.fishLife > 200 then
			self.fishLife = 200
		end
	else if self.id == 0 and self.water > 5 and self.heat > 1 and love.math.random(1, 1000000) == 2 then
		self.fishLife = 1
	end end
end

function Block:calcPlantSurvival(heat, water, htMax, htMin, wtMax, wtMin)
	local wt = 0
	local ht = 0
	
	if heat < htMax and heat > htMin then
		ht = 1
	else
		ht = -2
	end
	
	if water < wtMax and heat > wtMin then
		wt = 1
	else
		wt = -2
	end
	
	return wt + ht
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
	
	--spread land plant life
	if self.landPlantLife > 5 and neighbour.landPlantLife == 0 and neighbour.id ~= 0 and neighbour.id ~= 4 then
		--neighbour.landPlantLife, self.landPlantLife = self:mediumShare(neighbour.landPlantLife, self.landPlantLife)
		neighbour.landPlantLife = 1
	end
	
	--spread sea plant life
	if self.seaPlantLife > 5 and neighbour.seaPlantLife == 0 and neighbour.water > seaPlantMinWater and neighbour.id == 0 then--neighbour.id == 0 then
		neighbour.seaPlantLife = 1
	elseif neighbour.seaPlantLife > 5 and neighbour.water > seaPlantMinWater and neighbour.id == 0 and neighbour.seaPlantLife < 140 then
		if self.seaPlantLife > 100 then
			neighbour.seaPlantLife = neighbour.seaPlantLife + 60
			self.seaPlantLife = self.seaPlantLife - 60
		elseif self.seaPlantLife > 50 then
			neighbour.seaPlantLife = neighbour.seaPlantLife + 40
			self.seaPlantLife = self.seaPlantLife - 40
		end
	end
	
	self:checkValues()
end

function Block:evaporateWater()
	if self.water > 10 and (self.heat > 109 or self.water > 210) then
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