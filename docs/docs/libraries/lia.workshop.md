# Workshop Library

This page documents Workshop addon helpers.

---

## Overview

The workshop library tracks required Workshop addon IDs and mounts them on clients. It helps ensure that players have the assets needed for the gamemode. When the `AutoDownloadWorkshop` configuration is enabled, connecting players automatically receive the cached list of IDs so missing content can be downloaded.

`lia.workshop.send` is automatically called 10 seconds after each player's initial spawn when this configuration is on.

### Fields

* **lia.workshop.ids** (table) – IDs registered through `lia.workshop.AddWorkshop`.

* **lia.workshop.known** (table) – IDs that have previously been added and announced.

* **lia.workshop.cache** (table) – Cached list of IDs built after the `InitializedModules` hook.

* **resource.AddWorkshop** (function) – Alias of `lia.workshop.AddWorkshop` for compatibility.

---

### lia.workshop.AddWorkshop

**Purpose**

Registers a Steam Workshop addon ID so clients will download it.

**Parameters**

* `id` (*string|number*): Workshop item ID to add.

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
lia.workshop.AddWorkshop("1234567890")
-- Add a custom model pack from the Workshop
```

---

### lia.workshop.gather

**Purpose**

Collects Workshop IDs from all registered sources.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* `table`: Table of workshop IDs to download.

**Example**

```lua
local ids = lia.workshop.gather()
for id in pairs(ids) do
    print("Needs addon:", id)
end
```

---

### lia.workshop.send

**Purpose**

Sends the cached list of Workshop IDs to a player.

**Parameters**

* `ply` (*Player*): Target player.

**Realm**

`Server`

**Returns**

* `nil`: Nothing.

**Example**

```lua
hook.Add("PlayerInitialSpawn", "SendWorkshopList", function(ply)
    lia.workshop.send(ply)
end)
```

### Console Commands

`workshop_force_redownload` – clears the local queue and downloads all Workshop items again. Useful if a client

needs to re-fetch content that may have been corrupted.

