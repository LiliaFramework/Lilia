local function stripAgo(timeSince)
    local agoStr = L("ago")
    local suffix = " " .. agoStr
    if timeSince:sub(-#suffix) == suffix then return timeSince:sub(1, -#suffix - 1) end
    return timeSince
end
net.Receive("liaRequestFactionRoster", function(_, client)
    local character = client:getChar()
    if not character or not character:hasFlags("V") then return end
    local factionIndex = character:getFaction()
    if not factionIndex or factionIndex == FACTION_STAFF then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    local fields = "lia_characters.name, lia_characters.faction, lia_characters.id, lia_characters.steamID, lia_characters.lastJoinTime, lia_players.lastOnline, lia_characters.class, lia_characters.playtime"
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local condition = "lia_characters.schema = '" .. lia.db.escape(gamemode) .. "' AND lia_characters.faction = " .. lia.db.convertDataType(faction.uniqueID)
    local query = "SELECT " .. fields .. " FROM lia_characters LEFT JOIN lia_players ON lia_characters.steamID = lia_players.steamID WHERE " .. condition
    lia.db.query(query, function(data)
        local characters = {}
        if data then
            for _, v in ipairs(data) do
                local charID = tonumber(v.id)
                local isOnline = lia.char.isLoaded(charID)
                local lastOnlineText
                if isOnline then
                    lastOnlineText = L("onlineNow")
                else
                    local last = tonumber(v.lastOnline)
                    if not isnumber(last) then last = os.time(lia.time.toNumber(v.lastJoinTime)) end
                    local lastDiff = os.time() - last
                    local timeSince = lia.time.TimeSince(last)
                    local timeStripped = stripAgo(timeSince)
                    lastOnlineText = L("agoFormat", timeStripped, lia.time.formatDHM(lastDiff))
                end
                local classID = tonumber(v.class) or 0
                local classData = lia.class.list[classID]
                local playTime = tonumber(v.playtime) or 0
                if isOnline then
                    local char = lia.char.getCharacter(charID)
                    if char then
                        local loginTime = char:getLoginTime() or os.time()
                        playTime = char:getPlayTime() + os.time() - loginTime
                    end
                end
                table.insert(characters, {
                    id = charID,
                    name = v.name,
                    faction = v.faction,
                    steamID = v.steamID,
                    class = classData and classData.name or L("none"),
                    classID = classID,
                    playTime = lia.time.formatDHM(playTime),
                    lastOnline = lastOnlineText
                })
            end
        end
        net.Start("liaCharacterInfo")
        net.WriteTable(characters)
        net.Send(client)
    end)
end)