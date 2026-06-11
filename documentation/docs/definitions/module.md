# Module Definitions

Modules are self-contained framework systems loaded through the `MODULE` table. A module can register privileges, include dependency files, add network strings, register Workshop content, and expose client-side web assets while it loads.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Primary display name for the module. The loader resolves it for bootstrap messages and uses it as the default privilege category. |
| `author` | `string` | Author metadata for the module. |
| `discord` | `string` | Contact metadata for the module author. |
| `desc` | `string` | Human-readable module description used in UI and log output. |
| `version` | `string` or `number` | Documented version number field for module metadata. |
| [`Privileges`](#privileges-field) | `table` | Admin privilege definitions registered while the module loads. |
| [`Dependencies`](#dependencies-field) | `table` | Dependency include list. Each entry can point at a file or folder plus an optional realm. |
| [`NetworkStrings`](#networkstrings-field) | `table` | Server-side list of network strings registered with `util.AddNetworkString`. |
| `WorkshopContent` | `string` or `table` | Required Workshop content IDs for the module. |
| [`WebSounds`](#web-assets-field) | `table` | Client-side map of sound IDs or paths to remote URLs registered through `lia.websound`. |
| [`WebImages`](#web-assets-field) | `table` | Client-side map of image IDs or paths to remote URLs registered through `lia.webimage`. |
| [`enabled`](#enabled-field) | `boolean` or `function` | Boolean or callback that decides whether the module should finish loading. |
| `folder` | `string` | Internal module folder path. Also used when loading dependencies and inventory types. |
| `path` | `string` | Internal copy of the module load path set during initialization. |
| `uniqueID` | `string` | Internal module identifier derived from the folder name during load. |
| `variable` | `string` | Internal global variable name for the active module context, usually `MODULE` or `SCHEMA`. |
| `loading` | `boolean` | Internal flag marking that the module is currently in its load phase. |
| `Name` | `string` | Legacy capitalized variant seen in some older modules. Current loader code reads `MODULE.name`, so this form should not be relied on. |
| `versionID` | `string` | Optional documented identifier used by some modules for version tracking. |
| `panel` | `Panel` | Runtime chatbox module reference to the active client panel instance. |
| `ActiveTickets` | `table` | Runtime tickets-module table keyed by requester SteamID for active ticket state. |
| `TicketFrames` | `table` | Runtime client-side tickets-module table of open ticket frames. |
| `adminStickCategories` | `table` | Runtime admin-stick client table containing grouped category and action data. |
| `adminStickCategoryOrder` | `table` | Runtime admin-stick client array preserving category display order. |
| [`enabled()`](#enabled-field) | `function` | Optional callback form of `enabled`. Return `true` to continue loading, or `false` plus an optional reason to stop. |
| `ModuleLoaded()` | `function` | Optional lifecycle callback invoked after load, registration, and submodule handling complete. |

## Field Notes

### <a id="dependencies-field"></a>`Dependencies`

Dependency entries can target either a single file or a folder. The loader accepts mixed entries, so you can keep a module bootstrap file small and let the dependency list describe the rest of the load order.

```lua
MODULE.Dependencies = {
    {"libraries/shared.lua", "shared"},
    {"netcalls", "server"},
    {"derma", "client"}
}
```

### <a id="privileges-field"></a>`Privileges`

Privilege tables are registered while the module loads. If a privilege entry does not provide its own category, the loader falls back to the module's resolved `name`.

```lua
MODULE.name = "Inventory"
MODULE.Privileges = {
    {
        Name = "manageInventory",
        MinAccess = "superadmin"
    }
}
```

### <a id="networkstrings-field"></a>`NetworkStrings`

`NetworkStrings` is only consumed on the server. Each value is passed to `util.AddNetworkString` during module initialization.

```lua
MODULE.NetworkStrings = {
    "liaInventoryOpen",
    "liaInventorySync"
}
```

### <a id="web-assets-field"></a>`WebSounds` and `WebImages`

These tables let a module register remote assets that Lilia will hand off to the web sound and web image systems during load.

```lua
MODULE.WebSounds = {
    ["ui/beep.wav"] = "https://example.com/audio/beep.wav"
}

MODULE.WebImages = {
    ["icons/inventory.png"] = "https://example.com/images/inventory.png"
}
```

### <a id="enabled-field"></a>`enabled`

`enabled` can be a simple boolean or a function. The callback form is useful when a module depends on configuration, mounted content, or another runtime condition.

```lua
MODULE.enabled = function()
    if not file.Exists("materials/custom/ui", "GAME") then
        return false, "Missing required UI materials"
    end

    return true
end
```

## Example

This example is shaped like a real `module.lua` file:

```lua
MODULE.name = "Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Inventory grids, storage, and related networking."
MODULE.version = "1.0.0"

MODULE.Dependencies = {
    {"libraries", "shared"},
    {"netcalls", "server"},
    {"derma", "client"}
}

MODULE.Privileges = {
    {
        Name = "manageInventory",
        MinAccess = "admin"
    }
}

MODULE.NetworkStrings = {
    "liaInventoryOpen",
    "liaInventorySync"
}

MODULE.WorkshopContent = {
    "1234567890"
}

MODULE.WebImages = {
    ["icons/inventory.png"] = "https://example.com/images/inventory.png"
}

function MODULE:ModuleLoaded()
    print(self.name .. " loaded")
end
```
