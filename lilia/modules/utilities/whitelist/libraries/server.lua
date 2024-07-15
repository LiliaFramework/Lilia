function MODULE:CheckPassword(steamID64)
    if self.BlacklistedEnabled and table.HasValue(self.BlacklistedSteamID64, steamID64) then return false, "You are blacklisted from this server!" end
    if self.WhitelistEnabled and not table.HasValue(self.WhitelistedSteamID64, steamID64) then return false, "Sorry, you are not whitelisted for " .. GetHostName() end
end
