local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}

netstream.Hook("nVar", function(index, key, value)
	lia.net[index] = lia.net[index] or {}
	lia.net[index][key] = value
end)

netstream.Hook("nDel", function(index)
	lia.net[index] = nil
end)

netstream.Hook("nLcl", function(key, value)
	lia.net[LocalPlayer():EntIndex()] = lia.net[LocalPlayer():EntIndex()] or {}
	lia.net[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("gVar", function(key, value)
	lia.net.globals[key] = value
end)

function getNetVar(key, default)
	local value = lia.net.globals[key]

	return value ~= nil and value or default
end

function entityMeta:getNetVar(key, default)
	local index = self:EntIndex()

	if (lia.net[index] and lia.net[index][key] ~= nil) then
		return lia.net[index][key]
	end

	return default
end

function GetNetVar(key, default)
	local value = lia.net.globals[key]

	return value ~= nil and value or default
end

function entityMeta:GetNetVar(key, default)
	local index = self:EntIndex()

	if (lia.net[index] and lia.net[index][key] ~= nil) then
		return lia.net[index][key]
	end

	return default
end

playerMeta.getLocalVar = entityMeta.getNetVar
playerMeta.GetNetVar = entityMeta.GetNetVar
