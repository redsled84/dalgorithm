local inspect = require 'inspect'
local gamera = require 'gamera'
local cam = gamera.new(0,0,2000,2000)

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
	local str = tostring(self.id .. ' ' .. self.x .. ' ' .. self.y .. ' ' .. self.x+self.width .. ' ' .. self.y+self.height)
	love.graphics.print(str, self.x+5,self.y+5)
	love.graphics.rectangle(type, self.x, self.y, self.width, self.height)
end

local Rooms = {}

function Rooms:loadRooms(n)
	for k=1, n do
		local tilesize = 32
		local width, height = math.random(2, 6)*tilesize, math.random(2, 6)*tilesize
		local x = math.abs(math.random(0, math.floor(love.graphics.getWidth()/tilesize) - width/tilesize)) * tilesize
		local y = math.abs(math.random(0, math.floor(love.graphics.getHeight()/tilesize) - height/tilesize)) * tilesize
		local room = Entity:new({x=x, y=y, width=width, height=height, color={255,255,255, 200}, id=k})	
		table.insert(Rooms, room)
	end
end

function Rooms:loopRoomWithAllOtherRooms(f)
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

			f(A, B, room, tempRoom)
		end

		temp = shallowCopy(Rooms)
	end
end

function Rooms:collisionResolution()
	self:loopRoomWithAllOtherRooms(function(A, B, room)
		if A.x1 < B.x2 and A.x2 > B.x1 and A.y1 < B.y2 and A.y2 > B.y1 then
			local xDiff, yDiff = B.x2 - A.x1, B.y2 - A.y1
			if xDiff < yDiff then
				room.x = room.x + xDiff
			else
				room.y = room.y + yDiff
			end
			room.color = {0,0,255, 200}
			self:collisionResolution()
		end
	end)
end

function Rooms:checkSurroundingRooms()
	self:loopRoomWithAllOtherRooms(function(A, B, room, tempRoom)
		if A.x2 == B.x1 and A.y1 == B.y2 or -- A's top right corner touches B's bottom left corner
			A.x1 == B.x2 and A.y1 == B.y2 or -- A's top left corner touches B's bottom right corner
			A.x1 == B.x2 and A.y2 == B.y1 or -- A's bottom left corner touches B's top right corner
			A.x2 == B.x1 and A.y2 == B.y1 then -- A's bottom right corner touches B's top left corner
				-- empty because I don't want to do anything with the corners
		else
			-- check if the rooms are even touching at all
			if A.x1 - 1 < B.x2 and A.x2 + 1 > B.x1 and A.y1 - 1 < B.y2 and A.y2 + 1 > B.y1 then
				if A.y1 + 1 < B.y2 and A.y2 - 1 > B.y1 then	
					if A.x2 > B.x1 - 1 and A.x2 < B.x2 then -- A is touching B's LEFT wall
						print(room.id .. ' is touching the LEFT side of ' .. tempRoom.id)
					elseif A.x1 < B.x2 + 1 and A.x1 > B.x1 then -- A is touching B's RIGHT wall
						print(room.id .. ' is touching the RIGHT side of ' .. tempRoom.id)
					end
				end
				if A.x1 + 1 < B.x2 and A.x2 - 1 > B.x1 then
					if A.y2 > B.y1 - 1 and A.y2 < B.y2 then -- A is touching B's TOP wall
						print(room.id .. ' is touching the TOP side of ' .. tempRoom.id)
					elseif A.y1 < B.y2 + 1 and A.y1 > B.y1 then -- A is touching B's BOTTOM wall
						print(room.id .. ' is touching the BOTTOM side of ' .. tempRoom.id)
					end
				end
			end
		end
	end)
	print()
end

local numOfRooms = 9

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random();

	Rooms:loadRooms(numOfRooms)

	Rooms:collisionResolution()
	Rooms:checkSurroundingRooms()
end

function love.update(dt)
	local isDown = love.keyboard.isDown
	local camX, camY = cam:getPosition()

	if isDown("d") then
		camX = camX + 100 * dt
	end
	if isDown("a") then
		camX = camX - 100 * dt
	end
	if isDown("w") then
		camY = camY - 100 * dt
	end
	if isDown("s") then
		camY = camY + 100 * dt
	end

	cam:setPosition(camX, camY)
end

function love.draw()
	cam:draw(function(l,t,w,h)
		for _, v in ipairs(Rooms) do
			v:draw()
		end
	end)
end

function love.keypressed(key)
	if key == "r" then
		for i=#Rooms, 1, -1 do
			table.remove(Rooms, i)
		end

		Rooms:loadRooms(numOfRooms)

		Rooms:collisionResolution()
		Rooms:checkSurroundingRooms()
	end
	if key == "escape" then
		love.event.quit()
	end
end