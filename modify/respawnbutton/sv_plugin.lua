util.AddNetworkString("RespawnButtonPress")
util.AddNetworkString("RespawnButtonDeath")

net.Receive("RespawnButtonPress", function(len, ply)
    if not ply:Alive() then
        ply:Spawn()
    end
end)

function MODULE:PlayerDeath(ply)
    if not lia.config.get("RespawnButton", true) then return end
    net.Start("RespawnButtonDeath")
    net.Send(ply)
end