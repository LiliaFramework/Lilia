function MODULE:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()
    if (attacker == client or inflictor:IsWorld()) and not lia.config.PKWorld then return end

    if character:getData("canbepermakilled", false) then
        character:setData("permakilled", true)
    end
end

function MODULE:PlayerSpawn(client)
    local character = client:getChar()

    if lia.config.PKActive and character and character:getData("permakilled") then
        character:ban()
    end
end