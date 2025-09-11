# Modularity Library

This page documents the functions for working with modules and modularity.

---

## Overview

The modularity library (`lia.module`) provides a comprehensive system for managing modules, module loading, and module initialization in the Lilia framework, serving as the core architecture for the framework's extensible and modular design. This library handles sophisticated module management with support for dynamic module loading, dependency resolution, and automatic initialization sequences that ensure proper module startup order and inter-module communication. The system features advanced module loading with support for hot-reloading during development, lazy loading for performance optimization, and conditional loading based on server configuration or player requirements. It includes comprehensive module registration with validation systems, version checking, and compatibility verification to ensure stable module integration and prevent conflicts. The library provides robust module management functionality with lifecycle hooks, state tracking, and error handling to maintain system stability even when individual modules fail or are removed. Additional features include module discovery and auto-registration, dependency graph visualization for debugging, and integration with the framework's configuration system for flexible module management, making it essential for creating maintainable and extensible server configurations that can adapt to different needs and scale with growing communities.

---

### lia.module.load

**Purpose**

Loads a module from a file.

**Parameters**

* `modulePath` (*string*): The path to the module file.

**Returns**

* `success` (*boolean*): True if the module was loaded successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Load a module
local function loadModule(modulePath)
    return lia.module.load(modulePath)
end

-- Use in a function
local function loadPlayerModule()
    local success = lia.module.load("gamemode/modules/player.lua")
    if success then
        print("Player module loaded")
    else
        print("Failed to load player module")
    end
    return success
end

-- Use in a function
local function loadInventoryModule()
    local success = lia.module.load("gamemode/modules/inventory.lua")
    if success then
        print("Inventory module loaded")
    else
        print("Failed to load inventory module")
    end
    return success
end
```

---

### lia.module.initialize

**Purpose**

Initializes a module.

**Parameters**

* `moduleName` (*string*): The name of the module to initialize.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Initialize a module
local function initializeModule(moduleName)
    lia.module.initialize(moduleName)
end

-- Use in a function
local function initializePlayerModule()
    lia.module.initialize("player")
    print("Player module initialized")
end

-- Use in a function
local function initializeInventoryModule()
    lia.module.initialize("inventory")
    print("Inventory module initialized")
end
```

---

### lia.module.loadFromDir

**Purpose**

Loads all modules from a directory.

**Parameters**

* `directory` (*string*): The directory path to load from.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load modules from directory
local function loadModules(directory)
    lia.module.loadFromDir(directory)
end

-- Use in a function
local function loadAllModules()
    lia.module.loadFromDir("gamemode/modules/")
    print("All modules loaded from directory")
end

-- Use in a function
local function reloadModules()
    lia.module.loadFromDir("gamemode/modules/")
    print("Modules reloaded")
end
```

---

### lia.module.get

**Purpose**

Gets a module by name.

**Parameters**

* `moduleName` (*string*): The module name.

**Returns**

* `module` (*table*): The module data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a module
local function getModule(moduleName)
    return lia.module.get(moduleName)
end

-- Use in a function
local function checkModuleExists(moduleName)
    local module = lia.module.get(moduleName)
    if module then
        print("Module exists: " .. moduleName)
        return true
    else
        print("Module not found: " .. moduleName)
        return false
    end
end
```

---

### lia.module.printDisabledModules

**Purpose**

Prints all disabled modules.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Print disabled modules
local function printDisabledModules()
    lia.module.printDisabledModules()
end

-- Use in a function
local function showDisabledModules()
    lia.module.printDisabledModules()
end
```