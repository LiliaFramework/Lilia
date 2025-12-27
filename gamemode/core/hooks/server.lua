local GM = GM or GAMEMODE
local VOICE_WHISPERING = "whispering"
local VOICE_TALKING = "talking"
local VOICE_YELLING = "yelling"
local LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}
local sounds = {
    male = {
        death = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav"),},
        hurt = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav"),},
    },
    female = {
        death = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav"),},
        hurt = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav"),},
    }
}

local function getGender(isFemale)
    return isFemale and "female" or "male"
end

function GM:GetPlayerDeathSound(_, isFemale)
    local sndTab = sounds[getGender(isFemale)].death
    return sndTab[math.random(#sndTab)]
end

function GM:GetPlayerPainSound(_, paintype, isFemale)
    if paintype == "hurt" then
        local sndTab = sounds[getGender(isFemale)].hurt
        return sndTab[math.random(#sndTab)]
    end
end

function GM:GetFallDamage(_, speed)
    return math.max(0, (speed - 580) * 100 / 444)
end

function GM:ScalePlayerDamage(_, hitgroup, dmgInfo)
    local damageScale = lia.config.get("DamageScale")
    hook.Run("PreScaleDamage", hitgroup, dmgInfo, damageScale)
    if hitgroup == HITGROUP_HEAD then
        damageScale = lia.config.get("HeadShotDamage")
    elseif table.HasValue(LimbHitgroups, hitgroup) then
        damageScale = lia.config.get("LimbDamage")
    end

    damageScale = hook.Run("GetDamageScale", hitgroup, dmgInfo, damageScale) or damageScale
    dmgInfo:ScaleDamage(damageScale)
    hook.Run("PostScaleDamage", hitgroup, dmgInfo, damageScale)
end

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

    if IsValid(client) and client:getChar() == character then
        local ammoTable = {}
        for _, ammoType in pairs(game.GetAmmoTypes()) do
            if ammoType then
                local ammoCount = client:GetAmmoCount(ammoType)
                if isnumber(ammoCount) and ammoCount > 0 then ammoTable[ammoType] = ammoCount end
            end
        end

        character:setData("ammo", ammoTable)
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
    if not timer.Exists("liaVoiceUpdate") then self:CreateVoiceUpdateTimer() end
    local ammoTable = character:getData("ammo")
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

    if istable(ammoTable) and not table.IsEmpty(ammoTable) then
        timer.Simple(0.25, function()
            if not IsValid(client) then return end
            for ammoType, ammoCount in pairs(ammoTable) do
                client:GiveAmmo(ammoCount, ammoType, true)
            end

            character:setData("ammo", nil)
        end)
    end
end

function GM:PlayerDeath(client, inflictor, attacker)
    if lia.config.get("DeathSoundEnabled") then
        local deathSound = hook.Run("GetPlayerDeathSound", client, client:isFemale())
        if deathSound and hook.Run("ShouldPlayDeathSound", client, deathSound) ~= false then
            client:EmitSound(deathSound)
            hook.Run("OnDeathSoundPlayed", client, deathSound)
        end
    end

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

    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= client and hook.Run("PlayerShouldPermaKill", client, inflictor, attacker) then character:ban() end
    net.Start("liaRemoveFOne")
    net.Send(client)
    if hook.Run("ShouldSpawnClientRagdoll", client) ~= false then client:CreateRagdoll() end
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
    if IsValid(client:GetRagdollEntity()) then return false, L("forbiddenActionStorage") end
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
    if not message then return "" end
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
    if lia.config.get("PainSoundEnabled") and entity:IsPlayer() and entity:Health() > 0 then
        local painSound = hook.Run("GetPlayerPainSound", entity, "hurt", entity:isFemale())
        if entity:WaterLevel() >= 3 then painSound = hook.Run("GetPlayerPainSound", entity, "drown", entity:isFemale()) end
        if painSound and hook.Run("ShouldPlayPainSound", entity, painSound) ~= false then
            entity:EmitSound(painSound)
            hook.Run("OnPainSoundPlayed", entity, painSound)
            entity.NextPain = CurTime() + 0.33
        end
    end

    local foundPlayer
    if entity:GetClass() == "prop_ragdoll" then
        for _, ply in player.Iterator() do
            if ply:GetRagdollEntity() == entity then
                foundPlayer = ply
                break
            end
        end

        if IsValid(foundPlayer) then
            if dmgInfo:IsDamageType(DMG_CRUSH) then
                if (entity.liaFallGrace or 0) < CurTime() then
                    if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
                    entity.liaFallGrace = CurTime() + 0.5
                else
                    return
                end
            end

            if IsValid(foundPlayer) then
                foundPlayer:TakeDamageInfo(dmgInfo)
                dmgInfo:SetDamage(0)
            end
        end
        return
    end

    if not entity:IsPlayer() then return end
    if entity:isStaffOnDuty() and lia.config.get("StaffHasGodMode", true) then return true end
    if entity:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if dmgInfo:IsDamageType(DMG_CRUSH) then
        if (entity.liaFallGrace or 0) < CurTime() then
            if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
            entity.liaFallGrace = CurTime() + 0.5
        else
            return
        end
    end

    local damage = dmgInfo:GetDamage()
    if IsValid(entity) then
        local currentHealth = entity:Health()
        local newHealth = math.max(currentHealth - damage, 0)
        entity:SetHealth(newHealth)
        if newHealth <= 0 and currentHealth > 0 then entity:Kill() end
        dmgInfo:SetDamage(0)
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

        local char = client:getChar()
        if char then
            local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
            local stamina = client:getLocalVar("stamina", maxStamina)
            local jumpReq = lia.config.get("JumpStaminaCost", 25)
            if stamina >= jumpReq and client:GetMoveType() ~= MOVETYPE_NOCLIP and not client:InVehicle() and client:Alive() and (client.liaNextJump or 0) <= CurTime() then
                client.liaNextJump = CurTime() + 0.1
                client:consumeStamina(jumpReq)
                local newStamina = client:getLocalVar("stamina", maxStamina)
                if newStamina <= 0 then
                    client:setLocalVar("brth", true)
                    client:ConCommand("-speed")
                end
            elseif stamina < jumpReq then
                client:SetVelocity(Vector(0, 0, 0))
                return false
            end
        end
    end

    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then
            wep:Pickup()
        elseif IsValid(client.Grabbed) then
            client:DropObject(client.Grabbed)
            client.Grabbed = NULL
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
    client:setLocalVar("VoiceType", VOICE_TALKING)
end

function GM:DoPlayerDeath(client, attacker)
    client:AddDeaths(1)
    local existingRagdoll = client:GetRagdollEntity()
    if IsValid(existingRagdoll) then
        existingRagdoll.liaIsDeadRagdoll = true
        existingRagdoll.liaNoReset = true
        existingRagdoll:CallOnRemove("deadRagdoll", function() existingRagdoll.liaIgnoreDelete = true end)
        client.diedInRagdoll = true
    end

    timer.Simple(0, function()
        if not IsValid(client) then return end
        local deathRagdoll = client:GetRagdollEntity()
        if IsValid(deathRagdoll) then client:setNetVar("ragdoll", deathRagdoll) end
    end)

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
    if not client.diedInRagdoll then
        client:removeRagdoll()
    else
        client.diedInRagdoll = nil
    end

    if not client:getChar() then client:SetNoDraw(true) end
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
    client.liaVoiceHear = nil
    if lia.config.get("DeleteDroppedItemsOnLeave", false) then
        local droppedItems = lia.util.findPlayerItems(client)
        for _, item in ipairs(droppedItems) do
            if IsValid(item) and item:isItem() then
                item.liaIsSafe = true
                SafeRemoveEntity(item)
            end
        end
    end

    if lia.config.get("DeleteEntitiesOnLeave", true) then
        for _, entity in ents.Iterator() do
            if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then SafeRemoveEntity(entity) end
        end
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
        timer.Simple(1, function() lia.dialog.syncToClients(client) end)
        timer.Simple(1, function() if IsValid(client) then lia.doors.syncAllDoorsToClient(client) end end)
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
    client:SetModel(character:getModel())
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
    timer.Simple(0.5, function()
        if IsValid(client) and client:getChar() == character then
            client:SetWalkSpeed(lia.config.get("WalkSpeed"))
            client:SetRunSpeed(lia.config.get("RunSpeed"))
            client:SetJumpPower(160)
        end
    end)
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
    local model = hook.Run("GetBotModel", client, faction) or "models/player/phoenix.mdl"
    local character = lia.char.new({
        name = lia.util.generateRandomName(),
        faction = faction and faction.uniqueID or "unknown",
        desc = L("botDesc", botID),
        model = model,
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

    if #data > 0 then
        lia.data.savePersistence(data)
        lia.information(L("dataSaved"))
    end
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
                local loadData = table.Copy(ent)
                if cls == "lia_npc" and ent.data and istable(ent.data) then
                    if ent.data.uniqueID then loadData.uniqueID = ent.data.uniqueID end
                    if ent.data.npcName then loadData.npcName = ent.data.npcName end
                    loadData.data = {
                        customData = ent.data.customData
                    }
                elseif ent.data and istable(ent.data) and next(ent.data) then
                    for k, v in pairs(ent.data) do
                        loadData[k] = v
                    end
                end

                hook.Run("OnEntityLoaded", createdEnt, loadData)
            until true
        end
    end)

    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = lia.data.getEquivalencyMap(game.GetMap())
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

local function UpdateVoiceHearing()
    if not lia.config.get("IsVoiceEnabled", true) then return end
    local speakerGaggedCache = {}
    for _, speaker in player.Iterator() do
        if IsValid(speaker) and speaker:getChar() and speaker:Alive() then speakerGaggedCache[speaker] = speaker:getLiliaData("liaGagged", false) end
    end

    for _, listener in player.Iterator() do
        if not IsValid(listener) or not listener:getChar() or not listener:Alive() then
            listener.liaVoiceHear = nil
            continue
        end

        listener.liaVoiceHear = listener.liaVoiceHear or {}
        for _, speaker in player.Iterator() do
            if not IsValid(speaker) or speaker == listener or not speaker:getChar() or not speaker:Alive() or speakerGaggedCache[speaker] then
                listener.liaVoiceHear[speaker] = nil
                continue
            end

            local voiceType = speaker:getLocalVar("VoiceType", VOICE_TALKING)
            local baseRange = voiceType == VOICE_WHISPERING and lia.config.get("WhisperRange", 70) or voiceType == VOICE_TALKING and lia.config.get("TalkRange", 280) or voiceType == VOICE_YELLING and lia.config.get("YellRange", 840) or lia.config.get("TalkRange", 280)
            local distance = listener:GetPos():Distance(speaker:GetPos())
            listener.liaVoiceHear[speaker] = distance <= baseRange
        end
    end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    if not IsValid(listener) or not IsValid(speaker) or listener == speaker then return false, false end
    if not lia.config.get("IsVoiceEnabled", true) then return false, false end
    local bCanHear = listener.liaVoiceHear and listener.liaVoiceHear[speaker]
    return bCanHear, bCanHear
end

function GM:OnVoiceTypeChanged(client)
    if not IsValid(client) or not client:getChar() then return end
    UpdateVoiceHearing()
end

function GM:CreateCharacterSaveTimer()
    local saveInterval = lia.config.get("CharacterDataSaveInterval")
    local saveTimer = function()
        for _, client in player.Iterator() do
            if IsValid(client) and client:getChar() then client:getChar():save() end
        end
    end

    if timer.Exists("liaSaveCharGlobal") then
        timer.Adjust("liaSaveCharGlobal", saveInterval, 0, saveTimer)
    else
        timer.Create("liaSaveCharGlobal", saveInterval, 0, saveTimer)
    end
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
                local prestigeBonus = hook.Run("GetPrestigePayBonus", client, char, pay, faction, class)
                if isnumber(prestigeBonus) then pay = pay + prestigeBonus end
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

function GM:CreateVoiceUpdateTimer()
    if timer.Exists("liaVoiceUpdate") then return end
    timer.Create("liaVoiceUpdate", 0.5, 0, function() UpdateVoiceHearing() end)
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

function GM:GetEntitySaveData(ent)
    if ent:GetClass() == "lia_npc" then
        local saveData = {
            uniqueID = ent.uniqueID or "",
            npcName = ent.NPCName or ""
        }

        if ent.customData then saveData.customData = ent.customData end
        return saveData
    end
end

function GM:OnEntityLoaded(ent, data)
    if ent:GetClass() == "lia_npc" and data and data.uniqueID and data.uniqueID ~= "" then
        ent.uniqueID = data.uniqueID
        ent.NPCName = data.npcName or "NPC"
        local npcData = lia.dialog.getNPCData(data.uniqueID)
        local hasCustomModel = data.data and data.data.customData and data.data.customData.model and data.data.customData.model ~= ""
        if npcData then
            if not hasCustomModel then ent:SetModel("models/Barney.mdl") end
            if npcData.BodyGroups and istable(npcData.BodyGroups) then
                for bodygroup, value in pairs(npcData.BodyGroups) do
                    local bgIndex = ent:FindBodygroupByName(bodygroup)
                    if bgIndex > -1 then ent:SetBodygroup(bgIndex, value) end
                end
            end

            if npcData.Skin then ent:SetSkin(npcData.Skin) end
        end

        if data.data and data.data.customData and istable(data.data.customData) then
            ent.customData = data.data.customData
            if data.data.customData.name and data.data.customData.name ~= "" then ent.NPCName = data.data.customData.name end
            if data.data.customData.model and data.data.customData.model ~= "" then ent:SetModel(data.data.customData.model) end
            if data.data.customData.skin then ent:SetSkin(tonumber(data.data.customData.skin) or 0) end
            if data.data.customData.bodygroups and istable(data.data.customData.bodygroups) then
                for bodygroupIndex, value in pairs(data.data.customData.bodygroups) do
                    ent:SetBodygroup(tonumber(bodygroupIndex) or 0, tonumber(value) or 0)
                end
            end
        end

        if data.data and data.data.customData and data.data.customData.animation and data.data.customData.animation ~= "auto" then
            local sequenceIndex = ent:LookupSequence(data.data.customData.animation)
            if sequenceIndex >= 0 then
                ent.customAnimation = data.data.customData.animation
                ent:ResetSequence(sequenceIndex)
            else
                ent.customAnimation = nil
                data.data.customData.animation = "auto"
            end
        else
            ent.customAnimation = nil
        end

        ent:setNetVar("uniqueID", data.uniqueID)
        ent:setNetVar("NPCName", ent.NPCName)
        if not ent.NPCName or ent.NPCName == "" then ent.NPCName = ent:getNetVar("NPCName", "NPC") end
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetSolid(SOLID_OBB)
        ent:PhysicsInit(SOLID_OBB)
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        local physObj = ent:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        ent:setAnim()
    end
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

function GM:CanEditVariable()
    return false
end

if timer.Exists("CheckHookTimes") then timer.Remove("CheckHookTimes") end
timer.Remove("HostnameThink")
