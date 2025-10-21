# Utility Library

Common operations and helper functions for the Lilia framework.

---

## Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

### lia.util.findPlayersInBox

**Purpose**

Find all players within a specified 3D box area

**When Called**

When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

**Parameters**

* `mins` (*Vector*): The minimum corner coordinates of the box
* `maxs` (*Vector*): The maximum corner coordinates of the box

**Returns**

* Table of player entities found within the box area

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find players in a small area around a position
local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))
```
```

---

### lia.util.getBySteamID

**Purpose**

Find a player by their Steam ID or Steam ID 64

**When Called**

When you need to locate a specific player using their Steam identification for operations like bans, whitelists, or data retrieval

**Parameters**

* `steamID` (*String*): The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for

**Returns**

* Player entity if found with a valid character, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by Steam ID
local player = lia.util.getBySteamID("STEAM_0:0:12345678")
```
```

---

### lia.util.findPlayersInSphere

**Purpose**

Find all players within a specified spherical radius from a center point

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or notifications

**Parameters**

* `origin` (*Vector*): The center point of the sphere
* `radius` (*Number*): The radius of the sphere in units

**Returns**

* Table of player entities found within the spherical area

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find players within 500 units of a position
local nearbyPlayers = lia.util.findPlayersInSphere(playerPos, 500)
```
```

---

### lia.selectPlayer

**Purpose**

Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

**When Called**

When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

**Parameters**

* `client` (*Player*): The player requesting the search (for notifications and special selectors)
* `identifier` (*String*): The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)

**Returns**

* Player entity if found, nil otherwise with appropriate error notifications

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by partial name
local targetPlayer = lia.util.findPlayer(client, "John")
```
```

---

### lia.util.findPlayer

**Purpose**

Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

**When Called**

When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

**Parameters**

* `client` (*Player*): The player requesting the search (for notifications and special selectors)
* `identifier` (*String*): The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)

**Returns**

* Player entity if found, nil otherwise with appropriate error notifications

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by partial name
local targetPlayer = lia.util.findPlayer(client, "John")
```
```

---

### lia.managePlayerItems

**Purpose**

Find all items created by a specific player in the world

**When Called**

When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

**Parameters**

* `client` (*Player*): The player whose created items should be found

**Returns**

* Table of item entities created by the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all items dropped by a player
local playerItems = lia.util.findPlayerItems(somePlayer)
```
```

---

### lia.util.findPlayerItems

**Purpose**

Find all items created by a specific player in the world

**When Called**

When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

**Parameters**

* `client` (*Player*): The player whose created items should be found

**Returns**

* Table of item entities created by the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all items dropped by a player
local playerItems = lia.util.findPlayerItems(somePlayer)
```
```

---

### lia.cleanupPlayerItems

**Purpose**

Find all items of a specific class created by a particular player

**When Called**

When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

**Parameters**

* `client` (*Player*): The player whose created items should be found
* `class` (*String*): The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")

**Returns**

* Table of item entities of the specified class created by the player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all weapons dropped by a player
local droppedWeapons = lia.util.findPlayerItemsByClass(player, "weapon_ar2")
```
```

---

### lia.util.findPlayerItemsByClass

**Purpose**

Find all items of a specific class created by a particular player

**When Called**

When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

**Parameters**

* `client` (*Player*): The player whose created items should be found
* `class` (*String*): The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")

**Returns**

* Table of item entities of the specified class created by the player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all weapons dropped by a player
local droppedWeapons = lia.util.findPlayerItemsByClass(player, "weapon_ar2")
```
```

---

### lia.managePlayerEntities

**Purpose**

Find all entities created by or associated with a specific player, optionally filtered by class

**When Called**

When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

**Parameters**

* `client` (*Player*): The player whose entities should be found
* `class` (*String*): Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")

**Returns**

* Table of entities created by or associated with the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all entities created by a player
local playerEntities = lia.util.findPlayerEntities(somePlayer)
```
```

---

### lia.util.findPlayerEntities

**Purpose**

Find all entities created by or associated with a specific player, optionally filtered by class

**When Called**

When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

**Parameters**

* `client` (*Player*): The player whose entities should be found
* `class` (*String*): Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")

**Returns**

* Table of entities created by or associated with the specified player

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find all entities created by a player
local playerEntities = lia.util.findPlayerEntities(somePlayer)
```
```

---

### lia.playerNameMatches

**Purpose**

Check if two strings match using flexible comparison methods including case-insensitive and partial matching

**When Called**

When you need to compare strings with flexible matching for search functionality, name validation, or text processing

**Parameters**

* `a` (*String*): The first string to compare
* `b` (*String*): The second string to compare (the search pattern)

**Returns**

* Boolean indicating if the strings match using any of the comparison methods

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if strings are equal (case-insensitive)
local matches = lia.util.stringMatches("Hello", "hello")
```
```

---

### lia.advancedStringSearch

**Purpose**

Check if two strings match using flexible comparison methods including case-insensitive and partial matching

**When Called**

When you need to compare strings with flexible matching for search functionality, name validation, or text processing

**Parameters**

* `a` (*String*): The first string to compare
* `b` (*String*): The second string to compare (the search pattern)

**Returns**

* Boolean indicating if the strings match using any of the comparison methods

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if strings are equal (case-insensitive)
local matches = lia.util.stringMatches("Hello", "hello")
```
```

---

### lia.util.stringMatches

**Purpose**

Check if two strings match using flexible comparison methods including case-insensitive and partial matching

**When Called**

When you need to compare strings with flexible matching for search functionality, name validation, or text processing

**Parameters**

* `a` (*String*): The first string to compare
* `b` (*String*): The second string to compare (the search pattern)

**Returns**

* Boolean indicating if the strings match using any of the comparison methods

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if strings are equal (case-insensitive)
local matches = lia.util.stringMatches("Hello", "hello")
```
```

---

### lia.getActiveAdmins

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
```lua
-- Simple: Get all online admins
local admins = lia.util.getAdmins()
```
```

---

### lia.util.getAdmins

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
```lua
-- Simple: Get all online admins
local admins = lia.util.getAdmins()
```
```

---

### lia.util.findPlayerBySteamID64

**Purpose**

Find a player by their Steam ID 64, converting it to Steam ID format first

**When Called**

When you need to locate a player using their Steam ID 64 for database operations or external integrations

**Parameters**

* `SteamID64` (*String*): The Steam ID 64 to search for

**Returns**

* Player entity if found, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by Steam ID 64
local player = lia.util.findPlayerBySteamID64("76561198012345678")
```
```

---

### lia.trackPlayerActivity

**Purpose**

Find a player by their Steam ID

**When Called**

When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

**Parameters**

* `SteamID` (*String*): The Steam ID to search for (STEAM_0:0:123456 format)

**Returns**

* Player entity if found, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by Steam ID
local player = lia.util.findPlayerBySteamID("STEAM_0:0:12345678")
```
```

---

### lia.util.findPlayerBySteamID

**Purpose**

Find a player by their Steam ID

**When Called**

When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

**Parameters**

* `SteamID` (*String*): The Steam ID to search for (STEAM_0:0:123456 format)

**Returns**

* Player entity if found, nil otherwise

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find player by Steam ID
local player = lia.util.findPlayerBySteamID("STEAM_0:0:12345678")
```
```

---

### lia.findValidPlacement

**Purpose**

Check if an entity can fit at a specific position without colliding with solid objects

**When Called**

When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

**Parameters**

* `pos` (*Vector*): The position to check for entity placement
* `mins` (*Vector*): Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
* `maxs` (*Vector*): Optional maximum bounding box coordinates (defaults to mins value)
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection

**Returns**

* Boolean indicating if the position is clear (true) or obstructed (false)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if player can fit at position
local canTeleport = lia.util.canFit(targetPosition)
```
```

---

### lia.util.canFit

**Purpose**

Check if an entity can fit at a specific position without colliding with solid objects

**When Called**

When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

**Parameters**

* `pos` (*Vector*): The position to check for entity placement
* `mins` (*Vector*): Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
* `maxs` (*Vector*): Optional maximum bounding box coordinates (defaults to mins value)
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection

**Returns**

* Boolean indicating if the position is clear (true) or obstructed (false)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if player can fit at position
local canTeleport = lia.util.canFit(targetPosition)
```
```

---

### lia.util.playerInRadius

**Purpose**

Find all players within a specified radius from a center position

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or area management

**Parameters**

* `pos` (*Vector*): The center position to check from
* `dist` (*Number*): The radius distance to check within

**Returns**

* Table of player entities found within the specified radius

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find players within 100 units
local nearbyPlayers = lia.util.playerInRadius(playerPos, 100)
```
```

---

### lia.formatPlayerInfo

**Purpose**

Format a string using named placeholders with flexible argument handling

**When Called**

When you need to format strings with named parameters for localization, templating, or dynamic text generation

**Parameters**

* `format` (*String*): The format string containing {placeholder} patterns
* `...` (*Mixed*): Either a table with named keys or individual arguments to replace placeholders

**Returns**

* String with placeholders replaced by provided values

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Format string with individual arguments
local message = lia.util.formatStringNamed("Hello {name}!", "John")
```
```

---

### lia.util.formatStringNamed

**Purpose**

Format a string using named placeholders with flexible argument handling

**When Called**

When you need to format strings with named parameters for localization, templating, or dynamic text generation

**Parameters**

* `format` (*String*): The format string containing {placeholder} patterns
* `...` (*Mixed*): Either a table with named keys or individual arguments to replace placeholders

**Returns**

* String with placeholders replaced by provided values

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Format string with individual arguments
local message = lia.util.formatStringNamed("Hello {name}!", "John")
```
```

---

### lia.preloadMaterials

**Purpose**

Get a cached material object from a file path, creating it if it doesn't exist

**When Called**

When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

**Parameters**

* `materialPath` (*String*): The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialParameters` (*String*): Optional parameters for material creation

**Returns**

* IMaterial object for the specified material path

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a cached material
local blurMaterial = lia.util.getMaterial("pp/blurscreen")
```
```

---

### lia.drawMaterialEffect

**Purpose**

Get a cached material object from a file path, creating it if it doesn't exist

**When Called**

When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

**Parameters**

* `materialPath` (*String*): The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialParameters` (*String*): Optional parameters for material creation

**Returns**

* IMaterial object for the specified material path

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a cached material
local blurMaterial = lia.util.getMaterial("pp/blurscreen")
```
```

---

### lia.util.getMaterial

**Purpose**

Get a cached material object from a file path, creating it if it doesn't exist

**When Called**

When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

**Parameters**

* `materialPath` (*String*): The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialParameters` (*String*): Optional parameters for material creation

**Returns**

* IMaterial object for the specified material path

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Get a cached material
local blurMaterial = lia.util.getMaterial("pp/blurscreen")
```
```

---

### lia.managePlayerFaction

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.util.findFaction

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.GetSoundPath

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.f_IsWAV

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.f_SampleDepth

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.f_SampleRate

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.f_Channels

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.f_Duration

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.SoundDuration

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

**Returns**

* Faction table if found, nil otherwise with error notification

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find faction by name
local faction = lia.util.findFaction(player, "Security")
```
```

---

### lia.generateCulturalName

**Purpose**

Generate a random full name by combining first and last names from provided or default lists

**When Called**

When you need to create random character names for NPCs, testing, or procedural content generation

**Parameters**

* `firstNames` (*Table*): Optional table of first names to choose from
* `lastNames` (*Table*): Optional table of last names to choose from

**Returns**

* String containing a randomly generated full name (FirstName LastName)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Generate a random name using defaults
local randomName = lia.util.generateRandomName()
```
```

---

### lia.util.generateRandomName

**Purpose**

Generate a random full name by combining first and last names from provided or default lists

**When Called**

When you need to create random character names for NPCs, testing, or procedural content generation

**Parameters**

* `firstNames` (*Table*): Optional table of first names to choose from
* `lastNames` (*Table*): Optional table of last names to choose from

**Returns**

* String containing a randomly generated full name (FirstName LastName)

**Realm**

Both (Universal)

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Generate a random name using defaults
local randomName = lia.util.generateRandomName()
```
```

---

### lia.sendAdminPanel

**Purpose**

Send a table-based user interface to a specific client for displaying data in a structured format

**When Called**

When you need to display tabular data to a player, such as inventories, player lists, or administrative information

**Parameters**

* `client` (*Player*): The player to send the table UI to
* `title` (*String*): The title of the table window
* `columns` (*Table*): Array of column definitions with name, width, and other properties
* `data` (*Table*): Array of row data to display in the table
* `options` (*Table*): Optional configuration options for the table UI
* `characterID` (*Number*): Optional character ID for character-specific data

**Returns**

* Nothing (sends network message to client)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
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
```

---

### lia.util.sendTableUI

**Purpose**

Send a table-based user interface to a specific client for displaying data in a structured format

**When Called**

When you need to display tabular data to a player, such as inventories, player lists, or administrative information

**Parameters**

* `client` (*Player*): The player to send the table UI to
* `title` (*String*): The title of the table window
* `columns` (*Table*): Array of column definitions with name, width, and other properties
* `data` (*Table*): Array of row data to display in the table
* `options` (*Table*): Optional configuration options for the table UI
* `characterID` (*Number*): Optional character ID for character-specific data

**Returns**

* Nothing (sends network message to client)

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
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
```

---

### lia.spawnEntitiesInArea

**Purpose**

Find empty spaces around an entity for spawning or placement purposes

**When Called**

When you need to find valid locations to spawn entities, NPCs, or items around a central position

**Parameters**

* `entity` (*Entity*): The central entity to search around
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection
* `spacing` (*Number*): Distance between each tested position (default: 32)
* `size` (*Number*): Grid size to search in (default: 3, meaning -3 to +3 in both x and y)
* `height` (*Number*): Height of the area to check for collisions (default: 36)
* `tolerance` (*Number*): Additional clearance above ground (default: 5)

**Returns**

* Table of valid Vector positions sorted by distance from the entity

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find nearby empty spaces
local emptySpaces = lia.util.findEmptySpace(someEntity)
```
```

---

### lia.util.findEmptySpace

**Purpose**

Find empty spaces around an entity for spawning or placement purposes

**When Called**

When you need to find valid locations to spawn entities, NPCs, or items around a central position

**Parameters**

* `entity` (*Entity*): The central entity to search around
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection
* `spacing` (*Number*): Distance between each tested position (default: 32)
* `size` (*Number*): Grid size to search in (default: 3, meaning -3 to +3 in both x and y)
* `height` (*Number*): Height of the area to check for collisions (default: 36)
* `tolerance` (*Number*): Additional clearance above ground (default: 5)

**Returns**

* Table of valid Vector positions sorted by distance from the entity

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Find nearby empty spaces
local emptySpaces = lia.util.findEmptySpace(someEntity)
```
```

---

### lia.createAnimatedMenu

**Purpose**

Animate a panel's appearance with scaling, positioning, and alpha transitions

**When Called**

When you need to create smooth entrance animations for UI panels, menus, or dialog boxes

**Parameters**

* `panel` (*Panel*): The DPanel to animate
* `target_w` (*Number*): Target width for the animation
* `target_h` (*Number*): Target height for the animation
* `duration` (*Number*): Duration of size/position animation in seconds (default: 0.18)
* `alpha_dur` (*Number*): Duration of alpha animation in seconds (default: same as duration)
* `callback` (*Function*): Optional callback function to execute when animation completes
* `scale_factor` (*Number*): Scale factor for initial size (default: 0.8)

**Returns**

* Nothing (modifies panel directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Basic panel appearance animation
local panel = vgui.Create("DPanel")
panel:SetSize(200, 100)
lia.util.animateAppearance(panel, 200, 100)
```
```

---

### lia.util.animateAppearance

**Purpose**

Animate a panel's appearance with scaling, positioning, and alpha transitions

**When Called**

When you need to create smooth entrance animations for UI panels, menus, or dialog boxes

**Parameters**

* `panel` (*Panel*): The DPanel to animate
* `target_w` (*Number*): Target width for the animation
* `target_h` (*Number*): Target height for the animation
* `duration` (*Number*): Duration of size/position animation in seconds (default: 0.18)
* `alpha_dur` (*Number*): Duration of alpha animation in seconds (default: same as duration)
* `callback` (*Function*): Optional callback function to execute when animation completes
* `scale_factor` (*Number*): Scale factor for initial size (default: 0.8)

**Returns**

* Nothing (modifies panel directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Basic panel appearance animation
local panel = vgui.Create("DPanel")
panel:SetSize(200, 100)
lia.util.animateAppearance(panel, 200, 100)
```
```

---

### lia.positionPanelsSmartly

**Purpose**

Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

**When Called**

When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

**Parameters**

* `panel` (*Panel*): The DPanel whose position should be clamped

**Returns**

* Nothing (modifies panel position directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Keep panel within screen bounds
local panel = vgui.Create("DPanel")
panel:SetPos(ScrW() + 100, ScrH() + 50) -- Off-screen position
lia.util.clampMenuPosition(panel) -- Will move panel back on screen
```
```

---

### lia.util.clampMenuPosition

**Purpose**

Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

**When Called**

When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

**Parameters**

* `panel` (*Panel*): The DPanel whose position should be clamped

**Returns**

* Nothing (modifies panel position directly)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Keep panel within screen bounds
local panel = vgui.Create("DPanel")
panel:SetPos(ScrW() + 100, ScrH() + 50) -- Off-screen position
lia.util.clampMenuPosition(panel) -- Will move panel back on screen
```
```

---

### lia.drawAnimatedGradient

**Purpose**

Draw a gradient background using predefined gradient materials

**When Called**

When you need to create gradient backgrounds for UI elements, panels, or visual effects

**Parameters**

* `_x` (*Number*): X position to draw the gradient
* `_y` (*Number*): Y position to draw the gradient
* `_w` (*Number*): Width of the gradient area
* `_h` (*Number*): Height of the gradient area
* `direction` (*Number*): Gradient direction (1=up, 2=down, 3=left, 4=right)
* `color_shadow` (*Color*): Color for the gradient shadow effect
* `radius` (*Number*): Corner radius for rounded gradients (default: 0)
* `flags` (*Number*): Material flags for rendering

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw a basic gradient background
lia.util.drawGradient(100, 100, 200, 150, 2, Color(0, 0, 0, 150))
```
```

---

### lia.util.drawGradient

**Purpose**

Draw a gradient background using predefined gradient materials

**When Called**

When you need to create gradient backgrounds for UI elements, panels, or visual effects

**Parameters**

* `_x` (*Number*): X position to draw the gradient
* `_y` (*Number*): Y position to draw the gradient
* `_w` (*Number*): Width of the gradient area
* `_h` (*Number*): Height of the gradient area
* `direction` (*Number*): Gradient direction (1=up, 2=down, 3=left, 4=right)
* `color_shadow` (*Color*): Color for the gradient shadow effect
* `radius` (*Number*): Corner radius for rounded gradients (default: 0)
* `flags` (*Number*): Material flags for rendering

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw a basic gradient background
lia.util.drawGradient(100, 100, 200, 150, 2, Color(0, 0, 0, 150))
```
```

---

### lia.createResponsiveTextPanel

**Purpose**

Wrap text to fit within a specified width, breaking it into multiple lines

**When Called**

When you need to display text that might be too long for a UI element, ensuring it wraps properly

**Parameters**

* `text` (*String*): The text to wrap
* `width` (*Number*): Maximum width in pixels for the text
* `font` (*String*): Font to use for text measurement (default: "LiliaFont.16")

**Returns**

* Table of wrapped text lines, Number: Maximum width of any line

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Wrap text to fit in a label
local lines, maxWidth = lia.util.wrapText("This is a long text that needs wrapping", 200)
```
```

---

### lia.util.wrapText

**Purpose**

Wrap text to fit within a specified width, breaking it into multiple lines

**When Called**

When you need to display text that might be too long for a UI element, ensuring it wraps properly

**Parameters**

* `text` (*String*): The text to wrap
* `width` (*Number*): Maximum width in pixels for the text
* `font` (*String*): Font to use for text measurement (default: "LiliaFont.16")

**Returns**

* Table of wrapped text lines, Number: Maximum width of any line

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Wrap text to fit in a label
local lines, maxWidth = lia.util.wrapText("This is a long text that needs wrapping", 200)
```
```

---

### lia.drawDynamicBlur

**Purpose**

Draw a blur effect behind a panel using screen-space blurring

**When Called**

When you need to create a blurred background effect for UI elements like menus or dialogs

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `_` (*Any*): Unused parameter (legacy)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add basic blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlur(panel, 5, nil, 200)
```
```

---

### lia.createBlurredMenu

**Purpose**

Draw a blur effect behind a panel using screen-space blurring

**When Called**

When you need to create a blurred background effect for UI elements like menus or dialogs

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `_` (*Any*): Unused parameter (legacy)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add basic blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlur(panel, 5, nil, 200)
```
```

---

### lia.util.drawBlur

**Purpose**

Draw a blur effect behind a panel using screen-space blurring

**When Called**

When you need to create a blurred background effect for UI elements like menus or dialogs

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `_` (*Any*): Unused parameter (legacy)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add basic blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlur(panel, 5, nil, 200)
```
```

---

### lia.drawContextualBlur

**Purpose**

Draw a black blur effect with enhanced darkness behind a panel

**When Called**

When you need to create a darker, more opaque blurred background effect for UI elements

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 6)
* `passes` (*Number*): Number of blur passes for quality (default: 5, minimum: 1)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)
* `darkAlpha` (*Number*): Alpha transparency of the dark overlay (default: 220)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add dark blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
```
```

---

### lia.createContextualUI

**Purpose**

Draw a black blur effect with enhanced darkness behind a panel

**When Called**

When you need to create a darker, more opaque blurred background effect for UI elements

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 6)
* `passes` (*Number*): Number of blur passes for quality (default: 5, minimum: 1)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)
* `darkAlpha` (*Number*): Alpha transparency of the dark overlay (default: 220)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add dark blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
```
```

---

### lia.util.drawBlackBlur

**Purpose**

Draw a black blur effect with enhanced darkness behind a panel

**When Called**

When you need to create a darker, more opaque blurred background effect for UI elements

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 6)
* `passes` (*Number*): Number of blur passes for quality (default: 5, minimum: 1)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)
* `darkAlpha` (*Number*): Alpha transparency of the dark overlay (default: 220)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add dark blur behind a panel
local panel = vgui.Create("DPanel")
lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
```
```

---

### lia.drawDamageOverlay

**Purpose**

Draw a blur effect at specific screen coordinates

**When Called**

When you need to apply blur effects to specific screen areas for HUD elements or overlays

**Parameters**

* `x` (*Number*): X position to draw the blur
* `y` (*Number*): Y position to draw the blur
* `w` (*Number*): Width of the blur area
* `h` (*Number*): Height of the blur area
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `passes` (*Number*): Number of blur passes (default: 0.2)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Blur a specific screen area
lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)
```
```

---

### lia.drawMinimapWithEffects

**Purpose**

Draw a blur effect at specific screen coordinates

**When Called**

When you need to apply blur effects to specific screen areas for HUD elements or overlays

**Parameters**

* `x` (*Number*): X position to draw the blur
* `y` (*Number*): Y position to draw the blur
* `w` (*Number*): Width of the blur area
* `h` (*Number*): Height of the blur area
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `passes` (*Number*): Number of blur passes (default: 0.2)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Blur a specific screen area
lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)
```
```

---

### lia.util.drawBlurAt

**Purpose**

Draw a blur effect at specific screen coordinates

**When Called**

When you need to apply blur effects to specific screen areas for HUD elements or overlays

**Parameters**

* `x` (*Number*): X position to draw the blur
* `y` (*Number*): Y position to draw the blur
* `w` (*Number*): Width of the blur area
* `h` (*Number*): Height of the blur area
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `passes` (*Number*): Number of blur passes (default: 0.2)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Blur a specific screen area
lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)
```
```

---

### lia.createDataManager

**Purpose**

Create a complete table-based UI window for displaying data with interactive features

**When Called**

When you need to display tabular data with sorting, actions, and interactive options

**Parameters**

* `title` (*String*): Title for the table window
* `columns` (*Table*): Array of column definitions
* `data` (*Table*): Array of row data to display
* `options` (*Table*): Optional action buttons and configurations
* `charID` (*Number*): Character ID for character-specific data

**Returns**

* Frame, ListView: The created frame and list view objects

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic table UI
local frame, listView = lia.util.createTableUI("Player List", columns, playerData)
```
```

---

### lia.util.createTableUI

**Purpose**

Create a complete table-based UI window for displaying data with interactive features

**When Called**

When you need to display tabular data with sorting, actions, and interactive options

**Parameters**

* `title` (*String*): Title for the table window
* `columns` (*Table*): Array of column definitions
* `data` (*Table*): Array of row data to display
* `options` (*Table*): Optional action buttons and configurations
* `charID` (*Number*): Character ID for character-specific data

**Returns**

* Frame, ListView: The created frame and list view objects

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic table UI
local frame, listView = lia.util.createTableUI("Player List", columns, playerData)
```
```

---

### lia.createCategorizedOptions

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*String*): Title for the options menu
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

**Returns**

* Frame: The created options menu frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic options menu
local frame = lia.util.openOptionsMenu("Choose Action", {
{name = "Option 1", callback = function() print("Option 1 selected") end},
{name = "Option 2", callback = function() print("Option 2 selected") end}
})
```
```

---

### lia.util.openOptionsMenu

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*String*): Title for the options menu
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

**Returns**

* Frame: The created options menu frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic options menu
local frame = lia.util.openOptionsMenu("Choose Action", {
{name = "Option 1", callback = function() print("Option 1 selected") end},
{name = "Option 2", callback = function() print("Option 2 selected") end}
})
```
```

---

### lia.scaleColorAlpha

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*String*): Title for the options menu
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

**Returns**

* Frame: The created options menu frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic options menu
local frame = lia.util.openOptionsMenu("Choose Action", {
{name = "Option 1", callback = function() print("Option 1 selected") end},
{name = "Option 2", callback = function() print("Option 2 selected") end}
})
```
```

---

### lia.EntText

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*String*): Title for the options menu
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

**Returns**

* Frame: The created options menu frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create basic options menu
local frame = lia.util.openOptionsMenu("Choose Action", {
{name = "Option 1", callback = function() print("Option 1 selected") end},
{name = "Option 2", callback = function() print("Option 2 selected") end}
})
```
```

---

### lia.drawEntityInfo

**Purpose**

Draw floating text above an entity with distance-based fade effects

**When Called**

When you need to display information or labels above entities in the 3D world

**Parameters**

* `ent` (*Entity*): The entity to draw text above
* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text above an entity
lia.util.drawEntText(someEntity, "Important Item")
```
```

---

### lia.drawSmartEntityLabels

**Purpose**

Draw floating text above an entity with distance-based fade effects

**When Called**

When you need to display information or labels above entities in the 3D world

**Parameters**

* `ent` (*Entity*): The entity to draw text above
* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text above an entity
lia.util.drawEntText(someEntity, "Important Item")
```
```

---

### lia.util.drawEntText

**Purpose**

Draw floating text above an entity with distance-based fade effects

**When Called**

When you need to display information or labels above entities in the 3D world

**Parameters**

* `ent` (*Entity*): The entity to draw text above
* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text above an entity
lia.util.drawEntText(someEntity, "Important Item")
```
```

---

### lia.drawContextualWorldInfo

**Purpose**

Draw floating text at the player's look position with distance-based fade effects

**When Called**

When you need to display contextual information at the location the player is looking at

**Parameters**

* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control
* `maxDist` (*Number*): Maximum distance to display text (default: 380)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text where player is looking
lia.util.drawLookText("Target Location")
```
```

---

### lia.util.drawLookText

**Purpose**

Draw floating text at the player's look position with distance-based fade effects

**When Called**

When you need to display contextual information at the location the player is looking at

**Parameters**

* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control
* `maxDist` (*Number*): Maximum distance to display text (default: 380)

**Returns**

* Nothing (draws directly to screen)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text where player is looking
lia.util.drawLookText("Target Location")
```
```

---

