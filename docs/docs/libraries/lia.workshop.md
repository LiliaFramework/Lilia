# Workshop Library

This page documents Workshop addon helpers.

---

## Overview

The workshop library tracks required Workshop addon IDs and mounts them on clients. It helps ensure that players have the assets needed for the gamemode.

---

### lia.workshop.gather()

    
**Description:**
Collects workshop IDs from installed addons and registered modules.
**Realm:**
* Server
**Returns:**
* ids (table) – Table of workshop IDs to download.
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.workshop.gather
local ids = lia.workshop.gather()
```

### lia.workshop.send(ply)

    
**Description:**
Sends the collected workshop IDs to a connecting player.
**Parameters:**
* ply (Player) – Player to send the download list to.
**Realm:**
* Server
**Returns:**
* None
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.workshop.send
lia.workshop.send(ply)
```
