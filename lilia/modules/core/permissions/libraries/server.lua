local GM = GM or GAMEMODE

function GM:PlayerSpawnEffect(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Effects", nil) or client:getChar():hasFlags("L")
end

function GM:PlayerSpawnNPC(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn NPCs", nil) or client:getChar():hasFlags("n")
end

function GM:PlayerSpawnProp(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Props", nil) or client:getChar():hasFlags("e")
end

function GM:PlayerSpawnRagdoll(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Ragdolls", nil) or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnSENT(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SENTs", nil) or client:getChar():hasFlags("E")
end

function GM:PlayerSpawnSWEP(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("z")
end

function GM:PlayerSpawnVehicle(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Cars", nil) or client:getChar():hasFlags("C")
end

function GM:PlayerGiveSWEP(client)
    return client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("W")
end

function GM:PlayerNoClip(client)
    return (not client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Staff Permissions - No Clip Outside Staff Character", nil)) or client:isStaffOnDuty()
end

function GM:OnPhysgunReload(_, client)
    return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Physgun Reload", nil)
end

function GM:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    return (client:isStaffOnDuty() or client:getChar():hasFlags("t")) and CAMI.PlayerHasAccess(client, privilege, nil)
end

function GM:CanProperty(client, property, entity)
    return (entity:GetCreator() == client and (property == "remover" or property == "collision")) or (CAMI.PlayerHasAccess(client, "Staff Permissions - Access Property " .. property:gsub("^%l", string.upper), nil) and client:isStaffOnDuty())
end

function GM:PlayerSpawnObject(client)
    if not client.NextSpawn then client.NextSpawn = CurTime() end
    if CAMI.PlayerHasAccess(client, "Spawn Permissions - No Spawn Delay", nil) then return true end
    if client.NextSpawn >= CurTime() then
        client:notify("You can't spawn props that fast!")
        return false
    end

    client.NextSpawn = CurTime() + 0.75
    return true
end

function GM:PhysgunPickup(client, entity)
    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup", nil) then
        if entity:IsVehicle() then
            return CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup on Vehicles", nil)
        elseif entity:IsPlayer() then
            return not CAMI.PlayerHasAccess(entity, "Staff Permissions - Can't be Grabbed with PhysGun", nil) and CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab Players", nil)
        elseif entity:IsWorld() or entity:CreatedByMap() then
            return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab World Props", nil)
        end
        return true
    end
    return false
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
    entity:assignCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
    entity:assignCreator(client)
end