local inspect = require 'inspect'
local Room = {}

math.randomseed(os.time())
math.random();math.random();math.random()
	

function Room:newObject(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Room:getRandomVars()
	local tilesize = 32
	local width = math.random(4, 12)
	local height = math.random(4, 12)
	local x = math.random(0, math.floor(love.graphics.getWidth()/32) - width) * tilesize
	local y = math.random(0, math.floor(love.graphics.getHeight()/32) - height) * tilesize

	return x, y, width, height, tilesize
end

function Room:createRoom()
	local x, y, width, height, tilesize = self:getRandomVars()
	local room = self:newObject({
		x = x,
		y = y,
		width = width,
		height = height,
		tilesize = tilesize,
		marked = {}
	})

	local ranNum = math.random(1,4)
	if ranNum == 1 then
		room.marked.N = true
	elseif ranNum == 2 then
		room.marked.E = true
	elseif ranNum == 3 then
		room.marked.S = true
	elseif ranNum == 4 then
		room.marked.W = true
	end

	return room
end

function love.load()
	base = Room:createRoom()

	print(inspect(base))
end

function love.update(dt)

end

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", base.x, base.y, base.width*base.tilesize, base.height*base.tilesize)
	love.graphics.setColor(0, 0, 255)
	if base.marked.N then
		love.graphics.rectangle('fill', base.x, base.y, base.width*base.tilesize, base.tilesize)
	elseif base.marked.E then
		love.graphics.rectangle('fill', base.x+(base.width-1)*base.tilesize, base.y, base.tilesize, base.height*base.tilesize)
	elseif base.marked.S then
		love.graphics.rectangle('fill', base.x, base.y+(base.height-1)*base.tilesize, base.width*base.tilesize, base.tilesize)
	elseif base.marked.W then
		love.graphics.rectangle('fill', base.x, base.y, base.tilesize, base.height*base.tilesize)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == 'r' then
		base = Room:createRoom()
	end
end