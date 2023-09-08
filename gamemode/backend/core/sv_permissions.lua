--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnNPC(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnNPC"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn NPCs.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn NPCs.")

            return false
        end
    else
        return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E"))
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnProp(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnProp"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn Props.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn Props.")

            return false
        end
    else
        return client:IsAdmin() or client:getChar():hasFlags("e")
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnRagdoll(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnRagdoll"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn Ragdolls.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn Ragdolls.")

            return false
        end
    else
        return client:IsAdmin() or client:getChar():hasFlags("r")
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSWEP(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnSWEP"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn SWEPs.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn SWEPs.")

            return false
        end
    else
        return client:IsSuperAdmin() or client:getChar():hasFlags("W")
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnEffect(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnEffect"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn Effects.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn Effects.")

            return false
        end
    else
        return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E"))
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnSENT(client)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnSENT"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn SENTs.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn SENTs.")

            return false
        end
    else
        return client:IsAdmin() or client:getChar():hasFlags("E")
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnVehicle(client, model, name, data)
    if not client:getChar() then return end
    if lia.config.CustomPermissions then
        local permission = lia.config.PermissionTable["PlayerSpawnVehicle"]
        if permission.IsAdmin and client:IsAdmin() then
            return true
        elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
            return true
        elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
            if permission.CustomCheck(client, data) then
                return true
            else
                client:ChatPrint("You don't have permission to spawn Vehicles.")

                return false
            end
        else
            if data.Category == "Chairs" then
                return client:getChar():hasFlags("c") or client:IsSuperAdmin()
            else
                return client:getChar():hasFlags("C") or client:IsSuperAdmin()
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function GM:CanTool(client, trace, tool)
    local privilege = "Lilia - Management - Access Tool " .. tool:gsub("^%l", string.upper)
    if not client:getChar() then return false end
    if not client:getChar():hasFlags("t") then return false end
    if CAMI.PlayerHasAccess(client, privilege, nil) then return true end
end

--------------------------------------------------------------------------------------------------------
function GM:PhysgunPickup(client, entity)
    if not client:getChar() then return false end
    if client:IsSuperAdmin() then return true end
    if entity:GetCreator() == client and entity:GetClass() == "prop_physics" then return true end
    if CAMI.PlayerHasAccess(client, "Lilia - Management - Physgun Pickup", nil) then
        if table.HasValue(lia.config.RestrictedEntityList, entity:GetClass()) then
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
    if table.HasValue(lia.config.BlockedProperties, property) and table.HasValue("stamina", entity:GetClass()) then return false end

    return not table.HasValue(lia.config.BlockedProperties, property)
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