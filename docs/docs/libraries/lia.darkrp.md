# DarkRP Compatibility

This page describes helpers for integrating with DarkRP.

---

## Overview

The darkrp library bridges functionality with the DarkRP gamemode. It mirrors
several DarkRP helpers so third-party addons expecting the `DarkRP` globals
continue to function. The functions documented here are also assigned to the
global `DarkRP` table. A simplified `RPExtraTeams` table is created as well,
mapping each faction to its team index for compatibility.

---

### lia.darkrp.isEmpty

**Description:**

Checks whether the position is free from world geometry, players, NPCs and props. A 35 unit sphere around the position is checked to ensure spawn areas are unobstructed.

**Parameters:**

* `position` (`Vector`) – World position to test.


* `entitiesToIgnore` (`table, optional`) – Entities ignored during the check.


**Realm:**

* Server


**Returns:**

* boolean – True if the position is clear, false otherwise.


**Example Usage:**

```lua
    local ply = Entity(1) -- example player
    if lia.darkrp.isEmpty(ply:GetPos(), {ply}) then
        print("Spawn point is clear")
    end
```

---

### lia.darkrp.findEmptyPos

**Description:**

Searches around the given start position for a spot free of world geometry and blocking entities.

**Parameters:**

* `startPos` (`Vector`) – The initial position to search from.


* `entitiesToIgnore` (`table, optional`) – Entities ignored during the search.


* `maxDistance` (`number`) – Maximum distance to search in units.


* `searchStep` (`number`) – Step increment when expanding the search radius.


* `checkArea` (`Vector`) – Additional height offset tested for clearance.


**Realm:**

* Server


**Returns:**

* Vector – A position considered safe for spawning.


**Example Usage:**

```lua
    local spawn = lia.darkrp.findEmptyPos(ply:GetPos(), {ply}, 128, 16, Vector(0,0,64))
```

---

### lia.darkrp.notify

**Description:**

Sends a notification to the specified client. The second and third parameters exist only for DarkRP compatibility and are ignored.

**Parameters:**

* `client` (`Player`) – The player to receive the message.


* `message` (`string`) – Text of the notification.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    lia.darkrp.notify(ply, nil, nil, "Purchase complete")
```

---

### lia.darkrp.textWrap

**Description:**

Clientside helper that wraps a string so it fits within a given pixel width using the provided font.

**Parameters:**

* `text` (`string`) – The text to wrap.


* `fontName` (`string`) – The font used to measure width.


* `maxLineWidth` (`number`) – Maximum pixel width before wrapping occurs.


**Realm:**

* Client


**Returns:**

* string – The wrapped text with newline characters inserted.


**Example Usage:**

```lua
    local wrapped = lia.darkrp.textWrap("Some very long text", "DermaDefault", 150)
    chat.AddText(wrapped)
```

---

### lia.darkrp.formatMoney

**Description:**

Formats the given amount using lia.currency.get so other DarkRP addons receive familiar strings.

**Parameters:**

* `amount` (`number`) – The value of money to format.


**Realm:**

* Shared


**Returns:**

* string – The formatted currency value.


**Example Usage:**

```lua
    print(lia.darkrp.formatMoney(2500))
```

---

### lia.darkrp.createEntity

**Description:**

Registers a new DarkRP entity as an item so that it can be spawned

through lia's item system.

**Parameters:**

* `name` (`string`) – Display name of the entity.
* `data` (`table`) – Table containing fields such as `model`, `desc`, `category`, `ent`, `price` and optional `cmd`.

**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    lia.darkrp.createEntity("Fuel", {
        model = "models/props_c17/oildrum001.mdl",
        ent = "prop_physics",
        price = 50
    })
```

---

### lia.darkrp.createCategory

**Description:**

Stub for DarkRP category creation. Included only for compatibility.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.darkrp.createCategory
    lia.darkrp.createCategory()
```
