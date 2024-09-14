lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    onRun = function()
        for _, v in pairs(player.GetAll()) do
            v:ConCommand("r_cleardecals")
        end
    end
})

lia.command.add("viewclaims", {
    description = "View the claims for all admins.",
    adminOnly = true,
    onRun = function(client, arguments)
        if not file.Exists("caseclaims.txt", "DATA") then
            client:ChatPrint("No claims have been recorded yet.")
            return
        end

        local caseclaims = util.JSONToTable(file.Read("caseclaims.txt", "DATA"))
        local claimsData = {}
        for steamID, claim in pairs(caseclaims) do
            table.insert(claimsData, {
                steamID = steamID,
                name = claim.name,
                claims = claim.claims,
                lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim)
            })
        end

        lia.util.CreateTableUI(client, "Admin Claims", {
            {
                name = "SteamID",
                field = "steamID",
                width = 200
            },
            {
                name = "Admin Name",
                field = "name",
                width = 150
            },
            {
                name = "Total Claims",
                field = "claims",
                width = 100
            },
            {
                name = "Last Claim Date",
                field = "lastclaim",
                width = 200
            }
        }, claimsData)
    end
})

lia.command.add("playtime", {
    adminOnly = false,
    onRun = function(client)
        local steamID = client:SteamID()
        local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
        local result = sql.QueryRow(query)
        if result then
            local playTimeInSeconds = tonumber(result.play_time) or 0
            local hours = math.floor(playTimeInSeconds / 3600)
            local minutes = math.floor((playTimeInSeconds % 3600) / 60)
            local seconds = playTimeInSeconds % 60
            client:chatNotify(string.format("Your playtime: %d hours, %d minutes, %d seconds", hours, minutes, seconds))
        else
            client:notify("Could not retrieve your playtime. Please try again or contact an admin if the issue persists.")
        end
    end
})

sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(true)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()

sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Unblinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(false)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Un-Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()