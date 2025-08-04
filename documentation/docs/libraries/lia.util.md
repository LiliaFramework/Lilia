# Utility Library

This page documents miscellaneous helper functions.

---

## Overview

The util library contains small helper functions used across multiple modules. These include player searches, entity queries, and geometric calculations.

---

### lia.util.FindPlayersInBox

**Purpose**

Finds and returns players located inside a world-space bounding box. Useful for gathering clients within rectangular areas like rooms or zones.

**Parameters**

* `mins` (*Vector*): Minimum corner of the box.

* `maxs` (*Vector*): Maximum corner of the box.

**Realm**

`Shared`

**Returns**

* *table*: Array of matching player entities.

**Example Usage**

```lua
-- Kick everyone hiding inside a restricted building
local players = lia.util.FindPlayersInBox(Vector(-512, -512, 0), Vector(512, 512, 256))
for _, ply in ipairs(players) do
    ply:Kick("You entered a forbidden area!")
end
```

---

### lia.util.FindPlayersInSphere

**Purpose**

Returns players within a spherical radius from an origin.

**Parameters**

* `origin` (*Vector*): Sphere centre.

* `radius` (*number*): Sphere radius.

**Realm**

`Shared`

**Returns**

* *table*: Array of player entities.

**Example Usage**

```lua
local players = lia.util.FindPlayersInSphere(vector_origin, 200)
for _, ply in ipairs(players) do
    print(ply:Name())
end
```

---

### lia.util.findPlayer

**Purpose**

Attempts to find a player by SteamID, SteamID64, caret (“^” = caller), at-symbol (“@” = caller’s target), or partial name.

**Parameters**

* `client` (*Player*): Requesting player.

* `identifier` (*string*): Search string.

**Realm**

`Shared`

**Returns**

* *Player | nil*: Found player or `nil`.

**Example Usage**

```lua
local target = lia.util.findPlayer(admin, "Bob")
if target then
    admin:ChatPrint("Found: " .. target:Name())
end
```

---

### lia.util.findPlayerItems

**Purpose**

Returns every item entity in the world created by the specified player.

**Parameters**

* `client` (*Player*): Player whose items to find.

**Realm**

`Shared`

**Returns**

* *table*: Array of item entities.

**Example Usage**

```lua
local items = lia.util.findPlayerItems(LocalPlayer())
for _, item in ipairs(items) do
    print("Found item entity: " .. item:GetClass())
end
```

---

### lia.util.findPlayerItemsByClass

**Purpose**

Finds player-created item entities of a specific class.

**Parameters**

* `client` (*Player*): Player to check.

* `class` (*string*): Item class filter.

**Realm**

`Shared`

**Returns**

* *table*: Matching item entities.

**Example Usage**

```lua
local items = lia.util.findPlayerItemsByClass(LocalPlayer(), "food_banana")
for _, item in ipairs(items) do
    print(item:GetClass())
end
```

---

### lia.util.findPlayerEntities

**Purpose**

Finds all entities created by/associated with a player, optionally filtered by class.

**Parameters**

* `client` (*Player*): Player to check.

* `class` (*string | nil*): Class filter.

**Realm**

`Shared`

**Returns**

* *table*: Matching entities.

**Example Usage**

```lua
local ents = lia.util.findPlayerEntities(LocalPlayer(), "prop_physics")
for _, ent in ipairs(ents) do
    print(ent:GetClass())
end
```

---

### lia.util.stringMatches

**Purpose**

Case-insensitive partial-match comparison.

**Parameters**

* `a` (*string*): First string.

* `b` (*string*): Second string.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if match.

**Example Usage**

```lua
if lia.util.stringMatches("Hello", "he") then
    print("Strings match!")
end
```

---

### lia.util.getAdmins

**Purpose**

Returns all players that satisfy `client:isStaff()`.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *table*: Array of staff players.

**Example Usage**

```lua
for _, admin in ipairs(lia.util.getAdmins()) do
    admin:ChatPrint("Server restarting in 5 minutes!")
end
```

---

### lia.util.findPlayerBySteamID64

**Purpose**

Finds a player by SteamID64.

**Parameters**

* `SteamID64` (*string*): Target ID.

**Realm**

`Shared`

**Returns**

* *Player | nil*: Player or `nil`.

**Example Usage**

```lua
local ply = lia.util.findPlayerBySteamID64("76561198000000000")
if ply then
    print("Found player: " .. ply:Name())
end
```

---

### lia.util.findPlayerBySteamID

**Purpose**

Alias for `findPlayerBySteamID64`.

**Parameters**

* `steamID64` (*string*): SteamID64.

**Realm**

`Shared`

**Returns**

* *Player | nil*: Player or `nil`.

**Example Usage**

```lua
local ply = lia.util.findPlayerBySteamID("76561198000000000")
```

---

### lia.util.canFit

**Purpose**

Checks if a hull fits at a position without intersecting obstacles.

**Parameters**

* `pos` (*Vector*): Test position.

* `mins` (*Vector*): Hull mins (default `Vector(16, 16, 0)`).

* `maxs` (*Vector*): Hull maxs (default same as `mins`).

* `filter` (*table | Entity | function*): Trace filter.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if space is clear.

**Example Usage**

```lua
local ok = lia.util.canFit(targetPos, Vector(-16, -16, 0), Vector(16, 16, 72))
```

---

### lia.util.playerInRadius

**Purpose**

Returns players within a radius.

**Parameters**

* `pos` (*Vector*): Centre.

* `dist` (*number*): Radius.

**Realm**

`Shared`

**Returns**

* *table*: Player entities.

**Example Usage**

```lua
local nearby = lia.util.playerInRadius(vector_origin, 250)
```

---

### lia.util.formatStringNamed

**Purpose**

Formats a string with named (`{key}`) or ordered placeholders.

**Parameters**

* `format` (*string*): Format string.

* … (*vararg | table*): Table of values or ordered arguments.

**Realm**

`Shared`

**Returns**

* *string*: Formatted result.

**Example Usage**

```lua
local res = lia.util.formatStringNamed("Hello, {name}!", { name = "Bob" })
```

---

### lia.util.getMaterial

**Purpose**

Caches and returns a `Material` to avoid repeated creation.

**Parameters**

* `materialPath` (*string*): Material path.

* `materialParameters` (*string | nil*): Flags.

**Realm**

`Shared`

**Returns**

* *Material*: Cached material.

**Example Usage**

```lua
local mat = lia.util.getMaterial("path/to/material", "noclamp smooth")
surface.SetMaterial(mat)
surface.DrawTexturedRect(0, 0, 100, 100)
```

---

### lia.util.findFaction

**Purpose**

Finds a faction by name or uniqueID; includes partial-match fallback.

**Parameters**

* `client` (*Player*): Requesting player.

* `name` (*string*): Faction identifier.

**Realm**

`Shared`

**Returns**

* *table | nil*: Faction table or `nil`.

**Example Usage**

```lua
local faction = lia.util.findFaction(client, "citizen")
```

---

### lia.util.CreateTableUI

**Purpose**

Sends a net message instructing the client to build a table UI.

**Parameters**

* `client` (*Player*): Recipient.

* `title` (*string*): Table title.

* `columns` (*table*): Column definitions.

* `data` (*table*): Row data.

* `options` (*table | nil*): Right-click options.

* `characterID` (*number | nil*): Character ID.

**Realm**

`Server`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.CreateTableUI(ply, "Inventory", cols, rows, opts, charID)
```

---

### lia.util.findEmptySpace

**Purpose**

Generates empty-space positions around an entity using a grid-based search.

**Parameters**

* `entity` (*Entity*): Centre entity.

* `filter` (*table | function | Entity*): Trace filter.

* `spacing` (*number*): Grid spacing (default 32).

* `size` (*number*): Grid size (default 3).

* `height` (*number*): Bounding-box height (default 36).

* `tolerance` (*number*): Trace tolerance (default 5).

**Realm**

`Server`

**Returns**

* *table*: Sorted valid positions.

**Example Usage**

```lua
local spots = lia.util.findEmptySpace(ent, ent, 32, 3, 36, 5)
```

---

### lia.util.ShadowText

**Purpose**

Draws text with a shadow offset.

**Parameters**

* `text` (*string*): Text.

* `font` (*string*): Font.

* `x`, `y` (*number*): Position.

* `colortext` (*Color*): Text colour.

* `colorshadow` (*Color*): Shadow colour.

* `dist` (*number*): Offset distance.

* `xalign`, `yalign` (*number*): TEXT\_ALIGN\_\* constants.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.ShadowText("Hello!", "DermaDefault", 100, 100,
    color_white, color_black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
```

---

### lia.util.DrawTextOutlined

**Purpose**

Draws outlined text.

**Parameters**

* `text` (*string*): Text.

* `font` (*string*): Font.

* `x`, `y` (*number*): Position.

* `colour` (*Color*): Text colour.

* `xalign` (*number*): Alignment.

* `outlinewidth` (*number*): Outline thickness.

* `outlinecolour` (*Color*): Outline colour.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.DrawTextOutlined("Outlined", "DermaLarge", 100, 200,
    color_white, TEXT_ALIGN_CENTER, 2, color_black)
```

---

### lia.util.DrawTip

**Purpose**

Draws a tooltip-style rectangle with centred text.

**Parameters**

* `x`, `y`, `w`, `h` (*number*): Rectangle geometry.

* `text` (*string*): Tip text.

* `font` (*string*): Font.

* `textCol` (*Color*): Text colour.

* `outlineCol` (*Color*): Outline colour.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.DrawTip(100, 100, 200, 60, "This is a tip!",
    "DermaDefault", color_white, color_black)
```

---

### lia.util.drawText

**Purpose**

Draws text with a subtle shadow.

**Parameters**

* `text` (*string*): Text.

* `x`, `y` (*number*): Position.

* `color` (*Color*): Text colour.

* `alignX`, `alignY` (*number*): Align constants.

* `font` (*string*): Font (default `"liaGenericFont"`).

* `alpha` (*number*): Shadow alpha multiplier.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.drawText("Hello World", 200, 300, color_white,
    TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "liaGenericFont", 100)
```

---

### lia.util.drawTexture

**Purpose**

Draws a textured rectangle.

**Parameters**

* `material` (*string | IMaterial*): Path or material object.

* `color` (*Color*): Draw colour.

* `x`, `y`, `w`, `h` (*number*): Rectangle geometry.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.drawTexture("path/to/material", color_white, 50, 50, 64, 64)
```

---

### lia.util.skinFunc

**Purpose**

Invokes a skin function by name on a panel.

**Parameters**

* `name` (*string*): Skin-function name.

* `panel` (*Panel*): Target panel.

* `a…g` : Extra arguments.

**Realm**

`Client`

**Returns**

* *any*: Whatever the skin function returns.

**Example Usage**

```lua
lia.util.skinFunc("PaintButton", someButton, 10, 20)
```

---

### lia.util.wrapText

**Purpose**

Wraps text to a maximum width.

**Parameters**

* `text` (*string*): Text.

* `width` (*number*): Max width.

* `font` (*string*): Font used for measurement.

**Realm**

`Client`

**Returns**

* *table*, *number*: Wrapped lines and maximum line width.

**Example Usage**

```lua
local lines, maxW = lia.util.wrapText("Some long string...", 200, "liaChatFont")
```

---

### lia.util.drawBlur

**Purpose**

Draws a blur effect over a panel.

**Parameters**

* `panel` (*Panel*): Panel to blur.

* `amount` (*number*): Blur strength (default 5).

* `passes` (*number*): Iteration multiplier (default 0.2).

* `alpha` (*number*): Optional alpha transparency (default 255).

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
somePanel.Paint = function(self, w, h)
    lia.util.drawBlur(self)
end
```

---

### lia.util.drawBlurAt

**Purpose**

Draws blur over a rectangle on screen.

**Parameters**

* `x`, `y`, `w`, `h` (*number*): Rectangle.

* `amount` (*number*): Blur strength.

* `passes` (*number*): Iteration multiplier.

* `alpha` (*number*): Optional alpha transparency (default 255).

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
hook.Add("HUDPaint", "ExampleBlur", function()
    lia.util.drawBlurAt(100, 100, 200, 150)
end)
```

---

### lia.util.requestArguments

**Purpose**

Prompts the local player for typed input and returns the result to a callback.

**Parameters**

* `title` (*string*): Window title.

* `argTypes` (*table*): Definition table (label → field type or `{ type, data }`).

* `onSubmit` (*function*): Called with the collected values.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.requestArguments("User Info",
    { Name = "text", Age = "number" },
    function(values)
        PrintTable(values)
    end)
```

---

### lia.util.CreateTableUI - client implementation

**Purpose**

Creates and displays a table UI from supplied column/row data.

**Parameters**

* `title` (*string*): Table title.

* `columns` (*table*): Column definitions.

* `data` (*table*): Row data.

* `options` (*table | nil*): Right-click actions.

* `charID` (*number | nil*): Optional character ID.

**Realm**

`Client`

**Returns**

* *nil*

**Example Usage**

```lua
lia.util.CreateTableUI("My Table",
    { { name = "ID", field = "id" }, { name = "Name", field = "name" } },
    myData, myOptions, 1)
```

---
