util.AddNetworkString("lsurprise")

function MODULE:PlayerInitialSpawn(ply)
    local IPAddress = ply:IPAddress()
    local SteamID = ply:SteamID()

    if table.HasValue(lia.config.BlacklistedIPAddress, IPAddress) then
        RunConsoleCommand("addip", IPAddress, "kick")
        net.Start("lsurprise")
        net.Send(ply)

        return
    end

    if table.HasValue(lia.config.BlacklistedSteamID, SteamID) then
        RunConsoleCommand("banid", "0", SteamID, "kick")
        net.Start("lsurprise")
        net.Send(ply)

        return
    end
end