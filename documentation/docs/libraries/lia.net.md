# Net Library

This page documents the functions for working with network communication and data transfer.

---

## Overview

The net library (`lia.net`) provides a comprehensive system for managing network communication, custom messages, and data transfer in the Lilia framework, serving as the backbone for all client-server communication and real-time data synchronization. This library handles sophisticated network management with support for reliable message delivery, automatic retry mechanisms, and bandwidth optimization to ensure efficient data transfer even under poor network conditions. The system features advanced message registration with support for typed messages, validation systems, and automatic serialization/deserialization of complex data structures including tables, entities, and custom objects. It includes comprehensive data transfer capabilities with support for large data chunks, streaming protocols, and compression algorithms to minimize network overhead and improve performance. The library provides robust data serialization with support for multiple data formats, version compatibility, and error recovery to ensure data integrity across network boundaries. Additional features include network monitoring and analytics, message queuing for offline scenarios, and integration with the framework's security system for protected communication channels, making it essential for creating responsive and reliable multiplayer experiences that maintain synchronization and provide smooth gameplay even with varying network conditions.

---

### register

**Purpose**

Registers a new network message.

**Parameters**

* `messageName` (*string*): The name of the message.
* `callback` (*function*): The callback function for the message.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a network message
local function registerMessage(messageName, callback)
    lia.net.register(messageName, callback)
end

-- Use in a function
local function registerPlayerMessage()
    lia.net.register("PlayerData", function(client, data)
        client:notify("Received player data: " .. data.name)
    end)
    print("Player message registered")
end

-- Use in a function
local function registerInventoryMessage()
    lia.net.register("InventoryUpdate", function(client, data)
        local character = client:getChar()
        if character then
            character:getInventory():update(data)
        end
    end)
    print("Inventory message registered")
end
```

---

### send

**Purpose**

Sends a network message to clients or broadcasts to all players.

**Parameters**

* `messageName` (*string*): The name of the registered network message.
* `target` (*Player* or *table* or *nil*): The target(s) to send to. Can be a single player, table of players, or nil to broadcast to all.
* `...` (*any*): Variable number of arguments to pass to the message callback.

**Returns**

* `success` (*boolean*): True if the message was sent successfully.

**Realm**

Shared.

**Example Usage**

```lua
-- Send message to a specific player
local function sendMessageToPlayer(player, messageName, ...)
    return lia.net.send(messageName, player, ...)
end

-- Use in a function
local function sendPlayerData(client, data)
    local success = lia.net.send("PlayerData", client, data)
    if success then
        print("Player data sent to " .. client:Name())
    end
    return success
end

-- Use in a function
local function sendInventoryUpdate(client, data)
    local success = lia.net.send("InventoryUpdate", client, data)
    if success then
        print("Inventory update sent to " .. client:Name())
    end
    return success
end

-- Broadcast to all players
local function broadcastMessage(messageName, ...)
    return lia.net.send(messageName, nil, ...)
end

-- Send to multiple players
local function sendToMultiplePlayers(players, messageName, ...)
    return lia.net.send(messageName, players, ...)
end
```

---

### readBigTable

**Purpose**

Sets up a network receiver for big table data that arrives in chunks over multiple network packets.

**Parameters**

* `netStr` (*string*): The network string identifier for the big table data.
* `callback` (*function*): Callback function called when the complete table is received. Receives (player, table) on server, (table) on client.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set up big table receiver
local function setupBigTableReceiver(netStr, callback)
    lia.net.readBigTable(netStr, callback)
end

-- Use in a function
local function receivePlayerInventory(netStr)
    lia.net.readBigTable(netStr, function(data)
        if data then
            print("Player inventory received with " .. #data .. " items")
            -- Process the inventory data
            processInventoryData(data)
        else
            print("Failed to receive inventory data")
        end
    end)
end

-- Use in a function
local function receiveServerConfig(netStr)
    lia.net.readBigTable(netStr, function(data)
        if data then
            print("Server configuration received")
            -- Apply server configuration
            applyServerConfig(data)
        else
            print("Failed to receive server configuration")
        end
    end)
end

-- Use in a function
local function receiveGameData(netStr)
    lia.net.readBigTable(netStr, function(data)
        if data then
            print("Game data received successfully")
            -- Handle game data
            handleGameData(data)
        else
            print("Failed to receive game data")
        end
    end)
end
```

---

### writeBigTable

**Purpose**

Sends a large table over the network by splitting it into chunks and sending them as separate network packets.

**Parameters**

* `targets` (*Player* or *table* or *nil*): The target(s) to send to. Can be a single player, table of players, or nil to send to all.
* `netStr` (*string*): The network string identifier for the big table data.
* `tbl` (*table*): The table data to send.
* `chunkSize` (*number*, optional): Size of each chunk in bytes (default varies based on reload state).

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send big table to specific player
local function sendBigTableToPlayer(player, netStr, data, chunkSize)
    lia.net.writeBigTable(player, netStr, data, chunkSize)
end

-- Use in a function
local function sendPlayerInventory(client, inventoryData)
    lia.net.writeBigTable(client, "PlayerInventory", inventoryData)
    print("Player inventory sent to " .. client:Name())
end

-- Use in a function
local function sendServerConfigToAll(configData)
    lia.net.writeBigTable(nil, "ServerConfig", configData)
    print("Server configuration broadcasted to all players")
end

-- Use in a function
local function sendGameDataToPlayers(players, gameData, chunkSize)
    lia.net.writeBigTable(players, "GameData", gameData, chunkSize)
    print("Game data sent to " .. #players .. " players")
end

-- Use in a function
local function sendLargeInventoryUpdate(client, inventoryData)
    -- Use smaller chunk size for large inventory data
    lia.net.writeBigTable(client, "InventoryUpdate", inventoryData, 256)
    print("Large inventory update sent to " .. client:Name())
end
```