local GM = GM or GAMEMODE
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

function GM:LiliaTablesLoaded()
    local ignore = function() end
    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE IF EXISTS lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
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
                client:notifyLocalized("waitDrop")
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
                client:notifyLocalized("waitPickup")
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
                client:notifyLocalized("waitEquip")
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
                client:notifyLocalized("waitUnequip")
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
        client:notifyLocalized("waitEquip")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    end
end

function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notifyLocalized("waitPickup")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
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
        client:notifyLocalized("waitDrop")
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

function GM:CheckPassword(steamid64, _, svpass, clpass, name)
    local convertingMessage = lia.config.isConverting and "Server is converting configuration, please retry later" or lia.data.isConverting and "Server is converting data, please retry later" or lia.log.isConverting and "Server is converting logs, please retry later"
    if convertingMessage then return false, convertingMessage end
    if svpass ~= "" and svpass ~= clpass then
        lia.log.add(nil, "failedPassword", steamid64, name, svpass, clpass)
        lia.information("Passwords do not match for " .. name .. " (" .. steamid64 .. "), " .. "server password: " .. svpass .. ", client password: " .. clpass .. ".")
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
        desc = "This is a bot. BotID is " .. botID .. ".",
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
    local pos = ent.pos or ent:GetPos()
    local tol = 1
    return string.format("%s_%.0f_%.0f_%.0f", ent.class or ent:GetClass(), pos.x / tol, pos.y / tol, pos.z / tol)
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
            if not seen[key] then
                seen[key] = true
                data.entities[#data.entities + 1] = {
                    pos = ent:GetPos(),
                    class = ent:GetClass(),
                    model = ent:GetModel(),
                    angles = ent:GetAngles(),
                }
            end
        end
    end

    for _, item in ipairs(ents.FindByClass("lia_item")) do
        if item.liaItemID and not item.temp then data.items[#data.items + 1] = {item.liaItemID, item:GetPos()} end
    end

    lia.data.set("persistance", data.entities, true)
    lia.data.set("itemsave", data.items, true)
end

function GM:OnEntityCreated(ent)
    if not IsValid(ent) or not ent:isLiliaPersistent() then return end
    local saved = lia.data.get("persistance", {}, true) or {}
    local seen = {}
    for _, e in ipairs(saved) do
        seen[makeKey(e)] = true
    end

    local key = makeKey(ent)
    if not seen[key] then
        saved[#saved + 1] = {
            pos = ent:GetPos(),
            class = ent:GetClass(),
            model = ent:GetModel(),
            angles = ent:GetAngles(),
        }

        lia.data.set("persistance", saved, true)
    end
end

function GM:LoadData()
    local function IsEntityNearby(pos, class)
        for _, ent in ipairs(ents.FindByClass(class)) do
            if ent:GetPos():Distance(pos) <= 50 then return true end
        end
        return false
    end

    local entities = lia.data.get("persistance", {}, true)
    for _, ent in ipairs(entities or {}) do
        if not IsEntityNearby(ent.pos, ent.class) then
            local createdEnt = ents.Create(ent.class)
            if IsValid(createdEnt) then
                if ent.pos then createdEnt:SetPos(ent.pos) end
                if ent.angles then createdEnt:SetAngles(ent.angles) end
                if ent.model then createdEnt:SetModel(ent.model) end
                createdEnt:Spawn()
                createdEnt:Activate()
            end
        else
            lia.error(string.format("Entity creation aborted: An entity of class '%s' is already nearby at position (%.2f, %.2f, %.2f).", ent.class, ent.pos.x, ent.pos.y, ent.pos.z))
        end
    end

    local items = lia.data.get("itemsave", {}, true)
    if items then
        local idRange = {}
        local positions = {}
        for _, item in ipairs(items) do
            idRange[#idRange + 1] = item[1]
            positions[item[1]] = item[2]
        end

        if #idRange > 0 then
            local range = "(" .. table.concat(idRange, ", ") .. ")"
            if hook.Run("ShouldDeleteSavedItems") == true then
                lia.db.query("DELETE FROM lia_items WHERE _itemID IN " .. range)
                lia.information("Server Deleted Server Items (does not include Logical Items)")
            else
                lia.db.query("SELECT _itemID, _uniqueID, _data FROM lia_items WHERE _itemID IN " .. range, function(data)
                    if data then
                        local loadedItems = {}
                        for _, item in ipairs(data) do
                            local itemID = tonumber(item._itemID)
                            local itemData = util.JSONToTable(item._data or "[]")
                            local uniqueID = item._uniqueID
                            local itemTable = lia.item.list[uniqueID]
                            local position = positions[itemID]
                            if itemTable and itemID then
                                local itemCreated = lia.item.new(uniqueID, itemID)
                                itemCreated.data = itemData or {}
                                itemCreated:spawn(position).liaItemID = itemID
                                itemCreated:onRestored()
                                itemCreated.invID = 0
                                table.insert(loadedItems, itemCreated)
                            end
                        end

                        hook.Run("OnSavedItemLoaded", loadedItems)
                    end
                end)
            end
        end
    end
end

local function DatabaseQuery()
    if not DatabaseQueryRan then
        local typeMap = {
            string = function(d) return ("%s VARCHAR(%d)"):format(d.field, d.length or 255) end,
            integer = function(d) return ("%s INT"):format(d.field) end,
            float = function(d) return ("%s FLOAT"):format(d.field) end,
            boolean = function(d) return ("%s TINYINT(1)"):format(d.field) end,
            datetime = function(d) return ("%s DATETIME"):format(d.field) end,
            text = function(d) return ("%s TEXT"):format(d.field) end
        }

        local dbModule = lia.db.module or "sqlite"
        local getColumnsQuery = dbModule == "sqlite" and "SELECT sql FROM sqlite_master WHERE type='table' AND name='lia_characters'" or "DESCRIBE lia_characters"
        lia.db.query(getColumnsQuery, function(results)
            local existing = {}
            if results and #results > 0 then
                if dbModule == "sqlite" then
                    local createSQL = results[1].sql or ""
                    for def in createSQL:match("%((.+)%)"):gmatch("([^,]+)") do
                        local col = def:match("^%s*`?(%w+)`?")
                        if col then existing[col] = true end
                    end
                else
                    for _, row in ipairs(results) do
                        existing[row.Field] = true
                    end
                end
            end

            for _, v in pairs(lia.char.vars) do
                if v.field and not existing[v.field] and typeMap[v.fieldType] then
                    local colDef = typeMap[v.fieldType](v)
                    if v.default ~= nil then colDef = colDef .. " DEFAULT '" .. tostring(v.default) .. "'" end
                    local alter = ("ALTER TABLE lia_characters ADD COLUMN %s"):format(colDef)
                    lia.db.query(alter, function() MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database] ", Color(255, 255, 255), string.format("Added missing column `%s`.\n", v.field)) end)
                end
            end
        end)

        DatabaseQueryRan = true
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

local publicURL = "https://raw.githubusercontent.com/LiliaFramework/Modules/refs/heads/gh-pages/modules.json"
local privateURL = "https://raw.githubusercontent.com/bleonheart/bleonheart.github.io/main/modules.json"
local versionURL = "https://raw.githubusercontent.com/LiliaFramework/LiliaFramework.github.io/main/version.json"
local function checkPublicModules()
    fetchURL(publicURL, function(body, code)
        if code ~= 200 then
            lia.updater("Error fetching module list (HTTP " .. code .. ")")
            return
        end

        local remote = util.JSONToTable(body)
        if not remote then
            lia.updater("Error parsing module data")
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
                lia.updater("Module with uniqueID '" .. info.uniqueID .. "' not found")
            elseif not match.version then
                lia.updater("Module '" .. info.name .. "' has no remote version info")
            elseif match.version ~= info.localVersion then
                lia.updater("Module '" .. info.name .. "' is outdated. Update to version " .. match.version)
            end
        end
    end, function(err) lia.updater("Error fetching module list: " .. err) end)
end

local function checkPrivateModules()
    fetchURL(privateURL, function(body, code)
        if code ~= 200 then
            lia.updater("Error fetching private module list (HTTP " .. code .. ")")
            return
        end

        local remote = util.JSONToTable(body)
        if not remote then
            lia.updater("Error parsing private module data")
            return
        end

        for _, info in ipairs(lia.module.privateVersionChecks) do
            for _, m in ipairs(remote) do
                if m.uniqueID == info.uniqueID and m.version and m.version ~= info.localVersion then
                    lia.updater("Module '" .. info.name .. "' is outdated, please report back to the author")
                    break
                end
            end
        end
    end, function(err) lia.updater("Error fetching private module list: " .. err) end)
end

local function checkFrameworkVersion()
    fetchURL(versionURL, function(body, code)
        if code ~= 200 then
            lia.updater("Error fetching framework version (HTTP " .. code .. ")")
            return
        end

        local remote = util.JSONToTable(body)
        if not remote or not remote.version then
            lia.updater("Error parsing framework version data")
            return
        end

        local localVersion = GM.version
        if not localVersion then
            lia.updater("Error reading local framework version")
            return
        end

        if remote.version ~= localVersion then lia.updater("Framework is outdated. Update at https://github.com/LiliaFramework/Lilia/releases/tag/release") end
    end, function(err) lia.updater("Error fetching framework version: " .. err) end)
end

function GM:InitializedModules()
    if self.UpdateCheckDone then return end
    timer.Simple(0, function()
        if lia.module.versionChecks then checkPublicModules() end
        if lia.module.privateVersionChecks then checkPrivateModules() end
        checkFrameworkVersion()
    end)

    timer.Simple(5, DatabaseQuery)
    self.UpdateCheckDone = true
end

function ClientAddText(client, ...)
    if not client or not IsValid(client) then
        lia.error("Invalid client provided to chat.AddText")
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
    local char = speaker:getChar()
    if not (char and not char:getData("VoiceBan", false)) then return false, false end
    if not lia.config.get("IsVoiceEnabled", true) then return false, false end
    local voiceType = speaker:getNetVar("VoiceType", "Talking")
    local range = TalkRanges[voiceType] or TalkRanges["Talking"]
    local distanceSqr = listener:GetPos():DistToSqr(speaker:GetPos())
    local canHear = distanceSqr <= range * range
    return canHear, canHear
end

local networkStrings = {"msg", "ServerChatAddText", "TogglePropBlacklist", "ToggleCarBlacklist", "liaCharacterInvList", "liaNotify", "liaNotifyL", "CreateTableUI", "WorkshopDownloader_Start", "liaPACSync", "liaPACPartAdd", "liaPACPartRemove", "liaPACPartReset", "sam_blind", "CurTime-Sync", "NetStreamDS", "liaInventoryAdd", "liaInventoryRemove", "liaInventoryData", "liaInventoryInit", "liaInventoryDelete", "liaItemDelete", "liaItemInstance", "seqSet", "setWaypoint", "setWaypointWithLogo", "AnimationStatus", "actBar", "RequestDropdown", "OptionsRequest", "StringRequest", "BinaryQuestionRequest", "liaTransferItem", "liaStorageOpen", "liaStorageUnlock", "liaStorageExit", "liaStorageTransfer", "trunkInitStorage", "VendorTrade", "VendorExit", "VendorMoney", "VendorStock", "VendorMaxStock", "VendorAllowFaction", "VendorAllowClass", "VendorEdit", "VendorMode", "VendorPrice", "VendorSync", "VendorOpen", "rgnDone", "AdminModeSwapCharacter", "managesitrooms", "liaCharChoose", "lia_managesitrooms_action", "SpawnMenuSpawnItem", "SpawnMenuGiveItem", "send_logs_request", "send_logs", "OpenInvMenu", "TicketSystemClaim", "TicketSystemClose", "TicketSystem", "ViewClaims", "RunOption", "RunLocalOption", "TransferMoneyFromP2P", "CheckHack", "CheckSeed", "VerifyCheats", "request_respawn", "classUpdate", "ChangeSpeakMode", "liaTeleportToEntity", "removeF1", "liaCharList", "liaCharCreate", "liaCharDelete", "cmd", "liaCmdArgPrompt", "prePlayerLoadedChar", "playerLoadedChar", "postPlayerLoadedChar", "doorMenu", "doorPerm", "charSet", "charVar", "charData", "charInfo", "charKick", "liaCharFetchNames", "attrib"}
for _, netString in ipairs(networkStrings) do
    util.AddNetworkString(netString)
end