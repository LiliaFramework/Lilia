# Utility Library

Common operations and helper functions for the Lilia framework.

---

## Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

### findPlayersInBox

**Purpose**

Find all players within a specified 3D box area

**When Called**

When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

**Parameters**

* `mins` (*unknown*): Vector: The minimum corner coordinates of the box
* `mins` (*Vector*): The minimum corner coordinates of the box
* `maxs` (*unknown*): Vector: The maximum corner coordinates of the box
* `maxs` (*Vector*): The maximum corner coordinates of the box

**Returns**

* Table of player entities found within the box area

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find players in a small area around a position
local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))
```

---

### getBySteamID

**Purpose**

Find a player by their Steam ID or Steam ID 64

**When Called**

When you need to locate a specific player using their Steam identification for operations like bans, whitelists, or data retrieval

**Parameters**

* `steamID` (*unknown*): String: The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for
* `steamID` (*String*): The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for

**Returns**

* Player entity if found with a valid character, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find player by Steam ID
local player = lia.util.getBySteamID("STEAM_0:0:12345678")
```

---

### findPlayersInSphere

**Purpose**

Find all players within a specified spherical radius from a center point

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or notifications

**Parameters**

* `origin` (*unknown*): Vector: The center point of the sphere
* `origin` (*Vector*): The center point of the sphere
* `radius` (*unknown*): Number: The radius of the sphere in units
* `radius` (*Number*): The radius of the sphere in units

**Returns**

* Table of player entities found within the spherical area

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find players within 500 units of a position
local nearbyPlayers = lia.util.findPlayersInSphere(playerPos, 500)
```

---

### findPlayer

**Purpose**

Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

**When Called**

When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

**Parameters**

* `client` (*unknown*): Player: The player requesting the search (for notifications and special selectors)
* `client` (*Player*): The player requesting the search (for notifications and special selectors)
* `identifier` (*unknown*): String: The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)
* `identifier` (*String*): The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)

**Returns**

* Player entity if found, nil otherwise with appropriate error notifications

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find player by partial name
local targetPlayer = lia.util.findPlayer(client, "John")
```

---

### findPlayerItems

**Purpose**

Find all items created by a specific player in the world

**When Called**

When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

**Parameters**

* `client` (*unknown*): Player: The player whose created items should be found
* `client` (*Player*): The player whose created items should be found

**Returns**

* Table of item entities created by the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find all items dropped by a player
local playerItems = lia.util.findPlayerItems(somePlayer)
```

---

### findPlayerItemsByClass

**Purpose**

Find all items of a specific class created by a particular player

**When Called**

When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

**Parameters**

* `client` (*unknown*): Player: The player whose created items should be found
* `client` (*Player*): The player whose created items should be found
* `class` (*unknown*): String: The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")
* `class` (*String*): The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")

**Returns**

* Table of item entities of the specified class created by the player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find all weapons dropped by a player
local droppedWeapons = lia.util.findPlayerItemsByClass(player, "weapon_ar2")
```

---

### findPlayerEntities

**Purpose**

Find all entities created by or associated with a specific player, optionally filtered by class

**When Called**

When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

**Parameters**

* `client` (*unknown*): Player: The player whose entities should be found
* `client` (*Player*): The player whose entities should be found
* `class` (*unknown*): String: Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")
* `class` (*String*): Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")

**Returns**

* Table of entities created by or associated with the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find all entities created by a player
local playerEntities = lia.util.findPlayerEntities(somePlayer)
```

---

### stringMatches

**Purpose**

Check if two strings match using flexible comparison methods including case-insensitive and partial matching

**When Called**

When you need to compare strings with flexible matching for search functionality, name validation, or text processing

**Parameters**

* `a` (*unknown*): String: The first string to compare
* `a` (*String*): The first string to compare
* `b` (*unknown*): String: The second string to compare (the search pattern)
* `b` (*String*): The second string to compare (the search pattern)

**Returns**

* Boolean indicating if the strings match using any of the comparison methods

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if strings are equal (case-insensitive)
local matches = lia.util.stringMatches("Hello", "hello")
```

---

### getAdmins

**Purpose**

Get a list of all currently online administrators/staff members

**When Called**

When you need to identify staff members for admin-only operations, notifications, or privilege checks

**Returns**

* Table of player entities that are currently staff members

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get all online admins
local admins = lia.util.getAdmins()
```

---

### findPlayerBySteamID64

**Purpose**

Find a player by their Steam ID 64, converting it to Steam ID format first

**When Called**

When you need to locate a player using their Steam ID 64 for database operations or external integrations

**Parameters**

* `SteamID64` (*unknown*): String: The Steam ID 64 to search for
* `SteamID64` (*String*): The Steam ID 64 to search for

**Returns**

* Player entity if found, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find player by Steam ID 64
local player = lia.util.findPlayerBySteamID64("76561198012345678")
```

---

### findPlayerBySteamID

**Purpose**

Find a player by their Steam ID

**When Called**

When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

**Parameters**

* `SteamID` (*unknown*): String: The Steam ID to search for (STEAM_0:0:123456 format)
* `SteamID` (*String*): The Steam ID to search for (STEAM_0:0:123456 format)

**Returns**

* Player entity if found, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find player by Steam ID
local player = lia.util.findPlayerBySteamID("STEAM_0:0:12345678")
```

---

### canFit

**Purpose**

Check if an entity can fit at a specific position without colliding with solid objects

**When Called**

When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

**Parameters**

* `pos` (*unknown*): Vector: The position to check for entity placement
* `pos` (*Vector*): The position to check for entity placement
* `mins` (*unknown*): Vector: Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
* `mins` (*Vector*): Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
* `maxs` (*unknown*): Vector: Optional maximum bounding box coordinates (defaults to mins value)
* `maxs` (*Vector*): Optional maximum bounding box coordinates (defaults to mins value)
* `filter` (*unknown*): Entity/Table: Optional entity or table of entities to ignore in collision detection
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection

**Returns**

* Boolean indicating if the position is clear (true) or obstructed (false)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player can fit at position
local canTeleport = lia.util.canFit(targetPosition)
```

---

### playerInRadius

**Purpose**

Find all players within a specified radius from a center position

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or area management

**Parameters**

* `pos` (*unknown*): Vector: The center position to check from
* `pos` (*Vector*): The center position to check from
* `dist` (*unknown*): Number: The radius distance to check within
* `dist` (*Number*): The radius distance to check within

**Returns**

* Table of player entities found within the specified radius

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find players within 100 units
local nearbyPlayers = lia.util.playerInRadius(playerPos, 100)
```

---

### formatStringNamed

**Purpose**

Format a string using named placeholders with flexible argument handling

**When Called**

When you need to format strings with named parameters for localization, templating, or dynamic text generation

**Parameters**

* `format` (*unknown*): String: The format string containing {placeholder} patterns
* `format` (*String*): The format string containing {placeholder} patterns
* `...` (*Mixed*): Either a table with named keys or individual arguments to replace placeholders

**Returns**

* String with placeholders replaced by provided values

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Format string with individual arguments
local message = lia.util.formatStringNamed("Hello {name}!", "John")
```

---

### getMaterial

**Purpose**

Get a cached material object from a file path, creating it if it doesn't exist

**When Called**

When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

**Parameters**

* `materialPath` (*unknown*): String: The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialPath` (*String*): The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialParameters` (*unknown*): String: Optional parameters for material creation
* `materialParameters` (*String*): Optional parameters for material creation

**Returns**

* IMaterial object for the specified material path

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a cached material
local blurMaterial = lia.util.getMaterial("pp/blurscreen")
```

---

### findFaction

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*unknown*): Player: The player requesting the faction (for error notifications)
* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*unknown*): String: The faction name or unique ID to search for
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```

---

### lia.SoundDuration

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*unknown*): Player: The player requesting the faction (for error notifications)
* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*unknown*): String: The faction name or unique ID to search for
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```

---

### generateRandomName

**Purpose**

Generate a random full name by combining first and last names from provided or default lists

**When Called**

When you need to create random character names for NPCs, testing, or procedural content generation

**Parameters**

* `firstNames` (*unknown*): Table: Optional table of first names to choose from
* `firstNames` (*Table*): Optional table of first names to choose from
* `lastNames` (*unknown*): Table: Optional table of last names to choose from
* `lastNames` (*Table*): Optional table of last names to choose from

**Returns**

* String containing a randomly generated full name (FirstName LastName)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Generate a random name using defaults
local randomName = lia.util.generateRandomName()
```

---

### sendTableUI

**Purpose**

Send a table-based user interface to a specific client for displaying data in a structured format

**When Called**

When you need to display tabular data to a player, such as inventories, player lists, or administrative information

**Parameters**

* `client` (*unknown*): Player: The player to send the table UI to
* `client` (*Player*): The player to send the table UI to
* `title` (*unknown*): String: The title of the table window
* `title` (*String*): The title of the table window
* `columns` (*unknown*): Table: Array of column definitions with name, width, and other properties
* `columns` (*Table*): Array of column definitions with name, width, and other properties
* `data` (*unknown*): Table: Array of row data to display in the table
* `data` (*Table*): Array of row data to display in the table
* `options` (*unknown*): Table: Optional configuration options for the table UI
* `options` (*Table*): Optional configuration options for the table UI
* `characterID` (*unknown*): Number: Optional character ID for character-specific data
* `characterID` (*Number*): Optional character ID for character-specific data

**Returns**

* Nothing (sends network message to client)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send basic player list
local columns = {
{name = "Name", width = 150},
{name = "Steam ID", width = 200}
}
local players = player.GetAll()
local data = {}
for _, ply in ipairs(players) do
data[#data + 1] = {ply:Name(), ply:SteamID()}
end
lia.util.sendTableUI(client, "Player List", columns, data)
```

---

### findEmptySpace

**Purpose**

Find empty spaces around an entity for spawning or placement purposes

**When Called**

When you need to find valid locations to spawn entities, NPCs, or items around a central position

**Parameters**

* `entity` (*unknown*): Entity: The central entity to search around
* `entity` (*Entity*): The central entity to search around
* `filter` (*unknown*): Entity/Table: Optional entity or table of entities to ignore in collision detection
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection
* `spacing` (*unknown*): Number: Distance between each tested position (default: 32)
* `spacing` (*Number*): Distance between each tested position (default: 32)
* `size` (*unknown*): Number: Grid size to search in (default: 3, meaning -3 to +3 in both x and y)
* `size` (*Number*): Grid size to search in (default: 3, meaning -3 to +3 in both x and y)
* `height` (*unknown*): Number: Height of the area to check for collisions (default: 36)
* `height` (*Number*): Height of the area to check for collisions (default: 36)
* `tolerance` (*unknown*): Number: Additional clearance above ground (default: 5)
* `tolerance` (*Number*): Additional clearance above ground (default: 5)

**Returns**

* Table of valid Vector positions sorted by distance from the entity

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Find nearby empty spaces
local emptySpaces = lia.util.findEmptySpace(someEntity)
```

---

### animateAppearance

**Purpose**

Animate a panel's appearance with scaling, positioning, and alpha transitions

**When Called**

When you need to create smooth entrance animations for UI panels, menus, or dialog boxes

**Parameters**

* `panel` (*unknown*): Panel: The DPanel to animate
* `panel` (*Panel*): The DPanel to animate
* `target_w` (*unknown*): Number: Target width for the animation
* `target_w` (*Number*): Target width for the animation
* `target_h` (*unknown*): Number: Target height for the animation
* `target_h` (*Number*): Target height for the animation
* `duration` (*unknown*): Number: Duration of size/position animation in seconds (default: 0.18)
* `duration` (*Number*): Duration of size/position animation in seconds (default: 0.18)
* `alpha_dur` (*unknown*): Number: Duration of alpha animation in seconds (default: same as duration)
* `alpha_dur` (*Number*): Duration of alpha animation in seconds (default: same as duration)
* `callback` (*unknown*): Function: Optional callback function to execute when animation completes
* `callback` (*Function*): Optional callback function to execute when animation completes
* `scale_factor` (*unknown*): Number: Scale factor for initial size (default: 0.8)
* `scale_factor` (*Number*): Scale factor for initial size (default: 0.8)

**Returns**

* Nothing (modifies panel directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Basic panel appearance animation
local panel = vgui.Create("DPanel")
panel:SetSize(200, 100)
lia.util.animateAppearance(panel, 200, 100)
```

---

### clampMenuPosition

**Purpose**

Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

**When Called**

When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

**Parameters**

* `panel` (*unknown*): Panel: The DPanel whose position should be clamped
* `panel` (*Panel*): The DPanel whose position should be clamped

**Returns**

* Nothing (modifies panel position directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Keep panel within screen bounds
local panel = vgui.Create("DPanel")
panel:SetPos(ScrW() + 100, ScrH() + 50) -- Off-screen position
lia.util.clampMenuPosition(panel) -- Will move panel back on screen
```

---

### drawGradient

**Purpose**

Draw a gradient background using predefined gradient materials

**When Called**

When you need to create gradient backgrounds for UI elements, panels, or visual effects

**Parameters**

* `_x` (*unknown*): Number: X position to draw the gradient
* `_x` (*Number*): X position to draw the gradient
* `_y` (*unknown*): Number: Y position to draw the gradient
* `_y` (*Number*): Y position to draw the gradient
* `_w` (*unknown*): Number: Width of the gradient area
* `_w` (*Number*): Width of the gradient area
* `_h` (*unknown*): Number: Height of the gradient area
* `_h` (*Number*): Height of the gradient area
* `direction` (*unknown*): Number: Gradient direction (1=up, 2=down, 3=left, 4=right)
* `direction` (*Number*): Gradient direction (1=up, 2=down, 3=left, 4=right)
* `color_shadow` (*unknown*): Color: Color for the gradient shadow effect
* `color_shadow` (*Color*): Color for the gradient shadow effect
* `radius` (*unknown*): Number: Corner radius for rounded gradients (default: 0)
* `radius` (*Number*): Corner radius for rounded gradients (default: 0)
* `flags` (*unknown*): Number: Material flags for rendering
* `flags` (*Number*): Material flags for rendering

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Draw a basic gradient background
lia.util.drawGradient(100, 100, 200, 150, 2, Color(0, 0, 0, 150))
```

---

### wrapText

**Purpose**

Wrap text to fit within a specified width, breaking it into multiple lines

**When Called**

When you need to display text that might be too long for a UI element, ensuring it wraps properly

**Parameters**

* `text` (*unknown*): String: The text to wrap
* `text` (*String*): The text to wrap
* `width` (*unknown*): Number: Maximum width in pixels for the text
* `width` (*Number*): Maximum width in pixels for the text
* `font` (*unknown*): String: Font to use for text measurement (default: "LiliaFont.16")
* `font` (*String*): Font to use for text measurement (default: "LiliaFont.16")

**Returns**

* Table of wrapped text lines, Number: Maximum width of any line

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Wrap text to fit in a label
local lines, maxWidth = lia.util.wrapText("This is a long text that needs wrapping", 200)
```

---

### drawBlur

**Purpose**

Draw a blur effect behind a panel using screen-space blurring

**When Called**

When you need to create a blurred background effect for UI elements like menus or dialogs

**Parameters**

* `panel` (*unknown*): Panel: The panel to draw blur behind
* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*unknown*): Number: Intensity of the blur effect (default: 5)
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `_` (*unknown*): Any: Unused parameter (legacy)
* `_` (*Any*): Unused parameter (legacy)
* `alpha` (*unknown*): Number: Alpha transparency of the blur effect (default: 255)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add basic blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlur(panel, 5, nil, 200)
```

---

### drawBlackBlur

**Purpose**

Draw a black blur effect with enhanced darkness behind a panel

**When Called**

When you need to create a darker, more opaque blurred background effect for UI elements

**Parameters**

* `panel` (*unknown*): Panel: The panel to draw blur behind
* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*unknown*): Number: Intensity of the blur effect (default: 6)
* `amount` (*Number*): Intensity of the blur effect (default: 6)
* `passes` (*unknown*): Number: Number of blur passes for quality (default: 5, minimum: 1)
* `passes` (*Number*): Number of blur passes for quality (default: 5, minimum: 1)
* `alpha` (*unknown*): Number: Alpha transparency of the blur effect (default: 255)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)
* `darkAlpha` (*unknown*): Number: Alpha transparency of the dark overlay (default: 220)
* `darkAlpha` (*Number*): Alpha transparency of the dark overlay (default: 220)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add dark blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
```

---

### drawBlurAt

**Purpose**

Draw a blur effect at specific screen coordinates

**When Called**

When you need to apply blur effects to specific screen areas for HUD elements or overlays

**Parameters**

* `x` (*unknown*): Number: X position to draw the blur
* `x` (*Number*): X position to draw the blur
* `y` (*unknown*): Number: Y position to draw the blur
* `y` (*Number*): Y position to draw the blur
* `w` (*unknown*): Number: Width of the blur area
* `w` (*Number*): Width of the blur area
* `h` (*unknown*): Number: Height of the blur area
* `h` (*Number*): Height of the blur area
* `amount` (*unknown*): Number: Intensity of the blur effect (default: 5)
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `passes` (*unknown*): Number: Number of blur passes (default: 0.2)
* `passes` (*Number*): Number of blur passes (default: 0.2)
* `alpha` (*unknown*): Number: Alpha transparency of the blur effect (default: 255)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Blur a specific screen area
lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)
```

---

### createTableUI

**Purpose**

Create a complete table-based UI window for displaying data with interactive features

**When Called**

When you need to display tabular data with sorting, actions, and interactive options

**Parameters**

* `title` (*unknown*): String: Title for the table window
* `title` (*String*): Title for the table window
* `columns` (*unknown*): Table: Array of column definitions
* `columns` (*Table*): Array of column definitions
* `data` (*unknown*): Table: Array of row data to display
* `data` (*Table*): Array of row data to display
* `options` (*unknown*): Table: Optional action buttons and configurations
* `options` (*Table*): Optional action buttons and configurations
* `charID` (*unknown*): Number: Character ID for character-specific data
* `charID` (*Number*): Character ID for character-specific data

**Returns**

* Frame, ListView: The created frame and list view objects

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Create basic table UI
local frame, listView = lia.util.createTableUI("Player List", columns, playerData)
```

---

### openOptionsMenu

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*unknown*): String: Title for the options menu
* `title` (*String*): Title for the options menu
* `options` (*unknown*): Table: Array of option objects or key-value pairs with name and callback properties
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

**Returns**

* Frame: The created options menu frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Create basic options menu
local frame = lia.util.openOptionsMenu("Choose Action", {
{name = "Option 1", callback = function() print("Option 1 selected") end},
{name = "Option 2", callback = function() print("Option 2 selected") end}
})
```

---

### drawEntText

**Purpose**

Draw floating text above an entity with distance-based fade effects

**When Called**

When you need to display information or labels above entities in the 3D world

**Parameters**

* `ent` (*unknown*): Entity: The entity to draw text above
* `ent` (*Entity*): The entity to draw text above
* `text` (*unknown*): String: The text to display
* `text` (*String*): The text to display
* `posY` (*unknown*): Number: Vertical offset for text positioning (default: 0)
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*unknown*): Number: Optional alpha override for manual control
* `alphaOverride` (*Number*): Optional alpha override for manual control

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Draw text above an entity
lia.util.drawEntText(someEntity, "Important Item")
```

---

### drawLookText

**Purpose**

Draw floating text at the player's look position with distance-based fade effects

**When Called**

When you need to display contextual information at the location the player is looking at

**Parameters**

* `text` (*unknown*): String: The text to display
* `text` (*String*): The text to display
* `posY` (*unknown*): Number: Vertical offset for text positioning (default: 0)
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*unknown*): Number: Optional alpha override for manual control
* `alphaOverride` (*Number*): Optional alpha override for manual control
* `maxDist` (*unknown*): Number: Maximum distance to display text (default: 380)
* `maxDist` (*Number*): Maximum distance to display text (default: 380)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Draw text where player is looking
lia.util.drawLookText("Target Location")
```

---

