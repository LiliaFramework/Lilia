local GM = GM or GAMEMODE
local encodeVector = lia.data.encodeVector
local encodeAngle = lia.data.encodeAngle
local decodeVector = lia.data.decodeVector
local decodeAngle = lia.data.decodeAngle
function GM:CharPreSave(character)
    local client = character:getPlayer()
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

        character:setData("ammo", ammoTable)
    end
end

function GM:PlayerLoadedChar(client, character)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        _lastJoinTime = timeStamp
    }, nil, "characters", "_id = " .. character:getID())

    client:removeRagdoll()
    character:setData("loginTime", os.time())
    hook.Run("PlayerLoadout", client)
    local ammoTable = character:getData("ammo", {})
    if table.IsEmpty(ammoTable) then return end
    timer.Simple(0.25, function()
        if not IsValid(ammoTable) then return end
        for ammoType, ammoCount in pairs(ammoTable) do
            if IsValid(ammoCount) or IsValid(ammoCount) then client:GiveAmmo(ammoCount, ammoType, true) end
        end

        character:setData("ammo", nil)
    end)
end

function GM:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()
    if not character then return end
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
end

function GM:PlayerShouldPermaKill(client)
    local character = client:getChar()
    return character:getData("markedForDeath", false)
end

function GM:CharLoaded(id)
    local character = lia.char.loaded[id]
    if character then
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
    end
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
        client:notifyLocalized("moneyTaken", lia.currency.get(amount))
        lia.log.add(client, "moneyPickedUp", amount)
    end
end

function GM:CanItemBeTransfered(item, curInv, inventory)
    if item.isBag and curInv ~= inventory and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
        local character = lia.char.loaded[curInv.client]
        character:getPlayer():notifyLocalized("forbiddenActionStorage")
        return false
    end

    if item.OnCanBeTransfered then
        local itemHook = item:OnCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

function GM:CanPlayerInteractItem(client, action, item)
    action = string.lower(action)
    if not client:Alive() then return false, L("forbiddenActionStorage") end
    if client:getLocalVar("ragdoll", false) then return false, L("forbiddenActionStorage") end
    if action == "drop" then
        if hook.Run("CanPlayerDropItem", client, item) ~= false then
            if not client.dropDelay then
                client.dropDelay = true
                timer.Create("DropDelay." .. client:SteamID64(), lia.config.get("DropDelay"), 1, function() if IsValid(client) then client.dropDelay = nil end end)
                return true
            else
                client:notifyLocalized("switchCooldown")
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
                client:notifyLocalized("switchCooldown")
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
                client:notifyLocalized("switchCooldown")
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
                client:notifyLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end
end

function GM:CanPlayerEquipItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.equipDelay ~= nil then
        client:notifyLocalized("switchCooldown")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    end
end

function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notifyLocalized("switchCooldown")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    elseif client:OwnerSteamID64() ~= client:SteamID64() then
        client:notifyLocalized("familySharedPickupDisabled")
        return false
    elseif IsValid(item.entity) then
        local character = client:getChar()
        if item.entity.SteamID64 == client:SteamID64() and item.entity.liaCharID ~= character:getID() then
            client:notifyLocalized("playerCharBelonging")
            return false
        end
    end
end

function GM:CanPlayerDropItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.dropDelay ~= nil then
        client:notifyLocalized("switchCooldown")
        return false
    elseif item.isBag and item:getInv() then
        local items = item:getInv():getItems()
        for _, otheritem in pairs(items) do
            if not otheritem.ignoreEquipCheck and otheritem:getData("equip", false) then
                client:notifyLocalized("cantDropBagHasEquipped")
                return false
            end
        end
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    end
end

local logTypeMap = {
    ooc = "chatOOC",
    looc = "chatLOOC"
}

function GM:CheckPassword(steamID64, _, serverPassword, clientPassword, playerName)
    local banRecord = lia.admin.isBanned(steamID64)
    local banExpired = lia.admin.hasBanExpired(steamID64)
    if banRecord then
        if not banExpired then return false, L("banMessage", banRecord.duration / 60, banRecord.reason) end
        lia.admin.removeBan(steamID64)
    end

    local convertingMessage = lia.config.isConverting and L("serverConvertingConfig") or lia.data.isConverting and L("serverConvertingData") or lia.log.isConverting and L("serverConvertingLogs")
    if convertingMessage then return false, convertingMessage end
    if serverPassword ~= "" and serverPassword ~= clientPassword then
        lia.log.add(nil, "failedPassword", steamID64, playerName, serverPassword, clientPassword)
        lia.information(L("passwordMismatchInfo", playerName, steamID64, serverPassword, clientPassword))
        return false, L("passwordMismatchInfo", playerName, steamID64, serverPassword, clientPassword)
    end
end

function GM:PlayerSay(client, message)
    local chatType, parsedMessage, anonymous = lia.chat.parse(client, message, true)
    message = parsedMessage
    if chatType == "ic" and lia.command.parse(client, message) then return "" end
    if utf8.len(message) > lia.config.get("MaxChatLength") then
        client:notifyLocalized("tooLongMessage")
        return ""
    end

    local logType = logTypeMap[chatType] or "chat"
    lia.chat.send(client, chatType, message, anonymous)
    if logType == "chat" then
        lia.log.add(client, logType, chatType and chatType:upper() or "??", message)
    else
        lia.log.add(client, logType, message)
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
    if entity:isNoClipping() then return true end
    if IsValid(entity.liaPlayer) then
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
                entity.liaFallGrace = CurTime() + 0.5
            else
                return
            end
        end

        entity.liaPlayer:TakeDamageInfo(dmgInfo)
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
    return istable(SCHEMA) and tostring(SCHEMA.name) or "A Lilia Gamemode"
end

function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    client:Give("lia_hands")
    client:SetupHands()
    client:setNetVar("VoiceType", "Talking")
end

function GM:ShouldSpawnClientRagdoll(client)
    if client:IsBot() then
        client:Spawn()
        return false
    end
end

function GM:DoPlayerDeath(client, attacker)
    client:AddDeaths(1)
    if hook.Run("ShouldSpawnClientRagdoll", client) ~= false then client:createRagdoll(false, true) end
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
    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:stopAction()
    client:SetDSP(1, false)
    client:removeRagdoll()
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
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        hook.Run("OnCharDisconnect", client, character)
        character:save()
    end

    client:removeRagdoll()
    lia.char.cleanUpForPlayer(client)
    for _, entity in ents.Iterator() do
        if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then SafeRemoveEntity(entity) end
    end
end

function GM:InitializedConfig()
    timer.Simple(0.2, function() lia.config.send() end)
end

function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
        hook.Run("SetupBotPlayer", client)
        return
    end

    lia.config.send(client)
    client.liaJoinTime = RealTime()
    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        lia.db.updateTable({
            _lastIP = address
        }, nil, "players", "_steamID = " .. client:SteamID64())

        net.Start("liaDataSync")
        net.WriteTable(data)
        net.WriteType(client.firstJoin)
        net.WriteType(client.lastJoin)
        net.Send(client)
        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then v:sync(client) end
        end

        hook.Run("PlayerLiliaDataLoaded", client)
    end)

    hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerLoadout(client)
    local character = client:getChar()
    if client.liaSkipLoadout then
        client.liaSkipLoadout = nil
        return
    end

    if not character then
        client:SetNoDraw(true)
        client:Lock()
        client:SetNotSolid(true)
        return
    end

    client:SetWeaponColor(Vector(0.30, 0.80, 0.10))
    client:StripWeapons()
    client:setLocalVar("blur", nil)
    client:SetModel(character:getModel())
    client:SetWalkSpeed(lia.config.get("WalkSpeed"))
    client:SetRunSpeed(lia.config.get("RunSpeed"))
    client:SetJumpPower(160)
    hook.Run("FactionOnLoadout", client)
    hook.Run("ClassOnLoadout", client)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    hook.Run("FactionPostLoadout", client)
    hook.Run("ClassPostLoadout", client)
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
    local index = math.random(1, table.Count(lia.faction.indices))
    local faction = lia.faction.indices[index]
    local invType = hook.Run("GetDefaultInventoryType") or "GridInv"
    if not invType then return end
    local inventory = lia.inventory.new(invType)
    local character = lia.char.new({
        name = client:Name(),
        faction = faction and faction.uniqueID or "unknown",
        desc = L("botDesc", botID),
        model = "models/gman.mdl",
    }, botID, client, client:SteamID64())

    local defaultClass = lia.faction.getDefaultClass(faction.index)
    if defaultClass then character:joinClass(defaultClass.index) end
    character.isBot = true
    character.vars.inv = {}
    inventory.id = "bot" .. character:getID()
    character.vars.inv[1] = inventory
    lia.inventory.instances[inventory.id] = inventory
    lia.char.loaded[botID] = character
    character:setup()
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
            pos = decodeVector(ent.pos) -- handle encoded table
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
    local data = {
        entities = {},
        items = {}
    }

    for _, ent in ents.Iterator() do
        if ent:isLiliaPersistent() then
            local key = makeKey(ent)
            if key ~= "" and not seen[key] then
                seen[key] = true
                local entPos = ent:GetPos()
                local entAng = ent:GetAngles()
                local entData = {
                    pos = encodeVector(entPos),
                    class = ent:GetClass(),
                    model = ent:GetModel(),
                    angles = encodeAngle(entAng)
                }

                local extra = hook.Run("GetEntitySaveData", ent)
                if extra ~= nil then entData.data = extra end
                data.entities[#data.entities + 1] = entData
                print("[PERSIST] Saved entity:", entData.class, "Pos:", tostring(entPos), "Model:", tostring(entData.model))
                hook.Run("OnEntityPersisted", ent, entData)
            end
        end
    end

    for _, item in ipairs(ents.FindByClass("lia_item")) do
        if item.liaItemID and not item.temp then data.items[#data.items + 1] = {item.liaItemID, encodeVector(item:GetPos())} end
    end

    print("[PERSIST] Total entities saved:", #data.entities)
    print("[PERSIST] Total items saved:", #data.items)
    lia.data.set("persistence", data.entities)
    lia.data.set("itemsave", data.items)
end

function GM:LoadData()
    local function IsEntityNearby(pos, class)
        for _, ent in ipairs(ents.FindByClass(class)) do
            if ent:GetPos():DistToSqr(pos) <= 50 * 50 then return true end
        end
        return false
    end

    local entities = lia.data.get("persistence", {}) or {}
    print("[PERSIST] Loading entities count:", #entities)
    PrintTable(entities)
    for _, ent in ipairs(entities) do
        local decodedPos = decodeVector(ent.pos)
        local decodedAng = decodeAngle(ent.angles)
        if not decodedPos or not isvector(decodedPos) then
            print("[PERSIST] Skipping entity (invalid pos):", ent.class)
        elseif not ent.class then
            print("[PERSIST] Skipping entity (missing class)")
        elseif not IsEntityNearby(decodedPos, ent.class) then
            local createdEnt = ents.Create(ent.class)
            if IsValid(createdEnt) then
                createdEnt:SetPos(decodedPos)
                if decodedAng then createdEnt:SetAngles(decodedAng) end
                if ent.model then createdEnt:SetModel(ent.model) end
                createdEnt:Spawn()
                createdEnt:Activate()
                print("[PERSIST] Spawned entity:", ent.class, "Pos:", tostring(decodedPos), "Model:", tostring(ent.model))
                hook.Run("OnEntityLoaded", createdEnt, ent.data)
            else
                print("[PERSIST] Failed to create entity:", ent.class)
            end
        else
            print("[PERSIST] Skipped spawn (nearby exists):", ent.class, "Pos:", tostring(decodedPos))
            lia.error(L("entityCreationAborted", ent.class, decodedPos.x, decodedPos.y, decodedPos.z))
        end
    end

    local items = lia.data.get("itemsave", {}) or {}
    print("[PERSIST] Loading items count:", #items)
    if #items > 0 then
        local idRange, positions = {}, {}
        for _, item in ipairs(items) do
            local id = item[1]
            idRange[#idRange + 1] = id
            positions[id] = decodeVector(item[2])
        end

        if #idRange > 0 then
            local range = "(" .. table.concat(idRange, ", ") .. ")"
            if hook.Run("ShouldDeleteSavedItems") == true then
                lia.db.query("DELETE FROM lia_items WHERE _itemID IN " .. range)
                print("[PERSIST] Deleted saved items:", range)
                lia.information(L("serverDeletedItems"))
            else
                lia.db.query("SELECT _itemID, _uniqueID, _data FROM lia_items WHERE _itemID IN " .. range, function(data)
                    if not data then
                        print("[PERSIST] Item query returned no data")
                        return
                    end

                    local loadedItems = {}
                    for _, row in ipairs(data) do
                        local itemID = tonumber(row._itemID)
                        local itemData = util.JSONToTable(row._data or "[]")
                        local uniqueID = row._uniqueID
                        local itemTable = lia.item.list[uniqueID]
                        local position = positions[itemID]
                        if itemTable and itemID and position then
                            local itemCreated = lia.item.new(uniqueID, itemID)
                            itemCreated.data = itemData or {}
                            itemCreated:spawn(position).liaItemID = itemID
                            itemCreated:onRestored()
                            itemCreated.invID = 0
                            loadedItems[#loadedItems + 1] = itemCreated
                            print("[PERSIST] Restored item:", uniqueID, "ID:", itemID, "Pos:", tostring(position))
                        else
                            print("[PERSIST] Failed to restore item ID:", itemID, "UniqueID:", tostring(uniqueID))
                        end
                    end

                    print("[PERSIST] Total items restored:", #loadedItems)
                    hook.Run("OnSavedItemLoaded", loadedItems)
                end)
            end
        end
    end
end

function GM:OnEntityCreated(ent)
    if not IsValid(ent) or not ent:isLiliaPersistent() then return end
    local saved = lia.data.get("persistence", {}) or {}
    local seen = {}
    for _, e in ipairs(saved) do
        seen[makeKey(e)] = true
    end

    local key = makeKey(ent)
    if not seen[key] then
        saved[#saved + 1] = {
            pos = encodeVector(ent:GetPos()),
            class = ent:GetClass(),
            model = ent:GetModel(),
            angles = encodeAngle(ent:GetAngles())
        }

        lia.data.set("persistence", saved)
    end
end

local hasChttp = util.IsBinaryModuleInstalled("chttp")
if hasChttp then require("chttp") end
local function fetchURL(url, onSuccess, onError)
    if hasChttp then
        CHTTP({
            url = url,
            method = "GET",
            success = function(code, body) onSuccess(body, code) end,
            failed = function(err) onError(err) end
        })
    else
        http.Fetch(url, function(body, _, _, code) onSuccess(body, code) end, function(err) onError(err) end)
    end
end

local function versionCompare(localVersion, remoteVersion)
    local function toParts(v)
        local parts = {}
        if not v then return parts end
        for num in tostring(v):gmatch("%d+") do
            table.insert(parts, tonumber(num))
        end
        return parts
    end

    local lParts = toParts(localVersion)
    local rParts = toParts(remoteVersion)
    local len = math.max(#lParts, #rParts)
    for i = 1, len do
        local l = lParts[i] or 0
        local r = rParts[i] or 0
        if l < r then return -1 end
        if l > r then return 1 end
    end
    return 0
end

local publicURL = "https://raw.githubusercontent.com/LiliaFramework/Modules/refs/heads/gh-pages/modules.json"
local privateURL = "https://raw.githubusercontent.com/bleonheart/bleonheart.github.io/main/modules.json"
local versionURL = "https://raw.githubusercontent.com/LiliaFramework/LiliaFramework.github.io/main/version.json"
local function checkPublicModules()
    fetchURL(publicURL, function(body, code)
        if code ~= 200 then
            lia.updater(L("moduleListHTTPError", code))
            return
        end

        local remote = util.JSONToTable(body)
        if not remote then
            lia.updater(L("moduleDataParseError"))
            return
        end

        for _, info in ipairs(lia.module.versionChecks) do
            local match
            for _, m in ipairs(remote) do
                if m.uniqueID == info.uniqueID then
                    match = m
                    break
                end
            end

            if not match then
                lia.updater(L("moduleUniqueIDNotFound", info.uniqueID))
            elseif not match.version then
                lia.updater(L("moduleNoRemoteVersion", info.name))
            elseif info.localVersion and versionCompare(info.localVersion, match.version) < 0 then
                lia.updater(L("moduleOutdated", info.name, match.version))
            end
        end
    end, function(err) lia.updater(L("moduleListError", err)) end)
end

local function checkPrivateModules()
    fetchURL(privateURL, function(body, code)
        if code ~= 200 then
            lia.updater(L("privateModuleListHTTPError", code))
            return
        end

        local remote = util.JSONToTable(body)
        if not remote then
            lia.updater(L("privateModuleDataParseError"))
            return
        end

        for _, info in ipairs(lia.module.privateVersionChecks) do
            for _, m in ipairs(remote) do
                if m.uniqueID == info.uniqueID and m.version and info.localVersion and versionCompare(info.localVersion, m.version) < 0 then
                    lia.updater(L("privateModuleOutdated", info.name))
                    break
                end
            end
        end
    end, function(err) lia.updater(L("privateModuleListError", err)) end)
end

local function checkFrameworkVersion()
    fetchURL(versionURL, function(body, code)
        if code ~= 200 then
            lia.updater(L("frameworkVersionHTTPError", code))
            return
        end

        local remote = util.JSONToTable(body)
        if not remote or not remote.version then
            lia.updater(L("frameworkVersionDataParseError"))
            return
        end

        local localVersion = GM.version
        if not localVersion then
            lia.updater(L("localFrameworkVersionError"))
            return
        end

        if versionCompare(localVersion, remote.version) < 0 then lia.updater(L("frameworkOutdated")) end
    end, function(err) lia.updater(L("frameworkVersionError", err)) end)
end

function GM:InitializedModules()
    if self.UpdateCheckDone then return end
    timer.Simple(0, function()
        if lia.module.versionChecks then checkPublicModules() end
        if lia.module.privateVersionChecks then checkPrivateModules() end
        checkFrameworkVersion()
    end)

    timer.Simple(5, lia.db.addDatabaseFields)
    self.UpdateCheckDone = true
end

function GM:LiliaTablesLoaded()
    hook.Run("LoadData")
    hook.Run("PostLoadData")
    lia.db.addDatabaseFields()
end

function ClientAddText(client, ...)
    if not client or not IsValid(client) then
        lia.error(L("invalidClientChatAddText"))
        return
    end

    local args = {...}
    net.Start("ServerChatAddText")
    net.WriteTable(args)
    net.Send(client)
end

local TalkRanges = {
    ["Whispering"] = 120,
    ["Talking"] = 300,
    ["Yelling"] = 600,
}

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    if not IsValid(listener) and IsValid(speaker) or listener == speaker then return false, false end
    if speaker:getNetVar("IsDeadRestricted", false) then return false, false end
    if speaker:getNetVar("liaGagged", false) then return false, false end
    local char = speaker:getChar()
    if not (char and not char:getData("VoiceBan", false)) then return false, false end
    if not lia.config.get("IsVoiceEnabled", true) then return false, false end
    local voiceType = speaker:getNetVar("VoiceType", "Talking")
    local range = TalkRanges[voiceType] or TalkRanges["Talking"]
    local distanceSqr = listener:GetPos():DistToSqr(speaker:GetPos())
    local canHear = distanceSqr <= range * range
    return canHear, canHear
end

concommand.Add("bots", function(ply)
    if IsValid(ply) then return end
    local maxPlayers = game.MaxPlayers()
    local currentCount = player.GetCount()
    local toSpawn = maxPlayers - currentCount
    if toSpawn <= 0 then return end
    timer.Remove("BotsSpawnTimer")
    timer.Create("BotsSpawnTimer", 1.5, toSpawn, function() game.ConsoleCommand("bot\n") end)
end)

concommand.Add("kickbots", function()
    for _, bot in player.Iterator() do
        if bot:IsBot() then lia.command.execAdminCommand("kick", nil, bot, nil, L("allBotsKicked")) end
    end
end)

concommand.Add("stopsoundall", function(client)
    if client:IsSuperAdmin() then
        for _, v in player.Iterator() do
            v:ConCommand("stopsound")
        end
    else
        client:notifyLocalized("mustSuperAdminStopSound")
    end
end)

concommand.Add("list_entities", function(client)
    local entityCount = {}
    local totalEntities = 0
    if not IsValid(client) then
        lia.information(L("entitiesOnServer"))
        for _, entity in ents.Iterator() do
            local className = entity:GetClass() or L("unknown")
            entityCount[className] = (entityCount[className] or 0) + 1
            totalEntities = totalEntities + 1
        end

        for className, count in pairs(entityCount) do
            lia.information(string.format(L("entityClassCount"), className, count))
        end

        lia.information(string.format(L("totalEntities"), totalEntities))
    end
end)

local networkStrings = {"CharacterInfo", "RegenChat", "msg", "doorPerm", "invAct", "liaDataSync", "ServerChatAddText", "charSet", "liaCharFetchNames", "charData", "charVar", "liaCharacterInvList", "charKick", "cMsg", "liaCmdArgPrompt", "cmd", "cfgSet", "cfgList", "gVar", "liaNotify", "liaNotifyL", "CreateTableUI", "WorkshopDownloader_Start", "WorkshopDownloader_Request", "WorkshopDownloader_Info", "liaPACSync", "liaPACPartAdd", "liaPACPartRemove", "liaPACPartReset", "blindTarget", "blindFade", "CurTime-Sync", "NetStreamDS", "attrib", "charInfo", "nVar", "nDel", "doorMenu", "liaInventoryAdd", "liaInventoryRemove", "liaInventoryData", "liaInventoryInit", "liaInventoryDelete", "liaItemDelete", "liaItemInstance", "invData", "invQuantity", "seqSet", "liaData", "setWaypoint", "setWaypointWithLogo", "AnimationStatus", "actBar", "RequestDropdown", "OptionsRequest", "StringRequest", "ArgumentsRequest", "BinaryQuestionRequest", "nLcl", "item", "OpenInvMenu", "prePlayerLoadedChar", "playerLoadedChar", "postPlayerLoadedChar", "liaTransferItem", "AdminModeSwapCharacter", "managesitrooms", "liaCharChoose", "lia_managesitrooms_action", "SpawnMenuSpawnItem", "SpawnMenuGiveItem", "send_logs", "send_logs_request", "TicketSystemClaim", "TicketSystemClose", "TicketSystem", "ViewClaims", "RequestRemoveWarning", "ChangeAttribute", "liaTeleportToEntity", "removeF1", "ForceUpdateF1", "TransferMoneyFromP2P", "RunOption", "RunLocalOption", "rgnDone", "liaStorageOpen", "liaStorageUnlock", "liaStorageExit", "liaStorageTransfer", "trunkInitStorage", "VendorTrade", "VendorExit", "VendorEdit", "VendorMoney", "VendorStock", "VendorMaxStock", "VendorAllowFaction", "VendorAllowClass", "VendorMode", "VendorPrice", "VendorSync", "VendorOpen", "Vendor", "VendorFaction", "liaCharList", "liaCharCreate", "liaCharDelete", "CheckHack", "CheckSeed", "VerifyCheats", "request_respawn", "classUpdate"}
for _, netString in ipairs(networkStrings) do
    util.AddNetworkString(netString)
end