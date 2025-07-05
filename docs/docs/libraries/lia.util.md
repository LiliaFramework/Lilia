# Utility Library

This page documents miscellaneous helper functions.

---

## Overview

The util library contains small miscellaneous helper functions used across modules. These include player searches, entity queries, and geometric calculations.

---

### lia.util.FindPlayersInBox

**Description:**

Finds and returns players located inside a world-space bounding box. Useful for quickly gathering clients within rectangular areas like rooms or zones.

**Parameters:**

* `mins` (`Vector`) – The minimum corner of the box.


* `maxs` (`Vector`) – The maximum corner of the box.


**Realm:**

* Shared


**Returns:**

* table – A table of matching player entities.


**Example Usage:**

```lua
    -- Kick everyone hiding inside a restricted building
    local players = lia.util.FindPlayersInBox(Vector(-512, -512, 0), Vector(512, 512, 256))
    for _, ply in ipairs(players) do
        ply:Kick("You entered a forbidden area!")
    end
```

---

### lia.util.FindPlayersInSphere

**Description:**

Finds and returns a table of players within a given spherical radius from an origin.

**Parameters:**

* `origin` (`Vector`) — The center of the sphere.


* `radius` (`number`) — The radius of the sphere.


**Realm:**

* Shared


**Returns:**

* table — A table of valid player entities.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.FindPlayersInSphere
    local players = lia.util.FindPlayersInSphere(Vector(0, 0, 0), 200)
    for _, ply in ipairs(players) do
        print(ply:Name())
    end
```

---

### lia.util.findPlayer

**Description:**

Attempts to find a player using various identifier formats. The search accepts SteamID, SteamID64, "^" for the caller, "@" for their target, or a partial name.

**Parameters:**

* `client` (`Player`) — The player requesting the find (used for notifications).


* `identifier` (`string`) — The identifier to search by.


**Realm:**

* Shared



**Returns:**

* Player|nil — The found player, or nil if not found.


**Example Usage:**

```lua
    -- Search for a player by partial name
    local target = lia.util.findPlayer(admin, "Bob")
    if target then
        admin:ChatPrint("Found: " .. target:Name())
    end
```

---

### lia.util.findPlayerItems

**Description:**

Finds all item entities in the world created by the specified player.

**Parameters:**

* `client` (`Player`) — The player whose items to find.


**Realm:**

* Shared


**Returns:**

* table — A table of valid item entities.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findPlayerItems
    local items = lia.util.findPlayerItems(LocalPlayer())
    for _, item in ipairs(items) do
        print("Found item entity: " .. item:GetClass())
    end
```

---

### lia.util.findPlayerItemsByClass

**Description:**

Finds all item entities in the world created by the specified player with a specific class ID.

**Parameters:**

* `client` (`Player`) — The player whose items to find.


* `class` (`string`) — The class ID to filter by.


**Realm:**

* Shared


**Returns:**

* table — A table of valid item entities matching the class.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findPlayerItemsByClass
    local items = lia.util.findPlayerItemsByClass(LocalPlayer(), "food_banana")
    for _, item in ipairs(items) do
        print("Found item entity: " .. item:GetClass())
    end
```

---

### lia.util.findPlayerEntities

**Description:**

Finds all entities in the world created by or associated with the specified player. An optional class filter can be applied.

**Parameters:**

* `client` (`Player`) — The player whose entities to find.


* `class` (`string|nil`) — The class name to filter by (optional).


**Realm:**

* Shared


**Returns:**

* table — A table of valid entities.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findPlayerEntities
    local entities = lia.util.findPlayerEntities(LocalPlayer(), "prop_physics")
    for _, ent in ipairs(entities) do
        print("Found player entity: " .. ent:GetClass())
    end
```

---

### lia.util.stringMatches

**Description:**

Checks if string a matches string b (case-insensitive, partial matches).

**Parameters:**

* `a` (`string`) — The first string to check.


* `b` (`string`) — The second string to match against.


**Realm:**

* Shared


**Returns:**

* boolean — True if they match, false otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.stringMatches
    if lia.util.stringMatches("Hello", "he") then
        print("Strings match!")
    end
```

---

### lia.util.getAdmins

**Description:**

Returns all players considered staff or admins, as determined by client:isStaff().

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* table — A table of player entities who are staff.


**Example Usage:**

```lua
    -- Notify all online staff members about an upcoming restart
    local admins = lia.util.getAdmins()
    for _, admin in ipairs(admins) do
        admin:ChatPrint("Server restarting" .. " in 5 minutes!")
    end
```

---

### lia.util.findPlayerBySteamID64

**Description:**

Finds a player currently on the server by their SteamID64.

**Parameters:**

* `SteamID64` (`string`) — The SteamID64 to search for.


**Realm:**

* Shared


**Returns:**

* Player|nil — The found player or nil if not found.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findPlayerBySteamID64
    local ply = lia.util.findPlayerBySteamID64("76561198000000000")
    if ply then
        print("Found player: " .. ply:Name())
    end
```

---

### lia.util.findPlayerBySteamID

**Description:**

Finds a player currently on the server by their SteamID64.

**Parameters:**

* `steamID64` (`string`) — The SteamID64 of the player (e.g. "76561198000000000").


**Realm:**

* Shared

**Returns:**

* Player|nil — The found player or nil if not found.

**Example Usage:**

```lua
    -- Find a player by SteamID64
    local ply = lia.util.findPlayerBySteamID("76561198000000000")
    if ply then
        print("Found player: " .. ply:Name())
    end
```

### lia.util.canFit

**Description:**

Checks if a hull (defined by mins and maxs) can fit at the given position without intersecting obstacles.

**Parameters:**

* `pos` (`Vector`) — The position to test.


* `mins` (`Vector`) — The minimum corner of the hull (defaults to Vector(16, 16, 0) if nil).


* `maxs` (`Vector`) — The maximum corner of the hull (defaults to same as mins if nil).


* `filter` (`table|Entity|function`) — Optional filter for the trace.


**Realm:**

* Shared


**Returns:**

* boolean — True if it can fit, false otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.canFit
    local canStand = lia.util.canFit(somePos, Vector(-16, -16, 0), Vector(16, 16, 72))
    if canStand then
        print("The player can stand here.")
    end
```

---

### lia.util.playerInRadius

**Description:**

Finds and returns a table of players within a given radius from a position.

**Parameters:**

* `pos` (`Vector`) — The center position.


* `dist` (`number`) — The radius to search within.


**Realm:**

* Shared


**Returns:**

* table — A table of player entities within the radius.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.playerInRadius
    local playersNearby = lia.util.playerInRadius(Vector(0, 0, 0), 250)
    for _, ply in ipairs(playersNearby) do
        print("Nearby player: " .. ply:Name())
    end
```

---

### lia.util.formatStringNamed

**Description:**

Formats a string with named or indexed placeholders. If a table is passed, uses named keys. Otherwise uses ordered arguments.

**Parameters:**

* `format` (`string`) — The format string with placeholders like "{key}".


* ... (vararg|table) — Either a table or vararg arguments to fill placeholders.


**Realm:**

* Shared


**Returns:**

* string — The formatted string.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.formatStringNamed
    local result = lia.util.formatStringNamed("Hello, {name}!", {name = "Bob"})
    print(result) -- "Hello, Bob!"
```

---

### lia.util.getMaterial

**Description:**

Retrieves a cached Material for the specified path and parameters, to avoid repeated creation.

**Parameters:**

* `materialPath` (`string`) — The file path to the material.


* `materialParameters` (`string|nil`) — Optional material parameters.


**Realm:**

* Shared


**Returns:**

* Material — The requested material.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.getMaterial
    local mat = lia.util.getMaterial("path/to/material", "noclamp smooth")
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, 100, 100)
```

---

### lia.util.findFaction

**Description:**

Finds a faction by name or uniqueID. If an exact identifier is found in lia.faction.teams, returns that. Otherwise checks for partial match.

**Parameters:**

* `client` (`Player`) — The player requesting the search (used for notifications).


* `name` (`string`) — The name or uniqueID of the faction to find.


**Realm:**

* Shared


**Returns:**

* table|nil — The found faction table, or nil if not found.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findFaction
    local faction = lia.util.findFaction(client, "citizen")
    if faction then
        print("Found faction: " .. faction.name)
    end
```

---

### lia.util.CreateTableUI

**Description:**

Sends a net message to the client to create a table UI with given data.

**Parameters:**

* `client` (`Player`) — The player to whom the UI will be sent.


* `title` (`string`) — The title of the table UI.


* `columns` (`table`) — The columns of the table.


* `data` (`table`) — The row data.


* `options` (`table|nil`) — Additional options for the table actions.


* `characterID` (`number|nil`) — An optional character ID to pass along.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.CreateTableUI
    lia.util.CreateTableUI(somePlayer, "My Table", {{name="ID", field="id"}, {name="Name", field="name"}}, someData, someOptions, charID)
```

---

### lia.util.findEmptySpace

**Description:**

Finds potential empty space positions around an entity using a grid-based approach.

**Parameters:**

* `entity` (`Entity`) — The entity around which to search.


* `filter` (`table|function|Entity`) — The filter for the trace or the entity to ignore.


* `spacing` (`number`) — The spacing between each point in the grid (default 32).


* `size` (`number`) — The grid size in each direction (default 3).


* `height` (`number`) — The height of the bounding box (default 36).


* `tolerance` (`number`) — The trace tolerance (default 5).


**Realm:**

* Server


**Returns:**

* table — A sorted table of valid positions found.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.findEmptySpace
    local positions = lia.util.findEmptySpace(someEntity, someFilter, 32, 3, 36, 5)
    for _, pos in ipairs(positions) do
        print("Empty space at: " .. tostring(pos))
    end
```

---

### lia.util.ShadowText

**Description:**

Draws text with a shadow offset.

**Parameters:**

* `text` (`string`) — The text to draw.


* `font` (`string`) — The font used.


* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `colortext` (`Color`) — The color of the text.


* `colorshadow` (`Color`) — The shadow color.


* `dist` (`number`) — The distance offset for the shadow.


* `xalign` (`number`) — The horizontal alignment (TEXT_ALIGN_*).


* `yalign` (`number`) — The vertical alignment (TEXT_ALIGN_*).


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.ShadowText
    lia.util.ShadowText("Hello!", "DermaDefault", 100, 100, color_white, color_black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
```

---

### lia.util.DrawTextOutlined

**Description:**

Draws text with an outlined border.

**Parameters:**

* `text` (`string`) — The text to draw.


* `font` (`string`) — The font used.


* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `colour` (`Color`) — The text color.


* `xalign` (`number`) — The horizontal alignment.


* `outlinewidth` (`number`) — The outline thickness.


* `outlinecolour` (`Color`) — The outline color.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.DrawTextOutlined
    lia.util.DrawTextOutlined("Outlined Text", "DermaLarge", 100, 200, color_white, TEXT_ALIGN_CENTER, 2, color_black)
```

---

### lia.util.DrawTip

**Description:**

Draws a tooltip-like shape with text in the center.

**Parameters:**

* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `w` (`number`) — The width of the tip.


* `h` (`number`) — The height of the tip.


* `text` (`string`) — The text to display.


* `font` (`string`) — The font for the text.


* `textCol` (`Color`) — The text color.


* `outlineCol` (`Color`) — The outline color.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.DrawTip
    lia.util.DrawTip(100, 100, 200, 60, "This is a tip!", "DermaDefault", color_white, color_black)
```

---

### lia.util.drawText

**Description:**

Draws text with a subtle shadow effect.

**Parameters:**

* `text` (`string`) — The text to draw.


* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `color` (`Color`) — The text color.


* `alignX` (`number`) — Horizontal alignment (TEXT_ALIGN_*).


* `alignY` (`number`) — Vertical alignment (TEXT_ALIGN_*).


* `font` (`string`) — The font to use (defaults to "liaGenericFont").


* `alpha` (`number`) — The shadow alpha multiplier.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.drawText
    lia.util.drawText("Hello World", 200, 300, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "liaGenericFont", 100)
```

---

### lia.util.drawTexture

**Description:**

Draws a textured rectangle with the specified material.

**Parameters:**

* `material` (`string|IMaterial`) — Path to the material or IMaterial object.


* `color` (`Color`) — The draw color (defaults to color_white).


* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `w` (`number`) — The width.


* `h` (`number`) — The height.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.drawTexture
    lia.util.drawTexture("path/to/material", color_white, 50, 50, 64, 64)
```

---

### lia.util.skinFunc

**Description:**

Calls a skin function by name, passing the panel and any extra arguments.

**Parameters:**

* `name` (`string`) — The name of the skin function.


* `panel` (`Panel`) — The panel to apply the skin function to.


* a, b, c, d, e, f, g — Additional arguments passed to the skin function.


**Realm:**

* Client


**Returns:**

* any — The result of the skin function call, if any.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.skinFunc
    lia.util.skinFunc("PaintButton", someButton, 10, 20)
```

---

### lia.util.wrapText

**Description:**

Wraps text to a maximum width, returning a table of lines and the maximum line width found.

**Parameters:**

* `text` (`string`) — The text to wrap.


* `width` (`number`) — The maximum width in pixels.


* `font` (`string`) — The font name to use for measuring.


**Realm:**

* Client


**Returns:**

* table, number — A table of wrapped lines and the maximum line width found.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.wrapText
    local lines, maxW = lia.util.wrapText("Some long string that needs wrapping...", 200, "liaChatFont")
    for _, line in ipairs(lines) do
        print(line)
    end
    print("Max width: " .. maxW)
```

---

### lia.util.drawBlur

**Description:**

Draws a blur effect over the specified panel.

**Parameters:**

* `panel` (`Panel`) — The panel to blur.


* `amount` (`number`) — The blur strength (defaults to 5).


* `passes` (`number`) — The iteration multiplier (defaults to 0.2).


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    somePanel.Paint = function(self, w, h)
        lia.util.drawBlur(self)
    end
```

---

### lia.util.drawBlurAt

**Description:**

Draws a blur effect at a specified rectangle on the screen.

**Parameters:**

* `x` (`number`) — The x position.


* `y` (`number`) — The y position.


* `w` (`number`) — The width of the rectangle.


* `h` (`number`) — The height of the rectangle.


* `amount` (`number`) — The blur strength (defaults to 5).


* `passes` (`number`) — The iteration multiplier (defaults to 0.2).


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    hook.Add("HUDPaint", "ExampleBlur", function()
        lia.util.drawBlurAt(100, 100, 200, 150)
    end)
```

---

### lia.util.CreateTableUI

**Description:**

Creates and displays a table UI with given columns and data on the client side.

**Parameters:**

* `title` (`string`) — The title of the table.


* `columns` (`table`) — The columns, each being {name=..., field=..., width=...}.


* `data` (`table`) — The row data, each row is a table of field values.


* `options` (`table|nil`) — Table of options for right-click actions, each containing {name=..., net=..., ExtraFields=...}.


* `charID` (`number|nil`) — Optional character ID.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.util.CreateTableUI
    lia.util.CreateTableUI("My Table", {{name="ID", field="id"}, {name="Name", field="name"}}, myData, myOptions, 1)
```

