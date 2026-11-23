local spawnCooldowns = {}
local validToolTiers = {
    disabled = true,
    staff = true,
    basic = true
}

lia.staffCharacterPermissions = lia.data.get("staffCharacterPermissions", {})
lia.staffCharacterFlags = lia.data.get("staffCharacterFlags", {})
local function hasStaffCharacterConfigurationAccess(client)
    return IsValid(client) and lia.admin.hasAccess(client, "manageUsergroups")
end

local function getStaffCharacterConfiguration()
    local privileges, flags = {}, {}
    for id in pairs(lia.admin.privilegeNames or {}) do
        privileges[id] = true
    end

    for id in pairs(lia.admin.privileges or {}) do
        privileges[id] = true
    end

    for id, data in pairs(lia.flag.list or {}) do
        flags[id] = data.desc or data.description or id
    end
    return {
        permissions = lia.staffCharacterPermissions or {},
        flags = lia.staffCharacterFlags or {},
        privileges = privileges,
        flagDefinitions = flags
    }
end

local function sendStaffCharacterConfiguration(client)
    net.Start("liaStaffCharacterConfiguration")
    net.WriteTable(getStaffCharacterConfiguration())
    net.Send(client)
end

net.Receive("liaRequestStaffCharacterConfiguration", function(_, client) if hasStaffCharacterConfigurationAccess(client) then sendStaffCharacterConfiguration(client) end end)
net.Receive("liaSetStaffCharacterPermission", function(_, client)
    if not hasStaffCharacterConfigurationAccess(client) then return end
    local permission, enabled = lia.admin.normalizePrivilege(string.Trim(net.ReadString() or "")), net.ReadBool()
    if permission == "" or not (lia.admin.privilegeNames[permission] or lia.admin.privileges[permission]) then return end
    lia.staffCharacterPermissions[permission] = enabled and true or nil
    lia.data.set("staffCharacterPermissions", lia.staffCharacterPermissions, true, true)
    sendStaffCharacterConfiguration(client)
end)

net.Receive("liaSetStaffCharacterFlag", function(_, client)
    if not hasStaffCharacterConfigurationAccess(client) then return end
    local flag, enabled = net.ReadString(), net.ReadBool()
    if #flag ~= 1 or not lia.flag.list[flag] then return end
    lia.staffCharacterFlags[flag] = enabled and true or nil
    lia.data.set("staffCharacterFlags", lia.staffCharacterFlags, true, true)
    sendStaffCharacterConfiguration(client)
end)

net.Receive("liaResetStaffCharacterConfiguration", function(_, client)
    if not hasStaffCharacterConfigurationAccess(client) then return end
    lia.staffCharacterPermissions, lia.staffCharacterFlags = {}, {}
    lia.data.set("staffCharacterPermissions", {}, true, true)
    lia.data.set("staffCharacterFlags", {}, true, true)
    sendStaffCharacterConfiguration(client)
end)

local function getToolNames()
    local names, seen = {}, {}
    for _, weapon in ipairs(weapons.GetList()) do
        if weapon.ClassName == "gmod_tool" and istable(weapon.Tool) then
            for toolName in pairs(weapon.Tool) do
                toolName = string.lower(tostring(toolName))
                if not seen[toolName] then
                    seen[toolName] = true
                    names[#names + 1] = toolName
                end
            end
        end
    end

    table.sort(names)
    return names
end

local function sendToolPermissionTiers(client)
    net.Start("liaToolPermissionTiers")
    net.WriteTable({
        tools = getToolNames(),
        tiers = lia.data.get("toolPermissionTiers", {})
    })

    net.Send(client)
end

net.Receive("liaRequestToolPermissionTiers", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    sendToolPermissionTiers(client)
end)

net.Receive("liaSetToolPermissionTier", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    local toolName = string.lower(string.Trim(net.ReadString() or ""))
    local tier = net.ReadString()
    if toolName == "" or not validToolTiers[tier] or not table.HasValue(getToolNames(), toolName) then return end
    local tiers = lia.data.get("toolPermissionTiers", {})
    tiers[toolName] = tier
    lia.data.set("toolPermissionTiers", tiers, true, true)
    sendToolPermissionTiers(client)
end)

net.Receive("liaSetToolPermissionTiersBatch", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    local count = math.min(net.ReadUInt(12), 4095)
    local validTools = {}
    for _, toolName in ipairs(getToolNames()) do
        validTools[toolName] = true
    end

    local tiers = lia.data.get("toolPermissionTiers", {})
    local changed = 0
    for _ = 1, count do
        local toolName = string.lower(string.Trim(net.ReadString() or ""))
        local tier = net.ReadString()
        if validTools[toolName] and validToolTiers[tier] and tiers[toolName] ~= tier then
            tiers[toolName] = tier
            changed = changed + 1
        end
    end

    if changed > 0 then
        lia.data.set("toolPermissionTiers", tiers, true, true)
    end

    sendToolPermissionTiers(client)
end)

net.Receive("liaResetToolPermissionTiers", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    lia.data.set("toolPermissionTiers", {}, true, true)
    sendToolPermissionTiers(client)
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

        undo.Create("Item")
        undo.SetPlayer(client)
        undo.AddEntity(ent)
        local name = lia.item.list[id] and lia.item.list[id].name or id
        undo.SetCustomUndoText(string.format("Undone %s", name))
        undo.Finish(string.format("Item (%s)", name))
        client:notifySuccess(string.format("Item '%s' spawned in the world.", name))
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
    targetChar:getInv():add(id)
end)

local function writeFeaturePositionRadii(positions)
    net.WriteUInt(#positions, 16)
    for i = 1, #positions do
        net.WriteFloat(math.max(0, tonumber(positions[i].radius) or 0))
    end
end

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

            writeFeaturePositionRadii(positions)
            net.Send(client)
        end)
    else
        net.Start("liaFeaturePositions")
        net.WriteString(typeId)
        net.WriteUInt(0, 16)
        writeFeaturePositionRadii({})
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

                    writeFeaturePositionRadii(positions)
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

                    writeFeaturePositionRadii(positions)
                    net.Send(client)
                end)
            end
        end)
    end
end)


net.Receive("liaRequestStaffCases", function(_, client)
    local canSeeTickets = client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()
    local canSeeWarnings = client:hasPrivilege("viewPlayerWarnings")
    local canSeePks = client:hasPrivilege("manageCharacters")
    if not (canSeeTickets or canSeeWarnings or canSeePks) then return end
    local payload = {
        tickets = {},
        warnings = {},
        pks = {}
    }

    local pendingFetches = 0
    local hasSentPayload = false
    local function finishFetch()
        pendingFetches = pendingFetches - 1
        if pendingFetches <= 0 and not hasSentPayload then
            hasSentPayload = true
            lia.net.writeBigTable(client, "liaStaffCasesSnapshot", payload)
        end
    end

    if canSeeTickets then
        local ticketsModule = lia.module.get("tickets")
        local activeTickets = ticketsModule and ticketsModule.ActiveTickets or {}
        for steamID, ticket in pairs(activeTickets or {}) do
            payload.tickets[#payload.tickets + 1] = {
                requester = ticket.requester or steamID,
                requesterSteamID = steamID,
                timestamp = ticket.timestamp or os.time(),
                admin = "",
                adminSteamID = ticket.admin,
                message = ticket.message,
                live = true
            }
        end

        pendingFetches = pendingFetches + 1
        lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims"):next(function(res)
            for _, row in ipairs(res.results or {}) do
                payload.tickets[#payload.tickets + 1] = {
                    requester = row.requester,
                    requesterSteamID = row.requesterSteamID,
                    timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                    admin = row.admin,
                    adminSteamID = row.adminSteamID,
                    message = row.message,
                    live = false
                }
            end

            table.sort(payload.tickets, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
            finishFetch()
        end)
    end

    if canSeePks then
        pendingFetches = pendingFetches + 1
        lia.db.query("SELECT * FROM lia_permakills", function(data)
            payload.pks = data or {}
            finishFetch()
        end)
    end

    if canSeeWarnings then
        pendingFetches = pendingFetches + 1
        lia.db.select({"id", "charID", "timestamp", "warned", "warnedSteamID", "warner", "warnerSteamID", "message", "severity"}, "warnings"):next(function(res)
            payload.warnings = res.results or {}
            finishFetch()
        end)
    end

    if pendingFetches == 0 then lia.net.writeBigTable(client, "liaStaffCasesSnapshot", payload) end
end)

local function buildFullCharListPage(client, requestID, offset, limit)
    lia.db.count("characters"):next(function(total)
        total = tonumber(total) or 0
        if total <= 0 then
            lia.net.writeBigTable(client, "liaFullCharListPage", {
                requestID = requestID,
                total = 0,
                offset = offset,
                limit = limit,
                count = 0,
                done = true,
                players = {}
            })
            return
        end

        local safeOffset = math.max(0, math.min(offset, math.max(total - 1, 0)))
        local safeLimit = math.Clamp(limit, 25, 250)
        local query = string.format([[SELECT c.id, c.name, c.`desc`, c.faction, c.steamID, c.lastJoinTime, c.banned, c.playtime, c.money, COALESCE(c.charflags, '') AS flags, d.value AS charBanInfo, f.value AS chardataFlags
FROM lia_characters AS c
LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.`key` = 'charBanInfo'
LEFT JOIN lia_chardata AS f ON f.charID = c.id AND f.`key` = 'flags'
ORDER BY c.steamID ASC, c.id ASC
LIMIT %d OFFSET %d]], safeLimit, safeOffset)
        lia.db.query(query, function(data)
            local payload = {
                requestID = requestID,
                total = total,
                offset = safeOffset,
                limit = safeLimit,
                count = 0,
                done = false,
                players = {}
            }

            for _, row in ipairs(data or {}) do
                local stored = lia.char.getCharacter(row.id)
                local bannedVal = tonumber(row.banned) or 0
                local isBanned = bannedVal ~= 0 and (bannedVal == -1 or bannedVal > os.time())
                local steamID = tostring(row.steamID)
                local playTime = tonumber(row.playtime) or 0
                local flags = row.flags or ""
                if flags == "" and row.chardataFlags and row.chardataFlags ~= "" then
                    local ok, decoded = pcall(pon.decode, row.chardataFlags)
                    if ok and decoded then
                        flags = decoded[1] or ""
                    else
                        local jsonDecoded = util.JSONToTable(row.chardataFlags)
                        if jsonDecoded then flags = jsonDecoded[1] or jsonDecoded.flags or "" end
                    end
                end

                if stored then
                    local loginTime = stored:getLoginTime() or os.time()
                    playTime = stored:getPlayTime() + os.time() - loginTime
                    local memoryFlags = stored:getFlags() or ""
                    if memoryFlags ~= "" then flags = memoryFlags end
                end

                local entry = {
                    ID = row.id,
                    Name = row.name,
                    Desc = row.desc,
                    Faction = row.faction,
                    SteamID = steamID,
                    LastUsed = stored and "Online now" or row.lastJoinTime,
                    Banned = isBanned,
                    PlayTime = playTime,
                    Money = tonumber(row.money) or 0,
                    Flags = flags
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
                payload.count = payload.count + 1
                payload.players[steamID] = payload.players[steamID] or {}
                payload.players[steamID][#payload.players[steamID] + 1] = entry
            end

            payload.done = safeOffset + payload.count >= total
            lia.net.writeBigTable(client, "liaFullCharListPage", payload)
        end)
    end)
end


net.Receive("liaRequestFullCharListPage", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestFullCharListPage", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(listCharacters)=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false), "finalResult=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false))
    if not IsValid(client) or not client:hasPrivilege("listCharacters") then return end
    local requestID = net.ReadUInt(16)
    local offset = net.ReadUInt(32)
    local limit = net.ReadUInt(16)
    buildFullCharListPage(client, requestID, offset, limit)
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
        client:notifySuccess(string.format("%s has set %s's flags to '%s'.", client:Name(), target:Name(), flags))
        return
    end

    lia.db.query("SELECT id, name FROM lia_characters WHERE steamID = " .. lia.db.convertDataType(steamID) .. " LIMIT 1", function(data)
        if not data or not data[1] then
            client:notify(string.format("Player not found."))
            return
        end

        local charID = data[1].id
        local charName = data[1].name
        lia.char.setCharDatabase(charID, "flags", flags)
        client:notifySuccess(string.format("%s has set %s's flags to '%s'.", client:Name(), charName, flags))
    end)
end)

net.Receive("liaModifyCharacterFlags", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaModifyCharacterFlags", "hasPrivilege(manageFlags)=", tostring(client:hasPrivilege("manageFlags")), "finalResult=", tostring(client:hasPrivilege("manageFlags")))
    if not client:hasPrivilege("manageFlags") then return end
    local charID = tonumber(net.ReadUInt(32))
    local flags = string.gsub(net.ReadString() or "", "%s", "")
    if not charID or charID <= 0 then
        client:notifyError(string.format("charID must be a number"))
        return
    end

    local loadedChar = lia.char.loaded[charID]
    if loadedChar then
        loadedChar:setFlags(flags)
        client:notifySuccess(string.format("%s has set %s's flags to '%s'.", client:Name(), loadedChar:getName(), flags))
        return
    end

    lia.db.query("SELECT name FROM lia_characters WHERE id = " .. lia.db.convertDataType(charID) .. " LIMIT 1", function(data)
        if not data or not data[1] then
            client:notify(string.format("Player not found."))
            return
        end

        lia.char.setCharDatabase(charID, "flags", flags)
        client:notifySuccess(string.format("%s has set %s's flags to '%s'.", client:Name(), data[1].name or tostring(charID), flags))
    end)
end)




local protectedPlayerEntityClasses = {
    viewmodel = true,
    predicted_viewmodel = true,
    gmod_hands = true
}

local function getPlayerEntityOwner(entity)
    if not IsValid(entity) then return end
    if isfunction(entity.CPPIGetOwner) then
        local owner = entity:CPPIGetOwner()
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end

    if isfunction(entity.GetCreator) then
        local creator = entity:GetCreator()
        if IsValid(creator) and creator:IsPlayer() then return creator end
    end

    if isfunction(entity.GetOwner) then
        local owner = entity:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end

    local directOwner = entity.client or entity.player or entity.ply
    if IsValid(directOwner) and directOwner:IsPlayer() then return directOwner end
    local steamID = entity.SteamID or entity.steamID
    if isstring(steamID) and steamID ~= "" then
        local owner = player.GetBySteamID(steamID)
        if IsValid(owner) then return owner end
    end

    local steamID64 = entity.SteamID64 or entity.steamID64
    if isstring(steamID64) and steamID64 ~= "" then
        local owner = player.GetBySteamID64(steamID64)
        if IsValid(owner) then return owner end
    end

    local characterID = tonumber(entity.liaCharID)
    if characterID and characterID > 0 then
        local character = lia.char.getCharacter(characterID)
        local owner = character and character:getPlayer()
        if IsValid(owner) then return owner end
    end

    local parent = entity:GetParent()
    if IsValid(parent) and parent:IsPlayer() then return parent end
end

local function getPlayerEntityType(entity)
    local class = entity:GetClass()
    if class == "viewmodel" or class == "predicted_viewmodel" then return "Viewmodel" end
    if class == "gmod_hands" then return "Hands" end
    if entity:IsWeapon() then return "Weapon" end
    if entity:IsVehicle() then return "Vehicle" end
    if entity:IsNPC() then return "NPC" end
    if entity:isDoor() then return "Door" end
    if entity:isProp() then return "Prop" end
    return "Entity"
end

local function getPlayerEntityName(entity)
    local class = entity:GetClass()
    local name = entity:GetName()
    if isstring(name) and name ~= "" then return name end
    if entity:IsWeapon() then
        local stored = weapons.GetStored(class)
        if stored and isstring(stored.PrintName) and stored.PrintName ~= "" then return stored.PrintName end
    end

    local stored = scripted_ents.GetStored(class)
    if stored and stored.t and isstring(stored.t.PrintName) and stored.t.PrintName ~= "" then return stored.t.PrintName end
    if isstring(entity.PrintName) and entity.PrintName ~= "" then return entity.PrintName end
    return class:gsub("_", " "):gsub("(%a)([%w']*)", function(first, rest) return string.upper(first) .. string.lower(rest) end)
end

local function getPlayerEntityModel(entity)
    local model = entity:GetModel()
    if entity:IsWeapon() then
        local stored = weapons.GetStored(entity:GetClass())
        if stored and isstring(stored.WorldModel) and stored.WorldModel ~= "" then model = stored.WorldModel end
    end
    return isstring(model) and model or ""
end

local function getVectorData(vector)
    return {
        x = vector.x,
        y = vector.y,
        z = vector.z
    }
end

local function getAngleData(angle)
    return {
        p = angle.p,
        y = angle.y,
        r = angle.r
    }
end

local function buildPlayerEntitySnapshot()
    local entities = {}
    for _, entity in ents.Iterator() do
        if not IsValid(entity) or entity:IsWorld() or entity:IsPlayer() or entity:IsWeapon() then continue end
        local class = entity:GetClass()
        if protectedPlayerEntityClasses[class] then continue end
        local owner = getPlayerEntityOwner(entity)
        if not IsValid(owner) then continue end
        local color = entity:GetColor()
        local char = owner:getChar()
        local creationTime = isfunction(entity.GetCreationTime) and entity:GetCreationTime() or 0
        entities[#entities + 1] = {
            entityIndex = entity:EntIndex(),
            clientSided = false,
            class = class,
            model = getPlayerEntityModel(entity),
            name = getPlayerEntityName(entity),
            type = getPlayerEntityType(entity),
            position = getVectorData(entity:GetPos()),
            angles = getAngleData(entity:GetAngles()),
            mapCreated = entity:CreatedByMap(),
            isDoor = entity:isDoor(),
            isProp = entity:isProp(),
            health = entity:Health(),
            maxHealth = entity:GetMaxHealth(),
            material = entity:GetMaterial() or "",
            skin = entity:GetSkin() or 0,
            color = {
                r = color.r,
                g = color.g,
                b = color.b,
                a = color.a
            },
            creationTime = creationTime,
            ownerName = owner:Name(),
            ownerCharacter = char and char:getName() or "",
            ownerSteamID = owner:SteamID(),
            ownerSteamID64 = owner:SteamID64(),
            ownerUserGroup = owner:GetUserGroup(),
            removable = not protectedPlayerEntityClasses[class]
        }
    end

    table.sort(entities, function(a, b)
        if a.ownerSteamID == b.ownerSteamID then
            if a.name == b.name then return a.entityIndex < b.entityIndex end
            return string.lower(a.name) < string.lower(b.name)
        end
        return string.lower(a.ownerName) < string.lower(b.ownerName)
    end)
    return entities
end

local function sendPlayerEntitySnapshot(client)
    if not IsValid(client) or not client:hasPrivilege("viewEntityTab") then return end
    lia.net.writeBigTable(client, "liaMapEntities", buildPlayerEntitySnapshot())
end

local function findPlayerEntityTeleportPosition(client, entity)
    local mins, maxs = client:GetHull()
    local center = entity:WorldSpaceCenter()
    local offsets = {Vector(0, 0, math.max(maxs.z + 32, 96)), entity:GetForward() * 96 + Vector(0, 0, 32), entity:GetForward() * -96 + Vector(0, 0, 32), entity:GetRight() * 96 + Vector(0, 0, 32), entity:GetRight() * -96 + Vector(0, 0, 32)}
    for _, offset in ipairs(offsets) do
        local position = center + offset
        local trace = util.TraceHull({
            start = position,
            endpos = position,
            mins = mins,
            maxs = maxs,
            mask = MASK_PLAYERSOLID,
            filter = {client, entity}
        })

        if not trace.StartSolid and not trace.AllSolid then return position end
    end
    return center + Vector(0, 0, 128)
end

net.Receive("liaRequestMapEntities", function(_, client)
    local allowed = client:hasPrivilege("viewEntityTab")
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestMapEntities", "hasPrivilege(viewEntityTab)=", tostring(allowed), "finalResult=", tostring(allowed))
    if not allowed then return end
    sendPlayerEntitySnapshot(client)
end)

net.Receive("liaMapEntityAction", function(_, client)
    if not client:hasPrivilege("viewEntityTab") then return end
    local action = net.ReadUInt(2)
    local entityIndex = net.ReadUInt(16)
    local entity = Entity(entityIndex)
    if not IsValid(entity) or entity:IsWorld() or entity:IsPlayer() or entity:IsWeapon() or protectedPlayerEntityClasses[entity:GetClass()] or not IsValid(getPlayerEntityOwner(entity)) then
        client:notifyError("The selected entity is no longer available or cannot be managed from this menu.")
        return
    end

    if action == 1 then
        if not client:hasPrivilege("command_goto") then
            client:notifyError("You do not have permission to teleport to entities.")
            return
        end

        local position = findPlayerEntityTeleportPosition(client, entity)
        client:SetPos(position)
        client:SetLocalVelocity(vector_origin)
        client:SetEyeAngles((entity:WorldSpaceCenter() - client:EyePos()):Angle())
        client:notifySuccess("Teleported to " .. getPlayerEntityName(entity) .. ".")
        return
    end

    if action ~= 2 then return end
    local class = entity:GetClass()
    if protectedPlayerEntityClasses[class] then
        client:notifyError("This entity is protected and cannot be removed.")
        return
    end

    local canRemove
    if entity:CreatedByMap() then
        canRemove = client:hasPrivilege("canRemoveWorldEntities")
    else
        canRemove = client:hasPrivilege("canRemoveBlockedEntities") or client:hasPrivilege("canRemoveWorldEntities")
    end

    if not canRemove then
        client:notifyError("You do not have permission to remove this entity.")
        return
    end

    local entityName = getPlayerEntityName(entity)
    SafeRemoveEntity(entity)
    client:notifySuccess("Removed " .. entityName .. ".")
    timer.Simple(0, function() sendPlayerEntitySnapshot(client) end)
end)

net.Receive("liaRequestOnlineStaffData", function(_, client)
    local d = deferred.new()
    local staffData = {}
    local canViewStaffManagement = IsValid(client) and client:hasPrivilege("viewStaffManagement")
    local steamIDLookup = {}
    for _, ply in player.Iterator() do
        if IsValid(ply) and ply:isStaff() then
            local char = ply:getChar()
            local charID = char and char:getID() or 0
            local steamID = ply:SteamID()
            local usergroup = ply:GetUserGroup()
            local isStaffOnDuty = ply:isStaffOnDuty()
            local characterName = char and char:getName() or "N/A"
            local steamName = ply:IsBot() and ply:Name() or ply:SteamName()
            staffData[#staffData + 1] = {
                steamID = steamID,
                charID = charID,
                name = steamName,
                usergroup = usergroup,
                isStaffOnDuty = isStaffOnDuty,
                characterName = characterName,
                tickets = 0,
                warnings = 0,
                kicks = 0,
                kills = 0,
                respawns = 0,
                blinds = 0,
                mutes = 0,
                jails = 0,
                strips = 0
            }

            steamIDLookup[steamID] = staffData[#staffData]
        end
    end

    if #staffData == 0 then
        net.Start("liaOnlineStaffData")
        net.WriteTable({})
        net.Send(client)
        return
    end

    local steamIDs = {}
    for _, staffInfo in ipairs(staffData) do
        if staffInfo.steamID and staffInfo.steamID ~= "" then steamIDs[#steamIDs + 1] = lia.db.convertDataType(staffInfo.steamID) end
    end

    local completedQueries = 0
    local totalQueries = 3
    local actionFieldMap = {
        plykick = "kicks",
        plykill = "kills",
        plyrespawn = "respawns",
        plyblind = "blinds",
        plymute = "mutes",
        plyjail = "jails",
        plystrip = "strips"
    }

    local function finishQuery()
        completedQueries = completedQueries + 1
        if completedQueries >= totalQueries then d:resolve(staffData) end
    end

    if not canViewStaffManagement or #steamIDs == 0 then
        d:resolve(staffData)
    else
        local steamIDFilter = table.concat(steamIDs, ", ")
        lia.db.query("SELECT warnerSteamID AS steamID, COUNT(*) AS count FROM lia_warnings WHERE warnerSteamID IN (" .. steamIDFilter .. ") GROUP BY warnerSteamID", function(rows)
            for _, row in ipairs(rows or {}) do
                local entry = steamIDLookup[row.steamID]
                if entry then entry.warnings = tonumber(row.count) or 0 end
            end

            finishQuery()
        end)

        lia.db.query("SELECT adminSteamID AS steamID, COUNT(*) AS count FROM lia_ticketclaims WHERE adminSteamID IN (" .. steamIDFilter .. ") GROUP BY adminSteamID", function(rows)
            for _, row in ipairs(rows or {}) do
                local entry = steamIDLookup[row.steamID]
                if entry then entry.tickets = tonumber(row.count) or 0 end
            end

            finishQuery()
        end)

        lia.db.query("SELECT staffSteamID AS steamID, action, COUNT(*) AS count FROM lia_staffactions WHERE staffSteamID IN (" .. steamIDFilter .. ") GROUP BY staffSteamID, action", function(rows)
            for _, row in ipairs(rows or {}) do
                local entry = steamIDLookup[row.steamID]
                local field = actionFieldMap[row.action]
                if entry and field then entry[field] = tonumber(row.count) or 0 end
            end

            finishQuery()
        end)
    end

    d:next(function(data)
        net.Start("liaOnlineStaffData")
        net.WriteTable(data)
        net.Send(client)
    end)
end)
