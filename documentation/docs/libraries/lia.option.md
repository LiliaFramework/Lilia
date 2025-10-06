# Option Library

This page documents the functions for working with client-side options and settings.

---

## Overview

The option library (`lia.option`) provides a comprehensive system for managing client-side options, settings, and preferences in the Lilia framework, enabling personalized user experiences and customizable interface configurations. This library handles sophisticated option management with support for various option types including sliders, toggles, dropdowns, and custom input fields, with validation systems and constraint checking to ensure valid user input. The system features advanced option registration with support for default values, option categories, and dependency relationships that create logical option groupings and conditional visibility. It includes comprehensive saving and loading functionality with cloud synchronization, profile management, and automatic backup systems to preserve user preferences across sessions and devices. The library provides robust option management with real-time updates, change notifications, and integration with the framework's UI system for seamless option modification and immediate effect application. Additional features include option migration tools for framework updates, accessibility support for different input methods, and performance optimization for large option sets, making it essential for creating user-friendly interfaces that adapt to individual player preferences and enhance overall user experience and comfort.

---

### add

**Purpose**

Adds a new client-side option to the options system.

**Parameters**

* `key` (*string*): The unique identifier for the option.
* `name` (*string*): The display name for the option.
* `desc` (*string*): The description of the option.
* `default` (*any*): The default value for the option.
* `callback` (*function*, optional): Function called when the option value changes.
* `data` (*table*): Additional option configuration data.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a client option
local function addOption(key, name, desc, default, callback, data)
    lia.option.add(key, name, desc, default, callback, data)
end

-- Use in a function
local function createVolumeOption()
    lia.option.add("volume", "Volume", "Audio volume level", 1.0, nil, {
        category = "Audio",
        min = 0.0,
        max = 1.0,
        type = "Float"
    })
    print("Volume option created")
end

-- Use in a function
local function createLanguageOption()
    lia.option.add("language", "Language", "Interface language", "en", nil, {
        category = "Interface",
        type = "Table",
        options = {"en", "es", "fr"}
    })
    print("Language option created")
end

-- Use in a function
local function createESPEnabledOption()
    lia.option.add("espEnabled", "ESP Enabled", "Enable ESP display", false, function(old, new)
        print("ESP toggled from " .. tostring(old) .. " to " .. tostring(new))
    end, {
        category = "ESP",
        type = "Boolean",
        visible = function()
            return LocalPlayer():isStaffOnDuty()
        end
    })
    print("ESP option created")
end
```

---

### getOptions

**Purpose**

Gets the available options for a specific option key, typically used for dropdown/combo box options.

**Parameters**

* `key` (*string*): The option key to get options for.

**Returns**

* `options` (*table*): Table of available options for the specified key.

**Realm**

Shared.

**Example Usage**

```lua
-- Get options for a specific option
local function getOptionsForKey(key)
    return lia.option.getOptions(key)
end

-- Use in a function
local function getLanguageOptions()
    local options = lia.option.getOptions("language")
    print("Available languages:")
    for _, option in ipairs(options) do
        print("- " .. option)
    end
    return options
end

-- Use in a function
local function getWeaponSelectorPositions()
    local options = lia.option.getOptions("weaponSelectorPosition")
    print("Available positions:")
    for _, option in ipairs(options) do
        print("- " .. option)
    end
    return options
end
```

---

### set

**Purpose**

Sets an option value and triggers any associated callbacks and hooks.

**Parameters**

* `key` (*string*): The option key to set.
* `value` (*any*): The new value for the option.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set option value
local function setOption(key, value)
    lia.option.set(key, value)
end

-- Use in a function
local function setVolume(volume)
    lia.option.set("volume", volume)
    print("Volume set to " .. volume)
end

-- Use in a function
local function setLanguage(language)
    lia.option.set("language", language)
    print("Language set to " .. language)
end

-- Use in a function
local function toggleESP()
    local current = lia.option.get("espEnabled", false)
    lia.option.set("espEnabled", not current)
    print("ESP toggled to " .. tostring(not current))
end
```

---

### get

**Purpose**

Gets an option value, returning the current value, default value, or provided default.

**Parameters**

* `key` (*string*): The option key to get.
* `default` (*any*, optional): Default value to return if option doesn't exist.

**Returns**

* `value` (*any*): The current option value, default value, or provided default.

**Realm**

Shared.

**Example Usage**

```lua
-- Get option value
local function getOption(key, default)
    return lia.option.get(key, default)
end

-- Use in a function
local function getVolume()
    local volume = lia.option.get("volume", 1.0)
    print("Current volume: " .. volume)
    return volume
end

-- Use in a function
local function getLanguage()
    local language = lia.option.get("language", "en")
    print("Current language: " .. language)
    return language
end

-- Use in a function
local function getESPEnabled()
    local espEnabled = lia.option.get("espEnabled", false)
    print("ESP enabled: " .. tostring(espEnabled))
    return espEnabled
end
```

---

### save

**Purpose**

Saves all current option values to the options.json file for persistence across sessions.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Save all options
local function saveAllOptions()
    lia.option.save()
    print("All options saved")
end

-- Use in a function
local function saveOptionsOnExit()
    lia.option.save()
    print("Options saved before exit")
end

-- Use in a function
local function saveOptionsAfterChanges()
    lia.option.save()
    print("Options saved after configuration changes")
end
```

---

### load

**Purpose**

Loads option values from the options.json file and applies them to the current session.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Load all options
local function loadAllOptions()
    lia.option.load()
    print("All options loaded")
end

-- Use in a function
local function loadOptionsOnStart()
    lia.option.load()
    print("Options loaded on game start")
end

-- Use in a function
local function restoreOptions()
    lia.option.load()
    print("Options restored from previous session")
end
```