local inspect = require 'inspect'
local gamera = require 'gamera'
local cam = gamera.new(0,0,2000,2000)
local tilesize = 32

local function shallowCopy(t)
	local t2 = {}
	for k=1, #t do
		t2[k] = t[k]
	end
	return t2
end
-- things like player, door, enemies, etc...
local Entity = {}
local positions = {}

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
		local tilesize = tilesize
		local width, height = math.random(2, 6)*tilesize, math.random(2, 6)*tilesize
		local x = math.abs(math.random(0, math.floor(love.graphics.getWidth()/tilesize) - width/tilesize)) * tilesize
		local y = math.abs(math.random(0, math.floor(love.graphics.getHeight()/tilesize) - height/tilesize)) * tilesize
		local room = Entity:new({
			x = x,
			y = y,
			width = width,
			height = height,
			color = { 255, 255, 255, 200 },
			doors = {},
			id = k
		})	
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
			if room.id < tempRoom.id then
				break
			else
				f(A, B, room, tempRoom)
			end
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
			self:collisionResolution() -- yay recursion!!
		end
	end)
end

local function setPosition(a1, a2, b1, b2)
	local a, b = 0, 0
	if a1 <= b2 and a2 >= b2 then
		a = a1
		b = b2
	end
	if a1 <= b1 and a2 >= b1 then
		a = a2
		b = b1
	end
	if a2 <= b2 and a1 >= b1 then
		a = a1
		b = a2
	end
	if a1 <= b1 and a2 >= b2 then
		a = b1
		b = b2
	end
	return a, b
end

function Rooms:createDoors()
	self:loopRoomWithAllOtherRooms(function(A, B, room, tempRoom)
		if A.x2 == B.x1 and A.y1 == B.y2 or -- A's top right corner touches B's bottom left corner
			A.x1 == B.x2 and A.y1 == B.y2 or -- A's top left corner touches B's bottom right corner
			A.x1 == B.x2 and A.y2 == B.y1 or -- A's bottom left corner touches B's top right corner
			A.x2 == B.x1 and A.y2 == B.y1 then -- A's bottom right corner touches B's top left corner
				-- empty because I don't want the corners to count as 'touching'
		else
			-- check if the rooms are even touching at all
			if A.x1 - 1 < B.x2 and A.x2 + 1 > B.x1 and A.y1 - 1 < B.y2 and A.y2 + 1 > B.y1 then
				if A.y1 + 1 < B.y2 and A.y2 - 1 > B.y1 then	-- Because the walls are only touching on the y-axis, when spawning doors we will use conditionals with the y positions
					local x, y1, y2 = nil, nil, nil
					-- In the case that only one of A's y-points is touching B, check which of A's point is touching and which of B's point is touching
					-- In the case that both A's y-points are not touching, figure out if the room is bigger or smaller than B
					-- If it's bigger, get both of B's y points
					-- If it's smaller, get both of A's y points
					-- A door will then be randomly spawned within these points

					y1, y2 = setPosition(A.y1, A.y2, B.y1, B.y2)

					if A.x2 > B.x1 - 1 and A.x2 < B.x2 then -- A is touching B's LEFT wall
						-- print(room.id .. ' is touching the LEFT side of ' .. tempRoom.id)
						x = B.x1
					elseif A.x1 < B.x2 + 1 and A.x1 > B.x1 then -- A is touching B's RIGHT wall
						-- print(room.id .. ' is touching the RIGHT side of ' .. tempRoom.id)
						x = B.x2
					end

					local doorY = 0
					if y2 - y1 - tilesize == 0 then
						doorY = y1
					else
						doorY = (math.random(0, (y2-y1-tilesize)/tilesize) * tilesize) + y1
					end
					room.doors[#room.doors+1] = Entity:new({x=x-tilesize/2, y=doorY, width=tilesize, height=tilesize})

					positions[#positions+1] = {x = x, y1 = y1, y2 = y2}
					x, y1, y2 = nil, nil, nil
				end
				if A.x1 + 1 < B.x2 and A.x2 - 1 > B.x1 then
					local y, x1, x2 = nil, nil, nil
					x1, x2 = setPosition(A.x1, A.x2, B.x1, B.x2)

					if A.y2 > B.y1 - 1 and A.y2 < B.y2 then -- A is touching B's TOP wall
						-- print(room.id .. ' is touching the TOP side of ' .. tempRoom.id)
						y = B.y1
					elseif A.y1 < B.y2 + 1 and A.y1 > B.y1 then -- A is touching B's BOTTOM wall
						-- print(room.id .. ' is touching the BOTTOM side of ' .. tempRoom.id)
						y = B.y2
					end

					local doorX = 0
					if x2 - x1 - tilesize == 0 then
						doorX = x1
					else
						doorX = (math.random(0, (x2-x1-tilesize)/tilesize) * tilesize) + x1
					end
					room.doors[#room.doors+1] = Entity:new({x=doorX, y=y-tilesize/2, width=tilesize, height=tilesize})

					positions[#positions+1] = {y = y, x1 = x1, x2 = x2}
					y, x1, x2 = nil, nil, nil
				end
			end
		end
	end)
end


local numOfRooms = 15


function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random();

	Rooms:loadRooms(numOfRooms)

	Rooms:collisionResolution()
	Rooms:createDoors()
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
			if #v.doors > 0 then
				love.graphics.setColor(0,255,0, 100)
				love.graphics.rectangle('fill', v.doors[1].x, v.doors[1].y, v.doors[1].width, v.doors[1].height)
			end
		end

		-- for _, v in ipairs(positions) do
		-- 	if v.x ~= nil then
		-- 		love.graphics.setColor(255,0,0)
		-- 		love.graphics.line(v.x, v.y1, v.x, v.y2)
		-- 	elseif v.y ~= nil then
		-- 		love.graphics.setColor(255,0,0)
		-- 		love.graphics.line(v.x1, v.y, v.x2, v.y)
		-- 	end
		-- end
	end)
end

function love.keypressed(key)
	if key == "r" then
		for i=#Rooms, 1, -1 do
			table.remove(Rooms, i)
		end
		for i=#positions, 1, -1 do
			table.remove(positions, i)
		end

		Rooms:loadRooms(numOfRooms)

		Rooms:collisionResolution()
		Rooms:createDoors()

		print(#positions)
	end
	if key == "escape" then
		love.event.quit()
	end
end