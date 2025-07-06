# Modularity Library

This page explains the module loading system.

---

## Overview

The modularity library loads modules contained in the `modules` folder. It resolves dependencies and initializes both serverside and clientside components. It fires the `DoModuleIncludes`, `InitializedSchema` and `InitializedModules` hooks during the loading process.

See [Module Fields](../definitions/module.md) for the options and callbacks a module file may define.

---

### lia.module.load

**Purpose**

Loads a module from the given path and processes any dependencies, permissions
or submodules associated with it.

**Parameters**

* `uniqueID` (*string*): Identifier for the module.
* `path` (*string*): Location of the module on disk.
* `isSingleFile` (*boolean*): Set to `true` to load a single file module.
* `variable` (*string*): Temporary global table name. Defaults to `"MODULE"`.
* `skipSubmodules` (*boolean*): Prevent loading submodules when `true`.

**Realm**

`Shared`

**Returns**

* `nil`

**Example**

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

**Purpose**

Loads the schema and all modules, firing initialization hooks when done.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `nil`

**Example**

```lua
-- Wait for all modules before executing setup code
hook.Add("InitializedModules", "SetupExampleData", function()
    print("Modules finished loading.")
end)

lia.module.initialize()
```

---

### lia.module.loadFromDir

**Purpose**

Searches a directory for modules and loads each one it finds.

**Parameters**

* `directory` (*string*): Path containing module folders and files.
* `group` (*string*): Module group such as `"schema"` or `"module"`.

**Realm**

`Shared`

**Returns**

* `nil`

**Example**

```lua
-- Load every module in the core directory (normally done by lia.module.initialize)
lia.module.loadFromDir("lilia/modules/core", "module")
```

---

### lia.module.get

**Purpose**

Fetches a loaded module by its identifier.

**Parameters**

* `identifier` (*string*): Unique identifier of the module.

**Realm**

`Shared`

**Returns**

* `table|nil`: The module table if present.

**Example**

```lua
-- Retrieve the main menu module and print its display name
local main = lia.module.get("mainmenu")
if main then
    print("Loaded module:", main.name)
end
```

---

