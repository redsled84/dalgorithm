local Physics = {}


function Physics:initialize()
	self.bodies = {}
end


-- Takes start-x, start-y, end-x, end-y
function Physics:createLinePolygon(world, sx, sy, ex, ey, size)
	local polygon = {
		body = love.physics.newBody(world, 0, 0, "static"),
		shape = love.physics.newPolygonShape({ sx, sy, ex, ey, 
			sx + size, sy + size, ex + size, ey + size })
	}
	polygon.fixture = love.physics.newFixture(polygon.body, polygon.shape, 1)
	table.insert(self.bodies, polygon)
end


function Physics:createCircle(world, x, y, radius, bounciness)
	bounciness = bounciness or 0.9
	local circle = {
		body = love.physics.newBody(world, x, y, "dynamic"),
		shape = love.physics.newCircleShape(radius)
	}
	circle.fixture = love.physics.newFixture(circle.body, circle.shape, 1):setRestitution(bounciness)
	table.insert(self.bodies, circle)
	return 
end


function Physics:createRectangle(world, x, y, w, h)
	local rect = {
		body = love.physics.newBody(world, 0, 0, "dynamic"),
		shape = love.physics.newRectangleShape(x, y, w, h),
		type = "rectangle",
		width = w,
		height = h,
		x = x,
		y = y
	}
	local fixture = love.physics.newFixture(rect.body, rect.shape, 1.25)
	rect.fixture = fixture
	table.insert(self.bodies, rect)
end

function Physics:removeAllBodies()
	for i=#self.bodies,1,-1 do
		local v = self.bodies[i]
		v.body:destroy()
		table.remove(self.bodies, i)
	end
end


function Physics:removeBodiesOutOfBounds(x1, x2, y)
	for i=#self.bodies,1,-1 do
		local v = self.bodies[i]
		if v.body:getY() > y or
		v.body:getX() < x1 or
		v.body:getX() > x2 and
		v.shape:getType() == 'circle' then
			v.body:destroy()
			table.remove(self.bodies, i)
		end
	end
end


function Physics:updateWorld(dt, world)
	-- if not world:isDestroyed() then
		world:update(dt)

		for _,v in ipairs(self.bodies) do
			local x, y = v.body:getWorldCenter()
			v.x, v.y = x - v.width / 2, y - v.height / 2

			-- print(v.body:isAwake())
		end
	-- end
	-- Physics:removeBodiesOutOfBounds(0, love.graphics.getWidth(), love.graphics.getHeight())
end

function Physics:drawPhysicsBodies(world)
	if not world:isDestroyed() then
		for _,v in ipairs(self.bodies) do
			if v.shape:getType() == 'circle' then
				love.graphics.setColor(0,255,0)
				love.graphics.circle("line", v.body:getX(), v.body:getY(), v.shape:getRadius())
			elseif v.type == "rectangle" then
				love.graphics.setColor(0,0,255)
				love.graphics.polygon("line", v.body:getWorldPoints(v.shape:getPoints()))
				love.graphics.setColor(0,0,255,100)
				love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
			else
				love.graphics.setColor(255,0,0)
				love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
			end
		end
	end
end

return Physics