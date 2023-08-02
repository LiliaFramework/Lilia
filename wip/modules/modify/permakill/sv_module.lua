function MODULE:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()

    if lia.config.PKActive then
        if (attacker == client or inflictor:IsWorld()) and not lia.config.PKWorld then return end
        character:setData("permakilled", true)
    end
end

function MODULE:PlayerSpawn(client)
    local character = client:getChar()

    if lia.config.PKActive and character and character:getData("permakilled") then
        character:ban()
    end
end