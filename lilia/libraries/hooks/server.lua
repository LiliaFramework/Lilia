---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local GM = GM or GAMEMODE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local defaultAngleData = {
    ["models/items/car_battery01.mdl"] = Angle(-15, 180, 0),
    ["models/props_junk/harpoon002a.mdl"] = Angle(0, 0, 0),
    ["models/props_junk/propane_tank001a.mdl"] = Angle(-90, 0, 0),
}

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PrePlayerLoadedChar(client, _, _)
    client:SetBodyGroups("000000000")
    client:SetSkin(0)
    client:ExitVehicle()
    client:Freeze(false)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CreateDefaultInventory(character)
    local charID = character:getID()
    if lia.inventory.types["grid"] then
        return lia.inventory.instance("grid", {
            char = charID
        })
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CharacterPreSave(character)
    local client = character:getPlayer()
    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.onSave then v:call("onSave", client) end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    character:setData("loginTime", os.time())
    hook.Run("PlayerLoadout", client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CharacterLoaded(id)
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnCharFallover(client, entity, bFallenOver)
    bFallenOver = bFallenOver or false
    if IsValid(entity) then
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
        entity:SetCustomCollisionCheck(false)
    end

    client:setNetVar("fallingover", bFallenOver)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

    if not item then return end
    lia.log.add(client, "itemUse", action, item)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerSay(client, message)
    local chatType, message, anonymous = lia.chat.parse(client, message, true)
    if (chatType == "ic") and lia.command.parse(client, message) then return "" end
    if utf8.len(message) <= lia.config.MaxChatLength then
        lia.chat.send(client, chatType, message, anonymous)
        lia.log.add(client, "chat", chatType and chatType:upper() or "??", message)
        hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    else
        client:notify("Your message is too long and has not been sent.")
    end
    return ""
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:GetGameDescription()
    if lia.config.GamemodeName ~= "A Lilia Gamemode" then
        return lia.config.GamemodeName
    else
        if istable(SCHEMA) then return tostring(SCHEMA.name) end
    end
    return lia.config.GamemodeName
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerSpawn(client)
    client:SetNoDraw(false)
    client:UnLock()
    client:SetNotSolid(false)
    client:setAction()
    hook.Run("PlayerLoadout", client)
    for i = 0, client:GetBoneCount() - 1 do
        client:ManipulateBoneAngles(client:LookupBone(client:GetBoneName(i)), Angle(0, 0, 0))
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerDeathThink()
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:KeyPress(client, key)
    if key == IN_ATTACK2 and IsValid(client.Grabbed) then
        client:DropObject(client.Grabbed)
        client.Grabbed = NULL
    elseif key == IN_USE then
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:KeyRelease(client, key)
    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then wep:Grab() end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:EntityNetworkedVarChanged(entity, varName, _, newVal)
    if varName == "Model" and entity.SetModel then hook.Run("PlayerModelChanged", entity, newVal) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerUse(client, _)
    if client:getNetVar("handcuffed") then return false end
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
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

        character.isBot = true
        character.vars.inv = {}
        inventory.id = "bot" .. character:getID()
        character.vars.inv[1] = inventory
        lia.inventory.instances[inventory.id] = inventory
        lia.char.loaded[botID] = character
        character:setup()
        client:Spawn()
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
    hook.Run("ClassOnLoadout", client)
    hook.Run("FactionOnLoadout", client)
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not (IsValid(client) or character) then return end
    client:Give("lia_hands")
    client:SetupHands()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
        lia.log.add(client, "playerDisconnected")
    end

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    lia.char.cleanUpForPlayer(client)
    for _, entity in pairs(ents.GetAll()) do
        if entity:GetCreator() == client then entity:Remove() end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerAuthed(client, steamID)
    lia.log.add(client, "playerConnected", client, steamID)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerHurt(client, attacker, health, damage)
    lia.log.add(client, "playerHurt", attacker:IsPlayer() and attacker:Name() or attacker:GetClass(), damage, health)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerDeath(client, _, _)
    local char = client:getChar()
    if not char then return end
    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
        client:setLocalVar("blur", nil)
    end
end

hook.Add("KeyPress", "OverrideRespawn", function(ply, key)
    if key == IN_JUMP and ply:Alive() then
        -- Perform your custom respawn logic here
        -- For example, you can prevent the respawn or trigger a different respawn method
        return true -- Returning true will prevent the default action (respawning)
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnServerLog(client, logType, ...)
    for _, v in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", v, logType) ~= false then lia.log.send(v, lia.log.getString(client, logType, ...)) end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:Move(client, moveData)
    local char = client:getChar()
    if not char then return end
    if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
        local mf, ms = 0, 0
        local speed = client:GetWalkSpeed()
        local ratio = lia.config.WalkRatio
        if moveData:KeyDown(IN_FORWARD) then
            mf = ratio
        elseif moveData:KeyDown(IN_BACK) then
            mf = -ratio
        end

        if moveData:KeyDown(IN_MOVELEFT) then
            ms = -ratio
        elseif moveData:KeyDown(IN_MOVERIGHT) then
            ms = ratio
        end

        moveData:SetForwardSpeed(mf * speed)
        moveData:SetSideSpeed(ms * speed)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:InitPostEntity()
    if SERVER then
        lia.faction.formatModelData()
        timer.Simple(2, function() lia.entityDataLoaded = true end)
        lia.db.waitForTablesToLoad():next(function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end)
    else
        lia.joinTime = RealTime() - 0.9716
        if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
        for command, value in pairs(lia.config.StartupConsoleCommands) do
            local client_command = command .. " " .. value
            if concommand.GetTable()[command] ~= nil then
                LocalPlayer():ConCommand(client_command)
                print(string.format("Executed console command on client: %s", client_command))
            end
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanDrive(client)
    if not client:IsSuperAdmin() then return false end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerSpray(_)
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerDeathSound()
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:CanPlayerSuicide(_)
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:AllowPlayerPickup(_, _)
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:PlayerShouldTakeDamage(client, _)
    return client:getChar() ~= nil
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------