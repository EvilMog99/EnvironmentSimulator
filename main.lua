function love.load()
	face = love.graphics.newImage("face.png")
	x, y, w, h = 20, 20, 20, 20
end


function love.update(dt)
	w = w + 1
	h = h + 1
end


function love.draw()
	love.graphics.setColor(0, 0.4, 0.4)
	love.graphics.rectangle("fill", x, y, w, h)

	love.graphics.print("Hello World!", 400, 300)
	
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.draw(face, 0, 300)
end