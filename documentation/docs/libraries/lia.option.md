# Option Library

User-configurable settings management system for the Lilia framework.

---

## Overview

The option library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.

---

### add

**Purpose**

Registers a new configurable option in the Lilia framework with automatic type detection and UI generation

**When Called**

During module initialization or when adding new user-configurable settings

**Parameters**

* `key` (*string*): Unique identifier for the option
* `name` (*string*): Display name for the option (can be localized)
* `desc` (*string*): Description text for the option (can be localized)
* `default` (*any*): Default value for the option
* `callback` (*function, optional*): Function called when option value changes (oldValue, newValue)
* `data` (*table*): Configuration data containing type, category, min/max values, etc.

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add a boolean toggle option
lia.option.add("showHUD", "Show HUD", "Toggle HUD visibility", true, nil, {
    category = "categoryGeneral",
    isQuick = true
})

```

**Medium Complexity:**
```lua
-- Medium: Add a numeric slider with callback
lia.option.add("volume", "Volume", "Master volume level", 0.8, function(oldVal, newVal)
    RunConsoleCommand("volume", tostring(newVal))
end, {
    category = "categoryAudio",
    min = 0,
    max = 1,
    decimals = 2
})

```

**High Complexity:**
```lua
-- High: Add a color picker with visibility condition and networking
lia.option.add("espColor", "ESP Color", "Color for ESP display", Color(255, 0, 0), nil, {
    category = "categoryESP",
    visible = function()
        return LocalPlayer():isStaffOnDuty()
    end,
    shouldNetwork = true,
    type = "Color"
})

```

---

### getOptions

**Purpose**

Retrieves the available options for a dropdown/selection type option, handling both static and dynamic option lists

**When Called**

When rendering dropdown options in the UI or when modules need to access option choices

**Parameters**

* `key` (*string*): The option key to get choices for

**Returns**

* table - Array of available option choices (localized strings)

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get static options for a dropdown
local options = lia.option.getOptions("weaponSelectorPosition")
-- Returns: {"Left", "Right", "Center"}

```

**Medium Complexity:**
```lua
-- Medium: Use options in UI creation
local combo = vgui.Create("liaComboBox")
local options = lia.option.getOptions("language")
for _, option in pairs(options) do
    combo:AddChoice(option, option)
end

```

**High Complexity:**
```lua
-- High: Dynamic options with validation
local options = lia.option.getOptions("teamSelection")
if #options > 0 then
    for i, option in ipairs(options) do
        if option and option ~= "" then
            teamCombo:AddChoice(option, option)
        end
    end
else
    teamCombo:AddChoice("No teams available", "")
end

```

---

### set

**Purpose**

Sets the value of an option, triggers callbacks, saves to file, and optionally networks to clients

**When Called**

When user changes an option value through UI or when programmatically updating option values

**Parameters**

* `key` (*string*): The option key to set
* `value` (*any*): The new value to set for the option

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set a boolean option
lia.option.set("showHUD", true)

```

**Medium Complexity:**
```lua
-- Medium: Set option with callback execution
lia.option.set("volume", 0.5)
-- This will trigger the callback function if one was defined

```

**High Complexity:**
```lua
-- High: Set multiple options with validation
local optionsToSet = {
    {"showHUD", true},
    {"volume", 0.8},
    {"espColor", Color(255, 0, 0)}
}
for _, optionData in ipairs(optionsToSet) do
    local key, value = optionData[1], optionData[2]
    if lia.option.stored[key] then
        lia.option.set(key, value)
    end
end

```

---

### get

**Purpose**

Retrieves the current value of an option, falling back to default value or provided fallback if not set

**When Called**

When modules need to read option values for configuration or when UI needs to display current values

**Parameters**

* `key` (*string*): The option key to retrieve
* `default` (*any, optional*): Fallback value if option doesn't exist or has no value

**Returns**

* any - The current option value, default value, or provided fallback

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a boolean option
local showHUD = lia.option.get("showHUD")
if showHUD then
    -- HUD is enabled
end

```

**Medium Complexity:**
```lua
-- Medium: Get option with fallback
local volume = lia.option.get("volume", 0.5)
RunConsoleCommand("volume", tostring(volume))

```

**High Complexity:**
```lua
-- High: Get multiple options with validation and type checking
local config = {
    showHUD = lia.option.get("showHUD", true),
    volume = lia.option.get("volume", 0.8),
    espColor = lia.option.get("espColor", Color(255, 0, 0))
}
-- Validate and apply configuration
if type(config.showHUD) == "boolean" then
    hook.Run("HUDVisibilityChanged", config.showHUD)
end
if type(config.volume) == "number" and config.volume >= 0 and config.volume <= 1 then
    RunConsoleCommand("volume", tostring(config.volume))
end

```

---

### save

**Purpose**

Saves all current option values to a JSON file for persistence across sessions

**When Called**

Automatically called when options are changed, or manually when saving configuration

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Save options after changes
lia.option.set("showHUD", true)
lia.option.save() -- Automatically called, but can be called manually

```

**Medium Complexity:**
```lua
-- Medium: Save options with error handling
local function saveOptionsSafely()
    local success, err = pcall(lia.option.save)
    if not success then
        print("Failed to save options: " .. tostring(err))
    end
end
saveOptionsSafely()

```

**High Complexity:**
```lua
-- High: Batch save with validation and backup
local function batchSaveOptions()
    -- Create backup of current options
    local backupPath = "lilia/options_backup_" .. os.time() .. ".json"
    local currentData = file.Read("lilia/options.json", "DATA")
    if currentData then
        file.Write(backupPath, currentData)
    end
    -- Save current options
    lia.option.save()
    -- Verify save was successful
    local savedData = file.Read("lilia/options.json", "DATA")
    if savedData then
        print("Options saved successfully")
    else
        print("Failed to save options")
    end
end
batchSaveOptions()

```

---

### load

**Purpose**

Loads saved option values from JSON file and initializes options with defaults if no saved data exists

**When Called**

During client initialization or when manually reloading option configuration

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load options at startup
lia.option.load()
-- This is typically called automatically during initialization

```

**Medium Complexity:**
```lua
-- Medium: Load options with error handling
local function loadOptionsSafely()
    local success, err = pcall(lia.option.load)
    if not success then
        print("Failed to load options: " .. tostring(err))
        -- Reset to defaults
        for key, option in pairs(lia.option.stored) do
            option.value = option.default
        end
    end
end
loadOptionsSafely()

```

**High Complexity:**
```lua
-- High: Load options with validation and migration
local function loadOptionsWithMigration()
    -- Check if options file exists
    if file.Exists("lilia/options.json", "DATA") then
        local data = file.Read("lilia/options.json", "DATA")
        if data then
            local saved = util.JSONToTable(data)
            if saved then
                -- Validate and migrate old option formats
                for key, value in pairs(saved) do
                    if lia.option.stored[key] then
                        local option = lia.option.stored[key]
                        -- Type validation
                        if option.type == "Boolean" and type(value) ~= "boolean" then
                            value = tobool(value)
                        elseif option.type == "Int" and type(value) ~= "number" then
                            value = tonumber(value) or option.default
                        end
                        option.value = value
                    end
                end
            end
        end
    else
        -- No saved options, use defaults
        lia.option.load()
    end
    -- Trigger initialization hook
    hook.Run("InitializedOptions")
end
loadOptionsWithMigration()

```

---

