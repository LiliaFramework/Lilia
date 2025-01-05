local GM = GM or GAMEMODE
function GM:InitializedModules()
    local bootstrapEndTime = SysTime()
    local timeTaken = bootstrapEndTime - BootingTime
    LiliaBootstrap("Bootstrapper", string.format("Lilia loaded in %.2f seconds.", timeTaken), Color(0, 255, 0))
    for _, data in pairs(lia.char.vars) do
        if data.fieldType then
            local fieldDefinition
            if data.fieldType == "string" then
                fieldDefinition = data.field .. " VARCHAR(" .. (data.length or "255") .. ")"
            elseif data.fieldType == "integer" then
                fieldDefinition = data.field .. " INT"
            elseif data.fieldType == "float" then
                fieldDefinition = data.field .. " FLOAT"
            elseif data.fieldType == "boolean" then
                fieldDefinition = data.field .. " TINYINT(1)"
            elseif data.fieldType == "datetime" then
                fieldDefinition = data.field .. " DATETIME"
            elseif data.fieldType == "text" then
                fieldDefinition = data.field .. " TEXT"
            end

            if fieldDefinition then
                if data.default ~= nil then fieldDefinition = fieldDefinition .. " DEFAULT '" .. tostring(data.default) .. "'" end
                lia.db.query("SELECT " .. data.field .. " FROM lia_characters", function(result)
                    if not result then
                        local success, _ = lia.db.query("ALTER TABLE lia_characters ADD COLUMN " .. fieldDefinition)
                        if success then
                            LiliaInformation("Adding column " .. data.field .. " to the database!")
                        else
                            LiliaInformation("Failed to add column " .. data.field .. " due to a query error.")
                        end
                    end
                end)
            end
        end
    end
end

function GM:CharPreSave(character)
    local client = character:getPlayer()
    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.OnSave then v:call("OnSave", client) end
    end
end

function GM:PlayerLoadedChar(client, character)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        _lastJoinTime = timeStamp
    }, nil, "characters", "_id = " .. character:getID())

    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaNoReset = true
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
    end

    character:setData("loginTime", os.time())
    hook.Run("PlayerLoadout", client)
end

function GM:CharLoaded(id)
    local character = lia.char.loaded[id]
    if character then
        local client = character:getPlayer()
        if IsValid(client) then
            local uniqueID = "liaSaveChar" .. client:SteamID()
            timer.Create(uniqueID, lia.config.CharacterDataSaveInterval, 0, function()
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
        if SERVER and character and character:getPlayer() then
            character:getPlayer():notify("You can't transfer a backpack that has items inside of it.")
        elseif CLIENT then
            lia.notices.notify("You can't transfer a backpack that has items inside of it.")
        end
        return false
    end

    if item.OnCanBeTransfered then
        local itemHook = item:OnCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

function GM:CanPlayerInteractItem(client, action, item)
    action = string.lower(action)
    if not client:Alive() then return false, "You can't use items while dead" end
    if client:getLocalVar("ragdoll", false) then return false, "You can't use items while ragdolled." end
    if action == "drop" then
        if hook.Run("CanPlayerDropItem", client, item) ~= false then
            if not client.dropDelay then
                client.dropDelay = true
                timer.Create("DropDelay." .. client:SteamID64(), lia.config.DropDelay, 1, function() if IsValid(client) then client.dropDelay = nil end end)
                return true
            else
                client:notify("You need to wait before dropping something again!")
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
                timer.Create("TakeDelay." .. client:SteamID64(), lia.config.TakeDelay, 1, function() if IsValid(client) then client.takeDelay = nil end end)
                return true
            else
                client:notify("You need to wait before picking something up again!")
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
                timer.Create("EquipDelay." .. client:SteamID64(), lia.config.EquipDelay, 1, function() if IsValid(client) then client.equipDelay = nil end end)
                return true
            else
                client:notify("You need to wait before equipping something again!")
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
                timer.Create("UnequipDelay." .. client:SteamID64(), lia.config.UnequipDelay, 1, function() if IsValid(client) then client.unequipDelay = nil end end)
                return true
            else
                client:notify("You need to wait before unequipping something again!")
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
        client:notify("You need to wait before equipping something again!")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    end
end

function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notify("You need to wait before picking something up again!")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyLocalized("forbiddenActionStorage")
        return false
    elseif IsValid(item.entity) then
        local character = client:getChar()
        if item.entity.SteamID64 == client:SteamID() and item.entity.liaCharID ~= character:getID() then
            client:notifyLocalized("playerCharBelonging")
            return false
        end
    end
end

function GM:CanPlayerDropItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.dropDelay ~= nil then
        client:notify("You need to wait before dropping something again!")
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

function GM:PlayerSay(client, message)
    local logTypeMap = {
        ooc = "chatOOC",
        looc = "chatLOOC"
    }

    local chatType, message, anonymous = lia.chat.parse(client, message, true)
    if chatType == "ic" and lia.command.parse(client, message) then return "" end
    if utf8.len(message) > lia.config.MaxChatLength then
        client:notify("Your message is too long and has not been sent.")
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

function GM:EntityTakeDamage(entity, dmgInfo)
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
    if key == IN_USE then
        local trace = util.TraceLine({
            start = client:GetShootPos(),
            endpos = client:GetShootPos() + client:GetAimVector() * 96,
            filter = client
        })

        local entity = trace.Entity
        if IsValid(entity) and (entity:isDoor() or entity:IsPlayer()) then hook.Run("PlayerUse", client, entity) end
    elseif key == IN_JUMP then
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

function GM:EntityNetworkedVarChanged(entity, varName, _, newVal)
    if varName == "Model" and entity.SetModel then hook.Run("PlayerModelChanged", entity, newVal) end
end

function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

function GM:GetGameDescription()
    return (lia.config.GamemodeName == "A Lilia Gamemode" and istable(SCHEMA)) and tostring(SCHEMA.name) or lia.config.GamemodeName
end

function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not (IsValid(client) or character) then return end
    client:Give("lia_hands")
    client:SetupHands()
end

function GM:DoPlayerDeath(client, attacker)
    client:AddDeaths(1)
    if hook.Run("ShouldSpawnClientRagdoll", client) ~= false then client:CreateRagdoll() end
    if IsValid(attacker) and attacker:IsPlayer() then
        if client == attacker then
            attacker:AddFrags(-1)
        else
            attacker:AddFrags(1)
        end
    end

    client:SetDSP(31)
end

function GM:PlayerDeath(client)
    local character = client:getChar()
    if not character then return end
    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
        client:setLocalVar("blur", nil)
    end
end

function GM:PlayerSpawn(client)
    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:stopAction()
    client:SetDSP(1)
    hook.Run("PlayerLoadout", client)
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        hook.Run("OnCharDisconnect", client, character)
        character:save()
    end

    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaNoReset = true
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
    end

    lia.char.cleanUpForPlayer(client)
    for _, entity in pairs(ents.GetAll()) do
        if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then entity:Remove() end
    end
end

function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
        self:SetupBotPlayer(client)
        return
    end

    client.liaJoinTime = RealTime()
    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        netstream.Start(client, "liaDataSync", data, client.firstJoin, client.lastJoin)
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
    client:SetWalkSpeed(lia.config.WalkSpeed)
    client:SetRunSpeed(lia.config.RunSpeed)
    client:SetJumpPower(160)
    hook.Run("FactionOnLoadout", client)
    hook.Run("ClassOnLoadout", client)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    hook.Run("FactionPostLoadout", client)
    hook.Run("ClassPostLoadout", client)
    client:SelectWeapon("lia_hands")
end

function GM:SetupBotPlayer(client)
    local botID = os.time()
    local index = math.random(1, table.Count(lia.faction.indices))
    local faction = lia.faction.indices[index]
    local inventory = lia.inventory.new("grid")
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

function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

function GM:PlayerDeathThink(client)
    if client:getChar() and not client:IsOnDeathTimer() then client:Spawn() end
    return false
end
