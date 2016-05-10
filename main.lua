local inspect = require 'inspect'
math.randomseed(os.time())
math.random();math.random();math.random();
local function loopTable(t, f)
	for i=1, #t do
		local item = t[i]
		f(item)
	end
end

local Node = {
	nodes = {}, 
	leafs = {},
	cellCounter = 0
}

function Node:new(x, y, w, h)
	local node = {
		x = x,
		y = y,
		w = w,
		h = h,
		children = {}
	}
	table.insert(self.nodes, node)
	return node
end

function Node:split(node)
	self.cellCounter = self.cellCounter + 1
	local p = love.math.random(0, 1)
	if p == 1 then -- vertical 
		node.children = {
			A = Node:new(node.x, node.y, node.w/2, node.h),
			B = Node:new(node.x+node.w/2, node.y, node.w/2, node.h)
		}
	elseif p == 0 then -- h
		node.children = {
			A = Node:new(node.x, node.y, node.w, node.h/2),
			B = Node:new(node.x, node.y+node.h/2, node.w, node.h/2)
		}
	end

	if self.cellCounter < 6 then
		local q = love.math.random(0, 1)
		local prob = love.math.random()
		if q == 1 then
			self:split(node.children.A)
		end
		if q == 0 then
			self:split(node.children.B)
		end
	end
end

function Node:getLeafs()
	loopTable(self.nodes, function(item)
		if item.children.A == nil and item.children.B == nil then 
			table.insert(self.leafs, item)
		end
	end)
end

function Node:drawLeafs()
	for i=1, #self.leafs do
		local leaf = self.leafs[i]
		love.graphics.rectangle('line', leaf.x, leaf.y, leaf.w, leaf.h)
	end
end

function love.load()
	local root = Node:new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	Node:split(root)
	Node:getLeafs()
end

function love.update(dt)
	print(Node.cellCounter)
end

function love.draw()
	Node:drawLeafs()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end