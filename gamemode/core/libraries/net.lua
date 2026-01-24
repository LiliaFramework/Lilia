--[[
    Folder: Libraries
    File: net.md
]]
--[[
    Network Library

    Network communication and data streaming system for the Lilia framework.
]]
--[[
    Overview:
        The network library provides comprehensive functionality for managing network communication in the Lilia framework. It handles both simple message passing and complex data streaming between server and client. The library includes support for registering network message handlers, sending messages to specific targets or broadcasting to all clients, and managing large data transfers through chunked streaming. It also provides global variable synchronization across the network, allowing server-side variables to be automatically synchronized with clients. The library operates on both server and client sides, with server handling message broadcasting and client handling message reception and acknowledgment.
]]
lia.net = lia.net or {}
lia.net.sendq = lia.net.sendq or {}
lia.net.globals = lia.net.globals or {}
lia.net.locals = lia.net.locals or {}
lia.net.buffers = lia.net.buffers or {}
lia.net.registry = lia.net.registry or {}
lia.net.cache = lia.net.cache or {}
local chunkTime = 0.05
local CACHE_TTL = 30
local MAX_CACHE_SIZE = 1000
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

--[[
    Purpose:
        Determine if a net payload with given args is still fresh in cache.

    When Called:
        Before sending large net payloads to avoid duplicate work.

    Parameters:
        name (string)
            Cache identifier.
        args (table)
            Arguments that define cache identity.

    Returns:
        boolean
            true if cached entry exists within TTL.

    Realm:
        Shared

    Example Usage:
        ```lua
        if not lia.net.isCacheHit("bigSync", {ply:SteamID64()}) then
            lia.net.writeBigTable(ply, "liaBigSync", payload)
            lia.net.addToCache("bigSync", {ply:SteamID64()})
        end
        ```
]]
function lia.net.isCacheHit(name, args)
    local key = generateCacheKey(name, args)
    local entry = lia.net.cache[key]
    return entry and CurTime() - entry.timestamp <= CACHE_TTL
end

--[[
    Purpose:
        Insert a cache marker for a named payload/args combination.

    When Called:
        Right after sending a large or expensive net payload.

    Parameters:
        name (string)
            Cache identifier.
        args (table)
            Arguments that define cache identity.
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.net.writeBigTable(targets, "liaDialogSync", data)
        lia.net.addToCache("dialogSync", {table.Count(data)})
        ```
]]
function lia.net.addToCache(name, args)
    local key = generateCacheKey(name, args)
    lia.net.cache[key] = {
        timestamp = CurTime()
    }

    cleanupCache()
end

--[[
    Purpose:
        Receive chunked JSON-compressed tables and reconstruct them.

    When Called:
        To register a receiver for big table streams (both realms).

    Parameters:
        netStr (string)
            Net message name carrying the chunks.
        callback (function)
            Function called when table is fully received. Client: function(tbl), Server: function(ply, tbl).
    Realm:
        Shared

    Example Usage:
        ```lua
        lia.net.readBigTable("liaDoorDataBulk", function(tbl)
            if not tbl then return end
            for doorID, data in pairs(tbl) do
                lia.doors.updateCachedData(doorID, data)
            end
        end)
        ```
]]
function lia.net.readBigTable(netStr, callback)
    lia.net.buffers[netStr] = lia.net.buffers[netStr] or {}
    net.Receive(netStr, function(_, ply)
        local sid = net.ReadUInt(32)
        local total = net.ReadUInt(16)
        local idx = net.ReadUInt(16)
        local clen = net.ReadUInt(16)
        local chunk = net.ReadData(clen)
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
        timer.Simple(chunkTime, function()
            if not IsValid(ply) then return end
            local q = lia.net.sendq[ply]
            if not q then return end
            local ss = q[sid]
            if not ss then return end
            sendChunk(ply, ss, sid, 1)
        end)
    end

    --[[
    Purpose:
        Send a large table by compressing and chunking it across the net.

    When Called:
        For big payloads (dialog sync, door data, keybinds) that exceed net limits.

    Parameters:
        targets (Player|table|nil)
            Single player, list of players, or nil to broadcast to humans.
        netStr (string)
            Net message name to use.
        tbl (table)
            Data to serialize.
        chunkSize (number|nil)
            Optional override for chunk size.
    Realm:
        Server

    Example Usage:
        ```lua
        local payload = {doors = lia.doors.stored, ts = os.time()}
        lia.net.writeBigTable(player.GetHumans(), "liaDoorDataBulk", payload, 2048)
        lia.net.addToCache("doorBulk", {payload.ts})
        ```
    ]]
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
            delay = delay + (isReload and chunkTime * 2 or chunkTime)
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

    --[[
    Purpose:
        Validate netvar payloads to prevent functions being networked.

    When Called:
        Internally before setting globals/locals.

    Parameters:
        name (string)
            Identifier for error reporting.
        object (any)
            Value to validate for networking safety.

    Returns:
        boolean|nil
            true if bad type detected.

    Realm:
        Server

    Example Usage:
        ```lua
        if lia.net.checkBadType("example", someTable) then return end
        ```
    ]]
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

    --[[
    Purpose:
        Set a global netvar and broadcast it (or send to specific receiver).

    When Called:
        Whenever shared state changes (config sync, feature flags, etc.).

    Parameters:
        key (string)
            Netvar identifier.
        value (any)
            Value to set.
        receiver (Player|table|nil)
            Optional target(s); broadcasts when nil.
    Realm:
        Server

    Example Usage:
        ```lua
        lia.net.setNetVar("eventActive", true)
        lia.net.setNetVar("roundNumber", round, targetPlayers)
        ```
    ]]
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

--[[
    Purpose:
        Retrieve a global netvar with a fallback default.

    When Called:
        Client/server code reading synchronized state.

    Parameters:
        key (string)
            Netvar identifier.
        default (any)
            Fallback value if netvar is not set.

    Returns:
        any

    Realm:
        Shared

    Example Usage:
        ```lua
        if lia.net.getNetVar("eventActive", false) then
            DrawEventHUD()
        end
        ```
]]
function lia.net.getNetVar(key, default)
    local value = lia.net.globals[key]
    return value ~= nil and value or default
end
