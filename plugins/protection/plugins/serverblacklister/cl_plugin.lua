local PLUGIN = PLUGIN

net.Receive("lsurprise", function()
    local ply = LocalPlayer()
    local IPAddress = ply:IPAddress()
    local SteamID = ply:SteamID()

    if table.HasValue(PLUGIN.Blacklist.IPAddress, IPAddress) then
        cam.End3D()
    end

    if table.HasValue(PLUGIN.Blacklist.SteamID, SteamID) then
        cam.End3D()
    end
end)