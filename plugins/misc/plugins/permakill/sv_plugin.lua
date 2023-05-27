function PLUGIN:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()

    if lia.config.get("pkActive") then
        if (attacker == client or inflictor:IsWorld()) and not lia.config.get("pkWorld", false) then return end
        character:setData("permakilled", true)
    end
end

function PLUGIN:PlayerSpawn(client)
    local character = client:getChar()

    if lia.config.get("pkActive") and character and character:getData("permakilled") then
        character:ban()
    end
end