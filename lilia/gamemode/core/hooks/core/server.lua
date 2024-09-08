local GM = GM or GAMEMODE
function GM:onCharCreated(client, character, data)
    LiliaDeprecated("onCharCreated is deprecated. Use OnCharCreated for optimization purposes.")
    hook.Run("OnCharCreated", client, character, data)
end

function GM:onTransferred(client)
    LiliaDeprecated("onTransferred is deprecated. Use OnTransferred for optimization purposes.")
    hook.Run("OnTransferred", client)
end

function GM:CharacterPreSave(character)
    LiliaDeprecated("CharacterPreSave is deprecated. Use CharPreSave for optimization purposes.")
    hook.Run("CharPreSave", character)
end

function GM:CharPreSave(character)
    local client = character:getPlayer()
    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.onSave then v:call("onSave", client) end
    end
end

function GM:PlayerLoadedChar(client, character, lastChar)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        _lastJoinTime = timeStamp
    }, nil, "characters", "_id = " .. character:getID())

    if lastChar then
        local charEnts = lastChar:getVar("charEnts") or {}
        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then v:Remove() end
        end

        lastChar:setVar("charEnts", nil)
    end

    if client:hasRagdoll() then
        local ragdoll = client:getRagdoll()
        ragdoll.liaNoReset = true
        ragdoll.liaIgnoreDelete = true
        ragdoll:Remove()
    end

    character:setData("loginTime", os.time())
    hook.Run("PlayerLoadout", client)
end

function GM:CharacterLoaded(id)
    LiliaDeprecated("CharacterLoaded is deprecated. Use CharLoaded for optimization purposes.")
    hook.Run("CharLoaded", id)
end

function GM:PreCharacterDelete(id)
    LiliaDeprecated("PreCharacterDelete is deprecated. Use PreCharDelete for optimization purposes.")
    hook.Run("PreCharDelete", id)
end

function GM:OnCharacterDelete(client, id)
    LiliaDeprecated("OnCharacterDelete is deprecated. Use OnCharDelete for optimization purposes.")
    hook.Run("OnCharDelete", client, id)
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
    if moneyEntity and moneyEntity:IsValid() then
        local amount = moneyEntity:getAmount()
        client:getChar():giveMoney(amount)
        client:notifyLocalized("moneyTaken", lia.currency.get(amount))
        lia.log.add(client, "moneyPickedUp", amount)
    end
end

function GM:OnPlayerInteractItem(client, action, item)
    if isentity(item) then
        if IsValid(item) then
            local itemID = item.liaItemID
            item = lia.item.instances[itemID]
        else
            return
        end
    elseif isnumber(item) then
        item = lia.item.instances[item]
    end

    action = string.lower(action)
    if not item then return end
    local name = item.name
    if action == "use" then
        lia.log.add(client, "itemUse", name)
    elseif action == "drop" then
        lia.log.add(client, "itemDrop", name)
    elseif action == "take" then
        lia.log.add(client, "itemTake", name)
    elseif action == "unequip" then
        lia.log.add(client, "itemUnequip", name)
    elseif action == "equip" then
        lia.log.add(client, "itemEquip", name)
    else
        lia.log.add(client, "itemInteraction", action, item)
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

    if item.onCanBeTransfered then
        LiliaDeprecated("onCanBeTransfered is deprecated. Use OnCanBeTransfered for optimization purposes.")
        local itemHook = item:onCanBeTransfered(curInv, inventory)
        return itemHook ~= false
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
            if not otheritem.ignoreEquipCheck and otheritem:getData("equip") == true then
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
    local chatType, message, anonymous = lia.chat.parse(client, message, true)
    if (chatType == "ic") and lia.command.parse(client, message) then return "" end
    if utf8.len(message) <= lia.config.MaxChatLength then
        local isOOC = chatType == "ooc"
        local isLOOC = chatType == "looc"
        lia.chat.send(client, chatType, message, anonymous)
        local logType
        if isOOC then
            logType = "chatOOC"
            lia.log.add(client, logType, message)
        elseif isLOOC then
            logType = "chatLOOC"
            lia.log.add(client, logType, message)
        else
            logType = "chat"
            lia.log.add(client, logType, chatType and chatType:upper() or "??", message)
        end

        hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    else
        client:notify("Your message is too long and has not been sent.")
    end
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

function GM:GetPreferredCarryAngles(entity)
    if entity.preferedAngle then return entity.preferedAngle end
    local class = entity:GetClass()
    if class == "lia_item" then
        local itemTable = entity:getItemTable()
        if itemTable then
            local preferedAngle = itemTable.preferedAngle
            if preferedAngle then return preferedAngle end
        end
    end
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

function GM:PlayerShouldTakeDamage(client)
    return client:getChar() ~= nil
end

function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

function GM:Think()
    if (self.NextDBRefresh or 0) < CurTime() then
        lia.db.query("SELECT 1 + 1", onSuccess)
        self.NextDBRefresh = CurTime() + 10
    end
end

function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not (IsValid(client) or character) then return end
    client:Give("lia_hands")
    client:SetupHands()
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
    hook.Run("PlayerLoadout", client)
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        local charEnts = character:getVar("charEnts") or {}
        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then v:Remove() end
        end

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

function GM:PlayerDeathThink(client)
    if client:getChar() and not client:IsOnDeathTimer() then client:Spawn() end
    return false
end