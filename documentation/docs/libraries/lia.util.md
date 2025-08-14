# Utility Library

Documentation for utility functions.

---

### lia.util.FindPlayersInBox

**Purpose**

Finds all valid player entities within a specified axis-aligned box.

**Parameters**

* `mins` (*Vector*) - The minimum corner of the box.
* `maxs` (*Vector*) - The maximum corner of the box.

**Returns**

* `table` - A table of player entities found within the box.

**Realm**

Shared.

**Example Usage**

```lua
local players = lia.util.FindPlayersInBox(Vector(0,0,0), Vector(100,100,100))
for _, ply in ipairs(players) do
print(ply:Nick())
end
```

---

### lia.util.getBySteamID

**Purpose**

Finds a player by their SteamID or SteamID64 string, only if they have a character.

**Parameters**

* `steamID` (*string*) - The SteamID or SteamID64 of the player.

**Returns**

* Player or nil - The player entity if found and has a character, otherwise none.

**Realm**

Shared.

**Example Usage**

```lua
local ply = lia.util.getBySteamID("STEAM_0:1:123456")
if ply then
print("Found player:", ply:Nick())
end
```

---

### lia.util.FindPlayersInSphere

**Purpose**

Finds all players within a given radius of a point.

**Parameters**

* `origin` (*Vector*) - The center point of the sphere.
* `radius` (*number*) - The radius to search within.

**Returns**

* `table` - A table of player entities found within the sphere.

**Realm**

Shared.

**Example Usage**

```lua
local players = lia.util.FindPlayersInSphere(Vector(0,0,0), 256)
for _, ply in ipairs(players) do
print(ply:Nick())
end
```

---

### lia.util.findPlayer

**Purpose**

Finds a player based on a string identifier, which can be a name, SteamID, SteamID64, or special symbol.
Notifies the client if the player is not found.

**Parameters**

* `client` (*Player*) - The player requesting the search (for notifications).
* `identifier` (*string*) - The identifier to search for.

**Returns**

* Player or nil - The found player entity, or nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
local ply = lia.util.findPlayer(client, "STEAM_0:1:123456")
if ply then
print("Found player:", ply:Nick())
end
```

---

### lia.util.findPlayerItems

**Purpose**

Finds all item entities created by the specified player.

**Parameters**

* `client` (*Player*) - The player whose items to find.

**Returns**

* `table` - A table of item entities created by the player.

**Realm**

Shared.

**Example Usage**

```lua
local items = lia.util.findPlayerItems(client)
for _, item in ipairs(items) do
print(item:GetClass())
end
```

---

### lia.util.findPlayerItemsByClass

**Purpose**

Finds all item entities of a specific class created by the specified player.

**Parameters**

* `client` (*Player*) - The player whose items to find.
* `class` (*string*) - The class (item ID) to filter by.

**Returns**

* `table` - A table of item entities matching the class and player.

**Realm**

Shared.

**Example Usage**

```lua
local medkits = lia.util.findPlayerItemsByClass(client, "medkit")
for _, item in ipairs(medkits) do
print(item:GetClass())
end
```

---

### lia.util.findPlayerEntities

**Purpose**

Finds all entities of a given class created by or associated with the specified player.

**Parameters**

* `client` (*Player*) - The player whose entities to find.
* `class` (*string or nil*) - The class to filter by (optional).

**Returns**

* `table` - A table of entities matching the criteria.

**Realm**

Shared.

**Example Usage**

```lua
local ents = lia.util.findPlayerEntities(client, "prop_physics")
for _, ent in ipairs(ents) do
print(ent:GetClass())
end
```

---

### lia.util.stringMatches

**Purpose**

Checks if two strings match, case-insensitively and as substrings.

**Parameters**

* `a` (*string*) - The first string.
* `b` (*string*) - The second string.

**Returns**

* `boolean` - True if the strings match or one contains the other, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if lia.util.stringMatches("John Doe", "john") then
print("Match found!")
end
```

---

### lia.util.getAdmins

**Purpose**

Returns a table of all players who are considered staff (admins).

**Parameters**

* None.

**Returns**

* `table` - A table of player entities who are staff.

**Realm**

Shared.

**Example Usage**

```lua
local admins = lia.util.getAdmins()
for _, admin in ipairs(admins) do
print(admin:Nick())
end
```

---

### lia.util.findPlayerBySteamID64

**Purpose**

Finds a player by their SteamID64.

**Parameters**

* `SteamID64` (*string*) - The SteamID64 of the player.

**Returns**

* Player or nil - The player entity if found, otherwise none.

**Realm**

Shared.

**Example Usage**

```lua
local ply = lia.util.findPlayerBySteamID64("76561198000000000")
if ply then
print("Found player:", ply:Nick())
end
```

---

### lia.util.findPlayerBySteamID

**Purpose**

Finds a player by their SteamID.

**Parameters**

* `SteamID` (*string*) - The SteamID of the player.

**Returns**

* Player or nil - The player entity if found, otherwise none.

**Realm**

Shared.

**Example Usage**

```lua
local ply = lia.util.findPlayerBySteamID("STEAM_0:1:123456")
if ply then
print("Found player:", ply:Nick())
end
```

---

### lia.util.canFit

**Purpose**

Checks if a hull of given size can fit at a position without colliding with the world or other objects.

**Parameters**

* `pos` (*Vector*) - The position to check.
* `mins` (*Vector*) - The minimum bounds of the hull (optional, defaults to Vector(16, 16, 0)).
* `maxs` (*Vector*) - The maximum bounds of the hull (optional, defaults to mins).
* `filter` (*Entity/table*) - Entities to ignore in the trace (optional).

**Returns**

* `boolean` - True if the hull can fit, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if lia.util.canFit(Vector(0,0,0)) then
print("Space is clear!")
end
```

---

### lia.util.playerInRadius

**Purpose**

Returns all valid players within a certain radius of a position.

**Parameters**

* `pos` (*Vector*) - The center position.
* `dist` (*number*) - The radius to search (units).

**Returns**

* `table` - A table of player entities within the radius.

**Realm**

Shared.

**Example Usage**

```lua
local players = lia.util.playerInRadius(Vector(0,0,0), 128)
for _, ply in ipairs(players) do
print(ply:Nick())
end
```

---

### lia.util.formatStringNamed

**Purpose**

Formats a string using named or positional arguments, replacing {name} or {1}, {2}, etc.

**Parameters**

* `format` (*string*) - The format string containing placeholders.
* ...             - Arguments as a table (named) or as a list (positional).

**Returns**

* `string` - The formatted string.

**Realm**

Shared.

**Example Usage**

```lua
local str = lia.util.formatStringNamed("Hello, {name}!", {name = "John"})
print(str) -- "Hello, John!"
```

---

### lia.util.getMaterial

**Purpose**

Returns a cached Material object for the given path and parameters, creating it if necessary.

**Parameters**

* `materialPath` (*string*) - The path to the material.
* `materialParameters` (*string*) - Optional parameters for the material.

**Returns**

* `IMaterial` - The Material object.

**Realm**

Client.

**Example Usage**

```lua
local mat = lia.util.getMaterial("icon16/user.png")
surface.SetMaterial(mat)
```

---

### lia.util.findFaction

**Purpose**

Finds a faction by name or uniqueID, notifies the client if not found.

**Parameters**

* `client` (*Player*) - The player requesting the search (for notifications).
* `name` (*string*) - The name or uniqueID of the faction.

**Returns**

* table or nil - The faction table if found, otherwise none.

**Realm**

Shared.

**Example Usage**

```lua
local faction = lia.util.findFaction(client, "overwatch")
if faction then
print("Faction found:", faction.name)
end
```

---

### lia.util.SendTableUI

**Purpose**

Sends a table UI to a client for display, including title, columns, data, and options using the big table transfer system.

**Parameters**

* `client` (*Player*) - The player to send the UI to.
* `title` (*string*) - The title of the table.
* `columns` (*table*) - The columns to display.
* `data` (*table*) - The data rows to display.
* `options` (*table*) - Optional actions for each row.
* `characterID` (*number*) - Optional character ID for context.

**Returns**

* None.

**Realm**

Server.

**Example Usage**

```lua
lia.util.SendTableUI(client, "Player List", columns, data, options, charID)
```

---

### lia.util.findEmptySpace

**Purpose**

Finds empty positions around an entity where a hull of given size can fit, useful for spawning items or players.

**Parameters**

* `entity` (*Entity*) - The entity to search around.
* `filter` (*Entity/table*) - Entities to ignore in the trace (optional).
* `spacing` (*number*) - The distance between each check (optional, default 32).
* `size` (*number*) - The number of positions to check in each direction (optional, default 3).
* `height` (*number*) - The height of the hull (optional, default 36).
* `tolerance` (*number*) - The Z offset for the trace (optional, default 5).

**Returns**

* `table` - A sorted table of valid positions (Vector) around the entity.

**Realm**

Server.

**Example Usage**

```lua
local positions = lia.util.findEmptySpace(ent)
for _, pos in ipairs(positions) do
print(pos)
end
```

---

### lia.util.ShadowText

**Purpose**

Draws text with a shadow at the specified position.

**Parameters**

* `text` (*string*) - The text to draw.
* `font` (*string*) - The font to use.
* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `colortext` (*Color*) - The color of the text.
* `colorshadow` (*Color*) - The color of the shadow.
* `dist` (*number*) - The distance to offset the shadow.
* `xalign` (*number*) - The horizontal alignment.
* `yalign` (*number*) - The vertical alignment.

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.ShadowText("Hello", "DermaDefault", 100, 100, color_white, color_black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
```

---

### lia.util.DrawTextOutlined

**Purpose**

Draws text with an outline at the specified position.

**Parameters**

* `text` (*string*) - The text to draw.
* `font` (*string*) - The font to use.
* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `colour` (*Color*) - The color of the text.
* `xalign` (*number*) - The horizontal alignment.
* `outlinewidth` (*number*) - The width of the outline.
* `outlinecolour` (*Color*) - The color of the outline.

**Returns**

* `number` - The width of the drawn text.

**Realm**

Client.

**Example Usage**

```lua
lia.util.DrawTextOutlined("Outlined", "DermaDefault", 100, 100, color_white, TEXT_ALIGN_LEFT, 2, color_black)
```

---

### lia.util.DrawTip

**Purpose**

Draws a tooltip-like tip box with a triangle pointer and text.

**Parameters**

* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `w` (*number*) - The width of the tip.
* `h` (*number*) - The height of the tip.
* `text` (*string*) - The text to display.
* `font` (*string*) - The font to use.
* `textCol` (*Color*) - The color of the text.
* `outlineCol` (*Color*) - The color of the outline.

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.DrawTip(100, 100, 200, 50, "Tip!", "DermaDefault", color_white, color_black)
```

---

### lia.util.drawText

**Purpose**

Draws text with a shadow at the specified position using draw.TextShadow.

**Parameters**

* `text` (*string*) - The text to draw.
* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `color` (*Color*) - The color of the text (optional, defaults to white).
* `alignX` (*number*) - The horizontal alignment (optional).
* `alignY` (*number*) - The vertical alignment (optional).
* `font` (*string*) - The font to use (optional, defaults to "liaGenericFont").
* `alpha` (*number*) - The alpha value for the shadow (optional).

**Returns**

* `number` - The width of the drawn text.

**Realm**

Client.

**Example Usage**

```lua
lia.util.drawText("Hello", 100, 100, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
```

---

### lia.util.drawTexture

**Purpose**

Draws a textured rectangle using a cached material.

**Parameters**

* `material` (*string*) - The path to the material.
* `color` (*Color*) - The color to draw with (optional, defaults to white).
* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `w` (*number*) - The width.
* `h` (*number*) - The height.

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.drawTexture("icon16/user.png", color_white, 100, 100, 16, 16)
```

---

### lia.util.skinFunc

**Purpose**

Calls a skin function for a panel, if it exists.

**Parameters**

* `name` (*string*) - The name of the skin function.
* `panel` (*Panel*) - The panel to pass to the skin function.
* a, b, c, d, e, f, g - Additional arguments to pass.

**Returns**

* `any` - The return value of the skin function, or nil if not found.

**Realm**

Client.

**Example Usage**

```lua
lia.util.skinFunc("Paint", panel, w, h)
```

---

### lia.util.wrapText

**Purpose**

Wraps a string of text to fit within a specified width, using the given font.

**Parameters**

* `text` (*string*) - The text to wrap.
* `width` (*number*) - The maximum width in pixels.
* `font` (*string*) - The font to use (optional, defaults to "liaChatFont").

**Returns**

* table, number - A table of wrapped lines and the maximum width.

**Realm**

Client.

**Example Usage**

```lua
local lines, maxW = lia.util.wrapText("This is a long message.", 200)
for _, line in ipairs(lines) do
print(line)
end
```

---

### lia.util.drawBlur

**Purpose**

Draws a blur effect over the specified panel.

**Parameters**

* `panel` (*Panel*) - The panel to blur.
* `amount` (*number*) - The blur amount (optional, default 5).
* `passes` (*number*) - The number of passes (optional, default 0.2).
* `alpha` (*number*) - The alpha value (optional, default 255).

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.drawBlur(panel, 5, 1, 200)
```

---

### lia.util.drawBlurAt

**Purpose**

Draws a blur effect over a specified rectangle on the screen.

**Parameters**

* `x` (*number*) - The X position.
* `y` (*number*) - The Y position.
* `w` (*number*) - The width.
* `h` (*number*) - The height.
* `amount` (*number*) - The blur amount (optional, default 5).
* `passes` (*number*) - The number of passes (optional, default 0.2).
* `alpha` (*number*) - The alpha value (optional, default 255).

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.drawBlurAt(100, 100, 200, 100, 5, 1, 200)
```

---

### lia.util.drawBlackBlur

**Purpose**

Draws a blur effect over the specified panel and overlays it with a black tint.

**Parameters**

* `panel` (*Panel*) - The panel to blur.
* `amount` (*number*) - The blur amount (optional, default 5).
* `passes` (*number*) - The number of passes (optional, default 0.2).
* `alpha` (*number*) - The alpha value for the black overlay (optional, default 255).

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.drawBlackBlur(panel, 5, 1, 200)
```

---

### lia.util.requestArguments

**Purpose**

Opens a UI to request multiple arguments from the user, supporting strings, numbers, booleans, and dropdowns.

**Parameters**

* `title` (*string*) - The title of the UI.
* `argTypes` (*table*) - A table describing the argument types and names.
* `onSubmit` (*function*) - Callback function called with the result table.

**Returns**

* None.

**Realm**

Client.

**Example Usage**

```lua
lia.util.requestArguments("Enter Info", {Name="string", Age="int"}, function(result) PrintTable(result) end)
```

---

### lia.util.CreateTableUI

**Purpose**

Creates and displays a table UI frame with columns, data, and row options for the client.

**Parameters**

* `title` (*string*) - The title of the table.
* `columns` (*table*) - The columns to display.
* `data` (*table*) - The data rows to display.
* `options` (*table*) - Optional actions for each row.
* `charID` (*number*) - Optional character ID for context.

**Returns**

* Panel, DListView - The frame and the list view created.

**Realm**

Client.

**Example Usage**

```lua
local frame, listView = lia.util.CreateTableUI("Player List", columns, data, options, charID)
```

---
