# Workshop Library

This page documents Workshop-addon helpers.

---

## Overview

The workshop library tracks required Workshop addon IDs and mounts them on clients to ensure players have the assets needed for the gamemode. When the **`AutoDownloadWorkshop`** configuration is enabled, connecting players automatically receive the cached list of IDs so missing content can be downloaded.

Workshop IDs added via `lia.workshop.AddWorkshop` are stored in `lia.workshop.ids`. After all modules are initialised, `lia.workshop.cache` holds the combined set that clients will download. For convenience, `resource.AddWorkshop` is aliased to `lia.workshop.AddWorkshop`.

Clients store the list received from the server in `lia.workshop.serverIds`, which drives the in-game display and download queue.

The server sends this list a short time after each player spawns. When the client opts to download the addons—either automatically or via the prompt—it requests them and `lia.workshop.send` transmits the IDs. Clients may run `workshop_force_redownload` in the console to forcibly re-download all configured addons.

---

### lia.workshop.AddWorkshop

**Purpose**

Registers a Steam Workshop addon ID so clients will download it.

**Parameters**

* `id` (*string | number*): Workshop item ID.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Add a custom model pack
lia.workshop.AddWorkshop("1234567890")
```

---

### lia.workshop.gather

**Purpose**

Collects Workshop IDs from every registered source.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *table*: Set of Workshop IDs pending download.

**Example Usage**

```lua
local ids = lia.workshop.gather()
for id in pairs(ids) do
    print("Needs addon:", id)
end
```

---

### lia.workshop.send

**Purpose**

Sends the cached Workshop-ID list to a player.

**Parameters**

* `ply` (*Player*): Target player.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("PlayerInitialSpawn", "SendWorkshopList", function(ply)
    lia.workshop.send(ply)
end)
```

---

### lia.workshop.checkPrompt

**Purpose**

Displays the Workshop download prompt or automatically requests the addons based on the client's `autoDownloadWorkshop` option.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("InitializedOptions", "WorkshopCheck", function()
    lia.workshop.checkPrompt()
end)
```

---
