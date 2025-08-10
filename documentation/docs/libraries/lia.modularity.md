
# Modularity Library

This page explains the module-loading system.

---

## Overview

The modularity library loads modules contained in the **`modules`** folder, resolves dependencies, and initialises both server-side and client-side components. During the process it fires the `DoModuleIncludes`, `InitializedSchema`, and `InitializedModules` hooks. See [Module Fields](../definitions/module.md) for the callbacks and options a module may define. Loaded modules are stored in `lia.module.list`, indexed by their unique identifier.

Modules placed in a schema's `preload` directory are loaded **before** any framework modules. When a module with the same identifier exists in both `preload` and `lilia/gamemode/modules`, the version inside `preload` takes priority and the framework copy is skipped. If a schema overrides a framework module outside of `preload`, the loader prints a notice suggesting the module be moved to `preload` for improved efficiency.

---

### lia.module.load

**Purpose**

Loads a module at a given path, setting up its environment and processing permissions, dependencies, extras, and optional sub-modules. Existing hooks are removed when reloading a module. If the core file is missing or the module reports itself as disabled, the loader prints a message and aborts.

**Parameters**

* `uniqueID` (*string*): Identifier for the module.

* `path` (*string*): Filesystem path of the module.

* `isSingleFile` (*boolean?*): Set to `true` to load a single-file module (default `false`).

* `variable` (*string?*): Temporary global table name (default `"MODULE"`; `"SCHEMA"` when `uniqueID` is `"schema"`).

* `skipSubmodules` (*boolean?*): When `true`, sub-modules inside a `submodules` folder are not loaded (default `false`).

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Watch the include process
hook.Add("DoModuleIncludes", "DebugInclude", function(path, module)
    print("Including files from " .. path .. " for " .. module.uniqueID)
end)

-- Load a folder module and skip its sub-modules
lia.module.load("example", "lilia/gamemode/modules/example", false, nil, true)
```

---

### lia.module.initialize

**Purpose**

Loads the active schema and every discovered module, then fires initialisation hooks. Modules in the `preload` directory are loaded before core and schema modules. Overrides trigger a suggestion to move them into `preload` for efficiency. After loading, modules that report `enabled = false` are removed from `lia.module.list`.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("InitializedModules", "SetupExampleData", function()
    print("Modules finished loading.")
end)

lia.module.initialize()
```

---

### lia.module.loadFromDir

**Purpose**

Finds and loads every module folder located in a directory.

**Parameters**

* `directory` (*string*): Path containing module folders.

* `group` (*string?*): Group identifier such as `"schema"` or `"module"` (default `"module"`). Determines the temporary global name (`SCHEMA` or `MODULE`).

* `skip` (*table?*): Set of module identifiers to skip while loading.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Manually load all core modules except those in the skip table
lia.module.loadFromDir("lilia/gamemode/modules", "module", {test = true})
```

---

### lia.module.get

**Purpose**

Fetches a previously loaded module by its identifier.

**Parameters**

* `identifier` (*string*): Module unique ID.

**Realm**

`Shared`

**Returns**

* *table | nil*: Module table if present, otherwise `nil`.

**Example Usage**

```lua
local main = lia.module.get("mainmenu")

if main then
    print("Loaded module:", main.name)
end
```


