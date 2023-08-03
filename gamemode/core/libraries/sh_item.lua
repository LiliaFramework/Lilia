
lia.util.include("lilia/gamemode/core/meta/sh_item.lua")

function lia.item.get(identifier)
	return lia.item.base[identifier] or lia.item.list[identifier]
end

function lia.item.load(path, baseID, isBaseItem)
	local uniqueID = path:match("sh_([_%w]+)%.lua")

	if uniqueID then
		uniqueID = (isBaseItem and "base_" or "") .. uniqueID
		lia.item.register(uniqueID, baseID, isBaseItem, path)
	elseif not path:find(".txt") then
		ErrorNoHalt("[Lilia] Item at '" .. path .. "' follows an invalid naming convention!\n")
	end
end

function lia.item.isItem(object)
	return istable(object) and object.isItem == true
end

function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
	assert(isstring(uniqueID), "uniqueID must be a string")
	local baseTable = lia.item.base[baseID] or lia.meta.item

	if baseID then
		assert(baseTable, "Item " .. uniqueID .. " has a non-existent base " .. baseID)
	end

	local targetTable = isBaseItem and lia.item.base or lia.item.list

	if luaGenerated then
		ITEM = setmetatable({
			hooks = table.Copy(baseTable.hooks or {}),
			postHooks = table.Copy(baseTable.postHooks or {}),
			BaseClass = baseTable,
			__tostring = baseTable.__tostring,
		}, {
			__eq = baseTable.__eq,
			__tostring = baseTable.__tostring,
			__index = baseTable
		})

		ITEM.__tostring = baseTable.__tostring
		ITEM.desc = "noDesc"
		ITEM.uniqueID = uniqueID
		ITEM.base = baseID
		ITEM.isBase = isBaseItem
		ITEM.category = ITEM.category or "misc"
		ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or lia.item.defaultfunctions)
	else
		ITEM = targetTable[uniqueID] or setmetatable({
			hooks = table.Copy(baseTable.hooks or {}),
			postHooks = table.Copy(baseTable.postHooks or {}),
			BaseClass = baseTable,
			__tostring = baseTable.__tostring,
		}, {
			__eq = baseTable.__eq,
			__tostring = baseTable.__tostring,
			__index = baseTable
		})

		ITEM.__tostring = baseTable.__tostring
		ITEM.desc = "noDesc"
		ITEM.uniqueID = uniqueID
		ITEM.base = baseID
		ITEM.isBase = isBaseItem
		ITEM.category = ITEM.category or "misc"
		ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or lia.item.defaultfunctions)
	end

	if not luaGenerated and path then
		lia.util.include(path)
	end

	ITEM:onRegistered()
	local itemType = ITEM.uniqueID
	targetTable[itemType] = ITEM
	ITEM = nil

	return targetTable[itemType]
end

function lia.item.loadFromDir(directory)
	local files, folders
	files = file.Find(directory .. "/base/*.lua", "LUA")

	for _, v in ipairs(files) do
		lia.item.load(directory .. "/base/" .. v, nil, true)
	end

	files, folders = file.Find(directory .. "/*", "LUA")

	for _, v in ipairs(folders) do
		if v == "base" then continue end

		for _, v2 in ipairs(file.Find(directory .. "/" .. v .. "/*.lua", "LUA")) do
			lia.item.load(directory .. "/" .. v .. "/" .. v2, "base_" .. v)
		end
	end

	for _, v in ipairs(files) do
		lia.item.load(directory .. "/" .. v)
	end
end

function lia.item.new(uniqueID, id)
	id = id and tonumber(id) or id
	assert(isnumber(id), "non-number ID given to lia.item.new")
	if lia.item.instances[id] and lia.item.instances[id].uniqueID == uniqueID then return lia.item.instances[id] end
	local stockItem = lia.item.list[uniqueID]

	if stockItem then
		local item = setmetatable({
			id = id,
			data = {}
		}, {
			__eq = stockItem.__eq,
			__tostring = stockItem.__tostring,
			__index = stockItem
		})

		lia.item.instances[id] = item

		return item
	else
		error("[Lilia] Attempt to create an unknown item '" .. tostring(uniqueID) .. "'\n")
	end
end

lia.char.registerVar("inv", {
	noNetworking = true,
	noDisplay = true,
	onGet = function(character, index)
		if index and type(index) ~= "number" then return character.vars.inv or {} end

		return character.vars.inv and character.vars.inv[index or 1]
	end,
	onSync = function(character, recipient)
		net.Start("liaCharacterInvList")
		net.WriteUInt(character:getID(), 32)
		net.WriteUInt(#character.vars.inv, 32)

		for i = 1, #character.vars.inv do
			net.WriteType(character.vars.inv[i].id)
		end

		if recipient == nil then
			net.Broadcast()
		else
			net.Send(recipient)
		end
	end
})

lia.util.include("item/sv_item.lua")
lia.util.include("item/sh_item_functions.lua")
lia.util.include("item/sv_networking.lua")
lia.util.include("item/cl_networking.lua")