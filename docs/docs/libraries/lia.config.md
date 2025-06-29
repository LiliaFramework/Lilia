# Config Library

This page explains how to add and access configuration settings.

---

## Overview

The config library stores server configuration values with descriptions and default settings. It also provides callbacks when values change so modules can react to new options.

---

### `lia.config.add(key, name, value, callback, data)`

    
    Description:
    Registers a new config option with the given key, display name, default value, and optional callback/data.
    
    Parameters:
    key (string) — The unique key identifying the config.
    name (string) — The display name of the config option.
    value (any) — The default value of this config option.
    callback (function) — A function called when the value changes (optional).
    data (table) — Additional data for this config option, including config type, category, description, etc.
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- Register a config option with a callback that prints when it changes
    lia.config.add(
    "maxPlayers",                 -- unique key
    "Maximum Players",            -- name shown in the menu
    64,                            -- default value
    function(old, new)
    print("Player limit updated from", old, "to", new)
    end,
    {category = "Server"}
    )

### `lia.config.setDefault(key, value)`

    
    Description:
    Overrides the default value of an existing config.
    
    Parameters:
    key (string) — The key identifying the config.
    value (any) — The new default value.
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.setDefault
    lia.config.setDefault("maxPlayers", 32)

### `lia.config.forceSet(key, value, noSave)`

    
    Description:
    Forces a config value without triggering networking or callback if 'noSave' is true, then optionally saves.
    
    Parameters:
    key (string) — The key identifying the config.
    value (any) — The new value to set.
    noSave (boolean) — If true, does not save to disk.
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.forceSet
    lia.config.forceSet("someSetting", true, true)

### `lia.config.set(key, value)`

    
    Description:
    Sets a config value, runs callback, and handles networking (if on server). Also saves the config.
    
    Parameters:
    key (string) — The key identifying the config.
    value (any) — The new value to set.
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.set
    lia.config.set("maxPlayers", 24)

### `lia.config.get(key, default)`

    
    Description:
    Retrieves the current value of a config, or returns a default if neither value nor default is set.
    
    Parameters:
    key (string) — The key identifying the config.
    default (any) — Fallback value if the config is not found.
    
    Returns:
    (any) The config's value or the provided default.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.get
    local players = lia.config.get("maxPlayers", 64)

### `lia.config.load()`

    
    Description:
    Loads the config data from storage (server-side) and updates the stored config values.
    Triggers "InitializedConfig" hook once done.
    
    Parameters:
    None
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Internal Function:
    true
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.load
    lia.config.load()

### `lia.config.getChangedValues()`

    
    Description:
    Returns a table of all config entries where the current value differs from the default.
    
    Parameters:
    None
    
    Returns:
    (table) Key-value pairs of changed config entries.
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.getChangedValues
    local changed = lia.config.getChangedValues()

### `lia.config.send(client)`

    
    Description:
    Sends current changed config values to a specified client.
    
    Parameters:
    client (player) — The player to receive the config data.
    
    Returns:
    nil
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.send
    lia.config.send(client)

### `lia.config.save()`

    
    Description:
    Saves all changed config values to persistent storage.
    
    Parameters:
    None
    
    Returns:
    nil
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.config.save
    lia.config.save()
