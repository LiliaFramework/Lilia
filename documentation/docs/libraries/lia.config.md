# Config Library

## lia.config.add

**Purpose:** Registers a new configuration variable with the Lilia config system. This function sets up the config's name, default value, type, description, category, and optional callback for when the value changes. The config is stored in `lia.config.stored`.

**Parameters:**
- `key` (string) - The unique key for the config variable.
- `name` (string) - The display name for the config variable (localized automatically).
- `value` (any) - The default value for the config variable.
- `callback` (function) - (Optional) Function to call when the config value changes.
- `data` (table) - Table containing additional config properties (type, desc, category, etc). String values such as `desc`, `category`, and entries in an `options` table are localized automatically.

**Returns:** None.

**Realm:** Shared.

**Example Usage:**
```lua
-- Add a new integer config variable for maximum players
lia.config.add("MaxPlayers", "Maximum Players", 32, function(old, new)
    print("Max players changed from", old, "to", new)
end, {
    desc = "The maximum number of players allowed on the server.",
    category = "server",
    type = "Int",
    min = 1,
    max = 128
})
```

## lia.config.getOptions

**Purpose:** Retrieves the available options for a configuration variable. This function returns either the static options defined in the config data or dynamically generated options from a function.

**Parameters:**
- `key` (string) - The config variable key.

**Returns:** table - An array of available options for the config variable. If no options are defined or the config doesn't exist, returns an empty table.

**Realm:** Shared.

**Example Usage:**
```lua
-- Get options for a dropdown config
local options = lia.config.getOptions("PlayerModel")
-- Returns: {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", ...}

-- Get options from a dynamic function
local timeOptions = lia.config.getOptions("TimeScale")
-- Returns: {"1x", "2x", "4x", "8x"} (if defined by optionsFunc)
```

**Notes:**
- If the config has an `optionsFunc`, it calls that function to generate options dynamically
- If the config has static `options` defined, it returns those directly
- String values in the options are automatically localized
- Returns an empty table if the config doesn't exist or has no options

## lia.config.setDefault

**Purpose:** Sets the default value for a given config variable. This does not change the current value, only the default.

**Parameters:**
- `key` (string) - The config variable key.
- `value` (any) - The new default value.

**Returns:** None.

**Realm:** Shared.

**Example Usage:**
```lua
-- Change the default walk speed to 150
lia.config.setDefault("WalkSpeed", 150)
```

## lia.config.forceSet

**Purpose:** Sets the value of a config variable, bypassing any callbacks or networking, and optionally skips saving to the database.

**Parameters:**
- `key` (string) - The config variable key.
- `value` (any) - The value to set.
- `noSave` (boolean) - If true, does not save the config to the database.

**Returns:** None.

**Realm:** Shared.

**Example Usage:**
```lua
-- Force the money limit to 10000 without saving to the database
lia.config.forceSet("MoneyLimit", 10000, true)
```

## lia.config.set

**Purpose:** Sets the value of a config variable, triggers networking to clients (if applicable), calls the callback, and saves the config.

**Parameters:**
- `key` (string) - The config variable key.
- `value` (any) - The value to set.

**Returns:** None.

**Realm:** Shared (server triggers networking).

**Example Usage:**
```lua
-- Set the walk speed to 140 and notify all clients
lia.config.set("WalkSpeed", 140)
```

## lia.config.get

**Purpose:** Retrieves the value of a config variable. If the value is not set, returns the default or a provided fallback.

**Parameters:**
- `key` (string) - The config variable key.
- `default` (any) - (Optional) Value to return if the config is not found.

**Returns:** Any - The current value, the default, or the provided fallback.

**Realm:** Shared.

**Example Usage:**
```lua
-- Get the current money limit, or 5000 if not set
local limit = lia.config.get("MoneyLimit", 5000)
```

## lia.config.load

**Purpose:** Loads all config variables from the database for the current schema/gamemode. If a config is missing, it is inserted with its default value. On the client, requests the config list from the server.

**Parameters:** None.

**Returns:** None.

**Realm:** Server (loads from DB), Client (requests from server).

**Example Usage:**
```lua
-- Load all config variables at server startup
lia.config.load()
```

## lia.config.getChangedValues

**Purpose:** Returns a table of all config variables whose value differs from their default.

**Parameters:** None.

**Returns:** table - A table of changed config key-value pairs.

**Realm:** Server.

**Example Usage:**
```lua
-- Get all changed config values for saving
local changed = lia.config.getChangedValues()
```

## lia.config.send

**Purpose:** Sends the current changed config values to a specific client or broadcasts to all clients.

**Parameters:**
- `client` (Player) - (Optional) The client to send to. If nil, broadcasts to all.

**Returns:** None.

**Realm:** Server.

**Example Usage:**
```lua
-- Send config to a specific client
lia.config.send(somePlayer)

-- Broadcast config to all clients
lia.config.send()
```

## lia.config.save

**Purpose:** Saves all changed config values to the database for the current schema/gamemode.

**Parameters:** None.

**Returns:** None.

**Realm:** Server.

**Example Usage:**
```lua
-- Save all config changes to the database
lia.config.save()
```

