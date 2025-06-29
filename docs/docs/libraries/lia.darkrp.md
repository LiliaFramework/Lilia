# DarkRP Compatibility

This page describes helpers for integrating with DarkRP.

---

## Overview

The darkrp library bridges functionality with the DarkRP gamemode. It offers helper checks and wrappers to maintain compatibility when running Lilia alongside DarkRP.

---

### lia.darkrp.isEmpty(position, entitiesToIgnore)

    
**Description:**
Checks whether the specified position is free from players, NPCs,
and props.
**Parameters:**
* position (Vector) – World position to test.
* entitiesToIgnore (table) – Entities ignored during the check.
**Realm:**
* Server
**Returns:**
* boolean – True if the position is clear, false otherwise.
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.isEmpty
if lia.darkrp.isEmpty(Vector(0,0,0)) then
print("Spawn point is clear")
end
```

### lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)

    
**Description:**
Finds a nearby position that is unobstructed by players or props.
**Parameters:**
* startPos (Vector) – The initial position to search from.
* entitiesToIgnore (table) – Entities ignored during the search.
* maxDistance (number) – Maximum distance to search in units.
* searchStep (number) – Step increment when expanding the search radius.
* checkArea (Vector) – Additional offset tested for clearance.
**Realm:**
* Server
**Returns:**
* Vector – A position considered safe for spawning.
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.findEmptyPos
local pos = lia.darkrp.findEmptyPos(Vector(0,0,0), nil, 128, 16, Vector(0,0,32))
```

### lia.darkrp.notify(client, _, _, message)

    
**Description:**
Forwards a notification message to the given client using
lia's notify system.
**Parameters:**
* client (Player) – The player to receive the message.
* message (string) – Text of the notification.
**Realm:**
* Server
**Returns:**
* nil
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.notify
lia.darkrp.notify(player.GetAll()[1], nil, nil, "Hello!")
```

### lia.darkrp.textWrap(text, fontName, maxLineWidth)

    
**Description:**
Wraps a text string so that it fits within the specified width
when drawn with the given font.
**Parameters:**
* text (string) – The text to wrap.
* fontName (string) – The font used to measure width.
* maxLineWidth (number) – Maximum pixel width before wrapping occurs.
**Realm:**
* Client
**Returns:**
* string – The wrapped text with newline characters inserted.
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.textWrap
local wrapped = lia.darkrp.textWrap("Some very long text", "DermaDefault", 150)
```

### lia.darkrp.formatMoney(amount)

    
**Description:**
Converts a numeric amount to a formatted currency string.
**Parameters:**
* amount (number) – The value of money to format.
**Realm:**
* Shared
**Returns:**
* string – The formatted currency value.
**Example:**
```lua
-- This snippet demonstrates a common usage of print
print(lia.darkrp.formatMoney(2500))
```

### lia.darkrp.createEntity(name, data)

    
**Description:**
Registers a new DarkRP entity as an item so that it can be spawned
through lia's item system.
**Parameters:**
* name (string) – Display name of the entity.
* data (table) – Table containing entity definition fields such as
* model, description, and price.
**Realm:**
* Shared
**Returns:**
* nil
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.createEntity
lia.darkrp.createEntity("Fuel", {model = "models/props_c17/oildrum001.mdl", price = 50})
```

### lia.darkrp.createCategory()

    
**Description:**
Placeholder for DarkRP category creation. Currently unused.
**Parameters:**
* None
**Realm:**
* Shared
**Returns:**
* nil
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.darkrp.createCategory
lia.darkrp.createCategory()
```
