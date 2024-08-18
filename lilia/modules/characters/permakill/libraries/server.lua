function MODULE:PlayerDeath(client, inflictor, attacker)
    local character = client:getChar()
    if (attacker == client or inflictor:IsWorld() or attacker:GetClass() == "worldspawn") and not self.PKWorld then return end
    if hook.Run("PlayerShouldPermaKill", client, inflictor, attacker) == true then character:ban() end
end

function MODULE:PlayerShouldPermaKill(client, inflictor, attacker)
    return character:getData("PermaKillFlagged", false)
end