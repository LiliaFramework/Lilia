# Derma Library

Advanced UI rendering and interaction system for the Lilia framework.

---

## Overview

The derma library provides comprehensive UI rendering and interaction functionality for the Lilia framework. It handles advanced drawing operations including rounded rectangles, circles, shadows, blur effects, and gradients using custom shaders. The library offers a fluent API for creating complex UI elements with smooth animations, color pickers, player selectors, and various input dialogs. It includes utility functions for text rendering with shadows and outlines, entity text display, and menu positioning. The library operates primarily on the client side and provides both low-level drawing functions and high-level UI components for creating modern, visually appealing interfaces.

---

### lia.derma.dermaMenu

**Purpose**

Creates a context menu at the current mouse cursor position

**When Called**

When right-clicking or when a context menu is needed

**Returns**

* Panel - The created context menu panel

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create a basic context menu
local menu = lia.derma.dermaMenu()
menu:AddOption("Option 1", function() print("Option 1 clicked") end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create context menu with multiple options
local menu = lia.derma.dermaMenu()
menu:AddOption("Edit", function() editItem() end)
menu:AddOption("Delete", function() deleteItem() end)
menu:AddSpacer()
menu:AddOption("Properties", function() showProperties() end)
```
```

**High Complexity:**
```lua
```lua
-- High: Create dynamic context menu based on conditions
local menu = lia.derma.dermaMenu()
if player:IsAdmin() then
menu:AddOption("Admin Action", function() adminAction() end)
end
if item:CanUse() then
menu:AddOption("Use Item", function() item:Use() end)
end
menu:AddOption("Inspect", function() inspectItem(item) end)
```
```

---

### lia.derma.colorPicker

**Purpose**

Opens a color picker dialog for selecting colors

**When Called**

When user needs to select a color from a visual picker interface

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open color picker with callback
lia.derma.colorPicker(function(color)
print("Selected color:", color.r, color.g, color.b)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Open color picker with default color
local defaultColor = Color(255, 0, 0)
lia.derma.colorPicker(function(color)
myPanel:SetColor(color)
end, defaultColor)
```
```

**High Complexity:**
```lua
```lua
-- High: Color picker with validation and multiple callbacks
local currentColor = settings:GetColor("theme_color")
lia.derma.colorPicker(function(color)
if color:Distance(currentColor) > 50 then
settings:SetColor("theme_color", color)
updateTheme(color)
notify("Theme color updated!")
end
end, currentColor)
```
```

---

### lia.derma.playerSelector

**Purpose**

Opens a player selection dialog showing all connected players

**When Called**

When user needs to select a player from a list

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open player selector with callback
lia.derma.playerSelector(function(player)
print("Selected player:", player:Name())
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Player selector with validation
lia.derma.playerSelector(function(player)
if IsValid(player) and player:IsPlayer() then
sendMessage(player, "Hello!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Player selector with admin checks and multiple actions
lia.derma.playerSelector(function(player)
if not IsValid(player) then return end
local menu = lia.derma.dermaMenu()
menu:AddOption("Teleport", function() teleportToPlayer(player) end)
menu:AddOption("Spectate", function() spectatePlayer(player) end)
if player:IsAdmin() then
menu:AddOption("Admin Panel", function() openAdminPanel(player) end)
end
menu:Open()
end)
```
```

---

### lia.CreatePlayerCard

**Purpose**

Opens a player selection dialog showing all connected players

**When Called**

When user needs to select a player from a list

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open player selector with callback
lia.derma.playerSelector(function(player)
print("Selected player:", player:Name())
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Player selector with validation
lia.derma.playerSelector(function(player)
if IsValid(player) and player:IsPlayer() then
sendMessage(player, "Hello!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Player selector with admin checks and multiple actions
lia.derma.playerSelector(function(player)
if not IsValid(player) then return end
local menu = lia.derma.dermaMenu()
menu:AddOption("Teleport", function() teleportToPlayer(player) end)
menu:AddOption("Spectate", function() spectatePlayer(player) end)
if player:IsAdmin() then
menu:AddOption("Admin Panel", function() openAdminPanel(player) end)
end
menu:Open()
end)
```
```

---

### lia.derma.textBox

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.apply_func

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.getShader

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.newFlag

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.createShaderMat

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.resetParams

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.nzr

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.clamp0

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.normalizeCornerRadii

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.setupDraw

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.drawRounded

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Open text input dialog
lia.derma.textBox("Enter Name", "Type your name here", function(text)
print("Entered:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(text)
if string.len(text) >= 6 then
setPassword(text)
else
notify("Password too short!")
end
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Text input with multiple validations and processing
lia.derma.textBox("Create Item", "Enter item name", function(text)
if not text or text == "" then return end
local cleanText = string.Trim(text)
if string.len(cleanText) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanText) then
notify("Item already exists!")
return
end
createItem(cleanText)
refreshItemList()
end)
```
```

---

### lia.derma.draw

**Purpose**

Draws a rounded rectangle with specified parameters

**When Called**

When rendering UI elements that need rounded corners

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw a basic rounded rectangle
lia.derma.draw(8, 100, 100, 200, 100, Color(255, 0, 0))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom flags and color
local flags = lia.derma.SHAPE_IOS
lia.derma.draw(12, 50, 50, 300, 150, Color(0, 255, 0, 200), flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic drawing with conditions
local radius = isHovered and 16 or 8
local color = isSelected and Color(255, 255, 0) or Color(100, 100, 100)
local flags = bit.bor(lia.derma.SHAPE_FIGMA, lia.derma.BLUR)
lia.derma.draw(radius, x, y, w, h, color, flags)
```
```

---

### lia.derma.drawOutlined

**Purpose**

Draws a rounded rectangle with an outline border

**When Called**

When rendering UI elements that need outlined rounded corners

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw outlined rounded rectangle
lia.derma.drawOutlined(8, 100, 100, 200, 100, Color(255, 0, 0), 2)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom thickness and flags
local flags = lia.derma.SHAPE_IOS
lia.derma.drawOutlined(12, 50, 50, 300, 150, Color(0, 255, 0), 3, flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic outlined drawing with hover effects
local thickness = isHovered and 3 or 1
local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
lia.derma.drawOutlined(radius, x, y, w, h, color, thickness, flags)
```
```

---

### lia.derma.drawTexture

**Purpose**

Draws a rounded rectangle with a texture applied

**When Called**

When rendering UI elements that need textured rounded backgrounds

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw textured rounded rectangle
local texture = Material("icon16/user.png"):GetTexture("$basetexture")
lia.derma.drawTexture(8, 100, 100, 200, 100, Color(255, 255, 255), texture)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with color tint and custom flags
local texture = Material("gui/button.png"):GetTexture("$basetexture")
local flags = lia.derma.SHAPE_IOS
lia.derma.drawTexture(12, 50, 50, 300, 150, Color(200, 200, 200), texture, flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic textured drawing with multiple textures
local texture = isHovered and hoverTexture or normalTexture
local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
lia.derma.drawTexture(radius, x, y, w, h, color, texture, flags)
```
```

---

### lia.derma.drawMaterial

**Purpose**

Draws a rounded rectangle with a material applied

**When Called**

When rendering UI elements that need material-based rounded backgrounds

**Returns**

* boolean - Success status (if material has valid texture)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw material-based rounded rectangle
local mat = Material("gui/button.png")
lia.derma.drawMaterial(8, 100, 100, 200, 100, Color(255, 255, 255), mat)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with color tint and validation
local mat = Material("effects/fire_cloud1")
if mat and mat:IsValid() then
lia.derma.drawMaterial(12, 50, 50, 300, 150, Color(255, 200, 0), mat)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic material drawing with fallback
local mat = getMaterialForState(currentState)
if mat and mat:IsValid() then
local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
lia.derma.drawMaterial(radius, x, y, w, h, color, mat, flags)
else
-- Fallback to solid color
lia.derma.draw(radius, x, y, w, h, fallbackColor, flags)
end
```
```

---

### lia.derma.drawCircle

**Purpose**

Draws a filled circle with specified parameters

**When Called**

When rendering circular UI elements like buttons or indicators

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw a basic circle
lia.derma.drawCircle(100, 100, 50, Color(255, 0, 0))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw circle with custom flags
local flags = lia.derma.SHAPE_CIRCLE
lia.derma.drawCircle(200, 200, 75, Color(0, 255, 0, 200), flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic circle drawing with hover effects
local radius = isHovered and 60 or 50
local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
lia.derma.drawCircle(x, y, radius, color, flags)
```
```

---

### lia.derma.drawCircleOutlined

**Purpose**

Draws a circle with an outline border

**When Called**

When rendering circular UI elements that need outlined borders

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw outlined circle
lia.derma.drawCircleOutlined(100, 100, 50, Color(255, 0, 0), 2)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom thickness and flags
local flags = lia.derma.SHAPE_CIRCLE
lia.derma.drawCircleOutlined(200, 200, 75, Color(0, 255, 0), 3, flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic outlined circle with hover effects
local thickness = isHovered and 3 or 1
local color = isActive and Color(255, 255, 0) or Color(100, 100, 100)
lia.derma.drawCircleOutlined(x, y, radius, color, thickness, flags)
```
```

---

### lia.derma.drawCircleTexture

**Purpose**

Draws a circle with a texture applied

**When Called**

When rendering circular UI elements that need textured backgrounds

**Returns**

* boolean - Success status

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw textured circle
local texture = Material("icon16/user.png"):GetTexture("$basetexture")
lia.derma.drawCircleTexture(100, 100, 50, Color(255, 255, 255), texture)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with color tint and custom flags
local texture = Material("gui/button.png"):GetTexture("$basetexture")
local flags = lia.derma.SHAPE_CIRCLE
lia.derma.drawCircleTexture(200, 200, 75, Color(200, 200, 200), texture, flags)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic textured circle with multiple textures
local texture = isHovered and hoverTexture or normalTexture
local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
lia.derma.drawCircleTexture(x, y, radius, color, texture, flags)
```
```

---

### lia.derma.drawCircleMaterial

**Purpose**

Draws a circle with a material applied

**When Called**

When rendering circular UI elements that need material-based backgrounds

**Returns**

* boolean - Success status (if material has valid texture)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw material-based circle
local mat = Material("gui/button.png")
lia.derma.drawCircleMaterial(100, 100, 50, Color(255, 255, 255), mat)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with color tint and validation
local mat = Material("effects/fire_cloud1")
if mat and mat:IsValid() then
lia.derma.drawCircleMaterial(200, 200, 75, Color(255, 200, 0), mat)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic material circle with fallback
local mat = getMaterialForState(currentState)
if mat and mat:IsValid() then
local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
lia.derma.drawCircleMaterial(x, y, radius, color, mat, flags)
else
-- Fallback to solid color circle
lia.derma.drawCircle(x, y, radius, fallbackColor, flags)
end
```
```

---

### lia.drawBlur

**Purpose**

Draws a circle with a material applied

**When Called**

When rendering circular UI elements that need material-based backgrounds

**Returns**

* boolean - Success status (if material has valid texture)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw material-based circle
local mat = Material("gui/button.png")
lia.derma.drawCircleMaterial(100, 100, 50, Color(255, 255, 255), mat)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with color tint and validation
local mat = Material("effects/fire_cloud1")
if mat and mat:IsValid() then
lia.derma.drawCircleMaterial(200, 200, 75, Color(255, 200, 0), mat)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic material circle with fallback
local mat = getMaterialForState(currentState)
if mat and mat:IsValid() then
local color = isActive and Color(255, 255, 255) or Color(150, 150, 150)
lia.derma.drawCircleMaterial(x, y, radius, color, mat, flags)
else
-- Fallback to solid color circle
lia.derma.drawCircle(x, y, radius, fallbackColor, flags)
end
```
```

---

### lia.derma.drawBlur

**Purpose**

Draws a blurred rounded rectangle using custom shaders

**When Called**

When rendering UI elements that need blur effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blurred rectangle
lia.derma.drawBlur(100, 100, 200, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom corner radii and flags
local flags = lia.derma.SHAPE_IOS
lia.derma.drawBlur(50, 50, 300, 150, flags, 12, 12, 12, 12)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with different corner radii
local tl = isTopLeft and 16 or 8
local tr = isTopRight and 16 or 8
local bl = isBottomLeft and 16 or 8
local br = isBottomRight and 16 or 8
lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
```
```

---

### lia.setupShadows

**Purpose**

Draws a blurred rounded rectangle using custom shaders

**When Called**

When rendering UI elements that need blur effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blurred rectangle
lia.derma.drawBlur(100, 100, 200, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom corner radii and flags
local flags = lia.derma.SHAPE_IOS
lia.derma.drawBlur(50, 50, 300, 150, flags, 12, 12, 12, 12)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with different corner radii
local tl = isTopLeft and 16 or 8
local tr = isTopRight and 16 or 8
local bl = isBottomLeft and 16 or 8
local br = isBottomRight and 16 or 8
lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
```
```

---

### lia.drawShadows

**Purpose**

Draws a blurred rounded rectangle using custom shaders

**When Called**

When rendering UI elements that need blur effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blurred rectangle
lia.derma.drawBlur(100, 100, 200, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom corner radii and flags
local flags = lia.derma.SHAPE_IOS
lia.derma.drawBlur(50, 50, 300, 150, flags, 12, 12, 12, 12)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with different corner radii
local tl = isTopLeft and 16 or 8
local tr = isTopRight and 16 or 8
local bl = isBottomLeft and 16 or 8
local br = isBottomRight and 16 or 8
lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
```
```

---

### lia.derma.drawShadowsEx

**Purpose**

Draws shadows for rounded rectangles with extensive customization

**When Called**

When rendering UI elements that need shadow effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw basic shadow
lia.derma.drawShadowsEx(100, 100, 200, 100, Color(0, 0, 0, 100))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom spread and intensity
lia.derma.drawShadowsEx(50, 50, 300, 150, Color(0, 0, 0, 150), flags, 12, 12, 12, 12, 20, 25)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic shadow with different corner radii
local spread = isHovered and 40 or 20
local intensity = spread * 1.5
lia.derma.drawShadowsEx(x, y, w, h, shadowColor, flags, tl, tr, bl, br, spread, intensity, thickness)
```
```

---

### lia.derma.drawShadows

**Purpose**

Draws shadows for rounded rectangles with uniform corner radius

**When Called**

When rendering UI elements that need shadow effects with same corner radius

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw basic shadow with uniform radius
lia.derma.drawShadows(8, 100, 100, 200, 100, Color(0, 0, 0, 100))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom spread and intensity
lia.derma.drawShadows(12, 50, 50, 300, 150, Color(0, 0, 0, 150), 20, 25)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic shadow with hover effects
local radius = isHovered and 16 or 8
local spread = isHovered and 40 or 20
local intensity = spread * 1.5
lia.derma.drawShadows(radius, x, y, w, h, shadowColor, spread, intensity, flags)
```
```

---

### lia.derma.drawShadowsOutlined

**Purpose**

Draws outlined shadows for rounded rectangles with uniform corner radius

**When Called**

When rendering UI elements that need outlined shadow effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw outlined shadow
lia.derma.drawShadowsOutlined(8, 100, 100, 200, 100, Color(0, 0, 0, 100), 2)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom thickness and spread
lia.derma.drawShadowsOutlined(12, 50, 50, 300, 150, Color(0, 0, 0, 150), 3, 20, 25)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic outlined shadow with hover effects
local thickness = isHovered and 3 or 1
local spread = isHovered and 40 or 20
local intensity = spread * 1.5
lia.derma.drawShadowsOutlined(radius, x, y, w, h, shadowColor, thickness, spread, intensity, flags)
```
```

---

### lia.derma.rect

**Purpose**

Creates a fluent rectangle drawing object for chained operations

**When Called**

When creating complex UI elements with multiple drawing operations

**Returns**

* Table - Fluent drawing object with methods for chaining

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create and draw a rectangle
lia.derma.rect(100, 100, 200, 100):Color(Color(255, 0, 0)):Draw()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create rectangle with multiple properties
lia.derma.rect(50, 50, 300, 150)
:Color(Color(0, 255, 0, 200))
:Rad(12)
:Shape(lia.derma.SHAPE_IOS)
:Draw()
```
```

**High Complexity:**
```lua
```lua
-- High: Complex rectangle with shadows and clipping
lia.derma.rect(x, y, w, h)
:Color(backgroundColor)
:Radii(16, 8, 16, 8)
:Shadow(20, 25)
:Clip(parentPanel)
:Draw()
```
```

---

### lia.derma.circle

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

**Returns**

* Table - Fluent drawing object with methods for chaining

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create and draw a circle
lia.derma.circle(100, 100, 50):Color(Color(255, 0, 0)):Draw()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create circle with multiple properties
lia.derma.circle(200, 200, 75)
:Color(Color(0, 255, 0, 200))
:Outline(2)
:Draw()
```
```

**High Complexity:**
```lua
```lua
-- High: Complex circle with shadows and textures
lia.derma.circle(x, y, radius)
:Color(circleColor)
:Texture(circleTexture)
:Shadow(15, 20)
:Blur(1.5)
:Draw()
```
```

---

### lia.derma.setFlag

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

**Returns**

* Table - Fluent drawing object with methods for chaining

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create and draw a circle
lia.derma.circle(100, 100, 50):Color(Color(255, 0, 0)):Draw()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create circle with multiple properties
lia.derma.circle(200, 200, 75)
:Color(Color(0, 255, 0, 200))
:Outline(2)
:Draw()
```
```

**High Complexity:**
```lua
```lua
-- High: Complex circle with shadows and textures
lia.derma.circle(x, y, radius)
:Color(circleColor)
:Texture(circleTexture)
:Shadow(15, 20)
:Blur(1.5)
:Draw()
```
```

---

### lia.derma.setDefaultShape

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

**Returns**

* Table - Fluent drawing object with methods for chaining

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create and draw a circle
lia.derma.circle(100, 100, 50):Color(Color(255, 0, 0)):Draw()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create circle with multiple properties
lia.derma.circle(200, 200, 75)
:Color(Color(0, 255, 0, 200))
:Outline(2)
:Draw()
```
```

**High Complexity:**
```lua
```lua
-- High: Complex circle with shadows and textures
lia.derma.circle(x, y, radius)
:Color(circleColor)
:Texture(circleTexture)
:Shadow(15, 20)
:Blur(1.5)
:Draw()
```
```

---

### lia.derma.shadowText

**Purpose**

Draws text with a shadow effect for better readability

**When Called**

When rendering text that needs to stand out against backgrounds

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text with shadow
lia.derma.shadowText("Hello World", "DermaDefault", 100, 100, Color(255, 255, 255), Color(0, 0, 0), 2)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom alignment
lia.derma.shadowText("Centered Text", "LiliaFont.20", 200, 200, Color(255, 255, 255), Color(0, 0, 0, 150), 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic shadow text with hover effects
local shadowDist = isHovered and 4 or 2
local shadowColor = Color(0, 0, 0, isHovered and 200 or 100)
lia.derma.shadowText(text, font, x, y, textColor, shadowColor, shadowDist, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

---

### lia.derma.drawTextOutlined

**Purpose**

Draws text with an outline border for better visibility

**When Called**

When rendering text that needs to stand out with outline effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw outlined text
lia.derma.drawTextOutlined("Hello World", "DermaDefault", 100, 100, Color(255, 255, 255), TEXT_ALIGN_LEFT, 2, Color(0, 0, 0))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom alignment and outline
lia.derma.drawTextOutlined("Centered Text", "LiliaFont.20", 200, 200, Color(255, 255, 255), TEXT_ALIGN_CENTER, 3, Color(0, 0, 0, 200))
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic outlined text with hover effects
local outlineWidth = isHovered and 4 or 2
local outlineColor = Color(0, 0, 0, isHovered and 255 or 150)
lia.derma.drawTextOutlined(text, font, x, y, textColor, TEXT_ALIGN_CENTER, outlineWidth, outlineColor)
```
```

---

### lia.derma.drawTip

**Purpose**

Draws a tooltip-style speech bubble with text

**When Called**

When rendering tooltips or help text in speech bubble format

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw basic tooltip
lia.derma.drawTip(100, 100, 200, 80, "Help text", "DermaDefault", Color(255, 255, 255), Color(0, 0, 0))
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom styling
lia.derma.drawTip(50, 50, 300, 100, "This is a tooltip", "LiliaFont.16", Color(255, 255, 255), Color(100, 100, 100))
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic tooltip with hover effects
local w = math.max(200, surface.GetTextSize(text) + 40)
local h = 60
local textColor = Color(255, 255, 255)
local outlineColor = Color(0, 0, 0, isHovered and 200 or 100)
lia.derma.drawTip(x, y, w, h, text, font, textColor, outlineColor)
```
```

---

### lia.derma.drawText

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text with automatic shadow
lia.derma.drawText("Hello World", 100, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom color and alignment
lia.derma.drawText("Centered Text", 200, 200, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic text with hover effects
local textColor = Color(255, 255, 255)
local alpha = isHovered and 1.0 or 0.7
lia.derma.drawText(text, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, font, alpha)
```
```

---

### lia.derma.drawBoxWithText

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text with automatic shadow
lia.derma.drawText("Hello World", 100, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom color and alignment
lia.derma.drawText("Centered Text", 200, 200, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic text with hover effects
local textColor = Color(255, 255, 255)
local alpha = isHovered and 1.0 or 0.7
lia.derma.drawText(text, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, font, alpha)
```
```

---

### lia.derma.drawSurfaceTexture

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text with automatic shadow
lia.derma.drawText("Hello World", 100, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom color and alignment
lia.derma.drawText("Centered Text", 200, 200, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic text with hover effects
local textColor = Color(255, 255, 255)
local alpha = isHovered and 1.0 or 0.7
lia.derma.drawText(text, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, font, alpha)
```
```

---

### lia.derma.skinFunc

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw text with automatic shadow
lia.derma.drawText("Hello World", 100, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom color and alignment
lia.derma.drawText("Centered Text", 200, 200, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic text with hover effects
local textColor = Color(255, 255, 255)
local alpha = isHovered and 1.0 or 0.7
lia.derma.drawText(text, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, font, alpha)
```
```

---

### lia.derma.approachExp

**Purpose**

Performs exponential interpolation between current and target values

**When Called**

When smooth animation transitions are needed

**Returns**

* number - New interpolated value

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Smooth value transition
local currentValue = lia.derma.approachExp(currentValue, targetValue, 5, FrameTime())
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Animate panel alpha
local targetAlpha = isVisible and 255 or 0
panel:SetAlpha(lia.derma.approachExp(panel:GetAlpha(), targetAlpha, 8, FrameTime()))
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with multiple properties
local dt = FrameTime()
local targetX = isHovered and hoverX or normalX
local targetY = isHovered and hoverY or normalY
local targetScale = isHovered and 1.1 or 1.0
panel:SetPos(
lia.derma.approachExp(panel:GetPos(), targetX, 6, dt),
lia.derma.approachExp(panel:GetPos(), targetY, 6, dt)
)
panel:SetSize(
lia.derma.approachExp(panel:GetWide(), targetW * targetScale, 4, dt),
lia.derma.approachExp(panel:GetTall(), targetH * targetScale, 4, dt)
)
```
```

---

### lia.derma.easeOutCubic

**Purpose**

Applies cubic ease-out easing function to a normalized time value

**When Called**

When smooth deceleration animations are needed

**Returns**

* number - Eased value

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Apply ease-out to animation progress
local eased = lia.derma.easeOutCubic(animationProgress)
panel:SetAlpha(eased * 255)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Smooth panel movement with ease-out
local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
local eased = lia.derma.easeOutCubic(progress)
panel:SetPos(startX + (endX - startX) * eased, startY + (endY - startY) * eased)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with multiple eased properties
local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
local eased = lia.derma.easeOutCubic(progress)
panel:SetPos(
startX + (endX - startX) * eased,
startY + (endY - startY) * eased
)
panel:SetSize(
startW + (endW - startW) * eased,
startH + (endH - startH) * eased
)
panel:SetAlpha(startAlpha + (endAlpha - startAlpha) * eased)
```
```

---

### lia.derma.easeInOutCubic

**Purpose**

Applies cubic ease-in-out easing function to a normalized time value

**When Called**

When smooth acceleration and deceleration animations are needed

**Returns**

* number - Eased value

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Apply ease-in-out to animation progress
local eased = lia.derma.easeInOutCubic(animationProgress)
panel:SetAlpha(eased * 255)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Smooth panel scaling with ease-in-out
local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
local eased = lia.derma.easeInOutCubic(progress)
local scale = startScale + (endScale - startScale) * eased
panel:SetSize(baseW * scale, baseH * scale)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex UI animation with ease-in-out
local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
local eased = lia.derma.easeInOutCubic(progress)
-- Animate position, size, and rotation
panel:SetPos(
startX + (endX - startX) * eased,
startY + (endY - startY) * eased
)
panel:SetSize(
startW + (endW - startW) * eased,
startH + (endH - startH) * eased
)
panel:SetRotation(startRotation + (endRotation - startRotation) * eased)
```
```

---

### lia.derma.animateAppearance

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Animate panel appearance
lia.derma.animateAppearance(myPanel, 300, 200)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Animate with custom duration and callback
lia.derma.animateAppearance(myPanel, 400, 300, 0.3, 0.2, function(panel)
print("Animation completed!")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with validation and effects
if IsValid(panel) then
local targetW = isExpanded and 500 or 300
local targetH = isExpanded and 400 or 200
local duration = isExpanded and 0.25 or 0.15
local scaleFactor = isExpanded and 0.9 or 0.7
lia.derma.animateAppearance(panel, targetW, targetH, duration, duration * 0.8, function(animPanel)
if IsValid(animPanel) then
onAnimationComplete(animPanel)
end
end, scaleFactor)
end
```
```

---

### lia.derma.clampMenuPosition

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Animate panel appearance
lia.derma.animateAppearance(myPanel, 300, 200)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Animate with custom duration and callback
lia.derma.animateAppearance(myPanel, 400, 300, 0.3, 0.2, function(panel)
print("Animation completed!")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with validation and effects
if IsValid(panel) then
local targetW = isExpanded and 500 or 300
local targetH = isExpanded and 400 or 200
local duration = isExpanded and 0.25 or 0.15
local scaleFactor = isExpanded and 0.9 or 0.7
lia.derma.animateAppearance(panel, targetW, targetH, duration, duration * 0.8, function(animPanel)
if IsValid(animPanel) then
onAnimationComplete(animPanel)
end
end, scaleFactor)
end
```
```

---

### lia.derma.drawGradient

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Animate panel appearance
lia.derma.animateAppearance(myPanel, 300, 200)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Animate with custom duration and callback
lia.derma.animateAppearance(myPanel, 400, 300, 0.3, 0.2, function(panel)
print("Animation completed!")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with validation and effects
if IsValid(panel) then
local targetW = isExpanded and 500 or 300
local targetH = isExpanded and 400 or 200
local duration = isExpanded and 0.25 or 0.15
local scaleFactor = isExpanded and 0.9 or 0.7
lia.derma.animateAppearance(panel, targetW, targetH, duration, duration * 0.8, function(animPanel)
if IsValid(animPanel) then
onAnimationComplete(animPanel)
end
end, scaleFactor)
end
```
```

---

### lia.derma.wrapText

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Animate panel appearance
lia.derma.animateAppearance(myPanel, 300, 200)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Animate with custom duration and callback
lia.derma.animateAppearance(myPanel, 400, 300, 0.3, 0.2, function(panel)
print("Animation completed!")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex animation with validation and effects
if IsValid(panel) then
local targetW = isExpanded and 500 or 300
local targetH = isExpanded and 400 or 200
local duration = isExpanded and 0.25 or 0.15
local scaleFactor = isExpanded and 0.9 or 0.7
lia.derma.animateAppearance(panel, targetW, targetH, duration, duration * 0.8, function(animPanel)
if IsValid(animPanel) then
onAnimationComplete(animPanel)
end
end, scaleFactor)
end
```
```

---

### lia.derma.drawBlur

**Purpose**

Draws blur effect behind a panel using screen space effects

**When Called**

When rendering panel backgrounds that need blur effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blur behind panel
lia.derma.drawBlur(myPanel)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom blur settings
lia.derma.drawBlur(myPanel, 8, 0.3, 200)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with panel validation
if IsValid(panel) and panel:IsVisible() then
local amount = isHovered and 10 or 5
local alpha = isActive and 255 or 150
lia.derma.drawBlur(panel, amount, 0.2, alpha)
end
```
```

---

### lia.derma.drawBlackBlur

**Purpose**

Draws blur effect behind a panel using screen space effects

**When Called**

When rendering panel backgrounds that need blur effects

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blur behind panel
lia.derma.drawBlur(myPanel)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom blur settings
lia.derma.drawBlur(myPanel, 8, 0.3, 200)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with panel validation
if IsValid(panel) and panel:IsVisible() then
local amount = isHovered and 10 or 5
local alpha = isActive and 255 or 150
lia.derma.drawBlur(panel, amount, 0.2, alpha)
end
```
```

---

### lia.derma.drawBlurAt

**Purpose**

Draws blur effect at specific screen coordinates

**When Called**

When rendering blur effects at specific screen positions

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw blur at specific position
lia.derma.drawBlurAt(100, 100, 200, 100)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom blur settings
lia.derma.drawBlurAt(50, 50, 300, 150, 8, 0.3, 200)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic blur with screen bounds checking
local x, y = getScreenPosition()
local w, h = getBlurSize()
if x >= 0 and y >= 0 and x + w <= ScrW() and y + h <= ScrH() then
local amount = isHovered and 10 or 5
lia.derma.drawBlurAt(x, y, w, h, amount, 0.2, 255)
end
```
```

---

### lia.derma.requestArguments

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.trigger

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.derma.createTableUI

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.derma.openOptionsMenu

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.scaleColorAlpha

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.EntText

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request basic arguments
local argTypes = {
name = "string",
age = "number",
isActive = "boolean"
}
lia.derma.requestArguments("User Info", argTypes, function(success, results)
if success then
print("Name:", results.name, "Age:", results.age)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with dropdown and defaults
local argTypes = {
{name = "player", type = "player"},
{name = "action", type = "table", data = {"kick", "ban", "mute"}},
{name = "reason", type = "string"}
}
local defaults = {reason = "No reason provided"}
lia.derma.requestArguments("Admin Action", argTypes, onSubmit, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Complex argument validation with ordered fields
local argTypes = {
{name = "itemName", type = "string"},
{name = "itemType", type = "table", data = {{"Weapon", "weapon"}, {"Tool", "tool"}}},
{name = "quantity", type = "number"},
{name = "isStackable", type = "boolean"}
}
lia.derma.requestArguments("Create Item", argTypes, function(success, results)
if success and validateItemData(results) then
createItem(results)
end
end)
```
```

---

### lia.derma.drawEntText

**Purpose**

Draws text above entities in 3D space with distance-based scaling

**When Called**

When rendering entity labels or information in 3D space

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Draw entity name
lia.derma.drawEntText(entity, entity:GetName())
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Draw with custom offset and alpha
lia.derma.drawEntText(entity, "Custom Text", 20, 200)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic entity text with conditions
if IsValid(entity) and entity:IsPlayer() then
local text = entity:Name()
if entity:IsAdmin() then
text = "[ADMIN] " .. text
end
local alpha = entity:IsTyping() and 150 or 255
lia.derma.drawEntText(entity, text, 0, alpha)
end
```
```

---

### lia.derma.requestDropdown

**Purpose**

Creates a dropdown selection dialog for user choice

**When Called**

When user needs to select from a list of options

**Returns**

* Panel - The created dialog frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request dropdown selection
local options = {"Option 1", "Option 2", "Option 3"}
lia.derma.requestDropdown("Choose Option", options, function(selected)
print("Selected:", selected)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with data values and default
local options = {
{"Kick Player", "kick"},
{"Ban Player", "ban"},
{"Mute Player", "mute"}
}
lia.derma.requestDropdown("Admin Action", options, function(text, data)
performAction(data)
end, "kick")
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic options with validation
local options = {}
for _, player in pairs(player.GetAll()) do
if IsValid(player) then
table.insert(options, {player:Name(), player:SteamID()})
end
end
lia.derma.requestDropdown("Select Player", options, function(name, steamid)
if steamid and steamid ~= "" then
processPlayerSelection(steamid)
end
end)
```
```

---

### lia.derma.requestString

**Purpose**

Creates a text input dialog for user string entry

**When Called**

When user needs to input text through a dialog

**Returns**

* Panel - The created dialog frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request text input
lia.derma.requestString("Enter Name", "Type your name:", function(text)
if text and text ~= "" then
print("Name:", text)
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with default value and max length
lia.derma.requestString("Set Password", "Enter new password:", function(password)
if string.len(password) >= 6 then
setPassword(password)
end
end, "", 20)
```
```

**High Complexity:**
```lua
```lua
-- High: Request with validation and processing
lia.derma.requestString("Create Item", "Enter item name:", function(name)
if not name or name == "" then return end
local cleanName = string.Trim(name)
if string.len(cleanName) < 3 then
notify("Name too short!")
return
end
if itemExists(cleanName) then
notify("Item already exists!")
return
end
createItem(cleanName)
end, "", 50)
```
```

---

### lia.derma.requestOptions

**Purpose**

Creates a multi-select dialog for choosing multiple options

**When Called**

When user needs to select multiple options from a list

**Returns**

* Panel - The created dialog frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request multiple selections
local options = {"Option 1", "Option 2", "Option 3"}
lia.derma.requestOptions("Choose Options", options, function(selected)
print("Selected:", table.concat(selected, ", "))
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with data values and defaults
local options = {
{"Admin", "admin"},
{"Moderator", "moderator"},
{"VIP", "vip"}
}
local defaults = {"admin"}
lia.derma.requestOptions("Select Roles", options, function(selected)
assignRoles(selected)
end, defaults)
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic options with validation
local options = {}
for _, permission in pairs(availablePermissions) do
table.insert(options, {permission.displayName, permission.id})
end
lia.derma.requestOptions("Select Permissions", options, function(selected)
if #selected > 0 then
validateAndAssignPermissions(selected)
else
notify("Please select at least one permission!")
end
end, userPermissions)
```
```

---

### lia.derma.requestBinaryQuestion

**Purpose**

Creates a yes/no confirmation dialog

**When Called**

When user confirmation is needed for an action

**Returns**

* Panel - The created dialog frame

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request confirmation
lia.derma.requestBinaryQuestion("Confirm", "Are you sure?", function(result)
if result then
print("User confirmed")
else
print("User cancelled")
end
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with custom button text
lia.derma.requestBinaryQuestion("Delete Item", "Delete this item permanently?", function(result)
if result then
deleteItem(item)
end
end, "Delete", "Cancel")
```
```

**High Complexity:**
```lua
```lua
-- High: Request with validation and logging
lia.derma.requestBinaryQuestion("Admin Action", "Execute admin command: " .. command .. "?", function(result)
if result then
if validateAdminCommand(command) then
executeAdminCommand(command)
logAdminAction(command)
else
notify("Invalid command!")
end
end
end, "Execute", "Cancel")
```
```

---

### lia.description

**Purpose**

Creates a dialog with multiple action buttons

**When Called**

When user needs to choose from multiple actions

**Returns**

* Panel, Table - The created dialog frame and button panels array

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request button selection
local buttons = {"Option 1", "Option 2", "Option 3"}
lia.derma.requestButtons("Choose Action", buttons, function(index, text)
print("Selected:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with custom callbacks and icons
local buttons = {
{text = "Edit", callback = function() editItem() end, icon = "icon16/pencil.png"},
{text = "Delete", callback = function() deleteItem() end, icon = "icon16/delete.png"},
{text = "Copy", callback = function() copyItem() end, icon = "icon16/copy.png"}
}
lia.derma.requestButtons("Item Actions", buttons, nil, "Choose an action for this item")
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic buttons with validation
local buttons = {}
if player:IsAdmin() then
table.insert(buttons, {text = "Admin Panel", callback = function() openAdminPanel() end})
end
if item:CanEdit() then
table.insert(buttons, {text = "Edit", callback = function() editItem(item) end})
end
table.insert(buttons, {text = "View", callback = function() viewItem(item) end})
lia.derma.requestButtons("Item Options", buttons, function(index, text)
logAction("Button clicked: " .. text)
end, "Available actions for " .. item:GetName())
```
```

---

### lia.derma.requestButtons

**Purpose**

Creates a dialog with multiple action buttons

**When Called**

When user needs to choose from multiple actions

**Returns**

* Panel, Table - The created dialog frame and button panels array

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Request button selection
local buttons = {"Option 1", "Option 2", "Option 3"}
lia.derma.requestButtons("Choose Action", buttons, function(index, text)
print("Selected:", text)
end)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Request with custom callbacks and icons
local buttons = {
{text = "Edit", callback = function() editItem() end, icon = "icon16/pencil.png"},
{text = "Delete", callback = function() deleteItem() end, icon = "icon16/delete.png"},
{text = "Copy", callback = function() copyItem() end, icon = "icon16/copy.png"}
}
lia.derma.requestButtons("Item Actions", buttons, nil, "Choose an action for this item")
```
```

**High Complexity:**
```lua
```lua
-- High: Dynamic buttons with validation
local buttons = {}
if player:IsAdmin() then
table.insert(buttons, {text = "Admin Panel", callback = function() openAdminPanel() end})
end
if item:CanEdit() then
table.insert(buttons, {text = "Edit", callback = function() editItem(item) end})
end
table.insert(buttons, {text = "View", callback = function() viewItem(item) end})
lia.derma.requestButtons("Item Options", buttons, function(index, text)
logAction("Button clicked: " .. text)
end, "Available actions for " .. item:GetName())
```
```

---

