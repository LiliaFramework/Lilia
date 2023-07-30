------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnNPC(client, npcType, weapon)
    return client:IsAdmin() or client:getChar():hasFlags("n")
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnSWEP(client, weapon, info)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnProp(client)
    if client:getChar() and client:getChar():hasFlags("e") then return true end

    return false
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnRagdoll(client)
    if client:getChar() and client:getChar():hasFlags("r") then return true end

    return false
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerGiveSWEP(client, class, swep)
    return client:IsSuperAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnEffect(client, model)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnSENT(client, class)
    return client:IsAdmin()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnVehicle(client, model, name, data)
    if client:getChar() then
        if data.Category == "Chairs" then
            return client:getChar():hasFlags("c")
        else
            return client:getChar():hasFlags("C")
        end
    end

    return false
end