# Module Fields

This document describes the default `MODULE` fields provided by the Lilia framework. Use these to configure module metadata, dependencies, loading behavior, and lifecycle hooks.
Unspecified fields will use sensible defaults.

---
## Overview

A `MODULE` table defines a self-contained add-on for the Lilia framework. Each field controls how the module is identified, loaded, and interacts with permissions and workshop content.

---
## Field Summary

| Field                | Type                    | Description                                                      |
|----------------------|-------------------------|------------------------------------------------------------------|
| `name`               | `string`                | Identifies the module in logs and UI.                            |
| `author`             | `string`                | Name or SteamID64 of the module’s author.                        |
| `discord`            | `string`                | Discord tag or support channel.                                  |
| `version`            | `string`                | Version string for compatibility checks.                         |
| `desc`               | `string`                | Short description of module functionality.                       |
| `identifier`         | `string`                | Unique global key referencing the module.                        |
| `CAMIPrivileges`     | `table`                 | CAMI privileges defined or required by the module.               |
| `WorkshopContent`    | `table`                 | Steam Workshop add-on IDs required.                              |
| `enabled`            | `boolean` or `function` | Controls whether the module loads.                               |
| `Dependencies`       | `table`                 | Files or folders required for the module to run.                 |
| `folder`             | `string`                | Filesystem path where the module resides.                        |
| `path`               | `string`                | Absolute path to the module’s root directory.                    |
| `uniqueID`           | `string`                | Internal identifier for the module list.                         |
| `loading`            | `boolean`               | True while the module is in the process of loading.              |
| `ModuleLoaded`       | `function`              | Callback run after module finishes loading.                      |
| `Public`             | `boolean`               | Participates in public version checks.                           |
| `Private`            | `boolean`               | Uses private version checking.                                   |

---
## Field Details

### Identification & Metadata

#### `name`
**Type:** `string`  
**Description:** Identifies the module in logs and UI elements.  
**Example:**
```lua
MODULE.name = "My Module"
````

#### `author`

**Type:** `string`
**Description:** Name or SteamID64 of the module’s author.
**Example:**

```lua
MODULE.author = "Samael"
```

#### `discord`

**Type:** `string`
**Description:** Discord tag or support channel for the module.
**Example:**

```lua
MODULE.discord = "@liliaplayer"
```

#### `desc`

**Type:** `string`
**Description:** Short description of what the module provides.
**Example:**

```lua
MODULE.desc = "Adds a Chatbox"
```

#### `identifier`

**Type:** `string`
**Description:** Unique key used to reference this module globally.
**Example:**

```lua
MODULE.identifier = "example_mod"
```

---
### Version & Compatibility

#### `version`

**Type:** `string`
**Description:** Version string used for compatibility checks.
**Example:**

```lua
MODULE.version = "1.0"
```

#### `Public`

**Type:** `boolean`
**Description:** When true, the module participates in public version checks.
**Example:**

```lua
MODULE.Public = true
```

#### `Private`

**Type:** `boolean`
**Description:** When true, the module uses private version checking.
**Example:**

```lua
MODULE.Private = true
```

---
### Dependencies & Content

#### `CAMIPrivileges`

**Type:** `table`
**Description:** CAMI privileges required or provided by the module.
**Example:**

```lua
MODULE.CAMIPrivileges = {
    { Name = "Staff Permissions - Admin Chat", MinAccess = "admin" }
}
```

#### `WorkshopContent`

**Type:** `table`
**Description:** Steam Workshop add-on IDs required by this module.
**Example:**

```lua
MODULE.WorkshopContent = { "2959728255" }
```

#### `Dependencies`

**Type:** `table`
**Description:** Files or folders that this module requires to run.
**Example:**

```lua
MODULE.Dependencies = {
    { File = "logs.lua", Realm = "server" }
}
```

---
### Loading & Lifecycle

#### `enabled`

**Type:** `boolean` or `function`
**Description:** Controls whether the module loads. Can be a static boolean or a function returning a boolean.
**Example:**

```lua
MODULE.enabled = true
```

#### `loading`

**Type:** `boolean`
**Description:** True while the module is in the process of loading.
**Example:**

```lua
if MODULE.loading then return end
```

#### `ModuleLoaded`

**Type:** `function`
**Description:** Optional callback run after the module finishes loading.
**Example:**

```lua
function MODULE:ModuleLoaded()
    print("Module fully initialized")
end
```

---
### Access & Visibility

#### `folder`

**Type:** `string`
**Description:** Filesystem path where the module is located.
**Example:**

```lua
print(MODULE.folder)
```

#### `path`

**Type:** `string`
**Description:** Absolute path to the module’s root directory.
**Example:**

```lua
print(MODULE.path)
```

#### `uniqueID`

**Type:** `string`
**Description:** Identifier used internally for the module list.
**Example:**

```lua
print(MODULE.uniqueID)
```
