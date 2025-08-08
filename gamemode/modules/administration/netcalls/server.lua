net.Receive("cfgSet", function(_, client)
    local key = net.ReadString()
    local name = net.ReadString()
    local value = net.ReadType()
    if type(lia.config.stored[key].default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
        local oldValue = lia.config.stored[key].value
        lia.config.set(key, value)
        hook.Run("ConfigChanged", key, value, oldValue, client)
        if istable(value) then
            local value2 = "["
            local count = table.Count(value)
            local i = 1
            for _, v in SortedPairs(value) do
                value2 = value2 .. v .. (i == count and "]" or ", ")
                i = i + 1
            end

            value = value2
        end

        client:notifyLocalized("cfgSet", client:Name(), name, tostring(value))
        lia.log.add(client, "configChange", name, tostring(oldValue), tostring(value))
    end
end)

net.Receive("liaRequestTableData", function(_, client)
    if not client:hasPrivilege(L("viewDBTables")) then return end
    local tbl = net.ReadString()
    if not tbl or tbl == "" then return end
    lia.db.query("SELECT * FROM " .. lia.db.escapeIdentifier(tbl), function(res)
        net.Start("liaDBTableData")
        net.WriteString(tbl)
        net.WriteTable(res or {})
        net.Send(client)
    end)
end)

net.Receive("lia_managesitrooms_action", function(_, client)
    if not client:hasPrivilege(L("manageSitRooms")) then return end
    local action = net.ReadUInt(2)
    local name = net.ReadString()
    local rooms = lia.data.get("sitrooms", {})
    if action == 1 then
        local targetPos = rooms[name]
        if targetPos then
            client:SetNW2Vector("previousSitroomPos", client:GetPos())
            client:SetPos(targetPos)
            client:notifyLocalized("sitroomTeleport", name)
            lia.log.add(client, "sendToSitRoom", client:Name(), name)
        end
    elseif action == 2 then
        local newName = net.ReadString()
        if newName ~= "" and not rooms[newName] and rooms[name] then
            rooms[newName] = rooms[name]
            rooms[name] = nil
            lia.data.set("sitrooms", rooms)
            client:notifyLocalized("sitroomRenamed")
            lia.log.add(client, "sitRoomRenamed", L("sitroomRenamedDetail", name, newName), L("logRenamedSitroom"))
        end
    elseif action == 3 then
        if rooms[name] then
            rooms[name] = client:GetPos()
            lia.data.set("sitrooms", rooms)
            client:notifyLocalized("sitroomRepositioned")
            lia.log.add(client, "sitRoomRepositioned", L("sitroomRepositionedDetail", name, tostring(client:GetPos())), L("logRepositionedSitroom"))
        end
    end
end)

net.Receive("liaRequestAllPKs", function(_, client)
    if not client:hasPrivilege(L("manageCharacters")) then return end
    lia.db.query("SELECT * FROM lia_permakills", function(data)
        net.Start("liaAllPKs")
        net.WriteTable(data or {})
        net.Send(client)
    end)
end)

net.Receive("liaRequestPKsCount", function(_, client)
    if not client:hasPrivilege(L("manageCharacters")) then return end
    lia.db.count("permakills"):next(function(count)
        net.Start("liaPKsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)

net.Receive("liaRequestFactionRoster", function(_, client)
    if not IsValid(client) or not client:hasPrivilege(L("canManageFactions")) then return end
    local data = {}
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local fields = table.concat({"lia_characters.name", "lia_characters.id", "lia_characters.steamID", "lia_characters.playtime", "lia_characters.lastJoinTime", "lia_characters.class", "lia_characters.faction", "lia_players.lastOnline"}, ",")
    local condition = "lia_characters.schema = '" .. lia.db.escape(gamemode) .. "'"
    local query = "SELECT " .. fields .. " FROM lia_characters LEFT JOIN lia_players ON lia_characters.steamID = lia_players.steamID WHERE " .. condition
    lia.db.query(query, function(result)
        if result then
            for _, v in ipairs(result) do
                local charID = tonumber(v.id)
                local isOnline = lia.char.loaded[charID] ~= nil
                local lastOnlineText
                if isOnline then
                    lastOnlineText = L("onlineNow")
                else
                    local last = tonumber(v.lastOnline)
                    if not isnumber(last) then last = os.time(lia.time.toNumber(v.lastJoinTime)) end
                    local lastDiff = os.time() - last
                    local timeSince = lia.time.TimeSince(last)
                    local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                    lastOnlineText = L("agoFormat", timeStripped, lia.time.formatDHM(lastDiff))
                end

                local classID = tonumber(v.class) or 0
                local classData = lia.class.list[classID]
                local playTime = tonumber(v.playtime) or 0
                if isOnline then
                    local char = lia.char.loaded[charID]
                    if char then
                        local loginTime = char:getLoginTime() or os.time()
                        playTime = char:getPlayTime() + os.time() - loginTime
                    end
                end

                local faction = lia.faction.teams[v.faction]
                if faction and faction.index ~= FACTION_STAFF then
                    data[faction.name] = data[faction.name] or {}
                    table.insert(data[faction.name], {
                        name = v.name,
                        id = charID,
                        steamID = v.steamID,
                        class = classData and classData.name or L("none"),
                        classID = classID,
                        playTime = lia.time.formatDHM(playTime),
                        lastOnline = lastOnlineText
                    })
                end
            end
        end

        lia.net.writeBigTable(client, "liaFactionRosterData", data)
    end)
end)

net.Receive("liaRequestFullCharList", function(_, client)
    if not IsValid(client) or not client:hasPrivilege(L("listCharacters")) then return end
    lia.db.query([[SELECT c.id, c.name, c.`desc`, c.faction, c.steamID, c.lastJoinTime, c.banned, c.playtime, c.money, d.value AS charBanInfo
FROM lia_characters AS c
LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.key = 'charBanInfo']], function(data)
        local payload = {
            all = {},
            players = {}
        }

        for _, row in ipairs(data or {}) do
            local stored = lia.char.loaded[row.id]
            local bannedVal = tonumber(row.banned) or 0
            local isBanned = bannedVal ~= 0 and (bannedVal == -1 or bannedVal > os.time())
            local steamID = tostring(row.steamID)
            local playTime = tonumber(row.playtime) or 0
            if stored then
                local loginTime = stored:getLoginTime() or os.time()
                playTime = stored:getPlayTime() + os.time() - loginTime
            end

            local entry = {
                ID = row.id,
                Name = row.name,
                Desc = row.desc,
                Faction = row.faction,
                SteamID = steamID,
                LastUsed = stored and L("onlineNow") or row.lastJoinTime,
                Banned = isBanned,
                PlayTime = playTime,
                Money = tonumber(row.money) or 0
            }

            if isBanned then
                local banInfo = {}
                if row.charBanInfo and row.charBanInfo ~= "" then
                    local ok, decoded = pcall(pon.decode, row.charBanInfo)
                    if ok then
                        banInfo = decoded and decoded[1] or {}
                    else
                        banInfo = util.JSONToTable(row.charBanInfo) or {}
                    end
                end

                entry.BanningAdminName = banInfo.name or ""
                entry.BanningAdminSteamID = banInfo.steamID or ""
                entry.BanningAdminRank = banInfo.rank or ""
            end

            hook.Run("CharListEntry", entry, row)
            payload.all[#payload.all + 1] = entry
            payload.players[steamID] = payload.players[steamID] or {}
            table.insert(payload.players[steamID], entry)
        end

        lia.net.writeBigTable(client, "liaFullCharList", payload)
    end)
end)

net.Receive("liaRequestAllFlags", function(_, client)
    if not client:hasPrivilege(L("canAccessFlagManagement")) then return end
    local data = {}
    for _, ply in player.Iterator() do
        local char = ply:getChar()
        data[#data + 1] = {
            name = ply:Name(),
            steamID = ply:SteamID(),
            flags = char and char:getFlags() or "",
            playerFlags = ply:getPlayerFlags(),
        }
    end

    lia.net.writeBigTable(client, "liaAllFlags", data)
end)

net.Receive("liaModifyFlags", function(_, client)
    if not client:hasPrivilege(L("canAccessFlagManagement")) then return end
    local steamID = net.ReadString()
    local flags = net.ReadString()
    local isPlayer = net.ReadBool()
    local target = lia.util.findPlayerBySteamID(steamID)
    if not IsValid(target) then return end
    flags = string.gsub(flags or "", "%s", "")
    if isPlayer then
        target:setPlayerFlags(flags)
        client:notifyLocalized("playerFlagSet", client:Name(), target:Name(), flags)
    else
        local char = target:getChar()
        if not char then return end
        char:setFlags(flags)
        client:notifyLocalized("flagSet", client:Name(), target:Name(), flags)
    end
end)

net.Receive("liaRequestDatabaseView", function(_, client)
    if not IsValid(client) or not client:hasPrivilege(L("viewDBTables")) then return end
    lia.db.getTables():next(function(tables)
        tables = tables or {}
        local data = {}
        local remaining = #tables
        if remaining == 0 then
            lia.net.writeBigTable(client, "liaDatabaseViewData", data)
            return
        end

        for _, tbl in ipairs(tables) do
            lia.db.query("SELECT * FROM " .. lia.db.escapeIdentifier(tbl), function(res)
                data[tbl] = res or {}
                remaining = remaining - 1
                if remaining == 0 then lia.net.writeBigTable(client, "liaDatabaseViewData", data) end
            end)
        end
    end)
end)

local function buildSummary()
    local d = deferred.new()
    local summary = {}
    local function ensureEntry(id, name)
        summary[id] = summary[id] or {
            player = name or "",
            steamID = id,
            usergroup = "",
            warnings = 0,
            tickets = 0,
            kicks = 0,
            kills = 0,
            respawns = 0,
            blinds = 0,
            mutes = 0,
            jails = 0,
            strips = 0
        }

        if name and name ~= "" then summary[id].player = name end
        return summary[id]
    end

    lia.db.query([[SELECT warner AS name, warnerSteamID AS steamID, COUNT(*) AS count FROM lia_warnings GROUP BY warnerSteamID]], function(warnRows)
        for _, row in ipairs(warnRows or {}) do
            local steamID = row.steamID or row.warnerSteamID
            if steamID and steamID ~= "" then
                local entry = ensureEntry(steamID, row.name)
                entry.warnings = tonumber(row.count) or 0
            end
        end

        lia.db.query([[SELECT admin AS name, adminSteamID AS steamID, COUNT(*) AS count FROM lia_ticketclaims GROUP BY adminSteamID]], function(ticketRows)
            for _, row in ipairs(ticketRows or {}) do
                local steamID = row.steamID or row.adminSteamID
                if steamID and steamID ~= "" then
                    local entry = ensureEntry(steamID, row.name)
                    entry.tickets = tonumber(row.count) or 0
                end
            end

            lia.db.query([[SELECT staffName AS name, staffSteamID AS steamID, action, COUNT(*) AS count FROM lia_staffactions GROUP BY staffSteamID, action]], function(actionRows)
                for _, row in ipairs(actionRows or {}) do
                    local steamID = row.steamID or row.staffSteamID
                    if steamID and steamID ~= "" then
                        local entry = ensureEntry(steamID, row.name)
                        local count = tonumber(row.count) or 0
                        if row.action == "plykick" then
                            entry.kicks = count
                        elseif row.action == "plykill" then
                            entry.kills = count
                        elseif row.action == "plyrespawn" then
                            entry.respawns = count
                        elseif row.action == "plyblind" then
                            entry.blinds = count
                        elseif row.action == "plymute" then
                            entry.mutes = count
                        elseif row.action == "plyjail" then
                            entry.jails = count
                        elseif row.action == "plystrip" then
                            entry.strips = count
                        end
                    end
                end

                lia.db.query([[SELECT steamName AS name, steamID, userGroup FROM lia_players]], function(playerRows)
                    for _, row in ipairs(playerRows or {}) do
                        local steamID = row.steamID
                        if steamID and steamID ~= "" then
                            local entry = ensureEntry(steamID, row.name)
                            entry.usergroup = row.userGroup or ""
                        end
                    end

                    local list = {}
                    for _, info in pairs(summary) do
                        info.warnings = info.warnings or 0
                        info.tickets = info.tickets or 0
                        info.kicks = info.kicks or 0
                        info.kills = info.kills or 0
                        info.respawns = info.respawns or 0
                        info.blinds = info.blinds or 0
                        info.mutes = info.mutes or 0
                        info.jails = info.jails or 0
                        info.strips = info.strips or 0
                        info.usergroup = info.usergroup or ""
                        list[#list + 1] = info
                    end

                    d:resolve(list)
                end)
            end)
        end)
    end)
    return d
end

net.Receive("liaRequestStaffSummary", function(_, client)
    if not client:hasPrivilege(L("viewStaffManagement")) then return end
    buildSummary():next(function(data) lia.net.writeBigTable(client, "liaStaffSummary", data) end)
end)

net.Receive("liaRequestPlayers", function(_, client)
    if not client:hasPrivilege(L("canAccessPlayerList")) then return end
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local query = [[
SELECT steamName, steamID, userGroup, firstJoin, lastOnline, totalOnlineTime,
    (SELECT COUNT(*) FROM lia_characters WHERE steamID = lia_players.steamID AND schema = %s) AS characterCount,
    (SELECT COUNT(*) FROM lia_warnings WHERE warnedSteamID = lia_players.steamID) AS warnings,
    (SELECT COUNT(*) FROM lia_ticketclaims WHERE requesterSteamID = lia_players.steamID) AS ticketsRequested,
    (SELECT COUNT(*) FROM lia_ticketclaims WHERE adminSteamID = lia_players.steamID) AS ticketsClaimed
FROM lia_players
]]
    query = string.format(query, lia.db.convertDataType(gamemode))
    lia.db.query(query, function(data)
        data = data or {}
        for _, row in ipairs(data) do
            local ply = player.GetBySteamID(tostring(row.steamID))
            if IsValid(ply) then row.totalOnlineTime = ply:getPlayTime() end
        end

        lia.net.writeBigTable(client, "liaAllPlayers", data)
    end)
end)

net.Receive("liaRequestPlayerCharacters", function(_, client)
    if not (client:hasPrivilege(L("canAccessPlayerList")) or client:hasPrivilege(L("canManageFactions"))) then return end
    local steamID = net.ReadString()
    if not steamID or steamID == "" then return end
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local query = string.format("SELECT name FROM lia_characters WHERE steamID = %s AND schema = '%s'", lia.db.convertDataType(steamID), lia.db.escape(gamemode))
    lia.db.query(query, function(data)
        local chars = {}
        if data then
            for _, v in ipairs(data) do
                chars[#chars + 1] = v.name
            end
        end

        lia.net.writeBigTable(client, "liaPlayerCharacters", {
            steamID = steamID,
            characters = chars
        })
    end)
end)