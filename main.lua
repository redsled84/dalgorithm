require 'yaci'

local Node = newclass('Node')
function Node:new(x, y, w, h)
	local node = {x=x, y=y, w=w, h=h}
	table.insert(self.nodes, node)
	return node
end

function Node:split(node)
	local p = math.random(0, 1)
	if p == 1 then -- vertical
		local hNodeA = self:new(node.x, node.y, node.w/2, node.h); hNodeA.super = node
		local hNodeB = self:new(node.x+node.w/2, node.y, node.w/2, node.h); hNodeB.super = node
		node.children = {A = hNodeA, B = hNodeB}
	else -- horizontal
		local vNodeA = self:new(node.x, node.y, node.w, node.h/2); vNodeA.super = node
		local vNodeB = self:new(node.x, node.y+node.h/2, node.w, node.h/2); vNodeB.super = node
		node.children = {A = vNodeA, B = vNodeB}
	end
end

function love.load()
	local root = Node:new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	Node:split(root)
end

function love.draw()
	for i=1, #Node.nodes do
		local node = Node.nodes[i]
		if #node.children > 0 then
			local childA = node.children.A
			local childB = node.children.B
			
		end
	end
end