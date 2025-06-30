# Networking Library

This page documents network variable and message helpers.

---

## Overview

The networking library synchronizes data between the server and clients. It provides wrappers around net messages and networked variables.

---

### setNetVar(key, value, receiver)

    
**Description:**

Stores a global networked variable and broadcasts it to clients. When a
receiver is specified the update is only sent to those players.
**Parameters:**

* key (string) – Name of the variable.
* value (any) – Value to store.
* receiver (Player|table|nil) – Optional receiver(s) for the update.
**Realm:**

* Server
**Returns:**

* nil
**Example Usage:**

```lua
    -- Start a new round and only inform the winner
    local round = getNetVar("round", 0) + 1
    setNetVar("round", round)
    local winner = DetermineWinner()
    setNetVar("last_winner", winner, winner)
    hook.Run("RoundStarted", round)
```

---


### getNetVar(key, default)

    
**Description:**

Retrieves a global networked variable previously set by setNetVar.
**Parameters:**

* key (string) – Variable name.
* default (any) – Fallback value if the variable is not set.
**Realm:**

* Shared
**Returns:**

* any – Stored value or default.
**Example Usage:**

```lua
    -- Inform a joining player of the current round and last winner
    hook.Add("PlayerInitialSpawn", "ShowRound", function(ply)
        ply:ChatPrint("Current round: " .. getNetVar("round", 0))
        local winner = getNetVar("last_winner")
        if IsValid(winner) then
            ply:ChatPrint("Last round won by " .. winner:Name())
        end
    end)
```
