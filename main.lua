local inspect = require 'inspect'
local class = require 'middleclass'

local Object = class('Object')

function Object:initialize(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end


local Room = class('Room', Object)

math.randomseed(os.time())
math.random();math.random();math.random()
local tilesize = 32

function Room:getRandomVars()
	local tilesize = tilesize
	local width = math.random(4, 12)
	local height = math.random(4, 12)
	local x = math.random(0, math.floor(love.graphics.getWidth()/tilesize) - width) * tilesize
	local y = math.random(0, math.floor(love.graphics.getHeight()/tilesize) - height) * tilesize

	return x, y, width, height, tilesize
end

function Room:createRoom()
	local x, y, width, height, tilesize = self:getRandomVars()
	local room = self:initialize({
		x = x,
		y = y,
		width = width,
		height = height,
		tilesize = tilesize,
		marked = {
			N = false,
			E = false,
			S = false,
			W = false
		},
		doors = {}
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

local Door = class('Door', Object)

-- the way this function is designed will only allow one door to be added
function Door:spawnDoor(room)
	local ranOnX = math.random(2,room.width-1)
	local ranOnY = math.random(2,room.height-1)

	local door = self:initialize({
		x = nil,
		y = nil,
		width = room.tilesize,
		height = room.tilesize
	})

	if room.marked.N then
		door.x = room.x + ranOnX * room.tilesize
		door.y = room.y
	elseif room.marked.S then
		door.x = room.x + ranOnX * room.tilesize
		door.y = room.y + (room.height-1) * room.tilesize
	elseif room.marked.E then
		door.x = room.x + (room.width-1) * room.tilesize
		door.y = room.y + ranOnY * room.tilesize
	elseif room.marked.W then
		door.x = room.x
		door.y = room.y + ranOnY * room.tilesize
	end

	return door
end

function Door:checkSpawn(roomt)
	for i,v in ipairs(roomt) do
		if v.marked.N then

		elseif v.marked.S then

		elseif v.marked.E then

		elseif v.marked.W then

		end
	end
end

local Corridor = class('Corridor', Object)




function love.load()
	base = Room:createRoom()
	door = Door:spawnDoor(base)
	base.doors[#base.doors+1] = door
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
	love.graphics.setColor(0,255,0)
	love.graphics.rectangle('fill', door.x, door.y, door.width, door.height)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == 'r' then
		base = Room:createRoom()
		door = Door:spawnDoor(base)
		base.doors[#base.doors+1] = door
	end
end