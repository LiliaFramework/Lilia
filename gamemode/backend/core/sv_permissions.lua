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
    local entity = trace.Entity
    if not client:getChar() then return end

    if lia.config.CustomToolAccess then
        local permission = lia.config.CustomToolAccessTable[tool]

        if permission.IsSuperAdmin and client:IsSuperAdmin() then
            if permission.ExtraCheck and type(permission.ExtraCheck) == "function" then
                if permission.ExtraCheck(client, trace, tool, entity) then
                    return true
                else
                    client:ChatPrint("You don't have permission to use this tool.")

                    return false
                end
            end
        elseif table.HasValue(permission.ToolAllowedUsergroup, client:GetUserGroup()) then
            return true
        elseif table.HasValue(lia.config.DisallowedTools, tool) then
            return false
        elseif permission.IsAdmin and client:IsAdmin() then
            if permission.ExtraCheck(client, trace, tool, entity) then
                return true
            else
                client:ChatPrint("You don't have permission to use this tool.")

                return false
            end
        elseif permission.ToolAllowedUsergroup and table.HasValue(permission.ToolAllowedUsergroup, client:GetUserGroup()) then
            if permission.ExtraCheck(client, trace, tool, entity) then
                return true
            else
                client:ChatPrint("You don't have permission to use this tool.")

                return false
            end
        else
            client:ChatPrint("You don't have permission to spawn NPCs.")

            return false
        end
    else
        return client:getChar():hasFlags("t") or client:IsSuperAdmin()
    end
end
--------------------------------------------------------------------------------------------------------
function GM:PhysgunPickup(client, entity)
    if client:IsSuperAdmin() then
        return true
    else
        if table.HasValue(lia.config.RestrictedEntityList, entity:GetClass()) then
            return false
        elseif entity:GetCreator() == client and entity:GetClass() == "prop_physics" then
            return true
        elseif client:Team() == FACTION_STAFF or client:IsAdmin() then
            return true
        elseif entity:IsVehicle() then
            return false
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CanProperty(client, property, entity)
    if not client:getChar() then return end
    if client:IsSuperAdmin() then return true end
    if table.HasValue(lia.config.BlockedProperties, property) and table.HasValue("stamina", entity:GetClass()) then return false end

    return not table.HasValue(lia.config.BlockedProperties, property)
end
--------------------------------------------------------------------------------------------------------