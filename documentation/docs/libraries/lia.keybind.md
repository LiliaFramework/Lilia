# Keybind Library

Keyboard binding registration, storage, and execution system for the Lilia framework.

---

Overview

The keybind library provides comprehensive functionality for managing keyboard bindings in the Lilia framework. It handles registration, storage, and execution of custom keybinds that can be triggered by players. The library supports both client-side and server-side keybind execution, with automatic networking for server-only keybinds. It includes persistent storage of keybind configurations, user interface for keybind management, and validation to prevent key conflicts. The library operates on both client and server sides, with the client handling input detection and UI, while the server processes server-only keybind actions. It ensures proper key mapping, callback execution, and provides a complete keybind management system for the gamemode.

---

### add

**Purpose**

Registers a new keybind with the keybind system, allowing players to bind custom actions to keyboard keys

**When Called**

During initialization of modules or when registering custom keybinds for gameplay features

**Parameters**

* `k` (*string|number*): Either the action name (string) or key code (number) depending on parameter format
* `d` (*table|string*): Either configuration table with keyBind, desc, onPress, etc. or action name (string)
* `desc` (*string, optional*): Description of the keybind action (used when d is action name)
* `cb` (*table, optional*): Callback table with onPress, onRelease, shouldRun, serverOnly functions (used when d is action name)

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add a basic keybind with table configuration
lia.keybind.add("openInventory", {
keyBind = KEY_I,
desc = "openInventoryDesc",
onPress = function()
local f1Menu = vgui.Create("liaMenu")
f1Menu:setActiveTab(L("inv"))
end
})

```

**Medium Complexity:**
```lua
-- Medium: Add keybind with conditional execution and server-only flag
lia.keybind.add("adminMode", {
keyBind = KEY_F1,
desc = "adminModeDesc",
serverOnly = true,
onPress = function(client)
if not IsValid(client) then return end
    client:ChatPrint(L("adminModeToggle"))
    -- Admin mode logic here
end,
shouldRun = function(client)
return client:IsAdmin()
end
})

```

**High Complexity:**
```lua
-- High: Add keybind with multiple callbacks and complex validation
lia.keybind.add("convertEntity", {
keyBind = KEY_E,
desc = "convertEntityDesc",
onPress = function(client)
if not IsValid(client) or not client:getChar() then return end
    local trace = client:GetEyeTrace()
    local targetEntity = trace.Entity
    -- Complex entity conversion logic
end,
onRelease = function(client)
-- Handle key release if needed
end,
shouldRun = function(client)
return client:getChar() ~= nil and client:GetEyeTrace().Entity:IsValid()
end,
serverOnly = true
})

```

---

### get

**Purpose**

Retrieves the current key code bound to a specific keybind action

**When Called**

When checking what key is currently bound to an action, typically in UI or validation code

**Parameters**

* `a` (*string*): The action name to get the key for
* `df` (*number, optional*): Default key code to return if no key is bound

**Returns**

* number - The key code bound to the action, or the default value if none is set

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get the key bound to open inventory
local inventoryKey = lia.keybind.get("openInventory")
print("Inventory key:", inventoryKey)

```

**Medium Complexity:**
```lua
-- Medium: Get key with fallback default
local adminKey = lia.keybind.get("adminMode", KEY_F1)
if adminKey == KEY_NONE then
    print("Admin mode not bound to any key")
    else
        print("Admin mode bound to:", input.GetKeyName(adminKey))
    end

```

**High Complexity:**
```lua
-- High: Check multiple keybinds and handle different states
local keybinds = {"openInventory", "adminMode", "quickTakeItem"}
local boundKeys = {}
for _, action in ipairs(keybinds) do
    local key = lia.keybind.get(action, KEY_NONE)
    if key ~= KEY_NONE then
        boundKeys[action] = {
        key = key,
        name = input.GetKeyName(key) or "Unknown"
        }
    end
end
-- Process bound keys...

```

---

### save

**Purpose**

Saves all current keybind configurations to a JSON file for persistent storage

**When Called**

When keybind settings are changed by the player or during shutdown to preserve settings

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Save keybinds after player changes settings
lia.keybind.save()

```

**Medium Complexity:**
```lua
-- Medium: Save keybinds with validation
local function saveKeybindsSafely()
    local success = pcall(function()
    lia.keybind.save()
end)
if success then
    print("Keybinds saved successfully")
    else
        print("Failed to save keybinds")
    end
end
saveKeybindsSafely()

```

**High Complexity:**
```lua
-- High: Save keybinds with backup and error handling
local function saveKeybindsWithBackup()
    -- Create backup of current settings
    local backupPath = "lilia/keybinds_backup.json"
    local currentPath = "lilia/keybinds.json"
    if file.Exists(currentPath, "DATA") then
        local currentData = file.Read(currentPath, "DATA")
        file.Write(backupPath, currentData)
    end
    -- Save new settings
    local success = pcall(function()
    lia.keybind.save()
end)
if not success then
    -- Restore from backup if save failed
    if file.Exists(backupPath, "DATA") then
        local backupData = file.Read(backupPath, "DATA")
        file.Write(currentPath, backupData)
    end
end
end
saveKeybindsWithBackup()

```

---

### load

**Purpose**

Loads keybind configurations from a JSON file and applies them to the keybind system

**When Called**

During client initialization to restore previously saved keybind settings

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load keybinds during initialization
lia.keybind.load()

```

**Medium Complexity:**
```lua
-- Medium: Load keybinds with validation and fallback
local function loadKeybindsSafely()
    local success = pcall(function()
    lia.keybind.load()
end)
if success then
    print("Keybinds loaded successfully")
    hook.Run("KeybindsLoaded")
    else
        print("Failed to load keybinds, using defaults")
        -- Reset to default keybinds
        for action, data in pairs(lia.keybind.stored) do
            if istable(data) and data.default then
                data.value = data.default
            end
        end
    end
end
loadKeybindsSafely()

```

**High Complexity:**
```lua
-- High: Load keybinds with migration and validation
local function loadKeybindsWithMigration()
    local keybindPath = "lilia/keybinds.json"
    local oldPath = "lilia/old_keybinds.json"
    -- Check for old format and migrate if needed
    if file.Exists(oldPath, "DATA") and not file.Exists(keybindPath, "DATA") then
        local oldData = file.Read(oldPath, "DATA")
        if oldData then
            file.Write(keybindPath, oldData)
            file.Delete(oldPath)
        end
    end
    -- Load with error handling
    local success = pcall(function()
    lia.keybind.load()
end)
if not success then
    -- Create default keybind file
    local defaultKeybinds = {}
    for action, data in pairs(lia.keybind.stored) do
        if istable(data) and data.default then
            defaultKeybinds[action] = data.default
        end
    end
    local json = util.TableToJSON(defaultKeybinds, true)
    if json then
        file.Write(keybindPath, json)
        lia.keybind.load()
    end
end
-- Validate loaded keybinds
for action, data in pairs(lia.keybind.stored) do
    if istable(data) and data.value then
        if not KeybindKeys[data.value] and data.value ~= KEY_NONE then
            data.value = data.default or KEY_NONE
        end
    end
end
end
loadKeybindsWithMigration()

```

---

