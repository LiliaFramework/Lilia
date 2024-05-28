lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    onRun = function()
        for _, v in pairs(player.GetAll()) do
            v:ConCommand("r_cleardecals")
        end
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

lia.command.add("asay", {
    adminOnly = false,
    syntax = "<string message>",
    onRun = function(client, arguments)
        if CAMI.PlayerHasAccess(client, "Staff Permissions - Speak in Admin Chat", nil) then
            local text = table.concat(arguments, " ")
            if text:find("%S") then lia.chat.send(client, "asay", text) end
        else
            client:notify("No access!")
        end
    end
})