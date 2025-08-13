# Module Fields

This document describes the default `MODULE` fields provided by the Lilia framework. Use these to configure module metadata, dependencies, loading behavior, and lifecycle hooks.

Unspecified fields will use sensible defaults.

---

## Overview

A `MODULE` table defines a self-contained add-on for the Lilia framework. Each field controls how the module is identified, loaded, and interacts with permissions and workshop content.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Unknown"` | Identifies the module in logs and UI. |
| `author` | `string` | `"Anonymous"` | Name or SteamID64 of the module’s author. |
| `discord` | `string` | `""` | Discord tag or support channel. |
| `version` | `number` | `0` | Version number for compatibility checks. |
| `desc` | `string` | `"No Description"` | Short description of module functionality. |
| `CAMIPrivileges` | `table` | `nil` | CAMI privileges defined or required by the module. |
| `WorkshopContent` | `table` | `nil` | Steam Workshop add-on IDs required. |
| `enabled` | `boolean` or `function` | `true` | Controls whether the module loads. |
| `Dependencies` | `table` | `nil` | Files or directories included before the module loads. |
| `folder` | `string` | `""` | Filesystem path where the module resides. |
| `path` | `string` | `""` | Absolute path to the module’s root directory. |
| `uniqueID` | `string` | `""` | Internal identifier for the module list. Prefix with `public_` or `private_` to opt into version checks. |
| `loading` | `boolean` | `false` | True while the module is in the process of loading. |
| `ModuleLoaded` | `function` | `nil` | Callback run after module finishes loading. |

---

## Field Details

### Identification & Metadata

#### `name`

**Type:**

`string`

**Description:**

Identifies the module in logs and UI elements.

**Example Usage:**

```lua
MODULE.name = "My Module"
```

---

#### `author`

**Type:**

`string`

**Description:**

Name or SteamID64 of the module’s author.

**Example Usage:**

```lua
MODULE.author = "Samael"
```

---

#### `discord`

**Type:**

`string`

**Description:**

Discord tag or support channel for the module.

**Example Usage:**

```lua
MODULE.discord = "@liliaplayer"
```

---

#### `desc`

**Type:**

`string`

**Description:**

Detailed description of what the module provides and why it exists.

**Example Usage:**

```lua
MODULE.desc = "Adds an advanced chat system with channels and admin tools."
```

---

### Version & Compatibility

#### `version`

**Type:**

`number`

**Description:**

Version number used for compatibility checks.

**Example Usage:**

```lua
MODULE.version = 1.0
```

---

### Dependencies & Content

#### `CAMIPrivileges`

**Type:**

`table`

**Description:**

CAMI privileges required or provided by the module.

**Example Usage:**

```lua
MODULE.CAMIPrivileges = {
    { Name = "Staff Permissions - Admin Chat", MinAccess = "admin" }
}
```

---

#### `WorkshopContent`

**Type:**

`table`

**Description:**

Steam Workshop add-on IDs required by this module.

**Example Usage:**

```lua
MODULE.WorkshopContent = {
    "3527535922", -- shared assets
    "1234567890"  -- map data
}
```

---

#### `Dependencies`

**Type:**

`table`

**Description:**

List of additional files or directories to include before the module itself

loads. Paths are relative to the module's folder. Each entry may specify a

`File` or `Folder` key along with an optional `Realm` value (`server`, `client`

or `shared`) to control where the code is executed.

**Example Usage:**

```lua
MODULE.Dependencies = {
    { File = "logs.lua", Realm = "server" },
    { Folder = "libs", Realm = "shared" },
}
```

---

### Loading & Lifecycle

#### `enabled`

**Type:**

`boolean` or `function`

**Description:**

Controls whether the module loads. Can be a static boolean or a function returning a boolean.

When the function form is used, it may optionally return a second string

explaining why the module is disabled. This message is displayed through

`lia.bootstrap` when the loader skips the module.

When a module is disabled or skipped, you will see a console message in the format:

`[Lilia] [Bootstrap] [Module Disabled/Skipped] <reason>`.

**Example Usage:**

```lua
-- Enabled by default
MODULE.enabled = true

-- Or evaluate a configuration value
MODULE.enabled = function()
    return lia.config.get("EnableMyModule", true)
end

-- Provide a custom disable reason
MODULE.enabled = function()
    return false, "Disabled Temporarily"
end
```

---

#### `loading`

**Type:**

`boolean`

**Description:**

True while the module is in the process of loading.

**Example Usage:**

```lua
if MODULE.loading then return end
```

---

#### `ModuleLoaded`

**Type:**

`function`

**Description:**

Optional callback run after the module finishes loading.

**Example Usage:**

```lua
function MODULE:ModuleLoaded()
    print("Module fully initialized")
end
```

---

### Access & Visibility

#### `folder`

**Type:**

`string`

**Description:**

Relative directory of the module within the gamemode or add-on. Useful when including other files from this module.

**Example Usage:**

```lua
print(MODULE.folder)
```

---

#### `path`

**Type:**

`string`

**Description:**

Full filesystem path to the module's directory. Usually set automatically by the loader.

**Example Usage:**

```lua
print(MODULE.path)
```

---

#### `uniqueID`

**Type:**

`string`

**Description:**

Identifier used internally for the module list. Prefix with `public_` or `private_` to enable public or private version checks.

**Example Usage:**

```lua
print(MODULE.uniqueID)
```

---

### Default Folder Load Order

When loading a module from a directory, Lilia automatically scans for common sub-folders and includes them in a specific sequence. Files in these folders run on the appropriate realm, letting you simply drop code into place. The loader processes the following paths in order:

1. `languages`

2. `factions`

3. `classes`

4. `attributes`

5. `pim.lua`, `client.lua`, `server.lua`, `config.lua` and `commands.lua`

6. `config`

7. `dependencies`

8. `libs`

9. `hooks`

10. `libraries`

11. `commands`

12. `netcalls`

13. `meta`

14. `derma`

15. `pim`

16. `entities`

17. `items`

18. `submodules` (each loaded as its own module)

---

### Example `module.lua`

A complete example showing common fields in use:

```lua
-- example/gamemode/modules/public_myfeature/module.lua
MODULE.name = "My Feature"
MODULE.author = "76561198012345678"
MODULE.discord = "@example"
MODULE.version = 1.0
MODULE.desc = "Adds an example feature used to demonstrate module creation."

MODULE.enabled = true

MODULE.WorkshopContent = {
    "1234567890"
}

MODULE.CAMIPrivileges = {
    { Name = "My Feature - Use", MinAccess = "admin" }
}

MODULE.Dependencies = {
    { File = "hooks.lua", Realm = "server" },
    { Folder = "libraries", Realm = "shared" }
}

function MODULE:ModuleLoaded()
    print("My Feature loaded!")
end
```

---
