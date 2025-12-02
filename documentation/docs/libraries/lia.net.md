# Network Library

Network communication and data streaming system for the Lilia framework.

---

Overview

The network library provides comprehensive functionality for managing network communication in the Lilia framework. It handles both simple message passing and complex data streaming between server and client. The library includes support for registering network message handlers, sending messages to specific targets or broadcasting to all clients, and managing large data transfers through chunked streaming. It also provides global variable synchronization across the network, allowing server-side variables to be automatically synchronized with clients. The library operates on both server and client sides, with server handling message broadcasting and client handling message reception and acknowledgment.

---

### lia.net.isCacheHit

#### 📋 Purpose
Checks if a network message with specific arguments is currently cached

#### ⏰ When Called
Before sending or processing a network message to avoid duplicate transmissions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name identifier for the network message |
| `args` | **table** | The arguments that were sent with the message |

#### ↩️ Returns
* boolean - true if message is cached and not expired, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.net.isCacheHit("updateStatus", {"ready", true}) then
        return -- Skip, already sent recently
    end

```

---

### lia.net.addToCache

#### 📋 Purpose
Adds a network message to the cache to prevent duplicate transmissions

#### ⏰ When Called
After successfully sending or receiving a network message

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name identifier for the network message |
| `args` | **table** | The arguments that were sent with the message |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.net.addToCache("updateStatus", {"ready", true})

```

---

### lia.net.register

#### 📋 Purpose
Registers a network message handler for receiving messages sent via lia.net.send

#### ⏰ When Called
During initialization or when setting up network message handlers

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name identifier for the network message |
| `callback` | **function** | Function to call when this message is received |

#### ↩️ Returns
* boolean - true if registration successful, false if invalid arguments

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic message handler
    lia.net.register("playerMessage", function(data)
        print("Received message:", data)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register handler with validation
    lia.net.register("updateHealth", function(data)
        if data and data.health then
            LocalPlayer():SetHealth(data.health)
        end
    end)

```

#### ⚙️ High Complexity
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

### lia.net.send

#### 📋 Purpose
Sends a network message to specified targets or broadcasts to all clients

#### ⏰ When Called
When you need to send data from server to client(s) or client to server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The registered message name to send |
| `target` | **Player/table/nil** | Target player(s) - nil broadcasts to all, table sends to multiple players |

#### ↩️ Returns
* boolean - true if message sent successfully, false if invalid name or target

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send message to all clients
    lia.net.send("playerMessage", nil, "Hello everyone!")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send message to specific player
    local targetPlayer = player.GetByID(1)
    if targetPlayer then
        lia.net.send("updateHealth", targetPlayer, {health = 100})
    end

```

#### ⚙️ High Complexity
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

---

### lia.net.readBigTable

#### 📋 Purpose
Sets up a receiver for large table data that is sent in chunks via lia.net.writeBigTable

#### ⏰ When Called
During initialization to set up handlers for receiving large data transfers

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `netStr` | **string** | The network string identifier for the message |
| `callback` | **function** | Function to call when all chunks are received and data is reconstructed |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set up receiver for large data
    lia.net.readBigTable("largeData", function(data)
        print("Received large table with", #data, "entries")
    end)

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

### lia.net.writeBigTable

#### 📋 Purpose
Sends large table data to clients in chunks to avoid network limits

#### ⏰ When Called
When you need to send large amounts of data that exceed normal network limits

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `targets` | **Player/table/nil** | Target player(s) - nil sends to all players |
| `netStr` | **string** | The network string identifier for the message |
| `tbl` | **table** | The table data to send |
| `chunkSize` | **number, optional** | Size of each chunk in bytes (default: 2048, 512 during reload) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send large table to all players
    local largeData = {}
    for i = 1, 1000 do
        largeData[i] = {id = i, name = "Item " .. i}
    end
    lia.net.writeBigTable(nil, "largeData", largeData)

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.net.checkBadType

#### 📋 Purpose
Checks if an object contains invalid types (functions) that cannot be sent over the network

#### ⏰ When Called
Before setting net variables to ensure they don't contain functions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name/key of the net variable being checked |
| `object` | **any** | The object to check for invalid types |

#### ↩️ Returns
* boolean - true if bad types are found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Check if a table contains functions before setting as net var
    local data = {name = "test", callback = function() end}
    if not lia.net.checkBadType("playerData", data) then
        lia.net.setNetVar("playerData", data)
    end

```

---

### lia.net.setNetVar

#### 📋 Purpose
Sets a global net variable that syncs to all clients or a specific receiver

#### ⏰ When Called
When you need to set server-side variables that should be synchronized with clients

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | The variable key name |
| `value` | **any** | The value to store (cannot contain functions) |
| `receiver` | **Player, optional** | Specific player to send to, nil broadcasts to all |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set a global variable for all players
    lia.net.setNetVar("serverTime", os.time())

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set variable for specific player
    local player = player.GetByID(1)
    if player then
        lia.net.setNetVar("playerScore", 100, player)
    end

```

#### ⚙️ High Complexity
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

---

### lia.net.setClientNetVar

#### 📋 Purpose
Sets a client-specific net variable that only syncs to one client

#### ⏰ When Called
When you need to set a net variable that should only be visible to a specific client

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The client to send the net variable to |
| `key` | **string** | The variable key |
| `value` | **any** | The value to store |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Send a private message only to a specific player
    lia.net.setClientNetVar(player, "privateMessage", "This is only for you!")

```

---

### lia.net.getNetVar

#### 📋 Purpose
Retrieves a global net variable value

#### ⏰ When Called
When you need to get the value of a net variable that was set with lia.net.setNetVar

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | The variable key name |
| `default` | **any, optional** | Default value to return if the key doesn't exist |

#### ↩️ Returns
* any - The stored value or the default value if not found

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a stored value
    local serverTime = lia.net.getNetVar("serverTime")
    if serverTime then
        print("Server time:", serverTime)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get with default value
    local maxPlayers = lia.net.getNetVar("maxPlayers", 32)
    print("Max players:", maxPlayers)

```

#### ⚙️ High Complexity
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

---

