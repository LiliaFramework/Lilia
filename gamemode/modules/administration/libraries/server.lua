local MODULE = MODULE
function MODULE:PlayerSay(client)
    if client:getNetVar("liaGagged") then return "" end
end

function MODULE:OnReloaded()
    for _, client in player.Iterator() do
        if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
    end
end

function MODULE:PlayerSpawn(client)
    if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
end
