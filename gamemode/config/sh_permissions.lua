--------------------------------------------------------------------------------------------------------
function lia.config.LoadPermissions()
    lia.config.CustomPermissions = false
    lia.config.PermissionTable = {
        ["PlayerSpawnNPC"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E")) end,
        },
        ["PlayerSpawnProp"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsAdmin() or client:getChar():hasFlags("e") end,
        },
        ["PlayerSpawnRagdoll"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsAdmin() or client:getChar():hasFlags("r") end,
        },
        ["PlayerSpawnSWEP"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsSuperAdmin() or client:getChar():hasFlags("W") end,
        },
        ["PlayerSpawnEffect"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E")) end,
        },
        ["PlayerSpawnSENT"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client) return client:IsAdmin() or client:getChar():hasFlags("E") end,
        },
        ["PlayerSpawnVehicle"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client, model, name, data)
                if client:IsSuperAdmin() then return true end
                if table.HasValue(lia.config.RestrictedVehicles, name) then
                    ply:notify("You can't spawn this vehicle since it's restricted!")
                    return false
                else
                    if data.Category == "Chairs" then
                        return client:getChar():hasFlags("c")
                    else
                        return client:getChar():hasFlags("C")
                    end
                end
                return false
            end,
        },
    }
end
--------------------------------------------------------------------------------------------------------