# Utility Library

Common operations and helper functions for the Lilia framework.

---

Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

### lia.util.findPlayersInBox

#### 📋 Purpose
Finds all players within an axis-aligned bounding box.

#### ⏰ When Called
Use when you need the players contained inside specific world bounds (e.g. triggers or zones).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | Minimum corner of the search box. |
| `maxs` | **Vector** | Maximum corner of the search box. |

#### ↩️ Returns
* table
List of player entities inside the box.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local players = lia.util.findPlayersInBox(Vector(-128, -128, 0), Vector(128, 128, 128))

```

---

### lia.util.getBySteamID

#### 📋 Purpose
Locates a connected player by SteamID or SteamID64 and requires an active character.

#### ⏰ When Called
Use when commands or systems need to resolve a Steam identifier to a live player with a character loaded.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamID` | **string** | SteamID (e.g. "STEAM_0:1:12345") or SteamID64; empty/invalid strings are ignored. |

#### ↩️ Returns
* Player|nil
The matching player with a loaded character, or nil if not found/invalid input.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ply = lia.util.getBySteamID("76561198000000000")
    if ply then print("Found", ply:Name()) end

```

---

### lia.util.findPlayersInSphere

#### 📋 Purpose
Returns all players inside a spherical radius from a point.

#### ⏰ When Called
Use to gather players near a position for proximity-based effects or checks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | **Vector** | Center of the search sphere. |
| `radius` | **number** | Radius of the search sphere. |

#### ↩️ Returns
* table
Players whose positions are within the given radius.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, ply in ipairs(lia.util.findPlayersInSphere(pos, 256)) do
        ply:ChatPrint("You feel a nearby pulse.")
    end

```

---

### lia.util.findPlayer

#### 📋 Purpose
Resolves a player from various identifiers and optionally informs the caller on failure.

#### ⏰ When Called
Use in admin/command handlers that accept flexible player identifiers (SteamID, SteamID64, name, "^", "@").

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player requesting the lookup; used for localized error notifications. |
| `identifier` | **string** | Identifier to match: SteamID, SteamID64, "^" (self), "@" (trace target), or partial name. |

#### ↩️ Returns
* Player|nil
Matched player or nil when no match is found/identifier is invalid.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local target = lia.util.findPlayer(caller, args[1])
    if not target then return end
    target:kick("Example")

```

---

### lia.util.findPlayerItems

#### 📋 Purpose
Collects all spawned item entities created by a specific player.

#### ⏰ When Called
Use when cleaning up or inspecting items a player has spawned into the world.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose created item entities should be found. |

#### ↩️ Returns
* table
List of item entities created by the player.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, ent in ipairs(lia.util.findPlayerItems(ply)) do
        ent:Remove()
    end

```

---

### lia.util.findPlayerItemsByClass

#### 📋 Purpose
Collects spawned item entities from a player filtered by item class.

#### ⏰ When Called
Use when you need only specific item classes (by netvar "id") created by a player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose item entities are being inspected. |
| `class` | **string** | Item class/netvar id to match. |

#### ↩️ Returns
* table
Item entities created by the player that match the class.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ammo = lia.util.findPlayerItemsByClass(ply, "ammo_9mm")

```

---

### lia.util.findPlayerEntities

#### 📋 Purpose
Finds entities created by or associated with a player, optionally by class.

#### ⏰ When Called
Use to track props or scripted entities a player spawned or owns.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose entities should be matched. |
| `class` | **string|nil** | Optional entity class filter; nil includes all classes. |

#### ↩️ Returns
* table
Entities created by or linked via entity.client to the player that match the class filter.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ragdolls = lia.util.findPlayerEntities(ply, "prop_ragdoll")

```

---

### lia.util.stringMatches

#### 📋 Purpose
Performs case-insensitive equality and substring comparison between two strings.

#### ⏰ When Called
Use for loose name matching where exact case is not important.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **string** | First string to compare. |
| `b` | **string** | Second string to compare. |

#### ↩️ Returns
* boolean
True if the strings are equal (case-insensitive) or one contains the other; otherwise false.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.util.stringMatches(ply:Name(), "john") then print("Matched player") end

```

---

### lia.util.getAdmins

#### 📋 Purpose
Returns all connected staff members.

#### ⏰ When Called
Use when broadcasting staff notifications or iterating over staff-only recipients.

#### ↩️ Returns
* table
Players that pass `isStaff()`.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, admin in ipairs(lia.util.getAdmins()) do
        admin:notify("Server restart in 5 minutes.")
    end

```

---

### lia.util.findPlayerBySteamID64

#### 📋 Purpose
Resolves a player from a SteamID64 wrapper around `findPlayerBySteamID`.

#### ⏰ When Called
Use when you have a 64-bit SteamID and need the corresponding player entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `SteamID64` | **string** | SteamID64 to resolve. |

#### ↩️ Returns
* Player|nil
Matching player or nil when none is found/SteamID64 is invalid.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ply = lia.util.findPlayerBySteamID64(steamID64)

```

---

### lia.util.findPlayerBySteamID

#### 📋 Purpose
Searches connected players for a matching SteamID.

#### ⏰ When Called
Use when you need to map a SteamID string to the in-game player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `SteamID` | **string** | SteamID in legacy format (e.g. "STEAM_0:1:12345"). |

#### ↩️ Returns
* Player|nil
Player whose SteamID matches, or nil if none.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ply = lia.util.findPlayerBySteamID("STEAM_0:1:12345")

```

---

### lia.util.canFit

#### 📋 Purpose
Checks whether a bounding hull can fit at a position without collisions.

#### ⏰ When Called
Use before spawning or teleporting entities to ensure the space is clear.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pos` | **Vector** | Position to test. |
| `mins` | **Vector** | Hull minimums; defaults to Vector(16, 16, 0) mirrored if positive. |
| `maxs` | **Vector|nil** | Hull maximums; defaults to mins when nil. |
| `filter` | **Entity|table|nil** | Entity or filter list to ignore in the trace. |

#### ↩️ Returns
* boolean
True if the hull does not hit anything solid, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.util.canFit(pos, Vector(16, 16, 0)) then
        ent:SetPos(pos)
    end

```

---

### lia.util.playerInRadius

#### 📋 Purpose
Finds all players within a given radius.

#### ⏰ When Called
Use for proximity-based logic such as AoE effects or notifications.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pos` | **Vector** | Center position for the search. |
| `dist` | **number** | Radius to search, in units. |

#### ↩️ Returns
* table
Players whose distance squared to pos is less than dist^2.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, ply in ipairs(lia.util.playerInRadius(pos, 512)) do
        ply:notify("You are near the beacon.")
    end

```

---

### lia.util.formatStringNamed

#### 📋 Purpose
Formats a string using named placeholders or positional arguments.

#### ⏰ When Called
Use to substitute tokens in a template string with table keys or ordered arguments.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | **string** | Template containing placeholders like "{name}". |

#### ↩️ Returns
* string
The formatted string with placeholders replaced.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.util.formatStringNamed("Hello {who}", {who = "world"})
    lia.util.formatStringNamed("{1} + {2}", 1, 2)

```

---

### lia.util.getMaterial

#### 📋 Purpose
Retrieves and caches a material by path and parameters.

#### ⏰ When Called
Use whenever drawing materials repeatedly to avoid recreating them.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `materialPath` | **string** | Path to the material. |
| `materialParameters` | **string|nil** | Optional material creation parameters. |

#### ↩️ Returns
* IMaterial
Cached or newly created material instance.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local blurMat = lia.util.getMaterial("pp/blurscreen")

```

---

### lia.util.findFaction

#### 📋 Purpose
Resolves a faction table by name or unique ID and notifies the caller on failure.

#### ⏰ When Called
Use in commands or UI when users input a faction identifier.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player to notify on invalid faction. |
| `name` | **string** | Faction name or uniqueID to search for. |

#### ↩️ Returns
* table|nil
Matching faction table, or nil if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local faction = lia.util.findFaction(ply, "combine")
    if faction then print(faction.name) end

```

---

### lia.util.generateRandomName

#### 📋 Purpose
Generates a random full name from provided or default name lists.

#### ⏰ When Called
Use when creating placeholder or randomized character names.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `firstNames` | **table|nil** | Optional list of first names to draw from; defaults to built-in list when nil/empty. |
| `lastNames` | **table|nil** | Optional list of last names to draw from; defaults to built-in list when nil/empty. |

#### ↩️ Returns
* string
Concatenated first and last name.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local name = lia.util.generateRandomName()

```

---

### lia.util.sendTableUI

#### 📋 Purpose
Sends a localized table UI payload to a client.

#### ⏰ When Called
Use when the server needs to present tabular data/options to a specific player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Recipient player. |
| `title` | **string|nil** | Localization key for the window title; defaults to "tableListTitle". |
| `columns` | **table** | Column definitions; names are localized if present. |
| `data` | **table** | Row data to display. |
| `options` | **table|nil** | Optional menu options to accompany the table. |
| `characterID` | **number|nil** | Optional character identifier to send with the payload. |

#### ↩️ Returns
* nil
Communicates with the client via net message only.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.util.sendTableUI(ply, "staffList", columns, rows, options, charID)

```

---

### lia.util.findEmptySpace

#### 📋 Purpose
Finds nearby empty positions around an entity using grid sampling.

#### ⏰ When Called
Use when spawning items or players near an entity while avoiding collisions and the void.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Origin entity to search around. |
| `filter` | **Entity|table|nil** | Optional trace filter to ignore certain entities; defaults to the origin entity. |
| `spacing` | **number** | Grid spacing between samples; defaults to 32. |
| `size` | **number** | Number of steps in each direction from the origin; defaults to 3. |
| `height` | **number** | Hull height used for traces; defaults to 36. |
| `tolerance` | **number** | Upward offset to avoid starting inside the ground; defaults to 5. |

#### ↩️ Returns
* table
Sorted list of valid origin positions, nearest to farthest from the entity.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local spots = lia.util.findEmptySpace(ent, nil, 24)
    local pos = spots[1]

```

---

### lia.util.animateAppearance

#### 📋 Purpose
Animates a panel appearing from a scaled, transparent state to its target size and opacity.

#### ⏰ When Called
Use when showing popups or menus that should ease into view.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel to animate. |
| `targetWidth` | **number** | Final width of the panel. |
| `targetHeight` | **number** | Final height of the panel. |
| `duration` | **number|nil** | Duration for size/position easing; defaults to 0.18 seconds. |
| `alphaDuration` | **number|nil** | Duration for alpha easing; defaults to duration. |
| `callback` | **function|nil** | Called when the animation finishes. |
| `scaleFactor` | **number|nil** | Initial size scale relative to target; defaults to 0.8. |

#### ↩️ Returns
* nil
Mutates the panel over time via its Think hook.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.animateAppearance(panel, 300, 200)

```

---

### lia.util.clampMenuPosition

#### 📋 Purpose
Keeps a menu panel within the screen bounds, respecting the character logo space.

#### ⏰ When Called
Use after positioning a menu to prevent it from going off-screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Menu panel to clamp. |

#### ↩️ Returns
* nil
Adjusts the panel position in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.clampMenuPosition(menu)

```

---

### lia.util.drawGradient

#### 📋 Purpose
Draws a directional gradient rectangle.

#### ⏰ When Called
Use in panel paints when you need simple gradient backgrounds.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position of the gradient. |
| `y` | **number** | Y position of the gradient. |
| `w` | **number** | Width of the gradient. |
| `h` | **number** | Height of the gradient. |
| `direction` | **number** | Gradient direction index (1 up, 2 down, 3 left, 4 right). |
| `colorShadow` | **Color** | Color tint for the gradient. |
| `radius` | **number|nil** | Corner radius for drawing helper; defaults to 0. |
| `flags` | **number|nil** | Optional draw flags passed to `drawMaterial`. |

#### ↩️ Returns
* nil
Performs immediate drawing operations.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.drawGradient(0, 0, w, h, 2, Color(0, 0, 0, 180))

```

---

### lia.util.wrapText

#### 📋 Purpose
Wraps text to a maximum width using a specified font.

#### ⏰ When Called
Use when drawing text that must fit inside a set horizontal space.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to wrap. |
| `width` | **number** | Maximum width in pixels. |
| `font` | **string|nil** | Font name to measure with; defaults to "LiliaFont.16". |

#### ↩️ Returns
* table, number
Array of wrapped lines and the widest line width.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local lines = lia.util.wrapText(description, 300, "LiliaFont.17")

```

---

### lia.util.drawBlur

#### 📋 Purpose
Draws a blurred background behind a panel.

#### ⏰ When Called
Use inside a panel's Paint hook to soften the content behind it.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel whose screen area will be blurred. |
| `amount` | **number|nil** | Blur strength; defaults to 5. |
| `passes` | **number|nil** | Unused; kept for signature compatibility. |
| `alpha` | **number|nil** | Draw color alpha; defaults to 255. |

#### ↩️ Returns
* nil
Renders blur to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.drawBlur(self, 4)

```

---

### lia.util.drawBlackBlur

#### 📋 Purpose
Draws a blurred background with a dark overlay in a panel's bounds.

#### ⏰ When Called
Use for modal overlays where both blur and darkening are desired.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel area to blur. |
| `amount` | **number|nil** | Blur strength; defaults to 6. |
| `passes` | **number|nil** | Number of blur passes; defaults to 5. |
| `alpha` | **number|nil** | Blur draw alpha; defaults to 255. |
| `darkAlpha` | **number|nil** | Alpha for the black overlay; defaults to 220. |

#### ↩️ Returns
* nil
Renders blur and overlay.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.drawBlackBlur(self, 6, 4, 255, 200)

```

---

### lia.util.drawBlurAt

#### 📋 Purpose
Draws a blur effect over a specific rectangle on the screen.

#### ⏰ When Called
Use when you need a localized blur that is not tied to a panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X coordinate of the rectangle. |
| `y` | **number** | Y coordinate of the rectangle. |
| `w` | **number** | Width of the rectangle. |
| `h` | **number** | Height of the rectangle. |
| `amount` | **number|nil** | Blur strength; defaults to 5. |
| `passes` | **number|nil** | Number of blur samples; defaults to 0.2 steps when nil. |
| `alpha` | **number|nil** | Draw alpha; defaults to 255. |

#### ↩️ Returns
* nil
Renders blur to the specified area.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.drawBlurAt(100, 100, 200, 150, 4)

```

---

### lia.util.requestEntityInformation

#### 📋 Purpose
Prompts the user for entity information and forwards the result.

#### ⏰ When Called
Use when a client must supply additional data for an entity action.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Entity that the information pertains to; removed if the request fails. |
| `argTypes` | **table** | Argument descriptors passed to `requestArguments`. |
| `callback` | **function|nil** | Invoked with the collected information on success. |

#### ↩️ Returns
* nil
Handles UI flow and optional callback invocation.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.requestEntityInformation(ent, argTypes, function(info) print(info) end)

```

---

### lia.util.createTableUI

#### 📋 Purpose
Builds and displays a table UI on the client.

#### ⏰ When Called
Use when the client needs to view tabular data with optional menu actions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Localization key for the frame title; defaults to "tableListTitle". |
| `columns` | **table** | Column definitions with `name`, `width`, `align`, and `sortable` fields. |
| `data` | **table** | Row data keyed by column field names. |
| `options` | **table|nil** | Optional menu options with callbacks or net names. |
| `charID` | **number|nil** | Character identifier forwarded with net options. |

#### ↩️ Returns
* Panel, Panel
The created frame and table list view.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local frame, list = lia.util.createTableUI("myData", cols, rows)

```

---

### lia.util.openOptionsMenu

#### 📋 Purpose
Displays a simple options menu with clickable entries.

#### ⏰ When Called
Use to quickly prompt the user with a list of named actions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text to show at the top of the menu; defaults to "options". |
| `options` | **table** | Either an array of {name, callback} or a map of name -> callback. |

#### ↩️ Returns
* Panel|nil
The created frame, or nil if no valid options exist.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.openOptionsMenu("choose", {{"Yes", onYes}, {"No", onNo}})

```

---

### lia.util.drawEntText

#### 📋 Purpose
Draws floating text above an entity that eases in based on distance.

#### ⏰ When Called
Use in HUD painting to label world entities when nearby.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | Entity to draw text above. |
| `text` | **string** | Text to display. |
| `posY` | **number|nil** | Vertical offset in screen space; defaults to 0. |
| `alphaOverride` | **number|nil** | Optional alpha multiplier (0-1 or 0-255). |

#### ↩️ Returns
* nil
Performs drawing only; caches fade state per-entity.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("HUDPaint", "DrawEntLabels", function()
        lia.util.drawEntText(ent, "Storage")
    end)

```

---

### lia.util.drawLookText

#### 📋 Purpose
Draws text at the player's look position with distance-based easing.

#### ⏰ When Called
Use to display contextual prompts or hints where the player is aiming.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to render at the hit position. |
| `posY` | **number|nil** | Screen-space vertical offset; defaults to 0. |
| `Screen` | **unknown** | space vertical offset; defaults to 0. |
| `Screen` | **unknown** | space vertical offset; defaults to 0. |
| `alphaOverride` | **number|nil** | Optional alpha multiplier (0-1 or 0-255). |
| `maxDist` | **number|nil** | Maximum trace distance; defaults to 380 units. |

#### ↩️ Returns
* nil
Draws text when a trace hits within range.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.util.drawLookText("Press E to interact")

```

---

