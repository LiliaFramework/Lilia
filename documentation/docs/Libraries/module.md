# Modularity Library

Module loading, initialization, and lifecycle management system for the Lilia framework.

---

Overview

The modularity library provides comprehensive functionality for managing modules in the Lilia framework. It handles loading, initialization, and management of modules including schemas, preload modules, and regular modules. The library operates on both server and client sides, managing module dependencies, permissions, and lifecycle events. It includes functionality for loading modules from directories, handling module-specific data storage, and ensuring proper initialization order. The library also manages submodules, handles module validation, and provides hooks for module lifecycle events. It ensures that all modules are properly loaded and initialized before gameplay begins.

---

### lia.module.load

#### 📋 Purpose
Loads and initializes a module from a specified directory path with the given unique ID.

#### ⏰ When Called
Called during module initialization to load individual modules, their dependencies, and register them in the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier for the module. |
| `path` | **string** | The file system path to the module directory. |
| `variable` | **string, optional** | The global variable name to assign the module to (defaults to "MODULE"). |
| `skipSubmodules` | **boolean, optional** | Whether to skip loading submodules for this module. |

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load a custom module
    lia.module.load("mymodule", "gamemodes/my_schema/modules/mymodule")

```

---

### lia.module.initialize

#### 📋 Purpose
Initializes the entire module system by loading the schema, preload modules, and all available modules in the correct order.

#### ⏰ When Called
Called once during gamemode initialization to set up the module loading system and load all modules.

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Initialize the module system (called automatically by the framework)
    lia.module.initialize()

```

---

### lia.module.loadFromDir

#### 📋 Purpose
Loads all modules found in the specified directory, optionally skipping certain modules.

#### ⏰ When Called
Called during module initialization to load groups of modules from directories like preload, modules, and overrides.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | The directory path to search for modules. |
| `group` | **string** | The type of modules being loaded ("schema" or "module"). |
| `skip` | **table, optional** | A table of module IDs to skip loading. |

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load all modules from the gamemode's modules directory
    lia.module.loadFromDir("gamemodes/my_schema/modules", "module")

```

---

### lia.module.get

#### 📋 Purpose
Retrieves a loaded module by its unique identifier.

#### ⏰ When Called
Called whenever code needs to access a specific module's data or functions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | The unique identifier of the module to retrieve. |

#### ↩️ Returns
* table or nil
The module table if found, nil if the module doesn't exist.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Get a reference to the inventory module
    local inventoryModule = lia.module.get("inventory")
    if inventoryModule then
        -- Use the module
    end

```

---

