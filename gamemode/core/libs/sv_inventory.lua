if (not lia.inventory) then
	include("sh_inventory.lua")
end

local INV_FIELDS = {"_invID", "_invType", "_charID"}
local INV_TABLE = "inventories"
local DATA_FIELDS = {"_key", "_value"}
local DATA_TABLE = "invdata"
local ITEMS_TABLE = "items"

function lia.inventory.loadByID(id, noCache)
	local instance = lia.inventory.instances[invID]

	-- Do not reload inventories unless necessary.
	if (instance and not noCache) then
		local d = deferred.new()
		d:resolve(instance)

		return d
	end

	-- Allow for custom ways of loading inventories.
	for typeID, invType in pairs(lia.inventory.types) do
		local loadFunction = rawget(invType, "loadFromStorage")
		if (loadFunction) then
			local d = loadFunction(invType, id)
			if (d) then
				return d
			end
		end
	end

	-- If there were no custom loaders and the id is a normal one, load from
	-- the default database table.
	assert(
		isnumber(id) and id >= 0,
		"No inventories implement loadFromStorage for ID "..tostring(id)
	)
	return lia.inventory.loadFromDefaultStorage(id, noCache)
end

function lia.inventory.loadFromDefaultStorage(id, noCache)
	return deferred.all({
		lia.db.select(INV_FIELDS, INV_TABLE, "_invID = "..id, 1),
		lia.db.select(DATA_FIELDS, DATA_TABLE, "_invID = "..id)
	})
	:next(function(res)
		if (lia.inventory.instances[id] and not noCache) then
			return lia.inventory.instances[id]
		end

		local results = res[1].results and res[1].results[1] or nil
		if (not results) then
			return
		end

		local typeID = results._invType
		local invType = lia.inventory.types[typeID]
		if (not invType) then
			ErrorNoHalt("Inventory "..id.." has invalid type "..typeID.."\n")
			return
		end

		local instance = invType:new()
		instance.id = id
		instance.data = {}
		for _, row in ipairs(res[2].results or {}) do
			local decoded = util.JSONToTable(row._value)
			instance.data[row._key] = decoded and decoded[1] or nil
		end

		-- Compatibility of NS1.1 inventory
		instance.data.char = tonumber(results._charID) or instance.data.char

		lia.inventory.instances[id] = instance
		instance:onLoaded()
		return instance:loadItems():next(function() return instance end)
	end, function(err)
		print("Failed to load inventory "..tostring(id))
		print(err)
	end)
end

function lia.inventory.instance(typeID, initialData)
	local invType = lia.inventory.types[typeID]
	assert(
		istable(invType),
		"invalid inventory type "..tostring(typeID)
	)
	assert(
		initialData == nil or istable(initialData),
		"initialData must be a table for lia.inventory.instance"
	)
	initialData = initialData or {}
	return invType:initializeStorage(initialData)
		:next(function(id)
			local instance = invType:new()
			instance.id = id
			instance.data = initialData

			lia.inventory.instances[id] = instance
			instance:onInstanced()
			return instance
		end)
end

function lia.inventory.loadAllFromCharID(charID)
	assert(isnumber(charID), "charID must be a number")
	return lia.db.select({"_invID"}, INV_TABLE, "_charID = "..charID)
		:next(function(res)
			return deferred.map(res.results or {}, function(result)
				return lia.inventory.loadByID(tonumber(result._invID))
			end)
		end)
end

function lia.inventory.deleteByID(id)
	lia.db.delete(DATA_TABLE, "_invID = "..id)
	lia.db.delete(INV_TABLE, "_invID = "..id)
	lia.db.delete(ITEMS_TABLE, "_invID = "..id)
	local instance = lia.inventory.instances[id]
	if (instance) then
		instance:destroy()
	end
end

function lia.inventory.cleanUpForCharacter(character)
	for _, inventory in pairs(character:getInv(true)) do
		inventory:destroy()
	end
end
