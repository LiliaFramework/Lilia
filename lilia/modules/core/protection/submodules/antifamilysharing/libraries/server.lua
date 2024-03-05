function MODULE:PlayerAuthed(client, steamid)
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local SteamName = client:steamName()
    local SteamID = client:SteamID()
    if self.FamilySharingEnabled and OwnerSteamID64 ~= steamID64 then
        client:Kick("Sorry! We do not allow family-shared accounts in this server!")
        self:NotifyAdmin(SteamName .. " (" .. SteamID .. ") kicked for family sharing.")
    elseif WhitelistCore and table.HasValue(WhitelistCore.BlacklistedSteamID64, OwnerSteamID64) then
        client:Ban("You are using an account whose family share is blacklisted from this server!")
        self:NotifyAdmin(SteamName .. " (" .. SteamID .. ") was banned for family sharing ALTing when blacklisting.")
    end
end

function MODULE:NotifyAdmin(notification)
    for _, admin in ipairs(player.GetAll()) do
        if IsValid(admin) and CAMI.PlayerHasAccess(admin, "Staff Permissions - Can See Family Sharing Notifications", nil) then admin:ChatPrint(notification) end
    end
end
