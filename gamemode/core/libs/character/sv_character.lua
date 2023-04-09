function lia.char.create(data, callback)
	local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())

	data.money = data.money or lia.config.get("defMoney", 0)

	lia.db.insertTable({
		_name = data.name or "",
		_desc = data.desc or "",
		_model = data.model or "models/error.mdl",
		_schema = SCHEMA and SCHEMA.folder or "lilia",
		_createTime = timeStamp,
		_lastJoinTime = timeStamp,
		_steamID = data.steamID,
		_faction = data.faction or "Unknown",
		_money = data.money,
		_data = data.data
	}, function(_, charID)
		local client
		for k, v in ipairs(player.GetAll()) do
			if (v:SteamID64() == data.steamID) then
				client = v
				break
			end
		end

		local character = lia.char.new(data, charID, client, data.steamID)
		character.vars.inv = {}
		hook.Run("CreateDefaultInventory", character)
			:next(function(inventory)
				character.vars.inv[1] = inventory
				lia.char.loaded[charID] = character
				if (callback) then
					callback(charID)
				end
			end)
	end)
end

function lia.char.restore(client, callback, noCache, id)
	local steamID64 = client:SteamID64()
	local fields = {"_id"}
	for _, var in pairs(lia.char.vars) do
		if (var.field) then
			fields[#fields + 1] = var.field
		end
	end
	fields = table.concat(fields, ", ")

	local condition = "_schema = '"..lia.db.escape(SCHEMA.folder)
		.."' AND _steamID = "..steamID64

	if (id) then
		condition = condition.." AND _id = "..id
	end

	local query = "SELECT "..fields.." FROM lia_characters WHERE "..condition
	lia.db.query(query, function(data)
		local characters = {}
		local results = data or {}
		local done = 0

		if (#results == 0) then
			if (callback) then
				callback(characters)
			end
			return
		end

		for k, v in ipairs(results) do
			local id = tonumber(v._id)

			if (not id) then
				ErrorNoHalt(
					"[Lilia] Attempt to load character '"
					..(data._name or "nil").."' with invalid ID!"
				)
				continue
			end
			local data = {}

			for k2, v2 in pairs(lia.char.vars) do
				if (v2.field and v[v2.field]) then
					local value = tostring(v[v2.field])

					if (isnumber(v2.default)) then
						value = tonumber(value) or v2.default
					elseif (isbool(v2.default)) then
						value = tobool(value)
					elseif (istable(v2.default)) then
						value = util.JSONToTable(value)
					end

					data[k2] = value
				end
			end

			characters[#characters + 1] = id

			local character = lia.char.new(data, id, client)
			hook.Run("CharacterRestored", character)
			character.vars.inv = {}

			lia.inventory.loadAllFromCharID(id)
				-- Try to get a default inventory if one does not exist.
				:next(function(inventories)
					if (#inventories == 0) then
						local promise =
							hook.Run("CreateDefaultInventory", character)
						assert(
							promise ~= nil,
							"No default inventory available"
						)
						return promise:next(function(inventory)
							assert(
								inventory ~= nil,
								"No default inventory available"
							)
							return {inventory}
						end)
					end
					return inventories
				end, function(err)
					print("Failed to load inventories for "..tostring(id))
					print(err)

					if (IsValid(client)) then
						client:ChatPrint(
							"A server error occured while loading your"..
							" inventories. Check server log for details."
						)
					end
				end)
				-- Then, store all the inventories.
				:next(function(inventories)
					character.vars.inv = inventories
					lia.char.loaded[id] = character
					done = done + 1

					if (done == #results and callback) then
						callback(characters)
					end
				end)
		end
	end)
end

function lia.char.cleanUpForPlayer(client)
	for _, charID in pairs(client.liaCharList or {}) do
		local character = lia.char.loaded[charID]
		if (not character) then return end

		netstream.Start(nil, "charDel", character:getID())
		lia.inventory.cleanUpForCharacter(character)
		lia.char.loaded[charID] = nil

		hook.Run("CharacterCleanUp", character)
	end
end

local function removePlayer(client)
	if (client:getChar()) then
		client:KillSilent()
		client:setNetVar("char", nil)
		client:Spawn()
		netstream.Start(client, "charKick", nil, true)
	end
end

function lia.char.delete(id, client)
	assert(isnumber(id), "id must be a number")

	if (IsValid(client)) then
		removePlayer(client)
	else
		for _, client in ipairs(player.GetAll()) do
			if (not table.HasValue(client.liaCharList or {}, id)) then continue end
			table.RemoveByValue(client.liaCharList, id)

			removePlayer(client)
		end
	end

	hook.Run("PreCharacterDelete", id)

	for index, charID in pairs(client.liaCharList) do
		if (charID == id) then
			table.remove(client.liaCharList, index)
			break
		end
	end

	lia.char.loaded[id] = nil
	netstream.Start(nil, "charDel", id)
	lia.db.query("DELETE FROM lia_characters WHERE _id = "..id)
	lia.db.query(
		"SELECT _invID FROM lia_inventories WHERE _charID = "..id,
		function(data)
			if (data) then
				for _, inventory in ipairs(data) do
					lia.inventory.deleteByID(tonumber(inventory._invID))
				end
			end
		end
	)

	hook.Run("OnCharacterDelete", client, id)
end
