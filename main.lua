require("classlib")
--local player = require("playerobj")

class "Block"-- : extends(classlib)
{
	id = -1,
	timer = 0, maxTimer = 60,
	cycled = false,

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
end

local allBlocks = {} --array of Block arrays

function love.load()
	face = love.graphics.newImage("face.png")
	wldX, wldY, blkW, blkH = 0, 0, 20, 20
	moveUp, moveDown, moveLeft, moveRight = false, false, false, false
	
	dbVal = ""
	
	xLoop_start = 1
	xLoop_end = 20
	xLoop_inc = 1
	yLoop_start = 1
	yLoop_end = 20
	yLoop_inc = 1
	for i=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			allBlocks[i] = Block:new(-1)
		end
	end
end


function love.update(dt)
	--w = w + 1
	--h = h + 1
	if moveUp then
		Player:moveY(-1)
	else if moveDown then
		Player:moveY(1)
	end end
	
	if moveLeft then
		Player:moveX(-1)
	else if moveRight then
		Player:moveX(1)
	end end
	
	Player:resetId(1)
end


function love.draw()
	
	--love.graphics.setColor(1, 1, 1, 0.5)
	--love.graphics.draw(face, 0, 300)
	
	for i=xLoop_start, xLoop_end, xLoop_inc do
		for j=yLoop_start, yLoop_end, yLoop_inc do
			drawBlock(allBlocks[i], i * blkW, j * blkH)
		end
	end
	
	drawCharacter(Player)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Debug: " .. dbVal, 400, 300)
end

function drawCharacter(chr)
	if chr.id == 1 then
		love.graphics.setColor(0, 0.6, 0.1)
	else
		love.graphics.setColor(0.6, 0.1, 0)
	end
	love.graphics.rectangle("fill", chr.x, chr.y, blkW, blkH)
end

function drawBlock(blk, x, y)
	if blk.id == 1 then
		love.graphics.setColor(0, 0.6, 0.1)
	else
		love.graphics.setColor(0.6, 0.1, 0)
	end
	love.graphics.rectangle("fill", x, y, blkW, blkH)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, blkW, blkH)
end

local switch = {
	['w'] = function(b)
		moveUp = b
	end,
	['s'] = function(b)
		moveDown = b
	end,
	['a'] = function(b)
		moveLeft = b
	end,
	['d'] = function(b)
		moveRight = b
	end
}

function love.keypressed(key, scancode, isrepeat)
	switch[scancode](true)
end

function love.keyreleased(key, scancode, isrepeat)
	switch[scancode](false)
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



