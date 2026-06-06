local spawnCooldowns = {}
net.Receive("liaAdminSetCharProperty", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaAdminSetCharProperty", "hasPrivilege(listCharacters)=", tostring(client:hasPrivilege("listCharacters")), "finalResult=", tostring(client:hasPrivilege("listCharacters")))
    if not client:hasPrivilege("listCharacters") then return end
    local charID = net.ReadInt(32)
    local property = net.ReadString()
    local value = net.ReadType()
    local charIDsafe = tonumber(charID)
    if not charIDsafe then
        client:notifyErrorLocalized("invalidCharID")
        return
    end

    lia.db.query("SELECT name, money, model FROM lia_characters WHERE id = " .. charIDsafe, function(data)
        if not data or #data == 0 then
            client:notifyErrorLocalized("characterNotFound")
            return
        end

        local charData = data[1]
        if property == "money" then
            local moneyValue = tonumber(value) or 0
            if lia.char.setCharDatabase(charID, "money", moneyValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("setMoney", target:Name(), lia.currency.get(moneyValue))
                else
                    client:notifySuccessLocalized("offlineCharMoneySet", charID, lia.currency.get(moneyValue))
                end

                lia.log.add(client, "adminSetCharMoney", charID, moneyValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        elseif property == "name" then
            local nameValue = tostring(value)
            if lia.char.setCharDatabase(charID, "name", nameValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("changeName", client:Name(), charData.name, nameValue)
                else
                    client:notifySuccessLocalized("offlineCharNameSet", charID, nameValue)
                end

                lia.log.add(client, "adminSetCharName", charID, nameValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        elseif property == "model" then
            local modelValue = tostring(value)
            if lia.char.setCharDatabase(charID, "model", modelValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("changeModelAdmin", client:Name(), target:Name(), modelValue)
                else
                    client:notifySuccessLocalized("offlineCharModelSet", charID, modelValue)
                end

                lia.log.add(client, "adminSetCharModel", charID, modelValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        else
            client:notifyErrorLocalized("invalidArg")
            return
        end
    end)
end)

local function fixupProp(client, ent, mins, maxs)
    local pos = ent:GetPos()
    local down, up = ent:LocalToWorld(mins), ent:LocalToWorld(maxs)
    local trD = util.TraceLine({
        start = pos,
        endpos = down,
        filter = {ent, client}
    })

    local trU = util.TraceLine({
        start = pos,
        endpos = up,
        filter = {ent, client}
    })

    if trD.Hit and trU.Hit then return end
    if trD.Hit then ent:SetPos(pos + trD.HitPos - down) end
    if trU.Hit then ent:SetPos(pos + trU.HitPos - up) end
end

local function tryFixPropPosition(client, ent)
    local m, M = ent:OBBMins(), ent:OBBMaxs()
    fixupProp(client, ent, Vector(m.x, 0, 0), Vector(M.x, 0, 0))
    fixupProp(client, ent, Vector(0, m.y, 0), Vector(0, M.y, 0))
    fixupProp(client, ent, Vector(0, 0, m.z), Vector(0, 0, M.z))
end

net.Receive("liaSpawnMenuSpawnItem", function(_, client)
    local id = net.ReadString()
    lia.debug("[Permissions]", "Permission Check for net.Receive liaSpawnMenuSpawnItem", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(canUseItemSpawner)=", tostring(IsValid(client) and client:hasPrivilege("canUseItemSpawner") or false), "finalResult=", tostring(IsValid(client) and id and client:hasPrivilege("canUseItemSpawner") or false))
    if not IsValid(client) or not id or not client:hasPrivilege("canUseItemSpawner") then return end
    local currentTime = CurTime()
    local lastSpawnTime = spawnCooldowns[client] or 0
    if currentTime - lastSpawnTime < 0.5 then return end
    spawnCooldowns[client] = currentTime
    local startPos, dir = client:EyePos(), client:GetAimVector()
    local tr = util.TraceLine({
        start = startPos,
        endpos = startPos + dir * 4096,
        filter = client
    })

    if not tr.Hit then return end
    lia.item.spawn(id, tr.HitPos, function(item)
        local ent = item:getEntity()
        if not IsValid(ent) then return end
        tryFixPropPosition(client, ent)
        if IsValid(client) then
            ent.SteamID = client:SteamID()
            ent.liaCharID = 0
            ent:SetCreator(client)
        end

        undo.Create(L("item"))
        undo.SetPlayer(client)
        undo.AddEntity(ent)
        local name = lia.item.list[id] and lia.item.list[id].name or id
        undo.SetCustomUndoText(L("spawnUndoText", name))
        undo.Finish(L("spawnUndoName", name))
        lia.log.add(client, "spawnItem", name, "SpawnMenuSpawnItem")
        client:notifySuccessLocalized("logItemSpawned", name)
    end, angle_zero, {})
end)

net.Receive("liaSpawnMenuGiveItem", function(_, client)
    local id, targetID = net.ReadString(), net.ReadString()
    if not IsValid(client) then return end
    if not id then return end
    lia.debug("[Permissions]", "Permission Check for net.Receive liaSpawnMenuGiveItem", "hasPrivilege(canUseItemSpawner)=", tostring(client:hasPrivilege("canUseItemSpawner")), "finalResult=", tostring(client:hasPrivilege("canUseItemSpawner")))
    if not client:hasPrivilege("canUseItemSpawner") then return end
    local targetChar = lia.char.getBySteamID(targetID)
    if not targetChar then return end
    local target = targetChar:getPlayer()
    targetChar:getInv():add(id)
    lia.log.add(client, "chargiveItem", id, target, "SpawnMenuGiveItem")
end)

net.Receive("liaManagesitroomsAction", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaManagesitroomsAction", "hasPrivilege(manageSitRooms)=", tostring(client:hasPrivilege("manageSitRooms")), "finalResult=", tostring(client:hasPrivilege("manageSitRooms")))
    if not client:hasPrivilege("manageSitRooms") then return end
    local action = net.ReadUInt(2)
    local name = net.ReadString()
    local rooms = lia.data.get("sitrooms", {})
    if action == 1 then
        local targetPos = rooms[name]
        if targetPos then
            client.previousSitroomPos = client:GetPos()
            client:SetPos(targetPos)
            client:notifySuccessLocalized("sitroomTeleport", name)
            lia.log.add(client, "sendToSitRoom", client:Name(), name)
            local message = L("staffLogTeleportedToSitRoom", client:Name(), client:SteamID64(), name)
            StaffAddTextShadowed(Color(123, 104, 238), "SIT", Color(255, 255, 255), message)
        end
    elseif action == 2 then
        local newName = net.ReadString()
        if newName ~= "" and not rooms[newName] and rooms[name] then
            rooms[newName] = rooms[name]
            rooms[name] = nil
            lia.data.set("sitrooms", rooms)
            client:notifySuccessLocalized("sitroomRenamed")
            lia.log.add(client, "sitRoomRenamed", L("sitroomRenamedDetail", name, newName), L("logRenamedSitroom"))
        end
    elseif action == 3 then
        if rooms[name] then
            rooms[name] = client:GetPos()
            lia.data.set("sitrooms", rooms)
            client:notifySuccessLocalized("sitroomRepositioned")
            lia.log.add(client, "sitRoomRepositioned", L("sitroomRepositionedDetail", name, tostring(client:GetPos())), L("logRepositionedSitroom"))
        end
    end
end)

net.Receive("liaFeaturePositionsRequest", function(_, client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for net.Receive liaFeaturePositionsRequest", "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if not permission then return end
    local typeId = net.ReadString()
    local callback = lia.util.positionCallbacks and lia.util.positionCallbacks[typeId]
    if callback and callback.serverOnly and callback.onSelect then
        callback.onSelect(client, function(positions, count)
            net.Start("liaFeaturePositions")
            net.WriteString(typeId)
            net.WriteUInt(count or #positions, 16)
            for j = 1, #positions do
                net.WriteVector(positions[j].pos)
                net.WriteString(positions[j].label or "")
            end

            net.Send(client)
        end)
    else
        net.Start("liaFeaturePositions")
        net.WriteString(typeId)
        net.WriteUInt(0, 16)
        net.Send(client)
    end
end)

net.Receive("liaSetFeaturePosition", function(_, client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for net.Receive liaSetFeaturePosition", "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if not permission then return end
    local typeId = net.ReadString()
    local pos = net.ReadVector()
    local callback = lia.util.positionCallbacks and lia.util.positionCallbacks[typeId]
    if callback and callback.serverOnly and callback.onRun then
        callback.onRun(pos, client, typeId)
        timer.Simple(1, function()
            if not IsValid(client) then return end
            local innerCallback = lia.util.positionCallbacks and lia.util.positionCallbacks[typeId]
            if innerCallback and innerCallback.onSelect then
                innerCallback.onSelect(client, function(positions, count)
                    net.Start("liaFeaturePositions")
                    net.WriteString(typeId)
                    net.WriteUInt(count or #positions, 16)
                    for j = 1, #positions do
                        net.WriteVector(positions[j].pos)
                        net.WriteString(positions[j].label or "")
                    end

                    net.Send(client)
                end)
            end
        end)
    end
end)

net.Receive("liaRemoveFeaturePosition", function(_, client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRemoveFeaturePosition", "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if not permission then return end
    local typeId = net.ReadString()
    local pos = net.ReadVector()
    local callback = lia.util.positionCallbacks and lia.util.positionCallbacks[typeId]
    if callback and callback.serverOnly and callback.onRemove then
        callback.onRemove(pos, client, typeId)
        timer.Simple(1, function()
            if not IsValid(client) then return end
            local innerCallback = lia.util.positionCallbacks and lia.util.positionCallbacks[typeId]
            if innerCallback and innerCallback.onSelect then
                innerCallback.onSelect(client, function(positions, count)
                    net.Start("liaFeaturePositions")
                    net.WriteString(typeId)
                    net.WriteUInt(count or #positions, 16)
                    for j = 1, #positions do
                        net.WriteVector(positions[j].pos)
                        net.WriteString(positions[j].label or "")
                    end

                    net.Send(client)
                end)
            end
        end)
    end
end)

net.Receive("liaRequestAllPks", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestAllPks", "hasPrivilege(manageCharacters)=", tostring(client:hasPrivilege("manageCharacters")), "finalResult=", tostring(client:hasPrivilege("manageCharacters")))
    if not client:hasPrivilege("manageCharacters") then return end
    lia.db.query("SELECT * FROM lia_permakills", function(data)
        net.Start("liaAllPks")
        net.WriteTable(data or {})
        net.Send(client)
    end)
end)

net.Receive("liaRequestPksCount", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestPksCount", "hasPrivilege(manageCharacters)=", tostring(client:hasPrivilege("manageCharacters")), "finalResult=", tostring(client:hasPrivilege("manageCharacters")))
    if not client:hasPrivilege("manageCharacters") then return end
    lia.db.count("permakills"):next(function(count)
        net.Start("liaPksCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)

net.Receive("liaRequestFullCharList", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestFullCharList", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(listCharacters)=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false), "finalResult=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false))
    if not IsValid(client) or not client:hasPrivilege("listCharacters") then return end
    lia.db.query([[SELECT c.id, c.name, c.`desc`, c.faction, c.steamID, c.lastJoinTime, c.banned, c.playtime, c.money, d.value AS charBanInfo
FROM lia_characters AS c
LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.key = 'charBanInfo']], function(data)
        local payload = {
            all = {},
            players = {}
        }

        for _, row in ipairs(data or {}) do
            local stored = lia.char.getCharacter(row.id)
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
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestAllFlags", "hasPrivilege(manageFlags)=", tostring(client:hasPrivilege("manageFlags")), "finalResult=", tostring(client:hasPrivilege("manageFlags")))
    if not client:hasPrivilege("manageFlags") then return end
    lia.db.fieldExists("lia_characters", "charflags"):next(function(exists)
        if not exists then lia.db.query("ALTER TABLE lia_characters ADD COLUMN charflags VARCHAR(255) DEFAULT ''") end
        lia.db.query([[SELECT c.id, c.name, c.steamID, COALESCE(c.charflags, '') AS flags
FROM lia_characters AS c]], function(charData)
            lia.db.query([[SELECT d.charID, d.value AS flags
FROM lia_chardata AS d
WHERE d.key = 'flags']], function(chardata)
                local chardataFlags = {}
                for _, row in ipairs(chardata or {}) do
                    if row.value and row.value ~= "" then
                        local ok, decoded = pcall(pon.decode, row.value)
                        if ok and decoded then chardataFlags[row.charID] = decoded[1] or "" end
                    end
                end

                local processedData = {}
                for _, row in ipairs(charData or {}) do
                    local char = lia.char.loaded[row.id]
                    local flags = row.flags or ""
                    if flags == "" and chardataFlags[row.id] then flags = chardataFlags[row.id] end
                    if char then
                        local memoryFlags = char:getFlags() or ""
                        if memoryFlags ~= "" then flags = memoryFlags end
                    end

                    processedData[#processedData + 1] = {
                        name = row.name or "",
                        steamID = row.steamID or "",
                        flags = flags,
                    }
                end

                lia.net.writeBigTable(client, "liaAllFlags", processedData)
            end)
        end)
    end)
end)

net.Receive("liaModifyFlags", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaModifyFlags", "hasPrivilege(manageFlags)=", tostring(client:hasPrivilege("manageFlags")), "finalResult=", tostring(client:hasPrivilege("manageFlags")))
    if not client:hasPrivilege("manageFlags") then return end
    local steamID = net.ReadString()
    local flags = net.ReadString()
    flags = string.gsub(flags or "", "%s", "")
    local target = lia.util.findPlayerBySteamID(steamID)
    if IsValid(target) then
        local char = target:getChar()
        if not char then return end
        char:setFlags(flags)
        client:notifySuccessLocalized("flagSet", client:Name(), target:Name(), flags)
        return
    end

    lia.db.query("SELECT id, name FROM lia_characters WHERE steamID = " .. lia.db.convertDataType(steamID) .. " LIMIT 1", function(data)
        if not data or not data[1] then
            client:notifyLocalized("playerNotFound")
            return
        end

        local charID = data[1].id
        local charName = data[1].name
        lia.char.setCharDatabase(charID, "flags", flags)
        client:notifySuccessLocalized("flagSet", client:Name(), charName, flags)
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
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestStaffSummary", "hasPrivilege(viewStaffManagement)=", tostring(client:hasPrivilege("viewStaffManagement")), "finalResult=", tostring(client:hasPrivilege("viewStaffManagement")))
    if not client:hasPrivilege("viewStaffManagement") then return end
    buildSummary():next(function(data) lia.net.writeBigTable(client, "liaStaffSummary", data) end)
end)

net.Receive("liaRequestPlayers", function(_, client)
    if not client:hasPrivilege("canAccessPlayerList") then return end
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

net.Receive("liaRequestMapEntities", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestMapEntities", "hasPrivilege(manageCharacters)=", tostring(client:hasPrivilege("manageCharacters")), "finalResult=", tostring(client:hasPrivilege("manageCharacters")))
    if not client:hasPrivilege("manageCharacters") then return end
    local entities = {}
    for _, entity in ents.Iterator() do
        if IsValid(entity) and (entity:CreatedByMap() or entity:isDoor() or entity:isProp()) then
            entities[#entities + 1] = {
                class = entity:GetClass(),
                model = entity:GetModel(),
                name = entity:GetName() or entity.PrintName or "",
                position = tostring(entity:GetPos()),
                angles = tostring(entity:GetAngles()),
                mapCreated = entity:CreatedByMap(),
                isDoor = entity:isDoor(),
                isProp = entity:isProp(),
                health = entity:Health(),
                maxHealth = entity:GetMaxHealth(),
                material = entity:GetMaterial(),
                skin = entity:GetSkin(),
                color = entity:GetColor()
            }
        end
    end

    lia.net.writeBigTable(client, "liaMapEntities", entities)
end)

net.Receive("liaRequestOnlineStaffData", function(_, client)
    local d = deferred.new()
    local staffData = {}
    for _, ply in player.Iterator() do
        if IsValid(ply) and ply:isStaff() then
            local char = ply:getChar()
            local charID = char and char:getID() or 0
            local steamID = ply:SteamID()
            local usergroup = ply:GetUserGroup()
            local isStaffOnDuty = ply:isStaffOnDuty()
            local characterName = char and char:getName() or "N/A"
            staffData[#staffData + 1] = {
                steamID = steamID,
                charID = charID,
                name = ply:Nick(),
                usergroup = usergroup,
                isStaffOnDuty = isStaffOnDuty,
                characterName = characterName,
                tickets = 0,
                warnings = 0
            }
        end
    end

    if #staffData == 0 then
        net.Start("liaOnlineStaffData")
        net.WriteTable({})
        net.Send(client)
        return
    end

    local completedQueries = 0
    local totalQueries = #staffData * 2
    for i, staffInfo in ipairs(staffData) do
        local charID = staffInfo.charID
        local steamID = staffInfo.steamID
        if charID and charID > 0 then
            lia.db.count("warnings", "charID = " .. lia.db.convertDataType(charID)):next(function(count)
                staffData[i].warnings = count or 0
                completedQueries = completedQueries + 1
                if completedQueries >= totalQueries then d:resolve(staffData) end
            end)
        else
            completedQueries = completedQueries + 1
        end

        if steamID and steamID ~= "" then
            lia.db.count("ticketclaims", "requesterSteamID = " .. lia.db.convertDataType(steamID)):next(function(count)
                staffData[i].tickets = count or 0
                completedQueries = completedQueries + 1
                if completedQueries >= totalQueries then d:resolve(staffData) end
            end)
        else
            completedQueries = completedQueries + 1
        end
    end

    d:next(function(data)
        net.Start("liaOnlineStaffData")
        net.WriteTable(data)
        net.Send(client)
    end)
end)
