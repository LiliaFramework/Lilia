function lia.config.load_permissions()
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
                if data.Category == "Chairs" then
                    return client:getChar():hasFlags("c") or client:IsSuperAdmin()
                else
                    return client:getChar():hasFlags("C") or client:IsSuperAdmin()
                end
                return false
            end,
        },
    }
end