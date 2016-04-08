local inspect = require 'inspect'

local meter = 64; love.physics.setMeter(meter)
local world = love.physics.newWorld(0, 0 * meter, true)

local tile_size = 32
math.randomseed(os.time())
math.random();math.random();math.random();

local Physics = require 'physics'
local gamera = require 'gamera'
local cam = gamera.new(0-love.graphics.getWidth(),0-love.graphics.getHeight(),2000,2000)
local Rooms = {}
local positions = {}
local blocks = {}
local counter = 0

local function shallowCopy(t)
	local t2 = {}
	for k=1, #t do
		t2[k] = t[k]
	end
	return t2
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

function Rooms:checkAwesomeRooms(f)
	local temp = shallowCopy(self)
	for i=1, #self do
		table.remove(temp, i)
		local room = self[i]
		local A = {
			x1 = room.x,
			y1 = room.y,
			x2 = room.x+room.width,
			y2 = room.y+room.height
		}
		for j=1, #temp do
			local tempRoom = temp[j]
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
	counter = counter + 1
end

function Rooms:addPositions()
	self:checkAwesomeRooms(function(A, B, room, tempRoom)
		if A.x2 == B.x1 and A.y1 == B.y2 or -- A's top right corner touches B's bottom left corner
			A.x1 == B.x2 and A.y1 == B.y2 or -- A's top left corner touches B's bottom right corner
			A.x1 == B.x2 and A.y2 == B.y1 or -- A's bottom left corner touches B's top right corner
			A.x2 == B.x1 and A.y2 == B.y1 then -- A's bottom right corner touches B's top left corner
				-- empty because I don't want the corners to count as 'touching'
		else
			if A.x2 == B.x1 and A.y1 == B.y2 or -- A's top right corner touches B's bottom left corner
				A.x1 == B.x2 and A.y1 == B.y2 or -- A's top left corner touches B's bottom right corner
				A.x1 == B.x2 and A.y2 == B.y1 or -- A's bottom left corner touches B's top right corner
				A.x2 == B.x1 and A.y2 == B.y1 then -- A's bottom right corner touches B's top left corner
					-- empty because I don't want to do anything with the corners
					room.isTouching = false
			else
				-- check if the rooms are even touching at all
				if A.x1 - 1 < B.x2 and A.x2 + 1 > B.x1 and A.y1 - 1 < B.y2 and A.y2 + 1 > B.y1 then
					if A.y1 + 1 < B.y2 and A.y2 - 1 > B.y1 then	
						local x, y1, y2 = nil, nil, nil
						y1, y2 = setPosition(A.y1+tile_size, A.y2-tile_size, B.y1+tile_size, B.y2-tile_size)

						print(y1, y2)

						if A.x2 > B.x1 - 1 and A.x2 < B.x2 then -- A is touching B's LEFT wall
							x = B.x1
						elseif A.x1 < B.x2 + 1 and A.x1 > B.x1 then -- A is touching B's RIGHT wall
							x = B.x2
						end

						if y1 > 0 and y2 > 0 and math.abs(y2 - y1) > tile_size then
							local doorY = 0
							if y2 - y1 - tile_size == 0 then
								doorY = y1
							else
								doorY = (math.random(0, (y2-y1-tile_size)/tile_size) * tile_size) + y1
							end
							room.doors[#room.doors+1] = {x=x-tile_size, y=doorY, width=tile_size, height=tile_size, connectedTo=tempRoom.id, isSide=true}
						end
						x, y1, y2 = nil, nil, nil
					end
					if A.x1 + 1 < B.x2 and A.x2 - 1 > B.x1 then
						local y, x1, x2 = nil, nil, nil
						x1, x2 = setPosition(A.x1+tile_size, A.x2-tile_size, B.x1+tile_size, B.x2-tile_size)
						if A.y2 > B.y1 - 1 and A.y2 < B.y2 then -- A is touching B's TOP wall
							y = B.y1
						elseif A.y1 < B.y2 + 1 and A.y1 > B.y1 then -- A is touching B's BOTTOM wall
							y = B.y2
						end

						if x1 > 0 and x2 > 0 and math.abs(x2 - x1) > tile_size then
							local doorX = 0
							if x2 - x1 - tile_size == 0 then
								doorX = x1
							else
								doorX = (math.random(0, (x2-x1-tile_size)/tile_size) * tile_size) + x1
							end
							room.doors[#room.doors+1] = {x=doorX, y=y-tile_size, width=tile_size, height=tile_size, connectedTo=tempRoom.id, isSide=false}
						end
						y, x1, x2 = nil, nil, nil
					end
				end
			end
		end
	end)
end

function blocks:addBlocks()
	for i=1, #Rooms do
		local room = Rooms[i]
			for j=0, room.width/tile_size-1 do
				local x = room.x+j*tile_size
				self[#self+1] = {x = x, y = room.y, width = tile_size, height = tile_size}
				self[#self+1] = {x = x, y = room.y+(room.height/tile_size-1)*tile_size, width = tile_size, height = tile_size}
			end

			for j=1, room.height/tile_size-2 do
				local y = room.y+j*tile_size
				self[#self+1] = {x = room.x, y = y, width = tile_size, height = tile_size}
				self[#self+1] = {x = room.x+(room.width/tile_size-1)*tile_size, y = y, width = tile_size, height = tile_size}
			end

	end
end

function blocks:getBlockIndex(x, y)
	for i=1, #self do
		local v = self[i]
		if v.x == x and v.y == y then
			return i
		end
	end
end

function blocks:removeBlockFromCoors(x, y)
	local i = self:getBlockIndex(x, y)
	self[i] = {}
end

function blocks:removeBlocks()
	local counter = 0
	for k=#self, 1, -1 do
		local block = self[k]
		for i=#Rooms, 1, -1 do
			for j=#Rooms[i].doors, 1, -1 do
				local door = Rooms[i].doors[j]
				if door.x == block.x and door.y == block.y then
					if not door.isSide then
						blocks:removeBlockFromCoors(door.x, door.y+tile_size)
					else
						blocks:removeBlockFromCoors(door.x+tile_size, door.y)
					end
					self[k] = {}
				end
			end
		end
	end
end

function love.load()
	Physics:initialize()

	for i=1, 30 do
		Physics:createRectangle(world, math.random(300,400),math.random(300,400),math.random(6,12)*tile_size,math.random(6,12)*tile_size)
	end

	for i=1, #Physics.bodies do
		local v = Physics.bodies[i]
		v.body:setFixedRotation(true)
	end
end

local function AllAreAsleep()
	local counter = 0
	for i,v in ipairs(Physics.bodies) do
		if v.body:isAwake() then
			counter = counter + 1
		end
	end

	if counter == #Physics.bodies then
		return false
	else
		return true
	end
end

function love.update(dt)
	Physics:updateWorld(dt, world)

	if counter == 0 and AllAreAsleep() then
		for i=1, #Physics.bodies do
			local v = Physics.bodies[i]
			table.insert(Rooms, {x = v.x - v.x%tile_size, y = v.y - v.y % tile_size, width = v.width, height = v.height, id=i, doors = {}})
		end
		Physics:removeAllBodies()

		Rooms:addPositions()
		blocks:addBlocks()
		blocks:removeBlocks()
	end

	local isDown = love.keyboard.isDown
	local camX, camY = cam:getPosition()

	if isDown("right") then
		camX = camX + 200 * dt
	end
	if isDown("left") then
		camX = camX - 200 * dt
	end
	if isDown("up") then
		camY = camY - 200 * dt
	end
	if isDown("down") then
		camY = camY + 200 * dt
	end

	cam:setPosition(camX, camY)
end

function love.draw()
	cam:draw(function(l,t,w,h)
		Physics:drawPhysicsBodies(world)

		if #Rooms > 0 then
			for _,v in ipairs(blocks) do
				if v.x then
				love.graphics.setColor(0,0,255,175)
				love.graphics.rectangle('fill', v.x, v.y, v.width, v.height)
				end
			end
			-- for _, v in ipairs(Rooms) do
			-- 	love.graphics.setColor(255, 165, 0)
			-- 	love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
			-- 	love.graphics.setColor(255,255,255)
			-- 	love.graphics.print(tostring(v.id), v.x, v.y)
			-- 	if #v.doors > 0 then
			-- 		for j=1, #v.doors do
			-- 			love.graphics.setColor(0,255,0, 100)
			-- 			love.graphics.rectangle('line', v.doors[j].x, v.doors[j].y, v.doors[j].width, v.doors[j].height)
			-- 			love.graphics.setColor(255,255,255)
			-- 			love.graphics.print(tostring(v.doors[j].isSide), v.x+25, v.y)
			-- 		end
			-- 	end
			-- end
		end
	end)
end

function love.keypressed(key)
	if key == 'e' then
		
	end

	if key == 'escape' then
		love.event.quit()
	end
end