# Config Library

This page documents the functions for working with configuration and settings.

---

## Overview

The config library (`lia.config`) provides a comprehensive system for managing server configurations, settings, and options in the Lilia framework. It includes configuration registration, value management, networking, and persistence functionality.

---

### lia.config.add

**Purpose**

Adds a new configuration option to the config system.

**Parameters**

* `key` (*string*): The configuration key.
* `data` (*table*): The configuration data table containing type, default, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a basic configuration option
lia.config.add("ServerName", {
    type = "string",
    default = "My Server",
    category = "General"
})

-- Add a configuration with more options
lia.config.add("MaxPlayers", {
    type = "number",
    default = 32,
    min = 1,
    max = 128,
    category = "Server",
    onChanged = function(oldValue, newValue)
        print("Max players changed from " .. oldValue .. " to " .. newValue)
    end
})

-- Add a boolean configuration
lia.config.add("EnablePVP", {
    type = "boolean",
    default = true,
    category = "Gameplay"
})

-- Add a color configuration
lia.config.add("ThemeColor", {
    type = "color",
    default = Color(255, 0, 0),
    category = "UI"
})
```

---

### lia.config.getOptions

**Purpose**

Gets all configuration options.

**Parameters**

*None*

**Returns**

* `options` (*table*): Table of all configuration options.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all configuration options
local function getAllOptions()
    return lia.config.getOptions()
end

-- Use in a function
local function showAllOptions()
    local options = lia.config.getOptions()
    for key, data in pairs(options) do
        print("Option: " .. key .. " = " .. tostring(data.default))
    end
end

-- Use in a configuration menu
local function createConfigMenu()
    local options = lia.config.getOptions()
    local menu = vgui.Create("DFrame")
    
    for key, data in pairs(options) do
        local label = vgui.Create("DLabel", menu)
        label:SetText(key .. ": " .. tostring(data.default))
    end
    
    return menu
end
```

---

### lia.config.setDefault

**Purpose**

Sets the default value for a configuration option.

**Parameters**

* `key` (*string*): The configuration key.
* `value` (*any*): The default value to set.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set default value for a configuration
lia.config.setDefault("ServerName", "My New Server")

-- Set default value for multiple configurations
local function setDefaults()
    lia.config.setDefault("MaxPlayers", 64)
    lia.config.setDefault("EnablePVP", false)
    lia.config.setDefault("ThemeColor", Color(0, 255, 0))
end

-- Use in a function
local function resetToDefaults()
    local options = lia.config.getOptions()
    for key, data in pairs(options) do
        lia.config.setDefault(key, data.default)
    end
end
```

---

### lia.config.forceSet

**Purpose**

Forces a configuration value to be set without triggering callbacks.

**Parameters**

* `key` (*string*): The configuration key.
* `value` (*any*): The value to set.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Force set a configuration value
lia.config.forceSet("ServerName", "Forced Server Name")

-- Force set multiple values
local function forceSetMultiple()
    lia.config.forceSet("MaxPlayers", 100)
    lia.config.forceSet("EnablePVP", true)
end

-- Use in a function
local function updateConfigSilently(key, value)
    lia.config.forceSet(key, value)
    print("Configuration updated silently: " .. key)
end
```

---

### lia.config.set

**Purpose**

Sets a configuration value and triggers callbacks.

**Parameters**

* `key` (*string*): The configuration key.
* `value` (*any*): The value to set.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set a configuration value
lia.config.set("ServerName", "New Server Name")

-- Set multiple values
local function updateConfigs()
    lia.config.set("MaxPlayers", 64)
    lia.config.set("EnablePVP", true)
    lia.config.set("ThemeColor", Color(255, 0, 0))
end

-- Use in a command
lia.command.add("setconfig", {
    arguments = {
        {name = "key", type = "string"},
        {name = "value", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.config.set(arguments[1], arguments[2])
        client:notify("Configuration updated: " .. arguments[1])
    end
})
```

---

### lia.config.get

**Purpose**

Gets a configuration value.

**Parameters**

* `key` (*string*): The configuration key.

**Returns**

* `value` (*any*): The configuration value.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a configuration value
local serverName = lia.config.get("ServerName")
print("Server name:", serverName)

-- Get multiple values
local function getServerInfo()
    local name = lia.config.get("ServerName")
    local maxPlayers = lia.config.get("MaxPlayers")
    local pvp = lia.config.get("EnablePVP")
    
    return {
        name = name,
        maxPlayers = maxPlayers,
        pvp = pvp
    }
end

-- Use in a function
local function checkConfig(key)
    local value = lia.config.get(key)
    if value then
        print("Configuration " .. key .. " = " .. tostring(value))
    else
        print("Configuration " .. key .. " not found")
    end
end
```

---

### lia.config.load

**Purpose**

Loads configuration from the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load configuration on server start
local function initializeConfig()
    lia.config.load()
    print("Configuration loaded from database")
end

-- Use in a hook
hook.Add("Initialize", "LoadConfig", function()
    lia.config.load()
end)

-- Use in a function
local function reloadConfig()
    lia.config.load()
    print("Configuration reloaded")
end
```

---

### lia.config.getChangedValues

**Purpose**

Gets all configuration values that have been changed from their defaults.

**Parameters**

*None*

**Returns**

* `changedValues` (*table*): Table of changed configuration values.

**Realm**

Server.

**Example Usage**

```lua
-- Get changed configuration values
local function getChangedConfigs()
    return lia.config.getChangedValues()
end

-- Use in a function
local function showChangedConfigs()
    local changed = lia.config.getChangedValues()
    for key, value in pairs(changed) do
        print("Changed: " .. key .. " = " .. tostring(value))
    end
end

-- Use in a command
lia.command.add("showchanged", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local changed = lia.config.getChangedValues()
        for key, value in pairs(changed) do
            client:notify(key .. " = " .. tostring(value))
        end
    end
})
```

---

### lia.config.send

**Purpose**

Sends configuration to a client.

**Parameters**

* `client` (*Player*): The client to send configuration to.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send configuration to a client
local function sendConfigToClient(client)
    lia.config.send(client)
end

-- Use in a hook
hook.Add("PlayerInitialSpawn", "SendConfig", function(client)
    lia.config.send(client)
end)

-- Use in a function
local function updateClientConfig(client)
    lia.config.send(client)
    client:notify("Configuration updated")
end
```

---

### lia.config.save

**Purpose**

Saves configuration to the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save configuration to database
local function saveConfig()
    lia.config.save()
    print("Configuration saved to database")
end

-- Use in a timer
timer.Create("SaveConfig", 300, 0, function()
    lia.config.save()
end)

-- Use in a command
lia.command.add("saveconfig", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.config.save()
        client:notify("Configuration saved")
    end
})
```

---

### lia.config.reset

**Purpose**

Resets a configuration value to its default.

**Parameters**

* `key` (*string*): The configuration key to reset.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Reset a configuration to default
lia.config.reset("ServerName")

-- Reset multiple configurations
local function resetMultiple()
    lia.config.reset("MaxPlayers")
    lia.config.reset("EnablePVP")
    lia.config.reset("ThemeColor")
end

-- Use in a command
lia.command.add("resetconfig", {
    arguments = {
        {name = "key", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.config.reset(arguments[1])
        client:notify("Configuration reset: " .. arguments[1])
    end
})
```

---

### lia.config.resetAll

**Purpose**

Resets all configuration values to their defaults.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Reset all configurations to defaults
local function resetAllConfigs()
    lia.config.resetAll()
    print("All configurations reset to defaults")
end

-- Use in a command
lia.command.add("resetallconfigs", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.config.resetAll()
        client:notify("All configurations reset")
    end
})

-- Use in a function
local function factoryReset()
    lia.config.resetAll()
    print("Factory reset completed")
end
```

---

### lia.config.getCategory

**Purpose**

Gets all configuration options in a specific category.

**Parameters**

* `category` (*string*): The category name.

**Returns**

* `options` (*table*): Table of configuration options in the category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get configuration options in a category
local function getCategoryOptions(category)
    return lia.config.getCategory(category)
end

-- Use in a function
local function showCategoryOptions(category)
    local options = lia.config.getCategory(category)
    for key, data in pairs(options) do
        print("Category " .. category .. ": " .. key .. " = " .. tostring(data.default))
    end
end

-- Use in a menu
local function createCategoryMenu(category)
    local options = lia.config.getCategory(category)
    local menu = vgui.Create("DFrame")
    
    for key, data in pairs(options) do
        local label = vgui.Create("DLabel", menu)
        label:SetText(key .. ": " .. tostring(data.default))
    end
    
    return menu
end
```

---

### lia.config.addCategory

**Purpose**

Adds a new configuration category.

**Parameters**

* `name` (*string*): The category name.
* `data` (*table*): The category data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a new configuration category
lia.config.addCategory("UI", {
    name = "User Interface",
    description = "UI-related settings"
})

-- Add multiple categories
local function addCategories()
    lia.config.addCategory("Gameplay", {
        name = "Gameplay Settings",
        description = "Gameplay-related settings"
    })
    
    lia.config.addCategory("Server", {
        name = "Server Settings",
        description = "Server-related settings"
    })
end

-- Use in a function
local function createCustomCategory(name, displayName, description)
    lia.config.addCategory(name, {
        name = displayName,
        description = description
    })
end
```