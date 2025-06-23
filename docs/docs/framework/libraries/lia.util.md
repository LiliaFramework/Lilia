# lia.util

---

The `lia.util` library offers a collection of versatile helper functions designed to simplify common tasks within the Lilia Framework. These utilities encompass a wide range of functionalities, including player searches, entity management, string manipulation, UI enhancements, and graphical rendering. By leveraging these helper functions, developers can streamline their workflow, enhance user interfaces, and implement complex features with ease.

---

## Functions

### **lia.util.FindPlayersInBox**

**Description:**  
Finds all players within a box defined by minimum and maximum coordinates. This function is useful for detecting players in specific areas or triggering events based on player locations.

**Realm:**  
`shared`

**Parameters:**  

- `mins` (`Vector`):  
  The minimum corner of the box.

- `maxs` (`Vector`):  
  The maximum corner of the box.

**Returns:**  
`table` - A list of players within the specified box.

**Example Usage:**
```lua
local mins = Vector(-100, -100, 0)
local maxs = Vector(100, 100, 200)
local playersInBox = lia.util.FindPlayersInBox(mins, maxs)

for _, ply in ipairs(playersInBox) do
    ply:ChatPrint("You are within the designated area!")
end
```

---

### **lia.util.FindPlayersInSphere**

**Description:**  
Finds all players within a sphere defined by an origin point and radius. This function is ideal for proximity-based interactions, such as area-of-effect abilities or localized notifications.

**Realm:**  
`Client`

**Parameters:**  

- `origin` (`Vector`):  
  The center point of the sphere.

- `radius` (`number`):  
  The radius of the sphere.

**Returns:**  
`table` - A list of players within the specified sphere.

**Example Usage:**
```lua
local origin = Vector(0, 0, 0)
local radius = 500
local nearbyPlayers = lia.util.FindPlayersInSphere(origin, radius)

for _, ply in ipairs(nearbyPlayers) do
    ply:ChatPrint("A sphere event is happening nearby!")
end
```

---

### **lia.util.findPlayer**

**Description:**  
Attempts to find a player by matching their name or Steam ID. This function supports both exact matches and pattern-based searches, providing flexibility in player identification.

**Realm:**  
`Shared`

**Parameters:**  

- `identifier` (`string`):  
  The search query, which can be a player's name or Steam ID.

- `allowPatterns` (`bool`, optional):  
  Whether to accept Lua patterns in the `identifier`. Defaults to `false`.

**Returns:**  
`Player|nil` - The player that matches the given search query, or `nil` if no match is found.

**Example Usage:**
```lua
-- Find a player by exact name
local ply = lia.util.findPlayer("Alice")
if ply then
    ply:ChatPrint("You have been found by name!")
end

-- Find a player by Steam ID with pattern matching
local plyPattern = lia.util.findPlayer("^STEAM_1:1:12345$", true)
if plyPattern then
    plyPattern:ChatPrint("You have been found by Steam ID pattern!")
end
```

---

### **lia.util.findPlayerItems**

**Description:**  
Finds all items owned by a specified player. This function is useful for inventory management, allowing developers to retrieve and manipulate items associated with a player.

**Realm:**  
`Shared`

**Parameters:**  

- `client` (`Player`):  
  The player whose items are being searched for.

**Returns:**  
`table` - A table containing all items owned by the given player.

**Example Usage:**
```lua
local playerItems = lia.util.findPlayerItems(LocalPlayer())

for _, item in ipairs(playerItems) do
    print("Item:", item:GetClass())
end
```

---

### **lia.util.findPlayerItemsByClass**

**Description:**  
Finds items of a specific class owned by a specified player. This function allows for targeted searches within a player's inventory, facilitating actions like item management or specific item-based events.

**Realm:**  
`Shared`

**Parameters:**  

- `client` (`Player`):  
  The player whose items are being searched for.

- `class` (`string`):  
  The class of the items being searched for.

**Returns:**  
`table` - A table containing all items of the specified class owned by the given player.

**Example Usage:**
```lua
local swords = lia.util.findPlayerItemsByClass(player, "weapon_sword")

for _, sword in ipairs(swords) do
    print("Sword found:", sword:GetModel())
end
```

---

### **lia.util.findPlayerEntities**

**Description:**  
Finds all entities of a specific class owned by a specified player. If no class is specified, it finds all entities owned by the player. This function is beneficial for entity management, enabling developers to track and manipulate player-owned entities.

**Realm:**  
`Shared`

**Parameters:**  

- `client` (`Player`):  
  The player whose entities are being searched for.

- `class` (`string`, optional):  
  The class of the entities being searched for. If not provided, all entities owned by the player are returned.

**Returns:**  
`table` - A table containing all entities of the specified class (or all entities if no class is specified) owned by the given player.

**Example Usage:**
```lua
-- Find all entities owned by the player
local allEntities = lia.util.findPlayerEntities(player)

for _, ent in ipairs(allEntities) do
    print("Entity:", ent:GetClass())
end

-- Find all doors owned by the player
local doors = lia.util.findPlayerEntities(player, "prop_door")

for _, door in ipairs(doors) do
    print("Door found:", door:GetPos())
end
```

---

### **lia.util.stringMatches**

**Description:**  
Checks if two strings are equivalent using a fuzzy matching approach. Both strings are converted to lowercase, and the function returns `true` if the strings are identical or if one string is a substring of the other.

**Realm:**  
`Shared`

**Parameters:**  

- `a` (`string`):  
  The first string to check.

- `b` (`string`):  
  The second string to check.

**Returns:**  
`bool` - Whether or not the strings are equivalent based on fuzzy matching.

**Example Usage:**
```lua
local match1 = lia.util.stringMatches("HelloWorld", "helloworld") -- true
local match2 = lia.util.stringMatches("HelloWorld", "world")      -- true
local match3 = lia.util.stringMatches("HelloWorld", "Lua")        -- false

print(match1, match2, match3) -- Output: true true false
```

---

### **lia.util.getAdmins**

**Description:**  
Retrieves all online players with administrative permissions. This function is useful for administering server controls, such as broadcasting messages to staff or managing administrative tasks.

**Realm:**  
`Shared`

**Returns:**  
`table` - A table containing all online players with administrative permissions.

**Example Usage:**
```lua
local admins = lia.util.getAdmins()

for _, admin in ipairs(admins) do
    admin:ChatPrint("Server maintenance will begin in 10 minutes.")
end
```

---

### **lia.util.findPlayerBySteamID64**

**Description:**  
Finds a player by their SteamID64. This function is particularly useful for identifying players based on their unique Steam identifiers.

**Realm:**  
`Shared`

**Parameters:**  

- `SteamID64` (`string`):  
  The SteamID64 of the player to find.

**Returns:**  
`Player|nil` - The player object if found, `nil` otherwise.

**Example Usage:**
```lua
local steamID64 = "76561198000000000"
local ply = lia.util.findPlayerBySteamID64(steamID64)

if ply then
    ply:ChatPrint("You have been identified by SteamID64!")
else
    print("Player not found.")
end
```

---

### **lia.util.findPlayerBySteamID**

**Description:**  
Finds a player by their SteamID. This function assists in locating players using their traditional Steam identifiers.

**Realm:**  
`Shared`

**Parameters:**  

- `SteamID` (`string`):  
  The SteamID of the player to find.

**Returns:**  
`Player|nil` - The player object if found, `nil` otherwise.

**Example Usage:**
```lua
local steamID = "STEAM_1:1:12345678"
local ply = lia.util.findPlayerBySteamID(steamID)

if ply then
    ply:ChatPrint("You have been identified by SteamID!")
else
    print("Player not found.")
end
```

---

### **lia.util.canFit**

**Description:**  
Checks if a position can accommodate a player's collision hull. This function is essential for ensuring that entities or players can be placed without overlapping existing objects or terrain.

**Realm:**  
`Shared`

**Parameters:**  

- `pos` (`Vector`):  
  The position to check.

- `mins` (`Vector`, optional):  
  The minimum size of the collision hull. Defaults to `Vector(16, 16, 0)` if not provided.

- `maxs` (`Vector`, optional):  
  The maximum size of the collision hull. Defaults to the value of `mins` if not provided.

- `filter` (`table`, optional):  
  Entities to exclude from the collision check.

**Returns:**  
`bool` - `true` if the position can fit the collision hull, `false` otherwise.

**Example Usage:**
```lua
local position = Vector(0, 0, 0)
local canFit = lia.util.canFit(position)

if canFit then
    print("Position is clear for placement.")
else
    print("Cannot place entity here.")
end
```

---

### **lia.util.playerInRadius**

**Description:**  
Retrieves all players within a certain radius from a given position. This function is useful for proximity-based events, such as area-of-effect abilities or localized interactions.

**Realm:**  
`Shared`

**Parameters:**  

- `pos` (`Vector`):  
  The center position.

- `dist` (`number`):  
  The maximum distance from the center.

**Returns:**  
`table` - A table containing players within the specified radius.

**Example Usage:**
```lua
local center = Vector(100, 100, 0)
local radius = 300
local nearbyPlayers = lia.util.playerInRadius(center, radius)

for _, ply in ipairs(nearbyPlayers) do
    ply:ChatPrint("You are within the event radius!")
end
```

---

### **lia.util.findEmptySpace**

**Description:**  
Finds empty spaces around an entity where another entity can be placed. This server-side function is useful for dynamically spawning entities in safe locations without overlapping existing objects.

**Realm:**  
`Server`

**Parameters:**  

- `entity` (`Entity`):  
  The entity around which to search for empty spaces.

- `filter` (`table`, optional):  
  Entities to exclude from the collision check.

- `spacing` (`number`, optional):  
  Spacing between empty spaces. Defaults to `32` units.

- `size` (`number`, optional):  
  Size of the search grid. Defaults to `3`.

- `height` (`number`, optional):  
  Height of the search grid. Defaults to `36` units.

- `tolerance` (`number`, optional):  
  Tolerance for collision checking. Defaults to `5` units.

**Returns:**  
`table` - A table containing positions of empty spaces.

**Example Usage:**
```lua
local entity = ents.FindByClass("prop_physics")[1]
local emptySpaces = lia.util.findEmptySpace(entity)

for _, pos in ipairs(emptySpaces) do
    print("Empty space found at:", pos)
end
```

---

### **lia.util.formatStringNamed**

**Description:**  
Returns a string with named arguments in the format string replaced by the provided arguments. This function supports both table-based and ordered argument replacements, enhancing string formatting flexibility.

**Realm:**  
`Shared`

**Parameters:**  

- `format` (`string`):  
  The format string containing placeholders in `{}`.

- `...` (`table|...`):  
  Arguments to replace the placeholders. If a table is provided, it uses key-value pairs for replacement. Otherwise, it replaces placeholders in order.

**Returns:**  
`string` - The formatted string with placeholders replaced by the provided arguments.

**Example Usage:**
```lua
-- Using a table for named arguments
local formatted1 = lia.util.formatStringNamed("Hello, {name}! Welcome to {place}.", {name = "Bobby", place = "Lua Land"})
print(formatted1)
-- Output: "Hello, Bobby! Welcome to Lua Land."

-- Using ordered arguments
local formatted2 = lia.util.formatStringNamed("Hello, {1}! You have {2} new messages.", "Alice", 5)
print(formatted2)
-- Output: "Hello, Alice! You have 5 new messages."
```

---

### **lia.util.getMaterial**

**Description:**  
Returns a cached copy of the given material or creates and caches one if it doesn't exist. This is a quick helper function to optimize material retrieval and reduce redundant material loading.

**Realm:**  
`Shared`

**Parameters:**  

- `materialPath` (`string`):  
  The path to the material.

- `materialParameters` (`string`, optional):  
  Additional parameters for the material.

**Returns:**  
`Material|nil` - The cached material or `nil` if the material doesn't exist in the filesystem.

**Example Usage:**
```lua
local mat = lia.util.getMaterial("vgui/gradient-u", "noclamp smooth")
surface.SetMaterial(mat)
surface.SetDrawColor(255, 255, 255)
surface.DrawTexturedRect(0, 0, 256, 256)
```

---

### **lia.util.CreateTableUI** *(Server Only)*

**Description:**  
Sends a request to the client to display a table UI. This function is useful for presenting structured data to players in a user-friendly table format, such as inventories, leaderboards, or data logs.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`):  
  The player to whom the UI should be sent.

- `title` (`string`):  
  The title of the table UI.

- `columns` (`table`):  
  A table defining the columns in the table.

- `data` (`table`):  
  A table containing rows of data.

- `options` (`table`, optional):  
  Additional options for the table UI.

- `characterID` (`number`, optional):  
  The character ID associated with the data.

**Example Usage:**
```lua
local columns = {
    {name = "Item", field = "itemName", width = 200},
    {name = "Quantity", field = "quantity", width = 100},
    {name = "Price", field = "price", width = 100}
}

local data = {
    {itemName = "Sword", quantity = 1, price = "$100"},
    {itemName = "Shield", quantity = 2, price = "$150"},
    {itemName = "Potion", quantity = 5, price = "$50"}
}

lia.util.CreateTableUI(player, "Inventory", columns, data, {}, characterID)
```

---

### **lia.util.FindEmptySpace** *(Server Only)*

**Description:**  
Finds empty spaces around an entity where another entity can be placed. This function ensures that new entities are spawned in valid locations without colliding with existing objects or terrain, maintaining the game's spatial integrity.

**Realm:**  
`Server`

**Parameters:**  

- `entity` (`Entity`):  
  The entity around which to search for empty spaces.

- `filter` (`table`, optional):  
  Entities to exclude from the collision check.

- `spacing` (`number`, optional):  
  Spacing between empty spaces. Defaults to `32` units.

- `size` (`number`, optional):  
  Size of the search grid. Defaults to `3`.

- `height` (`number`, optional):  
  Height of the search grid. Defaults to `36` units.

- `tolerance` (`number`, optional):  
  Tolerance for collision checking. Defaults to `5` units.

**Returns:**  
`table` - A table containing positions of empty spaces.

**Example Usage:**
```lua
local entity = ents.FindByClass("prop_physics")[1]
local emptyPositions = lia.util.findEmptySpace(entity)

for _, pos in ipairs(emptyPositions) do
    print("Empty position found at:", pos)
end
```

---

### **lia.util.drawBlur**

**Description:**  
Blurs the content underneath the given panel. If the player has blurring disabled, it falls back to drawing a simple darkened rectangle. This function enhances UI aesthetics by providing a visually appealing background effect.

**Realm:**  
`Client`

**Parameters:**  

- `panel` (`Panel`):  
  The panel to apply the blur effect to.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Defaults to `0.2`.

**Example Usage:**
```lua
function PANEL:Paint(width, height)
    lia.util.drawBlur(self)
end
```

---

### **lia.util.drawBlurAt**

**Description:**  
Draws a blurred rectangle at the specified position and bounds. This function is intended for drawing blur effects in specific screen areas rather than entire panels.

**Realm:**  
`Client`

**Parameters:**  

- `x` (`number`):  
  X-position of the rectangle.

- `y` (`number`):  
  Y-position of the rectangle.

- `w` (`number`):  
  Width of the rectangle.

- `h` (`number`):  
  Height of the rectangle.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Defaults to `0.2`.

**Example Usage:**
```lua
hook.Add("HUDPaint", "MyHUDPaint", function()
    lia.util.drawBlurAt(100, 100, 200, 150)
end)
```

---

### **lia.util.ShadowText**

**Description:**  
Draws text with a shadow effect, enhancing readability against various backgrounds. This function is useful for creating visually appealing text elements in the UI.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  The text to draw.

- `font` (`string`):  
  The font to use.

- `x` (`number`):  
  The x-coordinate to draw the text at.

- `y` (`number`):  
  The y-coordinate to draw the text at.

- `colortext` (`Color`):  
  The color of the text.

- `colorshadow` (`Color`):  
  The color of the shadow.

- `dist` (`number`):  
  The distance of the shadow from the text.

- `xalign` (`number`):  
  Horizontal alignment of the text (e.g., `TEXT_ALIGN_LEFT`, `TEXT_ALIGN_CENTER`, `TEXT_ALIGN_RIGHT`).

- `yalign` (`number`):  
  Vertical alignment of the text (e.g., `TEXT_ALIGN_TOP`, `TEXT_ALIGN_CENTER`, `TEXT_ALIGN_BOTTOM`).

**Example Usage:**
```lua
lia.util.ShadowText("Hello, World!", "Default", 200, 200, Color(255, 255, 255), Color(0, 0, 0, 150), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```

---

### **lia.util.DrawTextOutlined**

**Description:**  
Draws text with an outline, making it stand out against complex backgrounds. This function enhances text visibility and aesthetic appeal in the UI.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  The text to draw.

- `font` (`string`):  
  The font to use.

- `x` (`number`):  
  The x-coordinate to draw the text at.

- `y` (`number`):  
  The y-coordinate to draw the text at.

- `colour` (`Color`):  
  The color of the text.

- `xalign` (`number`):  
  Horizontal alignment of the text (e.g., `TEXT_ALIGN_LEFT`, `TEXT_ALIGN_CENTER`, `TEXT_ALIGN_RIGHT`).

- `outlinewidth` (`number`):  
  The width of the outline.

- `outlinecolour` (`Color`):  
  The color of the outline.

**Returns:**  
`number` - The result of the `draw.DrawText` function.

**Example Usage:**
```lua
lia.util.DrawTextOutlined("Outlined Text", "Default", 300, 300, Color(255, 255, 255), TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
```

---

### **lia.util.DrawTip**

**Description:**  
Draws a tip box with text, providing contextual information or guidance to players. This function is useful for creating tooltip-like UI elements.

**Realm:**  
`Client`

**Parameters:**  

- `x` (`number`):  
  X-position of the top-left corner.

- `y` (`number`):  
  Y-position of the top-left corner.

- `w` (`number`):  
  Width of the tip box.

- `h` (`number`):  
  Height of the tip box.

- `text` (`string`):  
  The text to display inside the tip box.

- `font` (`string`):  
  The font to use for the text.

- `textCol` (`Color`):  
  The color of the text.

- `outlineCol` (`Color`):  
  The color of the outline.

**Example Usage:**
```lua
lia.util.DrawTip(50, 50, 200, 100, "This is a helpful tip!", "Default", Color(255, 255, 255), Color(0, 0, 0))
```

---

### **lia.util.drawText**

**Description:**  
Draws text with a shadow, enhancing its visibility against varying backgrounds. This function simplifies the process of rendering text elements with shadow effects.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  Text to draw.

- `x` (`number`):  
  X-position of the text.

- `y` (`number`):  
  Y-position of the text.

- `color` (`Color`):  
  Color of the text to draw.

- `alignX` (`number`, optional):  
  Horizontal alignment of the text, using one of the `TEXT_ALIGN_*` constants. Defaults to `TEXT_ALIGN_LEFT`.

- `alignY` (`number`, optional):  
  Vertical alignment of the text, using one of the `TEXT_ALIGN_*` constants. Defaults to `TEXT_ALIGN_LEFT`.

- `font` (`string`, optional):  
  Font to use for the text. Defaults to `"liaGenericFont"`.

- `alpha` (`number`, optional):  
  Alpha of the shadow. Defaults to `color.a * 0.575`.

**Returns:**  
`number` - The result of the `draw.TextShadow` function.

**Example Usage:**
```lua
lia.util.drawText("Shadowed Text", 400, 400, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "Default", 150)
```

---

### **lia.util.drawTexture**

**Description:**  
Draws a textured rectangle with a specified material and color. This function simplifies the rendering of textured elements in the UI.

**Realm:**  
`Client`

**Parameters:**  

- `material` (`string`):  
  Material to use for the texture.

- `color` (`Color`, optional):  
  Color of the texture. Defaults to `Color(255, 255, 255)`.

- `x` (`number`):  
  X-position of the top-left corner of the rectangle.

- `y` (`number`):  
  Y-position of the top-left corner of the rectangle.

- `w` (`number`):  
  Width of the rectangle.

- `h` (`number`):  
  Height of the rectangle.


**Example Usage:**
```lua
lia.util.drawTexture("vgui/gradient-u", Color(255, 255, 255, 200), 500, 500, 100, 50)
```

---

### **lia.util.skinFunc**

**Description:**  
Calls a named skin function with optional arguments on a panel. This function allows for dynamic skinning of UI elements, enabling customized appearances based on skin definitions.

**Realm:**  
`Client`

**Parameters:**  

- `name` (`string`):  
  Name of the skin function to call.

- `panel` (`Panel`, optional):  
  Panel to apply the skin function to. If not provided, the default skin is used.

- `a` (`any`, optional):  
  Argument 1.

- `b` (`any`, optional):  
  Argument 2.

- `c` (`any`, optional):  
  Argument 3.

- `d` (`any`, optional):  
  Argument 4.

- `e` (`any`, optional):  
  Argument 5.

- `f` (`any`, optional):  
  Argument 6.

- `g` (`any`, optional):  
  Argument 7.

**Returns:**  
`any` - The result of the skin function call.

**Example Usage:**
```lua
local result = lia.util.skinFunc("Paint", myPanel, 255, 255, 255, 255)
```

---

### **lia.util.wrapText**

**Description:**  
Wraps text so it does not exceed a certain width. This function intelligently breaks lines between words when possible or splits words if they are too long, ensuring that text fits within designated UI elements.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  Text to wrap.

- `width` (`number`):  
  Maximum allowed width in pixels.

- `font` (`string`, optional):  
  Font to use for the text. Defaults to `"liaChatFont"`.

**Returns:**  
- `table` - A table containing the wrapped lines of text.

- `number` - The maximum width of the wrapped text.

**Example Usage:**
```lua
local wrappedLines, maxWidth = lia.util.wrapText("This is a very long piece of text that needs to be wrapped.", 300)

for _, line in ipairs(wrappedLines) do
    print(line)
end
-- Output:
-- "This is a very"
-- "long piece of"
-- "text that needs"
-- "to be wrapped."
```

---

### **lia.util.drawBlur**

**Description:**  
Blurs the content underneath the given panel. This function falls back to a simple darkened rectangle if the player has blurring disabled, ensuring consistent visual effects across different player settings.

**Realm:**  
`Client`

**Parameters:**  

- `panel` (`Panel`):  
  The panel to draw the blur for.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Recommended to keep as default (`0.2`).

**Example Usage:**
```lua
function PANEL:Paint(width, height)
    lia.util.drawBlur(self)
end
```

---

### **lia.util.drawBlurAt**

**Description:**  
Draws a blurred rectangle with the specified position and bounds. This function is intended for use outside of panels and provides flexibility in where blur effects are applied on the screen.

**Realm:**  
`Client`

**Parameters:**  

- `x` (`number`):  
  X-position of the rectangle.

- `y` (`number`):  
  Y-position of the rectangle.

- `w` (`number`):  
  Width of the rectangle.

- `h` (`number`):  
  Height of the rectangle.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Recommended to keep as default (`0.2`).

**Example Usage:**
```lua
hook.Add("HUDPaint", "MyHUDPaint", function()
    lia.util.drawBlurAt(100, 100, 300, 200)
end)
```

---

### **lia.util.notifQuery**

**Description:**  
Displays a query notification panel with customizable options. This function is useful for prompting players with yes/no questions or binary choices, capturing their responses through key presses.

**Realm:**  
`Client`

**Parameters:**  

- `question` (`string`):  
  The question or prompt to display.

- `option1` (`string`):  
  The text for the first option.

- `option2` (`string`):  
  The text for the second option.

- `manualDismiss` (`bool`):  
  If `true`, the panel requires manual dismissal.

- `notifType` (`number`):  
  The type of notification.

- `callback` (`function`):  
  The function to call when an option is selected. It receives the option index and the notice panel as arguments.

**Returns:**  
`Panel` - The created notification panel.

**Example Usage:**
```lua
lia.util.notifQuery("Do you want to accept the quest?", "Yes", "No", false, 7, function(option, panel)
    if option == 1 then
        print("Player accepted the quest.")
    else
        print("Player declined the quest.")
    end
end)
```

---

### **lia.util.formatStringNamed**

**Description:**  
Returns a string with named arguments in the format string replaced by the provided arguments. This function supports both table-based and ordered argument replacements, enhancing string formatting flexibility.

**Realm:**  
`Shared`

**Parameters:**  

- `format` (`string`):  
  The format string containing placeholders in `{}`.

- `...` (`table|...`):  
  Arguments to replace the placeholders. If a table is provided, it uses key-value pairs for replacement. Otherwise, it replaces placeholders in order.

**Returns:**  
`string` - The formatted string with placeholders replaced by the provided arguments.

**Example Usage:**
```lua
-- Using a table for named arguments
local formatted1 = lia.util.formatStringNamed("Hello, {name}! Welcome to {place}.", {name = "Bobby", place = "Lua Land"})
print(formatted1)
-- Output: "Hello, Bobby! Welcome to Lua Land."

-- Using ordered arguments
local formatted2 = lia.util.formatStringNamed("Hello, {1}! You have {2} new messages.", "Alice", 5)
print(formatted2)
-- Output: "Hello, Alice! You have 5 new messages."
```

---

### **lia.util.getMaterial**

**Description:**  
Returns a cached copy of the given material or creates and caches one if it doesn't exist. This is a quick helper function to optimize material retrieval and reduce redundant material loading.

**Realm:**  
`Shared`

**Parameters:**  

- `materialPath` (`string`):  
  The path to the material.

- `materialParameters` (`string`, optional):  
  Additional parameters for the material.

**Returns:**  
`Material|nil` - The cached material or `nil` if the material doesn't exist in the filesystem.

**Example Usage:**
```lua
local mat = lia.util.getMaterial("vgui/gradient-u", "noclamp smooth")
surface.SetMaterial(mat)
surface.SetDrawColor(255, 255, 255)
surface.DrawTexturedRect(0, 0, 256, 256)
```

---

### **lia.util.drawBlur**

**Description:**  
Blurs the content underneath the given panel. This function falls back to a simple darkened rectangle if the player has blurring disabled, ensuring consistent visual effects across different player settings.

**Realm:**  
`Client`

**Parameters:**  

- `panel` (`Panel`):  
  The panel to draw the blur for.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Defaults to `0.2`.

**Example Usage:**
```lua
function PANEL:Paint(width, height)
    lia.util.drawBlur(self)
end
```

---

### **lia.util.drawBlurAt**

**Description:**  
Draws a blurred rectangle with the specified position and bounds. This function is intended for use outside of panels and provides flexibility in where blur effects are applied on the screen.

**Realm:**  
`Client`

**Parameters:**  

- `x` (`number`):  
  X-position of the rectangle.

- `y` (`number`):  
  Y-position of the rectangle.

- `w` (`number`):  
  Width of the rectangle.

- `h` (`number`):  
  Height of the rectangle.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Defaults to `0.2`.

**Example Usage:**
```lua
hook.Add("HUDPaint", "MyHUDPaint", function()
    lia.util.drawBlurAt(100, 100, 300, 200)
end)
```

---

### **lia.util.drawTexture**

**Description:**  
Draws a textured rectangle with a specified material and color. This function simplifies the rendering of textured elements in the UI.

**Realm:**  
`Client`

**Parameters:**  

- `material` (`string`):  
  Material to use for the texture.

- `color` (`Color`, optional):  
  Color of the texture. Defaults to `Color(255, 255, 255)`.

- `x` (`number`):  
  X-position of the top-left corner of the rectangle.

- `y` (`number`):  
  Y-position of the top-left corner of the rectangle.

- `w` (`number`):  
  Width of the rectangle.

- `h` (`number`):  
  Height of the rectangle.

**Example Usage:**
```lua
lia.util.drawTexture("vgui/gradient-u", Color(255, 255, 255, 200), 500, 500, 100, 50)
```

---

### **lia.util.skinFunc**

**Description:**  
Calls a named skin function with optional arguments on a panel. This function allows for dynamic skinning of UI elements, enabling customized appearances based on skin definitions.

**Realm:**  
`Client`

**Parameters:**  

- `name` (`string`):  
  Name of the skin function to call.

- `panel` (`Panel`, optional):  
  Panel to apply the skin function to. If not provided, the default skin is used.

- `a` (`any`, optional):  
  Argument 1.

- `b` (`any`, optional):  
  Argument 2.

- `c` (`any`, optional):  
  Argument 3.

- `d` (`any`, optional):  
  Argument 4.

- `e` (`any`, optional):  
  Argument 5.

- `f` (`any`, optional):  
  Argument 6.

- `g` (`any`, optional):  
  Argument 7.

**Returns:**  
`any` - The result of the skin function call.

**Example Usage:**
```lua
local result = lia.util.skinFunc("Paint", myPanel, 255, 255, 255, 255)
```

---

### **lia.util.wrapText**

**Description:**  
Wraps text so it does not exceed a certain width. This function intelligently breaks lines between words when possible or splits words if they are too long, ensuring that text fits within designated UI elements.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  Text to wrap.

- `width` (`number`):  
  Maximum allowed width in pixels.

- `font` (`string`, optional):  
  Font to use for the text. Defaults to `"liaChatFont"`.

**Returns:**  
- `table` - A table containing the wrapped lines of text.

- `number` - The maximum width of the wrapped text.

**Example Usage:**
```lua
local wrappedLines, maxWidth = lia.util.wrapText("This is a very long piece of text that needs to be wrapped.", 300)

for _, line in ipairs(wrappedLines) do
    print(line)
end
-- Output:
-- "This is a very"
-- "long piece of"
-- "text that needs"
-- "to be wrapped."
```

---

### **lia.util.drawBlur**

**Description:**  
Blurs the content underneath the given panel. This function falls back to a simple darkened rectangle if the player has blurring disabled, ensuring consistent visual effects across different player settings.

**Realm:**  
`Client`

**Parameters:**  

- `panel` (`Panel`):  
  The panel to draw the blur for.

- `amount` (`number`, optional):  
  Intensity of the blur. Recommended to keep between `0` and `10` for performance reasons. Defaults to `5`.

- `passes` (`number`, optional):  
  Quality of the blur. Recommended to keep as default (`0.2`).

**Example Usage:**
```lua
function PANEL:Paint(width, height)
    lia.util.drawBlur(self)
end
```

---

### **lia.util.notifQuery**

**Description:**  
Displays a query notification panel with customizable options. This function is useful for prompting players with yes/no questions or binary choices, capturing their responses through key presses.

**Realm:**  
`Client`

**Parameters:**  

- `question` (`string`):  
  The question or prompt to display.

- `option1` (`string`):  
  The text for the first option.

- `option2` (`string`):  
  The text for the second option.

- `manualDismiss` (`bool`):  
  If `true`, the panel requires manual dismissal.

- `notifType` (`number`):  
  The type of notification.

- `callback` (`function`):  
  The function to call when an option is selected. It receives the option index and the notice panel as arguments.

**Returns:**  
`Panel` - The created notification panel.

**Example Usage:**
```lua
lia.util.notifQuery("Do you want to accept the quest?", "Yes", "No", false, 7, function(option, panel)
    if option == 1 then
        print("Player accepted the quest.")
    else
        print("Player declined the quest.")
    end
end)
```

---

### **lia.util.CreateTableUI**

**Description:**  
Creates and displays a table UI on the client-side. This function allows for the presentation of structured data in a user-friendly table format, facilitating activities like inventory displays, leaderboards, or data logs.

**Realm:**  
`Client`

**Parameters:**  

- `title` (`string`):  
  The title of the table UI.

- `columns` (`table`):  
  A table defining the columns in the table. Each column should have a `name`, `field`, and optionally a `width`.

- `data` (`table`):  
  A table containing rows of data. Each row should correspond to the defined columns.

- `options` (`table`, optional):  
  Additional options for the table UI, such as context menu actions.

- `charID` (`number`, optional):  
  The character ID associated with the data.

**Example Usage:**
```lua
local columns = {
    {name = "Item", field = "itemName", width = 200},
    {name = "Quantity", field = "quantity", width = 100},
    {name = "Price", field = "price", width = 100}
}

local data = {
    {itemName = "Sword", quantity = 1, price = "$100"},
    {itemName = "Shield", quantity = 2, price = "$150"},
    {itemName = "Potion", quantity = 5, price = "$50"}
}

local options = {
    {name = "Use Item", net = "UseItem", ExtraFields = {confirm = "Are you sure you want to use this item?"}},
    {name = "Drop Item", net = "DropItem"}
}

lia.util.CreateTableUI("Inventory", columns, data, options, characterID)
```

---

### **lia.util.findEmptySpace** *(Server Only)*

**Description:**  
Finds empty spaces around an entity where another entity can be placed. This function ensures that new entities are spawned in valid locations without overlapping existing objects or terrain, maintaining the game's spatial integrity.

**Realm:**  
`Server`

**Parameters:**  

- `entity` (`Entity`):  
  The entity around which to search for empty spaces.

- `filter` (`table`, optional):  
  Entities to exclude from the collision check.

- `spacing` (`number`, optional):  
  Spacing between empty spaces. Defaults to `32` units.

- `size` (`number`, optional):  
  Size of the search grid. Defaults to `3`.

- `height` (`number`):  
  Height of the search grid. Defaults to `36` units.

- `tolerance` (`number`):  
  Tolerance for collision checking. Defaults to `5` units.

**Returns:**  
`table` - A table containing positions of empty spaces.

**Example Usage:**
```lua
local entity = ents.FindByClass("prop_physics")[1]
local emptyPositions = lia.util.findEmptySpace(entity)

for _, pos in ipairs(emptyPositions) do
    print("Empty position found at:", pos)
end
```

---

## Variables

### **lia.util**

**Description:**  
A table that stores all registered utility functions. These functions extend the capabilities of both client and server realms, providing additional functionalities for developers to enhance their schemas and plugins.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access and use the FindPlayersInBox function
local mins = Vector(-100, -100, 0)
local maxs = Vector(100, 100, 200)
local playersInBox = lia.util.FindPlayersInBox(mins, maxs)

for _, ply in ipairs(playersInBox) do
    ply:ChatPrint("You are within the designated area!")
end
```

---