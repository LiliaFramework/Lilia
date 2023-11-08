------------------------------------------------------------------------------------------
function MODULE:CheckPassword(steamID64)
    if table.HasValue(lia.config.BlacklistedSteamID64, steamID64) then return false, "You are blacklisted from this server!" end
end
--------------------------------------------------------------------------------------------------------------------------
