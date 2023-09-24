--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnNPC(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn NPCs", nil) then return true end

    return client:getChar():hasFlags("n") or client:getChar():hasFlags("E")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnProp(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn Props", nil) then return true end
    if FindMetaTable("Player").GetLimit then
        local limit = client:GetLimit("props")
        if limit < 0 then return end
        local props = client:GetCount("props") + 1
        if client:getLiliaData("extraProps") then
            if props > (limit + 50) then
                client:LimitHit("props")

                return false
            end
        else
            if props > limit then
                client:LimitHit("props")

                return false
            end
        end
    end

    return client:IsAdmin() or client:getChar():hasFlags("e")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnRagdoll(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn Ragdolls", nil) then return true end
    if FindMetaTable("Player").GetLimit then
        local limit = ply:GetLimit("ragdolls")
        if limit < 0 then return end
        local ragdolls = ply:GetCount("ragdolls") + 1
        if ragdolls > limit then
            ply:LimitHit("ragdolls")

            return false
        end
    end

    return client:getChar():hasFlags("r")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSWEP(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn SWEPs", nil) then return true end

    return client:getChar():hasFlags("W")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnEffect(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn Effects", nil) then return true end

    return client:getChar():hasFlags("n") or client:getChar():hasFlags("E")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSENT(client)
    if not client:getChar() then return false end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn SENTs", nil) then return true end

    return client:getChar():hasFlags("E")
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnVehicle(client, model, name, data)
    if not client:getChar() then return false end
    if table.HasValue(lia.config.RestrictedVehicles, name) then
        ply:notify("You can't spawn this vehicle since it's restricted!")

        return CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn Restricted Cars", nil)
    else
        return client:getChar():hasFlags("C") or CAMI.PlayerHasAccess(client, "Lilia - Management - Can Spawn Cars", nil)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CanTool(client, trace, tool)
    local privilege = "Lilia - Management - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    if not client:getChar() then return false end
    if not client:getChar():hasFlags("t") then return false end
    if toolname == "permaprops" and IsValid(entity) and string.StartWith(entity:GetClass(), "lia_") then return false end
    if tool == "advdupe2" and table.HasValue(lia.config.DuplicatorBlackList, entity:GetClass()) then return false end
    if tool == "remover" and table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Lilia - Management - Can Remove Blocked Entities", nil) end
    if CAMI.PlayerHasAccess(client, privilege, nil) then return true end
end
--------------------------------------------------------------------------------------------------------
function GM:PhysgunPickup(client, entity)
    if not client:getChar() then return false end
    if client:IsSuperAdmin() then return true end
    if entity:GetCreator() == client and entity:GetClass() == "prop_physics" then return true end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Physgun Pickup", nil) then
        if table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then
            if CAMI.PlayerHasAccess(client, "Lilia - Management - Physgun Pickup on Restricted Entities", nil) then
                return true
            else
                return false
            end
        elseif entity:IsVehicle() then
            if CAMI.PlayerHasAccess(client, "Lilia - Management - Physgun Pickup on Vehicles", nil) then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CanProperty(client, property, entity)
    if not client:getChar() then return false end
    if client:IsSuperAdmin() then return true end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Access Tool " .. property:gsub("^%l", string.upper), nil) then
        if table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then
            return CAMI.PlayerHasAccess(client, "Lilia - Management - Use Entity Properties on Blocked Entities", nil)
        else
            return true
        end
    else
        return false
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerCheckLimit(ply, name)
    if FindMetaTable("Player").GetLimit then
        if name == "props" then
            if ply:GetLimit("props") < 0 then return end
            if ply:getLiliaData("extraProps") then
                local limit = ply:GetLimit("props") + 50
                local props = ply:GetCount("props")
                if props <= limit + 50 then return true end
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------