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
landAntNoInWld = {0, 0}
seaAntNoInWld = {0, 0}
landPlantNoInWld = {0, 0}
seaPlantNoInWld = {0, 0}

seaCreatureType01NoInWld = {0, 0}

unlockedSeaAnt = false
unlockedSeaPlant = false
unlockedLandPlant = false
unlockedLandAnt = false

romingSpeed = 200

testColR = 0

mouse_leftDown = false
mouse_rightDown = false

tempBlk = nil

function love.load()
	face = love.graphics.newImage("face.png")
	wldPosX = 0
	wldPosY = 0
	wldX, wldY = 0, 0
	blkW, blkH = 10, 10
	wldWidth = 200
	wldHeight = 200
	moveUp, moveDown, moveLeft, moveRight = false, false, false, false
	updateCol = 1 --for setting which column will be updated next
	--windowWidth, windowHeight = love.window.getDimensions()
	volcanoRage = volcanoRageMax -- how frequent volcanoes spawn - starting at 0 makes it nice and slow
	
	updateIndexNoIndexWld = 1
	readIndexNoIndexWld = 2
	landAntNoInWld = {0, 0}
	seaAntNoInWld = {0, 0}
	landPlantNoInWld = {0, 0}
	seaPlantNoInWld = {0, 0}
	
	dbVal = ""
	
	xLoop_start = 1
	xLoop_end = xLoop_start + wldWidth --170 -- set world width
	xLoop_inc = 1
	yLoop_start = 1
	yLoop_end = yLoop_start + wldHeight --130 -- set world height
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
	
	buildSea(20, 20, xLoop_end - 20, yLoop_end - 20)
	
	--buildVolcano(10, 5, 3, 3)
	--buildVolcano(35, 20, 4, 7)
	
	rainTrigger = xLoop_end * yLoop_end * 10
	
	Player:resetId(1)
	
	love.window.setFullscreen(true)
	--windowSizeX, windowSizeY = love.window.getDimensions()
	--love.graphics.setMode(0, 0, false, false)
	windowSizeX = love.graphics.getWidth()
	windowSizeY = love.graphics.getHeight()
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then -- left click
		mouse_leftDown = true
	elseif button == 2 then -- right click
		mouse_rightDown = true
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 then -- left click
		mouse_leftDown = false
	elseif button == 2 then -- right click
		mouse_rightDown = false
	end
end

function asWholeNumber(v)
	return v - (v % 1)
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
	landAntNoInWld[updateIndexNoIndexWld] = 0
	seaAntNoInWld[updateIndexNoIndexWld] = 0
	landPlantNoInWld[updateIndexNoIndexWld] = 0
	seaPlantNoInWld[updateIndexNoIndexWld] = 0
	
	--update movement
	if moveUp then
		wldPosY = wldPosY + (romingSpeed * dt) 
		--Player:moveY(-1 * (dt + 1))
	else if moveDown then
		wldPosY = wldPosY - (romingSpeed * dt) 
		--Player:moveY(1 * (dt + 1))
	end end
	
	if moveLeft then
		wldPosX = wldPosX + (romingSpeed * dt) 
		--Player:moveX(-1 * (dt + 1))
	else if moveRight then
		wldPosX = wldPosX - (romingSpeed * dt) 
		--Player:moveX(1 * (dt + 1))
	end end
	
	--update all blocks
	updateCol = updateCol + 1
	if updateCol > xLoop_end then
		updateCol = 1
	end
	
	if love.math.random(1, 1000) == 2 then
		volcanoRage = 50
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
	if lavaCount > ((xLoop_end * yLoop_end) / 8) then
		forceWinter = 100
		dbVal = dbVal .. " Forced Winter " .. forceWinter .. " "
	elseif love.math.random(1, 1000) == 2 then
		forceWinter = 50
		dbVal = dbVal .. " Forced Winter " .. forceWinter .. " "
	elseif forceWinter > 0 then
		forceWinter = forceWinter - 1
		dbVal = dbVal .. " Forced Winter " .. forceWinter .. " "
	end
	
	--process mouse events
	if mouse_leftDown then
		--place block
		tempBlk, success = getBlock(math.floor((love.mouse.getX() - wldPosX) / blkW), math.floor((love.mouse.getY() - wldPosY) / blkH))
		tempBlk.id = 2
		tempBlk.water = 0
		tempBlk.heat = 50
	end
	if mouse_rightDown then
		
	end
	
	--process tiles
	lavaCount = 0
	for updateCol=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			accessWldBlock(updateCol, j):defineType(landAntNoInWld[updateIndexNoIndexWld], seaAntNoInWld[updateIndexNoIndexWld], landPlantNoInWld[readIndexNoIndexWld], seaPlantNoInWld[readIndexNoIndexWld])
			
			--count what life exists in this block
			if accessWldBlock(updateCol, j).landAntLife > 0 then
				landAntNoInWld[updateIndexNoIndexWld] = landAntNoInWld[updateIndexNoIndexWld] + 1
			end
			if accessWldBlock(updateCol, j).seaAntLife > 0 then
				seaAntNoInWld[updateIndexNoIndexWld] = seaAntNoInWld[updateIndexNoIndexWld] + 1
			end
			if accessWldBlock(updateCol, j).landPlantLife > 0 then
				landPlantNoInWld[updateIndexNoIndexWld] = landPlantNoInWld[updateIndexNoIndexWld] + 1
			end
			if accessWldBlock(updateCol, j).seaPlantLife > 0 then
				seaPlantNoInWld[updateIndexNoIndexWld] = seaPlantNoInWld[updateIndexNoIndexWld] + 1
			end
			
			--run block interaction
			--if testBlockExists(updateCol + 1, j) then
				accessWldBlock(updateCol, j):interact(accessWldBlock(updateCol + 1, j))
			--end
			--if testBlockExists(updateCol - 1, j) then
				accessWldBlock(updateCol, j):interact(accessWldBlock(updateCol - 1, j))
			--end
			--if testBlockExists(updateCol, j + 1) then
				accessWldBlock(updateCol, j):interact(accessWldBlock(updateCol, j + 1))
			--end
			--if testBlockExists(updateCol, j -  1) then
				accessWldBlock(updateCol, j):interact(accessWldBlock(updateCol, j - 1))
			--end
			
			accessWldBlock(updateCol, j):resetAfterUpdate()
			
			if accessWldBlock(updateCol, j).steam > 10 then
				allRainValue = allRainValue + accessWldBlock(updateCol, j).steam
				accessWldBlock(updateCol, j).steam = 0
			end
			
			if rainOnCycle and allRainValue > 1 then
				accessWldBlock(updateCol, j).water = accessWldBlock(updateCol, j).water + 0.5
				allRainValue = allRainValue - 0.5
			end
			
			if forceRain then
				accessWldBlock(updateCol, j).water = accessWldBlock(updateCol, j).water + 0.5
			end
			if forceWinter > 0 then
				accessWldBlock(updateCol, j).heat = accessWldBlock(updateCol, j).heat - 1
			end
			
			if accessWldBlock(updateCol, j).id == 4 then
				lavaCount = lavaCount + 1
			end
			
			if volcanoRage > 0 and love.math.random(1, 1000 * (volcanoRageMax + 1 - volcanoRage)) == 2 then
				buildVolcano(updateCol, j, love.math.random(1, 40), love.math.random(1, 40))
			elseif accessWldBlock(updateCol, j).id == 4 and love.math.random(1, 10000) == 2 then
				buildVolcano(updateCol, j, love.math.random(1, 5), love.math.random(1, 5))--support volcanoes
			elseif (accessWldBlock(updateCol, j).id == 4 and love.math.random(1, 100000000) == 2) 
				or (accessWldBlock(updateCol, j).id ~= 4 and love.math.random(1, 1000000) == 2) then
				buildVolcano(updateCol, j, love.math.random(1, 30), love.math.random(1, 30))--create volcanoes
			end
			
			--check for unlocks
			if not unlockedSeaAnt and accessWldBlock(updateCol, j).seaAntLife > 0 then
				unlockedSeaAnt = true
			end
			if not unlockedLandAnt and accessWldBlock(updateCol, j).landAntLife > 0 then
				unlockedLandAnt = true
			end
			if not unlockedSeaPlant and accessWldBlock(updateCol, j).seaPlantLife > 0 then
				unlockedSeaPlant = true
			end
			if not unlockedLandPlant and accessWldBlock(updateCol, j).landPlantLife > 0 then
				unlockedLandPlant = true
			end
		end
	end
	
	if volcanoRage > 0 then
		volcanoRage = volcanoRage - 1
	end
	
end

function accessWldBlock(x, y)
	return allBlocks[getRelevantX(x)][getRelevantY(y)]
end

function getRelevantX(x)
	return ((x - 1) % wldWidth) + 1
end

function getRelevantY(y)
	return ((y - 1) % wldHeight) + 1
end

function getBlock(x, y)
	if testBlockExists(x, y) then
		dbVal = dbVal .. " x: " .. x .. " y: " .. y
		return allBlocks[x][y], true
	end
	return nil, false
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
			accessWldBlock(i, j).id = blktype.lava
			accessWldBlock(i, j).heat = 200
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
			accessWldBlock(i, j).id = blktype.empty
			accessWldBlock(i, j).water = 200
		end
	end
end

tempLocX = 0
tempLocY = 0
function love.draw()
	--updateWldPosition()
	
	--love.graphics.setColor(1, 1, 1, 0.5)
	--love.graphics.draw(face, 0, 300)
	
	for i=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			--tempLocX = (getRelevantX(i) * blkW) + wldPosX
			--tempLocY = (getRelevantY(j) * blkH) + wldPosY
			--if tempLocX > 0 and tempLocX < windowSizeX and tempLocY > 0 and tempLocY < windowSizeY then
			--drawBlock(accessWldBlock(i, j), tempLocX, tempLocY)
			
			tempLocX = getRelevantX(i + math.floor(wldPosX / blkW))
			tempLocY = getRelevantY(j + math.floor(wldPosY / blkH))
			drawBlock(accessWldBlock(i, j), tempLocX * blkW, tempLocY * blkH)
			--[[tempLocX = (i * blkW) + wldPosX
			tempLocY = (j * blkH) + wldPosY
			if tempLocX > 0 and tempLocX < windowSizeX and tempLocY > 0 and tempLocY < windowSizeY then
				drawBlock(accessWldBlock(i, j), tempLocX, tempLocY)
			end]]
		end
	end
	dbVal = dbVal .. " tempLocX: " .. tempLocX
	
	drawCharacter(Player)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Weather: " .. dbVal, 10, 0)
	
	local yPos = 11
	if unlockedSeaAnt then
		drawPopulationToScreen(seaAntNoInWld[readIndexNoIndexWld], yPos, "Plankton")
		yPos = yPos + 11
	end
	if unlockedSeaPlant then
		drawPopulationToScreen(seaPlantNoInWld[readIndexNoIndexWld], yPos, "Coral")
		yPos = yPos + 11
	end
	if unlockedLandPlant then
		drawPopulationToScreen(landPlantNoInWld[readIndexNoIndexWld], yPos, "Plants")
		yPos = yPos + 11
	end
	if unlockedLandAnt then
		drawPopulationToScreen(landAntNoInWld[readIndexNoIndexWld], yPos, "Ants")
		yPos = yPos + 11
	end
end

function drawPopulationToScreen(noInWld, yPos, str)
	if noInWld > 0 then
		love.graphics.setColor(0.7, 0.7, 0.7, 1)
	else
		love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
	end
	love.graphics.print(str .. ":", 10, yPos)
	love.graphics.print("" .. noInWld, 70, yPos)
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
		love.graphics.setColor(testColR, 0.6, 0.8, 0.9)
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
			love.graphics.setColor(0, 0.6, 0.6, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.seaPlantLife/200 * (blkW / 2), 5)
		end
		if blk.landPlantLife > 0 then
			love.graphics.setColor(0, 1, 0, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.landPlantLife/200 * (blkW / 2), 5)
		end
		if blk.seaAntLife > 0 then
			love.graphics.setColor(0.5, 0.9, 0.6, 1)
			drawAnts(x + wldX, y + wldY, blk.seaAntLife)
			--love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.seaAntLife/200 * (blkW / 2), 5)
		end
		if blk.landAntLife > 0 then
			love.graphics.setColor(0.8, 0.4, 0, 1)
			drawAnts(x + wldX, y + wldY, blk.landAntLife)
			--love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.landAntLife/200 * (blkW / 2), 5)
		end

		if blk.fishLife > 0 then
			love.graphics.setColor(0.8, 0, 0.8, 1)
			love.graphics.circle("fill", x + wldX + (blkW / 2), y + wldY + (blkH / 2), blk.fishLife/200 * (blkW / 2), 5)
		end
		
		--love.graphics.setColor(0, 0, 0)
		--love.graphics.rectangle("line", x + wldX, y + wldY, blkW, blkH)
	end

end

function drawAnts(x, y, level)
	if level > 0 then
		love.graphics.rectangle("fill", x + 2, y + 2, 1, 1)
	end
	if level > 20 then
		love.graphics.rectangle("fill", x + 6, y + 1, 1, 1)
	end
	if level > 30 then
		love.graphics.rectangle("fill", x + 4, y, 1, 1)
	end
	if level > 40 then
		love.graphics.rectangle("fill", x + 3, y + 8, 1, 1)
	end
	if level > 50 then
		love.graphics.rectangle("fill", x + 1, y + 4, 1, 1)
	end
	if level > 60 then
		love.graphics.rectangle("fill", x + 8, y + 5, 1, 1)
	end
	if level > 70 then
		love.graphics.rectangle("fill", x + 4, y + 9, 1, 1)
	end
	if level > 80 then
		love.graphics.rectangle("fill", x + 7, y + 9, 1, 1)
	end
	if level > 90 then
		love.graphics.rectangle("fill", x + 1, y + 4, 1, 1)
	end
	
	if level > 100 then
		love.graphics.rectangle("fill", x + 6, y + 3, 1, 1)
	end
	if level > 110 then
		love.graphics.rectangle("fill", x + 5, y + 6, 1, 1)
	end
	if level > 120 then
		love.graphics.rectangle("fill", x + 6, y + 8, 1, 1)
	end
	if level > 130 then
		love.graphics.rectangle("fill", x + 7, y + 4, 1, 1)
	end
	if level > 140 then
		love.graphics.rectangle("fill", x + 7, y + 5, 1, 1)
	end
	if level > 150 then
		love.graphics.rectangle("fill", x + 5, y + 3, 1, 1)
	end
	if level > 160 then
		love.graphics.rectangle("fill", x + 7, y + 2, 1, 1)
	end
	if level > 170 then
		love.graphics.rectangle("fill", x + 8, y + 3, 1, 1)
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



