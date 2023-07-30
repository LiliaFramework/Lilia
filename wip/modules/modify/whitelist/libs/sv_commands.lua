local MODULE = MODULE

lia.command.add("WhitelistAdd", {
    superAdminOnly = true,
    onRun = function(client, arguments)
        local steamID = arguments[1]
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then return "Invalid SteamID!" end

        if MODULE.allowed[steamID] then
            return "This SteamID is already whitelisted"
        else
            MODULE.allowed[steamID] = true

            return "Added SteamID to the whitelist"
        end
    end
})

lia.command.add("WhitelistRemove", {
    superAdminOnly = true,
    onRun = function(client, arguments)
        local steamID = arguments[1]
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then return "Invalid SteamID!" end

        if not MODULE.allowed[steamID] then
            return "This SteamID is not whitelisted"
        else
            MODULE.allowed[steamID] = nil

            return "Removed SteamID from the whitelist"
        end
    end
})

lia.command.add("WhitelistClear", {
    superAdminOnly = true,
    onRun = function()
        MODULE.allowed = {}

        return "Cleared the whitelist"
    end
})

lia.command.add("WhitelistAddAll", {
    superAdminOnly = true,
    onRun = function()
        for _, client in ipairs(player.GetHumans()) do
            if IsValid(client) then
                MODULE.allowed[client:SteamID()] = true
            end
        end

        return "Added all current players to the whitelist"
    end
})