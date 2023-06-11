------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnNPC(client, npcType, weapon)
    return client:IsAdmin() or client:getChar():hasFlags("n")
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnSWEP(client, weapon, info)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnProp(client)
    if client:getChar() and client:getChar():hasFlags("e") then return true end

    return false
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnRagdoll(client)
    if client:getChar() and client:getChar():hasFlags("r") then return true end

    return false
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerGiveSWEP(client, class, swep)
    return client:IsSuperAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnEffect(client, model)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnSENT(client, class)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PLUGIN:PlayerSpawnVehicle(client, model, name, data)
    if client:getChar() then
        if data.Category == "Chairs" then
            return client:getChar():hasFlags("c")
        else
            return client:getChar():hasFlags("C")
        end
    end

    return false
end