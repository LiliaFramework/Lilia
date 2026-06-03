lia.net = lia.net or {}
lia.net.sendq = lia.net.sendq or {}
lia.net.cache = lia.net.cache or {}
lia.net.locals = lia.net.locals or {}
lia.net.globals = lia.net.globals or {}
lia.net.buffers = lia.net.buffers or {}
lia.net.profiler = lia.net.profiler or {}
lia.net.registry = lia.net.registry or {}
lia.net.profiler.active = lia.net.profiler.active or false
lia.net.profiler.loggedMessages = lia.net.profiler.loggedMessages or {}
lia.net.profiler.messageCounts = lia.net.profiler.messageCounts or {}
lia.net.profiler.currentMessage = lia.net.profiler.currentMessage or nil
lia.net.profiler.snapshotInterval = lia.net.profiler.snapshotInterval or 5
lia.net.profiler.snapshotTimer = lia.net.profiler.snapshotTimer or "liaNetProfilerSnapshot"
lia.net.profiler.snapshotDir = lia.net.profiler.snapshotDir or "netprof"
local chunkTime = 0.05
local CACHE_TTL = 30
local MAX_CACHE_SIZE = 1000
local function getChunkInterval()
    return (lia.reloadInProgress and chunkTime * 2) or chunkTime
end

local function generateCacheKey(name, args)
    local key = name .. "|"
    for i, arg in ipairs(args) do
        key = key .. tostring(arg) .. (i < #args and "|" or "")
    end
    return util.CRC(key)
end

local function cleanupCache()
    local currentTime = CurTime()
    local expired = {}
    for key, entry in pairs(lia.net.cache) do
        if currentTime - entry.timestamp > CACHE_TTL then table.insert(expired, key) end
    end

    for _, key in ipairs(expired) do
        lia.net.cache[key] = nil
    end

    local cacheSize = table.Count(lia.net.cache)
    if cacheSize > MAX_CACHE_SIZE then
        local sorted = {}
        for key, entry in pairs(lia.net.cache) do
            table.insert(sorted, {
                key = key,
                timestamp = entry.timestamp
            })
        end

        table.sort(sorted, function(a, b) return a.timestamp < b.timestamp end)
        local toRemove = cacheSize - MAX_CACHE_SIZE
        for i = 1, math.min(toRemove, #sorted) do
            lia.net.cache[sorted[i].key] = nil
        end
    end
end

function lia.net.isCacheHit(name, args)
    local key = generateCacheKey(name, args)
    local entry = lia.net.cache[key]
    return entry and CurTime() - entry.timestamp <= CACHE_TTL
end

function lia.net.addToCache(name, args)
    local key = generateCacheKey(name, args)
    lia.net.cache[key] = {
        timestamp = CurTime()
    }

    cleanupCache()
end

function lia.net.readBigTable(netStr, callback)
    lia.net.buffers[netStr] = lia.net.buffers[netStr] or {}
    net.Receive(netStr, function(_, ply)
        local sid = net.ReadUInt(32)
        local total = net.ReadUInt(16)
        local idx = net.ReadUInt(16)
        local clen = net.ReadUInt(16)
        local chunk = net.ReadData(clen)
        if not lia.net.buffers[netStr] then lia.net.buffers[netStr] = {} end
        local buffers = lia.net.buffers[netStr]
        local state = buffers[sid]
        if not state then
            state = {
                total = total,
                count = 0,
                parts = {}
            }

            buffers[sid] = state
        end

        if not state.parts[idx] then
            state.parts[idx] = chunk
            state.count = state.count + 1
        end

        if CLIENT then
            net.Start("liaBigTableAck")
            net.WriteUInt(sid, 32)
            net.WriteUInt(idx, 16)
            net.SendToServer()
        end

        if state.count == state.total then
            buffers[sid] = nil
            local full = table.concat(state.parts, "", 1, total)
            local decomp = util.Decompress(full)
            local tbl = decomp and util.JSONToTable(decomp) or nil
            if SERVER then
                if callback then callback(ply, tbl) end
            else
                if callback then callback(tbl) end
            end
        end
    end)
end

if SERVER then
    local function sendChunk(ply, s, sid, idx)
        if not IsValid(ply) then
            if lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
            return
        end

        local part = s.chunks[idx]
        if not part then
            if lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
            return
        end

        s.idx = idx
        net.Start(s.netStr)
        net.WriteUInt(sid, 32)
        net.WriteUInt(s.total, 16)
        net.WriteUInt(idx, 16)
        net.WriteUInt(#part, 16)
        net.WriteData(part, #part)
        net.Send(ply)
        if idx == s.total and lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
    end

    local function beginStream(ply, netStr, chunks, sid)
        lia.net.sendq[ply] = lia.net.sendq[ply] or {}
        local s = {
            netStr = netStr,
            chunks = chunks,
            total = #chunks,
            idx = 0
        }

        lia.net.sendq[ply][sid] = s
        timer.Simple(getChunkInterval(), function()
            if not IsValid(ply) then return end
            local q = lia.net.sendq[ply]
            if not q then return end
            local ss = q[sid]
            if not ss then return end
            sendChunk(ply, ss, sid, 1)
        end)
    end

    function lia.net.writeBigTable(targets, netStr, tbl, chunkSize)
        if not istable(tbl) then return end
        local json = util.TableToJSON(tbl)
        if not json then return end
        local data = util.Compress(json)
        if not data or #data == 0 then return end
        local isReload = lia.reloadInProgress or false
        local size = isReload and math.max(128, math.min(1024, chunkSize or 512)) or math.max(256, math.min(4096, chunkSize or 2048))
        local chunks = {}
        local pos = 1
        while pos <= #data do
            local part = string.sub(data, pos, pos + size - 1)
            chunks[#chunks + 1] = part
            pos = pos + size
        end

        local sid = (tonumber(util.CRC(tostring(SysTime()) .. json)) or 0) % 4294967296
        local delay = 0
        local function schedule(ply)
            if not IsValid(ply) then return end
            timer.Simple(delay, function() if IsValid(ply) then beginStream(ply, netStr, chunks, sid) end end)
            delay = delay + getChunkInterval()
        end

        if istable(targets) then
            local validTargets = 0
            for i = #targets, 1, -1 do
                if IsValid(targets[i]) then
                    schedule(targets[i])
                    validTargets = validTargets + 1
                end
            end

            if validTargets == 0 then
                for _, ply in ipairs(player.GetHumans()) do
                    schedule(ply)
                end
            end
        elseif IsValid(targets) then
            schedule(targets)
        else
            for _, ply in ipairs(player.GetHumans()) do
                schedule(ply)
            end
        end
    end

    function lia.net.checkBadType(name, object)
        if isfunction(object) then
            lia.error(L("netVarBadType", name))
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if lia.net.checkBadType(name, k) or lia.net.checkBadType(name, v) then return true end
            end
        end
    end

    function lia.net.setNetVar(key, value, receiver)
        if lia.net.checkBadType(key, value) then return end
        local oldValue = lia.net.getNetVar(key)
        if oldValue == value then return end
        lia.net.globals[key] = value
        if not lia.shuttingDown then
            net.Start("liaGlobalVar")
            net.WriteString(key)
            net.WriteType(value)
            if receiver then
                net.Send(receiver)
            else
                net.Broadcast()
            end
        end

        hook.Run("NetVarChanged", nil, key, oldValue, value)
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
end

function lia.net.getNetVar(key, default)
    local value = lia.net.globals[key]
    return value ~= nil and value or default
end

if not lia.net.profiler.originalNetStart then
    lia.net.profiler.originalNetStart = net.Start
    lia.net.profiler.originalNetSend = net.Send
    lia.net.profiler.originalNetBroadcast = net.Broadcast
    lia.net.profiler.originalNetSendToServer = net.SendToServer
    lia.net.profiler.originalNetReceive = net.Receive
end

local function buildProfilerSnapshot()
    local snapshot = {
        capturedAt = os.time(),
        active = lia.net.profiler.active,
        totals = {
            uniqueLogs = table.Count(lia.net.profiler.loggedMessages),
            trackedMessages = 0
        },
        topMessages = {}
    }

    local ranked = {}
    for messageKey, count in pairs(lia.net.profiler.messageCounts) do
        snapshot.totals.trackedMessages = snapshot.totals.trackedMessages + count
        ranked[#ranked + 1] = {
            message = messageKey,
            count = count
        }
    end

    table.sort(ranked, function(a, b) return a.count > b.count end)
    for i = 1, math.min(#ranked, 25) do
        snapshot.topMessages[#snapshot.topMessages + 1] = ranked[i]
    end
    return snapshot
end

local function writeProfilerSnapshot()
    if not SERVER or not lia.net.profiler.active then return end
    file.CreateDir(lia.net.profiler.snapshotDir)
    local snapshot = buildProfilerSnapshot()
    file.Write(lia.net.profiler.snapshotDir .. "/latest_snapshot.json", util.TableToJSON(snapshot, true) or "{}")
end

local function stopProfilerSnapshots()
    if SERVER then timer.Remove(lia.net.profiler.snapshotTimer) end
end

local function startProfilerSnapshots()
    if not SERVER then return end
    timer.Create(lia.net.profiler.snapshotTimer, lia.net.profiler.snapshotInterval, 0, function()
        if not lia.net.profiler.active then
            stopProfilerSnapshots()
            return
        end

        writeProfilerSnapshot()
    end)
end

function lia.net.profiler.log(direction, messageName, size, sender, receiver)
    if not lia.net.profiler.active then return end
    local senderStr = "Unknown"
    local receiverStr = "Unknown"
    if SERVER then
        if sender == "SERVER" then
            senderStr = "SERVER"
        elseif IsValid(sender) then
            senderStr = sender:Nick() .. " (" .. sender:SteamID() .. ")"
        end

        if receiver == "ALL" then
            receiverStr = "ALL"
        elseif IsValid(receiver) then
            receiverStr = receiver:Nick() .. " (" .. receiver:SteamID() .. ")"
        end
    else
        if sender == "CLIENT" then
            senderStr = "CLIENT"
        elseif IsValid(sender) then
            senderStr = sender:Nick() .. " (" .. sender:SteamID() .. ")"
        end

        if receiver == "SERVER" then receiverStr = "SERVER" end
    end

    local timeStr = string.format("%.3f", CurTime())
    local sizeStr = tostring(size) .. " bytes"
    local senderID = IsValid(sender) and sender:SteamID() or (sender == "SERVER" and "SERVER" or (sender == "CLIENT" and "CLIENT" or "Unknown"))
    local receiverID = IsValid(receiver) and receiver:SteamID() or (receiver == "SERVER" and "SERVER" or (receiver == "ALL" and "ALL" or (receiver == "CLIENT" and "CLIENT" or "Unknown")))
    local logKey = string.format("%.2f|%s|%s|%s|%s|%d", math.floor(CurTime() * 100) / 100, direction, messageName, senderID, receiverID, size)
    if lia.net.profiler.loggedMessages[logKey] then return end
    lia.net.profiler.loggedMessages[logKey] = true
    local countKey = direction .. "|" .. messageName
    lia.net.profiler.messageCounts[countKey] = (lia.net.profiler.messageCounts[countKey] or 0) + 1
    timer.Simple(0.05, function() lia.net.profiler.loggedMessages[logKey] = nil end)
    lia.debug(string.format("[Net Profiler] [%s] %s | %s | Size: %s | From: %s | To: %s", timeStr, direction, messageName, sizeStr, senderStr, receiverStr))
end

function net.Start(messageName)
    lia.net.profiler.currentMessage = messageName
    return lia.net.profiler.originalNetStart(messageName)
end

if SERVER then
    function net.Send(receiver)
        if lia.net.profiler.active and lia.net.profiler.currentMessage then
            local size = net.BytesWritten() or 0
            if IsValid(receiver) then
                lia.net.profiler.log("S->C", lia.net.profiler.currentMessage, size, "SERVER", receiver)
            elseif istable(receiver) then
                for _, ply in ipairs(receiver) do
                    if IsValid(ply) then lia.net.profiler.log("S->C", lia.net.profiler.currentMessage, size, "SERVER", ply) end
                end
            end
        end

        lia.net.profiler.currentMessage = nil
        return lia.net.profiler.originalNetSend(receiver)
    end

    function net.Broadcast()
        if lia.net.profiler.active and lia.net.profiler.currentMessage then
            local size = net.BytesWritten() or 0
            lia.net.profiler.log("S->C", lia.net.profiler.currentMessage, size, "SERVER", "ALL")
        end

        lia.net.profiler.currentMessage = nil
        return lia.net.profiler.originalNetBroadcast()
    end
else
    function net.SendToServer()
        if lia.net.profiler.active and lia.net.profiler.currentMessage then
            local size = net.BytesWritten() or 0
            local sender = LocalPlayer()
            lia.net.profiler.log("C->S", lia.net.profiler.currentMessage, size, sender, "SERVER")
        end

        lia.net.profiler.currentMessage = nil
        return lia.net.profiler.originalNetSendToServer()
    end
end

function net.Receive(messageName, callback)
    if SERVER then
        return lia.net.profiler.originalNetReceive(messageName, function(len, ply)
            if lia.net.profiler.active and IsValid(ply) then
                local size = len or 0
                lia.net.profiler.log("C->S", messageName, size, ply, "SERVER")
            end

            if callback then callback(len, ply) end
        end)
    else
        return lia.net.profiler.originalNetReceive(messageName, function(len, ply)
            if lia.net.profiler.active then
                local size = len or 0
                lia.net.profiler.log("S->C", messageName, size, "SERVER", "CLIENT")
            end

            if callback then callback(len, ply) end
        end)
    end
end

concommand.Add("lia_net_profiler", function(ply, cmd, args)
    local mode = string.lower(tostring(args[1] or "on"))
    local shouldDisable = mode == "0" or mode == "false" or mode == "off" or mode == "disable" or mode == "stop"
    local wasActive = lia.net.profiler.active
    lia.net.profiler.active = not shouldDisable
    if lia.net.profiler.active then
        if not wasActive then
            lia.net.profiler.messageCounts = {}
            lia.net.profiler.loggedMessages = {}
        end

        startProfilerSnapshots()
        writeProfilerSnapshot()
        lia.debug(string.format("[Net Profiler] Enabled - snapshots will be written every %d seconds", lia.net.profiler.snapshotInterval))
    else
        stopProfilerSnapshots()
        lia.debug("[Net Profiler] Disabled")
    end
end)
