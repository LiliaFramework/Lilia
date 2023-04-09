function GM:SetupBotCharacter(client)
	local botID = os.time()
	local index = math.random(1, table.Count(lia.faction.indices))
	local faction = lia.faction.indices[index]

	local character = lia.char.new({
		name = client:Name(),
		faction = faction and faction.uniqueID or "unknown",
		model = faction and table.Random(faction.models) or "models/gman.mdl"
	}, botID, client, client:SteamID64())
	character.isBot = true

	character.vars.inv = {}
	hook.Run("SetupBotInventory", client, character)

	lia.char.loaded[botID] = character
	character:setup()
	client:Spawn()
end

function GM:SetupBotInventory(client, character)
	local invType = hook.Run("GetDefaultInventoryType")
	if (not invType) then return end

	local inventory = lia.inventory.new(invType)
	inventory.id = "bot"..character:getID()

	character.vars.inv[1] = inventory
	lia.inventory.instances[inventory.id] = inventory
end

-- When the player first joins, send all important Lilia data.
function GM:PlayerInitialSpawn(client)
	client.liaJoinTime = RealTime()

	if (client:IsBot()) then
		return hook.Run("SetupBotCharacter", client)
	end

	-- Send server related data.
	lia.config.send(client)
	--lia.date.sync(client)

	-- Load and send the Lilia data for the player.
	client:loadLiliaData(function(data)
		if (not IsValid(client)) then return end

		local address = client:IPAddress()
		client:setLiliaData("lastIP", address)

		netstream.Start(
			client,
			"liaDataSync",
			data, client.firstJoin, client.lastJoin
		)

		for _, v in pairs(lia.item.instances) do
			if v.entity and v.invID == 0 then
				v:sync(client)
			end
		end

		hook.Run("PlayerLiliaDataLoaded", client)
	end)

	-- Allow other things to use PlayerInitialSpawn via a hook that runs later.
	hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerUse(client, entity)
	if (client:getNetVar("restricted")) then
		return false
	end

	if (entity:isDoor()) then
		local result = hook.Run("CanPlayerUseDoor", client, entity)

		if (result == false) then
			return false
		else
			result = hook.Run("PlayerUseDoor", client, entity)
			if (result ~= nil) then
				return result
			end
		end
	end

	return true
end

function GM:KeyPress(client, key)
	if (key == IN_USE) then
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local entity = util.TraceLine(data).Entity

		if (IsValid(entity) and entity:isDoor() or entity:IsPlayer()) then
			hook.Run("PlayerUse", client, entity)
		end
	end
end

function GM:KeyRelease(client, key)
	if (key == IN_RELOAD) then
		timer.Remove("liaToggleRaise"..client:SteamID())
	end
end

function GM:CanPlayerDropItem(client, item)
	if (item.isBag) then
		local inventory = item:getInv()

		if (inventory) then
			local items = inventory:getItems()
			for _, item in pairs(items) do

				if (not item.ignoreEquipCheck and item:getData("equip") == true) then
					client:notifyLocalized("cantDropBagHasEquipped")
					return false
				end
			end
		end
	end
end

function GM:CanPlayerInteractItem(client, action, item)
	if (client:getNetVar("restricted")) then
		return false
	end

	if (
		action == "drop" and
		hook.Run("CanPlayerDropItem", client, item) == false
	) then
		return false
	end

	if (
		action == "take" and
		hook.Run("CanPlayerTakeItem", client, item) == false
	) then
		return false
	end

	if (not client:Alive() or client:getLocalVar("ragdoll")) then
		return false
	end
end

function GM:CanPlayerTakeItem(client, item)
	if (IsValid(item.entity)) then
		local char = client:getChar()

		if (
			item.entity.liaSteamID == client:SteamID() and
			item.entity.liaCharID ~= char:getID()
		) then
			client:notifyLocalized("playerCharBelonging")

			return false
		end
	end
end

function GM:PlayerShouldTakeDamage(client, attacker)
	return client:getChar() ~= nil
end

function GM:EntityTakeDamage(entity, dmgInfo)
	if (IsValid(entity.liaPlayer)) then
		if (dmgInfo:IsDamageType(DMG_CRUSH)) then
			if ((entity.liaFallGrace or 0) < CurTime()) then
				if (dmgInfo:GetDamage() <= 10) then
					dmgInfo:SetDamage(0)
				end

				entity.liaFallGrace = CurTime() + 0.5
			else
				return
			end
		end

		entity.liaPlayer:TakeDamageInfo(dmgInfo)
	end
end

function GM:PrePlayerLoadedChar(client, character, lastChar)
	-- Remove all skins
	client:SetBodyGroups("000000000")
	client:SetSkin(0)
end

function GM:PlayerLoadedChar(client, character, lastChar)
	local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
	lia.db.updateTable({_lastJoinTime = timeStamp}, nil, "characters", "_id = "..character:getID())

	if (lastChar) then
		local charEnts = lastChar:getVar("charEnts") or {}

		for _, v in ipairs(charEnts) do
			if (v and IsValid(v)) then
				v:Remove()
			end
		end

		lastChar:setVar("charEnts", nil)
	end

	if (character) then
		for _, v in pairs(lia.class.list) do
			if (v.faction == client:Team()) and v.isDefault then
				character:setClass(v.index)
				break
			end
		end
	end

	if (IsValid(client.liaRagdoll)) then
		client.liaRagdoll.liaNoReset = true
		client.liaRagdoll.liaIgnoreDelete = true
		client.liaRagdoll:Remove()
	end

	hook.Run("CreateSalaryTimer", client)
	hook.Run("PlayerLoadout", client)
end

function GM:CharacterLoaded(id)
	local character = lia.char.loaded[id]

	if (character) then
		local client = character:getPlayer()

		if (IsValid(client)) then
			local uniqueID = "liaSaveChar"..client:SteamID()

			timer.Create(uniqueID, lia.config.get("saveInterval", 300), 0, function()
				if (IsValid(client) and client:getChar()) then
					client:getChar():save()
				else
					timer.Remove(uniqueID)
				end
			end)
		end
	end
end

function GM:PlayerSay(client, message)
	local chatType, message, anonymous = lia.chat.parse(client, message, true)

	if (chatType == "ic") and (lia.command.parse(client, message)) then
		return ""
	end

	lia.chat.send(client, chatType, message, anonymous)
	lia.log.add(client, "chat", chatType and chatType:upper() or "??", message)

	hook.Run("PostPlayerSay", client, message, chatType, anonymous)

	return ""
end

function GM:PlayerSpawn(client)
	client:SetNoDraw(false)
	client:UnLock()
	client:SetNotSolid(false)
	client:setAction()

	hook.Run("PlayerLoadout", client)
end

-- Shortcuts for (super)admin only things.
local IsAdmin = function(_, client) return client:IsAdmin() end

-- Set the gamemode hooks to the appropriate shortcuts.
GM.PlayerGiveSWEP = IsAdmin
GM.PlayerSpawnEffect = IsAdmin
GM.PlayerSpawnSENT = IsAdmin

function GM:PlayerSpawnNPC(client, npcType, weapon)
	return client:IsAdmin() or client:getChar():hasFlags("n")
end

function GM:PlayerSpawnSWEP(client, weapon, info)
	return client:IsAdmin()
end

function GM:PlayerSpawnProp(client)
	if (client:getChar() and client:getChar():hasFlags("e")) then
		return true
	end

	return false
end

function GM:PlayerSpawnRagdoll(client)
	if (client:getChar() and client:getChar():hasFlags("r")) then
		return true
	end

	return false
end

function GM:PlayerSpawnVehicle(client, model, name, data)
	if (client:getChar()) then
		if (data.Category == "Chairs") then
			return client:getChar():hasFlags("c")
		else
			return client:getChar():hasFlags("C")
		end
	end

	return false
end

-- Called when weapons should be given to a player.
function GM:PlayerLoadout(client)
	if (client.liaSkipLoadout) then
		client.liaSkipLoadout = nil

		return
	end

	client:SetWeaponColor(Vector(client:GetInfo("cl_weaponcolor")))
	client:StripWeapons()
	client:setLocalVar("blur", nil)

	local character = client:getChar()

	-- Check if they have loaded a character.
	if (character) then
		client:SetupHands()
		-- Set their player model to the character's model.
		client:SetModel(character:getModel())
		client:Give("lia_hands")
		client:SetWalkSpeed(lia.config.get("walkSpeed", 130))
		client:SetRunSpeed(lia.config.get("runSpeed", 235))

		local faction = lia.faction.indices[client:Team()]

		if (faction) then
			-- If their faction wants to do something when the player spawns, let it.
			if (faction.onSpawn) then
				faction:onSpawn(client)
			end

			-- If the faction has default weapons, give them to the player.
			if (faction.weapons) then
				for _, v in ipairs(faction.weapons) do
					client:Give(v)
				end
			end
		end

		-- Ditto, but for classes.
		local class = lia.class.list[client:getChar():getClass()]

		if (class) then
			if (class.onSpawn) then
				class:onSpawn(client)
			end

			if (class.weapons) then
				for _, v in ipairs(class.weapons) do
					client:Give(v)
				end
			end
		end

		-- Apply any flags as needed.
		lia.flag.onSpawn(client)

		hook.Run("PostPlayerLoadout", client)

		client:SelectWeapon("lia_hands")
	else
		client:SetNoDraw(true)
		client:Lock()
		client:SetNotSolid(true)
	end
end

function GM:PostPlayerLoadout(client)
	-- Reload All Attrib Boosts
	local char = client:getChar()

	if (char:getInv()) then
		for _, item in pairs(char:getInv():getItems()) do
			item:call("onLoadout", client)

			if (item:getData("equip") and istable(item.attribBoosts)) then
				for attribute, boost in pairs(item.attribBoosts) do
					char:addBoost(item.uniqueID, attribute, boost)
				end
			end
		end
	end
end

function GM:PlayerDeath(client, inflictor, attacker)
	if (not client:getChar()) then return end
	if (IsValid(client.liaRagdoll)) then
		client.liaRagdoll.liaIgnoreDelete = true
		client.liaRagdoll:Remove()
		client:setLocalVar("blur", nil)
	end

	client:setNetVar("deathStartTime", CurTime())
	client:setNetVar("deathTime", CurTime() + lia.config.get("spawnTime", 5))
end

function GM:PlayerHurt(client, attacker, health, damage)
	lia.log.add(
		client,
		"playerHurt",
		attacker:IsPlayer() and attacker:Name() or attacker:GetClass(),
		damage,
		health
	)
end

function GM:PlayerDeathThink(client)
	if (client:getChar()) then
		local deathTime = client:getNetVar("deathTime")

		if (deathTime and deathTime <= CurTime()) then
			client:Spawn()
		end
	end

	return false
end

function GM:PlayerDisconnected(client)
	client:saveLiliaData()

	local character = client:getChar()

	if (character) then
		local charEnts = character:getVar("charEnts") or {}

		for _, v in ipairs(charEnts) do
			if (v and IsValid(v)) then
				v:Remove()
			end
		end

		lia.log.add(client, "playerDisconnected")

		hook.Run("OnCharDisconnect", client, character)
		character:save()
	end

	if (IsValid(client.liaRagdoll)) then
		client.liaRagdoll.liaNoReset = true
		client.liaRagdoll.liaIgnoreDelete = true
		client.liaRagdoll:Remove()
	end

	lia.char.cleanUpForPlayer(client)
end

function GM:PlayerAuthed(client, steamID, uniqueID)
	lia.log.add(client, "playerConnected", client, steamID)
end

function GM:InitPostEntity()
	local doors = ents.FindByClass("prop_door_rotating")

	for _, v in ipairs(doors) do
		local parent = v:GetOwner()

		if (IsValid(parent)) then
			v.liaPartner = parent
			parent.liaPartner = v
		else
			for _, v2 in ipairs(doors) do
				if (v2:GetOwner() == v) then
					v2.liaPartner = v
					v.liaPartner = v2

					break
				end
			end
		end
	end

	lia.faction.formatModelData()

	timer.Simple(2, function()
		lia.entityDataLoaded = true
	end)


	lia.db.waitForTablesToLoad()
		:next(function()
			hook.Run("LoadData")
			hook.Run("PostLoadData")
		end)
end

function GM:ShutDown()
	if (hook.Run("ShouldDataBeSaved") == false) then return end

	lia.shuttingDown = true
	lia.config.save()

	hook.Run("SaveData")

	for _, v in ipairs(player.GetAll()) do
		v:saveLiliaData()

		if (v:getChar()) then
			v:getChar():save()
		end
	end
end

function GM:PlayerDeathSound()
	return true
end

function GM:InitializedSchema()
	if (not lia.data.get("date", nil, false, true)) then
		lia.data.set("date", os.time(), false, true)
	end

	--lia.date.start = lia.data.get("date", os.time(), false, true)

	local persistString = GetConVar("sbox_persist"):GetString()
	if (persistString == "" or string.StartWith(persistString, "ns_")) then
		local newValue = "ns_"..SCHEMA.folder
		game.ConsoleCommand("sbox_persist "..newValue.."\n")
	end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
	local allowVoice = lia.config.get("allowVoice")

	if (not allowVoice) then
		return false, false
	end

	if (listener:GetPos():DistToSqr(speaker:GetPos()) > lia.config.squaredVoiceDistance) then
		return false, false
	end

	return true, true
end

function GM:OnPhysgunFreeze(weapon, physObj, entity, client)
	-- Object is already frozen (!?)
	if (not physObj:IsMoveable()) then return false end
	if (entity:GetUnFreezable()) then return false end

	physObj:EnableMotion(false)

	-- With the jeep we need to pause all of its physics objects
	-- to stop it spazzing out and killing the server.
	if (entity:GetClass() == "prop_vehicle_jeep") then
		local objects = entity:GetPhysicsObjectCount()

		for i = 0, objects - 1 do
			entity:GetPhysicsObjectNum(i):EnableMotion(false)
		end
	end

	-- Add it to the player's frozen props
	client:AddFrozenPhysicsObject(entity, physObj)
	client:SendHint("PhysgunUnfreeze", 0.3)
	client:SuppressHint("PhysgunFreeze")

	return true
end

function GM:CanPlayerSuicide(client)
	return false
end

function GM:AllowPlayerPickup(client, entity)
	return false
end

function GM:PreCleanupMap()
	-- Pretend like we're shutting down so stuff gets saved properly.
	lia.shuttingDown = true
	hook.Run("SaveData")
	hook.Run("PersistenceSave")
end

function GM:PostCleanupMap()
	lia.shuttingDown = false
	hook.Run("LoadData")
	hook.Run("PostLoadData")
end

function GM:CharacterPreSave(character)
	local client = character:getPlayer()

	if (not character:getInv()) then
		return
	end
	for _, v in pairs(character:getInv():getItems()) do
		if (v.onSave) then
			v:call("onSave", client)
		end
	end
end

function GM:OnServerLog(client, logType, ...)
	for _, v in pairs(lia.util.getAdmins()) do

		if (hook.Run("CanPlayerSeeLog", v, logType) ~= false) then
			lia.log.send(v, lia.log.getString(client, logType, ...))
		end
	end
end

-- this table is based on mdl's prop keyvalue data. FIX IT WILLOX!
local defaultAngleData = {
	["models/items/car_battery01.mdl"] = Angle(-15, 180, 0),
	["models/props_junk/harpoon002a.mdl"] = Angle(0, 0, 0),
	["models/props_junk/propane_tank001a.mdl"] = Angle(-90, 0, 0),
}

function GM:GetPreferredCarryAngles(entity)
	if (entity.preferedAngle) then
		return entity.preferedAngle
	end

	local class = entity:GetClass()
	if (class == "lia_item") then
		local itemTable = entity:getItemTable()

		if (itemTable) then
			local preferedAngle = itemTable.preferedAngle

			if (preferedAngle) then -- I don't want to return something
				return preferedAngle
			end
		end
	elseif (class == "prop_physics") then
		local model = entity:GetModel():lower()

		return defaultAngleData[model]
	end
end

--- Called when a character loads with no inventory and one should be created.
-- Here is where a new inventory instance can be created and set for a character
-- that loads with no inventory. The default implementation is to create an
-- inventory instance whose type is the result of the GetDefaultInventoryType.
-- If nothing is returned, no default inventory is created.
-- hook. The "char" data is set for the instance to the ID of the character.
-- @param character The character that loaded with no inventory
-- @return A promise that resolves to the new inventory
function GM:CreateDefaultInventory(character)
	local invType = hook.Run("GetDefaultInventoryType", character)
	local charID = character:getID()

	if (lia.inventory.types[invType]) then
		return lia.inventory.instance(invType, {char = charID})
	elseif (invType ~= nil) then
		error("Invalid default inventory type "..tostring(invType))
	end
end

function GM:LiliaTablesLoaded()
	-- Add missing NS1.2 columns for lia_player table.
	local ignore = function() end
	lia.db.query("ALTER TABLE lia_players ADD COLUMN _firstJoin DATETIME")
		:catch(ignore)
	lia.db.query("ALTER TABLE lia_players ADD COLUMN _lastJoin DATETIME")
		:catch(ignore)
	-- Add missing _quantity column for lia_item table.
	lia.db.query("ALTER TABLE lia_items ADD COLUMN _quantity INTEGER")
		:catch(ignore)
end

function GM:PluginShouldLoad(plugin)
	return not lia.plugin.isDisabled(plugin)
end

-- Called to get how often a player should be paid in seconds.
function GM:GetSalaryInterval(client, faction)
	if (isnumber(faction.payTime)) then
		return faction.payTime
	end

	return lia.config.get("salaryInterval", 300)
end

-- Called to create a timer that pays the player's character.
function GM:CreateSalaryTimer(client)
	local character = client:getChar()
	if (not character) then return end

	local faction = lia.faction.indices[character:getFaction()]
	local class = lia.class.list[character:getClass()]

	local pay = hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or nil
	local limit = hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.playLimit) or nil
	if (not pay) then return end

	local timerID = "liaSalary"..client:SteamID()
	local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
	local delay = hook.Run("GetSalaryInterval", client, faction) or 300

	timerFunc(timerID, delay, 0, function()
		if (not IsValid(client) or client:getChar() ~= character) then
			timer.Remove(timerID)
			return
		end
		if limit and character:getMoney() >= limit then
			return
		end
		character:giveMoney(pay)
		client:notifyLocalized("salary", lia.currency.get(pay))
	end)
end

-- Just refer to the SCHEMA's name.
function GM:GetGameDescription()
	if (istable(SCHEMA)) then
		return tostring(SCHEMA.name)
	end
	return self.Name
end
