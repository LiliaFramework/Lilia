util.AddNetworkString("RespawnButtonPress")
util.AddNetworkString("RespawnButtonDeath")

net.Receive("RespawnButtonPress", function(len, ply)
    if not ply:Alive() then
        ply:Spawn()
    end
end)

function MODULE:PlayerDeath(ply)
    if not CONFIG.RespawnButton then return end
    net.Start("RespawnButtonDeath")
    net.Send(ply)
end