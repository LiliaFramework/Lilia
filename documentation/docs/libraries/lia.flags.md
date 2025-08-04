# Flags Library

This page explains permission-flag management.

---

## Overview

The flags library assigns text-based permission strings to characters. All registered flags live in `lia.flag.list`, each referenced by a **single-character identifier**. Flags grant characters extra abilities, though—in many cases—specific in-character checks are preferable.

---

### lia.flag.add

**Purpose**

Registers a flag in `lia.flag.list`, storing its description and an optional callback. The callback runs whenever the flag is granted or removed and on every spawn if the character already has the flag.

**Parameters**

* `flag` (*string*): Unique single-character identifier.

* `desc` (*string*): Human-readable description of the flag’s effect.

* `callback` (*function*): Called as `callback(client, isGiven)` where `isGiven` is `true` when granting or re-applying on spawn, and `false` on removal. *Optional*.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Give players with the "p" flag a physgun whenever they receive it.
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

**Purpose**

Re-applies all flag callbacks for a player who just spawned by iterating over their character’s flags and calling each callback with `(client, true)`. The base gamemode already invokes this from its `PlayerSpawn` hook, but modules can call it manually after custom spawn logic.

**Parameters**

* `client` (*Player*): The player who spawned.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Re-run flag callbacks whenever a player respawns.
hook.Add("PlayerSpawn", "ApplyFlagCallbacks", function(ply)
    lia.flag.onSpawn(ply)
end)
```

---

### Default flags

The base gamemode registers the following permission flags. Additional flags can be defined by modules.

| Flag | Ability                        |
| ---- | ------------------------------ |
| `p`  | Access to the physgun          |
| `t`  | Access to the toolgun          |
| `C`  | Spawn vehicles                 |
| `z`  | Spawn SWEPS                    |
| `E`  | Spawn SENTs                    |
| `L`  | Spawn Effects                  |
| `r`  | Spawn ragdolls                 |
| `e`  | Spawn props                    |
| `n`  | Spawn NPCs                     |
| `Z`  | Invite players to your faction |
| `X`  | Invite players to your class   |
| `V`  | Manage faction roster          |
| `P`  | Use PAC3 features              |

---
