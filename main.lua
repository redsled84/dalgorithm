local inspect = require 'inspect'
local Room = {}

function Room:newRoom(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random()
	local width = math.random(4, 12)
	local height = math.random(4, 12)
	local tilesize = 32
	print()
	local x = math.random(0, math.floor(love.graphics.getWidth()/32) - width) * tilesize
	local y = math.random(0, math.floor(love.graphics.getHeight()/32) - height) * tilesize
	base = Room:newRoom({
		x = x,
		y = y,
		width = width,
		height = height,
		tilesize = tilesize,
		marked = {}
	})
	
	ranNum = math.random(1,4)
	if ranNum == 1 then
		base.marked.N = true
	elseif ranNum == 2 then
		base.marked.E = true
	elseif ranNum == 3 then
		base.marked.S = true
	elseif ranNum == 4 then
		base.marked.W = true
	end

	print(inspect(base))
end

function love.update(dt)

end

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", base.x, base.y, base.width*base.tilesize, base.height*base.tilesize)
	love.graphics.setColor(0, 0, 255)
	if base.marked.N then
		
	elseif base.marked.E then
	elseif base.marked.S then

	elseif base.marked.W then

	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end