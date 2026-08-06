local spawnCooldowns = {}
local validToolTiers = {
    disabled = true,
    staff = true,
    basic = true
}

local function canViewNetProfiler(client)
    return IsValid(client) and client:hasPrivilege("viewNetProfiler")
end

local validNetLogViews = {
    session = true,
    players = true
}

local validNetLogSorts = {
    calls = true,
    usage = true,
    message = true,
    direction = true,
    source = true,
    totalBytes = true,
    avgBytes = true,
    minBytes = true,
    maxBytes = true,
    playerName = true,
    firstAt = true,
    lastAt = true
}

local validNetLogUsageFilters = {
    all = true,
    dominant = true,
    high = true,
    medium = true,
    low = true
}

local validNetLogSourceFilters = {
    all = true,
    live = true,
    snapshot = true
}

local validNetLogTimeRanges = {
    [0] = true,
    [300] = true,
    [900] = true,
    [3600] = true,
    [21600] = true
}

local function readNetProfilerSnapshot()
    local snapshotPath = (lia.net and lia.net.profiler and lia.net.profiler.snapshotDir or "netprof") .. "/latest_snapshot.json"
    if not file.Exists(snapshotPath, "DATA") then
        return {
            available = false,
            message = "No network profiler snapshot has been generated yet.",
            snapshotPath = snapshotPath
        }
    end

    local raw = file.Read(snapshotPath, "DATA")
    local parsed = raw and util.JSONToTable(raw) or nil
    if not istable(parsed) then
        return {
            available = false,
            message = "The latest network profiler snapshot could not be read.",
            snapshotPath = snapshotPath
        }
    end

    parsed.available = true
    parsed.snapshotPath = snapshotPath
    parsed.profilerActive = true
    parsed.snapshotInterval = lia.net and lia.net.profiler and lia.net.profiler.snapshotInterval or 0
    return parsed
end

local function sendNetProfilerSnapshot(client)
    net.Start("liaNetProfilerSnapshot")
    net.WriteTable(readNetProfilerSnapshot())
    net.Send(client)
end

local function splitProfilerMessageKey(value)
    local raw = string.Trim(tostring(value or ""))
    local direction, message = raw:match("^([^|]+)|(.+)$")
    direction = string.Trim(tostring(direction or "Unknown"))
    message = string.Trim(tostring(message or raw))
    if direction == "" then direction = "Unknown" end
    if message == "" then message = "unknown" end
    return direction, message
end

local function copySessionRow(row, fallbackID)
    local calls = math.max(math.floor(tonumber(row.calls or row.count) or 0), 0)
    local totalBytes = math.max(math.floor(tonumber(row.totalBytes or row.bytes) or 0), 0)
    local minBytes = math.max(math.floor(tonumber(row.minBytes) or 0), 0)
    local maxBytes = math.max(math.floor(tonumber(row.maxBytes) or 0), 0)
    return {
        id = tostring(row.id or fallbackID),
        key = tostring(row.key or fallbackID),
        message = tostring(row.message or row.name or "unknown"),
        direction = tostring(row.direction or "Unknown"),
        source = tostring(row.source or "live"),
        calls = calls,
        totalBytes = totalBytes,
        avgBytes = calls > 0 and totalBytes / calls or tonumber(row.avgBytes) or 0,
        minBytes = minBytes,
        maxBytes = maxBytes,
        firstAt = math.max(math.floor(tonumber(row.firstAt) or 0), 0),
        lastAt = math.max(math.floor(tonumber(row.lastAt) or 0), 0)
    }
end

local function collectLiveSessionRows()
    local rows = {}
    local tracker = lia.net and lia.net.profiler and lia.net.profiler.sessionTracker or nil
    if istable(tracker) and istable(tracker.messages) then
        for key, row in pairs(tracker.messages) do
            if istable(row) then rows[#rows + 1] = copySessionRow(row, "live|" .. tostring(key)) end
        end
    end

    if #rows == 0 then
        local counts = lia.net and lia.net.profiler and lia.net.profiler.messageCounts or nil
        if istable(counts) then
            for key, count in pairs(counts) do
                local numericCount = math.max(math.floor(tonumber(count) or 0), 0)
                if numericCount > 0 then
                    local direction, message = splitProfilerMessageKey(key)
                    rows[#rows + 1] = {
                        id = "live|" .. tostring(key),
                        key = tostring(key),
                        message = message,
                        direction = direction,
                        source = "live",
                        calls = numericCount,
                        totalBytes = 0,
                        avgBytes = 0,
                        minBytes = 0,
                        maxBytes = 0,
                        firstAt = 0,
                        lastAt = 0
                    }
                end
            end
        end
    end

    return rows
end

local function collectSnapshotRows(snapshot)
    local rows = {}
    local messages = istable(snapshot.messages) and snapshot.messages or snapshot.topMessages
    for _, entry in ipairs(istable(messages) and messages or {}) do
        if istable(entry) then
            local key = tostring(entry.key or entry.message or entry.name or "unknown")
            local direction, message = splitProfilerMessageKey(key)
            if entry.direction then direction = tostring(entry.direction) end
            if entry.name or entry.messageName then message = tostring(entry.name or entry.messageName) end
            local calls = math.max(math.floor(tonumber(entry.calls or entry.count or entry.usage) or 0), 0)
            if calls > 0 then
                rows[#rows + 1] = copySessionRow({
                    id = "snapshot|" .. key,
                    key = key,
                    message = message,
                    direction = direction,
                    source = "snapshot",
                    calls = calls,
                    totalBytes = entry.totalBytes or entry.bytes,
                    avgBytes = entry.avgBytes,
                    minBytes = entry.minBytes,
                    maxBytes = entry.maxBytes,
                    firstAt = entry.firstAt,
                    lastAt = entry.lastAt
                }, "snapshot|" .. key)
            end
        end
    end
    return rows
end

local function collectSessionRows(snapshot, requestedSource)
    local liveRows = collectLiveSessionRows()
    local snapshotRows = collectSnapshotRows(snapshot)
    if requestedSource == "live" then return liveRows, "live" end
    if requestedSource == "snapshot" then return snapshotRows, "snapshot" end
    if #liveRows > 0 then return liveRows, "live" end
    return snapshotRows, "snapshot"
end

local function collectPlayerRows()
    local rows = {}
    local players = {}
    local tracker = lia.net and lia.net.profiler and lia.net.profiler.sessionTracker or nil
    for steamID64, playerData in pairs(istable(tracker) and tracker.players or {}) do
        local playerName = tostring(playerData.playerName or "Unknown")
        local steamID = tostring(playerData.steamID or "UNKNOWN")
        players[#players + 1] = {
            steamID64 = tostring(steamID64),
            steamID = steamID,
            playerName = playerName,
            online = playerData.online == true,
            totalCalls = math.max(math.floor(tonumber(playerData.totalCalls) or 0), 0),
            totalBytes = math.max(math.floor(tonumber(playerData.totalBytes) or 0), 0),
            lastAt = math.max(math.floor(tonumber(playerData.lastAt) or 0), 0)
        }
        for key, entry in pairs(istable(playerData.messages) and playerData.messages or {}) do
            if istable(entry) then
                local calls = math.max(math.floor(tonumber(entry.calls) or 0), 0)
                local totalBytes = math.max(math.floor(tonumber(entry.totalBytes) or 0), 0)
                rows[#rows + 1] = {
                    id = tostring(entry.id or steamID64 .. "|" .. key),
                    steamID64 = tostring(steamID64),
                    steamID = tostring(entry.steamID or steamID),
                    playerName = tostring(entry.playerName or playerName),
                    online = entry.online == true,
                    message = tostring(entry.message or "unknown"),
                    direction = tostring(entry.direction or "Unknown"),
                    source = "live",
                    calls = calls,
                    totalBytes = totalBytes,
                    avgBytes = calls > 0 and totalBytes / calls or 0,
                    minBytes = math.max(math.floor(tonumber(entry.minBytes) or 0), 0),
                    maxBytes = math.max(math.floor(tonumber(entry.maxBytes) or 0), 0),
                    firstAt = math.max(math.floor(tonumber(entry.firstAt) or 0), 0),
                    lastAt = math.max(math.floor(tonumber(entry.lastAt) or 0), 0)
                }
            end
        end
    end

    table.sort(players, function(a, b)
        local an = a.playerName:lower()
        local bn = b.playerName:lower()
        if an == bn then return a.steamID64 < b.steamID64 end
        return an < bn
    end)
    return rows, players
end

local function getTrackerTotals()
    local tracker = lia.net and lia.net.profiler and lia.net.profiler.sessionTracker or {}
    local directionTotals = istable(tracker.directionTotals) and tracker.directionTotals or {}
    local inbound = directionTotals["C->S"] or {}
    local outbound = directionTotals["S->C"] or {}
    local startedAt = math.max(math.floor(tonumber(tracker.startedAt) or 0), 0)
    return {
        totalCalls = math.max(math.floor(tonumber(tracker.totalCalls) or 0), 0),
        totalBytes = math.max(math.floor(tonumber(tracker.totalBytes) or 0), 0),
        uniqueMessages = table.Count(istable(tracker.messages) and tracker.messages or {}),
        uniquePlayers = table.Count(istable(tracker.uniquePlayers) and tracker.uniquePlayers or {}),
        sessionStartedAt = startedAt,
        sessionDuration = startedAt > 0 and math.max(os.time() - startedAt, 0) or 0,
        inboundCalls = math.max(math.floor(tonumber(inbound.calls) or 0), 0),
        inboundBytes = math.max(math.floor(tonumber(inbound.bytes) or 0), 0),
        outboundCalls = math.max(math.floor(tonumber(outbound.calls) or 0), 0),
        outboundBytes = math.max(math.floor(tonumber(outbound.bytes) or 0), 0)
    }
end

local function matchesUsageFilter(usage, filter)
    if filter == "dominant" then return usage >= 25 end
    if filter == "high" then return usage >= 10 and usage < 25 end
    if filter == "medium" then return usage >= 2 and usage < 10 end
    if filter == "low" then return usage < 2 end
    return true
end

local function compareRows(a, b, sortBy, sortDesc)
    local aValue = a[sortBy]
    local bValue = b[sortBy]
    if isstring(aValue) then aValue = aValue:lower() end
    if isstring(bValue) then bValue = bValue:lower() end
    aValue = aValue or 0
    bValue = bValue or 0
    if aValue == bValue then
        local aPlayer = tostring(a.playerName or ""):lower()
        local bPlayer = tostring(b.playerName or ""):lower()
        if aPlayer ~= bPlayer then return aPlayer < bPlayer end
        local aMessage = tostring(a.message or ""):lower()
        local bMessage = tostring(b.message or ""):lower()
        if aMessage ~= bMessage then return aMessage < bMessage end
        return tostring(a.id or "") < tostring(b.id or "")
    end
    if sortDesc then return aValue > bValue end
    return aValue < bValue
end

local function getNetProfilerLogsPayload(request)
    local view = validNetLogViews[request.view] and request.view or "session"
    local snapshot = readNetProfilerSnapshot()
    local sourceFilter = validNetLogSourceFilters[request.source] and request.source or "all"
    local rows
    local players = {}
    local sourceMode
    if view == "players" then
        rows, players = collectPlayerRows()
        sourceMode = "live"
    else
        rows, sourceMode = collectSessionRows(snapshot, sourceFilter)
    end

    local baseTotals = getTrackerTotals()
    if view == "session" and sourceMode == "snapshot" then
        local snapshotTotals = istable(snapshot.totals) and snapshot.totals or {}
        local totalCalls = 0
        local totalBytes = 0
        for _, row in ipairs(rows) do
            totalCalls = totalCalls + row.calls
            totalBytes = totalBytes + row.totalBytes
        end
        baseTotals.totalCalls = math.max(totalCalls, math.floor(tonumber(snapshotTotals.totalCalls or snapshotTotals.trackedMessages) or 0))
        baseTotals.totalBytes = math.max(totalBytes, math.floor(tonumber(snapshotTotals.totalBytes) or 0))
        baseTotals.uniqueMessages = #rows
        baseTotals.uniquePlayers = math.max(math.floor(tonumber(snapshotTotals.uniquePlayers) or 0), 0)
        baseTotals.sessionStartedAt = math.max(math.floor(tonumber(snapshot.sessionStartedAt) or 0), 0)
        baseTotals.sessionDuration = math.max(math.floor(tonumber(snapshot.sessionDuration) or 0), 0)
        baseTotals.inboundCalls = math.max(math.floor(tonumber(snapshotTotals.inboundCalls) or 0), 0)
        baseTotals.inboundBytes = math.max(math.floor(tonumber(snapshotTotals.inboundBytes) or 0), 0)
        baseTotals.outboundCalls = math.max(math.floor(tonumber(snapshotTotals.outboundCalls) or 0), 0)
        baseTotals.outboundBytes = math.max(math.floor(tonumber(snapshotTotals.outboundBytes) or 0), 0)
    end

    local usageDenominator = math.max(baseTotals.totalCalls, 0)
    for _, row in ipairs(rows) do
        row.usage = usageDenominator > 0 and row.calls / usageDenominator * 100 or 0
    end

    local search = string.Trim(string.sub(tostring(request.search or ""), 1, 128)):lower()
    local direction = string.Trim(string.sub(tostring(request.direction or "all"), 1, 64))
    local directionLower = direction:lower()
    local playerFilter = string.Trim(string.sub(tostring(request.player or "all"), 1, 32))
    local usageFilter = validNetLogUsageFilters[request.usage] and request.usage or "all"
    local sortBy = validNetLogSorts[request.sortBy] and request.sortBy or "calls"
    local sortDesc = request.sortDesc ~= false
    local minCalls = math.max(math.floor(tonumber(request.minCalls) or 0), 0)
    local maxCalls = math.max(math.floor(tonumber(request.maxCalls) or 0), 0)
    local minBytes = math.max(math.floor(tonumber(request.minBytes) or 0), 0)
    local maxBytes = math.max(math.floor(tonumber(request.maxBytes) or 0), 0)
    local timeRange = math.max(math.floor(tonumber(request.timeRange) or 0), 0)
    if not validNetLogTimeRanges[timeRange] then timeRange = 0 end
    local minimumTimestamp = timeRange > 0 and os.time() - timeRange or 0
    local pageSize = math.Clamp(math.floor(tonumber(request.pageSize) or 25), 10, 100)
    local page = math.max(math.floor(tonumber(request.page) or 1), 1)
    local directions = {}
    local seenDirections = {}
    for _, row in ipairs(rows) do
        local key = row.direction:lower()
        if not seenDirections[key] then
            seenDirections[key] = true
            directions[#directions + 1] = row.direction
        end
    end
    table.sort(directions, function(a, b) return a:lower() < b:lower() end)

    local filtered = {}
    local matchedCalls = 0
    local matchedBytes = 0
    local matchedPlayers = {}
    for _, row in ipairs(rows) do
        local searchable = table.concat({tostring(row.playerName or ""), tostring(row.steamID or ""), tostring(row.steamID64 or ""), tostring(row.message or ""), tostring(row.direction or ""), tostring(row.source or "")}, " "):lower()
        local matchesSearch = search == "" or searchable:find(search, 1, true) ~= nil
        local matchesDirection = directionLower == "all" or row.direction:lower() == directionLower
        local matchesPlayer = view ~= "players" or playerFilter == "all" or row.steamID64 == playerFilter
        local matchesMinimumCalls = row.calls >= minCalls
        local matchesMaximumCalls = maxCalls == 0 or row.calls <= maxCalls
        local matchesMinimumBytes = row.totalBytes >= minBytes
        local matchesMaximumBytes = maxBytes == 0 or row.totalBytes <= maxBytes
        local matchesTime = minimumTimestamp == 0 or row.lastAt >= minimumTimestamp
        local matchesUsage = view ~= "session" or matchesUsageFilter(row.usage, usageFilter)
        if matchesSearch and matchesDirection and matchesPlayer and matchesMinimumCalls and matchesMaximumCalls and matchesMinimumBytes and matchesMaximumBytes and matchesTime and matchesUsage then
            filtered[#filtered + 1] = row
            matchedCalls = matchedCalls + row.calls
            matchedBytes = matchedBytes + row.totalBytes
            if row.steamID64 then matchedPlayers[row.steamID64] = true end
        end
    end

    table.sort(filtered, function(a, b) return compareRows(a, b, sortBy, sortDesc) end)
    local resultCount = #filtered
    local pageCount = math.max(math.ceil(resultCount / pageSize), 1)
    page = math.Clamp(page, 1, pageCount)
    local firstIndex = (page - 1) * pageSize + 1
    local lastIndex = math.min(firstIndex + pageSize - 1, resultCount)
    local pageRows = {}
    for index = firstIndex, lastIndex do
        local row = filtered[index]
        if row then
            local copy = table.Copy(row)
            copy.rank = index
            pageRows[#pageRows + 1] = copy
        end
    end

    local profilerActive = true
    local snapshotInterval = lia.net and lia.net.profiler and lia.net.profiler.snapshotInterval or tonumber(snapshot.snapshotInterval) or 0
    local available = #rows > 0 or view == "session" and sourceMode == "snapshot" and snapshot.available == true
    local capturedAt = sourceMode == "live" and os.time() or tonumber(snapshot.capturedAt) or 0
    local statusMessage
    if view == "players" then
        statusMessage = #rows > 0 and "Showing per-player network activity from the current profiler session." or "No player network activity has been captured in the current session."
    elseif #rows > 0 then
        statusMessage = sourceMode == "live" and "Showing current session network usage and bandwidth." or "Showing the latest saved profiler snapshot."
    else
        statusMessage = snapshot.message or "No network message usage has been captured yet."
    end

    baseTotals.matchedCalls = matchedCalls
    baseTotals.matchedBytes = matchedBytes
    baseTotals.matchedRows = resultCount
    baseTotals.matchedPlayers = table.Count(matchedPlayers)
    return {
        requestId = request.requestId or 0,
        view = view,
        available = available,
        message = statusMessage,
        profilerActive = profilerActive,
        sourceMode = sourceMode,
        snapshotPath = snapshot.snapshotPath,
        capturedAt = capturedAt,
        fetchedAt = os.time(),
        snapshotInterval = snapshotInterval,
        totals = baseTotals,
        pagination = {
            page = page,
            pageSize = pageSize,
            pageCount = pageCount,
            resultCount = resultCount,
            firstIndex = resultCount > 0 and firstIndex or 0,
            lastIndex = resultCount > 0 and lastIndex or 0
        },
        filters = {
            directions = directions,
            players = players
        },
        rows = pageRows
    }
end

local function sendNetProfilerLogs(client, request)
    lia.net.writeBigTable(client, "liaNetProfilerLogs", getNetProfilerLogsPayload(request))
end

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
    lia.log.add(client, "permissionChanged", "staff character " .. permission .. " -> " .. tostring(enabled))
    sendStaffCharacterConfiguration(client)
end)

net.Receive("liaSetStaffCharacterFlag", function(_, client)
    if not hasStaffCharacterConfigurationAccess(client) then return end
    local flag, enabled = net.ReadString(), net.ReadBool()
    if #flag ~= 1 or not lia.flag.list[flag] then return end
    lia.staffCharacterFlags[flag] = enabled and true or nil
    lia.data.set("staffCharacterFlags", lia.staffCharacterFlags, true, true)
    lia.log.add(client, "permissionChanged", "staff character flag " .. flag .. " -> " .. tostring(enabled))
    sendStaffCharacterConfiguration(client)
end)

net.Receive("liaResetStaffCharacterConfiguration", function(_, client)
    if not hasStaffCharacterConfigurationAccess(client) then return end
    lia.staffCharacterPermissions, lia.staffCharacterFlags = {}, {}
    lia.data.set("staffCharacterPermissions", {}, true, true)
    lia.data.set("staffCharacterFlags", {}, true, true)
    lia.log.add(client, "permissionChanged", "staff character permissions and flags reset")
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

net.Receive("liaRequestNetProfilerSnapshot", function(_, client)
    if not canViewNetProfiler(client) then return end
    sendNetProfilerSnapshot(client)
end)

net.Receive("liaRequestNetProfilerLogs", function(_, client)
    if not canViewNetProfiler(client) then return end
    if (client.liaNextNetProfilerRequest or 0) > CurTime() then return end
    client.liaNextNetProfilerRequest = CurTime() + 0.15
    local request = {
        requestId = net.ReadUInt(32),
        view = net.ReadString(),
        page = net.ReadUInt(16),
        pageSize = net.ReadUInt(8),
        search = net.ReadString(),
        direction = net.ReadString(),
        usage = net.ReadString(),
        source = net.ReadString(),
        player = net.ReadString(),
        timeRange = net.ReadUInt(32),
        sortBy = net.ReadString(),
        sortDesc = net.ReadBool(),
        minCalls = net.ReadUInt(32),
        maxCalls = net.ReadUInt(32),
        minBytes = net.ReadUInt(32),
        maxBytes = net.ReadUInt(32)
    }

    sendNetProfilerLogs(client, request)
end)


net.Receive("liaSetToolPermissionTier", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    local toolName = string.lower(string.Trim(net.ReadString() or ""))
    local tier = net.ReadString()
    if toolName == "" or not validToolTiers[tier] or not table.HasValue(getToolNames(), toolName) then return end
    local tiers = lia.data.get("toolPermissionTiers", {})
    tiers[toolName] = tier
    lia.data.set("toolPermissionTiers", tiers, true, true)
    lia.log.add(client, "permissionChanged", "tool_" .. toolName .. " -> " .. tier)
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
        lia.log.add(client, "permissionChanged", changed .. " tool permission tiers updated")
    end

    sendToolPermissionTiers(client)
end)

net.Receive("liaResetToolPermissionTiers", function(_, client)
    if not IsValid(client) or not client:hasPrivilege("manageUsergroups") then return end
    lia.data.set("toolPermissionTiers", {}, true, true)
    lia.log.add(client, "permissionChanged", "all tool permission tiers reset")
    sendToolPermissionTiers(client)
end)

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
LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.key = 'charBanInfo'
LEFT JOIN lia_chardata AS f ON f.charID = c.id AND f.key = 'flags'
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
                    LastUsed = stored and L("onlineNow") or row.lastJoinTime,
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

net.Receive("liaRequestFullCharList", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestFullCharList", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(listCharacters)=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false), "finalResult=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false))
    if not IsValid(client) or not client:hasPrivilege("listCharacters") then return end
    buildFullCharListPage(client, 0, 0, 100)
end)

net.Receive("liaRequestFullCharListPage", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestFullCharListPage", "isValidPlayer=", tostring(IsValid(client)), "hasPrivilege(listCharacters)=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false), "finalResult=", tostring(IsValid(client) and client:hasPrivilege("listCharacters") or false))
    if not IsValid(client) or not client:hasPrivilege("listCharacters") then return end
    local requestID = net.ReadUInt(16)
    local offset = net.ReadUInt(32)
    local limit = net.ReadUInt(16)
    buildFullCharListPage(client, requestID, offset, limit)
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

net.Receive("liaModifyCharacterFlags", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaModifyCharacterFlags", "hasPrivilege(manageFlags)=", tostring(client:hasPrivilege("manageFlags")), "finalResult=", tostring(client:hasPrivilege("manageFlags")))
    if not client:hasPrivilege("manageFlags") then return end
    local charID = tonumber(net.ReadUInt(32))
    local flags = string.gsub(net.ReadString() or "", "%s", "")
    if not charID or charID <= 0 then
        client:notifyErrorLocalized("charIDMustBeNumber")
        return
    end

    local loadedChar = lia.char.loaded[charID]
    if loadedChar then
        loadedChar:setFlags(flags)
        client:notifySuccessLocalized("flagSet", client:Name(), loadedChar:getName(), flags)
        return
    end

    lia.db.query("SELECT name FROM lia_characters WHERE id = " .. lia.db.convertDataType(charID) .. " LIMIT 1", function(data)
        if not data or not data[1] then
            client:notifyLocalized("playerNotFound")
            return
        end

        lia.char.setCharDatabase(charID, "flags", flags)
        client:notifySuccessLocalized("flagSet", client:Name(), data[1].name or tostring(charID), flags)
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
    local offsets = {
        Vector(0, 0, math.max(maxs.z + 32, 96)),
        entity:GetForward() * 96 + Vector(0, 0, 32),
        entity:GetForward() * -96 + Vector(0, 0, 32),
        entity:GetRight() * 96 + Vector(0, 0, 32),
        entity:GetRight() * -96 + Vector(0, 0, 32)
    }

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
