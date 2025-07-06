# Networking Library

This page documents network variable and message helpers.

---

## Overview

The networking library synchronizes data between the server and clients. It

wraps a few Garry's Mod networking helpers so global variables can be stored in

`lia.net.globals` and automatically replicated. Any values sent through this

system are synced to players on spawn using `PlayerInitialSpawn` and must not

contain functions (or tables holding functions) as they cannot be serialized.

---

### setNetVar

**Purpose**

Stores a value in `lia.net.globals` and optionally broadcasts the change to clients.

**Parameters**

* `key` (*string*): Name of the variable.
* `value` (*any*): Value to store.
* `receiver` (*Player|table|nil*): Optional target player(s).

**Realm**

`Server`

**Returns**

* `nil`

**Example**

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

Retrieves a value from `lia.net.globals`, returning a default if not set.

**Parameters**

* `key` (*string*): Variable name.
* `default` (*any*): Fallback value if unset.

**Realm**

`Shared`

**Returns**

* *any*: Stored value or default.

**Example**

```lua
-- Inform new players of the current round and previous champion
hook.Add("PlayerInitialSpawn", "ShowRound", function(ply)
    local round = getNetVar("round", 0)
    ply:ChatPrint(string.format("Current round: %s", round))

    local lastWinner = getNetVar("last_winner")
    if IsValid(lastWinner) then
        ply:ChatPrint(string.format("Last round won by %s", lastWinner:Name()))
    end
end)
```

---

#### Library Conventions

1. **Namespace**
   When formatting libraries, make sure to only document lia.* functions of that type. For example if you are documenting workshop.lua, you'd document lia.workshop functions .

2. **Shared Definitions**
   Omit any parameters or fields already documented in `docs/definitions.lua`.

3. **Internal-Only Functions**
   If this function is not meant to be used outside the internal scope of the gamemode, such as lia.module.load, add the “Internal function” note (see above).
