require("classlib")
require("ObjBlock")
--local player = require("playerobj")



allBlocks = {} --array of Block arrays
allRainValue = 0
rainTrigger = 1
rainOnCycle = false
lavaCount = 0
forceRain = false
forceWinter = 0
volcanoRage = 0
volcanoRageMax = 100

updateIndexNoIndexWld = 1
readIndexNoIndexWld = 2
landPlantNoInWld = {0, 0}
seaPlantNoInWld = {0, 0}

function love.load()
	face = love.graphics.newImage("face.png")
	wldX, wldY = -20, -20
	blkW, blkH = 5, 5
	moveUp, moveDown, moveLeft, moveRight = false, false, false, false
	updateCol = 1 --for setting which column will be updated next
	--windowWidth, windowHeight = love.window.getDimensions()
	volcanoRage = volcanoRageMax -- how frequent volcanoes spawn - starting at 0 makes it nice and slow
	
	updateIndexNoIndexWld = 1
	readIndexNoIndexWld = 2
	landPlantNoInWld = {0, 0}
	seaPlantNoInWld = {0, 0}
	
	dbVal = ""
	
	xLoop_start = 1
	xLoop_end = 170 -- set world width
	xLoop_inc = 1
	yLoop_start = 1
	yLoop_end = 130 -- set world height
	yLoop_inc = 1
	for i=xLoop_start, xLoop_end, xLoop_inc do
		allBlocks[i] = {}
		for j=yLoop_start, yLoop_end, yLoop_inc do
			allBlocks[i][j] = Block:new(2)
			allBlocks[i][j].heat = 10
		end
	end
	
	--buildSea(6, 15, 10, 10)
	--buildSea(22, 15, 15, 12)
	--buildSea(20, 8, 5, 5)
	--buildSea(30, 10, 20, 50)
	--buildSea(20, 30, 50, 20)
	
	--buildSea(100, 10, 50, 30)
	--buildSea(20, 100, 50, 50)
	--buildSea(150, 10, 30, 80)
	--buildSea(20, 150, 100, 30)
	
	buildSea(20, 20, 130, 90)
	
	--buildVolcano(10, 5, 3, 3)
	--buildVolcano(35, 20, 4, 7)
	
	rainTrigger = xLoop_end * yLoop_end * 10
	
	Player:resetId(1)
end


function love.update(dt)
	dbVal = ""
	--update life counting index
	if updateIndexNoIndexWld == 1 then
		updateIndexNoIndexWld = 2
		readIndexNoIndexWld = 1
	else
		updateIndexNoIndexWld = 1
		readIndexNoIndexWld = 2
	end
	landPlantNoInWld[updateIndexNoIndexWld] = 0
	seaPlantNoInWld[updateIndexNoIndexWld] = 0
	
	--update movement
	if moveUp then
		Player:moveY(-1 * (dt + 1))
	else if moveDown then
		Player:moveY(1 * (dt + 1))
	end end
	
	if moveLeft then
		Player:moveX(-1 * (dt + 1))
	else if moveRight then
		Player:moveX(1 * (dt + 1))
	end end
	
	--update all blocks
	updateCol = updateCol + 1
	if updateCol > xLoop_end then
		updateCol = 1
	end
	
	if volcanoRage > 0 then
		dbVal = dbVal .. "Volcano Rage: " .. volcanoRage .. " "
	end
	
	if (love.math.random(1, 100) == 2 and allRainValue > rainTrigger * 1.5) or (rainOnCycle and allRainValue > love.math.random(1, rainTrigger)) then
		rainOnCycle = true
		dbVal = dbVal .. "Raining "
	else
		rainOnCycle = false
	end
	
	forceRain = false
	if lavaCount > ((xLoop_end * yLoop_end) - (xLoop_end * yLoop_end / 1.5)) then
		forceWinter = 100
		dbVal = dbVal .. " + Forced Winter " .. forceWinter .. " "
	elseif forceWinter > 0 then
		forceWinter = forceWinter - 1
		dbVal = dbVal .. " + Forced Winter " .. forceWinter .. " "
	end
	lavaCount = 0
	for updateCol=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			allBlocks[updateCol][j]:defineType(landPlantNoInWld[readIndexNoIndexWld], seaPlantNoInWld[readIndexNoIndexWld])
			
			--count what life exists in this block
			if allBlocks[updateCol][j].landPlantLife > 0 then
				landPlantNoInWld[updateIndexNoIndexWld] = landPlantNoInWld[updateIndexNoIndexWld] + 1
			end
			if allBlocks[updateCol][j].seaPlantLife > 0 then
				seaPlantNoInWld[updateIndexNoIndexWld] = seaPlantNoInWld[updateIndexNoIndexWld] + 1
			end
			
			--run block interaction
			if testBlockExists(updateCol + 1, j) then
				allBlocks[updateCol][j]:interact(allBlocks[updateCol + 1][j])
			end
			if testBlockExists(updateCol - 1, j) then
				allBlocks[updateCol][j]:interact(allBlocks[updateCol - 1][j])
			end
			if testBlockExists(updateCol, j + 1) then
				allBlocks[updateCol][j]:interact(allBlocks[updateCol][j + 1])
			end
			if testBlockExists(updateCol, j -  1) then
				allBlocks[updateCol][j]:interact(allBlocks[updateCol][j - 1])
			end
			
			allBlocks[updateCol][j]:resetAfterUpdate()
			
			if allBlocks[updateCol][j].steam > 10 then
				allRainValue = allRainValue + allBlocks[updateCol][j].steam
				allBlocks[updateCol][j].steam = 0
			end
			
			if rainOnCycle and allRainValue > 1 then
				allBlocks[updateCol][j].water = allBlocks[updateCol][j].water + 0.5
				allRainValue = allRainValue - 0.5
			end
			
			if forceRain then
				allBlocks[updateCol][j].water = allBlocks[updateCol][j].water + 0.5
			end
			if forceWinter > 0 then
				allBlocks[updateCol][j].heat = allBlocks[updateCol][j].heat - 1
			end
			
			if allBlocks[updateCol][j].id == 4 then
				lavaCount = lavaCount + 1
			end
			
			if volcanoRage > 0 and love.math.random(1, 1000 * (volcanoRageMax + 1 - volcanoRage)) == 2 then
				buildVolcano(updateCol, j, love.math.random(1, 40), love.math.random(1, 40))
			elseif allBlocks[updateCol][j].id == 4 and love.math.random(1, 10000) == 2 then
				buildVolcano(updateCol, j, love.math.random(1, 5), love.math.random(1, 5))--support volcanoes
			elseif (allBlocks[updateCol][j].id == 4 and love.math.random(1, 100000000) == 2) 
				or (allBlocks[updateCol][j].id ~= 4 and love.math.random(1, 1000000) == 2) then
				buildVolcano(updateCol, j, love.math.random(1, 30), love.math.random(1, 30))--create volcanoes
			end
		end
	end
	
	if volcanoRage > 0 then
		volcanoRage = volcanoRage - 1
	end
	
end

function testBlockExists(tx, ty)
	if (tx > 0) and (tx <= xLoop_end)
		and (ty > 0) and (ty <= yLoop_end) then
		--dbVal = dbVal .. " Bl: x " .. tx .. " y: " .. ty
		return true
	end
	
	return false
end

function buildVolcano(startX, startY, width, height)
	--build volcano
	for i=startX, startX+width, 1 do
		for j=startY, startY+height, 1 do
			if testBlockExists(i, j) then
				allBlocks[i][j].id = blktype.lava
				allBlocks[i][j].heat = 200
			end
		end
	end
end

--[[function buildVolcanoCircle(startX, startY, width, height)
	--build volcano
	for i=startX, startX+width, 1 do
		for j=startY, startY+height, 1 do
			if testBlockExists(i, j) then
				allBlocks[i][j].id = blktype.lava
				allBlocks[i][j].heat = 200
			end
		end
	end
end]]

function buildSea(startX, startY, width, height)
	--build sea
	for i=startX, startX+width, 1 do
		for j=startY, startY+height, 1 do
			if testBlockExists(i, j) then
				allBlocks[i][j].id = blktype.empty
				allBlocks[i][j].water = 200
			end
		end
	end
end


function love.draw()
	--updateWldPosition()
	
	--love.graphics.setColor(1, 1, 1, 0.5)
	--love.graphics.draw(face, 0, 300)
	
	for i=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			drawBlock(allBlocks[i][j], i * blkW, j * blkH)
		end
	end
	
	drawCharacter(Player)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Weather: " .. dbVal, 100, 0)
	love.graphics.print("Coral:", 100, 11)
	love.graphics.print("" .. seaPlantNoInWld[readIndexNoIndexWld], 140, 11)
	love.graphics.print("Plants:", 100, 22)
	love.graphics.print("" .. landPlantNoInWld[readIndexNoIndexWld], 140, 22)
end

local getMaterialColor = {
		[-1] = function()
			return 0, 0, 0
		end,
		[0] = function()
			return 0, 0, 0
		end,
		[1] = function() --empty
			return 0.1, 0.1, 0.1
		end,
		[2] = function() --stone
			return 0.5, 0.5, 0.5
		end,
		[3] = function() --sand
			return 1, 1, 0
		end,
		[4] = function() --lava
			return 1, 0.2, 0.2
	end
}

function drawCharacter(chr)
	if chr.id == 1 then
		love.graphics.setColor(0, 0.6, 0.8, 0.9)
	else
		love.graphics.setColor(1, 0.2, 0.8, 0.9)
	end
	love.graphics.rectangle("fill", chr.x, chr.y, blkW, blkH)
end

function drawBlock(blk, x, y)
	if blk.id > -1 and blk.id < 5 then
		love.graphics.setColor(getMaterialColor[blk.id]())
		love.graphics.rectangle("fill", x + wldX, y + wldY, blkW, blkH)
		
		love.graphics.setColor(blk.heat / 200, 0, blk.water / 200, 0.5)
		love.graphics.rectangle("fill", x + wldX, y + wldY, blkW, blkH)
		
		if blk.seaPlantLife > 0 then
			love.graphics.setColor(0, 0.7, 0.7, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.seaPlantLife/200 * (blkW / 2), 5)
		end
		if blk.landPlantLife > 0 then
			love.graphics.setColor(0, 1, 0, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.landPlantLife/200 * (blkW / 2), 5)
		end
		if blk.fishLife > 0 then
			love.graphics.setColor(0.8, 0, 0.8, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.fishLife/200 * (blkW / 2), 5)
		end
		
		--love.graphics.setColor(0, 0, 0)
		--love.graphics.rectangle("line", x + wldX, y + wldY, blkW, blkH)
	end

end

function updateWldPosition()

	wldX = (windowWidth / 2)
	wldY = (windowHeight / 2)
end

function updateKey(scancode, b)
	if scancode == 'w' then
		moveUp = b
		return
	end
	if scancode == 's' then
		moveDown = b
		return
	end
	if scancode == 'a' then
		moveLeft = b
		return
	end
	if scancode == 'd' then
		moveRight = b
		return
	end
end

function love.keypressed(key, scancode, isrepeat)
	updateKey(scancode, true)
end

function love.keyreleased(key, scancode, isrepeat)
	updateKey(scancode, false)
end


--player object
Player = {
	id = -1,
	timer = 0, maxTimer = 60,
	cycled = false,
	x = 0, y = 0,
	moveX = function(self, addx)
				self.x = self.x + addx
			end,
			
	moveY = function(self, addy)
			self.y = self.y + addy
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



