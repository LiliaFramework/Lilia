# Networking Library (lia.net)

This page documents the `lia.net` library functions that handle communication between server and clients, including network variables, message passing, and large data transfers.

---

## Overview

The `lia.net` library provides a comprehensive system for synchronizing data between the server and clients. It includes:

- **Network Variables**: Global variables stored in `lia.net.globals` that are automatically synchronized across all clients
- **Message System**: Custom network message registration and sending with automatic serialization
- **Big Table Transfer**: Chunked transfer of large tables with compression and flow control
- **Type Safety**: Automatic validation to prevent sending invalid data types (functions, etc.)
- **Internal State Management**: Queues, buffers, and registries for managing network operations

All networked data is automatically re-sent to players when they spawn via `PlayerInitialSpawn`. Values **must not** contain functions or tables that contain functions, as they cannot be serialized.

---

## Core Functions

### lia.net.register

**Purpose**

Registers a network message handler that will be called when a message with the specified name is received. The handler is stored in `lia.net.registry[name]`.

**Parameters**

* `name` (*string*): Network message identifier to register.

* `callback` (*function*): Function to call when the message is received. Server signature: `callback(client, ...)`, Client signature: `callback(...)`.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if registration was successful, `false` if the arguments were invalid.

**Example Usage**

```lua
-- Register a simple message handler
lia.net.register("MyCustomMessage", function(client, data)
    if SERVER then
        print("Server received message from", client:Name(), "with data:", data)
    else
        print("Client received message with data:", data)
    end
end)
```

---

### lia.net.send

**Purpose**

Sends a network message to specified targets with automatic serialization of arguments. Uses the "liaNetMessage" net message internally.

**Parameters**

* `name` (*string*): Network message identifier to send.

* `target` (*Player | Player[] | nil*): Recipient(s). `nil` broadcasts to all players (server only), sends to server (client only).

* `...` (*any*): Variable number of arguments to send. Must be serializable.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the message was sent successfully, `false` if there was an error.

**Example Usage**

```lua
-- Server: Send to specific player
lia.net.send("MyCustomMessage", player, "Hello", {key = "value"})

-- Server: Broadcast to all players
lia.net.send("MyCustomMessage", nil, "Broadcast message")

-- Client: Send to server
lia.net.send("MyCustomMessage", nil, "Message from client")
```

---

## Big Table Functions

### lia.net.readBigTable

**Purpose**

Registers a handler that rebuilds large tables sent over the network in multiple compressed chunks. Clients acknowledge each chunk so the sender can throttle transmission. Uses internal buffers in `lia.net.buffers[netStr]`.

**Parameters**

* `netStr` (*string*): Network message identifier to listen for.

* `callback` (*function*): Function invoked when the table is fully received. Server signature: `callback(ply, tbl)`, Client signature: `callback(tbl)`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Both server and client: install receiver
lia.net.readBigTable("MyData", function(a, b)
    if SERVER then
        local ply, data = a, b
        print("Server received table from", ply, data)
    else
        local data = a
        PrintTable(data)
    end
end)
```

---

### lia.net.writeBigTable

**Purpose**

Splits a table into compressed chunks and streams it to one or more players. Used in conjunction with `lia.net.readBigTable`. Aborts if the table is not serializable or cannot be compressed. Uses internal send queues in `lia.net.sendq[ply]`.

**Parameters**

* `targets` (*Player | Player[] | nil*): Recipient(s); `nil` streams to all human players.

* `netStr` (*string*): Network message identifier.

* `tbl` (*table*): Data to send. Must be JSON-serializable (no functions, userdata, etc.).

* `chunkSize` (*number | nil*): Optional bytes per chunk (default `2048`, clamped to the range `256`–`4096`).

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
local data = {foo = "bar", numbers = {1, 2, 3}}

-- Broadcast to everyone
lia.net.writeBigTable(nil, "MyData", data)

-- Send to one player with smaller chunks
lia.net.writeBigTable(player, "MyData", data, 1024)

-- Send to multiple players
lia.net.writeBigTable({player1, player2}, "MyData", data)
```

---

## Network Variables

### setNetVar

**Purpose**

Stores a value in `lia.net.globals` and broadcasts the change, optionally restricting it to specific receivers. Disallowed types are rejected, and no network message is sent if the value has not changed. The `NetVarChanged` hook is fired after successful updates.

**Parameters**

* `key` (*string*): Name of the variable.

* `value` (*any*): Value to store. Must be serializable (no functions).

* `receiver` (*Player | Player[] | nil*): Target player(s). `nil` broadcasts to everyone.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Start a new round and store the winner
local nextRound = getNetVar("round", 0) + 1
setNetVar("round", nextRound)

local champion = DetermineWinner()

-- Only the winner receives this variable
setNetVar("last_winner", champion, champion)

-- Send to multiple players
setNetVar("team_score", 100, {player1, player2})

hook.Run("RoundStarted", nextRound)
```

---

### getNetVar

**Purpose**

Retrieves a value from `lia.net.globals`, returning a default if the key is unset.

**Parameters**

* `key` (*string*): Variable name.

* `default` (*any*): Fallback value if unset.

**Realm**

`Shared`

**Returns**

* *any*: Stored value or the supplied default.

**Example Usage**

```lua
-- Inform new players of the current round and previous champion
hook.Add("PlayerInitialSpawn", "ShowRound", function(ply)
    local round = getNetVar("round", 0)
    ply:ChatPrint(("Current round: %s"):format(round))

    local lastWinner = getNetVar("last_winner")
    if IsValid(lastWinner) then
        ply:ChatPrint(("Last round won by %s"):format(lastWinner:Name()))
    end
end)

-- Use in calculations
local score = getNetVar("team_score", 0) + 10
```

---

## Internal State

### lia.net.globals

**Purpose**

Table containing all network variables that are synchronized across clients.

**Realm**

`Shared`

**Example Usage**

```lua
-- Access directly (not recommended, use getNetVar instead)
local value = lia.net.globals["my_key"]

-- Set directly (not recommended, use setNetVar instead)
lia.net.globals["my_key"] = "my_value"
```

### lia.net.registry

**Purpose**

Table containing all registered network message handlers.

**Realm**

`Shared`

**Example Usage**

```lua
-- Check if a message is registered
if lia.net.registry["MyMessage"] then
    print("MyMessage is registered")
end

-- List all registered messages
for name, callback in pairs(lia.net.registry) do
    print("Registered:", name)
end
```

### lia.net.sendq

**Purpose**

Table containing send queues for each player, used by the big table transfer system.

**Realm**

`Server`

**Example Usage**

```lua
-- Check if a player has pending transfers
if lia.net.sendq[player] then
    print("Player has pending transfers")
end
```

### lia.net.buffers

**Purpose**

Table containing receive buffers for each network string, used by the big table transfer system.

**Realm**

`Shared`

**Example Usage**

```lua
-- Check buffer state for a specific message
if lia.net.buffers["MyData"] then
    print("MyData has active buffers")
end
```

---

## Hooks

### NetVarChanged

**Purpose**

Called when a network variable is changed via `setNetVar`.

**Parameters**

* `entity` (*Entity | nil*): The entity whose netvar was changed (always `nil` for global netvars).

* `key` (*string*): The name of the changed variable.

* `oldValue` (*any*): The previous value.

* `newValue` (*any*): The new value.

**Realm**

`Shared`

**Example Usage**

```lua
hook.Add("NetVarChanged", "OnNetVarChanged", function(entity, key, oldValue, newValue)
    if not entity then
        print("Global netvar '" .. key .. "' changed from", oldValue, "to", newValue)
    end
end)
```

---

## Technical Details

### Network Message Flow

1. **Registration**: `lia.net.register()` stores callbacks in `lia.net.registry`
2. **Sending**: `lia.net.send()` uses the "liaNetMessage" net message
3. **Receiving**: Netcalls receive "liaNetMessage" and call registered callbacks
4. **Error Handling**: Invalid messages and callback errors are logged

### Big Table Transfer Flow

1. **Server**: `lia.net.writeBigTable()` compresses and chunks data
2. **Streaming**: Chunks are sent with flow control (0.05s delay between chunks)
3. **Client**: `lia.net.readBigTable()` receives and buffers chunks
4. **Acknowledgment**: Client sends "LIA_BigTable_Ack" for each chunk
5. **Assembly**: Complete table is reconstructed and callback is invoked

### Type Validation

The `checkBadType()` function recursively checks for functions in tables and rejects them to prevent serialization errors.

### Performance Considerations

- Big table transfers use compression and chunking to handle large datasets
- Flow control prevents network flooding
- Automatic cleanup of completed transfers
- Buffers are cleared when players disconnect
