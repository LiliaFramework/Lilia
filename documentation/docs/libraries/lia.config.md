# Config Library

This page explains how to add and access configuration settings.

---

## Overview

The config library stores server configuration values with descriptions and default settings. It also provides callbacks when values change, so modules can react to new options.

---

### lia.config.add

**Purpose**

Registers a new config option with the given key, display name, default value, and optional callback. A data table describing the option is **required**.

**Parameters**

* `key` (*string*): Unique identifier for the option.

* `name` (*string*): Display name shown in menus.

* `value` (*any*): Default stored value.

* `callback` (*function*): Function run when the value changes. *Optional*.

* `data` (*table*): Table describing the option. Common fields include `desc`, `category`, `type`, `min`, `max`, `decimals`, `options`, and `noNetworking`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a walk-speed option with limits and a callback
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

**Purpose**

Changes the stored default for an existing config option without affecting its current value or notifying clients.

**Parameters**

* `key` (*string*): Key identifying the option.

* `value` (*any*): New default value.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Update the default maximum players
lia.config.setDefault("maxPlayers", 32)
```

---

### lia.config.forceSet

**Purpose**

Sets a config value directly without running callbacks or networking the update. The value is saved unless `noSave` is `true`.

**Parameters**

* `key` (*string*): Key identifying the option.

* `value` (*any*): New value to set.

* `noSave` (*boolean*): If `true`, value is not written to disk.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.config.forceSet("someSetting", true, true)
```

---

### lia.config.set

**Purpose**

Sets a config value, saves it server-side, triggers callbacks with the old and new values, and networks the update unless the config is marked `noNetworking`.

**Parameters**

* `key` (*string*): Key identifying the option.

* `value` (*any*): New value to set.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.config.set("maxPlayers", 24)
```

---

### lia.config.get

**Purpose**

Retrieves the current value of a config entry. If unset, returns the stored default or the provided fallback.

**Parameters**

* `key` (*string*): Key identifying the config option.

* `default` (*any*): Value to return if the config is not found.

**Realm**

`Shared`

**Returns**

* *any*: The config value or the default.

**Example Usage**

```lua
local players = lia.config.get("maxPlayers", 64)
```

---

### lia.config.load

**Purpose**

Loads config values from the database and stores them in `lia.config`. Missing entries are inserted with their defaults.

**Parameters**

*None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.config.load()
```

---

### lia.config.getChangedValues

**Purpose**

Returns a table of all config entries whose current value differs from the default.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *table*: Key-value pairs of changed config entries.

**Example Usage**

```lua
local changed = lia.config.getChangedValues()
```

---

### lia.config.send

**Purpose**

Sends all changed config values to a client. If no client is provided, the values are broadcast to everyone.

**Parameters**

* `client` (*Player*): Player to receive the config data.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Broadcast current config to every player
lia.config.send()
```

---

### lia.config.save

**Purpose**

Writes all changed config values to the database so they persist across restarts.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.config.save()
```

---

---
