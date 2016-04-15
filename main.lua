local inspect = require 'inspect'
local bump = require 'bump'
local bumpWorld = bump.newWorld()

local meter = 64; love.physics.setMeter(meter)
local world = love.physics.newWorld(0, 0 * meter, true)

local tile_size = 32
math.randomseed(os.time())
math.random();math.random();math.random();

local Physics = require 'physics'
local gamera = require 'gamera'
local cam = gamera.new(0-love.graphics.getWidth()*3,0-love.graphics.getHeight()*3,4000,4000)
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
	a1, b1 = a1+tile_size, b1+tile_size
	a2, b2 = a2-tile_size, b2-tile_size
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

local function doorPositions(a, b, w, h)

end

function Rooms:addPositions()
	self:checkAwesomeRooms(function(A, B, room, tempRoom)
		if A.x2 == B.x1 and A.y1 == B.y2 or -- A's top right corner touches B's bottom left corner
			A.x1 == B.x2 and A.y1 == B.y2 or -- A's top left corner touches B's bottom right corner
			A.x1 == B.x2 and A.y2 == B.y1 or -- A's bottom left corner touches B's top right corner
			A.x2 == B.x1 and A.y2 == B.y1 then -- A's bottom right corner touches B's top left corner
				-- empty because I don't want the corners to count as 'touching'
		else
			-- check if the rooms are even touching at all
			if A.x1 - 1 < B.x2 and A.x2 + 1 > B.x1 and A.y1 - 1 < B.y2 and A.y2 + 1 > B.y1 then
				if A.y1 + 1 < B.y2 and A.y2 - 1 > B.y1 then	
					local x, y1, y2 = 0, 0, 0
					y1, y2 = setPosition(A.y1, A.y2, B.y1, B.y2)

					if A.x2 > B.x1 - 1 and A.x2 < B.x2 then -- A is touching B's LEFT wall
						x = B.x1
					elseif A.x1 < B.x2 + 1 and A.x1 > B.x1 then -- A is touching B's RIGHT wall
						x = B.x2
					end

					if math.abs(y2 - y1) > tile_size then
						local doorY = 0
						if y2 - y1 - tile_size == 0 then
							doorY = y1
						else
							doorY = (math.random(0, (y2-y1-tile_size)/tile_size) * tile_size) + y1
						end
						room.doors[#room.doors+1] = {x=x-tile_size, y=doorY, width=tile_size, height=tile_size, connectedTo=tempRoom.id, isSide=true}
					end
				end
				if A.x1 + 1 < B.x2 and A.x2 - 1 > B.x1 then
					local y, x1, x2 = 0, 0, 0
					x1, x2 = setPosition(A.x1, A.x2, B.x1, B.x2)
					if A.y2 > B.y1 - 1 and A.y2 < B.y2 then -- A is touching B's TOP wall
						y = B.y1
					elseif A.y1 < B.y2 + 1 and A.y1 > B.y1 then -- A is touching B's BOTTOM wall
						y = B.y2
					end

					if math.abs(x2 - x1) > tile_size then
						local doorX = 0
						if x2 - x1 - tile_size == 0 then
							doorX = x1
						else
							doorX = (math.random(0, (x2-x1-tile_size)/tile_size) * tile_size) + x1
						end
						room.doors[#room.doors+1] = {x=doorX, y=y-tile_size, width=tile_size, height=tile_size, connectedTo=tempRoom.id, isSide=false}
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
	if i then
		self[i] = {}
	end
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
						if blocks:getBlockIndex(door.x, door.y+tile_size) then
							blocks:removeBlockFromCoors(door.x, door.y+tile_size)
						end
					else
						if blocks:getBlockIndex(door.x+tile_size, door.y) then
							blocks:removeBlockFromCoors(door.x+tile_size, door.y)
						end
					end
					self[k] = {}
				end
			end
		end
	end
end

local Player = {}

function Player:initialize(x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
	self.dx, self.dy = 0, 0
	self.cam = {
					x=0, 
	                y=0, 
	                width=0, 
	                height=0, 
	                offsetX=224, 
	                offsetY=192, 
	                centerX=0, 
	                centerY=0, 
	                speed=100
				}
	bumpWorld:add(self, x , y, w, h)
end

function Player:updateCamera(dt)
	local x = cam.x + self.cam.offsetX - love.graphics.getWidth() / 2
	local y = cam.y + self.cam.offsetY - love.graphics.getHeight() / 2
	local width = love.graphics.getWidth() - self.cam.offsetX*2
	local height = love.graphics.getHeight() - self.cam.offsetY*2
	local offsetX, offsetY = self.cam.offsetX, self.cam.offsetY

	-- self camera logic
	if self.y+self.h > y+height+love.graphics.getHeight()/2 then
		cam.y = self.y - offsetY - height + self.h
	elseif self.y+self.h < y+height/2+offsetY+self.h then
		cam.y = self.y - offsetY
	end

	if self.x+self.w > x+width+love.graphics.getWidth()/2 then
		cam.x = self.x - offsetX - width + self.w
	elseif self.x+self.w < x+width/2+offsetX+self.w then
		cam.x = self.x - offsetX
	end

	self.cam.x = x
	self.cam.y = y 
	self.cam.width = width 
	self.cam.height = height 
end


function Player:move(dx, dy)
	local dt = love.timer.getDelta()
	local lk = love.keyboard
	if lk.isDown("w") or lk.isDown("s") or lk.isDown("d") or lk.isDown("a") then
	if lk.isDown("w") then
		self.dy = self.dy - dy * dt
	end
	if lk.isDown("s") then
		self.dy = self.dy + dy * dt
	end
	if lk.isDown("d") then
		self.dx = self.dx + dx * dt 
	end
	if lk.isDown("a") then
		self.dx = self.dx - dx * dt
	end
	else
		self.dx, self.dy = 0,0
	end
end

function Player:collide()
	local cols
	self.x, self.y, cols = bumpWorld:move(self, self.x + self.dx, self.y + self.dy)
end

function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function love.load()
	Physics:initialize()
	Player:initialize(127, 127, tile_size/2, tile_size/2)

	for i=1, 30 do
		Physics:createRectangle(world, math.random(375,400),math.random(375,400),math.random(7,12)*tile_size,math.random(7,12)*tile_size)
	end

	for i=1, #Physics.bodies do
		local v = Physics.bodies[i]
		v.body:setFixedRotation(true)
	end
end

local function AllAreAsleep()
	local counter = 0
	for i,v in ipairs(Physics.bodies) do
		if not v.body:isAwake() then
			counter = counter + 1
		end
	end

	if counter == #Physics.bodies then
		return true
	end
end

local Blocks = {}

function love.update(dt)
	Physics:updateWorld(dt, world)

	Player:move(10, 10)
	Player:collide(dt)

	if counter == 0 and AllAreAsleep() then
		for i=1, #Physics.bodies do
			local v = Physics.bodies[i]
			table.insert(Rooms, {x = v.x - v.x%tile_size, y = v.y - v.y % tile_size, width = v.width, height = v.height, id=i, doors = {}})
		end
		Physics:removeAllBodies()

		Rooms:addPositions()
		blocks:addBlocks()
		blocks:removeBlocks()

		for i=#blocks, 1, -1 do
			local block = blocks[i]
			if block.x == nil or block.y == nil then
				table.remove(blocks, i)
			else
				bumpWorld:add(block, block.x, block.y, block.width, block.height)
			end
		end
	end

	local isDown = love.keyboard.isDown
	local camX, camY = cam:getPosition()

	if isDown("right") then
		camX = camX + 400 * dt
	end
	if isDown("left") then
		camX = camX - 400 * dt
	end
	if isDown("up") then
		camY = camY - 400 * dt
	end
	if isDown("down") then
		camY = camY + 400 * dt
	end

	cam:setPosition(camX, camY)
end

function love.draw()
	cam:draw(function(l,t,w,h)
		cam:setScale(1, 1)
		Physics:drawPhysicsBodies(world)
		if #Rooms > 0 then
			for _, v in ipairs(Rooms) do
				love.graphics.setColor(255, 165, 0)
				love.graphics.rectangle('fill', v.x, v.y, v.width, v.height)
			end
			for _,v in ipairs(blocks) do
				if v.x then
				love.graphics.setColor(0,255,0,60)
				love.graphics.rectangle('fill', v.x, v.y, v.width, v.height)
				end
			end
			for _,v in ipairs(Rooms) do
				love.graphics.setColor(255,255,255)
				love.graphics.print(tostring(v.x) .. ' ' .. tostring(v.y), v.x, v.y)
				for _, v in ipairs(v.doors) do
					love.graphics.setColor(0,0,255,200)
					love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
				end
			end
		end

		for y=-30,30 do
			for x=-30, 30 do
				local x, y = x*tile_size, y*tile_size
				-- love.graphics.print(x, x, y)
				-- love.graphics.print(y, x, y+10)
			end
		end
		Player:draw()
	end)
end

function love.keypressed(key)
	if key == 'e' then
		local temp = shallowCopy(blocks)
		for j=#blocks, 1, -1 do
			local block = blocks[j]
			table.remove(temp, j)
			for k=#temp, 1, -1 do
				local tempBlock = temp[k]
				if tempBlock.x == block.x and tempBlock.y == block.y then
					print(k, j)
				end
			end
			temp = shallowCopy(blocks)
		end
	end

	if key == 'escape' then
		love.event.quit()
	end
end