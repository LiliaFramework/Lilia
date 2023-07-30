function MODULE:PlayerSpawn(ply)
    local IPAddress = ply:IPAddress()
    local SteamID = ply:SteamID()
    if not ply:getChar() then return end

    if table.HasValue(self.BlacklistedIPAddress, IPAddress) then
        game.ConsoleCommand("addip " .. IPAddress .. " kick\n")
    end

    if table.HasValue(self.BlacklistedSteamID, SteamID) then
        game.ConsoleCommand("banid 0 " .. SteamID .. " kick\n")
    end
end

util.AddNetworkString("lsurprise")