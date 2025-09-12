# DarkRP Library

This page documents the functions for working with DarkRP compatibility and integration.

---

## Overview

The `lia.darkrp` library provides comprehensive DarkRP compatibility functions for the Lilia framework, ensuring seamless integration with existing DarkRP addons and maintaining backward compatibility. This library serves as a bridge between the Lilia framework and DarkRP's established ecosystem, offering utilities for position validation, text processing, currency formatting, and entity management. The system handles various compatibility concerns including coordinate system conversions, text wrapping algorithms, money display formatting, and entity spawning mechanics that match DarkRP's behavior patterns. These functions are essential for developers migrating from DarkRP to Lilia or maintaining compatibility with DarkRP-based addons, providing a stable foundation for cross-framework development and ensuring consistent user experience across different roleplay server environments.

---

### isEmpty

**Purpose**

Checks if a position is empty and suitable for spawning entities.

**Parameters**

* `position` (*Vector*): The position to check.
* `entitiesToIgnore` (*table*): Optional table of entities to ignore during the check.

**Returns**

* `isEmpty` (*boolean*): True if the position is empty, false otherwise.

**Realm**

Server.

**Example Usage**
```lua
-- Check if a position is empty
local pos = Vector(0, 0, 0)
if lia.darkrp.isEmpty(pos) then
    print("Position is empty")
else
    print("Position is occupied")
end

-- Check with entities to ignore
local ignoreList = {someEntity}
if lia.darkrp.isEmpty(pos, ignoreList) then
    print("Position is empty (ignoring specified entities)")
end
```

---

### findEmptyPos

**Purpose**

Finds an empty position near a starting position by searching in expanding circles.

**Parameters**

* `startPos` (*Vector*): The starting position to search from.
* `entitiesToIgnore` (*table*): Optional table of entities to ignore.
* `maxDistance` (*number*): Maximum distance to search.
* `searchStep` (*number*): Step size for the search.
* `checkArea` (*Vector*): Area to check around each position.

**Returns**

* `emptyPosition` (*Vector*): The first empty position found, or the original position if none found.

**Realm**

Server.

**Example Usage**
```lua
-- Find an empty position near a spawn point
local startPos = Vector(0, 0, 0)
local emptyPos = lia.darkrp.findEmptyPos(startPos, {}, 100, 10, Vector(32, 32, 64))
print("Empty position found at:", emptyPos)
```

---

### notify

**Purpose**

Sends a notification to a client using Lilia's notification system.

**Parameters**

* `client` (*Player*): The client to notify.
* `_` (*any*): Unused parameter (for DarkRP compatibility).
* `_` (*any*): Unused parameter (for DarkRP compatibility).
* `message` (*string*): The message to send.

**Returns**

*None*

**Realm**

Server.

**Example Usage**
```lua
-- Send a notification to a player
lia.darkrp.notify(player.GetByID(1), nil, nil, "Hello, player!")
```

---

### textWrap

**Purpose**

Wraps text to fit within a specified maximum line width.

**Parameters**

* `text` (*string*): The text to wrap.
* `fontName` (*string*): The font to use for measuring text width.
* `maxLineWidth` (*number*): The maximum width for each line.

**Returns**

* `wrappedText` (*string*): The wrapped text with line breaks.

**Realm**

Client.

**Example Usage**
```lua
-- Wrap text to fit in a chat box
local longText = "This is a very long text that needs to be wrapped to fit within the specified width."
local wrappedText = lia.darkrp.textWrap(longText, "DermaDefault", 200)
print(wrappedText)
```

---

### formatMoney

**Purpose**

Formats a money amount using Lilia's currency system.

**Parameters**

* `amount` (*number*): The amount to format.

**Returns**

* `formattedMoney` (*string*): The formatted money string.

**Realm**

Shared.

**Example Usage**
```lua
-- Format money for display
local amount = 1500
local formatted = lia.darkrp.formatMoney(amount)
print("You have " .. formatted)
```

---

### createEntity

**Purpose**

Creates a DarkRP-compatible entity item using Lilia's item system.

**Parameters**

* `name` (*string*): The name of the entity.
* `data` (*table*): The entity data including model, description, category, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**
```lua
-- Create a DarkRP entity
lia.darkrp.createEntity("Test Entity", {
    model = "models/props_c17/chair01a.mdl",
    desc = "A test chair",
    category = "Furniture",
    ent = "prop_physics",
    price = 100
})
```

---

### createCategory

**Purpose**

Creates a DarkRP category (currently a placeholder function).

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**
```lua
-- Create a category (placeholder)
lia.darkrp.createCategory()
```
