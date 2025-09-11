# Net Library

This page documents the functions for working with network communication and data transfer.

---

## Overview

The net library (`lia.net`) provides a comprehensive system for managing network communication, custom messages, and data transfer in the Lilia framework, serving as the backbone for all client-server communication and real-time data synchronization. This library handles sophisticated network management with support for reliable message delivery, automatic retry mechanisms, and bandwidth optimization to ensure efficient data transfer even under poor network conditions. The system features advanced message registration with support for typed messages, validation systems, and automatic serialization/deserialization of complex data structures including tables, entities, and custom objects. It includes comprehensive data transfer capabilities with support for large data chunks, streaming protocols, and compression algorithms to minimize network overhead and improve performance. The library provides robust data serialization with support for multiple data formats, version compatibility, and error recovery to ensure data integrity across network boundaries. Additional features include network monitoring and analytics, message queuing for offline scenarios, and integration with the framework's security system for protected communication channels, making it essential for creating responsive and reliable multiplayer experiences that maintain synchronization and provide smooth gameplay even with varying network conditions.

---

### lia.net.register

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

### lia.net.send

**Purpose**

Sends a network message to a client.

**Parameters**

* `client` (*Player*): The client to send the message to.
* `messageName` (*string*): The name of the message.
* `data` (*any*): The data to send.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send network message
local function sendMessage(client, messageName, data)
    lia.net.send(client, messageName, data)
end

-- Use in a function
local function sendPlayerData(client, data)
    lia.net.send(client, "PlayerData", data)
    print("Player data sent to " .. client:Name())
end

-- Use in a function
local function sendInventoryUpdate(client, data)
    lia.net.send(client, "InventoryUpdate", data)
    print("Inventory update sent to " .. client:Name())
end
```

---

### lia.net.readBigTable

**Purpose**

Reads a big table from network data.

**Parameters**

*None*

**Returns**

* `table*): The read table.

**Realm**

Client.

**Example Usage**

```lua
-- Read big table from network
local function readBigTable()
    return lia.net.readBigTable()
end

-- Use in a function
local function receiveBigData()
    local data = lia.net.readBigTable()
    if data then
        print("Big table received with " .. #data .. " entries")
        return data
    else
        print("Failed to read big table")
        return nil
    end
end
```

---

### lia.net.writeBigTable

**Purpose**

Writes a big table to network data.

**Parameters**

* `table*): The table to write.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Write big table to network
local function writeBigTable(table)
    lia.net.writeBigTable(table)
end

-- Use in a function
local function sendBigData(client, data)
    lia.net.writeBigTable(data)
    print("Big table sent to " .. client:Name())
end
```