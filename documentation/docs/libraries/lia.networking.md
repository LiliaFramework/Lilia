# Networking Library

This page documents network-variable and message helpers.

---

## Overview

The networking library synchronises data between the server and clients. It wraps a few Garry’s Mod helpers so global variables can be stored in `lia.net.globals` and automatically replicated. Any value sent through this system is re-sent to players on spawn via `PlayerInitialSpawn` and **must not** contain functions (or tables that contain functions), as they cannot be serialised.

---

### checkBadType

**Purpose**

Validates a value before it is networked, recursively ensuring no functions are present.

**Parameters**

* `name` (*string*): Identifier for error reporting.

* `object` (*any*): Value to inspect.

**Realm**

`Server`

**Returns**

* `boolean`: `true` if a disallowed type was found.

**Example Usage**

```lua
if checkBadType("roundData", someTable) then
    return
end
```

---

### setNetVar

**Purpose**

Stores a value in `lia.net.globals` and optionally broadcasts the change to clients.

**Parameters**

* `key` (*string*): Name of the variable.

* `value` (*any*): Value to store.

* `receiver` (*Player | table | nil*): Target player or list of players. `nil` broadcasts to everyone.

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
