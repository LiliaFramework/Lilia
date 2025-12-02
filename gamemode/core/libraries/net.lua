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
        Checks if a network message with specific arguments is currently cached

    When Called:
        Before sending or processing a network message to avoid duplicate transmissions

    Parameters:
        name (string)
            The name identifier for the network message
        args (table)
            The arguments that were sent with the message

    Returns:
        boolean - true if message is cached and not expired, false otherwise

    Realm:
        Shared

    Example Usage:
        ```lua
        if lia.net.isCacheHit("updateStatus", {"ready", true}) then
            return -- Skip, already sent recently
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
        Adds a network message to the cache to prevent duplicate transmissions

    When Called:
        After successfully sending or receiving a network message

    Parameters:
        name (string)
            The name identifier for the network message
        args (table)
            The arguments that were sent with the message

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.net.addToCache("updateStatus", {"ready", true})
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
        Registers a network message handler for receiving messages sent via lia.net.send

    When Called:
        During initialization or when setting up network message handlers

    Parameters:
        name (string)
            The name identifier for the network message
        callback (function)
            Function to call when this message is received

    Returns:
        boolean - true if registration successful, false if invalid arguments

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register a basic message handler
        lia.net.register("playerMessage", function(data)
            print("Received message:", data)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register handler with validation
        lia.net.register("updateHealth", function(data)
            if data and data.health then
                LocalPlayer():SetHealth(data.health)
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Register handler with multiple data types and error handling
        lia.net.register("syncInventory", function(data)
            if not data or not data.items then return end

            local inventory = LocalPlayer():GetCharacter():GetInventory()
            if not inventory then return end

            for _, itemData in ipairs(data.items) do
                if itemData.id and itemData.uniqueID then
                    inventory:Add(itemData.uniqueID, itemData.id)
                end
            end
        end)
        ```
]]
function lia.net.register(name, callback)
    if not isstring(name) or not isfunction(callback) then
        lia.error(L("invalidArgumentsForNetRegister"))
        return false
    end

    lia.net.registry[name] = callback
    return true
end

--[[
    Purpose:
        Sends a network message to specified targets or broadcasts to all clients

    When Called:
        When you need to send data from server to client(s) or client to server

    Parameters:
        name (string)
            The registered message name to send
        target (Player/table/nil)
            Target player(s) - nil broadcasts to all, table sends to multiple players
        ... (variadic)
            Additional arguments to send with the message

    Returns:
        boolean - true if message sent successfully, false if invalid name or target

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Send message to all clients
        lia.net.send("playerMessage", nil, "Hello everyone!")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send message to specific player
        local targetPlayer = player.GetByID(1)
        if targetPlayer then
            lia.net.send("updateHealth", targetPlayer, {health = 100})
        end
        ```

    High Complexity:
        ```lua
        -- High: Send message to multiple players with complex data
        local admins = {}
        for _, ply in player.Iterator() do
            if ply:IsAdmin() then
                table.insert(admins, ply)
            end
        end

        lia.net.send("adminNotification", admins, {
            type      = "warning",
            message   = "Server restart in 5 minutes",
            timestamp = os.time()
        })
        ```
]]
function lia.net.send(name, target, ...)
    if not isstring(name) then
        lia.error(L("invalidNetMessageName"))
        return false
    end

    local args = {...}
    if SERVER and target == nil and lia.net.isCacheHit(name, args) then return true end
    if SERVER then
        net.Start("liaNetMessage")
        net.WriteString(name)
        net.WriteTable(args)
        if target == nil then
            net.Broadcast()
            lia.net.addToCache(name, args)
        elseif istable(target) then
            for _, ply in ipairs(target) do
                if IsValid(ply) then net.Send(ply) end
            end
        elseif IsValid(target) then
            net.Send(target)
        else
            lia.error(L("invalidNetTarget"))
            return false
        end
    else
        net.Start("liaNetMessage")
        net.WriteString(name)
        net.WriteTable(args)
        net.SendToServer()
    end
    return true
end

--[[
    Purpose:
        Sets up a receiver for large table data that is sent in chunks via lia.net.writeBigTable

    When Called:
        During initialization to set up handlers for receiving large data transfers

    Parameters:
        netStr (string)
            The network string identifier for the message
        callback (function)
            Function to call when all chunks are received and data is reconstructed

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set up receiver for large data
        lia.net.readBigTable("largeData", function(data)
            print("Received large table with", #data, "entries")
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set up receiver with validation
        lia.net.readBigTable("playerData", function(data)
            if data and data.players then
                for _, playerData in ipairs(data.players) do
                    if playerData.name and playerData.id then
                        -- Process player data
                    end
                end
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Set up receiver with error handling and processing
        lia.net.readBigTable("inventorySync", function(data)
            if not data or not data.items then return end

            local inventory = LocalPlayer():GetCharacter():GetInventory()
            if not inventory then return end

            -- Clear existing items
            inventory:Clear()

            -- Add new items with validation
            for _, itemData in ipairs(data.items) do
                if itemData.uniqueID and itemData.id then
                    local success = inventory:Add(itemData.uniqueID, itemData.id)
                    if not success then
                        lia.log.add("Failed to add item: " .. tostring(itemData.uniqueID))
                    end
                end
            end

            -- Update UI
            if IsValid(inventory.panel) then
                inventory.panel:Rebuild()
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
            Sends large table data to clients in chunks to avoid network limits

        When Called:
            When you need to send large amounts of data that exceed normal network limits

        Parameters:
            targets (Player/table/nil)
                Target player(s) - nil sends to all players
            netStr (string)
                The network string identifier for the message
            tbl (table)
                The table data to send
            chunkSize (number, optional)
                Size of each chunk in bytes (default: 2048, 512 during reload)

        Returns:
            nil

        Realm:
            Server

        Example Usage:
    Low Complexity:
        ```lua
        -- Simple: Send large table to all players
        local largeData = {}
        for i = 1, 1000 do
            largeData[i] = {id = i, name = "Item " .. i}
        end
        lia.net.writeBigTable(nil, "largeData", largeData)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send to specific players with custom chunk size
        local playerData = {}
        for _, ply in player.Iterator() do
            playerData[ply:SteamID()] = {
                name  = ply:Name(),
                health = ply:Health(),
                armor = ply:Armor()
            }
        end

        local admins = {}
        for _, ply in player.Iterator() do
            if ply:IsAdmin() then
                table.insert(admins, ply)
            end
        end

        lia.net.writeBigTable(admins, "adminPlayerData", playerData, 1024)
        ```

    High Complexity:
        ```lua
        -- High: Send complex inventory data with validation and error handling
        local function sendInventoryData(targets)
            local inventoryData = {}

            for _, ply in player.Iterator() do
                local char = ply:GetCharacter()
                if char then
                    local inv = char:GetInventory()
                    if inv then
                        inventoryData[ply:SteamID()] = {
                            items  = {},
                            slots  = inv:GetSlots(),
                            weight = inv:GetWeight()
                        }

                        for _, item in ipairs(inv:GetItems()) do
                            table.insert(inventoryData[ply:SteamID()].items, {
                                uniqueID = item.uniqueID,
                                id       = item.id,
                                data     = item.data
                            })
                        end
                    end
                end
            end

            if next(inventoryData) then
                lia.net.writeBigTable(targets, "inventorySync", inventoryData, 1536)
            end
        end

        -- Send to specific players or all
        local targetPlayers = player.GetByID(1) -- Specific player
        sendInventoryData(targetPlayers)
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
            Checks if an object contains invalid types (functions) that cannot be sent over the network

        When Called:
            Before setting net variables to ensure they don't contain functions

        Parameters:
            name (string)
                The name/key of the net variable being checked
            object (any)
                The object to check for invalid types

        Returns:
            boolean - true if bad types are found, nil otherwise

        Realm:
            Server

        Example Usage:
            ```lua
            -- Check if a table contains functions before setting as net var
            local data = {name = "test", callback = function() end}
            if not lia.net.checkBadType("playerData", data) then
                lia.net.setNetVar("playerData", data)
            end
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
            Sets a global net variable that syncs to all clients or a specific receiver

        When Called:
            When you need to set server-side variables that should be synchronized with clients

        Parameters:
            key (string)
                The variable key name
            value (any)
                The value to store (cannot contain functions)
            receiver (Player, optional)
                Specific player to send to, nil broadcasts to all

        Returns:
            nil

        Realm:
            Server

        Example Usage:

        Low Complexity:
            ```lua
            -- Simple: Set a global variable for all players
            lia.net.setNetVar("serverTime", os.time())
            ```

        Medium Complexity:
            ```lua
            -- Medium: Set variable for specific player
            local player = player.GetByID(1)
            if player then
                lia.net.setNetVar("playerScore", 100, player)
            end
            ```

        High Complexity:
            ```lua
            -- High: Set complex data structure with validation
            local gameSettings = {
                maxPlayers = 32,
                gameMode = "survival",
                difficulty = "hard",
                features = {
                    pvp = true,
                    crafting = true,
                    trading = false
                }
            }

            -- Validate the data before setting
            if not lia.net.checkBadType("gameSettings", gameSettings) then
                lia.net.setNetVar("gameSettings", gameSettings)
            else
                lia.log.add("Failed to set game settings: contains invalid data types")
            end
            ```
    ]]
    function lia.net.setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        local oldValue = getNetVar(key)
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

    --[[
        Purpose:
            Sets a client-specific net variable that only syncs to one client

        When Called:
            When you need to set a net variable that should only be visible to a specific client

        Parameters:
            client (Player)
                The client to send the net variable to
            key (string)
                The variable key
            value (any)
                The value to store

        Returns:
            nil

        Realm:
            Server

        Example Usage:
            ```lua
            -- Send a private message only to a specific player
            lia.net.setClientNetVar(player, "privateMessage", "This is only for you!")
            ```
    ]]
    function lia.net.setClientNetVar(client, key, value)
        if not IsValid(client) or not isstring(key) then return end
        if checkBadType(key, value) then return end
        lia.net[client] = lia.net[client] or {}
        local oldValue = lia.net[client][key]
        if oldValue == value then return end
        lia.net[client][key] = value
        if not lia.shuttingDown then
            net.Start("liaClientNetVar")
            net.WriteUInt(client:EntIndex(), 16)
            net.WriteString(key)
            net.WriteType(value)
            net.Send(client)
        end

        hook.Run("NetVarChanged", client, key, oldValue, value)
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
end

--[[
    Purpose:
        Retrieves a global net variable value

    When Called:
        When you need to get the value of a net variable that was set with lia.net.setNetVar

    Parameters:
        key (string)
            The variable key name
        default (any, optional)
            Default value to return if the key doesn't exist

    Returns:
        any - The stored value or the default value if not found

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a stored value
        local serverTime = lia.net.getNetVar("serverTime")
        if serverTime then
            print("Server time:", serverTime)
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get with default value
        local maxPlayers = lia.net.getNetVar("maxPlayers", 32)
        print("Max players:", maxPlayers)
        ```

    High Complexity:
        ```lua
        -- High: Get complex data structure
        local gameSettings = lia.net.getNetVar("gameSettings")
        if gameSettings then
            print("Game mode:", gameSettings.gameMode)
            print("Difficulty:", gameSettings.difficulty)
            print("PVP enabled:", gameSettings.features.pvp)
        else
            -- Use defaults if not set
            gameSettings = {
                gameMode = "default",
                difficulty = "normal",
                features = {pvp = false}
            }
        end
        ```
]]
function lia.net.getNetVar(key, default)
    local value = lia.net.globals[key]
    return value ~= nil and value or default
end