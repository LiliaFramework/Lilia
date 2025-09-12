# Option Library

This page documents the functions for working with client-side options and settings.

---

## Overview

The option library (`lia.option`) provides a comprehensive system for managing client-side options, settings, and preferences in the Lilia framework, enabling personalized user experiences and customizable interface configurations. This library handles sophisticated option management with support for various option types including sliders, toggles, dropdowns, and custom input fields, with validation systems and constraint checking to ensure valid user input. The system features advanced option registration with support for default values, option categories, and dependency relationships that create logical option groupings and conditional visibility. It includes comprehensive saving and loading functionality with cloud synchronization, profile management, and automatic backup systems to preserve user preferences across sessions and devices. The library provides robust option management with real-time updates, change notifications, and integration with the framework's UI system for seamless option modification and immediate effect application. Additional features include option migration tools for framework updates, accessibility support for different input methods, and performance optimization for large option sets, making it essential for creating user-friendly interfaces that adapt to individual player preferences and enhance overall user experience and comfort.

---

### add

**Purpose**

Adds a new client-side option.

**Parameters**

* `optionData` (*table*): The option data table containing name, type, default, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a client option
local function addOption(optionData)
    lia.option.add(optionData)
end

-- Use in a function
local function createVolumeOption()
    lia.option.add({
        name = "Volume",
        type = "slider",
        default = 1.0,
        min = 0.0,
        max = 1.0,
        category = "Audio"
    })
    print("Volume option created")
end

-- Use in a function
local function createLanguageOption()
    lia.option.add({
        name = "Language",
        type = "combo",
        default = "en",
        options = {"en", "es", "fr"},
        category = "Interface"
    })
    print("Language option created")
end
```

---

### getOptions

**Purpose**

Gets all client options.

**Parameters**

*None*

**Returns**

* `options` (*table*): Table of all options.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all options
local function getAllOptions()
    return lia.option.getOptions()
end

-- Use in a function
local function showAllOptions()
    local options = lia.option.getOptions()
    print("Available options:")
    for _, option in ipairs(options) do
        print("- " .. option.name)
    end
end
```

---

### set

**Purpose**

Sets an option value for a client.

**Parameters**

* `client` (*Player*): The client to set the option for.
* `optionName` (*string*): The option name.
* `value` (*any*): The option value.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set option for client
local function setOption(client, optionName, value)
    lia.option.set(client, optionName, value)
end

-- Use in a function
local function setVolume(client, volume)
    lia.option.set(client, "Volume", volume)
    print("Volume set for " .. client:Name())
end
```

---

### get

**Purpose**

Gets an option value for a client.

**Parameters**

* `client` (*Player*): The client to get the option for.
* `optionName` (*string*): The option name.

**Returns**

* `value` (*any*): The option value.

**Realm**

Shared.

**Example Usage**

```lua
-- Get option for client
local function getOption(client, optionName)
    return lia.option.get(client, optionName)
end

-- Use in a function
local function getVolume(client)
    local volume = lia.option.get(client, "Volume")
    print("Volume for " .. client:Name() .. ": " .. volume)
    return volume
end
```

---

### save

**Purpose**

Saves options for a client.

**Parameters**

* `client` (*Player*): The client to save options for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save options for client
local function saveOptions(client)
    lia.option.save(client)
end

-- Use in a function
local function savePlayerOptions(client)
    lia.option.save(client)
    print("Options saved for " .. client:Name())
end
```

---

### load

**Purpose**

Loads options for a client.

**Parameters**

* `client` (*Player*): The client to load options for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load options for client
local function loadOptions(client)
    lia.option.load(client)
end

-- Use in a function
local function loadPlayerOptions(client)
    lia.option.load(client)
    print("Options loaded for " .. client:Name())
end
```