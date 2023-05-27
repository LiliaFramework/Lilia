util.AddNetworkString("liaPACSync")
util.AddNetworkString("liaPACPartAdd")
util.AddNetworkString("liaPACPartRemove")
util.AddNetworkString("liaPACPartReset")

local playerMeta = FindMetaTable("Entity")

function playerMeta:getParts()
	return self:getNetVar("parts", {})
end

function playerMeta:syncParts()
	net.Start("liaPACSync")
	net.Send(self)
end

function playerMeta:addPart(partID)
	if (self:getParts()[partID]) then return end
	net.Start("liaPACPartAdd")
		net.WriteEntity(self)
		net.WriteString(partID)
	net.Broadcast()

	local parts = self:getParts()
	parts[partID] = true
	self:setNetVar("parts", parts)
end

function playerMeta:removePart(partID)
	net.Start("liaPACPartRemove")
		net.WriteEntity(self)
		net.WriteString(partID)
	net.Broadcast()

	local parts = self:getParts()
	parts[partID] = nil
	self:setNetVar("parts", parts)
end

function playerMeta:resetParts()
	net.Start("liaPACPartReset")
		net.WriteEntity(self)
	net.Broadcast()
	self:setNetVar("parts", {})
end

function PLUGIN:PostPlayerInitialSpawn(client)
	timer.Simple(1, function()
		client:syncParts()
	end)
end

function PLUGIN:PlayerLoadout(client)
	client:resetParts()
end
