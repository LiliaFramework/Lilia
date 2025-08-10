# DarkRP Compatibility

This page describes helpers for integrating with DarkRP.

---

## Overview

The `darkrp` library bridges functionality with the DarkRP gamemode. It mirrors several DarkRP helpers so third-party addons expecting the `DarkRP` globals continue to function. The functions documented here are also assigned to the global `DarkRP` table. A simplified `RPExtraTeams` table is created as well, mapping each faction to its team index for compatibility.

---

### lia.darkrp.isEmpty

**Purpose**

Checks whether a position is free of solid contents, players, NPCs, props, and entities flagged with `NotEmptyPos` within a 35-unit sphere.

**Parameters**

* `position` (*Vector*): World position to test.

* `entitiesToIgnore` (*table*): Entities ignored during the check. Defaults to an empty table.

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

Searches around a start position for a spot free of world geometry and blocking entities. Both the starting position and the position offset by `checkArea` must be clear. The search steps outward along the positive and negative X, Y, and Z axes.

**Parameters**

* `startPos` (*Vector*): Initial position to search from.

* `entitiesToIgnore` (*table*): Entities ignored during the search. *Optional*.

* `maxDistance` (*number*): Maximum distance to search in units.

* `searchStep` (*number*): Step increment when expanding the search radius.

* `checkArea` (*Vector*): Additional height offset tested for clearance.

**Realm**

`Server`

**Returns**

* *Vector*: A safe position. Returns the original `startPos` if none found within `maxDistance`.

**Example Usage**

```lua
local spawn = lia.darkrp.findEmptyPos(ply:GetPos(), { ply }, 128, 16, Vector(0, 0, 64))
```

---

### lia.darkrp.notify

**Purpose**

Sends a localized notification to the specified client. The second and third parameters mirror the DarkRP API but are ignored by this implementation.

**Parameters**

* `client` (*Player*): Player to receive the message.

* `type` (*number*): DarkRP notification type. *Ignored.*

* `length` (*number*): Display time in seconds. *Ignored.*

* `message` (*string*): Localization key or message text to send.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.darkrp.notify(ply, nil, nil, "jobChanged")
```

---

### lia.darkrp.textWrap

**Purpose**

Client-side helper that wraps a string so it fits within a given pixel width using the provided font. Long words are wrapped character-by-character if necessary. Existing newline or tab characters reset the line width calculation.

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

Formats the given amount using `lia.currency.get` so other DarkRP addons receive familiar currency strings.

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

* `data` (*table*): Table of fields:
  * `cmd` (*string*): Console command used for spawning. Defaults to `name` in lowercase.
  * `model` (*string*): Model path. Defaults to `""`.
  * `desc` (*string*): Description of the entity. Defaults to `""`.
  * `category` (*string*): Item category. Defaults to `L("entities")`.
  * `ent` (*string*): Entity class to spawn. Defaults to `""`.
  * `price` (*number*): Cost of the entity. Defaults to `0`.

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

### Map KeyValue Compatibility

**Purpose**

Processes select DarkRP-specific key-values on door entities so maps configured for DarkRP behave as expected.

**Handled KeyValues**

* `DarkRPNonOwnable`: marks the door as unsellable by setting the `noSell` network variable.
* `DarkRPTitle`: sets the door's display name.
* `DarkRPCanLockpick`: when set to a truthy value, prevents lockpicking by setting the `noPick` flag.

**Realm**

`Server`

**Returns**

* *nil*: This hook runs automatically and does not return a value.

**Example Usage**

Add the key-values below to a door entity in Hammer:

```text
"DarkRPTitle" "Police Armory"
"DarkRPNonOwnable" "1"
```

---
