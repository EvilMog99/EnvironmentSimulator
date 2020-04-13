require("classlib")
require("ObjBlock")
--local player = require("playerobj")



local allBlocks = {} --array of Block arrays

function love.load()
	face = love.graphics.newImage("face.png")
	wldX, wldY = -20, -20
	blkW, blkH = 20, 20
	moveUp, moveDown, moveLeft, moveRight = false, false, false, false
	updateCol = 1 --for setting which column will be updated next
	--windowWidth, windowHeight = love.window.getDimensions()
	
	dbVal = ""
	
	xLoop_start = 1
	xLoop_end = 40
	xLoop_inc = 1
	yLoop_start = 1
	yLoop_end = 30
	yLoop_inc = 1
	for i=xLoop_start, xLoop_end, xLoop_inc do
		allBlocks[i] = {}
		for j=yLoop_start, yLoop_end, yLoop_inc do
			allBlocks[i][j] = Block:new(-1)
		end
	end
	
	Player:resetId(1)
end


function love.update(dt)
	--dbVal = ""
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
	
	for j=yLoop_start, yLoop_end, yLoop_inc do
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
	love.graphics.print("Debug: " .. dbVal, 100, 0)
end

function drawCharacter(chr)
	if chr.id == 1 then
		love.graphics.setColor(0, 0.6, 0.8, 0.9)
	else
		love.graphics.setColor(1, 0.2, 0.8, 0.9)
	end
	love.graphics.rectangle("fill", chr.x, chr.y, blkW, blkH)
end

function drawBlock(blk, x, y)
	if blk.id == 1 then
		love.graphics.setColor(0, 0.6, 0.1)
	else
		love.graphics.setColor(0.6, 0.1, 0)
	end
	love.graphics.rectangle("fill", x + wldX, y + wldY, blkW, blkH)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x + wldX, y + wldY, blkW, blkH)
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



