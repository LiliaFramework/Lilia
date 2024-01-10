
function PermaKillCore:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()
    if (attacker == client or inflictor:IsWorld()) and not lia.config.PKWorld then return end
    if character:getData("canbepermakilled", false) then character:ban() end
end

