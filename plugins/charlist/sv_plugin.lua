-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charunbanoffline", {
    syntax = "<string charID>",
    onRun = function(client, arguments)
        if not UserGroups.adminRanks[client:GetUserGroup()] then return "This command is only available to Admin+" end
        local targetChar = arguments[1]
        if not targetChar or not tonumber(arguments[1]) then return "Invalid argument #1 (charID)" end
        local charID = tonumber(arguments[1])
        local charData = lia.getCharData(targetChar)
        if not charData then return "Char not found" end
        lia.setCharData(charID, "banned")
        lia.setCharData(charID, "charBanInfo")
        client:notify("You have offline-charunbanned char ID " .. charID)
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charbanoffline", {
    syntax = "<string charID>",
    onRun = function(client, arguments)
        if not UserGroups.adminRanks[client:GetUserGroup()] then return "This command is only available to Admin+" end
        local targetChar = arguments[1]
        if not targetChar or not tonumber(arguments[1]) then return "Invalid argument #1 (charID)" end
        local charID = tonumber(arguments[1])
        local charData = lia.getCharData(targetChar)
        if not charData then return "Char not found" end
        lia.setCharData(charID, "banned", true)

        lia.setCharData(charID, "charBanInfo", {
            name = client.SteamName and client:SteamName() or client:Nick(),
            steamID = client:SteamID(),
            rank = client:GetUserGroup()
        })

        for k, v in pairs(player.GetAll()) do
            if v:getChar() and v:getChar():getID() == charID then
                v:getChar():kick()
                break
            end
        end

        client:notify("You have offline-charbanned char ID " .. charID)
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charlist", {
    syntax = "<string playerORsteamID>",
    onRun = function(client, arguments)
        local targetSteamID
        if not UserGroups.adminRanks[client:GetUserGroup()] then return "This command is only available to Admin+" end

        if arguments[1] then
            local target = lia.command.findPlayerSilent(table.concat(arguments, ' ', 1))

            if IsValid(target) then
                targetSteamID = target:SteamID64()
            else
                if arguments[1]:sub(1, 6) ~= "STEAM_" then return "Invalid argument (#1)" end
                targetSteamID = util.SteamIDTo64(arguments[1])
                if not targetSteamID or targetSteamID == 0 then return "Invalid argument (#1)" end
            end
        else
            targetSteamID = client:SteamID64()
        end

        if not targetSteamID then return "Invalid argument (#1)" end
        if not tonumber(targetSteamID) then return "Something went wrong - Contact Dev" end
        local targetSteamIDsafe = targetSteamID
        local q = sql.Query("SELECT * FROM lia_characters WHERE _steamID=" .. targetSteamIDsafe)
        if q == false then return "Query error - Contact developer" end
        local properData = {}
        local sendData = {}

        for k, v in pairs(q or {}) do
            local loaded = lia.char.loaded[v._id]
            local useData = loaded and loaded:getData() or v._data

            if type(useData) == "string" then
                useData = util.JSONToTable(useData) or {}
            end

            if not useData then return "Weird error - Contact developer" end
            local sendChar = {}
            sendChar.ID = v._id
            sendChar.Name = v._name
            sendChar.Desc = v._desc
            sendChar.Faction = v._faction
            sendChar.Banned = useData.banned and "Yes" or "No"
            sendChar.BanningAdminName = useData.charBanInfo and useData.charBanInfo.name or ""
            sendChar.BanningAdminSteamID = useData.charBanInfo and useData.charBanInfo.steamID or ""
            sendChar.BanningAdminRank = useData.charBanInfo and useData.charBanInfo.rank or ""
            table.insert(sendData, sendChar)
        end

        netstream.Start(client, "DisplayCharList", sendData, targetSteamIDsafe)
    end
})