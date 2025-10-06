# Util Library

This page documents the functions for working with utilities and helper functions.

---

## Overview

The util library (`lia.util`) provides a comprehensive system for managing utilities, helper functions, and common operations in the Lilia framework, serving as the foundational utility layer that supports all other framework components with essential functionality. This library handles sophisticated utility management with support for player-related operations including player searching, validation, and management functions that work across different player states and connection statuses. The system features advanced text utilities with support for string manipulation, formatting, validation, and localization that provide consistent text handling throughout the framework. It includes comprehensive rendering utilities with support for 2D and 3D rendering operations, UI element creation, and visual effects that enhance the user interface and gameplay experience. The library provides robust general helper functions with support for mathematical operations, data validation, performance optimization, and debugging tools that improve development efficiency and system reliability. Additional features include integration with Garry's Mod's native functions, cross-platform compatibility utilities, and performance monitoring tools that ensure optimal framework operation across different server configurations and client setups, making it essential for maintaining code quality and providing consistent functionality throughout the entire framework ecosystem.

---



### findPlayersInSphere

**Purpose**

Finds players within a sphere area.

**Parameters**

* `origin` (*Vector*): The center position.
* `radius` (*number*): The sphere radius.

**Returns**

* `players` (*table*): Table of players in the sphere.

**Realm**

Server.

**Example Usage**

```lua
-- Find players in sphere
local function findPlayersInSphere(position, radius)
    return lia.util.findPlayersInSphere(position, radius)
end

-- Use in a function
local function findPlayersNearEntity(entity, radius)
    return lia.util.findPlayersInSphere(entity:GetPos(), radius)
end
```

---

### findPlayersInBox

**Purpose**

Finds players within a box area.

**Parameters**

* `mins` (*Vector*): The minimum bounds of the box.
* `maxs` (*Vector*): The maximum bounds of the box.

**Returns**

* `players` (*table*): Table of players in the box.

**Realm**

Server.

**Example Usage**

```lua
-- Find players in box
local function findPlayersInBox(mins, maxs)
    return lia.util.findPlayersInBox(mins, maxs)
end

-- Use in a function
local function findPlayersInArea(minPos, maxPos)
    return lia.util.findPlayersInBox(minPos, maxPos)
end
```

---

### findPlayer

**Purpose**

Finds a player by name or SteamID.

**Parameters**

* `client` (*Player*): The client calling this function (for notifications).
* `identifier` (*string*): The player identifier.

**Returns**

* `player` (*Player*): The player or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Find player by identifier
local function findPlayer(client, identifier)
    return lia.util.findPlayer(client, identifier)
end

-- Use in a function
local function findPlayerByName(client, name)
    local player = lia.util.findPlayer(client, name)
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

### getBySteamID

**Purpose**

Finds a player by their SteamID, supporting both SteamID and SteamID64 formats. Only returns players who have a character loaded.

**Parameters**

* `steamID` (*string*): The SteamID or SteamID64 to search for.

**Returns**

* `player` (*Player*): The player with the matching SteamID or nil if not found.

**Realm**

Server.

**Example Usage**

```lua
-- Find player by SteamID
local function findPlayerBySteamID(steamID)
    return lia.util.getBySteamID(steamID)
end

-- Use in a function
local function getPlayerBySteamID64(steamID64)
    local player = lia.util.getBySteamID(steamID64)
    if player then
        print("Player found: " .. player:Name())
        return player
    else
        print("Player not found with SteamID64: " .. steamID64)
        return nil
    end
end

-- Find player with SteamID format
local function findPlayerWithSteamID(steamID)
    local player = lia.util.getBySteamID("STEAM_0:1:123456")
    if player and player:getChar() then
        print("Player found with character: " .. player:getChar():getName())
        return player
    end
    return nil
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
* `class` (*string*): The item class.

**Returns**

* `items` (*table*): Table of matching items.

**Realm**

Server.

**Example Usage**

```lua
-- Find player items by class
local function findPlayerItemsByClass(client, class)
    return lia.util.findPlayerItemsByClass(client, class)
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
* `class` (*string*, optional): The entity class to filter by.

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

-- Find player entities by class
local function findPlayerEntitiesByClass(client, class)
    return lia.util.findPlayerEntities(client, class)
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

* `pos` (*Vector*): The position to check.
* `mins` (*Vector*, optional): The minimum bounds. Defaults to Vector(16, 16, 0).
* `maxs` (*Vector*, optional): The maximum bounds. Defaults to mins parameter.
* `filter` (*Entity*, optional): Entity to ignore in collision check.

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

* `pos` (*Vector*): The center position.
* `dist` (*number*): The radius.

**Returns**

* `players` (*table*): Table of players in radius.

**Realm**

Server.

**Example Usage**

```lua
-- Check players in radius
local function playerInRadius(pos, dist)
    return lia.util.playerInRadius(pos, dist)
end

-- Use in a function
local function findNearbyPlayers(pos, dist)
    local players = lia.util.playerInRadius(pos, dist)
    print("Found " .. #players .. " players within " .. dist .. " units")
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

* `materialPath` (*string*): The material path.
* `materialParameters` (*string*, optional): Additional material parameters.

**Returns**

* `material` (*Material*): The material or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get material by name
local function getMaterial(materialPath)
    return lia.util.getMaterial(materialPath)
end

-- Get material with parameters
local function getMaterialWithParams(materialPath, materialParameters)
    return lia.util.getMaterial(materialPath, materialParameters)
end

-- Use in a function
local function loadMaterial(materialPath)
    local material = lia.util.getMaterial(materialPath)
    if material then
        print("Material loaded: " .. materialPath)
        return material
    else
        print("Material not found: " .. materialPath)
        return nil
    end
end
```

---

### findFaction

**Purpose**

Finds a faction by name.

**Parameters**

* `client` (*Player*): The client calling this function (for notifications).
* `name` (*string*): The faction name.

**Returns**

* `faction` (*table*): The faction data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Find faction by name
local function findFaction(client, name)
    return lia.util.findFaction(client, name)
end

-- Use in a function
local function checkFactionExists(client, factionName)
    local faction = lia.util.findFaction(client, factionName)
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
* `title` (*string*): The table title.
* `columns` (*table*): Table column definitions.
* `data` (*table*): The table data.
* `options` (*table*, optional): Table options.
* `characterID` (*number*, optional): Character ID.

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

Finds empty spaces near an entity's position.

**Parameters**

* `entity` (*Entity*): The entity to find space for.
* `filter` (*Entity*, optional): Entity to ignore in collision check.
* `spacing` (*number*, optional): Spacing between search positions. Defaults to 32.
* `size` (*number*, optional): Search radius size. Defaults to 3.
* `height` (*number*, optional): Height requirement. Defaults to 36.
* `tolerance` (*number*, optional): Collision tolerance. Defaults to 5.

**Returns**

* `emptyPositions` (*table*): Table of empty positions sorted by distance.

**Realm**

Server.

**Example Usage**

```lua
-- Find empty spaces
local function findEmptySpaces(entity)
    return lia.util.findEmptySpace(entity)
end

-- Use in a function
local function findSpawnPositions(entity)
    local emptyPositions = lia.util.findEmptySpace(entity)
    if #emptyPositions > 0 then
        print("Found " .. #emptyPositions .. " empty positions")
        return emptyPositions[1] -- Return closest position
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

Draws text with various effects. This is an alias to `lia.derma.drawText`.

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
    lia.util.drawText(text, "liaMediumFont", x, y, color)
end
```

---

### drawTexture

**Purpose**

Draws a texture. This is an alias to `lia.derma.drawSurfaceTexture`.

**Parameters**

* `texture` (*Material*): The texture to draw.
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
* `width` (*number*): The maximum width.
* `font` (*string*, optional): The font to use. Defaults to "liaChatFont".

**Returns**

* `wrappedLines` (*table*): Table of wrapped lines.
* `maxWidth` (*number*): The maximum width of the wrapped text.

**Realm**

Client.

**Example Usage**

```lua
-- Wrap text
local function wrapText(text, width, font)
    return lia.util.wrapText(text, width, font)
end

-- Use in a function
local function wrapLongText(text, width)
    local lines, maxWidth = lia.util.wrapText(text, width, "liaMediumFont")
    print("Text wrapped into " .. #lines .. " lines")
    return lines, maxWidth
end
```

---

### drawBlur

**Purpose**

Draws a blur effect on a panel.

**Parameters**

* `panel` (*Panel*): The panel to draw blur on.
* `amount` (*number*, optional): Blur amount. Defaults to 5.
* `passes` (*number*, optional): Number of blur passes. Defaults to 0.2.
* `alpha` (*number*, optional): Alpha value. Defaults to 255.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw blur effect on panel
local function drawBlur(panel, amount, passes, alpha)
    lia.util.drawBlur(panel, amount, passes, alpha)
end

-- Use in a function
local function drawBackgroundBlur(panel)
    lia.util.drawBlur(panel, 5, 0.2, 255)
end
```

---

### drawBlackBlur

**Purpose**

Draws a black blur effect on a panel.

**Parameters**

* `panel` (*Panel*): The panel to draw blur on.
* `amount` (*number*, optional): Blur amount. Defaults to 6.
* `passes` (*number*, optional): Number of blur passes. Defaults to 5.
* `alpha` (*number*, optional): Alpha value. Defaults to 255.
* `darkAlpha` (*number*, optional): Dark overlay alpha. Defaults to 220.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw black blur effect on panel
local function drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
    lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
end

-- Use in a function
local function drawDarkBackground(panel)
    lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
end
```

---

### drawBlurAt

**Purpose**

Draws a blur effect at a specific position.

**Parameters**

* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `w` (*number*): The width.
* `h` (*number*): The height.
* `amount` (*number*, optional): Blur amount. Defaults to 5.
* `passes` (*number*, optional): Number of blur passes. Defaults to 0.2.
* `alpha` (*number*, optional): Alpha value. Defaults to 255.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw blur at position
local function drawBlurAt(x, y, w, h, amount, passes, alpha)
    lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)
end

-- Use in a function
local function drawBlurAtEntity(entity)
    local pos = entity:GetPos()
    local screenPos = pos:ToScreen()
    lia.util.drawBlurAt(screenPos.x, screenPos.y, 100, 100)
end
```

---

### requestArguments

**Purpose**

Requests arguments from a client. This is an alias to `lia.derma.requestArguments`.

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

* `title` (*string*): The table title.
* `columns` (*table*): Table column definitions.
* `data` (*table*): The table data.
* `options` (*table*, optional): Table options.
* `charID` (*number*, optional): Character ID.

**Returns**

* `frame` (*DFrame*): The created frame.
* `listView` (*liaDListView*): The list view component.

**Realm**

Client.

**Example Usage**

```lua
-- Create table UI
local function createTableUI(title, columns, data, options, charID)
    return lia.util.CreateTableUI(title, columns, data, options, charID)
end

-- Use in a function
local function createPlayerListUI(players)
    local columns = {
        {name = "Name", field = "name"},
        {name = "SteamID", field = "steamid"}
    }
    local frame, listView = lia.util.CreateTableUI("PlayerList", columns, players)
    print("Player list UI created")
    return frame, listView
end
```

---

### openOptionsMenu

**Purpose**

Opens the options menu for a client.

**Parameters**

* `title` (*string*): The menu title.
* `options` (*table*): The options to display.

**Returns**

* `frame` (*DFrame*): The created frame.

**Realm**

Client.

**Example Usage**

```lua
-- Open options menu
local function openOptionsMenu(title, options)
    return lia.util.openOptionsMenu(title, options)
end

-- Use in a function
local function showOptionsMenu()
    local options = {
        {name = "Option 1", callback = function() print("Option 1 clicked") end},
        {name = "Option 2", callback = function() print("Option 2 clicked") end}
    }
    local frame = lia.util.openOptionsMenu("My Menu", options)
    print("Options menu opened")
    return frame
end
```

---

### animateAppearance

**Purpose**

Animates the appearance of a panel with scaling and fading effects.

**Parameters**

* `panel` (*Panel*): The panel to animate.
* `target_w` (*number*): The target width for the animation.
* `target_h` (*number*): The target height for the animation.
* `duration` (*number*, optional): The duration of the animation in seconds.
* `alpha_dur` (*number*, optional): The duration of the alpha transition.
* `callback` (*function*, optional): Function to call when animation completes.
* `scale_factor` (*number*, optional): The initial scale factor for the animation.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic panel appearance animation
local panel = vgui.Create("DPanel", parent)
lia.util.animateAppearance(panel, 300, 200, 0.3, 0.2)

-- Animate with callback
local function onAnimationComplete(panel)
    print("Animation completed!")
    panel:SetVisible(true)
end

lia.util.animateAppearance(myPanel, 400, 300, 0.5, 0.3, onAnimationComplete)

-- Custom scale factor
lia.util.animateAppearance(smallPanel, 200, 100, 0.2, 0.1, nil, 0.5)

-- Use in menu system
local function showMenu()
    local menu = createMainMenu()
    menu:SetVisible(false)
    lia.util.animateAppearance(menu, menu:GetWide(), menu:GetTall(), 0.4, 0.3, function()
        menu:SetVisible(true)
        menu:MakePopup()
    end)
end

-- Animate multiple panels in sequence
local function animatePanelSequence(panels)
    for i, panel in ipairs(panels) do
        timer.Simple((i - 1) * 0.1, function()
            if IsValid(panel) then
                lia.util.animateAppearance(panel, panel:GetWide(), panel:GetTall(), 0.2)
            end
        end)
    end
end
```

---

### approachExp

**Purpose**

Smoothly approaches a target value using exponential interpolation with delta time.

**Parameters**

* `current` (*number*): The current value.
* `target` (*number*): The target value to approach.
* `speed` (*number*): The speed of approach.
* `dt` (*number*): The delta time (usually FrameTime()).

**Returns**

* `newValue` (*number*): The new value after approaching the target.

**Realm**

Shared.

**Example Usage**

```lua
-- Basic exponential approach
local currentValue = 0
local targetValue = 100
local approachSpeed = 5

hook.Add("Think", "ApproachExample", function()
    currentValue = lia.util.approachExp(currentValue, targetValue, approachSpeed, FrameTime())
    print("Current value:", currentValue)
end)

-- Smooth camera movement
local cameraPos = Vector(0, 0, 0)
local targetPos = Vector(100, 50, 20)
local cameraSpeed = 3

local function smoothCameraMovement()
    cameraPos.x = lia.util.approachExp(cameraPos.x, targetPos.x, cameraSpeed, FrameTime())
    cameraPos.y = lia.util.approachExp(cameraPos.y, targetPos.y, cameraSpeed, FrameTime())
    cameraPos.z = lia.util.approachExp(cameraPos.z, targetPos.z, cameraSpeed, FrameTime())
end

-- Smooth health bar filling
local healthBar = {
    currentHealth = 100,
    displayHealth = 100,
    approachSpeed = 8
}

local function updateHealthBar(current, max)
    healthBar.currentHealth = current
end

hook.Add("HUDPaint", "HealthBar", function()
    healthBar.displayHealth = lia.util.approachExp(healthBar.displayHealth, healthBar.currentHealth, healthBar.approachSpeed, FrameTime())
    drawHealthBar(healthBar.displayHealth, 100)
end)

-- Smooth color transitions
local currentColor = Color(255, 255, 255)
local targetColor = Color(255, 0, 0)
local colorSpeed = 2

local function updateColor()
    currentColor.r = lia.util.approachExp(currentColor.r, targetColor.r, colorSpeed, FrameTime())
    currentColor.g = lia.util.approachExp(currentColor.g, targetColor.g, colorSpeed, FrameTime())
    currentColor.b = lia.util.approachExp(currentColor.b, targetColor.b, colorSpeed, FrameTime())
end
```

---

### clampMenuPosition

**Purpose**

Clamps a menu panel position to stay within screen boundaries.

**Parameters**

* `panel` (*Panel*): The panel to clamp the position of.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Clamp menu position
local menu = vgui.Create("DFrame")
menu:SetSize(300, 200)
menu:SetPos(ScrW() - 150, ScrH() - 100) -- Position near bottom-right
lia.util.clampMenuPosition(menu)

-- Use in context menu creation
local function createContextMenu(x, y)
    local menu = lia.derma.dermaMenu()
    menu:SetPos(x, y)
    lia.util.clampMenuPosition(menu)
    return menu
end

-- Clamp after showing animation
local function showMenuAtPosition(x, y)
    local menu = createMenu()
    menu:SetPos(x, y)
    menu:ShowAnimation()

    -- Clamp after animation to ensure it stays on screen
    timer.Simple(0.1, function()
        if IsValid(menu) then
            lia.util.clampMenuPosition(menu)
        end
    end)
end

-- Automatic menu positioning
local function showMenuNearMouse()
    local x, y = input.GetCursorPos()
    local menu = createMenu()
    menu:SetPos(x + 10, y + 10)
    lia.util.clampMenuPosition(menu)
end

-- Clamp multiple panels
local function clampAllMenus()
    local menus = {}
    -- Collect all menu panels
    table.insert(menus, mainMenu)
    table.insert(menus, contextMenu)
    table.insert(menus, dropdownMenu)

    for _, menu in ipairs(menus) do
        if IsValid(menu) then
            lia.util.clampMenuPosition(menu)
        end
    end
end
```

---

### drawGradient

**Purpose**

Draws a gradient rectangle with specified direction and colors.

**Parameters**

* `x` (*number*): The X position to draw at.
* `y` (*number*): The Y position to draw at.
* `w` (*number*): The width of the gradient.
* `h` (*number*): The height of the gradient.
* `direction` (*number*): The gradient direction (1-4: up, down, left, right).
* `color_shadow` (*Color*): The shadow color for the gradient.
* `radius` (*number*, optional): The corner radius for rounded gradients.
* `flags` (*number*, optional): Additional drawing flags.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic gradient drawing
lia.util.drawGradient(0, 0, 200, 100, 1, Color(0, 0, 0, 100))

-- Different gradient directions
local directions = {1, 2, 3, 4} -- up, down, left, right
for i, dir in ipairs(directions) do
    local x = (i - 1) * 50
    lia.util.drawGradient(x, 0, 40, 40, dir, Color(100, 100, 100, 150))
end

-- Gradient with rounded corners
lia.util.drawGradient(10, 10, 180, 80, 2, Color(0, 0, 0, 80), 8)

-- Use in panel painting
local panel = vgui.Create("DPanel")
panel.Paint = function(self, w, h)
    -- Draw background gradient
    lia.util.drawGradient(0, 0, w, h, 2, Color(50, 50, 50, 100))

    -- Draw accent gradient
    lia.util.drawGradient(0, h - 20, w, 20, 1, Color(100, 150, 255, 150))
end

-- Animated gradient
local gradientOffset = 0
hook.Add("HUDPaint", "AnimatedGradient", function()
    gradientOffset = (gradientOffset + 1) % 200
    lia.util.drawGradient(gradientOffset, 100, 100, 50, 3, Color(255, 100, 100, 100))
end)

-- Gradient for UI elements
local function drawGradientButton(x, y, w, h, direction, baseColor)
    local shadowColor = Color(baseColor.r * 0.7, baseColor.g * 0.7, baseColor.b * 0.7, baseColor.a)
    lia.util.drawGradient(x, y, w, h, direction, shadowColor, 4)
end
```

---

### easeInOutCubic

**Purpose**

Applies cubic ease-in-out interpolation to a value between 0 and 1.

**Parameters**

* `t` (*number*): The input value between 0 and 1.

**Returns**

* `easedValue` (*number*): The eased value.

**Realm**

Shared.

**Example Usage**

```lua
-- Basic cubic ease-in-out
local progress = 0.5
local eased = lia.util.easeInOutCubic(progress)
print("Eased value:", eased)

-- Animation using ease-in-out
local animProgress = 0
hook.Add("Think", "CubicAnimation", function()
    animProgress = math.min(animProgress + FrameTime(), 1)
    local easedProgress = lia.util.easeInOutCubic(animProgress)

    -- Apply to position, scale, etc.
    someElement:SetPos(0, easedProgress * 100)
end)

-- Smooth transitions
local function smoothTransition(startValue, endValue, progress)
    local easedProgress = lia.util.easeInOutCubic(progress)
    return startValue + (endValue - startValue) * easedProgress
end

-- Multiple easing curves comparison
local function compareEasing(progress)
    return {
        linear = progress,
        easeInOutCubic = lia.util.easeInOutCubic(progress),
        easeOutCubic = lia.util.easeOutCubic(progress)
    }
end

-- Use in color transitions
local startColor = Color(255, 0, 0)
local endColor = Color(0, 255, 0)

local function getTransitionColor(progress)
    local eased = lia.util.easeInOutCubic(progress)
    return Color(
        Lerp(eased, startColor.r, endColor.r),
        Lerp(eased, startColor.g, endColor.g),
        Lerp(eased, startColor.b, endColor.b)
    )
end

-- Smooth UI animations
local menuSlideProgress = 0
local function slideInMenu()
    menuSlideProgress = math.min(menuSlideProgress + FrameTime() * 2, 1)
    local eased = lia.util.easeInOutCubic(menuSlideProgress)
    menuPanel:SetPos(menuPanel.x - (1 - eased) * menuPanel:GetWide(), menuPanel.y)
end
```

---

### easeOutCubic

**Purpose**

Applies cubic ease-out interpolation to a value between 0 and 1.

**Parameters**

* `t` (*number*): The input value between 0 and 1.

**Returns**

* `easedValue` (*number*): The eased value.

**Realm**

Shared.

**Example Usage**

```lua
-- Basic cubic ease-out
local progress = 0.7
local eased = lia.util.easeOutCubic(progress)
print("Eased value:", eased)

-- Animation with ease-out
local animTime = 0
hook.Add("Think", "EaseOutAnimation", function()
    animTime = math.min(animTime + FrameTime(), 1)
    local easedTime = lia.util.easeOutCubic(animTime)

    -- Apply easing to movement
    object:SetPos(Lerp(easedTime, startPos, endPos))
end)

-- Bouncing effect
local bounceProgress = 0
local function createBounceEffect()
    bounceProgress = (bounceProgress + FrameTime() * 3) % (math.pi * 2)
    local eased = lia.util.easeOutCubic(math.abs(math.sin(bounceProgress)))
    element:SetScale(1 + eased * 0.2)
end

-- Smooth deceleration
local function decelerateMovement(currentSpeed, targetSpeed, deltaTime)
    local speedDiff = targetSpeed - currentSpeed
    local deceleration = 5
    local newSpeed = currentSpeed + speedDiff * lia.util.easeOutCubic(deltaTime * deceleration)
    return newSpeed
end

-- Camera easing
local cameraTarget = Vector(100, 100, 50)
local cameraCurrent = Vector(0, 0, 0)

local function smoothCameraMovement()
    local distance = cameraTarget - cameraCurrent
    local moveSpeed = 2
    local easedFactor = lia.util.easeOutCubic(FrameTime() * moveSpeed)

    cameraCurrent = cameraCurrent + distance * easedFactor
end

-- UI element reveal
local revealProgress = 0
local function revealElement(element)
    revealProgress = math.min(revealProgress + FrameTime() * 2, 1)
    local eased = lia.util.easeOutCubic(revealProgress)
    element:SetAlpha(eased * 255)
    element:SetSize(element.targetWidth * eased, element.targetHeight)
end
```

---

### drawEntText

**Purpose**

Draws floating text above entities with smooth fade-in/fade-out effects based on distance from the player's view. The text appears as a styled tooltip with background blur and theme colors.

**Parameters**

* `ent` (*Entity*): The entity to draw text above.
* `text` (*string*): The text to display.
* `posY` (*number*, optional): Vertical offset for the text position.
* `alphaOverride` (*number*, optional): Override the alpha fade value (0-1 or 0-255).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic entity text drawing
local function drawEntityName(entity)
    lia.util.drawEntText(entity, entity:GetClass())
end

-- Draw text with custom position offset
lia.util.drawEntText(myEntity, "Important Item", 20)

-- Draw text with alpha override
lia.util.drawEntText(doorEntity, "Locked Door", 0, 0.8)

-- Use in entity think hook
hook.Add("Think", "EntityLabels", function()
    for _, entity in ipairs(ents.FindByClass("prop_*")) do
        if entity:GetModel() == "models/props_c17/furnitureStove001a.mdl" then
            lia.util.drawEntText(entity, "Stove")
        end
    end
end)

-- Draw player names above their heads
hook.Add("PostPlayerDraw", "PlayerNames", function(player)
    if player ~= LocalPlayer() and player:Alive() then
        lia.util.drawEntText(player, player:Name(), 10)
    end
end)

-- Draw health above NPCs
hook.Add("PostDrawOpaqueRenderables", "NPCLabels", function()
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:Health() > 0 then
            local healthText = "NPC: " .. npc:Health() .. " HP"
            lia.util.drawEntText(npc, healthText, 15)
        end
    end
end)

-- Draw item information
local function drawItemInfo(itemEntity)
    if itemEntity:isItem() then
        local itemName = itemEntity:getNetVar("name", "Unknown Item")
        lia.util.drawEntText(itemEntity, itemName, 0, 200)
    end
end

-- Conditional text display
local function drawConditionalEntityText(entity, condition, text, offset)
    if condition and IsValid(entity) then
        lia.util.drawEntText(entity, text, offset or 0)
    end
end