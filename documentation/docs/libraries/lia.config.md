# Configuration Library

Comprehensive user-configurable settings management system for the Lilia framework.

---

## Overview

The configuration library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.

---

### lia.config.add

**Purpose**

Adds a new configuration option to the system with specified properties and validation

**When Called**

During gamemode initialization, module loading, or when registering new config options

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add a basic boolean configuration
lia.config.add("EnableFeature", "Enable Feature", true, nil, {
desc = "Enable or disable this feature",
category = "general",
type = "Boolean"
})
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Add configuration with callback and constraints
lia.config.add("WalkSpeed", "Walk Speed", 130, function(_, newValue)
for _, client in player.Iterator() do
client:SetWalkSpeed(newValue)
end
end, {
desc = "Player walking speed",
category = "character",
type = "Int",
min = 50,
max = 300
})
```
```

**High Complexity:**
```lua
```lua
-- High: Add configuration with dynamic options and complex validation
lia.config.add("Language", "Language", "English", nil, {
desc = "Select your preferred language",
category = "general",
type = "Table",
options = function()
local languages = {}
for code, data in pairs(lia.lang.getLanguages()) do
languages[data.name] = code
end
return languages
end
})
```
```

---

### lia.createDynamicOptions

**Purpose**

Retrieves the available options for a configuration setting, supporting both static and dynamic option lists

**When Called**

When building UI elements for configuration options, particularly dropdown menus and selection lists

**Returns**

* table - Array of available options for the configuration

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get static options for a configuration
local options = lia.config.getOptions("DermaSkin")
for _, option in ipairs(options) do
print("Available skin:", option)
end
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Use options in UI creation
local combo = vgui.Create("liaComboBox")
local options = lia.config.getOptions("Language")
for _, text in pairs(options) do
combo:AddChoice(text, text)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic options with validation and filtering
local function createDynamicOptions()
local options = lia.config.getOptions("DefaultMenuTab")
local filteredOptions = {}
for key, value in pairs(options) do
if IsValid(value) and value:IsVisible() then
filteredOptions[key] = value
end
end
return filteredOptions
end
```
```

---

### lia.config.getOptions

**Purpose**

Retrieves the available options for a configuration setting, supporting both static and dynamic option lists

**When Called**

When building UI elements for configuration options, particularly dropdown menus and selection lists

**Returns**

* table - Array of available options for the configuration

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get static options for a configuration
local options = lia.config.getOptions("DermaSkin")
for _, option in ipairs(options) do
print("Available skin:", option)
end
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Use options in UI creation
local combo = vgui.Create("liaComboBox")
local options = lia.config.getOptions("Language")
for _, text in pairs(options) do
combo:AddChoice(text, text)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic options with validation and filtering
local function createDynamicOptions()
local options = lia.config.getOptions("DefaultMenuTab")
local filteredOptions = {}
for key, value in pairs(options) do
if IsValid(value) and value:IsVisible() then
filteredOptions[key] = value
end
end
return filteredOptions
end
```
```

---

### lia.updateModuleDefaults

**Purpose**

Updates the default value for an existing configuration option without changing the current value

**When Called**

During configuration updates, module reloads, or when default values need to be changed

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Update default value for a configuration
lia.config.setDefault("MaxCharacters", 10)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Update default based on server conditions
local maxChars = SERVER and 5 or 3
lia.config.setDefault("MaxCharacters", maxChars)
```
```

**High Complexity:**
```lua
```lua
-- High: Update multiple defaults based on module availability
local function updateModuleDefaults()
local defaults = {
MaxCharacters = lia.module.get("characters") and 5 or 1,
AllowPMs = lia.module.get("chatbox") and true or false,
WalkSpeed = lia.module.get("attributes") and 130 or 100
}
for key, value in pairs(defaults) do
lia.config.setDefault(key, value)
end
end
```
```

---

### lia.config.setDefault

**Purpose**

Updates the default value for an existing configuration option without changing the current value

**When Called**

During configuration updates, module reloads, or when default values need to be changed

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Update default value for a configuration
lia.config.setDefault("MaxCharacters", 10)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Update default based on server conditions
local maxChars = SERVER and 5 or 3
lia.config.setDefault("MaxCharacters", maxChars)
```
```

**High Complexity:**
```lua
```lua
-- High: Update multiple defaults based on module availability
local function updateModuleDefaults()
local defaults = {
MaxCharacters = lia.module.get("characters") and 5 or 1,
AllowPMs = lia.module.get("chatbox") and true or false,
WalkSpeed = lia.module.get("attributes") and 130 or 100
}
for key, value in pairs(defaults) do
lia.config.setDefault(key, value)
end
end
```
```

---

### lia.applyModuleConfigs

**Purpose**

Forces a configuration value to be set immediately without triggering networking or callbacks, with optional save control

**When Called**

During initialization, module loading, or when bypassing normal configuration update mechanisms

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Force set a configuration value
lia.config.forceSet("WalkSpeed", 150)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Force set without saving for temporary changes
lia.config.forceSet("DebugMode", true, true)
-- Do some debug operations
lia.config.forceSet("DebugMode", false, true)
```
```

**High Complexity:**
```lua
```lua
-- High: Bulk force set with conditional saving
local function applyModuleConfigs(moduleName, configs, saveAfter)
for key, value in pairs(configs) do
lia.config.forceSet(key, value, not saveAfter)
end
if saveAfter then
lia.config.save()
end
end
```
```

---

### lia.config.forceSet

**Purpose**

Forces a configuration value to be set immediately without triggering networking or callbacks, with optional save control

**When Called**

During initialization, module loading, or when bypassing normal configuration update mechanisms

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Force set a configuration value
lia.config.forceSet("WalkSpeed", 150)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Force set without saving for temporary changes
lia.config.forceSet("DebugMode", true, true)
-- Do some debug operations
lia.config.forceSet("DebugMode", false, true)
```
```

**High Complexity:**
```lua
```lua
-- High: Bulk force set with conditional saving
local function applyModuleConfigs(moduleName, configs, saveAfter)
for key, value in pairs(configs) do
lia.config.forceSet(key, value, not saveAfter)
end
if saveAfter then
lia.config.save()
end
end
```
```

---

### lia.setConfigWithValidation

**Purpose**

Sets a configuration value with full networking, callback execution, and automatic saving on server

**When Called**

When users change configuration values through UI, commands, or programmatic updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set a configuration value
lia.config.set("WalkSpeed", 150)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set configuration with validation
local function setConfigWithValidation(key, value, min, max)
if type(value) == "number" and value >= min and value <= max then
lia.config.set(key, value)
else
print("Invalid value for " .. key)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Batch configuration updates with rollback
local function batchConfigUpdate(updates)
local originalValues = {}
for key, value in pairs(updates) do
originalValues[key] = lia.config.get(key)
lia.config.set(key, value)
end
return function()
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
end
end
```
```

---

### lia.batchConfigUpdate

**Purpose**

Sets a configuration value with full networking, callback execution, and automatic saving on server

**When Called**

When users change configuration values through UI, commands, or programmatic updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set a configuration value
lia.config.set("WalkSpeed", 150)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set configuration with validation
local function setConfigWithValidation(key, value, min, max)
if type(value) == "number" and value >= min and value <= max then
lia.config.set(key, value)
else
print("Invalid value for " .. key)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Batch configuration updates with rollback
local function batchConfigUpdate(updates)
local originalValues = {}
for key, value in pairs(updates) do
originalValues[key] = lia.config.get(key)
lia.config.set(key, value)
end
return function()
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
end
end
```
```

---

### lia.config.set

**Purpose**

Sets a configuration value with full networking, callback execution, and automatic saving on server

**When Called**

When users change configuration values through UI, commands, or programmatic updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set a configuration value
lia.config.set("WalkSpeed", 150)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set configuration with validation
local function setConfigWithValidation(key, value, min, max)
if type(value) == "number" and value >= min and value <= max then
lia.config.set(key, value)
else
print("Invalid value for " .. key)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Batch configuration updates with rollback
local function batchConfigUpdate(updates)
local originalValues = {}
for key, value in pairs(updates) do
originalValues[key] = lia.config.get(key)
lia.config.set(key, value)
end
return function()
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
end
end
```
```

---

### lia.getConfigValue

**Purpose**

Retrieves the current value of a configuration option with fallback to default values

**When Called**

When reading configuration values for gameplay logic, UI updates, or module functionality

**Returns**

* any - The current configuration value, default value, or provided fallback

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a configuration value
local walkSpeed = lia.config.get("WalkSpeed")
player:SetWalkSpeed(walkSpeed)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Get configuration with validation and fallback
local function getConfigValue(key, expectedType, fallback)
local value = lia.config.get(key, fallback)
if type(value) == expectedType then
return value
else
return fallback
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Get multiple configurations with type checking and validation
local function getPlayerSettings()
local settings = {}
local configs = {
walkSpeed = {"WalkSpeed", "number", 130},
runSpeed = {"RunSpeed", "number", 275},
maxChars = {"MaxCharacters", "number", 5}
}
for setting, data in pairs(configs) do
local key, expectedType, fallback = data[1], data[2], data[3]
local value = lia.config.get(key, fallback)
settings[setting] = type(value) == expectedType and value or fallback
end
return settings
end
```
```

---

### lia.getPlayerSettings

**Purpose**

Retrieves the current value of a configuration option with fallback to default values

**When Called**

When reading configuration values for gameplay logic, UI updates, or module functionality

**Returns**

* any - The current configuration value, default value, or provided fallback

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a configuration value
local walkSpeed = lia.config.get("WalkSpeed")
player:SetWalkSpeed(walkSpeed)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Get configuration with validation and fallback
local function getConfigValue(key, expectedType, fallback)
local value = lia.config.get(key, fallback)
if type(value) == expectedType then
return value
else
return fallback
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Get multiple configurations with type checking and validation
local function getPlayerSettings()
local settings = {}
local configs = {
walkSpeed = {"WalkSpeed", "number", 130},
runSpeed = {"RunSpeed", "number", 275},
maxChars = {"MaxCharacters", "number", 5}
}
for setting, data in pairs(configs) do
local key, expectedType, fallback = data[1], data[2], data[3]
local value = lia.config.get(key, fallback)
settings[setting] = type(value) == expectedType and value or fallback
end
return settings
end
```
```

---

### lia.config.get

**Purpose**

Retrieves the current value of a configuration option with fallback to default values

**When Called**

When reading configuration values for gameplay logic, UI updates, or module functionality

**Returns**

* any - The current configuration value, default value, or provided fallback

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a configuration value
local walkSpeed = lia.config.get("WalkSpeed")
player:SetWalkSpeed(walkSpeed)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Get configuration with validation and fallback
local function getConfigValue(key, expectedType, fallback)
local value = lia.config.get(key, fallback)
if type(value) == expectedType then
return value
else
return fallback
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Get multiple configurations with type checking and validation
local function getPlayerSettings()
local settings = {}
local configs = {
walkSpeed = {"WalkSpeed", "number", 130},
runSpeed = {"RunSpeed", "number", 275},
maxChars = {"MaxCharacters", "number", 5}
}
for setting, data in pairs(configs) do
local key, expectedType, fallback = data[1], data[2], data[3]
local value = lia.config.get(key, fallback)
settings[setting] = type(value) == expectedType and value or fallback
end
return settings
end
```
```

---

### lia.loadConfigWithFallback

**Purpose**

Loads configuration values from the database on server or requests them from server on client

**When Called**

During gamemode initialization, after database connection, or when configuration needs to be refreshed

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load configurations during initialization
lia.config.load()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load configurations with callback
lia.config.load()
hook.Add("InitializedConfig", "MyModule", function()
print("Configurations loaded successfully")
-- Initialize module with loaded configs
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Load configurations with error handling and fallback
local function loadConfigWithFallback()
local success = pcall(lia.config.load)
if not success then
print("Failed to load configurations, using defaults")
-- Apply default configurations
for key, config in pairs(lia.config.stored) do
config.value = config.default
end
end
end
```
```

---

### lia.config.load

**Purpose**

Loads configuration values from the database on server or requests them from server on client

**When Called**

During gamemode initialization, after database connection, or when configuration needs to be refreshed

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load configurations during initialization
lia.config.load()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load configurations with callback
lia.config.load()
hook.Add("InitializedConfig", "MyModule", function()
print("Configurations loaded successfully")
-- Initialize module with loaded configs
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Load configurations with error handling and fallback
local function loadConfigWithFallback()
local success = pcall(lia.config.load)
if not success then
print("Failed to load configurations, using defaults")
-- Apply default configurations
for key, config in pairs(lia.config.stored) do
config.value = config.default
end
end
end
```
```

---

### lia.sendConfigToClient

**Purpose**

Retrieves all configuration values that differ from their default values for efficient synchronization

**When Called**

Before sending configurations to clients or when preparing configuration data for export

**Returns**

* table - Dictionary of changed configuration keys and their current values

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get all changed values
local changed = lia.config.getChangedValues()
print("Changed configurations:", table.Count(changed))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send only changed configurations to specific client
local function sendConfigToClient(client)
local changed = lia.config.getChangedValues()
if table.Count(changed) > 0 then
net.Start("liaCfgList")
net.WriteTable(changed)
net.Send(client)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Export changed configurations with filtering and validation
local function exportChangedConfigs(filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
filtered[key] = {
value = value,
name = config.name,
category = config.category,
type = config.data.type
}
end
end
return filtered
end
```
```

---

### lia.exportChangedConfigs

**Purpose**

Retrieves all configuration values that differ from their default values for efficient synchronization

**When Called**

Before sending configurations to clients or when preparing configuration data for export

**Returns**

* table - Dictionary of changed configuration keys and their current values

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get all changed values
local changed = lia.config.getChangedValues()
print("Changed configurations:", table.Count(changed))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send only changed configurations to specific client
local function sendConfigToClient(client)
local changed = lia.config.getChangedValues()
if table.Count(changed) > 0 then
net.Start("liaCfgList")
net.WriteTable(changed)
net.Send(client)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Export changed configurations with filtering and validation
local function exportChangedConfigs(filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
filtered[key] = {
value = value,
name = config.name,
category = config.category,
type = config.data.type
}
end
end
return filtered
end
```
```

---

### lia.config.getChangedValues

**Purpose**

Retrieves all configuration values that differ from their default values for efficient synchronization

**When Called**

Before sending configurations to clients or when preparing configuration data for export

**Returns**

* table - Dictionary of changed configuration keys and their current values

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get all changed values
local changed = lia.config.getChangedValues()
print("Changed configurations:", table.Count(changed))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send only changed configurations to specific client
local function sendConfigToClient(client)
local changed = lia.config.getChangedValues()
if table.Count(changed) > 0 then
net.Start("liaCfgList")
net.WriteTable(changed)
net.Send(client)
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Export changed configurations with filtering and validation
local function exportChangedConfigs(filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
filtered[key] = {
value = value,
name = config.name,
category = config.category,
type = config.data.type
}
end
end
return filtered
end
```
```

---

### lia.sendConfigsWithPriority

**Purpose**

Sends configuration data to clients with intelligent batching and rate limiting for large datasets

**When Called**

When a client connects, when configurations change, or when manually syncing configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send configurations to all clients
lia.config.send()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send configurations to specific client on connect
hook.Add("PlayerInitialSpawn", "SendConfigs", function(client)
timer.Simple(1, function()
if IsValid(client) then
lia.config.send(client)
end
end)
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Send configurations with priority and filtering
local function sendConfigsWithPriority(priority, filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
if config.data.priority == priority then
filtered[key] = value
end
end
end
if table.Count(filtered) > 0 then
net.Start("liaCfgList")
net.WriteTable(filtered)
net.Broadcast()
end
end
```
```

---

### lia.config.send

**Purpose**

Sends configuration data to clients with intelligent batching and rate limiting for large datasets

**When Called**

When a client connects, when configurations change, or when manually syncing configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send configurations to all clients
lia.config.send()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send configurations to specific client on connect
hook.Add("PlayerInitialSpawn", "SendConfigs", function(client)
timer.Simple(1, function()
if IsValid(client) then
lia.config.send(client)
end
end)
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Send configurations with priority and filtering
local function sendConfigsWithPriority(priority, filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
if config.data.priority == priority then
filtered[key] = value
end
end
end
if table.Count(filtered) > 0 then
net.Start("liaCfgList")
net.WriteTable(filtered)
net.Broadcast()
end
end
```
```

---

### lia.getTargets

**Purpose**

Sends configuration data to clients with intelligent batching and rate limiting for large datasets

**When Called**

When a client connects, when configurations change, or when manually syncing configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send configurations to all clients
lia.config.send()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send configurations to specific client on connect
hook.Add("PlayerInitialSpawn", "SendConfigs", function(client)
timer.Simple(1, function()
if IsValid(client) then
lia.config.send(client)
end
end)
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Send configurations with priority and filtering
local function sendConfigsWithPriority(priority, filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
if config.data.priority == priority then
filtered[key] = value
end
end
end
if table.Count(filtered) > 0 then
net.Start("liaCfgList")
net.WriteTable(filtered)
net.Broadcast()
end
end
```
```

---

### lia.sendTableStaggered

**Purpose**

Sends configuration data to clients with intelligent batching and rate limiting for large datasets

**When Called**

When a client connects, when configurations change, or when manually syncing configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send configurations to all clients
lia.config.send()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Send configurations to specific client on connect
hook.Add("PlayerInitialSpawn", "SendConfigs", function(client)
timer.Simple(1, function()
if IsValid(client) then
lia.config.send(client)
end
end)
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Send configurations with priority and filtering
local function sendConfigsWithPriority(priority, filterFunc)
local changed = lia.config.getChangedValues()
local filtered = {}
for key, value in pairs(changed) do
local config = lia.config.stored[key]
if config and (not filterFunc or filterFunc(key, value, config)) then
if config.data.priority == priority then
filtered[key] = value
end
end
end
if table.Count(filtered) > 0 then
net.Start("liaCfgList")
net.WriteTable(filtered)
net.Broadcast()
end
end
```
```

---

### lia.saveConfigsSafely

**Purpose**

Saves all changed configuration values to the database using transaction-based operations

**When Called**

When configuration values change, during server shutdown, or when manually saving configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Save all configurations
lia.config.save()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Save configurations with error handling
local function saveConfigsSafely()
local success, err = pcall(lia.config.save)
if not success then
print("Failed to save configurations:", err)
-- Implement fallback or retry logic
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Save configurations with backup and validation
local function saveConfigsWithBackup()
local changed = lia.config.getChangedValues()
if table.Count(changed) == 0 then return end
-- Create backup
local backup = util.TableToJSON(changed)
file.Write("config_backup_" .. os.time() .. ".json", backup)
-- Save with validation
local success, err = pcall(lia.config.save)
if not success then
print("Save failed, restoring from backup")
-- Restore from backup logic
end
end
```
```

---

### lia.saveConfigsWithBackup

**Purpose**

Saves all changed configuration values to the database using transaction-based operations

**When Called**

When configuration values change, during server shutdown, or when manually saving configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Save all configurations
lia.config.save()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Save configurations with error handling
local function saveConfigsSafely()
local success, err = pcall(lia.config.save)
if not success then
print("Failed to save configurations:", err)
-- Implement fallback or retry logic
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Save configurations with backup and validation
local function saveConfigsWithBackup()
local changed = lia.config.getChangedValues()
if table.Count(changed) == 0 then return end
-- Create backup
local backup = util.TableToJSON(changed)
file.Write("config_backup_" .. os.time() .. ".json", backup)
-- Save with validation
local success, err = pcall(lia.config.save)
if not success then
print("Save failed, restoring from backup")
-- Restore from backup logic
end
end
```
```

---

### lia.config.save

**Purpose**

Saves all changed configuration values to the database using transaction-based operations

**When Called**

When configuration values change, during server shutdown, or when manually saving configurations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Save all configurations
lia.config.save()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Save configurations with error handling
local function saveConfigsSafely()
local success, err = pcall(lia.config.save)
if not success then
print("Failed to save configurations:", err)
-- Implement fallback or retry logic
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Save configurations with backup and validation
local function saveConfigsWithBackup()
local changed = lia.config.getChangedValues()
if table.Count(changed) == 0 then return end
-- Create backup
local backup = util.TableToJSON(changed)
file.Write("config_backup_" .. os.time() .. ".json", backup)
-- Save with validation
local success, err = pcall(lia.config.save)
if not success then
print("Save failed, restoring from backup")
-- Restore from backup logic
end
end
```
```

---

### lia.resetConfigsWithConfirmation

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.resetConfigsSelectively

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.config.reset

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.getDermaSkins

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.refreshScoreboard

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.getMenuTabNames

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.buildConfiguration

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

### lia.populate

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Reset all configurations to defaults
lia.config.reset()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Reset configurations with confirmation
local function resetConfigsWithConfirmation()
print("Resetting all configurations to defaults...")
lia.config.reset()
print("Configuration reset complete")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Reset configurations with selective restoration and logging
local function resetConfigsSelectively(keepConfigs)
local originalValues = {}
-- Store current values for configs to keep
for _, key in ipairs(keepConfigs) do
originalValues[key] = lia.config.get(key)
end
-- Reset all configurations
lia.config.reset()
-- Restore selected configurations
for key, value in pairs(originalValues) do
lia.config.set(key, value)
end
print("Reset complete, restored " .. table.Count(originalValues) .. " configurations")
end
```
```

---

