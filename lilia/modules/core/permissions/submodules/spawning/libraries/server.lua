local GM = GM or GAMEMODE
function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnNPC(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn NPCs", nil) or client:getChar():hasFlags("n") then return true end
    return false
end

function GM:PlayerSpawnObject(client, _, _)
    if not client.NextSpawn then client.NextSpawn = CurTime() end
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end

    if CAMI.PlayerHasAccess(client, "Spawn Permissions - No Spawn Delay", nil) then return true end
    if client.CurrentDupe and client.CurrentDupe.Entities then return true end
    if client.NextSpawn < CurTime() then
        client.NextSpawn = CurTime() + 0.75
    else
        client:notify("You can't spawn props that fast!")
        return false
    end
    return true
end

function GM:PlayerSpawnRagdoll(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Ragdolls", nil)) or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnProp(client, model)
    local isBlacklistedProp = table.HasValue(PermissionCore.BlackListedProps, model)
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end

    if isBlacklistedProp and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Blacklisted Props", nil) then return false end
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Props", nil)) or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("z") then return true end
end

function GM:PlayerGiveSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("W") then return true end
    return false
end

function GM:PlayerSpawnEffect(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Effects", nil) or client:getChar():hasFlags("L") then return true end
    return false
end

function GM:PlayerSpawnSENT(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SENTs", nil) or client:getChar():hasFlags("E") then return true end
    return false
end

function GM:PlayerSpawnVehicle(client, _, name, _)
    local delay = PermissionCore.PlayerSpawnVehicleDelay
    if IsValid(client) and client:getChar():hasFlags("C") or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Cars", nil) then
        if table.HasValue(PermissionCore.RestrictedVehicles, name) and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Restricted Cars", nil) then
            client:notify("You can't spawn this vehicle since it's restricted!")
            return false
        end

        if not CAMI.PlayerHasAccess(client, "Spawn Permissions - No Car Spawn Delay", nil) then client.NextVehicleSpawn = SysTime() + delay end
        return true
    end
    return false
end

function GM:PlayerSpawnedNPC(client, entity)
    if PermissionCore.NPCsDropWeapons then entity:SetKeyValue("spawnflags", "8192") end
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "NPC", true)
end

function GM:PlayerSpawnedVehicle(client, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Vehicle", true)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Effect", true)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Ragdoll", false)
end

function GM:PlayerSpawnedProp(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Model", false)
    if entity:GetMaterial() and string.lower(entity:GetMaterial()) == "pp/copy" then entity:Remove() end
end

function GM:PlayerSpawnedEntity(client, entity, class, group, hasName)
    local entityName = entity:GetName() or "Unnamed"
    local entityModel = entity:GetModel() or "Unknown Model"
    lia.log.add(client, "spawned_ent", group, class, hasName, entityName, entityModel)
    entity:SetCreator(client)
end