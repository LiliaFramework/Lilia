# Network Library

Network communication and data streaming system for the Lilia framework.

---

Overview

The network library provides comprehensive functionality for managing network communication in the Lilia framework. It handles both simple message passing and complex data streaming between server and client. The library includes support for registering network message handlers, sending messages to specific targets or broadcasting to all clients, and managing large data transfers through chunked streaming. It also provides global variable synchronization across the network, allowing server-side variables to be automatically synchronized with clients. The library operates on both server and client sides, with server handling message broadcasting and client handling message reception and acknowledgment.

---

### lia.net.isCacheHit

#### 📋 Purpose
Determine if a net payload with given args is still fresh in cache.

#### ⏰ When Called
Before sending large net payloads to avoid duplicate work.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Cache identifier. |
| `args` | **table** | Arguments that define cache identity. |

#### ↩️ Returns
* boolean
true if cached entry exists within TTL.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if not lia.net.isCacheHit("bigSync", {ply:SteamID64()}) then
        lia.net.writeBigTable(ply, "liaBigSync", payload)
        lia.net.addToCache("bigSync", {ply:SteamID64()})
    end

```

---

### lia.net.addToCache

#### 📋 Purpose
Insert a cache marker for a named payload/args combination.

#### ⏰ When Called
Right after sending a large or expensive net payload.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Cache identifier. |
| `args` | **table** | Arguments that define cache identity. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.net.writeBigTable(targets, "liaDialogSync", data)
    lia.net.addToCache("dialogSync", {table.Count(data)})

```

---

### lia.net.readBigTable

#### 📋 Purpose
Receive chunked JSON-compressed tables and reconstruct them.

#### ⏰ When Called
To register a receiver for big table streams (both realms).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `netStr` | **string** | Net message name carrying the chunks. |
| `callback` | **function** | Function called when table is fully received. Client: function(tbl), Server: function(ply, tbl). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.net.readBigTable("liaDoorDataBulk", function(tbl)
        if not tbl then return end
        for doorID, data in pairs(tbl) do
            lia.doors.updateCachedData(doorID, data)
        end
    end)

```

---

### lia.net.writeBigTable

#### 📋 Purpose
Send a large table by compressing and chunking it across the net.

#### ⏰ When Called
For big payloads (dialog sync, door data, keybinds) that exceed net limits.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `targets` | **Player|table|nil** | Single player, list of players, or nil to broadcast to humans. |
| `netStr` | **string** | Net message name to use. |
| `tbl` | **table** | Data to serialize. |
| `chunkSize` | **number|nil** | Optional override for chunk size. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local payload = {doors = lia.doors.stored, ts = os.time()}
    lia.net.writeBigTable(player.GetHumans(), "liaDoorDataBulk", payload, 2048)
    lia.net.addToCache("doorBulk", {payload.ts})

```

---

### lia.net.checkBadType

#### 📋 Purpose
Validate netvar payloads to prevent functions being networked.

#### ⏰ When Called
Internally before setting globals/locals.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Identifier for error reporting. |
| `object` | **any** | Value to validate for networking safety. |

#### ↩️ Returns
* boolean|nil
true if bad type detected.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.net.checkBadType("example", someTable) then return end

```

---

### lia.net.setNetVar

#### 📋 Purpose
Set a global netvar and broadcast it (or send to specific receiver).

#### ⏰ When Called
Whenever shared state changes (config sync, feature flags, etc.).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Netvar identifier. |
| `value` | **any** | Value to set. |
| `receiver` | **Player|table|nil** | Optional target(s); broadcasts when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.net.setNetVar("eventActive", true)
    lia.net.setNetVar("roundNumber", round, targetPlayers)

```

---

### lia.net.getNetVar

#### 📋 Purpose
Retrieve a global netvar with a fallback default.

#### ⏰ When Called
Client/server code reading synchronized state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Netvar identifier. |
| `default` | **any** | Fallback value if netvar is not set. |

#### ↩️ Returns
* any

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.net.getNetVar("eventActive", false) then
        DrawEventHUD()
    end

```

---

