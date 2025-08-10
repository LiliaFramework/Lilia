# Config Library

This page explains how to add and access configuration settings.

---

## Overview

The configuration library provides a centralized system for managing settings across the framework. It supports:

* **Type-safe values** with automatic detection for strings, numbers, booleans, colors and tables.
* **Validation rules** such as minimum/maximum ranges and selectable options.
* **Change callbacks** for reacting to updates at runtime.
* **Client-server synchronization** so changes propagate to connected players.
* **Category organization** and description text for use in UI.
* **Default value management** with persistence to the database.

---

### lia.config.add

**Purpose**

Registers a new config option with the given key, display name, default value, and optional callback. A data table describing the option is **required**. If an option with the same key already exists, its current value is kept.

**Parameters**

* `key` (*string*): Unique identifier for the option.

* `name` (*string*): Display name shown in menus. Localized automatically with `L`.

* `value` (*any*): Default stored value.

* `callback` (*function*): Function run when the value changes. Receives `(oldValue, newValue)`. *Optional*.

* `data` (*table*): Table describing the option. Common fields include `desc`, `category`, `type`, `min`, `max`, `decimals`, `options`, and `noNetworking`. `category` defaults to `L("character")` and `noNetworking` defaults to `false`. Additional fields are accepted and stored. Any string values for `desc`, `category`, or within `options` are localized automatically. If `type` is omitted, it is inferred from `value`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a walk-speed option with limits and a callback
lia.config.add(
    "walkSpeed",
    "walkSpeed",
    130,
    function(_, newValue)
        for _, ply in player.Iterator() do
            ply:SetWalkSpeed(newValue)
        end
    end,
    {
        desc = "walkSpeedDesc",
        category = "movement",
        type = "Int",
        min = 50,
        max = 300
    }
)
```

---

### lia.config.setDefault

**Purpose**

Changes the stored default for an existing config option without affecting its current value or notifying clients. This does not automatically persist the new default; call `lia.config.save()` to commit it.

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

Sets a config value directly without running callbacks or networking the update. The value is saved unless `noSave` is `true`. If the key does not exist, the call has no effect.

**Parameters**

* `key` (*string*): Key identifying the option.

* `value` (*any*): New value to set.

* `noSave` (*boolean*): If `true`, value is not written to disk. *Default*: `false`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.config.forceSet("someSetting", true, true)
```

---

### lia.config.set

**Purpose**

Sets a config value and updates `lia.config.stored`. On the server it broadcasts a `cfgSet` net message to clients (unless the option is marked `noNetworking`), runs the change callback with `(oldValue, newValue)`, and saves the result. On the client it only updates the local value. If the key does not exist, nothing happens.

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

Retrieves the current value of a config entry. If unset, returns the stored default or the provided fallback. Color tables are converted to `Color` objects automatically.

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

On the server, loads config values from the database for the current schema and inserts any missing entries with their defaults. After loading, the `InitializedConfig` hook is fired. On the client, `lia.config.load` requests the config list from the server.

**Parameters**

*None*

**Realm**

`Server` and `Client`

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

* `client` (*Player | nil*): Player to receive the config data. If omitted, all clients receive it.

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

Writes all changed config values to the database so they persist across restarts. Existing rows for the current schema are replaced.

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
