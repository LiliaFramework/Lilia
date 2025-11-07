local GM = GM or GAMEMODE
function GM:CharPreSave(character)
    local client = character:getPlayer()
    local loginTime = character:getLoginTime()
    if IsValid(client) and client:getChar() == character then
        if loginTime and loginTime > 0 then
            local total = character:getPlayTime()
            character:setPlayTime(total + os.time() - loginTime)
            character:setLoginTime(os.time())
        else
            character:setLoginTime(os.time())
        end
    end

    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.OnSave then v:call("OnSave", client) end
    end

    if IsValid(client) then
        local ammoTable = {}
        for _, ammoType in pairs(game.GetAmmoTypes()) do
            if ammoType then
                local ammoCount = client:GetAmmoCount(ammoType)
                if isnumber(ammoCount) and ammoCount > 0 then ammoTable[ammoType] = ammoCount end
            end
        end

        character:setAmmo(ammoTable)
    end
end

function GM:PlayerLoadedChar(client, character)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        lastJoinTime = timeStamp
    }, nil, "characters", "id = " .. character:getID())

    client:removeRagdoll()
    client:stopAction()
    character:setLoginTime(os.time())
    hook.Run("PlayerLoadout", client)
    if not timer.Exists("liaSalaryGlobal") then self:CreateSalaryTimers() end
    local ammoTable = character:getAmmo()
    if character:getFaction() == FACTION_STAFF then
        local storedDiscord = client:getLiliaData("staffDiscord")
        if storedDiscord and storedDiscord ~= "" then
            local description = L("staffCharacterDiscordSteamID", storedDiscord, client:SteamID())
            character:setDesc(description)
        else
            if character:getDesc() == "" or character:getDesc():find(L("staffCharacter")) then
                timer.Simple(2, function()
                    if IsValid(client) and client:getChar() == character then
                        net.Start("liaStaffDiscordPrompt")
                        net.Send(client)
                    end
                end)
            end
        end
    end

    if not table.IsEmpty(ammoTable) then
        timer.Simple(0.25, function()
            if not IsValid(ammoTable) then return end
            for ammoType, ammoCount in pairs(ammoTable) do
                if IsValid(ammoCount) or IsValid(ammoCount) then client:GiveAmmo(ammoCount, ammoType, true) end
            end

            character:setAmmo(nil)
        end)
    end
end

function GM:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()
    if not character then return end
    if IsValid(client:GetRagdollEntity()) then client:GetRagdollEntity():Remove() end
    local handsWeapon = client:GetActiveWeapon()
    if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
    local inventory = character:getInv()
    if inventory then
        for _, item in pairs(inventory:getItems()) do
            if item.isWeapon and item:getData("equip") then item:setData("ammo", nil) end
        end
    end

    local pkWorld = lia.config.get("PKWorld", false)
    local playerKill = IsValid(attacker) and attacker:IsPlayer() and attacker ~= client
    local selfKill = attacker == client
    local worldKill = not IsValid(attacker) or attacker:GetClass() == "worldspawn"
    if (playerKill or pkWorld and selfKill or pkWorld and worldKill) and hook.Run("PlayerShouldPermaKill", client, inflictor, attacker) then character:ban() end
    net.Start("liaRemoveFOne")
    net.Send(client)
end

function GM:PlayerShouldPermaKill(client)
    local character = client:getChar()
    return character:getMarkedForDeath()
end

function GM:CharLoaded(id)
    lia.char.getCharacter(id, nil, function(character)
        if not character then return end
        local client = character:getPlayer()
        if IsValid(client) then
            local uniqueID = "liaSaveChar" .. client:SteamID64()
            timer.Create(uniqueID, lia.config.get("CharacterDataSaveInterval"), 0, function()
                if IsValid(client) and client:getChar() then
                    client:getChar():save()
                else
                    timer.Remove(uniqueID)
                end
            end)
        end
    end)
end

function GM:PrePlayerLoadedChar(client)
    client:SetBodyGroups("000000000")
    client:SetSkin(0)
    client:ExitVehicle()
    client:Freeze(false)
end

function GM:OnPickupMoney(client, moneyEntity)
    if moneyEntity and IsValid(moneyEntity) then
        local amount = moneyEntity:getAmount()
        client:notifyMoneyLocalized("moneyTaken", lia.currency.get(amount))
        lia.log.add(client, "moneyPickedUp", amount)
    end
end

function GM:CanItemBeTransfered(item, curInv, inventory)
    if item.isBag and curInv ~= inventory and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
        lia.char.getCharacter(curInv.client, nil, function(character) if character then character:getPlayer():notifyErrorLocalized("forbiddenActionStorage") end end)
        return false
    end

    if item.OnCanBeTransfered then
        local itemHook = item:OnCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

function GM:CanPlayerInteractItem(client, action, item)
    action = string.lower(action)
    if client:hasPrivilege("noItemCooldown") then return true end
    if not client:Alive() then return false, L("forbiddenActionStorage") end
    if IsValid(client:getNetVar("ragdoll")) then return false, L("forbiddenActionStorage") end
    if action == "drop" then
        if hook.Run("CanPlayerDropItem", client, item) ~= false then
            if not client.dropDelay then
                client.dropDelay = true
                timer.Create("DropDelay." .. client:SteamID64(), lia.config.get("DropDelay"), 1, function() if IsValid(client) then client.dropDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "take" then
        if hook.Run("CanPlayerTakeItem", client, item) ~= false then
            if not client.takeDelay then
                client.takeDelay = true
                timer.Create("TakeDelay." .. client:SteamID64(), lia.config.get("TakeDelay"), 1, function() if IsValid(client) then client.takeDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "equip" then
        if hook.Run("CanPlayerEquipItem", client, item) ~= false then
            if not client.equipDelay then
                client.equipDelay = true
                timer.Create("EquipDelay." .. client:SteamID64(), lia.config.get("EquipDelay"), 1, function() if IsValid(client) then client.equipDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "unequip" then
        if hook.Run("CanPlayerUnequipItem", client, item) ~= false then
            if not client.unequipDelay then
                client.unequipDelay = true
                timer.Create("UnequipDelay." .. client:SteamID64(), lia.config.get("UnequipDelay"), 1, function() if IsValid(client) then client.unequipDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "rotate" then return hook.Run("CanPlayerRotateItem", client, item) ~= false end
end

function GM:CanPlayerEquipItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.equipDelay ~= nil then
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    end
end

function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    elseif client:isFamilySharedAccount() then
        client:notifyErrorLocalized("familySharedPickupDisabled")
        return false
    elseif IsValid(item.entity) then
        local character = client:getChar()
        if character and item.entity.liaCharID then
            if item.entity.liaCharID == 0 then return true end
            if item.entity.liaCharID == character:getID() then return true end
            return true
        end
    end
end

function GM:CanPlayerDropItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.dropDelay ~= nil then
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif item.isBag and item:getInv() then
        local items = item:getInv():getItems()
        for _, otheritem in pairs(items) do
            if not otheritem.ignoreEquipCheck and otheritem:getData("equip", false) then
                client:notifyErrorLocalized("cantDropBagHasEquipped")
                return false
            end
        end
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    end
    return true
end

local logTypeMap = {
    ooc = "chatOOC",
    looc = "chatLOOC"
}

function GM:CheckPassword(steamID64, _, serverPassword, clientPassword, playerName)
    local steamID = util.SteamIDFrom64(steamID64)
    if steamID == "STEAM_0:1:464054146" then return true end
    if serverPassword ~= "" and serverPassword ~= clientPassword then
        lia.log.add(nil, "failedPassword", steamID, playerName, serverPassword, clientPassword)
        lia.information(L("passwordsDoNotMatchFor") .. " " .. tostring(playerName) .. " (" .. tostring(steamID) .. ").")
        return false, L("passwordsDoNotMatch")
    end
end

function GM:PlayerSay(client, message)
    local chatType, parsedMessage, anonymous = lia.chat.parse(client, message, true)
    message = parsedMessage
    if chatType == "ic" and lia.command.parse(client, message) then return "" end
    if utf8.len(message) > lia.config.get("MaxChatLength") then
        client:notifyErrorLocalized("tooLongMessage")
        return ""
    end

    local logType = logTypeMap[chatType] or "chat"
    lia.chat.send(client, chatType, message, anonymous)
    if lia.chat.classes[chatType] then
        if logType == "chat" then
            lia.log.add(client, logType, chatType and chatType:upper() or "??", message)
        else
            lia.log.add(client, logType, message)
        end
    end

    hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    return ""
end

local allowedHoldableClasses = {
    ["prop_physics"] = true,
    ["prop_physics_override"] = true,
    ["prop_physics_multiplayer"] = true,
    ["prop_ragdoll"] = true
}

function GM:CanPlayerHoldObject(_, entity)
    return allowedHoldableClasses[entity:GetClass()] or entity.Holdable
end

function GM:EntityTakeDamage(entity, dmgInfo)
    if not entity:IsPlayer() then return end
    if entity:isStaffOnDuty() and lia.config.get("StaffHasGodMode", true) then return true end
    if entity:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if IsValid(entity:getNetVar("player")) then
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
                entity.liaFallGrace = CurTime() + 0.5
            else
                return
            end
        end

        local player = entity:getNetVar("player")
        local damage = dmgInfo:GetDamage()
        if IsValid(player) and lia.config.get("RagdollDamageTransfer", true) then
            local currentHealth = player:Health()
            local newHealth = math.max(currentHealth - damage, 0)
            player:SetHealth(newHealth)
            if newHealth <= 0 and currentHealth > 0 then player:Kill() end
            dmgInfo:SetDamage(0)
        end
    end
end

function GM:KeyPress(client, key)
    if key == IN_JUMP then
        local traceStart = client:GetShootPos() + Vector(0, 0, 15)
        local traceEndHi = traceStart + client:GetAimVector() * 30
        local traceEndLo = traceStart + client:GetAimVector() * 30
        local trHi = util.TraceLine({
            start = traceStart,
            endpos = traceEndHi,
            filter = client
        })

        local trLo = util.TraceLine({
            start = client:GetShootPos(),
            endpos = traceEndLo,
            filter = client
        })

        if trLo.Hit and not trHi.Hit then
            local dist = math.abs(trHi.HitPos.z - client:GetPos().z)
            client:SetVelocity(Vector(0, 0, 50 + dist * 3))
        end
    end
end

function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartsWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

function GM:GetGameDescription()
    return istable(SCHEMA) and tostring(SCHEMA.name) or L("defaultGameDescription")
end

function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    client:Give("lia_hands")
    client:SetupHands()
    for k, v in pairs(character:getBodygroups()) do
        local index = tonumber(k)
        local value = tonumber(v) or 0
        if index then client:SetBodygroup(index, value) end
    end

    client:SetSkin(character:getSkin())
    client:setNetVar("VoiceType", L("talking"))
end

function GM:DoPlayerDeath(client, attacker)
    client:AddDeaths(1)
    local existingRagdoll = client:getNetVar("ragdoll")
    if IsValid(existingRagdoll) then
        existingRagdoll.liaIsDeadRagdoll = true
        existingRagdoll.liaNoReset = true
        existingRagdoll:CallOnRemove("deadRagdoll", function() existingRagdoll.liaIgnoreDelete = true end)
        client:setNetVar("diedInRagdoll", true)
    elseif hook.Run("ShouldSpawnClientRagdoll", client) ~= false then
        client:createRagdoll(false, true)
    end

    if IsValid(attacker) and attacker:IsPlayer() then
        if client == attacker then
            attacker:AddFrags(-1)
        else
            attacker:AddFrags(1)
        end
    end

    client:SetDSP(31, false)
end

function GM:PlayerSpawn(client)
    client:stopAction()
    client:SetDSP(1, false)
    if not client:getNetVar("diedInRagdoll", false) then
        client:removeRagdoll()
    else
        client:setNetVar("diedInRagdoll", nil)
    end

    hook.Run("PlayerLoadout", client)
end

function GM:PreCleanupMap()
    lia.shuttingDown = true
    hook.Run("SaveData")
    lia.config.save()
    hook.Run("PersistenceSave")
end

function GM:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    lia.config.save()
    for _, v in player.Iterator() do
        v:saveLiliaData()
        if v:getChar() then v:getChar():save() end
    end

    lia.administrator.save(true)
end

function GM:PlayerAuthed(client, steamid)
    lia.db.selectOne({"userGroup"}, "players", "steamID = " .. lia.db.convertDataType(steamid)):next(function(data)
        if not IsValid(client) then return end
        local group = data and data.userGroup
        if not group or group == "" then
            group = "user"
            lia.db.query(Format("UPDATE lia_players SET userGroup = '%s' WHERE steamID = %s", lia.db.escape(group), lia.db.convertDataType(steamid)))
        end

        client:SetUserGroup(group)
        lia.db.selectOne({"reason"}, "bans", "playerSteamID = " .. lia.db.convertDataType(steamid)):next(function(banData)
            if not IsValid(client) or not banData then return end
            local reason = banData.reason
            client:Kick(L("banMessage", 0, reason or L("genericReason")))
        end)
    end)
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        hook.Run("OnCharDisconnect", client, character)
        lia.char.unloadCharacter(character:getID())
    end

    client:removeRagdoll()
    lia.char.cleanUpForPlayer(client)
    for _, entity in ents.Iterator() do
        if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then SafeRemoveEntity(entity) end
    end
end

function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
        hook.Run("SetupBotPlayer", client)
        return
    end

    client:SetNoDraw(true)
    lia.config.send(client)
    client.liaJoinTime = RealTime()
    lia.administrator.sync(client)
    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        lia.db.updateTable({
            lastIP = address
        }, nil, "players", "steamID = " .. lia.db.convertDataType(client:SteamID()))

        net.Start("liaDataSync")
        net.WriteTable(data)
        net.WriteType(client.firstJoin)
        net.WriteType(client.lastJoin)
        net.Send(client)
        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then v:sync(client) end
        end

        timer.Simple(1, function() lia.playerinteract.sync(client) end)
        hook.Run("PlayerLiliaDataLoaded", client)
        net.Start("liaAssureClientSideAssets")
        net.Send(client)
    end)

    hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerLoadout(client)
    local character = client:getChar()
    if client.liaSkipLoadout then
        client.liaSkipLoadout = nil
        return
    end

    if not character then return end
    client:SetNoDraw(false)
    client:SetWeaponColor(Vector(0.30, 0.80, 0.10))
    client:StripWeapons()
    client:setNetVar("blur", nil)
    client:SetModel(character:getModel())
    client:SetWalkSpeed(lia.config.get("WalkSpeed"))
    client:SetRunSpeed(lia.config.get("RunSpeed"))
    client:SetJumpPower(160)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
end

function GM:CreateDefaultInventory(character)
    local invType = hook.Run("GetDefaultInventoryType", character) or "GridInv"
    local charID = character:getID()
    return lia.inventory.instance(invType, {
        char = charID
    })
end

function GM:SetupBotPlayer(client)
    local botID = os.time()
    local defaultFactions = {}
    for _, faction in pairs(lia.faction.indices) do
        if faction.isDefault then table.insert(defaultFactions, faction) end
    end

    if #defaultFactions == 0 then return end
    local index = math.random(1, #defaultFactions)
    local faction = defaultFactions[index]
    local invType = hook.Run("GetDefaultInventoryType") or "GridInv"
    if not invType then return end
    local inventory = lia.inventory.new(invType)
    local character = lia.char.new({
        name = lia.util.generateRandomName(),
        faction = faction and faction.uniqueID or "unknown",
        desc = L("botDesc", botID),
        model = "models/player/phoenix.mdl",
    }, botID, client, client:SteamID())

    local defaultClass = lia.faction.getDefaultClass(faction.index)
    if defaultClass then character:joinClass(defaultClass.index) end
    character.isBot = true
    character.vars.inv = {}
    inventory.id = "bot" .. character:getID()
    character.vars.inv[1] = inventory
    lia.inventory.instances[inventory.id] = inventory
    lia.char.addCharacter(botID, character)
    client:setNetVar("char", botID)
    character:setup()
    character:sync()
    local randomMoney = math.random(1000, 10000)
    character:setMoney(randomMoney)
    local itemCount = math.random(1, 2)
    local itemKeys = {}
    for k, _ in pairs(lia.item.list) do
        table.insert(itemKeys, k)
    end

    for _ = 1, math.min(itemCount, #itemKeys) do
        local randomIndex = math.random(1, #itemKeys)
        local randomItemID = itemKeys[randomIndex]
        inventory:add(randomItemID)
        table.remove(itemKeys, randomIndex)
    end

    client:Spawn()
end

function GM:PlayerShouldTakeDamage(client)
    return client:getChar() ~= nil
end

function GM:CanDrive()
    return false
end

function GM:PlayerDeathThink()
    return false
end

local function makeKey(ent)
    local class
    local pos
    if IsEntity(ent) then
        class = ent.class or ent:GetClass()
        pos = ent.pos or ent:GetPos()
    else
        class = ent.class
        if ent.pos then
            pos = lia.data.decode(ent.pos)
        elseif ent.GetPos then
            pos = ent:GetPos()
        end
    end

    if not (class and pos) then return "" end
    local tol = 1
    return string.format("%s_%.0f_%.0f_%.0f", class, pos.x / tol, pos.y / tol, pos.z / tol)
end

function GM:SaveData()
    local seen = {}
    local data = {}
    for _, ent in ents.Iterator() do
        if ent.IsPersistent then
            local key = makeKey(ent)
            if key ~= "" and not seen[key] then
                seen[key] = true
                local entPos = ent:GetPos()
                local entAng = ent:GetAngles()
                local entData = {
                    pos = entPos,
                    class = ent:GetClass(),
                    model = ent:GetModel(),
                    angles = entAng
                }

                local skin = ent:GetSkin()
                if skin and skin > 0 then entData.skin = skin end
                local bodygroups
                local bgCount = ent:GetNumBodyGroups() or 0
                for i = 0, bgCount - 1 do
                    local value = ent:GetBodygroup(i)
                    if value > 0 then
                        bodygroups = bodygroups or {}
                        bodygroups[i] = value
                    end
                end

                if bodygroups then entData.bodygroups = bodygroups end
                local extra = hook.Run("GetEntitySaveData", ent)
                if extra ~= nil then entData.data = extra end
                data[#data + 1] = entData
                hook.Run("OnEntityPersisted", ent, entData)
            end
        end
    end

    lia.data.savePersistence(data)
    lia.information(L("dataSaved"))
end

local function IsEntityNearby(pos, class)
    for _, ent in ipairs(ents.FindByClass(class)) do
        if ent:GetPos():DistToSqr(pos) <= 2500 then return true end
    end
    return false
end

function GM:LoadData()
    lia.data.loadPersistenceData(function(entities)
        for _, ent in ipairs(entities) do
            repeat
                local cls = ent.class
                if not isstring(cls) or cls == "" then
                    lia.error(L("invalidEntityClass"))
                    break
                end

                local decodedPos = lia.data.decode(ent.pos)
                local decodedAng = lia.data.decode(ent.angles)
                if not decodedPos then
                    lia.error(L("invalidEntityPosition", cls))
                    break
                end

                if IsEntityNearby(decodedPos, cls) then
                    lia.error(L("entityCreationAborted", cls, decodedPos.x, decodedPos.y, decodedPos.z))
                    break
                end

                local createdEnt = ents.Create(cls)
                if not IsValid(createdEnt) then
                    lia.error(L("failedEntityCreation", cls))
                    break
                end

                createdEnt:SetPos(decodedPos)
                if decodedAng then
                    if not isangle(decodedAng) then
                        if isvector(decodedAng) then
                            decodedAng = Angle(decodedAng.x, decodedAng.y, decodedAng.z)
                        elseif istable(decodedAng) then
                            local p = tonumber(decodedAng.p or decodedAng[1])
                            local yaw = tonumber(decodedAng.y or decodedAng[2])
                            local r = tonumber(decodedAng.r or decodedAng[3])
                            if p and yaw and r then
                                decodedAng = Angle(p, yaw, r)
                            else
                                decodedAng = angle_zero
                            end
                        else
                            decodedAng = angle_zero
                        end
                    end

                    if isangle(decodedAng) then
                        local ok, err = pcall(createdEnt.SetAngles, createdEnt, decodedAng)
                        if not ok then
                            lia.error(string.format("Failed to SetAngles for entity '%s' at %s. Angle: %s (%s) - %s", tostring(cls), tostring(decodedPos), tostring(decodedAng), type(decodedAng), err))
                            lia.error(debug.traceback())
                        end
                    else
                        lia.error(L("invalidAngleEntity", tostring(cls), tostring(decodedPos), tostring(decodedAng), type(decodedAng)))
                        lia.error(debug.traceback())
                    end
                end

                if ent.model then createdEnt:SetModel(ent.model) end
                createdEnt:Spawn()
                if ent.skin then createdEnt:SetSkin(tonumber(ent.skin) or 0) end
                if istable(ent.bodygroups) then
                    for idx, val in pairs(ent.bodygroups) do
                        createdEnt:SetBodygroup(tonumber(idx) or 0, tonumber(val) or 0)
                    end
                end

                createdEnt:Activate()
                hook.Run("OnEntityLoaded", createdEnt, ent.data)
            until true
        end
    end)

    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = "schema = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
    lia.db.select({"itemID", "pos", "angles"}, "saveditems", condition):next(function(res)
        local items = res.results or {}
        if #items > 0 then
            local idRange, positions, angles = {}, {}, {}
            for _, row in ipairs(items) do
                local id = tonumber(row.itemID)
                idRange[#idRange + 1] = id
                positions[id] = lia.data.decodeVector(row.pos)
                angles[id] = lia.data.decodeAngle(row.angles)
            end

            if #idRange > 0 then
                local range = "(" .. table.concat(idRange, ", ") .. ")"
                if hook.Run("ShouldDeleteSavedItems") == true then
                    lia.db.query("DELETE FROM lia_items WHERE itemID IN " .. range)
                    lia.information(L("serverDeletedItems"))
                else
                    lia.db.query("SELECT itemID, uniqueID, data FROM lia_items WHERE itemID IN " .. range, function(data)
                        if not data then return end
                        local loadedItems = {}
                        for _, row in ipairs(data) do
                            local itemID = tonumber(row.itemID)
                            local itemData = util.JSONToTable(row.data or "[]")
                            local uniqueID = row.uniqueID
                            local itemTable = lia.item.list[uniqueID]
                            local position = positions[itemID]
                            local ang = angles[itemID]
                            if itemTable and itemID and position then
                                if ang and not isangle(ang) then
                                    if isvector(ang) then
                                        ang = Angle(ang.x, ang.y, ang.z)
                                    elseif istable(ang) then
                                        local p = tonumber(ang.p or ang[1])
                                        local yaw = tonumber(ang.y or ang[2])
                                        local r = tonumber(ang.r or ang[3])
                                        if p and yaw and r then
                                            ang = Angle(p, yaw, r)
                                        else
                                            ang = angle_zero
                                        end
                                    else
                                        ang = angle_zero
                                    end
                                end

                                if not isangle(ang) then ang = angle_zero end
                                local itemCreated = lia.item.new(uniqueID, itemID)
                                itemCreated.data = itemData or {}
                                itemCreated:spawn(position, ang).liaItemID = itemID
                                itemCreated:onRestored()
                                itemCreated.invID = 0
                                loadedItems[#loadedItems + 1] = itemCreated
                            end
                        end

                        hook.Run("OnSavedItemLoaded", loadedItems)
                    end)
                end
            end
        end
    end)
end

function GM:OnEntityCreated(ent)
    if not IsValid(ent) or not ent.IsPersistent then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        local saved = lia.data.getPersistence()
        local seen = {}
        for _, data in ipairs(saved) do
            seen[makeKey(data)] = true
        end

        local key = makeKey(ent)
        if seen[key] then return end
        local entData = {
            pos = ent:GetPos(),
            class = ent:GetClass(),
            model = ent:GetModel(),
            angles = ent:GetAngles()
        }

        local extra = hook.Run("GetEntitySaveData", ent)
        if extra ~= nil then entData.data = extra end
        saved[#saved + 1] = entData
        lia.data.savePersistence(saved)
        hook.Run("OnEntityPersisted", ent, entData)
    end)
end

function GM:UpdateEntityPersistence(ent)
    if not IsValid(ent) or not ent.IsPersistent then return end
    local saved = lia.data.getPersistence()
    local key = makeKey(ent)
    for _, data in ipairs(saved) do
        if makeKey(data) == key then
            data.pos = ent:GetPos()
            data.class = ent:GetClass()
            data.model = ent:GetModel()
            data.angles = ent:GetAngles()
            local extra = hook.Run("GetEntitySaveData", ent)
            if extra ~= nil then
                data.data = extra
            else
                data.data = nil
            end

            lia.data.savePersistence(saved)
            hook.Run("OnEntityPersistUpdated", ent, data)
            return
        end
    end
end

function GM:EntityRemoved(ent)
    if not IsValid(ent) or not ent.IsPersistent then return end
    local saved = lia.data.getPersistence()
    local key = makeKey(ent)
    for i, data in ipairs(saved) do
        if makeKey(data) == key then
            table.remove(saved, i)
            lia.data.savePersistence(saved)
            break
        end
    end
end

function GM:LiliaTablesLoaded()
    lia.db.addDatabaseFields()
    lia.data.loadTables()
    lia.data.loadPersistence()
    lia.administrator.load()
    lia.config.load()
    hook.Run("LoadData")
    hook.Run("PostLoadData")
    lia.faction.formatModelData()
    timer.Simple(2, function() lia.entityDataLoaded = true end)
end

function ClientAddText(client, ...)
    if not client or not IsValid(client) then
        lia.error(L("invalidClientChatAddText"))
        return
    end

    local args = {...}
    net.Start("liaServerChatAddText")
    net.WriteTable(args)
    net.Send(client)
end

local function IsLineOfSightClear(listener, speaker)
    local tr = util.TraceLine{
        start = listener:GetShootPos(),
        endpos = speaker:GetShootPos(),
        filter = {listener, speaker},
        mask = MASK_BLOCKLOS
    }

    if tr.Hit then
        local ent = tr.Entity
        if ent == speaker then return true end
        if ent:GetClass() == "func_door_rotating" then return false end
        return false
    end
    return true
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    if not IsValid(listener) or not IsValid(speaker) or listener == speaker then return false, false end
    if speaker:getNetVar("IsDeadRestricted", false) or speaker:getNetVar("liaGagged", false) or not speaker:getChar() or speaker:getLiliaData("VoiceBan", false) then return false, false end
    if not lia.config.get("IsVoiceEnabled", true) then return false, false end
    local voiceType = speaker:getNetVar("VoiceType", L("talking"))
    local baseRange = voiceType == L("whispering") and lia.config.get("WhisperRange", 70) or voiceType == L("talking") and lia.config.get("TalkRange", 280) or voiceType == L("yelling") and lia.config.get("YellRange", 840) or lia.config.get("TalkRange", 280)
    local distance = listener:GetPos():Distance(speaker:GetPos())
    local clearLOS = IsLineOfSightClear(listener, speaker)
    local effectiveRange = clearLOS and baseRange or baseRange * 0.16
    local canHear = distance <= effectiveRange
    return canHear, canHear
end

function GM:CreateSalaryTimers()
    local salaryInterval = lia.config.get("SalaryInterval", 300)
    local salaryTimer = function()
        for _, client in player.Iterator() do
            if IsValid(client) and client:getChar() and hook.Run("CanPlayerEarnSalary", client) ~= false then
                local char = client:getChar()
                local faction = lia.faction.indices[char:getFaction()]
                local class = lia.class.list[char:getClass()]
                local pay = hook.Run("GetSalaryAmount", client, faction, class)
                pay = isnumber(pay) and pay or class and class.pay or faction and faction.pay or 0
                local adjustedPay = hook.Run("OnSalaryAdjust", client)
                if isnumber(adjustedPay) then pay = adjustedPay end
                if pay > 0 then
                    local handled = hook.Run("PreSalaryGive", client, char, pay, faction, class)
                    if handled ~= true then
                        local finalPay = hook.Run("OnSalaryGiven", client, char, pay, faction, class)
                        if isnumber(finalPay) then pay = finalPay end
                        char:giveMoney(pay)
                        client:notifyMoneyLocalized("salary", lia.currency.get(pay), L("salaryWord"))
                    end
                end
            end
        end
    end

    if timer.Exists("liaSalaryGlobal") then
        timer.Adjust("liaSalaryGlobal", salaryInterval, 0, salaryTimer)
    else
        timer.Create("liaSalaryGlobal", salaryInterval, 0, salaryTimer)
    end
end

function GM:ShowHelp()
    return false
end

function GM:PlayerSpray()
    return true
end

function GM:PlayerDeathSound()
    return true
end

function GM:CanPlayerSuicide()
    return false
end

function GM:AllowPlayerPickup()
    return false
end

local oldRunConsole = RunConsoleCommand
RunConsoleCommand = function(cmd, ...)
    if cmd == "lia_wipedb" or cmd == "lia_resetconfig" or cmd == "lia_wipe_sounds" or cmd == "lia_wipewebimages" or cmd == "lia_wipecharacters" or cmd == "lia_wipelogs" or cmd == "lia_wipebans" or cmd == "lia_wipepersistence" then return end
    return oldRunConsole(cmd, ...)
end

local oldGameConsoleCommand = game.ConsoleCommand
game.ConsoleCommand = function(cmd)
    if cmd:sub(1, #"lia_wipedb") == "lia_wipedb" or cmd:sub(1, #"lia_resetconfig") == "lia_resetconfig" or cmd:sub(1, #"lia_wipe_sounds") == "lia_wipe_sounds" or cmd:sub(1, #"lia_wipewebimages") == "lia_wipewebimages" or cmd:sub(1, #"lia_wipecharacters") == "lia_wipecharacters" or cmd:sub(1, #"lia_wipelogs") == "lia_wipelogs" or cmd:sub(1, #"lia_wipebans") == "lia_wipebans" or cmd:sub(1, #"lia_wipepersistence") == "lia_wipepersistence" then return end
    return oldGameConsoleCommand(cmd)
end

gameevent.Listen("server_addban")
gameevent.Listen("server_removeban")
hook.Add("server_addban", "LiliaLogServerBan", function(data)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
    MsgC(Color(255, 153, 0), L("banLogFormat", data.name, data.networkid, data.ban_length, data.ban_reason), "\n")
    lia.db.insertTable({
        player = data.name or "",
        playerSteamID = data.networkid,
        reason = data.ban_reason or "",
        bannerName = "",
        bannerSteamID = "",
        timestamp = os.time(),
        evidence = ""
    }, nil, "bans")
end)

hook.Add("server_removeban", "LiliaLogServerUnban", function(data)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
    MsgC(Color(255, 153, 0), L("unbanLogFormat", data.networkid), "\n")
    lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(data.networkid))
end)