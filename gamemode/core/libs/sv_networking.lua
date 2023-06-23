local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}

-- Check if there is an attempt to send a function. Can't send those.
local function checkBadType(name, object)

	if isfunction(object) then
		ErrorNoHalt("Net var '"..name.."' contains a bad object type!")

		return true
	elseif istable(object) then
		for k, v in pairs(object) do
			-- Check both the key and the value for tables, and has recursion.
			if (checkBadType(name, k) or checkBadType(name, v)) then
				return true
			end
		end
	end
end

function setNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end
	if (getNetVar(key) == value) then return end

	lia.net.globals[key] = value
	netstream.Start(receiver, "gVar", key, value)
end

function playerMeta:syncVars()
	for entity, data in pairs(lia.net) do
		if (entity == "globals") then
			for k, v in pairs(data) do
				netstream.Start(self, "gVar", k, v)
			end
		elseif (IsValid(entity)) then
			for k, v in pairs(data) do
				netstream.Start(self, "nVar", entity:EntIndex(), k, v)
			end
		end
	end
end

function entityMeta:sendNetVar(key, receiver)
	netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
end

function entityMeta:clearNetVars(receiver)
	lia.net[self] = nil
	netstream.Start(receiver, "nDel", self:EntIndex())
end

function entityMeta:setNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end

	lia.net[self] = lia.net[self] or {}

	if (lia.net[self][key] ~= value) then
		lia.net[self][key] = value
	end

	self:sendNetVar(key, receiver)
end

function entityMeta:getNetVar(key, default)
	if (lia.net[self] and lia.net[self][key] ~= nil) then
		return lia.net[self][key]
	end

	return default
end

function playerMeta:setLocalVar(key, value)
	if (checkBadType(key, value)) then return end

	lia.net[self] = lia.net[self] or {}
	lia.net[self][key] = value

	netstream.Start(self, "nLcl", key, value)
end

playerMeta.getLocalVar = entityMeta.getNetVar

function getNetVar(key, default)
	local value = lia.net.globals[key]

	return value ~= nil and value or default
end

hook.Add("EntityRemoved", "nCleanUp", function(entity)
	entity:clearNetVars()
end)

hook.Add("PlayerInitialSpawn", "nSync", function(client)
	client:syncVars()
end)
