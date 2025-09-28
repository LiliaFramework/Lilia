# Keybind Library

This page documents the functions for working with player keybinds and input management.

---

## Overview

The keybind library (`lia.keybind`) provides a comprehensive system for managing player keybinds, input handling, and key configuration in the Lilia framework, enabling customizable control schemes and enhanced user interaction capabilities. This library handles sophisticated keybind management with support for complex key combinations, context-sensitive bindings, and dynamic key assignment based on player state or game mode. The system features advanced input processing with support for multiple input devices, gesture recognition, and customizable input sensitivity settings to accommodate different player preferences and accessibility needs. It includes comprehensive keybind registration with validation systems, conflict detection, and automatic resolution to ensure smooth user experience. The library provides robust saving and loading functionality with cloud synchronization, profile management, and backup systems to preserve player preferences across sessions and devices. Additional features include keybind visualization tools, tutorial systems for new players, and integration with the framework's UI system for creating intuitive and responsive control interfaces that enhance player comfort and gameplay efficiency.

---

### add

**Purpose**

Adds a new keybind to the keybind system.

**Parameters**

* `keybindData` (*table*): The keybind data table containing name, key, callback, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a basic keybind
lia.keybind.add({
    name = "Jump",
    key = KEY_SPACE,
    callback = function(client)
        client:ConCommand("+jump")
    end
})

-- Add a keybind with more options
lia.keybind.add({
    name = "Sprint",
    key = KEY_LSHIFT,
    callback = function(client)
        client:ConCommand("+speed")
    end,
    description = "Hold to sprint",
    category = "Movement"
})

-- Add a keybind with conditions
lia.keybind.add({
    name = "Use Item",
    key = KEY_E,
    callback = function(client)
        local character = client:getChar()
        if character then
            local item = character:getInventory():getSelectedItem()
            if item then
                item:use(client)
            end
        end
    end,
    description = "Use selected item",
    category = "Inventory"
})

-- Use in a function
local function createKeybind(name, key, callback, description)
    lia.keybind.add({
        name = name,
        key = key,
        callback = callback,
        description = description or ""
    })
    print("Keybind created: " .. name)
end
```

---

### get

**Purpose**

Gets a keybind by name.

**Parameters**

* `name` (*string*): The keybind name.

**Returns**

* `keybind` (*table*): The keybind data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a keybind
local function getKeybind(name)
    return lia.keybind.get(name)
end

-- Use in a function
local function checkKeybindExists(name)
    local keybind = lia.keybind.get(name)
    if keybind then
        print("Keybind exists: " .. name)
        return true
    else
        print("Keybind not found: " .. name)
        return false
    end
end

-- Use in a function
local function showKeybindInfo(name)
    local keybind = lia.keybind.get(name)
    if keybind then
        print("Keybind: " .. name)
        print("Key: " .. keybind.key)
        print("Description: " .. keybind.description)
        return keybind
    else
        print("Keybind not found")
        return nil
    end
end

-- Use in a function
local function getKeybindKey(name)
    local keybind = lia.keybind.get(name)
    return keybind and keybind.key or nil
end
```

---

### save

**Purpose**

Saves keybind data to the database.

**Parameters**

* `client` (*Player*): The client to save keybinds for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save keybinds for client
local function saveKeybinds(client)
    lia.keybind.save(client)
end

-- Use in a function
local function savePlayerKeybinds(client)
    lia.keybind.save(client)
    print("Keybinds saved for " .. client:Name())
end

-- Use in a function
local function saveAllPlayerKeybinds()
    for _, client in player.Iterator() do
        lia.keybind.save(client)
    end
    print("All player keybinds saved")
end

-- Use in a hook
hook.Add("PlayerDisconnected", "SaveKeybinds", function(client)
    lia.keybind.save(client)
end)
```

---

### load

**Purpose**

Loads keybind data from the database.

**Parameters**

* `client` (*Player*): The client to load keybinds for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load keybinds for client
local function loadKeybinds(client)
    lia.keybind.load(client)
end

-- Use in a function
local function loadPlayerKeybinds(client)
    lia.keybind.load(client)
    print("Keybinds loaded for " .. client:Name())
end

-- Use in a function
local function loadAllPlayerKeybinds()
    for _, client in player.Iterator() do
        lia.keybind.load(client)
    end
    print("All player keybinds loaded")
end

-- Use in a hook
hook.Add("PlayerInitialSpawn", "LoadKeybinds", function(client)
    lia.keybind.load(client)
end)
```









