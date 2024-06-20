function GAMEMODE:PlayerSpawnEffect(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Effects", nil)) or client:getChar():hasFlags("L")
end

function GAMEMODE:PlayerSpawnNPC(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn NPCs", nil)) or client:getChar():hasFlags("n")
end

function GAMEMODE:PlayerSpawnProp(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Props", nil)) or client:getChar():hasFlags("e")
end

function GAMEMODE:PlayerSpawnRagdoll(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Ragdolls", nil)) or client:getChar():hasFlags("r")
end

function GAMEMODE:PlayerSpawnSENT(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SENTs", nil)) or client:getChar():hasFlags("E")
end

function GAMEMODE:PlayerSpawnSWEP(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil)) or client:getChar():hasFlags("z")
end

function GAMEMODE:PlayerSpawnVehicle(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Cars", nil)) or client:getChar():hasFlags("C")
end

function GAMEMODE:PlayerGiveSWEP(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil)) or client:getChar():hasFlags("W")
end

function GAMEMODE:PlayerNoClip(client)
    return (not client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Staff Permissions - No Clip Outside Staff Character", nil)) or client:isStaffOnDuty()
end

function GAMEMODE:OnPhysgunReload(_, client)
    return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Physgun Reload", nil)
end

function GAMEMODE:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    return (client:isStaffOnDuty() or client:getChar():hasFlags("t")) and CAMI.PlayerHasAccess(client, privilege, nil)
end

function GAMEMODE:CanProperty(client, property, entity)
    return (entity:GetCreator() == client and (property == "remover" or property == "collision")) or (CAMI.PlayerHasAccess(client, "Staff Permissions - Access Property " .. property:gsub("^%l", string.upper), nil) and client:isStaffOnDuty())
end

function GAMEMODE:PlayerSpawnObject(client)
    if not client.NextSpawn then client.NextSpawn = CurTime() end
    if CAMI.PlayerHasAccess(client, "Spawn Permissions - No Spawn Delay", nil) then return true end
    if client.NextSpawn >= CurTime() then
        client:notify("You can't spawn props that fast!")
        return false
    end

    client.NextSpawn = CurTime() + 0.75
    return true
end

function GAMEMODE:PhysgunPickup(client, entity)
    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if entity:IsVehicle() then
        return CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup on Vehicles", nil)
    elseif entity:IsPlayer() then
        return not CAMI.PlayerHasAccess(entity, "Staff Permissions - Can't be Grabbed with PhysGun", nil) and CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab Players", nil)
    elseif entity:IsWorld() or entity:CreatedByMap() then
        return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab World Props", nil)
    end
    return false
end

function GAMEMODE:PlayerSpawnedNPC(client, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedEffect(client, _, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedProp(client, _, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedRagdoll(client, _, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedSENT(client, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedSWEP(client, entity)
    entity:assignCreator(client)
end

function GAMEMODE:PlayerSpawnedVehicle(client, entity)
    entity:assignCreator(client)
end
