--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnNPC(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn NPCs", nil) or client:getChar():hasFlags("n") then return true end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnProp(client, model)
    if not client then return true end
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Props", nil) or client:getChar():hasFlags("e") or client:Team() == FACTION_STAFF then
        if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - No Spawn Delay") or (client.AdvDupe2 and client.AdvDupe2.Pasting) then return true end

        return self:CheckSpawnPropBlackList(client, model)
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnRagdoll(client)
    if not client then return true end
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Ragdolls", nil) or client:getChar():hasFlags("r") or client:Team() == FACTION_STAFF then
        if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - No Spawn Delay") or (client.AdvDupe2 and client.AdvDupe2.Pasting) then return true end

        return true
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("z") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerGiveSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("W") then return true end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnEffect(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Effects", nil) or client:getChar():hasFlags("L") then return true end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSENT(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn SENTs", nil) or client:getChar():hasFlags("E") then return true end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnVehicle(client, model, name, data)
    if IsValid(client) and client:getChar():hasFlags("C") or CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Cars", nil) then
        if table.HasValue(lia.config.RestrictedVehicles, name) then
            if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Restricted Cars", nil) then
                return true
            else
                client:notify("You can't spawn this vehicle since it's restricted!")

                return false
            end
        end

        return true
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanTool(client, trace, tool)
    local privilege = "Lilia - Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    if IsValid(client) and client:getChar():hasFlags("t") or CAMI.PlayerHasAccess(client, privilege, nil) or client:Team() == FACTION_STAFF then
        if IsValid(entity) and entity:GetCreator() == client and entity:GetClass() == "prop_physics" then return true end
        if tool == "advdupe2" and (table.HasValue(lia.config.DuplicatorBlackList, entity) and IsValid(entity)) then return false end
        if tool == "permaprops" and string.StartWith(entity:GetClass(), "lia_") and IsValid(entity) then return false end
        if tool == "remover" then
            if table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Remove Blocked Entities", nil) end
            if entity:IsWorld() and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Remove World Entities", nil) end

            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PhysgunPickup(client, entity)
    if IsValid(client) and entity:GetCreator() == client and entity:GetClass() == "prop_physics" then return true end
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup", nil) or client:Team() == FACTION_STAFF then
        if table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup on Restricted Entities", nil)
        elseif entity:IsVehicle() then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup on Vehicles", nil)
        elseif entity:IsPlayer() then
            return CAMI.PlayerHasAccess(entity, "Lilia - Staff Permissions - Can't be Grabbed with PhysGun", nil) and CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Grab Players", nil)
        elseif entity:IsWorld() then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Grab World Props", nil)
        end

        return true
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanProperty(client, property, entity)
    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Access Tool " .. property:gsub("^%l", string.upper), nil) or client:Team() == FACTION_STAFF then
        if entity:IsWorld() and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Property World Entities", nil) end
        if table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Use Entity Properties on Blocked Entities", nil) end

        return true
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CheckSpawnPropBlackList(client, model)
    for _, gredwitch in pairs(file.Find("models/gredwitch/bombs/*.mdl", "GAME")) do
        if model == "models/gredwitch/bombs/" .. gredwitch then return false end
    end

    for _, gbombs in pairs(file.Find("models/gbombs/*.mdl", "GAME")) do
        if model == "models/gbombs/" .. gbombs then return false end
    end

    for _, phx in pairs(file.Find("models/props_phx/*.mdl", "GAME")) do
        if model == "models/props_phx/" .. phx then return false end
    end

    for _, mikeprops in pairs(file.Find("models/mikeprops/*.mdl", "GAME")) do
        if model == "models/mikeprops/" .. mikeprops then return false end
    end

    if table.HasValue(lia.config.BlackListedProps, model:lower()) then return false end

    return true
end

--------------------------------------------------------------------------------------------------------------------------
if sam then
    sam.config.set("Restrictions.Tool", false)
    sam.config.set("Restrictions.Limits", false)
    sam.config.set("Restrictions.Spawning", false)
end
--------------------------------------------------------------------------------------------------------------------------