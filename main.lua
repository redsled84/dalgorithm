local inspect = require 'inspect'

local function shallowCopy(t)
	local t2 = {}
	for k=1, #t do
		t2[k] = t[k]
	end
	return t2
end
-- things like player, door, enemies, etc...
local Entity = {}

function Entity:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Entity:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Entity:draw(color, type)
	local type = type or 'line'
	local color = color or self.color
	love.graphics.setColor(unpack(color))
	love.graphics.print(self.id, self.x+5,self.y+5)
	love.graphics.rectangle(type, self.x, self.y, self.width, self.height)
end

local Rooms = {}

function Rooms:loadRooms(n)
	for k=1, n do
		local tilesize = 32
		local width, height = math.random(2, 6)*tilesize, math.random(2, 6)*tilesize
		local x = math.abs(math.random(0, math.floor(love.graphics.getWidth()/tilesize) - width/tilesize)) * tilesize
		local y = math.abs(math.random(0, math.floor(love.graphics.getHeight()/tilesize) - height/tilesize)) * tilesize
		local room = Entity:new({x=x, y=y, width=width, height=height, color={255,255,255}, id=k})	
		table.insert(Rooms, room)
	end
end

function Rooms:collisionResolution()
	local temp = shallowCopy(Rooms)
	for k=1, #Rooms do
		-- Remove the room that is being looped through
		table.remove(temp, k)
		local room = Rooms[k]
		local A = {
			x1 = room.x,
			y1 = room.y,
			x2 = room.x+room.width,
			y2 = room.y+room.height
		}
		-- Loop through all rooms except the one that is currently being looped above
		for l=1, #temp do
			local tempRoom = temp[l]
			local B = {
				x1 = tempRoom.x,
				y1 = tempRoom.y,
				x2 = tempRoom.x+tempRoom.width,
				y2 = tempRoom.y+tempRoom.height
			}
			-- Importance: Ability to compare one room's values with the rest of the room's (needed for seperating colliding rooms)
			if A.x1 < B.x2 and A.x2 > B.x1 and A.y1 < B.y2 and A.y2 > B.y1 then
				local xDiff, yDiff = B.x2 - A.x1, B.y2 - A.y1
				if xDiff < yDiff then
					room.x = room.x + xDiff
				else
					room.y = room.y + yDiff
				end
				room.color = {0,0,255}
			end
		end	

		-- Reset temp
		temp = shallowCopy(Rooms)
	end
end

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random();

	Rooms:loadRooms(10)
end

function love.update(dt)
	Rooms:collisionResolution()
end

function love.draw()
	for _, v in ipairs(Rooms) do
		v:draw()
	end
end

function love.keypressed(key)
	if key == "s" then
		print(inspect(Rooms))
	end
	if key == "escape" then
		love.event.quit()
	end
end