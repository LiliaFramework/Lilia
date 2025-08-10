# Networking Library

This page documents network-variable and message helpers.

---

## Overview

The networking library synchronises data between the server and clients. It wraps helpers so global variables can be stored in `lia.net.globals` and automatically replicated. It also supports chunked transfer of large tables between server and clients. Any value sent through this system is re-sent to players on spawn via `PlayerInitialSpawn` and **must not** contain functions (or tables that contain functions), as they cannot be serialised.

---

### lia.net.readBigTable

**Purpose**

Registers a handler that rebuilds large tables sent over the network in multiple compressed chunks. Clients acknowledge each chunk so the sender can throttle transmission.

**Parameters**

* `netStr` (*string*): Network message identifier to listen for.

* `callback` (*function*): Function invoked when the table is fully received. On the server the signature is `callback(ply, tbl)`, on the client it is `callback(tbl)`.

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

Splits a table into compressed chunks and streams it to one or more players. Used in conjunction with `lia.net.readBigTable`. Aborts if the table is not serialisable or cannot be compressed.

**Parameters**

* `targets` (*Player | Player[] | nil*): Recipient(s); `nil` streams to all human players.

* `netStr` (*string*): Network message identifier.

* `tbl` (*table*): Data to send. Must be JSON-serialisable (no functions).

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
```

---

### checkBadType

**Purpose**

Recursively validates a value before it is networked, ensuring neither it nor any nested key or value is a function. Any disallowed value triggers `lia.error` with a translated message.

**Parameters**

* `name` (*string*): Identifier for error reporting.

* `object` (*any*): Value to inspect.

**Realm**

`Server`

**Returns**

* `boolean | nil`: `true` if a disallowed type was found; otherwise `nil`.

**Example Usage**

```lua
if checkBadType("roundData", someTable) then
    return
end
```

---

### setNetVar

**Purpose**

Stores a value in `lia.net.globals` and broadcasts the change, optionally restricting it to a receiver. Disallowed types are rejected, and no network message is sent if the value has not changed. The `NetVarChanged` hook is fired after successful updates.

**Parameters**

* `key` (*string*): Name of the variable.

* `value` (*any*): Value to store.

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
```

---
