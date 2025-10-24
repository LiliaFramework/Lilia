# Network Library

Network communication and data streaming system for the Lilia framework.

---

## Overview

The network library provides comprehensive functionality for managing network communication in the Lilia framework. It handles both simple message passing and complex data streaming between server and client. The library includes support for registering network message handlers, sending messages to specific targets or broadcasting to all clients, and managing large data transfers through chunked streaming. It also provides global variable synchronization across the network, allowing server-side variables to be automatically synchronized with clients. The library operates on both server and client sides, with server handling message broadcasting and client handling message reception and acknowledgment.

---

### register

**Purpose**

Registers a network message handler for receiving messages sent via lia.net.send

**When Called**

During initialization or when setting up network message handlers

**Parameters**

* `name` (*string*): The name identifier for the network message
* `callback` (*function*): Function to call when this message is received

**Returns**

* boolean - true if registration successful, false if invalid arguments

**Realm**

Shared (works on both server and client)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register a basic message handler
lia.net.register("playerMessage", function(data)
    print("Received message:", data)
end)

```

**Medium Complexity:**
```lua
-- Medium: Register handler with validation
lia.net.register("updateHealth", function(data)
    if data and data.health then
        LocalPlayer():SetHealth(data.health)
    end
end)

```

**High Complexity:**
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

---

### send

**Purpose**

Sends a network message to specified targets or broadcasts to all clients

**When Called**

When you need to send data from server to client(s) or client to server

**Parameters**

* `name` (*string*): The registered message name to send
* `target` (*Player/table/nil*): Target player(s) - nil broadcasts to all, table sends to multiple players

**Returns**

* boolean - true if message sent successfully, false if invalid name or target

**Realm**

Shared (works on both server and client)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send message to all clients
lia.net.send("playerMessage", nil, "Hello everyone!")

```

**Medium Complexity:**
```lua
-- Medium: Send message to specific player
local targetPlayer = player.GetByID(1)
if targetPlayer then
    lia.net.send("updateHealth", targetPlayer, {health = 100})
end

```

**High Complexity:**
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

---

### readBigTable

**Purpose**

Sets up a receiver for large table data that is sent in chunks via lia.net.writeBigTable

**When Called**

During initialization to set up handlers for receiving large data transfers

**Parameters**

* `netStr` (*string*): The network string identifier for the message
* `callback` (*function*): Function to call when all chunks are received and data is reconstructed

**Returns**

* None

**Realm**

Shared (works on both server and client)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set up receiver for large data
lia.net.readBigTable("largeData", function(data)
    print("Received large table with", #data, "entries")
end)

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### writeBigTable

**Purpose**

Sends large table data to clients in chunks to avoid network limits

**When Called**

When you need to send large amounts of data that exceed normal network limits

**Parameters**

* `targets` (*Player/table/nil*): Target player(s) - nil sends to all players
* `netStr` (*string*): The network string identifier for the message
* `tbl` (*table*): The table data to send
* `chunkSize` (*number, optional*): Size of each chunk in bytes (default: 2048, 512 during reload)

**Returns**

* None

**Realm**

Server only

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send large table to all players
local largeData = {}
for i = 1, 1000 do
    largeData[i] = {id = i, name = "Item " .. i}
end
lia.net.writeBigTable(nil, "largeData", largeData)

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.checkBadType

**Purpose**

Sends large table data to clients in chunks to avoid network limits

**When Called**

When you need to send large amounts of data that exceed normal network limits

**Parameters**

* `targets` (*Player/table/nil*): Target player(s) - nil sends to all players
* `netStr` (*string*): The network string identifier for the message
* `tbl` (*table*): The table data to send
* `chunkSize` (*number, optional*): Size of each chunk in bytes (default: 2048, 512 during reload)

**Returns**

* None

**Realm**

Server only

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send large table to all players
local largeData = {}
for i = 1, 1000 do
    largeData[i] = {id = i, name = "Item " .. i}
end
lia.net.writeBigTable(nil, "largeData", largeData)

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.setNetVar

**Purpose**

Sets a global network variable value and synchronizes it to clients

**When Called**

When you need to update a global variable that should be synchronized across the network

**Parameters**

* `key` (*string*): The name/key of the global variable to set
* `value` (*any*): The value to set for the global variable
* `receiver` (*Player, optional*): Specific player to send the update to, nil broadcasts to all

**Returns**

* None

**Realm**

Server only

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set a global variable
setNetVar("serverName", "My Lilia Server")

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.getNetVar

**Purpose**

Retrieves a global network variable value with optional default fallback

**When Called**

When you need to access a global variable that is synchronized across the network

**Parameters**

* `key` (*string*): The name/key of the global variable to retrieve
* `default` (*any, optional*): Default value to return if the variable doesn't exist

**Returns**

* The value of the global variable or the default value if not found

**Realm**

Server only (server-side version)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a global variable
local serverName = getNetVar("serverName", "Unknown Server")
print("Server name:", serverName)

```

**Medium Complexity:**
```lua
-- Medium: Get variable with validation
local maxPlayers = getNetVar("maxPlayers", 32)
if maxPlayers > 0 and maxPlayers <= 128 then
    game.SetMaxPlayers(maxPlayers)
end

```

**High Complexity:**
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

---

### lia.getNetVar

**Purpose**

Retrieves a global network variable value with optional default fallback (client-side)

**When Called**

When you need to access a global variable that is synchronized from the server

**Parameters**

* `key` (*string*): The name/key of the global variable to retrieve
* `default` (*any, optional*): Default value to return if the variable doesn't exist

**Returns**

* The value of the global variable or the default value if not found

**Realm**

Client only (client-side version)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a global variable on client
local serverName = getNetVar("serverName", "Unknown Server")
print("Connected to:", serverName)

```

**Medium Complexity:**
```lua
-- Medium: Get variable with UI update
local maxPlayers = getNetVar("maxPlayers", 32)
if IsValid(playerCountLabel) then
    playerCountLabel:SetText(player.GetCount() .. "/" .. maxPlayers)
end

```

**High Complexity:**
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

---

