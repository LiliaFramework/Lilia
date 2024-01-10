------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AntiFamilySharing:PlayerAuthed(client, steamid)
    if not self.FamilySharingEnabled then return end
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local JoiningPlayerName = client:Name()
    local OwnerAccount = "Unknown"
    if OwnerSteamID64 ~= steamID64 then
        client:Kick("Family share accounts are not allowed on this server.")
        for _, admin in ipairs(player.GetAll()) do
            if IsValid(admin) and CAMI.PlayerHasAccess(admin, "Staff Permissions - Can See Family Sharing Notifications", nil) then
                steamworks.RequestPlayerInfo(
                    OwnerSteamID64,
                    function(name)
                        OwnerAccount = name or OwnerAccount
                        admin:ChatPrint("Family share account " .. JoiningPlayerName .. " [" .. steamID64 .. "] attempted to join the server. Original owner: " .. OwnerAccount)
                    end
                )
            end
        end
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
