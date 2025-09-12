# Util Library

This page documents the functions for working with utilities and helper functions.

---

## Overview

The util library (`lia.util`) provides a comprehensive system for managing utilities, helper functions, and common operations in the Lilia framework, serving as the foundational utility layer that supports all other framework components with essential functionality. This library handles sophisticated utility management with support for player-related operations including player searching, validation, and management functions that work across different player states and connection statuses. The system features advanced text utilities with support for string manipulation, formatting, validation, and localization that provide consistent text handling throughout the framework. It includes comprehensive rendering utilities with support for 2D and 3D rendering operations, UI element creation, and visual effects that enhance the user interface and gameplay experience. The library provides robust general helper functions with support for mathematical operations, data validation, performance optimization, and debugging tools that improve development efficiency and system reliability. Additional features include integration with Garry's Mod's native functions, cross-platform compatibility utilities, and performance monitoring tools that ensure optimal framework operation across different server configurations and client setups, making it essential for maintaining code quality and providing consistent functionality throughout the entire framework ecosystem.

---


### getBySteamID

**Purpose**

Gets a player by SteamID.

**Parameters**

* `steamID` (*string*): The SteamID to search for.

**Returns**

* `player` (*Player*): The player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Get player by SteamID
local function getPlayerBySteamID(steamID)
    return lia.util.getBySteamID(steamID)
end

-- Use in a function
local function findPlayerBySteamID(steamID)
    local player = lia.util.getBySteamID(steamID)
    if player then
        print("Player found: " .. player:Name())
        return player
    else
        print("Player not found")
        return nil
    end
end
```

---

### FindPlayersInSphere

**Purpose**

Finds players within a sphere area.

**Parameters**

* `position` (*Vector*): The center position.
* `radius` (*number*): The sphere radius.

**Returns**

* `players` (*table*): Table of players in the sphere.

**Realm**

Server.

**Example Usage**

```lua
-- Find players in sphere
local function findPlayersInSphere(position, radius)
    return lia.util.FindPlayersInSphere(position, radius)
end

-- Use in a function
local function findPlayersNearEntity(entity, radius)
    return lia.util.FindPlayersInSphere(entity:GetPos(), radius)
end
```

---

### findPlayer

**Purpose**

Finds a player by name or SteamID.

**Parameters**

* `identifier` (*string*): The player identifier.

**Returns**

* `player` (*Player*): The player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find player by identifier
local function findPlayer(identifier)
    return lia.util.findPlayer(identifier)
end

-- Use in a function
local function findPlayerByName(name)
    local player = lia.util.findPlayer(name)
    if player then
        print("Player found: " .. player:Name())
        return player
    else
        print("Player not found: " .. name)
        return nil
    end
end
```

---

### findPlayerItems

**Purpose**

Finds items belonging to a player.

**Parameters**

* `client` (*Player*): The player to search for.

**Returns**

* `items` (*table*): Table of player items.

**Realm**

Server.

**Example Usage**

```lua
-- Find player items
local function findPlayerItems(client)
    return lia.util.findPlayerItems(client)
end

-- Use in a function
local function getPlayerItemCount(client)
    local items = lia.util.findPlayerItems(client)
    return #items
end
```

---

### findPlayerItemsByClass

**Purpose**

Finds player items by class.

**Parameters**

* `client` (*Player*): The player to search for.
* `itemClass` (*string*): The item class.

**Returns**

* `items` (*table*): Table of matching items.

**Realm**

Server.

**Example Usage**

```lua
-- Find player items by class
local function findPlayerItemsByClass(client, itemClass)
    return lia.util.findPlayerItemsByClass(client, itemClass)
end

-- Use in a function
local function findPlayerWeapons(client)
    return lia.util.findPlayerItemsByClass(client, "weapon_*")
end
```

---

### findPlayerEntities

**Purpose**

Finds entities belonging to a player.

**Parameters**

* `client` (*Player*): The player to search for.

**Returns**

* `entities` (*table*): Table of player entities.

**Realm**

Server.

**Example Usage**

```lua
-- Find player entities
local function findPlayerEntities(client)
    return lia.util.findPlayerEntities(client)
end

-- Use in a function
local function getPlayerEntityCount(client)
    local entities = lia.util.findPlayerEntities(client)
    return #entities
end
```

---

### stringMatches

**Purpose**

Checks if a string matches a pattern.

**Parameters**

* `text` (*string*): The text to check.
* `pattern` (*string*): The pattern to match.

**Returns**

* `matches` (*boolean*): True if the string matches.

**Realm**

Shared.

**Example Usage**

```lua
-- Check string matches
local function stringMatches(text, pattern)
    return lia.util.stringMatches(text, pattern)
end

-- Use in a function
local function checkPlayerName(name, pattern)
    return lia.util.stringMatches(name, pattern)
end
```

---

### getAdmins

**Purpose**

Gets all admin players.

**Parameters**

*None*

**Returns**

* `admins` (*table*): Table of admin players.

**Realm**

Server.

**Example Usage**

```lua
-- Get admin players
local function getAdmins()
    return lia.util.getAdmins()
end

-- Use in a function
local function showAdmins()
    local admins = lia.util.getAdmins()
    print("Admin players:")
    for _, admin in ipairs(admins) do
        print("- " .. admin:Name())
    end
end
```

---

### findPlayerBySteamID64

**Purpose**

Finds a player by SteamID64.

**Parameters**

* `steamID64` (*string*): The SteamID64 to search for.

**Returns**

* `player` (*Player*): The player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find player by SteamID64
local function findPlayerBySteamID64(steamID64)
    return lia.util.findPlayerBySteamID64(steamID64)
end

-- Use in a function
local function findPlayerBySteamID64(steamID64)
    local player = lia.util.findPlayerBySteamID64(steamID64)
    if player then
        print("Player found: " .. player:Name())
        return player
    else
        print("Player not found")
        return nil
    end
end
```

---

### findPlayerBySteamID

**Purpose**

Finds a player by SteamID.

**Parameters**

* `steamID` (*string*): The SteamID to search for.

**Returns**

* `player` (*Player*): The player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find player by SteamID
local function findPlayerBySteamID(steamID)
    return lia.util.findPlayerBySteamID(steamID)
end

-- Use in a function
local function findPlayerBySteamID(steamID)
    local player = lia.util.findPlayerBySteamID(steamID)
    if player then
        print("Player found: " .. player:Name())
        return player
    else
        print("Player not found")
        return nil
    end
end
```

---

### canFit

**Purpose**

Checks if an object can fit in a position.

**Parameters**

* `position` (*Vector*): The position to check.
* `size` (*Vector*): The size of the object.

**Returns**

* `canFit` (*boolean*): True if the object can fit.

**Realm**

Server.

**Example Usage**

```lua
-- Check if object can fit
local function canFit(position, size)
    return lia.util.canFit(position, size)
end

-- Use in a function
local function checkSpawnPosition(pos, size)
    if lia.util.canFit(pos, size) then
        print("Position is clear")
        return true
    else
        print("Position is blocked")
        return false
    end
end
```

---

### playerInRadius

**Purpose**

Checks if a player is within a radius.

**Parameters**

* `position` (*Vector*): The center position.
* `radius` (*number*): The radius.

**Returns**

* `players` (*table*): Table of players in radius.

**Realm**

Server.

**Example Usage**

```lua
-- Check players in radius
local function playerInRadius(position, radius)
    return lia.util.playerInRadius(position, radius)
end

-- Use in a function
local function findNearbyPlayers(pos, radius)
    local players = lia.util.playerInRadius(pos, radius)
    print("Found " .. #players .. " players within " .. radius .. " units")
    return players
end
```

---

### formatStringNamed

**Purpose**

Formats a string with named parameters.

**Parameters**

* `text` (*string*): The text to format.
* `parameters` (*table*): The named parameters.

**Returns**

* `formattedText` (*string*): The formatted text.

**Realm**

Shared.

**Example Usage**

```lua
-- Format string with named parameters
local function formatStringNamed(text, parameters)
    return lia.util.formatStringNamed(text, parameters)
end

-- Use in a function
local function formatPlayerMessage(message, player)
    local parameters = {
        name = player:Name(),
        steamid = player:SteamID()
    }
    return lia.util.formatStringNamed(message, parameters)
end
```

---

### getMaterial

**Purpose**

Gets a material by name.

**Parameters**

* `materialName` (*string*): The material name.

**Returns**

* `material` (*Material*): The material or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get material by name
local function getMaterial(materialName)
    return lia.util.getMaterial(materialName)
end

-- Use in a function
local function loadMaterial(materialName)
    local material = lia.util.getMaterial(materialName)
    if material then
        print("Material loaded: " .. materialName)
        return material
    else
        print("Material not found: " .. materialName)
        return nil
    end
end
```

---

### findFaction

**Purpose**

Finds a faction by name.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `faction` (*table*): The faction data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Find faction by name
local function findFaction(factionName)
    return lia.util.findFaction(factionName)
end

-- Use in a function
local function checkFactionExists(factionName)
    local faction = lia.util.findFaction(factionName)
    if faction then
        print("Faction exists: " .. factionName)
        return true
    else
        print("Faction not found: " .. factionName)
        return false
    end
end
```

---

### SendTableUI

**Purpose**

Sends a table to the client UI.

**Parameters**

* `client` (*Player*): The client to send to.
* `tableName` (*string*): The table name.
* `data` (*table*): The table data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send table to UI
local function sendTableUI(client, tableName, data)
    lia.util.SendTableUI(client, tableName, data)
end

-- Use in a function
local function sendPlayerData(client, data)
    lia.util.SendTableUI(client, "PlayerData", data)
    print("Player data sent to " .. client:Name())
end
```

---

### findEmptySpace

**Purpose**

Finds an empty space near a position.

**Parameters**

* `position` (*Vector*): The position to search from.
* `size` (*Vector*): The size of the space needed.

**Returns**

* `emptyPosition` (*Vector*): The empty position or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find empty space
local function findEmptySpace(position, size)
    return lia.util.findEmptySpace(position, size)
end

-- Use in a function
local function findSpawnPosition(pos, size)
    local emptyPos = lia.util.findEmptySpace(pos, size)
    if emptyPos then
        print("Empty space found at " .. tostring(emptyPos))
        return emptyPos
    else
        print("No empty space found")
        return nil
    end
end
```

---

### ShadowText

**Purpose**

Draws text with a shadow effect.

**Parameters**

* `text` (*string*): The text to draw.
* `font` (*string*): The font to use.
* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `color` (*Color*): The text color.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw shadow text
local function drawShadowText(text, font, x, y, color)
    lia.util.ShadowText(text, font, x, y, color)
end

-- Use in a function
local function drawPlayerName(client, x, y)
    local color = client:getChar():getFaction():getColor()
    lia.util.ShadowText(client:Name(), "liaMediumFont", x, y, color)
end
```

---

### DrawTextOutlined

**Purpose**

Draws text with an outline effect.

**Parameters**

* `text` (*string*): The text to draw.
* `font` (*string*): The font to use.
* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `color` (*Color*): The text color.
* `outlineColor` (*Color*): The outline color.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw outlined text
local function drawOutlinedText(text, font, x, y, color, outlineColor)
    lia.util.DrawTextOutlined(text, font, x, y, color, outlineColor)
end

-- Use in a function
local function drawTitleText(text, x, y)
    lia.util.DrawTextOutlined(text, "liaLargeFont", x, y, Color(255, 255, 255), Color(0, 0, 0))
end
```

---

### DrawTip

**Purpose**

Draws a tooltip.

**Parameters**

* `text` (*string*): The tooltip text.
* `x` (*number*): The x position.
* `y` (*number*): The y position.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw tooltip
local function drawTooltip(text, x, y)
    lia.util.DrawTip(text, x, y)
end

-- Use in a function
local function drawItemTooltip(item, x, y)
    local text = item:getName() .. "\n" .. item:getDescription()
    lia.util.DrawTip(text, x, y)
end
```

---

### drawText

**Purpose**

Draws text with various effects.

**Parameters**

* `text` (*string*): The text to draw.
* `font` (*string*): The font to use.
* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `color` (*Color*): The text color.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw text
local function drawText(text, font, x, y, color)
    lia.util.drawText(text, font, x, y, color)
end

-- Use in a function
local function drawCenteredText(text, x, y, color)
    local width = lia.util.getTextWidth(text, "liaMediumFont")
    lia.util.drawText(text, "liaMediumFont", x - width / 2, y, color)
end
```

---

### drawTexture

**Purpose**

Draws a texture.

**Parameters**

* `texture*): The texture to draw.
* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `width` (*number*): The width.
* `height` (*number*): The height.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw texture
local function drawTexture(texture, x, y, width, height)
    lia.util.drawTexture(texture, x, y, width, height)
end

-- Use in a function
local function drawBackground(texture, x, y, width, height)
    lia.util.drawTexture(texture, x, y, width, height)
end
```

---

### skinFunc

**Purpose**

Applies skin function to a panel.

**Parameters**

* `panel` (*Panel*): The panel to skin.
* `skinFunc` (*function*): The skin function.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Apply skin function
local function applySkin(panel, skinFunc)
    lia.util.skinFunc(panel, skinFunc)
end

-- Use in a function
local function skinPanel(panel)
    lia.util.skinFunc(panel, function(skin)
        skin.colors = lia.color.getTheme()
    end)
end
```

---

### wrapText

**Purpose**

Wraps text to fit within a width.

**Parameters**

* `text` (*string*): The text to wrap.
* `font` (*string*): The font to use.
* `width` (*number*): The maximum width.

**Returns**

* `wrappedText` (*table*): Table of wrapped lines.

**Realm**

Client.

**Example Usage**

```lua
-- Wrap text
local function wrapText(text, font, width)
    return lia.util.wrapText(text, font, width)
end

-- Use in a function
local function wrapLongText(text, width)
    local lines = lia.util.wrapText(text, "liaMediumFont", width)
    print("Text wrapped into " .. #lines .. " lines")
    return lines
end
```

---

### drawBlur

**Purpose**

Draws a blur effect.

**Parameters**

* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `width` (*number*): The width.
* `height` (*number*): The height.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw blur effect
local function drawBlur(x, y, width, height)
    lia.util.drawBlur(x, y, width, height)
end

-- Use in a function
local function drawBackgroundBlur()
    lia.util.drawBlur(0, 0, ScrW(), ScrH())
end
```

---

### drawBlackBlur

**Purpose**

Draws a black blur effect.

**Parameters**

* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `width` (*number*): The width.
* `height` (*number*): The height.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw black blur effect
local function drawBlackBlur(x, y, width, height)
    lia.util.drawBlackBlur(x, y, width, height)
end

-- Use in a function
local function drawDarkBackground()
    lia.util.drawBlackBlur(0, 0, ScrW(), ScrH())
end
```

---

### drawBlurAt

**Purpose**

Draws a blur effect at a specific position.

**Parameters**

* `position` (*Vector*): The position to draw at.
* `size` (*Vector*): The size of the blur.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw blur at position
local function drawBlurAt(position, size)
    lia.util.drawBlurAt(position, size)
end

-- Use in a function
local function drawBlurAtEntity(entity)
    local pos = entity:GetPos()
    local size = Vector(100, 100, 100)
    lia.util.drawBlurAt(pos, size)
end
```

---

### requestArguments

**Purpose**

Requests arguments from a client.

**Parameters**

* `client` (*Player*): The client to request from.
* `prompt` (*string*): The prompt text.
* `callback` (*function*): The callback function.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Request arguments from client
local function requestArguments(client, prompt, callback)
    lia.util.requestArguments(client, prompt, callback)
end

-- Use in a function
local function requestPlayerName(client, callback)
    lia.util.requestArguments(client, "Enter player name:", callback)
end
```

---

### CreateTableUI

**Purpose**

Creates a table UI for a client.

**Parameters**

* `client` (*Player*): The client to create for.
* `tableName` (*string*): The table name.
* `data` (*table*): The table data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Create table UI
local function createTableUI(client, tableName, data)
    lia.util.CreateTableUI(client, tableName, data)
end

-- Use in a function
local function createPlayerListUI(client, players)
    lia.util.CreateTableUI(client, "PlayerList", players)
    print("Player list UI created for " .. client:Name())
end
```

---

### openOptionsMenu

**Purpose**

Opens the options menu for a client.

**Parameters**

* `client` (*Player*): The client to open for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Open options menu
local function openOptionsMenu(client)
    lia.util.openOptionsMenu(client)
end

-- Use in a function
local function showOptionsMenu(client)
    lia.util.openOptionsMenu(client)
    print("Options menu opened for " .. client:Name())
end
```