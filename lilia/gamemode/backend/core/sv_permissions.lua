--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnNPC(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn NPCs", nil) or client:getChar():hasFlags("n") or client:getChar():hasFlags("E") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnProp(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Props", nil) or client:getChar():hasFlags("e") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnRagdoll(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Ragdolls", nil) or client:getChar():hasFlags("r") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSWEP(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("W") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnEffect(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Effects", nil) or client:getChar():hasFlags("n") or client:getChar():hasFlags("E") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSENT(client)
    if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn SENTs", nil) or client:getChar():hasFlags("E") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnVehicle(client, model, name, data)
    if client:getChar():hasFlags("C") or CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Cars", nil) then
        if table.HasValue(lia.config.RestrictedVehicles, name) then
            if CAMI.PlayerHasAccess(client, "Lilia - Spawn Permissions - Can Spawn Restricted Cars", nil) then
                return true
            else
                client:notify("You can't spawn this vehicle since it's restricted!")
            end
        else
            return true
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanTool(client, trace, tool)
    local privilege = "Lilia - Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    if IsValid(entity) and (client:getChar():hasFlags("t") or CAMI.PlayerHasAccess(client, privilege, nil)) then
        if tool == "permaprops" and not string.StartWith(entity:GetClass(), "lia_") or (tool == "advdupe2" and not table.HasValue(lia.config.DuplicatorBlackList, entity:GetClass())) then return true end
        if tool == "remover" and table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Can Remove Blocked Entities", nil) end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PhysgunPickup(client, entity)
    if entity:GetCreator() == client and entity:GetClass() == "prop_physics" then
        return true
    elseif CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup", nil) then
        if table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup on Restricted Entities", nil)
        elseif entity:IsVehicle() then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Physgun Pickup on Vehicles", nil)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanProperty(client, property, entity)
    if CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Access Tool " .. property:gsub("^%l", string.upper), nil) then
        if table.HasValue(lia.config.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(lia.config.PhysGunMoveRestrictedEntityList, entity:GetClass()) then
            return CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - Use Entity Properties on Blocked Entities", nil)
        else
            return true
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------