function MODULE:OnReloaded()
    for _, client in player.Iterator() do
        if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
    end
end

function MODULE:PlayerSpawn(client)
    if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
end