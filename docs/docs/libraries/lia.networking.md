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

**Description:**

Stores a value in `lia.net.globals` and sends it to every client or only the
given recipients. If the value differs from what was previously stored the
**NetVarChanged** hook fires once on the server and again on each client that
receives the update. When called for global variables the hook's entity argument
is `nil`. Any attempt to store functions results in an error.

**Parameters:**

* `key` (`string`) – Name of the variable.


* `value` (`any`) – Value to store.


* `receiver` (`Player|table|nil`) – Optional receiver(s) for the update.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

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

**Description:**

Returns the value stored in `lia.net.globals` or the given default if it has not
been set yet. On the client this table is kept up to date through net messages,
so any values assigned with `setNetVar` will be available after `PlayerInitialSpawn`.

**Parameters:**

* `key` (`string`) – Variable name.


* `default` (`any`) – Fallback value if the variable is not set.


**Realm:**

* Shared


**Returns:**

* any – Stored value or default.


**Example Usage:**

```lua
    -- Inform new players of the current round and previous champion
    hook.Add("PlayerInitialSpawn", "ShowRound", function(ply)
        local round = getNetVar("round", 0)
        ply:ChatPrint(string.format(L("currentRound"), round))

        local lastWinner = getNetVar("last_winner")
        if IsValid(lastWinner) then
            ply:ChatPrint(string.format(L("lastRoundWinner"), lastWinner:Name()))
        end
    end)
```
