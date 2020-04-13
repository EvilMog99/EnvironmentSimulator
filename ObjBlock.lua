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
	lava 	= 1,
	water 	= 2,
	stone 	= 3,
	sand	= 4,
		
}

blktype = protect(constants)


--class define
class "Block"-- : extends(classlib)
{
--vars
	id = -1,
	timer = 0, maxTimer = 60,
	cycled = false,
	heat = 0, wet = 0,
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
					cycled = true
				end
			end,
			
	resetId = function (self, newid)
				self.id = newid
			end
}
function Block:__init(newId)
	self.id = newId
	timer = 0
	maxTimer = 0
	cycled = false
end

function Block:copy(target)
	target.id = self.id
	target.timer = self.timer
	target.maxTimer = self.maxTimer
	target.cycled = self.cycled
end

function Block:interact(neighbour)
	--share values
	self.heat, neighbour.heat = self:shareVal(neighbour.heat, self.heat)
	neighbour.id = 1
	
end

function Block:shareVal(v1, v2)
	r = (v1 + v2) / 2
	return r, r
end

function Block:defineType()
	--if heat > 
end


--constants = {
--	x = 1,
--	y = 2,
--}
--constants = protect(constants)