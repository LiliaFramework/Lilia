function AntiFamilySharing:PlayerAuthed(client, steamid)
    if not self.FamilySharingEnabled then return end
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local JoiningPlayerName = client:steamName()
    local OwnerAccount = "Unknown"
    local logTable = {
        steamName = client:steamName(),
        ip = client:IPAddress(),
        steamid = client:SteamID(),
        steamid64 = client:SteamID64(),
    }

    if OwnerSteamID64 ~= steamID64 then
        client:Kick("Sorry! We do not allow family shared accounts in this server!")
        print(client:steamName() .. " (" .. client:SteamID() .. ") tried to join, but is using a family shared account IP: " .. client:IPAddress())
        file.Write("lilia/" .. SCHEMA.folder .. "/familyshared/" .. client:SteamID64() .. ".txt", util.TableToJSON(logTable, true))
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
