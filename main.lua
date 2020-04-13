function love.load()
	face = love.graphics.newImage("face.png")
	x, y, w, h = 80, 80, 20, 20
	moveUp, moveDown, moveLeft, moveRight = false, false, false, false
	
	dbVal = ""
end


function love.update(dt)
	--w = w + 1
	--h = h + 1
	if moveUp then
		y = y - 1
	else if moveDown then
		y = y + 1
	end end
	
	if moveLeft then
		x = x - 1
	else if moveRight then
		x = x + 1
	end end
end


function love.draw()
	love.graphics.setColor(0, 0.4, 0.4)
	love.graphics.rectangle("fill", x, y, w, h)
	
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.draw(face, 0, 300)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Debug: " .. dbVal, 400, 300)
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