# Modularity Library

This page explains the module loading system.

---

## Overview

The modularity library loads modules contained in the `modules` folder. It resolves dependencies and initializes both serverside and clientside components. It fires the `DoModuleIncludes`, `InitializedSchema` and `InitializedModules` hooks during the loading process.

See [Module Fields](../definitions/module.md) for the options and callbacks a module file may define.

---

### lia.module.load

**Description:**

Loads a module from the given path. If the target is a single file it is included directly.

When loading a folder, the core file is executed and CAMI privileges, dependencies and additional resources such as languages and factions are loaded. Submodules are processed unless `skipSubmodules` is true.

All functions placed on `MODULE` are registered as hooks. During the extra include phase the `DoModuleIncludes` hook is fired and, when complete, `MODULE.ModuleLoaded` runs if defined. The module table also gains `setData` and `getData` helpers for persistent storage. Enabled modules are stored in `lia.module.list`.

**Parameters:**

* uniqueID – The unique identifier of the module.


* path – The file system path where the module is located.


* isSingleFile – Boolean indicating if the module is a single file.


* variable – Optional global variable name used to temporarily store the module. Defaults to `"MODULE"`.

* skipSubmodules – When true, do not search for and load submodules. Defaults to `false`.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- Hook to see when extras are included
hook.Add("DoModuleIncludes", "DebugInclude", function(path, module)
    print("Including files from " .. path .. " for " .. module.uniqueID)
end)

-- Load a folder module and skip submodules
lia.module.load("example", "lilia/modules/example", false, nil, true)
```

---

### lia.module.initialize

**Description:**

Initializes the module system by loading the schema and each configured module directory. After the schema finishes loading the `InitializedSchema` hook is triggered. Modules from the base folders and the schema are then processed, followed by the `InitializedModules` hook. Items from `schema/items/` load last so that all modules are already available.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- Wait for all modules before executing setup code
hook.Add("InitializedModules", "SetupExampleData", function()
    print("Modules finished loading.")
end)

lia.module.initialize()
```

---

### lia.module.loadFromDir

**Description:**

Loads modules from a specified directory. It iterates over all subfolders and .lua files in the directory.

Each subfolder is treated as a multi-file module, and each .lua file as a single-file module.

Non-Lua files are ignored.

**Parameters:**

* directory – The directory path from which to load modules.


* group – A string representing the module group (e.g., "schema" or "module").

  This controls whether the module is loaded into `SCHEMA` or `MODULE`.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- Load every module in the core directory (normally done by lia.module.initialize)
lia.module.loadFromDir("lilia/modules/core", "module")
```

---

### lia.module.get

**Description:**

Retrieves a module table by its identifier.

**Parameters:**

* identifier – The unique identifier of the module to retrieve.


**Realm:**

* Shared


**Returns:**

* The module table if found, or nil if the module is not registered.


**Example Usage:**

```lua
-- Retrieve the main menu module and print its display name
local main = lia.module.get("mainmenu")
if main then
    print("Loaded module:", main.name)
end
```
