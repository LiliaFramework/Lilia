# Flags Library

This page explains permission flag management.

---

## Overview

The flags library assigns text-based permission strings to characters. The library exposes a `lia.flag.list` table that stores registered flags and their callbacks. Flags are referenced by **single-character identifiers**. They grant characters extra abilities but are often best replaced with specific in‑character checks when possible.

---

### lia.flag.add

**Description:**

Registers a new flag by adding it to `lia.flag.list`.

Each flag entry stores a description and an optional callback. The callback is invoked when the flag is given or removed from a character and on player spawn if the character already has the flag.

**Parameters:**

* `flag` (`string`) – The unique single-character identifier for the flag.


* `desc` (`string`) – A description of what the flag does.


* `callback` (`function`) – Optional function called with `(client, isGiven)` whenever the flag is toggled. `isGiven` is `true` when granting the flag or reapplying on spawn and `false` when it is removed.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- Give players with the "p" flag a physgun whenever the flag is granted.
    lia.flag.add("p", "Access to the physgun", function(client, isGiven)
        if isGiven then
            client:Give("weapon_physgun")
        else
            client:StripWeapon("weapon_physgun")
        end
    end)
```

---

### lia.flag.onSpawn

**Description:**

Called on the server when a player spawns. It iterates over the character's flags and runs

their callbacks, passing `(client, true)` so any flag effects are reapplied. The base

gamemode already calls this from its `PlayerSpawn` hook, but modules may invoke it manually

after custom spawn logic.

**Parameters:**

* `client` (`Player`) – The player who spawned.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Re-run flag callbacks whenever a player respawns
    hook.Add("PlayerSpawn", "ApplyFlagCallbacks", function(ply)
        lia.flag.onSpawn(ply)
    end)
```

---

### Default Flags

The base gamemode registers several permission flags. Modules may define more,

but these are always available:

* `p` – Access to the physgun.

* `t` – Access to the toolgun.

* `C` – Allows spawning vehicles.

* `z` – Allows spawning SWEPS.

* `E` – Allows spawning SENTs.

* `L` – Allows spawning Effects.

* `r` – Allows spawning ragdolls.

* `e` – Allows spawning props.

* `n` – Allows spawning NPCs.

* `Z` – Can invite players to your faction.

* `P` – Access to PAC3 features.
