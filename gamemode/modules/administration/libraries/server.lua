local ActiveTickets = {}
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

function MODULE:PlayerSay(client, text)
    if text and string.sub(text, 1, 1) == "@" then
        local message = string.sub(text, 2)
        ClientAddText(client, Color(70, 0, 130), L("you"), Color(151, 211, 255), " " .. L("ticketMessageToAdmins") .. ": ", Color(0, 255, 0), message)
        self:SendPopup(client, message)
        return ""
    end

    if client:getLiliaData("liaMuted", false) then return "" end
end

function MODULE:PlayerSpawn(client)
    if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
    lia.log.add(client, "playerSpawn")
end

function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege("alwaysSpawnAdminStick") or client:isStaffOnDuty() then client:Give("lia_adminstick") end
end

local spawnCooldowns = {}
net.Receive("liaSpawnMenuSpawnItem", function(_, client)
    local id = net.ReadString()
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
    if not client:hasPrivilege("canUseItemSpawner") then return end
    local targetChar = lia.char.getBySteamID(targetID)
    if not targetChar then return end
    local target = targetChar:getPlayer()
    targetChar:getInv():add(id)
    lia.log.add(client, "chargiveItem", id, target, "SpawnMenuGiveItem")
end)

local function CanPlayerSeeLog(client)
    return lia.config.get("AdminConsoleNetworkLogs", true) and client:hasPrivilege("canSeeLogs")
end

local function ReadLogEntries(category, page)
    local d = deferred.new()
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local logsPerPage = lia.config.get("logsPerPage", 50)
    local cutoff = os.time() - maxDays * 86400
    local cutoffStr = os.date("%Y-%m-%d %H:%M:%S", cutoff)
    local countCondition = table.concat({"gamemode = " .. lia.db.convertDataType(engine.ActiveGamemode()), "category = " .. lia.db.convertDataType(category), "timestamp >= " .. lia.db.convertDataType(cutoffStr)}, " AND ")
    lia.db.count("logs", countCondition):next(function(totalCount)
        local offset = (page - 1) * logsPerPage
        local limit = logsPerPage
        local condition = countCondition .. " ORDER BY id DESC LIMIT " .. limit .. " OFFSET " .. offset
        lia.db.select({"timestamp", "message", "steamID"}, "logs", condition):next(function(res)
            local rows = res.results or {}
            local logs = {}
            for _, row in ipairs(rows) do
                logs[#logs + 1] = {
                    timestamp = row.timestamp,
                    message = row.message,
                    steamID = row.steamID
                }
            end

            d:resolve({
                logs = logs,
                totalCount = totalCount,
                totalPages = math.max(1, math.ceil(totalCount / logsPerPage)),
                currentPage = page,
                category = category
            })
        end)
    end)
    return d
end

net.Receive("liaSendLogsRequest", function(_, client)
    if not CanPlayerSeeLog(client) then return end
    local category = net.ReadString()
    local page = net.ReadUInt(16)
    if hook.Run("CanPlayerSeeLogCategory", client, category) == false then return end
    ReadLogEntries(category, page):next(function(result) lia.net.writeBigTable(client, "liaSendLogs", result) end)
end)

net.Receive("liaSendLogsCategoriesRequest", function(_, client)
    if not CanPlayerSeeLog(client) then return end
    local categories = {}
    for _, v in pairs(lia.log.types) do
        categories[v.category or L("uncategorized")] = true
    end

    local catList = {}
    for k in pairs(categories) do
        if hook.Run("CanPlayerSeeLogCategory", client, k) ~= false then catList[#catList + 1] = k end
    end

    net.Start("liaSendLogsCategories")
    net.WriteTable(catList)
    net.Send(client)
end)

function MODULE:OnCharDelete(client, id)
    lia.log.add(client, "charDelete", id)
end

function MODULE:OnPlayerInteractItem(client, action, item, result)
    if isentity(item) then
        if IsValid(item) then
            local itemID = item.liaItemID
            item = lia.item.instances[itemID]
        else
            return
        end
    elseif isnumber(item) then
        item = lia.item.instances[item]
    end

    action = string.lower(action)
    if not item then return end
    local name = item.name
    if result == false then
        lia.log.add(client, "itemInteractionFailed", action, name)
        return
    end

    if action == "use" then
        lia.log.add(client, "use", name)
    elseif action == "drop" then
        lia.log.add(client, "itemDrop", name)
    elseif action == "take" then
        lia.log.add(client, "itemTake", name)
    elseif action == "unequip" then
        lia.log.add(client, "itemUnequip", name)
    elseif action == "equip" then
        lia.log.add(client, "itemEquip", name)
    else
        lia.log.add(client, "itemInteraction", action, item)
    end
end

function MODULE:PlayerConnect(name, ip)
    lia.log.add(nil, "playerConnect", name, ip)
end

function MODULE:PlayerInitialSpawn(client)
    lia.log.add(client, "playerInitialSpawn")
end

function MODULE:PlayerDisconnected(client)
    lia.log.add(client, "playerDisconnected")
end

function MODULE:PlayerHurt(client, attacker, health, damage)
    if IsValid(attacker) then
        lia.log.add(client, "playerHurt", attacker:IsPlayer() and attacker:Name() or attacker:GetClass(), damage, health)
    else
        lia.log.add(client, "playerHurt", "unknown", damage, health)
    end
end

function MODULE:PlayerDeath(client, _, attacker)
    if IsValid(attacker) then
        lia.log.add(client, "playerDeath", attacker:IsPlayer() and attacker:Name() or attacker:GetClass())
    else
        lia.log.add(client, "playerDeath", "unknown")
    end
end

function MODULE:OnCharCreated(client, character)
    lia.log.add(client, "charCreate", character)
end

function MODULE:PostPlayerLoadedChar(client, character)
    lia.log.add(client, "charLoad", character:getName(), character:getID())
end

function MODULE:PlayerSpawnedProp(client, model)
    lia.log.add(client, "spawned_prop", model)
end

function MODULE:PlayerSpawnedRagdoll(client, model)
    lia.log.add(client, "spawned_ragdoll", model)
end

function MODULE:PlayerSpawnedEffect(client, model)
    lia.log.add(client, "spawned_effect", model)
end

function MODULE:PlayerSpawnedVehicle(client, vehicle)
    lia.log.add(client, "spawned_vehicle", vehicle:GetClass(), vehicle:GetModel())
end

function MODULE:PlayerSpawnedNPC(client, npc)
    lia.log.add(client, "spawned_npc", npc:GetClass(), npc:GetModel())
end

function MODULE:PlayerSpawnedSENT(client, sent)
    lia.log.add(client, "spawned_sent", sent:GetClass(), sent:GetModel())
end

function MODULE:PlayerGiveSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:PlayerSpawnSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:CanTool(client, trace, tool)
    local entity = trace.Entity
    local entityInfo = "none"
    if IsValid(entity) then
        if entity:IsPlayer() then
            entityInfo = "player:" .. entity:Name()
        elseif entity:IsNPC() then
            entityInfo = "npc:" .. entity:GetClass()
        elseif entity:IsVehicle() then
            entityInfo = "vehicle:" .. entity:GetClass()
        else
            entityInfo = "entity:" .. entity:GetClass()
        end
    end

    lia.log.add(client, "toolgunUse", tool, entityInfo)
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, "observeToggle", state and L("enabled") or L("disabled"))
end

function MODULE:TicketSystemClaim(admin, requester)
    lia.db.count("ticketclaims", "adminSteamID = " .. lia.db.convertDataType(admin:SteamID())):next(function(count) lia.log.add(admin, "ticketClaimed", requester:Name(), count) end)
    local ticket = ActiveTickets[requester:SteamID()]
    lia.db.insertTable({
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        requester = requester:Nick(),
        requesterSteamID = requester:SteamID(),
        admin = admin:Nick(),
        adminSteamID = admin:SteamID(),
        message = ticket and ticket.message or ""
    }, nil, "ticketclaims")

    local requesterInfo = requester:Name() .. " (Steam64ID: " .. requester:SteamID64() .. ")"
    local adminInfo = admin:Name() .. " (Steam64ID: " .. admin:SteamID64() .. ")"
    StaffAddTextShadowed(Color(0, 191, 255), "TICKET", Color(255, 255, 255), adminInfo .. " claimed a ticket from " .. requesterInfo)
end

function MODULE:TicketSystemClose(admin, requester)
    lia.db.count("ticketclaims", "adminSteamID = " .. lia.db.convertDataType(admin:SteamID())):next(function(count) lia.log.add(admin, "ticketClosed", requester:Name(), count) end)
end

function MODULE:WarningIssued(admin, target, reason, severity, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningIssued", target, reason, severity or "Medium", count, index) end)
end

function MODULE:WarningRemoved(admin, target, warning, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningRemoved", target, warning, count, index) end)
end

function MODULE:ItemTransfered(context)
    local client = context.client
    local item = context.item
    if not (IsValid(client) and item) then return end
    local fromID = context.from and context.from:getID() or 0
    local toID = context.to and context.to:getID() or 0
    lia.log.add(client, "itemTransfer", item:getName(), fromID, toID)
end

function MODULE:OnItemAdded(owner, item)
    lia.log.add(owner, "itemAdded", item:getName())
end

function MODULE:ItemFunctionCalled(item, action, client)
    if not action then return end
    local lowered = string.lower(action)
    if lowered == "onloadout" or lowered == "onsave" then return end
    if IsValid(client) then lia.log.add(client, "itemFunction", action, item:getName()) end
end

function MODULE:ItemDraggedOutOfInventory(client, item)
    lia.log.add(client, "itemDraggedOut", item:getName())
end

net.Receive("liaCfgSet", function(_, client)
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

        client:notifySuccessLocalized("cfgSet", client:Name(), name, tostring(value))
        lia.log.add(client, "configChange", name, tostring(oldValue), tostring(value))
    end
end)

net.Receive("liaManagesitroomsAction", function(_, client)
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
            local message = client:Name() .. " (Steam64ID: " .. client:SteamID64() .. ") teleported to sit room \"" .. name .. "\"."
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

net.Receive("liaRequestAllPks", function(_, client)
    if not client:hasPrivilege("manageCharacters") then return end
    lia.db.query("SELECT * FROM lia_permakills", function(data)
        net.Start("liaAllPks")
        net.WriteTable(data or {})
        net.Send(client)
    end)
end)

net.Receive("liaRequestPksCount", function(_, client)
    if not client:hasPrivilege("manageCharacters") then return end
    lia.db.count("permakills"):next(function(count)
        net.Start("liaPksCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)

function MODULE:PlayerShouldPermaKill(client)
    local character = client:getChar()
    if not character then return false end
    return character:getData("permakilled", false)
end

net.Receive("liaRequestFullCharList", function(_, client)
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

local GM = GM or GAMEMODE
local restrictedProperties = {
    persist = true,
    drive = true,
    bonemanipulate = true
}

function GM:PlayerSpawnProp(client, model)
    local list = lia.data.get("prop_blacklist", {})
    if table.HasValue(list, model) and not client:hasPrivilege("canSpawnBlacklistedProps") then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyErrorLocalized("blacklistedProp")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnProps") or client:hasFlags("e")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyErrorLocalized("noSpawnPropsPerm", model)
    end
    return canSpawn
end

local propertyPrivilegeEquivalents = {
    bodygroups = "property_bodygroups",
    bonemanipulate = "property_bonemanipulate",
    collision = "property_collision",
    drive = "property_drive",
    editentity = "canEditSimfphysCars",
    gravity = "property_gravity",
    ignite = "property_ignite",
    extinguish = "property_extinguish",
    keepupright = "property_keepupright",
    motioncontrol_ragdoll = "property_motioncontrol_ragdoll",
    npc_bigger = "property_npc_bigger",
    npc_smaller = "property_npc_smaller",
    persist = "property_persist",
    remover = "property_remove",
    skin = "property_skin",
    statue = "property_statue",
    unstatue = "property_unstatue",
    color = "property_color",
    material = "property_material"
}

function GM:CanProperty(client, property, entity)
    if restrictedProperties[property] then
        lia.log.add(client, "permissionDenied", L("useProperty", property))
        client:notifyErrorLocalized("disabledFeature")
        return false
    end

    if IsValid(entity) and entity:IsWorld() then
        if client:hasPrivilege("canPropertyWorldEntities") then return true end
        lia.log.add(client, "permissionDenied", L("modifyWorldProperty", property))
        client:notifyErrorLocalized("noModifyWorldEntities")
        return false
    end

    if IsValid(entity) and entity:GetCreator() == client and (property == "remove" or property == "collision") then return true end
    local privilegeName = propertyPrivilegeEquivalents[property] or "property_" .. property
    if client:hasPrivilege(privilegeName) or client:isStaffOnDuty() then return true end
    lia.log.add(client, "permissionDenied", L("modifyProperty", property))
    client:notifyErrorLocalized("noModifyProperty")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:GetMoveType() == MOVETYPE_NOCLIP then return false end
end

function GM:PlayerSpawnVehicle(client, model)
    if not client:hasPrivilege("noCarSpawnDelay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local list = lia.data.get("carBlacklist", {})
    if model and table.HasValue(list, model) and not client:hasPrivilege("canSpawnBlacklistedCars") then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyErrorLocalized("blacklistedVehicle")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnCars") or client:hasFlags("C")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyErrorLocalized("noSpawnVehicles", model)
    end
    return canSpawn
end

function GM:PlayerSpawnEffect(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnEffects") or client:hasFlags("L")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("effect"))
        client:notifyErrorLocalized("noSpawnEffects")
    end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnNPCs") or client:hasFlags("n")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("npc"))
        client:notifyErrorLocalized("noSpawnNPCs")
    end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnRagdolls") or client:hasFlags("r")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("ragdoll"))
        client:notifyErrorLocalized("noSpawnRagdolls")
    end
    return canSpawn
end

function GM:PlayerSpawnSENT(client, class)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSENTs") or client:hasFlags("E")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("sent"), tostring(class))
        client:notifyErrorLocalized("noSpawnSents", tostring(class))
    end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client, weapon)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("z")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("swep"), tostring(weapon))
        client:notifyErrorLocalized("noSpawnSweps", tostring(weapon))
    end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("W")
    if not canGive then
        lia.log.add(client, "permissionDenied", L("giveSwep"))
        client:notifyErrorLocalized("noGiveSweps")
    end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("canPhysgunReload")
    if not canReload then
        lia.log.add(client, "permissionDenied", L("physgunReload"))
        client:notifyErrorLocalized("noPhysgunReload")
    end
    return canReload
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
    entity:SetCreator(client)
end

function GM:CanPlayerUseChar(client)
    if GetGlobalBool("characterSwapLock", false) and not client:hasPrivilege("canBypassCharacterLock") then return false, L("serverEventCharLock") end
end

local function buildClaimTable(rows)
    local caseclaims = {}
    for _, row in ipairs(rows or {}) do
        local adminID = row.adminSteamID
        caseclaims[adminID] = caseclaims[adminID] or {
            name = row.admin,
            claims = 0,
            lastclaim = 0,
            claimedFor = {}
        }

        local info = caseclaims[adminID]
        info.claims = info.claims + 1
        local rowTime = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp))
        if rowTime > info.lastclaim then info.lastclaim = rowTime end
        local reqPly = lia.util.getBySteamID(row.requesterSteamID)
        info.claimedFor[row.requesterSteamID] = IsValid(reqPly) and reqPly:Nick() or row.requester
    end

    for adminID, info in pairs(caseclaims) do
        local ply = lia.util.getBySteamID(adminID)
        if IsValid(ply) then info.name = ply:Nick() end
    end
    return caseclaims
end

function MODULE:GetAllCaseClaims()
    return lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims"):next(function(res) return buildClaimTable(res.results) end)
end

function MODULE:GetTicketsByRequester(steamID)
    local condition = "requesterSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims", condition):next(function(res)
        local tickets = {}
        for _, row in ipairs(res.results or {}) do
            tickets[#tickets + 1] = {
                timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                requester = row.requester,
                requesterSteamID = row.requesterSteamID,
                admin = row.admin,
                adminSteamID = row.adminSteamID,
                message = row.message
            }
        end
        return tickets
    end)
end

function MODULE:OnReloaded()
    for steamID, _ in pairs(ActiveTickets) do
        ActiveTickets[steamID] = nil
    end

    timer.Simple(0.05, function()
        net.Start("liaClearAllTicketFrames")
        net.Broadcast()
    end)
end

function MODULE:PlayerDisconnected(client)
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("liaTicketSystemClose")
            net.WriteEntity(client)
            net.Send(v)
        end
    end

    ActiveTickets[client:SteamID()] = nil
end

function MODULE:SendPopup(noob, message)
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("liaTicketSystem")
            net.WriteEntity(noob)
            net.WriteString(message)
            net.WriteEntity(noob.CaseClaimed)
            net.Send(v)
        end
    end

    if IsValid(noob) and noob:IsPlayer() then
        local requesterSteamID = noob:SteamID()
        ActiveTickets[requesterSteamID] = {
            timestamp = os.time(),
            requester = requesterSteamID,
            admin = noob.CaseClaimed and IsValid(noob.CaseClaimed) and noob.CaseClaimed:SteamID() or nil,
            message = message
        }

        hook.Run("TicketSystemCreated", noob, message)
        hook.Run("OnTicketCreated", noob, message)
        timer.Remove("ticketsystem-" .. requesterSteamID)
        timer.Create("ticketsystem-" .. requesterSteamID, 60, 1, function()
            if IsValid(noob) and noob:IsPlayer() then noob.CaseClaimed = nil end
            ActiveTickets[requesterSteamID] = nil
        end)
    end
end

net.Receive("liaViewClaims", function(_, client)
    local sid = net.ReadString()
    MODULE:GetAllCaseClaims():next(function(caseclaims)
        net.Start("liaViewClaims")
        net.WriteTable(caseclaims)
        net.WriteString(sid)
        net.Send(client)
    end)
end)

net.Receive("liaTicketSystemClaim", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    if (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) and not requester.CaseClaimed then
        for _, v in player.Iterator() do
            if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
                net.Start("liaTicketSystemClaim")
                net.WriteEntity(client)
                net.WriteEntity(requester)
                net.Send(v)
            end
        end

        local ticketMessage = ""
        local t = ActiveTickets[requester:SteamID()]
        if t then
            ticketMessage = t.message or ""
            t.admin = client:SteamID()
        end

        hook.Run("TicketSystemClaim", client, requester, ticketMessage)
        hook.Run("OnTicketClaimed", client, requester, ticketMessage)
        requester.CaseClaimed = client
    end
end)

net.Receive("liaTicketSystemClose", function(_, client)
    local requester = net.ReadEntity()
    if client == requester then
        client:notifyErrorLocalized("ticketActionSelf")
        return
    end

    if not requester or not IsValid(requester) or requester.CaseClaimed ~= client then return end
    if timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    for _, v in player.Iterator() do
        if v:hasPrivilege("alwaysSeeTickets") or v:isStaffOnDuty() then
            net.Start("liaTicketSystemClose")
            net.WriteEntity(requester)
            net.Send(v)
        end
    end

    local ticketMessage = ""
    local t = ActiveTickets[requester:SteamID()]
    if t then ticketMessage = t.message or "" end
    hook.Run("TicketSystemClose", client, requester, ticketMessage)
    hook.Run("OnTicketClosed", client, requester, ticketMessage)
    requester.CaseClaimed = nil
    ActiveTickets[requester:SteamID()] = nil
end)

net.Receive("liaRequestActiveTickets", function(_, client)
    if not (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) then return end
    lia.db.select({"timestamp", "requesterSteamID", "adminSteamID", "message"}, "ticketclaims"):next(function(res)
        local tickets = {}
        for _, row in ipairs(res.results or {}) do
            tickets[#tickets + 1] = {
                requester = row.requesterSteamID,
                timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                admin = row.adminSteamID,
                message = row.message,
            }
        end

        net.Start("liaActiveTickets")
        net.WriteTable(tickets)
        net.Send(client)
    end)
end)

net.Receive("liaRequestTicketsCount", function(_, client)
    if not (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) then return end
    lia.db.count("ticketclaims"):next(function(count)
        net.Start("liaTicketsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)

function MODULE:GetWarnings(charID)
    local condition = "charID = " .. lia.db.convertDataType(charID)
    return lia.db.select({"id", "timestamp", "message", "warner", "warnerSteamID", "severity"}, "warnings", condition):next(function(res) return res.results or {} end)
end

function MODULE:GetWarningsByIssuer(steamID)
    local condition = "warnerSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"id", "timestamp", "message", "warned", "warnedSteamID", "warner", "warnerSteamID", "severity"}, "warnings", condition):next(function(res) return res.results or {} end)
end

function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
    local finalSeverity = severity or "Medium"
    lia.db.insertTable({
        charID = charID,
        warned = warned,
        warnedSteamID = warnedSteamID,
        timestamp = timestamp,
        message = message,
        warner = warner,
        warnerSteamID = warnerSteamID,
        severity = finalSeverity
    }, nil, "warnings")
    return finalSeverity
end

function MODULE:RemoveWarning(charID, index)
    local d = deferred.new()
    self:GetWarnings(charID):next(function(rows)
        if index < 1 or index > #rows then return d:resolve(nil) end
        local row = rows[index]
        lia.db.delete("warnings", "id = " .. lia.db.convertDataType(row.id)):next(function() d:resolve(row) end)
    end)
    return d
end

net.Receive("liaRequestRemoveWarning", function(_, client)
    if not client:hasPrivilege("canRemoveWarns") then return end
    local charID = net.ReadInt(32)
    local rowData = net.ReadTable()
    local warnIndex = tonumber(rowData.ID or rowData.index)
    if not warnIndex then
        client:notifyErrorLocalized("invalidWarningIndex")
        return
    end

    lia.char.getCharacter(charID, client, function(targetChar)
        if not targetChar then
            client:notifyErrorLocalized("characterNotFound")
            return
        end

        local targetClient = targetChar:getPlayer()
        if not IsValid(targetClient) then
            client:notifyErrorLocalized("playerNotFound")
            return
        end

        MODULE:RemoveWarning(charID, warnIndex):next(function(warn)
            if not warn then
                client:notifyErrorLocalized("invalidWarningIndex")
                return
            end

            targetClient:notifyInfoLocalized("warningRemovedNotify", client:Nick())
            client:notifySuccessLocalized("warningRemoved", warnIndex, targetClient:Nick())
            hook.Run("WarningRemoved", client, targetClient, {
                reason = warn.message,
                admin = warn.warner,
                adminSteamID = warn.warnerSteamID,
                targetSteamID = targetClient:SteamID()
            }, warnIndex)
        end)
    end)
end)

net.Receive("liaRequestAllWarnings", function(_, client)
    if not client:hasPrivilege("viewPlayerWarnings") then return end
    lia.db.select({"timestamp", "warned", "warnedSteamID", "warner", "warnerSteamID", "message", "severity"}, "warnings"):next(function(res)
        net.Start("liaAllWarnings")
        net.WriteTable(res.results or {})
        net.Send(client)
    end)
end)

net.Receive("liaRequestWarningsCount", function(_, client)
    if not client:hasPrivilege("viewPlayerWarnings") then return end
    lia.db.count("warnings"):next(function(count)
        net.Start("liaWarningsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)

hook.Add("PhysgunPickup", "Lilia.PhysgunPickup", function(client, entity)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end

    if (client:hasPrivilege("physgunPickup") or client:isStaffOnDuty()) and entity.NoPhysgun then
        if not client:hasPrivilege("physgunPickupRestrictedEntities") then
            lia.log.add(client, "permissionDenied", L("physgunRestrictedEntity"))
            client:notifyErrorLocalized("noPickupRestricted")
            return false
        end
        return true
    end

    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:hasPrivilege("physgunPickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("physgunPickupVehicles") then
                lia.log.add(client, "permissionDenied", L("physgunVehicle"))
                client:notifyErrorLocalized("noPickupVehicles")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("cantBeGrabbedPhysgun") or not client:hasPrivilege("canGrabPlayers") then
                lia.log.add(client, "permissionDenied", L("physgunPlayer"))
                client:notifyErrorLocalized("noPickupPlayer")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("canGrabWorldProps") then
                lia.log.add(client, "permissionDenied", L("physgunWorldProp"))
                client:notifyErrorLocalized("noPickupWorld")
                return false
            end
            return true
        end
        return true
    end

    lia.log.add(client, "permissionDenied", L("physgunEntity"))
    client:notifyErrorLocalized("noPickupEntity")
    return false
end)

local DisallowedTools = {
    rope = true,
    light = true,
    lamp = true,
    dynamite = true,
    physprop = true,
    faceposer = true,
    stacker = true
}

hook.Add("CanTool", "Lilia.CanTool", function(client, trace, tool)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end

    local function CheckDuplicationScale(ply, entities)
        entities = entities or {}
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                ply:notifyErrorLocalized("duplicationSizeLimit")
                lia.log.add(ply, "dupeCrashAttempt")
                return false
            end

            v.ModelScale = 1
        end
        return true
    end

    if DisallowedTools[tool] and not client:hasPrivilege("useDisallowedTools") then
        lia.log.add(client, "toolDenied", tool)
        client:notifyErrorLocalized("toolNotAllowed", tool)
        return false
    end

    local formattedTool = tool:gsub("^%l", string.upper)
    local isStaffOrFlagged = client:isStaffOnDuty() or client:hasFlags("t")
    local hasPriv = client:hasPrivilege("tool_" .. tool)
    if not (isStaffOrFlagged and hasPriv) then
        local reasons = {}
        if not isStaffOrFlagged then table.insert(reasons, L("onDutyStaffOrFlagT")) end
        if not hasPriv then table.insert(reasons, L("privilege") .. " '" .. L("accessToolPrivilege", formattedTool) .. "'") end
        lia.log.add(client, "toolDenied", tool)
        client:notifyErrorLocalized("toolNoPermission", tool, table.concat(reasons, ", "))
        return false
    end

    local entity = trace.Entity
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if entity.NoRemover then
                if not client:hasPrivilege("canRemoveBlockedEntities") then
                    lia.log.add(client, "permissionDenied", L("removeBlockedEntity"))
                    client:notifyErrorLocalized("noRemoveBlockedEntities")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("canRemoveWorldEntities") then
                    lia.log.add(client, "permissionDenied", L("removeWorldEntity"))
                    client:notifyErrorLocalized("noRemoveWorldEntities")
                    return false
                end
                return true
            end
            return true
        end

        if (tool == "permaall" or tool == "blacklistandremove") and hook.Run("CanPersistEntity", entity) ~= false and (string.StartWith(entClass, "lia_") or entity.IsPersistent or entity:CreatedByMap()) then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("toolCantUseEntity", tool)
            return false
        end

        if (tool == "duplicator" or tool == "blacklistandremove") and entity.NoDuplicate then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("cannotDuplicateEntity", tool)
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("cannotWeldBall")
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    return true
end)

hook.Add("GravGunPickupAllowed", "Lilia.GravGunPickupAllowed", function(client)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end
end)

hook.Add("PlayerNoClip", "Lilia.PlayerNoClip", function(ply, enabled)
    if not (ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")) then
        lia.log.add(ply, "permissionDenied", L("noclip"))
        ply:notifyErrorLocalized("noNoclip")
        return false
    end

    ply:SetNoDraw(enabled)
    ply:SetNotSolid(enabled)
    ply:DrawWorldModel(not enabled)
    ply:DrawShadow(enabled)
    ply:SetNoTarget(enabled)
    if enabled then
        ply:GodEnable()
        ply:AddFlags(FL_NOTARGET)
    else
        ply:GodDisable()
        ply:RemoveFlags(FL_NOTARGET)
    end

    hook.Run("OnPlayerObserve", ply, enabled)
    return true
end)
