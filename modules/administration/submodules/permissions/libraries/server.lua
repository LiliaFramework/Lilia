local GM = GM or GAMEMODE
local resetCalled = 0
local restrictedProperties = {
    persist = true,
    drive = true,
    bonemanipulate = true
}

function GM:PlayerSpawnProp(client, model)
    local list = lia.data.get("blacklist", {}, true, true)
    if table.HasValue(list, model) and not client:hasPrivilege("Spawn Permissions - Can Spawn Blacklisted Props") then
        client:notifyLocalized("blacklistedProp")
        return false
    end

    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Props") or client:getChar():hasFlags("e")
    if not canSpawn then client:notifyLocalized("noSpawnPropsPerm") end
    return canSpawn
end

function GM:CanProperty(client, property, entity)
    if restrictedProperties[property] then
        client:notifyLocalized("disabledFeature")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then
        if client:hasPrivilege("Staff Permissions - Can Property World Entities") then return true end
        client:notifyLocalized("noModifyWorldEntities")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if client:IsSuperAdmin() or client:hasPrivilege("Staff Permissions - Access Property " .. property:gsub("^%l", string.upper)) and client:isStaffOnDuty() then return true end
    client:notifyLocalized("noModifyProperty")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:isNoClipping() then return false end
end

function GM:PhysgunPickup(client, entity)
    if (client:hasPrivilege("Staff Permissions - Physgun Pickup") or client:isStaffOnDuty()) and entity.NoPhysgun then
        if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Restricted Entities") then
            client:notifyLocalized("noPickupRestricted")
            return false
        end
        return true
    end

    if client:IsSuperAdmin() then return true end
    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:hasPrivilege("Staff Permissions - Physgun Pickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("Staff Permissions - Physgun Pickup on Vehicles") then
                client:notifyLocalized("noPickupVehicles")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("Staff Permissions - Can't be Grabbed with PhysGun") or not client:hasPrivilege("Staff Permissions - Can Grab Players") then
                client:notifyLocalized("noPickupPlayer")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("Staff Permissions - Can Grab World Props") then
                client:notifyLocalized("noPickupWorld")
                return false
            end
            return true
        end
        return true
    end

    client:notifyLocalized("noPickupEntity")
    return false
end

function GM:PlayerSpawnVehicle(client, model)
    if not client:hasPrivilege("Spawn Permissions - No Car Spawn Delay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local list = lia.data.get("carBlacklist", {}, true, true)
    if model and table.HasValue(list, model) and not client:hasPrivilege("Spawn Permissions - Can Spawn Blacklisted Cars") then
        client:notifyLocalized("blacklistedVehicle")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Cars") or client:getChar():hasFlags("C")
    if not canSpawn then client:notifyLocalized("noSpawnVehicles") end
    return canSpawn
end

function GM:PlayerNoClip(ply, enabled)
    if not (ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")) then
        ply:notifyLocalized("noNoclip")
        return false
    end

    ply:DrawShadow(not enabled)
    ply:SetNoTarget(enabled)
    ply:AddFlags(FL_NOTARGET)
    hook.Run("OnPlayerObserve", ply, enabled)
    return true
end

function GM:PlayerSpawnEffect(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Effects") or client:getChar():hasFlags("L")
    if not canSpawn then client:notifyLocalized("noSpawnEffects") end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn NPCs") or client:getChar():hasFlags("n")
    if not canSpawn then client:notifyLocalized("noSpawnNPCs") end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Ragdolls") or client:getChar():hasFlags("r")
    if not canSpawn then client:notifyLocalized("noSpawnRagdolls") end
    return canSpawn
end

function GM:PlayerSpawnSENT(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SENTs") or client:getChar():hasFlags("E")
    if not canSpawn then client:notifyLocalized("noSpawnSents") end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client)
    local canSpawn = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("z")
    if not canSpawn then client:notifyLocalized("noSpawnSweps") end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("W")
    if not canGive then client:notifyLocalized("noGiveSweps") end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("Staff Permissions - Can Physgun Reload")
    if not canReload then client:notifyLocalized("noPhysgunReload") end
    return canReload
end

local DisallowedTools = {
    rope = true,
    light = true,
    lamp = true,
    dynamite = true,
    physprop = true,
    faceposer = true,
    stacker = true
}

function GM:CanTool(client, _, tool)
    local function CheckDuplicationScale(ply, entities)
        entities = entities or {}
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                ply:notifyLocalized("duplicationSizeLimit")
                lia.log.add(ply, "dupeCrashAttempt")
                return false
            end

            v.ModelScale = 1
        end
        return true
    end

    if DisallowedTools[tool] and not client:IsSuperAdmin() then
        client:notifyLocalized("toolNotAllowed", tool)
        return false
    end

    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local isSuperAdmin = client:IsSuperAdmin()
    local isStaffOrFlagged = client:isStaffOnDuty() or client:getChar():hasFlags("t")
    local hasPriv = client:hasPrivilege(privilege)
    if not isSuperAdmin and not (isStaffOrFlagged and hasPriv) then
        local reasons = {}
        if not isSuperAdmin then table.insert(reasons, "SuperAdmin") end
        if not isStaffOrFlagged then table.insert(reasons, "On-duty staff or flag 't'") end
        if not hasPriv then table.insert(reasons, "Privilege '" .. privilege .. "'") end
        client:notifyLocalized("toolNoPermission", tool, table.concat(reasons, ", "))
        return false
    end

    local entity = client:getTracedEntity()
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if entity.NoRemover then
                if not client:hasPrivilege("Staff Permissions - Can Remove Blocked Entities") then
                    client:notifyLocalized("noRemoveBlockedEntities")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("Staff Permissions - Can Remove World Entities") then
                    client:notifyLocalized("noRemoveWorldEntities")
                    return false
                end
                return true
            end
            return true
        end

        if (tool == "permaall" or tool == "blacklistandremove") and hook.Run("CanPersistEntity", entity) ~= false and (string.StartWith(entClass, "lia_") or entity:isLiliaPersistent() or entity:CreatedByMap()) then
            client:notifyLocalized("toolCantUseEntity", tool)
            return false
        end

        if (tool == "duplicator" or tool == "blacklistandremove") and entity.NoDuplicate then
            client:notifyLocalized("cannotDuplicateEntity", tool)
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            client:notifyLocalized("cannotWeldBall")
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    return true
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
    entity:SetCreator(client)
end

function GM:CanPlayerUseChar(client)
    if GetGlobalBool("characterSwapLock", false) and not client:hasPrivilege("Staff Permissions - Can Bypass Character Lock") then return false, "Currently the server is in an event and you're unable to change characters." end
end

concommand.Add("kickbots", function()
    for _, bot in player.Iterator() do
        if bot:IsBot() then lia.command.execAdminCommand("kick", nil, bot, nil, "All bots kicked") end
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

local function handleDatabaseWipe(commandName)
    concommand.Add(commandName, function(client)
        if IsValid(client) then
            client:notifyLocalized("commandConsoleOnly")
            return
        end

        if resetCalled < RealTime() then
            resetCalled = RealTime() + 3
            MsgC(Color(255, 0, 0), "[Lilia] TO CONFIRM DATABASE RESET, RUN '" .. commandName .. "' AGAIN in 3 SECONDS.\n")
        else
            resetCalled = 0
            MsgC(Color(255, 0, 0), "[Lilia] DATABASE WIPE IN PROGRESS.\n")
            hook.Run("OnWipeTables")
            lia.db.wipeTables(lia.db.loadTables)
            game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
        end
    end)
end

handleDatabaseWipe("lia_recreatedb")
handleDatabaseWipe("lia_wipedb")

concommand.Add("lia_convertconfig", function(client)
    if IsValid(client) then
        client:notifyLocalized("commandConsoleOnly")
        return
    end

    lia.config.convertToDatabase(true)
end)

concommand.Add("lia_convertlogs", function(client)
    if IsValid(client) then
        client:notifyLocalized("commandConsoleOnly")
        return
    end

    lia.log.convertToDatabase(true)
end)

concommand.Add("lia_convertdata", function(client)
    if IsValid(client) then
        client:notifyLocalized("commandConsoleOnly")
        return
    end

    lia.data.convertToDatabase(true)
end)
