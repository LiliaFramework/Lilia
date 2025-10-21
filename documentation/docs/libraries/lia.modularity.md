# Modularity Library

Module loading, initialization, and lifecycle management system for the Lilia framework.

---

## Overview

The modularity library provides comprehensive functionality for managing modules in the Lilia framework. It handles loading, initialization, and management of modules including schemas, preload modules, and regular modules. The library operates on both server and client sides, managing module dependencies, permissions, and lifecycle events. It includes functionality for loading modules from directories, handling module-specific data storage, and ensuring proper initialization order. The library also manages submodules, handles module validation, and provides hooks for module lifecycle events. It ensures that all modules are properly loaded and initialized before gameplay begins.

---

### lia.module.load

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load a basic module
lia.module.load("mymodule", "gamemodes/lilia/modules/mymodule", false)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load module with custom variable name
lia.module.load("custommodule", "gamemodes/lilia/modules/custom", false, "CUSTOM_MODULE")
```
```

**High Complexity:**
```lua
```lua
-- High: Load single file module with submodule skipping
lia.module.load("singlemode", "gamemodes/lilia/modules/single.lua", true, "SINGLE_MODULE", true)
```
```

---

### lia.MODULE:IsValid

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load a basic module
lia.module.load("mymodule", "gamemodes/lilia/modules/mymodule", false)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load module with custom variable name
lia.module.load("custommodule", "gamemodes/lilia/modules/custom", false, "CUSTOM_MODULE")
```
```

**High Complexity:**
```lua
```lua
-- High: Load single file module with submodule skipping
lia.module.load("singlemode", "gamemodes/lilia/modules/single.lua", true, "SINGLE_MODULE", true)
```
```

---

### lia.MODULE:setData

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load a basic module
lia.module.load("mymodule", "gamemodes/lilia/modules/mymodule", false)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load module with custom variable name
lia.module.load("custommodule", "gamemodes/lilia/modules/custom", false, "CUSTOM_MODULE")
```
```

**High Complexity:**
```lua
```lua
-- High: Load single file module with submodule skipping
lia.module.load("singlemode", "gamemodes/lilia/modules/single.lua", true, "SINGLE_MODULE", true)
```
```

---

### lia.MODULE:getData

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load a basic module
lia.module.load("mymodule", "gamemodes/lilia/modules/mymodule", false)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load module with custom variable name
lia.module.load("custommodule", "gamemodes/lilia/modules/custom", false, "CUSTOM_MODULE")
```
```

**High Complexity:**
```lua
```lua
-- High: Load single file module with submodule skipping
lia.module.load("singlemode", "gamemodes/lilia/modules/single.lua", true, "SINGLE_MODULE", true)
```
```

---

### lia.module.initialize

**Purpose**

Initializes the entire module system, loading schemas, preload modules, and regular modules in proper order

**When Called**

Called during gamemode initialization to set up the complete module ecosystem

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Initialize modules (typically called automatically)
lia.module.initialize()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Initialize with custom schema path
local schemaPath = "gamemodes/mygamemode"
lia.module.load("schema", schemaPath .. "/schema", false, "schema")
lia.module.initialize()
```
```

**High Complexity:**
```lua
```lua
-- High: Initialize with custom module loading order
lia.module.initialize()
-- Custom post-initialization logic
for id, mod in pairs(lia.module.list) do
if mod.PostInitialize then
mod:PostInitialize()
end
end
```
```

---

### lia.module.loadFromDir

**Purpose**

Loads all modules from a specified directory

**When Called**

Called during module initialization to load multiple modules from a directory, or when manually loading modules from a specific folder

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load all modules from a directory
lia.module.loadFromDir("gamemodes/lilia/modules", "module")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load modules with specific group type
lia.module.loadFromDir("gamemodes/mygamemode/modules", "module")
```
```

**High Complexity:**
```lua
```lua
-- High: Load modules with skip list
local skipModules = {["disabledmodule"] = true, ["testmodule"] = true}
lia.module.loadFromDir("gamemodes/lilia/modules", "module", skipModules)
```
```

---

### lia.module.get

**Purpose**

Retrieves a loaded module by its unique identifier

**When Called**

Called when you need to access a specific module's data or functions, or to check if a module is loaded

**Returns**

* Module table or nil if not found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a module
local myModule = lia.module.get("mymodule")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Check if module exists and use it
local module = lia.module.get("inventory")
if module and module.GetItem then
local item = module:GetItem("weapon_pistol")
end
```
```

**High Complexity:**
```lua
```lua
-- High: Iterate through all modules and perform operations
for id, module in pairs(lia.module.list) do
local mod = lia.module.get(id)
if mod and mod.OnPlayerSpawn then
mod:OnPlayerSpawn(player)
end
end
```
```

---

