
# Modularity Library (lia.module)

This page explains the module-loading system that powers Lilia's modular architecture.

---

## Overview

The `lia.module` library is the core system responsible for loading, managing, and initializing modules within the Lilia framework. It provides a robust module loading system that handles dependencies, permissions, submodules, and automatic file inclusion. The library maintains a registry of all loaded modules in `lia.module.list` and ensures proper initialization order.

**Key Features:**
- **Automatic Module Discovery**: Scans directories for module folders and loads them automatically
- **Dependency Management**: Handles module dependencies and includes required files
- **Permission System**: Automatically registers module privileges with the admin system
- **Submodule Support**: Recursively loads submodules from `submodules/` folders
- **File Organization**: Automatically includes various module components (commands, hooks, libraries, etc.)
- **Schema Integration**: Special handling for schema modules and preload directories
- **Selective Hotreload**: Only reloads edited modules during development, preserving performance

---

## Hotreload Behavior

The module system implements an optimized hotreload mechanism that distinguishes between core framework components and modules:

### What Gets Reloaded Always

**Core Framework Components** are always loaded during hotreload, regardless of whether they've been modified:
- Core libraries (`gamemode/core/libraries/`)
- Global hooks (`gamemode/core/hooks/`)
- Meta tables (`gamemode/core/meta/`)
- Derma components (`gamemode/core/derma/`)
- Entities (`gamemode/entities/`)
- Schema configuration and items
- All shared/client/server realm files

### What Gets Reloaded Selectively

**Modules** are only reloaded if their files have been modified since the last load:
- Individual modules in `modules/` folders
- Schema modules in `schema/modules/`
- Preload modules in `schema/preload/`
- Module-specific items, hooks, libraries, and other components

### Hotreload Flow

```
Hotreload Triggered
        ↓
   Load Core Framework (Always)
        ↓
  Check Module Timestamps
        ↓
Reload Only Edited Modules
        ↓
  Fire Initialization Hooks
```

This approach ensures fast development iteration by avoiding unnecessary reloading of unchanged modules while maintaining consistency of core framework components.

---

## Core Functions

### lia.module.load

**Purpose**

Loads a module from a specified path, setting up its environment and processing all associated components. This function handles the complete module lifecycle including file inclusion, permission registration, dependency resolution, and hook setup.

**Parameters**

* `uniqueID` (*string*): Unique identifier for the module (e.g., "mainmenu", "inventory")
* `path` (*string*): Filesystem path to the module directory
* `isSingleFile` (*boolean?*): Set to `true` for single-file modules (default `false`)
* `variable` (*string?*): Global variable name for the module (default `"MODULE"`, `"SCHEMA"` for schema)
* `skipSubmodules` (*boolean?*): Skip loading submodules when `true` (default `false`)

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**What It Does**

1. **Environment Setup**: Creates a global `MODULE` table with basic properties
2. **File Loading**: Includes the core module file (e.g., `module.lua`)
3. **Permission Registration**: Automatically registers any defined privileges
4. **Dependency Resolution**: Loads required dependencies and extra files
5. **Hook Integration**: Converts module functions into hooks automatically
6. **Submodule Loading**: Recursively loads submodules unless skipped
7. **Module Registration**: Adds the module to `lia.module.list` for later access

**Example Usage**

```lua
-- Load a standard module
lia.module.load("example", "lilia/gamemode/modules/example")

-- Load a single-file module
lia.module.load("simple", "path/to/simple.lua", true)

-- Load module without submodules
lia.module.load("example", "path/to/example", false, nil, true)
```

---

### lia.module.initialize

**Purpose**

Initializes the complete module system by loading the schema, preload modules, core framework modules, and schema-specific modules in the correct order. This is the main entry point for the module system.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**What It Does**

1. **Schema Loading**: Loads the active schema module first
2. **Preload Processing**: Loads modules from the `preload/` directory before framework modules
3. **Framework Modules**: Loads core Lilia modules from `lilia/gamemode/modules/`
4. **Schema Modules**: Loads schema-specific modules from `schema/modules/`
5. **Override Handling**: Loads any module overrides from `schema/overrides/`
6. **Cleanup**: Removes disabled modules from the registry
7. **Hook Execution**: Fires `InitializedSchema` and `InitializedModules` hooks

**Loading Order**

1. Schema (`schema/schema.lua`)
2. Preload modules (`schema/preload/*`)
3. Core framework modules (`lilia/gamemode/modules/*`)
4. Schema modules (`schema/modules/*`)
5. Schema overrides (`schema/overrides/*`)

**Example Usage**

```lua
-- Initialize the entire module system
lia.module.initialize()

-- Hook into the initialization process
hook.Add("InitializedModules", "MySetup", function()
    print("All modules have been loaded!")
end)
```

---

### lia.module.loadFromDir

**Purpose**

Scans a directory for module folders and loads each one automatically. This function is used internally by the initialization system but can also be called manually for custom module loading.

**Parameters**

* `directory` (*string*): Path to scan for module folders
* `group` (*string?*): Module group type - `"schema"` or `"module"` (default `"module"`)
* `skip` (*table?*): Table of module IDs to skip during loading

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**What It Does**

1. **Directory Scanning**: Uses `file.Find` to discover module folders
2. **Module Loading**: Calls `lia.module.load` for each discovered module
3. **Skip Logic**: Respects the skip table to avoid loading specific modules
4. **Variable Naming**: Sets appropriate global variable names based on group

**Example Usage**

```lua
-- Load all modules from a custom directory
lia.module.loadFromDir("custom/modules", "module")

-- Load schema modules with specific exclusions
lia.module.loadFromDir("schema/modules", "module", {test = true, debug = true})
```

---

### lia.module.reloadEdited

**Purpose**

Reloads modules that have been edited since they were last loaded, skipping unchanged modules. This function is called automatically during hotreload operations and only affects modules, not core framework components.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**What It Does**

1. **Selective Module Reloading**: Only reloads modules whose files have been modified since last load
2. **Schema Handling**: Checks and reloads the schema if it has been edited
3. **Timestamp Tracking**: Updates cached modification times for reloaded modules
4. **Hook Execution**: Fires `InitializedSchema` and `InitializedModules` hooks when necessary
5. **Item Reloading**: Reloads schema items to apply changes

**Important Notes**

- **Module-Only Operation**: This function only reloads modules. Core framework components (libraries, hooks, entities, etc.) are always loaded regardless of file modification status
- **Hotreload Behavior**: When hotreloading the gamemode, everything except modules is loaded, and only the specific edited module is refreshed
- **Performance Optimized**: Skips reloading unchanged modules to improve hotreload performance

**Example Usage**

```lua
-- Reload only modules whose files have changed
lia.module.reloadEdited()
```

**Hotreload Flow**

```
Hotreload Triggered → Load Core Framework → Check Module Timestamps → Reload Only Edited Modules
                      ↓                           ↓                          ↓
              Always loaded:            Only modules with            Only affected modules
              - Libraries              newer timestamps             get refreshed
              - Hooks                  get checked                  - Schema (if edited)
              - Entities                                      - Specific modules
              - Meta tables                                    - Module items
              - Derma components
```

---

### lia.module.get

**Purpose**

Retrieves a loaded module by its unique identifier from the module registry.

**Parameters**

* `identifier` (*string*): The unique ID of the module to retrieve

**Realm**

`Shared`

**Returns**

* *table | nil*: The module table if found, otherwise `nil`

**What It Does**

Provides access to the module registry (`lia.module.list`) to retrieve loaded modules by their ID. This is useful for accessing module functions, data, or checking if a module is loaded.

**Example Usage**

```lua
-- Get a specific module
local mainMenu = lia.module.get("mainmenu")

if mainMenu then
    print("Main menu module loaded:", mainMenu.name)
    -- Access module functions
    if mainMenu.createCharacter then
        mainMenu:createCharacter()
    end
end

-- Check if a module exists
if lia.module.get("inventory") then
    print("Inventory system is available")
end
```

---

## Module Structure

When a module is loaded, the system automatically includes various files and folders:

### Automatic File Inclusion

The system automatically includes these files if they exist:
- `pim.lua` → Server realm
- `config.lua` → Shared realm  
- `commands.lua` → Shared realm
- `networking.lua` → Server realm

### Automatic Folder Inclusion

These folders are automatically included if they exist:
- `config/` - Configuration files
- `dependencies/` - Module dependencies
- `libs/` - Library files
- `hooks/` - Hook definitions
- `libraries/` - Module-specific libraries
- `commands/` - Command definitions
- `netcalls/` - Network calls
- `meta/` - Meta tables
- `derma/` - UI components

### Special Handling

- **Languages**: Automatically loads from `languages/` folder
- **Factions**: Automatically loads from `factions/` folder
- **Classes**: Automatically loads from `classes/` folder
- **Attributes**: Automatically loads from `attributes/` folder
- **Entities**: Automatically loads from `entities/` folder
- **Items**: Automatically loads from `items/` folder (except for schema)

---

## Module Properties

Each loaded module automatically receives these properties and methods:

### Core Properties

- `uniqueID` - The module's unique identifier
- `name` - Human-readable module name
- `desc` - Module description
- `author` - Module author
- `enabled` - Whether the module is enabled
- `folder` - Path to the module directory
- `path` - Full module path
- `loading` - Loading state flag

### Built-in Methods

- `IsValid()` - Returns true for valid modules
- `setData(value, global, ignoreMap)` - Store module data
- `getData(default)` - Retrieve module data
- `ModuleLoaded()` - Called after module initialization (if defined)

---

## Hooks and Events

The module system fires several hooks during operation:

- **`DoModuleIncludes`** - Fired when including module files
- **`InitializedSchema`** - Fired after schema initialization
- **`InitializedModules`** - Fired after all modules are loaded

---

## Best Practices

1. **Use Preload for Overrides**: Place schema-specific module overrides in `preload/` for better performance
2. **Check Module Availability**: Always check if a module exists before using it
3. **Follow Naming Conventions**: Use descriptive unique IDs and follow the standard module structure
4. **Handle Dependencies**: Properly declare module dependencies in the module table
5. **Use Hooks**: Hook into module events rather than directly calling module functions

---

## Example Module Structure

```
modules/example/
├── module.lua          # Core module file
├── config.lua          # Configuration
├── commands.lua        # Commands
├── libraries/          # Module libraries
├── hooks/              # Hook definitions
├── derma/              # UI components
├── submodules/         # Sub-modules
│   └── feature/
└── items/              # Module items
```


