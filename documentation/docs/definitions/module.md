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
| `WorkshopContent` | `table` | `nil` | Steam Workshop add-on IDs required. |
| `enabled` | `boolean` or `function` | `true` | Controls whether the module loads. |
| `Dependencies` | `table` | `nil` | Files or directories included before the module loads. |
| `folder` | `string` | `""` | Filesystem path where the module resides. |
| `path` | `string` | `""` | Absolute path to the module’s root directory. |
| `uniqueID` | `string` | `""` | Internal identifier for the module list. Prefix with `public_` or `private_` to opt into version checks. |
| `loading` | `boolean` | `false` | True while the module is in the process of loading. |
| `ModuleLoaded` | `function` | `nil` | Callback run after module finishes loading. |
| `Privileges` | `table` | `nil` | CAMI privileges required by the module. |
| `isSingleFile` | `boolean` | `false` | True if the module is loaded from a single file. |
| `variable` | `string` | `"MODULE"` | Variable name used to access the module table. |
| `CharacterInformation` | `table` | `nil` | Custom character information fields for the F1 menu. |
| `ActiveTickets` | `table` | `nil` | Active support tickets in the ticket system. |
| `adminStickCategories` | `table` | `nil` | Categories for admin stick tools. |
| `adminStickCategoryOrder` | `table` | `nil` | Order of admin stick tool categories. |
| `panel` | `Panel` | `nil` | Reference to the module's UI panel. |
| `loadedData` | `boolean` | `false` | True when the module's data has been loaded. |
| `versionID` | `string` | `nil` | Version identifier for update checking. |
| `NetworkStrings` | `table` | `nil` | Network string identifiers used by the module. |
| `WebImages` | `table` | `nil` | Web image URLs for caching. |
| `WebSounds` | `table` | `nil` | Web sound URLs for caching. |

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

#### `Privileges`

**Type:**

`table`

**Description:**

CAMI privileges required by the module. These are automatically registered with the CAMI system when the module loads.

**Example Usage:**

```lua
MODULE.Privileges = {
    {
        Name = "Staff Permissions - Admin Chat",
        MinAccess = "admin"
    },
    {
        Name = "Moderation - Kick Players",
        MinAccess = "moderator"
    }
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

#### `isSingleFile`

**Type:**

`boolean`

**Description:**

True if the module is loaded from a single file rather than a directory structure.

**Example Usage:**

```lua
if MODULE.isSingleFile then
    -- Handle single-file module loading
end
```

---

#### `variable`

**Type:**

`string`

**Description:**

The variable name used to access the module table (usually "MODULE").

**Example Usage:**

```lua
print("Module variable:", MODULE.variable) -- Output: MODULE
```

---

#### `CharacterInformation`

**Type:**

`table`

**Description:**

Custom character information fields displayed in the F1 menu's character information panel.

**Example Usage:**

```lua
MODULE.CharacterInformation = {
    {
        name = "Health",
        data = function(client) return client:Health() end
    }
}
```

---

#### `ActiveTickets`

**Type:**

`table`

**Description:**

Active support tickets in the ticket system module, keyed by SteamID.

**Example Usage:**

```lua
local ticket = MODULE.ActiveTickets[client:SteamID()]
if ticket then
    -- Handle existing ticket
end
```

---

#### `adminStickCategories`

**Type:**

`table`

**Description:**

Categories for organizing admin stick tools, used by the admin stick module.

**Example Usage:**

```lua
MODULE.adminStickCategories = {
    playerInfo = {
        name = "Player Information",
        icon = "icon16/user.png"
    }
}
```

---

#### `adminStickCategoryOrder`

**Type:**

`table`

**Description:**

Defines the display order of admin stick tool categories.

**Example Usage:**

```lua
MODULE.adminStickCategoryOrder = {"playerInformation", "moderation", "characterManagement"}
```

---

#### `panel`

**Type:**

`Panel`

**Description:**

Reference to the module's main UI panel (e.g., chatbox panel).

**Example Usage:**

```lua
if IsValid(MODULE.panel) then
    MODULE.panel:Remove()
end
```

---

#### `loadedData`

**Type:**

`boolean`

**Description:**

Indicates whether the module's persistent data has been loaded from the database.

**Example Usage:**

```lua
if not MODULE.loadedData then return end
-- Safe to access module data
```

---

#### `versionID`

**Type:**

`string`

**Description:**

Unique version identifier for update checking. Prefix with `public_` or `private_` to enable automatic version checks.

**Example Usage:**

```lua
MODULE.versionID = "public_mymodule"
MODULE.version = 1.2
```

---

#### `NetworkStrings`

**Type:**

`table`

**Description:**

Network string identifiers used by the module for client-server communication.

**Example Usage:**

```lua
MODULE.NetworkStrings = {
    "MyModuleData",
    "MyModuleAction"
}
```

---

#### `WebImages`

**Type:**

`table`

**Description:**

URLs of web images to be cached by the framework for use in the module.

**Example Usage:**

```lua
MODULE.WebImages = {
    logo = "https://example.com/logo.png",
    icon = "https://example.com/icon.png"
}
```

---

#### `WebSounds`

**Type:**

`table`

**Description:**

URLs of web sounds to be cached by the framework for use in the module.

**Example Usage:**

```lua
MODULE.WebSounds = {
    notification = "https://example.com/sound.mp3",
    alert = "https://example.com/alert.wav"
}
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

MODULE.Privileges = {
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
