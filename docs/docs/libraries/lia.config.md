# Config Library

This page explains how to add and access configuration settings.

---

## Overview

The config library stores server configuration values with descriptions and default settings. It also provides callbacks when values change so modules can react to new options.

---

### lia.config.add

**Description:**

Registers a new config option with the given key, display name, default value, and optional callback/data.

**Parameters:**

* `key` (`string`) — The unique key identifying the config.


* `name` (`string`) — The display name of the config option.


* `value` (`any`) — The default value of this config option.


* `callback` (`function`) — A function called when the value changes (optional).


* `data` (`table`) — Additional data customizing the option. Fields include:
    * desc (string) – Description shown in the menu.
    * category (string) – Category used to group the setting.
    * type (string) – "Boolean", "Int", "Float", "Color", or "Table". If omitted it is inferred from the default value.
    * min (number) – Minimum allowed value for numeric types.
    * max (number) – Maximum allowed value for numeric types.
    * decimals (number) – Number of decimals to display for Float types.
    * options (table) – List of choices for the "Table" type.
    * noNetworking (boolean) – Do not network this config to clients.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- Register a config option with limits and a callback
    lia.config.add(
        "walkSpeed",
        "Walk Speed",
        130,
        function(_, newValue)
            for _, ply in player.Iterator() do
                ply:SetWalkSpeed(newValue)
            end
        end,
        {
            desc = "Base walking speed for all players.",
            category = "Movement",
            type = "Int",
            min = 50,
            max = 300
        }
    )
```

---

### lia.config.setDefault

**Description:**

Changes the stored default for an existing config option without affecting its current value or notifying clients.

**Parameters:**

* `key` (`string`) — The key identifying the config.


* `value` (`any`) — The new default value.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.setDefault
    lia.config.setDefault("maxPlayers", 32)
```

---

### lia.config.forceSet

**Description:**

Sets a config value directly without running callbacks or sending network updates. The value is saved unless `noSave` is true.

**Parameters:**

* `key` (`string`) — The key identifying the config.


* `value` (`any`) — The new value to set.


* `noSave` (`boolean`) — If true, does not save to disk.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.forceSet
    lia.config.forceSet("someSetting", true, true)
```

---

### lia.config.set

**Description:**

Sets a config value, saves it server‑side, runs the callback with the old and new values, and networks the update to clients unless the config is marked `noNetworking`.

**Parameters:**

* `key` (`string`) — The key identifying the config.


* `value` (`any`) — The new value to set.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.set
    lia.config.set("maxPlayers", 24)
```

---

### lia.config.get

**Description:**

Retrieves the current value of a config. If no value is set, the stored default is returned or the supplied fallback is used. Color tables are automatically converted to `Color` objects.

**Parameters:**

* `key` (`string`) — The key identifying the config.


* `default` (`any`) — Fallback value if the config is not found.


**Realm:**

* Shared


**Returns:**

* (any) The config's value or the provided default.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.get
    local players = lia.config.get("maxPlayers", 64)
```

---

### lia.config.load

**Description:**

Loads config values from the database (server side) and stores them in `lia.config`. Any missing entries are inserted with their defaults. When finished the "InitializedConfig" hook is run. Clients simply wait for the data and then fire the same hook.

**Parameters:**

* None


**Realm:**

* Shared


    Internal Function:

    true

**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.load
    lia.config.load()
```

---

### lia.config.getChangedValues

**Description:**

Returns a table of all config entries where the current value differs from the default.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* (table) Key-value pairs of changed config entries.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.getChangedValues
    local changed = lia.config.getChangedValues()
```

---

### lia.config.send

**Description:**

Sends all changed config values to a client. If no client is specified the values are broadcast to everyone.

**Parameters:**

* `client` (`player`) — The player to receive the config data.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Broadcast changed configs to all players
    lia.config.send()
```

---

### lia.config.save

**Description:**

Writes all changed config values to the database so they persist across restarts.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.config.save
    lia.config.save()
```

---

### lia.config.convertToDatabase

**Description:**

Moves legacy `lia.config` data from the `data/lilia` folder into the `lia_config` database table. Players are prevented from joining while the conversion runs. If `changeMap` is true, the current map reloads when finished.

**Parameters:**

* `changeMap` (`boolean`) – Whether to reload the map after conversion completes.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    -- Force config conversion and reload the map
    lia.config.convertToDatabase(true)
```
