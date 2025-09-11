# Keybind Library

This page documents the functions for working with player keybinds and input management.

---

## Overview

The keybind library (`lia.keybind`) provides a comprehensive system for managing player keybinds, input handling, and key configuration in the Lilia framework, enabling customizable control schemes and enhanced user interaction capabilities. This library handles sophisticated keybind management with support for complex key combinations, context-sensitive bindings, and dynamic key assignment based on player state or game mode. The system features advanced input processing with support for multiple input devices, gesture recognition, and customizable input sensitivity settings to accommodate different player preferences and accessibility needs. It includes comprehensive keybind registration with validation systems, conflict detection, and automatic resolution to ensure smooth user experience. The library provides robust saving and loading functionality with cloud synchronization, profile management, and backup systems to preserve player preferences across sessions and devices. Additional features include keybind visualization tools, tutorial systems for new players, and integration with the framework's UI system for creating intuitive and responsive control interfaces that enhance player comfort and gameplay efficiency.

---

### lia.keybind.add

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

### lia.keybind.get

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

### lia.keybind.save

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
    for _, client in ipairs(player.GetAll()) do
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

### lia.keybind.load

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
    for _, client in ipairs(player.GetAll()) do
        lia.keybind.load(client)
    end
    print("All player keybinds loaded")
end

-- Use in a hook
hook.Add("PlayerInitialSpawn", "LoadKeybinds", function(client)
    lia.keybind.load(client)
end)
```

---

### lia.keybind.set

**Purpose**

Sets a keybind for a client.

**Parameters**

* `client` (*Player*): The client to set the keybind for.
* `name` (*string*): The keybind name.
* `key` (*number*): The key code.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set keybind for client
local function setKeybind(client, name, key)
    lia.keybind.set(client, name, key)
end

-- Use in a function
local function setPlayerKeybind(client, name, key)
    lia.keybind.set(client, name, key)
    client:notify("Keybind set: " .. name .. " = " .. key)
end

-- Use in a function
local function resetKeybind(client, name)
    local keybind = lia.keybind.get(name)
    if keybind then
        lia.keybind.set(client, name, keybind.defaultKey)
        client:notify("Keybind reset: " .. name)
    end
end

-- Use in a function
local function setMultipleKeybinds(client, keybinds)
    for name, key in pairs(keybinds) do
        lia.keybind.set(client, name, key)
    end
    client:notify("Multiple keybinds set")
end
```

---

### lia.keybind.getKey

**Purpose**

Gets the key for a keybind.

**Parameters**

* `client` (*Player*): The client to get the keybind for.
* `name` (*string*): The keybind name.

**Returns**

* `key` (*number*): The key code.

**Realm**

Shared.

**Example Usage**

```lua
-- Get keybind key
local function getKeybindKey(client, name)
    return lia.keybind.getKey(client, name)
end

-- Use in a function
local function showPlayerKeybind(client, name)
    local key = lia.keybind.getKey(client, name)
    if key then
        client:notify("Keybind " .. name .. " = " .. key)
    else
        client:notify("Keybind not found: " .. name)
    end
end

-- Use in a function
local function checkKeybindKey(client, name, expectedKey)
    local key = lia.keybind.getKey(client, name)
    return key == expectedKey
end

-- Use in a function
local function showAllPlayerKeybinds(client)
    local keybinds = lia.keybind.getAll()
    for _, keybind in ipairs(keybinds) do
        local key = lia.keybind.getKey(client, keybind.name)
        client:notify(keybind.name .. " = " .. (key or "Not set"))
    end
end
```

---

### lia.keybind.getAll

**Purpose**

Gets all registered keybinds.

**Parameters**

*None*

**Returns**

* `keybinds` (*table*): Table of all keybinds.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all keybinds
local function getAllKeybinds()
    return lia.keybind.getAll()
end

-- Use in a function
local function showAllKeybinds()
    local keybinds = lia.keybind.getAll()
    print("Available keybinds:")
    for _, keybind in ipairs(keybinds) do
        print("- " .. keybind.name .. " (" .. keybind.description .. ")")
    end
end

-- Use in a function
local function getKeybindCount()
    local keybinds = lia.keybind.getAll()
    return #keybinds
end

-- Use in a function
local function getKeybindsByCategory(category)
    local keybinds = lia.keybind.getAll()
    local filtered = {}
    for _, keybind in ipairs(keybinds) do
        if keybind.category == category then
            table.insert(filtered, keybind)
        end
    end
    return filtered
end
```

---

### lia.keybind.remove

**Purpose**

Removes a keybind from the system.

**Parameters**

* `name` (*string*): The keybind name to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a keybind
local function removeKeybind(name)
    lia.keybind.remove(name)
end

-- Use in a function
local function removeOldKeybind(name)
    lia.keybind.remove(name)
    print("Keybind removed: " .. name)
end

-- Use in a function
local function cleanupOldKeybinds()
    local oldKeybinds = {"old_keybind1", "old_keybind2", "old_keybind3"}
    for _, name in ipairs(oldKeybinds) do
        lia.keybind.remove(name)
    end
    print("Old keybinds cleaned up")
end

-- Use in a function
local function removeKeybindsByCategory(category)
    local keybinds = lia.keybind.getAll()
    for _, keybind in ipairs(keybinds) do
        if keybind.category == category then
            lia.keybind.remove(keybind.name)
        end
    end
    print("Keybinds removed for category: " .. category)
end
```

---

### lia.keybind.clear

**Purpose**

Clears all keybinds from the system.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Clear all keybinds
local function clearAllKeybinds()
    lia.keybind.clear()
end

-- Use in a function
local function resetKeybindSystem()
    lia.keybind.clear()
    print("Keybind system reset")
end

-- Use in a function
local function reloadKeybinds()
    lia.keybind.clear()
    -- Re-register default keybinds
    lia.keybind.add({name = "Jump", key = KEY_SPACE, callback = function(client) client:ConCommand("+jump") end})
    lia.keybind.add({name = "Sprint", key = KEY_LSHIFT, callback = function(client) client:ConCommand("+speed") end})
    print("Keybinds reloaded")
end

-- Use in a command
lia.command.add("resetkeybinds", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.keybind.clear()
        client:notify("All keybinds cleared")
    end
})
```

---

### lia.keybind.isPressed

**Purpose**

Checks if a keybind is currently pressed.

**Parameters**

* `client` (*Player*): The client to check.
* `name` (*string*): The keybind name.

**Returns**

* `isPressed` (*boolean*): True if the keybind is pressed.

**Realm**

Client.

**Example Usage**

```lua
-- Check if keybind is pressed
local function isKeybindPressed(client, name)
    return lia.keybind.isPressed(client, name)
end

-- Use in a function
local function checkSprintKeybind(client)
    if lia.keybind.isPressed(client, "Sprint") then
        print("Player is sprinting")
        return true
    else
        print("Player is not sprinting")
        return false
    end
end

-- Use in a function
local function checkJumpKeybind(client)
    if lia.keybind.isPressed(client, "Jump") then
        print("Player is jumping")
        return true
    else
        print("Player is not jumping")
        return false
    end
end

-- Use in a function
local function checkMultipleKeybinds(client, keybindNames)
    for _, name in ipairs(keybindNames) do
        if lia.keybind.isPressed(client, name) then
            print("Keybind pressed: " .. name)
        end
    end
end
```

---

### lia.keybind.wasPressed

**Purpose**

Checks if a keybind was just pressed.

**Parameters**

* `client` (*Player*): The client to check.
* `name` (*string*): The keybind name.

**Returns**

* `wasPressed` (*boolean*): True if the keybind was just pressed.

**Realm**

Client.

**Example Usage**

```lua
-- Check if keybind was just pressed
local function wasKeybindPressed(client, name)
    return lia.keybind.wasPressed(client, name)
end

-- Use in a function
local function checkJumpPress(client)
    if lia.keybind.wasPressed(client, "Jump") then
        print("Player just pressed jump")
        return true
    else
        print("Player did not just press jump")
        return false
    end
end

-- Use in a function
local function checkUsePress(client)
    if lia.keybind.wasPressed(client, "Use Item") then
        print("Player just pressed use item")
        return true
    else
        print("Player did not just press use item")
        return false
    end
end

-- Use in a function
local function checkActionPress(client, action)
    if lia.keybind.wasPressed(client, action) then
        print("Player just pressed " .. action)
        return true
    else
        print("Player did not just press " .. action)
        return false
    end
end
```

---

### lia.keybind.wasReleased

**Purpose**

Checks if a keybind was just released.

**Parameters**

* `client` (*Player*): The client to check.
* `name` (*string*): The keybind name.

**Returns**

* `wasReleased` (*boolean*): True if the keybind was just released.

**Realm**

Client.

**Example Usage**

```lua
-- Check if keybind was just released
local function wasKeybindReleased(client, name)
    return lia.keybind.wasReleased(client, name)
end

-- Use in a function
local function checkJumpRelease(client)
    if lia.keybind.wasReleased(client, "Jump") then
        print("Player just released jump")
        return true
    else
        print("Player did not just release jump")
        return false
    end
end

-- Use in a function
local function checkSprintRelease(client)
    if lia.keybind.wasReleased(client, "Sprint") then
        print("Player just released sprint")
        return true
    else
        print("Player did not just release sprint")
        return false
    end
end

-- Use in a function
local function checkActionRelease(client, action)
    if lia.keybind.wasReleased(client, action) then
        print("Player just released " .. action)
        return true
    else
        print("Player did not just release " .. action)
        return false
    end
end
```

---

### lia.keybind.getCategory

**Purpose**

Gets all keybinds in a category.

**Parameters**

* `category` (*string*): The category name.

**Returns**

* `keybinds` (*table*): Table of keybinds in the category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get keybinds by category
local function getKeybindsByCategory(category)
    return lia.keybind.getCategory(category)
end

-- Use in a function
local function showMovementKeybinds()
    local keybinds = lia.keybind.getCategory("Movement")
    print("Movement keybinds:")
    for _, keybind in ipairs(keybinds) do
        print("- " .. keybind.name .. " (" .. keybind.description .. ")")
    end
end

-- Use in a function
local function showInventoryKeybinds()
    local keybinds = lia.keybind.getCategory("Inventory")
    print("Inventory keybinds:")
    for _, keybind in ipairs(keybinds) do
        print("- " .. keybind.name .. " (" .. keybind.description .. ")")
    end
end

-- Use in a function
local function getCategoryKeybindCount(category)
    local keybinds = lia.keybind.getCategory(category)
    return #keybinds
end
```

---

### lia.keybind.getCategories

**Purpose**

Gets all keybind categories.

**Parameters**

*None*

**Returns**

* `categories` (*table*): Table of all categories.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all keybind categories
local function getKeybindCategories()
    return lia.keybind.getCategories()
end

-- Use in a function
local function showAllCategories()
    local categories = lia.keybind.getCategories()
    print("Available keybind categories:")
    for _, category in ipairs(categories) do
        print("- " .. category)
    end
end

-- Use in a function
local function getCategoryCount()
    local categories = lia.keybind.getCategories()
    return #categories
end

-- Use in a function
local function showCategoryInfo()
    local categories = lia.keybind.getCategories()
    for _, category in ipairs(categories) do
        local keybinds = lia.keybind.getCategory(category)
        print("Category " .. category .. ": " .. #keybinds .. " keybinds")
    end
end
```