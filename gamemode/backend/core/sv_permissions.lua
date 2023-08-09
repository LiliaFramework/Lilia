function GM:PlayerSpawnNPC(client, npcType, weapon)
    if not client:getChar() then return end

    return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E"))
end

function GM:PlayerSpawnProp(client, model)
    if not client:getChar() then return end

    return client:IsAdmin() or client:getChar():hasFlags("e")
end

function GM:PlayerSpawnRagdoll(client, model)
    if not client:getChar() then return end

    return client:IsAdmin() or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnSENT(client, class)
    if not client:getChar() then return end

    return client:IsAdmin() or client:getChar():hasFlags("E")
end

function GM:PlayerSpawnSWEP(client, class, weapon)
    if not client:getChar() then return end

    return client:IsSuperAdmin() or client:getChar():hasFlags("W")
end

function GM:PlayerSpawnEffect(client, class, weapon)
    if not client:getChar() then return end

    return client:IsAdmin() or (client:getChar():hasFlags("L") or client:getChar():hasFlags("E"))
end

function GM:PlayerSpawnVehicle(client, model, name, vehicleTable)
    if not client:getChar() then return end

    if data.Category == "Chairs" then
        return client:getChar():hasFlags("c") or client:IsSuperAdmin()
    else
        return client:getChar():hasFlags("C") or client:IsSuperAdmin()
    end
end