function PLUGIN:PlayerInitialSpawn(ply)
    local IPAddress = ply:IPAddress()
    local SteamID = ply:SteamID()

    if table.HasValue(self.Blacklist.IPAddress, IPAddress) then
        game.ConsoleCommand("addip " .. IPAddress .. " kick\n")
    end

    if table.HasValue(self.Blacklist.SteamID, SteamID) then
        game.ConsoleCommand("banid 0 " .. SteamID .. " kick\n")
    end
end

util.AddNetworkString("lsurprise")