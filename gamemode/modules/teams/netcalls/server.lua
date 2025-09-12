local function stripAgo(timeSince)
    local agoStr = L("ago")
    local suffix = " " .. agoStr
    if timeSince:sub(-#suffix) == suffix then return timeSince:sub(1, -#suffix - 1) end
    return timeSince
end

net.Receive("RequestFactionRoster", function(_, client)
    local character = client:getChar()
    if not character or not character:hasFlags("V") then return end
    local factionIndex = character:getFaction()
    if not factionIndex or factionIndex == FACTION_STAFF then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local condition = "lia_characters.schema = " .. lia.db.convertDataType(gamemode) .. " AND lia_characters.faction = " .. lia.db.convertDataType(faction.uniqueID)
    lia.db.selectWithJoin("SELECT n.value AS name, f.value AS faction, c.id, c.steamID, c.lastJoinTime, p.lastOnline, cl.value AS class, c.playtime FROM lia_characters AS c LEFT JOIN lia_players AS p ON c.steamID = p.steamID LEFT JOIN lia_chardata AS n ON n.charID = c.id AND n.key = 'name' LEFT JOIN lia_chardata AS f ON f.charID = c.id AND f.key = 'faction' LEFT JOIN lia_chardata AS cl ON cl.charID = c.id AND cl.key = 'class' WHERE " .. condition):next(function(data)
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

        net.Start("CharacterInfo")
        net.WriteTable(characters)
        net.Send(client)
    end)
end)
