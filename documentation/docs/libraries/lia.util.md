# Utility Library

Common operations and helper functions for the Lilia framework.

---

## Overview

The utility library provides comprehensive functionality for common operations and helper

functions used throughout the Lilia framework. It contains a wide range of utilities for

player management, string processing, entity handling, UI operations, and general purpose

calculations. The library is divided into server-side functions for game logic and data

management, and client-side functions for user interface, visual effects, and player

interaction. These utilities simplify complex operations, provide consistent behavior

across the framework, and offer reusable components for modules and plugins. The library

handles everything from player identification and spatial queries to advanced UI animations

and text processing, ensuring robust and efficient operations across both server and client

environments.

---

### findPlayersInBox

**Purpose**

Find all players within a specified 3D box area

**When Called**

When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

**Parameters**

* `mins` (*Vector*): The minimum corner coordinates of the box
* `maxs` (*Vector*): The maximum corner coordinates of the box

---

### getBySteamID

**Purpose**

Find a player by their Steam ID or Steam ID 64

**When Called**

When you need to locate a specific player using their Steam identification for operations like bans, whitelists, or data retrieval

**Parameters**

* `steamID` (*String*): The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for

---

### findPlayersInSphere

**Purpose**

Find all players within a specified spherical radius from a center point

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or notifications

**Parameters**

* `origin` (*Vector*): The center point of the sphere
* `radius` (*Number*): The radius of the sphere in units

---

### findPlayer

**Purpose**

Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

**When Called**

When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

**Parameters**

* `client` (*Player*): The player requesting the search (for notifications and special selectors)
* `identifier` (*String*): The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)

---

### findPlayerItems

**Purpose**

Find all items created by a specific player in the world

**When Called**

When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

**Parameters**

* `client` (*Player*): The player whose created items should be found

---

### findPlayerItemsByClass

**Purpose**

Find all items of a specific class created by a particular player

**When Called**

When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

**Parameters**

* `client` (*Player*): The player whose created items should be found
* `class` (*String*): The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")

---

### findPlayerEntities

**Purpose**

Find all entities created by or associated with a specific player, optionally filtered by class

**When Called**

When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

**Parameters**

* `client` (*Player*): The player whose entities should be found
* `class` (*String*): Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")

---

### stringMatches

**Purpose**

Check if two strings match using flexible comparison methods including case-insensitive and partial matching

**When Called**

When you need to compare strings with flexible matching for search functionality, name validation, or text processing

**Parameters**

* `a` (*String*): The first string to compare
* `b` (*String*): The second string to compare (the search pattern)

---

### getAdmins

**Purpose**

Get a list of all currently online administrators/staff members

**When Called**

When you need to identify staff members for admin-only operations, notifications, or privilege checks

---

### findPlayerBySteamID64

**Purpose**

Find a player by their Steam ID 64, converting it to Steam ID format first

**When Called**

When you need to locate a player using their Steam ID 64 for database operations or external integrations

**Parameters**

* `SteamID64` (*String*): The Steam ID 64 to search for

---

### findPlayerBySteamID

**Purpose**

Find a player by their Steam ID

**When Called**

When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

**Parameters**

* `SteamID` (*String*): The Steam ID to search for (STEAM_0:0:123456 format)

---

### canFit

**Purpose**

Check if an entity can fit at a specific position without colliding with solid objects

**When Called**

When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

**Parameters**

* `pos` (*Vector*): The position to check for entity placement
* `mins` (*Vector*): Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
* `maxs` (*Vector*): Optional maximum bounding box coordinates (defaults to mins value)
* `filter` (*Entity/Table*): Optional entity or table of entities to ignore in collision detection
* `math.random(` (*unknown*): 100, 100),
* `math.random(` (*unknown*): 100, 100),

---

### playerInRadius

**Purpose**

Find all players within a specified radius from a center position

**When Called**

When you need to find players in a circular area for proximity-based operations like damage, effects, or area management

**Parameters**

* `pos` (*Vector*): The center position to check from
* `dist` (*Number*): The radius distance to check within

---

### formatStringNamed

**Purpose**

Format a string using named placeholders with flexible argument handling

**When Called**

When you need to format strings with named parameters for localization, templating, or dynamic text generation

**Parameters**

* `format` (*String*): The format string containing {placeholder} patterns
* `...` (*Mixed*): Either a table with named keys or individual arguments to replace placeholders

---

### getMaterial

**Purpose**

Get a cached material object from a file path, creating it if it doesn't exist

**When Called**

When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

**Parameters**

* `materialPath` (*String*): The file path to the material (e.g., "materials/effects/blur.vmt")
* `materialParameters` (*String*): Optional parameters for material creation

---

### findFaction

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

---

### lia.SoundDuration

**Purpose**

Find a faction by name or unique ID using flexible matching

**When Called**

When you need to locate faction information for player assignment, permissions, or faction-based operations

**Parameters**

* `client` (*Player*): The player requesting the faction (for error notifications)
* `name` (*String*): The faction name or unique ID to search for

---

### generateRandomName

**Purpose**

Generate a random full name by combining first and last names from provided or default lists

**When Called**

When you need to create random character names for NPCs, testing, or procedural content generation

**Parameters**

* `firstNames` (*Table*): Optional table of first names to choose from
* `lastNames` (*Table*): Optional table of last names to choose from

---

### sendTableUI

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

---

### findEmptySpace

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
* `math.random(` (*unknown*): 16, 16),
* `math.random(` (*unknown*): 16, 16),

---

### animateAppearance

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

---

### clampMenuPosition

**Purpose**

Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

**When Called**

When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

**Parameters**

* `panel` (*Panel*): The DPanel whose position should be clamped
* `lia.util.clampMenuPosition(panel)` (*unknown*): - Will move panel back on screen

---

### drawGradient

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

---

### wrapText

**Purpose**

Wrap text to fit within a specified width, breaking it into multiple lines

**When Called**

When you need to display text that might be too long for a UI element, ensuring it wraps properly

**Parameters**

* `text` (*String*): The text to wrap
* `width` (*Number*): Maximum width in pixels for the text
* `font` (*String*): Font to use for text measurement (default: "LiliaFont.16")

---

### drawBlur

**Purpose**

Draw a blur effect behind a panel using screen-space blurring

**When Called**

When you need to create a blurred background effect for UI elements like menus or dialogs

**Parameters**

* `panel` (*Panel*): The panel to draw blur behind
* `amount` (*Number*): Intensity of the blur effect (default: 5)
* `_` (*Any*): Unused parameter (legacy)
* `alpha` (*Number*): Alpha transparency of the blur effect (default: 255)

---

### drawBlackBlur

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

---

### drawBlurAt

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
* `lia.util.drawBlurAt(mapX` (*unknown*): 10, mapY - 10, mapW + 20, mapH + 20, 2, 0.1, 150)

---

### createTableUI

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

---

### openOptionsMenu

**Purpose**

Create and display an options menu with interactive buttons

**When Called**

When you need to present a list of options or actions to the user in a popup menu

**Parameters**

* `title` (*String*): Title for the options menu
* `options` (*Table*): Array of option objects or key-value pairs with name and callback properties

---

### drawEntText

**Purpose**

Draw floating text above an entity with distance-based fade effects

**When Called**

When you need to display information or labels above entities in the 3D world

**Parameters**

* `ent` (*Entity*): The entity to draw text above
* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control

---

### drawLookText

**Purpose**

Draw floating text at the player's look position with distance-based fade effects

**When Called**

When you need to display contextual information at the location the player is looking at

**Parameters**

* `text` (*String*): The text to display
* `posY` (*Number*): Vertical offset for text positioning (default: 0)
* `alphaOverride` (*Number*): Optional alpha override for manual control
* `maxDist` (*Number*): Maximum distance to display text (default: 380)

---

