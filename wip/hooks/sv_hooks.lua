function GM:EntityNetworkedVarChanged(entity, varName, oldVal, newVal)
    if varName == "Model" and entity.SetModel then
        hook.Run("PlayerModelChanged", entity, newVal)
    end
end

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
    if not invType then return end
    local inventory = lia.inventory.new(invType)
    inventory.id = "bot" .. character:getID()
    character.vars.inv[1] = inventory
    lia.inventory.instances[inventory.id] = inventory
end

function GM:PlayerInitialSpawn(client)
    client.liaJoinTime = RealTime()
    if client:IsBot() then return hook.Run("SetupBotCharacter", client) end

    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        netstream.Start(client, "liaDataSync", data, client.firstJoin, client.lastJoin)

        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then
                v:sync(client)
            end
        end

        hook.Run("PlayerLiliaDataLoaded", client)
    end)

    hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerUse(client, entity)
    if client:getNetVar("restricted") then return false end

    if entity:isDoor() then
        local result = hook.Run("CanPlayerUseDoor", client, entity)

        if result == false then
            return false
        else
            result = hook.Run("PlayerUseDoor", client, entity)
            if result ~= nil then return result end
        end
    end

    return true
end

function GM:KeyPress(client, key)
    if key == IN_USE then
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local entity = util.TraceLine(data).Entity

        if IsValid(entity) and entity:isDoor() or entity:IsPlayer() then
            hook.Run("PlayerUse", client, entity)
        end
    end
end

function GM:KeyRelease(client, key)
    if key == IN_RELOAD then
        timer.Remove("liaToggleRaise" .. client:SteamID())
    end
end

function GM:CanPlayerDropItem(client, item)
    if item.isBag then
        local inventory = item:getInv()

        if inventory then
            local items = inventory:getItems()

            for _, item in pairs(items) do
                if not item.ignoreEquipCheck and item:getData("equip") == true then
                    client:notifyLocalized("cantDropBagHasEquipped")

                    return false
                end
            end
        end
    end
end

function GM:CanPlayerInteractItem(client, action, item)
    if client:getNetVar("restricted") then return false end
    if action == "drop" and hook.Run("CanPlayerDropItem", client, item) == false then return false end
    if action == "take" and hook.Run("CanPlayerTakeItem", client, item) == false then return false end
    if not client:Alive() or client:getLocalVar("ragdoll") then return false end
end

function GM:CanPlayerTakeItem(client, item)
    if IsValid(item.entity) then
        local char = client:getChar()

        if item.entity.liaSteamID == client:SteamID() and item.entity.liaCharID ~= char:getID() then
            client:notifyLocalized("playerCharBelonging")

            return false
        end
    end
end

function GM:PlayerShouldTakeDamage(client, attacker)
    return client:getChar() ~= nil
end

function GM:EntityTakeDamage(entity, dmgInfo)
    if IsValid(entity.liaPlayer) then
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then
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

function GM:PlayerLoadedChar(client, character, lastChar)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())

    lia.db.updateTable({
        _lastJoinTime = timeStamp
    }, nil, "characters", "_id = " .. character:getID())

    if lastChar then
        local charEnts = lastChar:getVar("charEnts") or {}

        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then
                v:Remove()
            end
        end

        lastChar:setVar("charEnts", nil)
    end

    if character then
        for _, v in pairs(lia.class.list) do
            if (v.faction == client:Team()) and v.isDefault then
                character:setClass(v.index)
                break
            end
        end
    end

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    hook.Run("PlayerLoadout", client)
end

function GM:CharacterLoaded(id)
    local character = lia.char.loaded[id]

    if character then
        local client = character:getPlayer()

        if IsValid(client) then
            local uniqueID = "liaSaveChar" .. client:SteamID()

            timer.Create(uniqueID, lia.config.CharacterSaveInterval, 0, function()
                if IsValid(client) and client:getChar() then
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
    if (chatType == "ic") and lia.command.parse(client, message) then return "" end
    lia.chat.send(client, chatType, message, anonymous)
    hook.Run("PostPlayerSay", client, message, chatType, anonymous)

    return ""
end

function GM:PlayerSpawn(client)
    local character = client:getChar()

    if lia.config.PKActive and character and character:getData("permakilled") then
        character:ban()
    end

    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:setAction()
    hook.Run("PlayerLoadout", client)
end

function GM:PostPlayerLoadout(client)
    local char = client:getChar()

    if char:getInv() then
        for _, item in pairs(char:getInv():getItems()) do
            item:call("onLoadout", client)

            if item:getData("equip") and istable(item.attribBoosts) then
                for attribute, boost in pairs(item.attribBoosts) do
                    char:addBoost(item.uniqueID, attribute, boost)
                end
            end
        end
    end
end

function GM:PlayerDeath(client, inflictor, attacker)
    local char = client:getChar()

    if char then
        if IsValid(client.liaRagdoll) then
            client.liaRagdoll.liaIgnoreDelete = true
            client.liaRagdoll:Remove()
            client:setLocalVar("blur", nil)
        end

        if lia.config.PKActive then
            if not (lia.config.PKWorld and (client == attacker or inflictor:IsWorld())) then return end
            character:setData("permakilled", true)
        end

        char:setData("deathPos", client:GetPos())
        client:setNetVar("deathStartTime", CurTime())
        client:setNetVar("deathTime", CurTime() + lia.config.SpawnTime
    end
end

function GM:PlayerDeathThink(client)
    if client:getChar() then
        local deathTime = client:getNetVar("deathTime")

        if deathTime and deathTime <= CurTime() then
            client:Spawn()
        end
    end

    return false
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()

    if character then
        local charEnts = character:getVar("charEnts") or {}

        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then
                v:Remove()
            end
        end

        hook.Run("OnCharDisconnect", client, character)
        character:save()
    end

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    lia.char.cleanUpForPlayer(client)
end

function GM:InitPostEntity()
    local doors = ents.FindByClass("prop_door_rotating")

    for _, v in ipairs(doors) do
        local parent = v:GetOwner()

        if IsValid(parent) then
            v.liaPartner = parent
            parent.liaPartner = v
        else
            for _, v2 in ipairs(doors) do
                if v2:GetOwner() == v then
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

    lia.db.waitForTablesToLoad():next(function()
        hook.Run("LoadData")
        hook.Run("PostLoadData")
    end)
end

function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")

    for _, v in ipairs(player.GetAll()) do
        v:saveLiliaData()

        if v:getChar() then
            v:getChar():save()
        end
    end
end

function GM:PlayerDeathSound()
    return true
end

function GM:InitializedSchema()
   local persistString = GetConVar("sbox_persist"):GetString()

    if persistString == "" or string.StartWith(persistString, "ns_") then
        local newValue = "ns_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    local allowVoice = lia.config.AllowVoice

    if allowVoice then
        if hook.Run("PlayerCanHearPlayersVoiceTalker", listener, speaker) then
            return true, true
        else
            if hook.Run("PlayerCanHearPlayersVoiceStandingTelephone", listener, speaker) then return true, true end
            if hook.Run("PlayerCanHearPlayersVoicePlacedRadios", listener, speaker) then return true, true end
            if hook.Run("PlayerCanHearPlayersVoiceHook3DVoice", listener, speaker) then return true, true end
            if hook.Run("PlayerCanHearPlayersVoiceHookTying", listener, speaker) then return true, true end
            if hook.Run("PlayerCanHearPlayersVoiceHookRadio", listener, speaker) then return true, true end
        end
    end

    return false, false
end

function GM:OnPhysgunFreeze(weapon, physObj, entity, client)
    if not physObj:IsMoveable() then return false end
    if entity:GetUnFreezable() then return false end
    physObj:EnableMotion(false)

    if entity:GetClass() == "prop_vehicle_jeep" then
        local objects = entity:GetPhysicsObjectCount()

        for i = 0, objects - 1 do
            entity:GetPhysicsObjectNum(i):EnableMotion(false)
        end
    end

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
    lia.shuttingDown = true
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end

function GM:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

function GM:PrePlayerLoadedChar(client, character, lastChar)
    client:SetBodyGroups("000000000")
    client:SetSkin(0)
end

function GM:CharacterPreSave(character)
    local client = character:getPlayer()
    if not character:getInv() then return end

    for _, v in pairs(character:getInv():getItems()) do
        if v.onSave then
            v:call("onSave", client)
        end
    end
end

local defaultAngleData = {
    ["models/items/car_battery01.mdl"] = Angle(-15, 180, 0),
    ["models/props_junk/harpoon002a.mdl"] = Angle(0, 0, 0),
    ["models/props_junk/propane_tank001a.mdl"] = Angle(-90, 0, 0),
}

function GM:GetPreferredCarryAngles(entity)
    if entity.preferedAngle then return entity.preferedAngle end
    local class = entity:GetClass()

    if class == "lia_item" then
        local itemTable = entity:getItemTable()

        if itemTable then
            local preferedAngle = itemTable.preferedAngle
            if preferedAngle then return preferedAngle end
        end
    elseif class == "prop_physics" then
        local model = entity:GetModel():lower()

        return defaultAngleData[model]
    end
end

function GM:CreateDefaultInventory(character)
    local invType = hook.Run("GetDefaultInventoryType", character)
    local charID = character:getID()

    if lia.inventory.types[invType] then
        return lia.inventory.instance(invType, {
            char = charID
        })
    elseif invType ~= nil then
        error("Invalid default inventory type " .. tostring(invType))
    end
end

function GM:ModuleShouldLoad(module)
    return not lia.module.isDisabled(module)
end

function GM:InitializedModules()
    local psaString = "Please Remove Talk Modes. Our framework has such built in by default."

    if TalkModes then
        timer.Simple(2, function()
            MsgC(Color(255, 0, 0), psaString)
        end)
    end
end

function GM:LiliaTablesLoaded()
    local ignore = function() end
    lia.db.query("ALTER TABLE lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
end