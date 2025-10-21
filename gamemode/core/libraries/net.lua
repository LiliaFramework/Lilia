--[[
    Network Library

    The network library provides comprehensive functionality for managing network communication
    in the Lilia framework. It handles both simple message passing and complex data streaming
    between server and client. The library includes support for registering network message
    handlers, sending messages to specific targets or broadcasting to all clients, and managing
    large data transfers through chunked streaming. It also provides global variable synchronization
    across the network, allowing server-side variables to be automatically synchronized with
    clients. The library operates on both server and client sides, with server handling message
    broadcasting and client handling message reception and acknowledgment.
]]
lia.net = lia.net or {}
lia.net.sendq = lia.net.sendq or {}
lia.net.globals = lia.net.globals or {}
lia.net.buffers = lia.net.buffers or {}
lia.net.registry = lia.net.registry or {}
--[[
    Purpose: Registers a network message handler for receiving messages sent via lia.net.send
    When Called: During initialization or when setting up network message handlers
    Parameters:
        - name (string): The name identifier for the network message
        - callback (function): Function to call when this message is received
    Returns: boolean - true if registration successful, false if invalid arguments
    Realm: Shared (works on both server and client)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Register a basic message handler
        lia.net.register("playerMessage", function(data)
            print("Received message:", data)
        end)
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Register handler with validation
        lia.net.register("updateHealth", function(data)
            if data and data.health then
                LocalPlayer():SetHealth(data.health)
            end
        end)
        ```

        High Complexity Example:
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
    Purpose: Sends a network message to specified targets or broadcasts to all clients
    When Called: When you need to send data from server to client(s) or client to server
    Parameters:
        - name (string): The registered message name to send
        - target (Player/table/nil): Target player(s) - nil broadcasts to all, table sends to multiple players
        - ... (variadic): Additional arguments to send with the message
    Returns: boolean - true if message sent successfully, false if invalid name or target
    Realm: Shared (works on both server and client)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send message to all clients
        lia.net.send("playerMessage", nil, "Hello everyone!")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Send message to specific player
        local targetPlayer = player.GetByID(1)
        if targetPlayer then
            lia.net.send("updateHealth", targetPlayer, {health = 100})
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Send message to multiple players with complex data
        local admins = {}
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                table.insert(admins, ply)
            end
        end

        lia.net.send("adminNotification", admins, {
            type = "warning",
            message = "Server restart in 5 minutes",
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
    if SERVER then
        net.Start("liaNetMessage")
        net.WriteString(name)
        net.WriteTable(args)
        if target == nil then
            net.Broadcast()
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
    Purpose: Sets up a receiver for large table data that is sent in chunks via lia.net.writeBigTable
    When Called: During initialization to set up handlers for receiving large data transfers
    Parameters:
        - netStr (string): The network string identifier for the message
        - callback (function): Function to call when all chunks are received and data is reconstructed
    Returns: None
    Realm: Shared (works on both server and client)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set up receiver for large data
        lia.net.readBigTable("largeData", function(data)
            print("Received large table with", #data, "entries")
        end)
        ```

        Medium Complexity Example:
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

        High Complexity Example:
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
                        print("Failed to add item:", itemData.uniqueID)
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
    local chunkTime = 0.05
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

    net.Receive("liaBigTableAck", function(_, ply)
        if not IsValid(ply) then return end
        local sid = net.ReadUInt(32)
        local last = net.ReadUInt(16)
        local q = lia.net.sendq[ply]
        if not q then return end
        local s = q[sid]
        if not s then return end
        if last ~= s.idx then return end
        if s.idx >= s.total then
            q[sid] = nil
            return
        end

        timer.Simple(chunkTime, function()
            if not IsValid(ply) then return end
            local qq = lia.net.sendq[ply]
            if not qq then return end
            local ss = qq[sid]
            if not ss then return end
            sendChunk(ply, ss, sid, ss.idx + 1)
        end)
    end)

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
        Purpose: Sends large table data to clients in chunks to avoid network limits
        When Called: When you need to send large amounts of data that exceed normal network limits
        Parameters:
            - targets (Player/table/nil): Target player(s) - nil sends to all players
            - netStr (string): The network string identifier for the message
            - tbl (table): The table data to send
            - chunkSize (number, optional): Size of each chunk in bytes (default: 2048, 512 during reload)
        Returns: None
        Realm: Server only
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

            Medium Complexity Example:
            ```lua
            -- Medium: Send to specific players with custom chunk size
            local playerData = {}
            for _, ply in ipairs(player.GetAll()) do
                playerData[ply:SteamID()] = {
                    name = ply:Name(),
                    health = ply:Health(),
                    armor = ply:Armor()
                }
            end

            local admins = {}
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    table.insert(admins, ply)
                end
            end

            lia.net.writeBigTable(admins, "adminPlayerData", playerData, 1024)
            ```

            High Complexity Example:
            ```lua
            -- High: Send complex inventory data with validation and error handling
            local function sendInventoryData(targets)
                local inventoryData = {}

                for _, ply in ipairs(player.GetAll()) do
                    local char = ply:GetCharacter()
                    if char then
                        local inv = char:GetInventory()
                        if inv then
                            inventoryData[ply:SteamID()] = {
                                items = {},
                                slots = inv:GetSlots(),
                                weight = inv:GetWeight()
                            }

                            for _, item in ipairs(inv:GetItems()) do
                                table.insert(inventoryData[ply:SteamID()].items, {
                                    uniqueID = item.uniqueID,
                                    id = item.id,
                                    data = item.data
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
end

if SERVER then
    function checkBadType(name, object)
        if isfunction(object) then
            lia.error(L("netVarBadType", name))
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if checkBadType(name, k) or checkBadType(name, v) then return true end
            end
        end
    end

    --[[
        Purpose: Sets a global network variable value and synchronizes it to clients
        When Called: When you need to update a global variable that should be synchronized across the network
        Parameters:
            - key (string): The name/key of the global variable to set
            - value (any): The value to set for the global variable
            - receiver (Player, optional): Specific player to send the update to, nil broadcasts to all
        Returns: None
        Realm: Server only
        Example Usage:
            Low Complexity:
            ```lua
            -- Simple: Set a global variable
            setNetVar("serverName", "My Lilia Server")
            ```

            Medium Complexity Example:
            ```lua
            -- Medium: Set variable with validation
            local function setMaxPlayers(count)
                if count > 0 and count <= 128 then
                    setNetVar("maxPlayers", count)
                    game.SetMaxPlayers(count)
                end
            end

            setMaxPlayers(64)
            ```

            High Complexity Example:
            ```lua
            -- High: Set complex configuration with validation and hooks
            local function updateServerConfig(config)
                if not config or not istable(config) then return end

                -- Validate and set individual config values
                if config.name and isstring(config.name) then
                    setNetVar("serverName", config.name)
                end

                if config.maxPlayers and isnumber(config.maxPlayers) then
                    if config.maxPlayers > 0 and config.maxPlayers <= 128 then
                        setNetVar("maxPlayers", config.maxPlayers)
                        game.SetMaxPlayers(config.maxPlayers)
                    end
                end

                if config.description and isstring(config.description) then
                    setNetVar("serverDescription", config.description)
                end

                -- Set complex configuration object
                setNetVar("serverConfig", {
                    name = config.name or "Lilia Server",
                    description = config.description or "A Lilia-based server",
                    maxPlayers = config.maxPlayers or 32,
                    gamemode = config.gamemode or "lilia",
                    map = config.map or game.GetMap(),
                    password = config.password or "",
                    tags = config.tags or {"roleplay", "serious"},
                    lastUpdated = os.time()
                })

                -- Notify specific admin players
                local admins = {}
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        table.insert(admins, ply)
                    end
                end

                if #admins > 0 then
                    setNetVar("adminNotification", {
                        type = "configUpdate",
                        message = "Server configuration has been updated",
                        timestamp = os.time()
                    }, admins)
                end
            end

            -- Usage
            updateServerConfig({
                name = "My Roleplay Server",
                maxPlayers = 50,
                description = "A serious roleplay server",
                tags = {"roleplay", "serious", "whitelist"}
            })
            ```
    ]]
    function setNetVar(key, value, receiver)
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
        Purpose: Retrieves a global network variable value with optional default fallback
        When Called: When you need to access a global variable that is synchronized across the network
        Parameters:
            - key (string): The name/key of the global variable to retrieve
            - default (any, optional): Default value to return if the variable doesn't exist
        Returns: The value of the global variable or the default value if not found
        Realm: Server only (server-side version)
        Example Usage:
            Low Complexity:
            ```lua
            -- Simple: Get a global variable
            local serverName = getNetVar("serverName", "Unknown Server")
            print("Server name:", serverName)
            ```

            Medium Complexity Example:
            ```lua
            -- Medium: Get variable with validation
            local maxPlayers = getNetVar("maxPlayers", 32)
            if maxPlayers > 0 and maxPlayers <= 128 then
                game.SetMaxPlayers(maxPlayers)
            end
            ```

            High Complexity Example:
            ```lua
            -- High: Get complex configuration with fallbacks
            local function getServerConfig()
                local config = getNetVar("serverConfig", {})

                return {
                    name = config.name or getNetVar("serverName", "Lilia Server"),
                    description = config.description or "A Lilia-based server",
                    maxPlayers = config.maxPlayers or getNetVar("maxPlayers", 32),
                    gamemode = config.gamemode or "lilia",
                    map = config.map or game.GetMap(),
                    password = config.password or "",
                    tags = config.tags or {"roleplay", "serious"}
                }
            end

            local serverConfig = getServerConfig()
            ```
    ]]
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
else
    --[[
        Purpose: Retrieves a global network variable value with optional default fallback (client-side)
        When Called: When you need to access a global variable that is synchronized from the server
        Parameters:
            - key (string): The name/key of the global variable to retrieve
            - default (any, optional): Default value to return if the variable doesn't exist
        Returns: The value of the global variable or the default value if not found
        Realm: Client only (client-side version)
        Example Usage:
            Low Complexity:
            ```lua
            -- Simple: Get a global variable on client
            local serverName = getNetVar("serverName", "Unknown Server")
            print("Connected to:", serverName)
            ```

            Medium Complexity Example:
            ```lua
            -- Medium: Get variable with UI update
            local maxPlayers = getNetVar("maxPlayers", 32)
            if IsValid(playerCountLabel) then
                playerCountLabel:SetText(player.GetCount() .. "/" .. maxPlayers)
            end
            ```

            High Complexity Example:
            ```lua
            -- High: Get configuration and update multiple UI elements
            local function updateServerInfo()
                local config = getNetVar("serverConfig", {})
                local serverName = config.name or getNetVar("serverName", "Unknown Server")
                local maxPlayers = config.maxPlayers or getNetVar("maxPlayers", 32)
                local description = config.description or "A Lilia-based server"

                if IsValid(serverInfoPanel) then
                    serverInfoPanel.serverNameLabel:SetText(serverName)
                    serverInfoPanel.playerCountLabel:SetText(player.GetCount() .. "/" .. maxPlayers)
                    serverInfoPanel.descriptionLabel:SetText(description)

                    -- Update tags
                    if config.tags then
                        serverInfoPanel.tagsPanel:Clear()
                        for _, tag in ipairs(config.tags) do
                            local tagLabel = serverInfoPanel.tagsPanel:Add("DLabel")
                            tagLabel:SetText(tag)
                            tagLabel:SetTextColor(Color(100, 200, 100))
                        end
                    end
                end
            end
            ```
    ]]
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end
end
