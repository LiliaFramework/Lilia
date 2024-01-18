function AntiFamilySharing:PlayerAuthed(client, steamid)
    local OwnerAccount = "Unknown"
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local JoiningPlayerName = client:steamName()
    local JoiningPlayerSteamID = client:SteamID()
    local function notifyAdmin(isBanned, isSharingEnabled, isBlacklisted)
        for _, admin in ipairs(player.GetAll()) do
            if IsValid(admin) and CAMI and CAMI.PlayerHasAccess(admin, "Staff Permissions - Can See Family Sharing Notifications", nil) then
                steamworks.RequestPlayerInfo(
                    OwnerSteamID64,
                    function(name)
                        OwnerAccount = name or OwnerAccount
                        local printMessage = "Family share account " .. JoiningPlayerName .. " [" .. steamID64 .. "] attempted to join the server."
                        if isBanned then
                            if isBlacklisted then
                                printMessage = printMessage .. " The account was banned as it was blacklisted. Original owner: " .. OwnerAccount
                            else
                                printMessage = printMessage .. " The account was banned as it was ALTing for a banned player. Original owner: " .. OwnerAccount
                            end
                        else
                            if isSharingEnabled then
                                printMessage = printMessage .. " Original owner: " .. OwnerAccount
                            else
                                printMessage = JoiningPlayerName .. " (" .. JoiningPlayerSteamID .. ") tried to join but is using a family shared account therefore, he was kicked."
                            end
                        end

                        admin:ChatPrint(printMessage)
                    end,
                    function(error) print("Steamworks request error:", error) end
                )
            end
        end
    end

    local isBanned, banReason = self:CheckBans(OwnerSteamID64)
    if self.FamilySharingEnabled then
        if WhitelistCore and table.HasValue(WhitelistCore.BlacklistedSteamID64, OwnerSteamID64) then
            client:Ban("You are using an account whose family share is blacklisted from this server!")
            notifyAdmin(true, true, true)
        elseif OwnerSteamID64 ~= steamID64 then
            if isBanned then
                client:Ban(banReason)
                notifyAdmin(isBanned, true, false)
            end
        end
    else
        if isBanned then
            client:Ban(banReason)
            notifyAdmin(isBanned, false, false)
        else
            client:Kick("Sorry! We do not allow family shared accounts in this server! Reason: Family Sharing")
            notifyAdmin(false, false, false)
            print(client:steamName() .. " (" .. client:SteamID() .. ") kicked for family sharing.")
        end
    end
end

function AntiFamilySharing:CheckBans(ownerSteamID64)
    local isBanned, banReason = false, "Unknown"
    local bansContent = file.Read("bans.txt", "DATA")
    if bansContent then
        local bansLines = string.Explode("\n", bansContent)
        for _, line in pairs(bansLines) do
            local parts = string.Explode(" ", line)
            if parts[2] == ownerSteamID64 then
                isBanned = true
                banReason = table.concat(parts, " ", 3)
                break
            end
        end
    else
        print("Error reading bans.txt file:", bansContent)
    end
    return isBanned, banReason
end
