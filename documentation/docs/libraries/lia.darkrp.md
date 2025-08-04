# DarkRP Compatibility

This page describes helpers for integrating with DarkRP.

---

## Overview

The `darkrp` library bridges functionality with the DarkRP gamemode. It mirrors several DarkRP helpers so third-party addons expecting the `DarkRP` globals continue to function. The functions documented here are also assigned to the global `DarkRP` table. A simplified `RPExtraTeams` table is created as well, mapping each faction to its team index for compatibility.

---

### lia.darkrp.isEmpty

**Purpose**

Checks whether a position is free of world geometry, players, NPCs, and props within a 35-unit sphere.

**Parameters**

* `position` (*Vector*): World position to test.

* `entitiesToIgnore` (*table*): Entities ignored during the check. *Optional*.

**Realm**

`Server`

**Returns**

* *boolean*: `true` if the position is clear, `false` otherwise.

**Example Usage**

```lua
local ply = Entity(1)
if lia.darkrp.isEmpty(ply:GetPos(), { ply }) then
    print("Spawn point is clear")
end
```

---

### lia.darkrp.findEmptyPos

**Purpose**

Searches around a start position for a spot free of world geometry and blocking entities.

**Parameters**

* `startPos` (*Vector*): Initial position to search from.

* `entitiesToIgnore` (*table*): Entities ignored during the search. *Optional*.

* `maxDistance` (*number*): Maximum distance to search in units.

* `searchStep` (*number*): Step increment when expanding the search radius.

* `checkArea` (*Vector*): Additional height offset tested for clearance.

**Realm**

`Server`

**Returns**

* *Vector*: A position considered safe for spawning.

**Example Usage**

```lua
local spawn = lia.darkrp.findEmptyPos(ply:GetPos(), { ply }, 128, 16, Vector(0, 0, 64))
```

---

### lia.darkrp.notify

**Purpose**

Sends a notification to the specified client. The second and third parameters mirror the DarkRP API but are ignored by this implementation.

**Parameters**

* `client` (*Player*): Player to receive the message.

* `type` (*number*): DarkRP notification type. *Ignored.*

* `length` (*number*): Display time in seconds. *Ignored.*

* `message` (*string*): Text of the notification.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.darkrp.notify(ply, nil, nil, "Purchase complete")
```

---

### lia.darkrp.textWrap

**Purpose**

Client-side helper that wraps a string so it fits within a given pixel width using the provided font.

**Parameters**

* `text` (*string*): Text to wrap.

* `fontName` (*string*): Font used to measure width.

* `maxLineWidth` (*number*): Maximum pixel width before wrapping occurs.

**Realm**

`Client`

**Returns**

* *string*: The wrapped text with newline characters inserted.

**Example Usage**

```lua
local wrapped = lia.darkrp.textWrap("Some very long text", "DermaDefault", 150)
chat.AddText(wrapped)
```

---

### lia.darkrp.formatMoney

**Purpose**

Formats the given amount using `lia.currency.get` so other DarkRP addons receive familiar strings.

**Parameters**

* `amount` (*number*): Value of money to format.

**Realm**

`Shared`

**Returns**

* *string*: The formatted currency value.

**Example Usage**

```lua
print(lia.darkrp.formatMoney(2500))
```

---

### lia.darkrp.createEntity

**Purpose**

Registers a new DarkRP entity as an item so that it can be spawned through lia's item system.

**Parameters**

* `name` (*string*): Display name of the entity.

* `data` (*table*): Table containing fields such as `model`, `desc`, `category`, `ent`, `price`, and optional `cmd`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.darkrp.createEntity("Fuel", {
    model = "models/props_c17/oildrum001.mdl",
    ent = "prop_physics",
    price = 50
})
```

---

### lia.darkrp.createCategory

**Purpose**

Stub for DarkRP category creation. Included only for compatibility.

**Parameters**

*None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.darkrp.createCategory()
```

---
