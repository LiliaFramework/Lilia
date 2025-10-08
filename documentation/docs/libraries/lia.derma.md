# Derma Library

This page documents the functions for creating and managing Derma UI elements in the Lilia framework.

---

## Overview

The derma library (`lia.derma`) provides a comprehensive collection of pre-built UI components and utilities for creating consistent, theme-aware user interfaces in the Lilia framework. This library offers a wide range of specialized UI elements including buttons, panels, frames, input controls, and selection dialogs that automatically integrate with the framework's theming system. The components are designed to provide a cohesive visual experience across all interface elements while maintaining flexibility for customization. The library includes advanced UI creation tools with automatic theme integration, responsive design capabilities, and built-in animation support that enables developers to create polished, professional-looking interfaces with minimal effort. Additionally, the system features robust input validation, accessibility support, and performance optimization to ensure smooth user interactions across different screen sizes and input methods.

---

### clampMenuPosition

**Purpose**

Clamps a menu panel's position to ensure it stays within the visible screen bounds, preventing menus from appearing partially or completely off-screen.

**Parameters**

* `panel` (*Panel*): The panel/menu to clamp the position for.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic menu position clamping
local menu = lia.derma.dermaMenu()
menu:SetSize(200, 300)
menu:SetPos(ScrW() - 50, ScrH() - 100) -- Position near screen edge
lia.derma.clampMenuPosition(menu) -- Will adjust position to stay on screen

-- Context menu positioning with clamping
local function showContextMenuAt(x, y)
    local menu = lia.derma.dermaMenu()
    menu:SetSize(150, 200)
    menu:SetPos(x, y)
    lia.derma.clampMenuPosition(menu) -- Ensure menu stays on screen
end

-- Use with mouse position for context menus
local function showContextMenuAtMouse()
    local mouseX, mouseY = input.GetCursorPos()
    showContextMenuAt(mouseX, mouseY)
end

hook.Add("OnContextMenuOpen", "ClampContextMenu", function()
    showContextMenuAtMouse()
end)

-- Custom menu positioning with fallback clamping
local function createMenuAtPosition(x, y, width, height)
    local menu = vgui.Create("DFrame")
    menu:SetSize(width, height)
    menu:SetPos(x - width/2, y - height/2) -- Center on position
    menu:MakePopup()

    -- Always clamp to ensure visibility
    lia.derma.clampMenuPosition(menu)

    return menu
end

-- Dropdown menu positioning
local function showDropdownMenu(parentPanel, options)
    local menu = lia.derma.frame(parentPanel, "Options", 200, 300)

    -- Position below parent panel
    local parentX, parentY = parentPanel:GetPos()
    menu:SetPos(parentX, parentY + parentPanel:GetTall())

    -- Clamp to screen bounds
    lia.derma.clampMenuPosition(menu)

    return menu
end

-- Notification popup positioning
local function showNotificationAtCorner(text, corner)
    local notification = vgui.Create("DPanel")
    notification:SetSize(300, 80)
    notification:SetPos(ScrW() - 310, ScrH() - 90)

    -- Clamp to ensure it doesn't go off screen
    lia.derma.clampMenuPosition(notification)

    -- Add text and styling...
end

-- Multi-monitor aware positioning
local function createMenuForScreen(screen)
    local screenX, screenY, screenW, screenH = screen.Bounds

    local menu = vgui.Create("DFrame")
    menu:SetSize(400, 300)

    -- Position in center of specific screen
    menu:SetPos(screenX + screenW/2 - 200, screenY + screenH/2 - 150)

    -- Clamp to that screen's bounds
    lia.derma.clampMenuPosition(menu)

    return menu
end
```

---

### CreateTableUI

**Purpose**

Creates a comprehensive table UI dialog for displaying data in a structured format with columns, rows, and interactive options.

**Parameters**

* `title` (*string*): The title text for the table window.
* `columns` (*table*): A table of column definitions with the following properties:
  - `name` (*string*): The localized name key for the column header.
  - `field` (*string*): The field name in the data rows to display.
  - `width` (*number*, optional): The width of the column.
* `data` (*table*): An array of data rows where each row is a table with field keys matching column definitions.
* `options` (*table*, optional): An array of action options with the following properties:
  - `name` (*string*): The localized name key for the option.
  - `net` (*string*): The network message to send when the option is selected.
  - `ExtraFields` (*table*, optional): Additional form fields for the option.
* `charID` (*number*): The character ID for network communication.

**Returns**

* `frame` (*liaDListView*): The created table frame dialog.
* `listView` (*DListView*): The underlying list view panel.

**Realm**

Client.

**Example Usage**

```lua
-- Basic table with player data
local columns = {
    {name = "playerName", field = "name"},
    {name = "playerSteamID", field = "steamID"},
    {name = "playerPing", field = "ping"}
}

local playerData = {}
for _, ply in ipairs(player.GetAll()) do
    table.insert(playerData, {
        name = ply:Name(),
        steamID = ply:SteamID(),
        ping = ply:Ping()
    })
end

local frame, listView = lia.derma.CreateTableUI("Players", columns, playerData)

-- Table with action options
local options = {
    {
        name = "kickPlayer",
        net = "KickPlayer",
        ExtraFields = {
            reason = "text"
        }
    },
    {
        name = "banPlayer",
        net = "BanPlayer"
    }
}

local frame, listView = lia.derma.CreateTableUI("Manage Players", columns, playerData, options, LocalPlayer():getChar():getID())

-- Table for item management
local itemColumns = {
    {name = "itemName", field = "name", width = 150},
    {name = "itemDesc", field = "description", width = 200},
    {name = "itemQuantity", field = "quantity"}
}

local inventoryData = {}
for itemID, itemData in pairs(LocalPlayer():getChar():getInv():getItems()) do
    table.insert(inventoryData, {
        name = itemData.name,
        description = itemData.description or "No description",
        quantity = itemData.quantity or 1
    })
end

lia.derma.CreateTableUI("Inventory", itemColumns, inventoryData, nil, LocalPlayer():getChar():getID())
```

---

### animateAppearance

**Purpose**

Animates the appearance of a panel with smooth size scaling and alpha fading transitions, creating a polished entrance effect for UI elements.

**Parameters**

* `panel` (*Panel*): The panel to animate.
* `target_w` (*number*): The target width for the panel.
* `target_h` (*number*): The target height for the panel.
* `duration` (*number*, optional): The duration of the animation in seconds (default: 0.18).
* `alpha_dur` (*number*, optional): The duration of the alpha fade in seconds (default: same as duration).
* `callback` (*function*, optional): A function to call when the animation completes.
* `scale_factor` (*number*, optional): The initial scale factor for the animation (default: 0.8).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic panel appearance animation
local frame = lia.derma.frame(nil, "Animated Frame", 400, 300)
lia.derma.animateAppearance(frame, 400, 300)

-- Custom animation with longer duration
local dialog = lia.derma.frame(nil, "Slow Animation", 500, 200)
lia.derma.animateAppearance(dialog, 500, 200, 0.5)

-- Animation with callback
local panel = vgui.Create("DPanel")
panel:SetSize(200, 100)
lia.derma.animateAppearance(panel, 200, 100, 0.3, 0.3, function()
    print("Animation completed!")
    panel:Remove()
end)

-- Animation with different scale factor
local largeFrame = lia.derma.frame(nil, "Large Animation", 800, 600)
lia.derma.animateAppearance(largeFrame, 800, 600, 0.25, 0.25, nil, 0.6)

-- Animate multiple panels sequentially
local function animatePanelsSequentially(panels, index)
    if index > #panels then return end

    local panel = panels[index]
    lia.derma.animateAppearance(panel, panel.targetW, panel.targetH, 0.2, 0.2, function()
        animatePanelsSequentially(panels, index + 1)
    end)
end

local panels = {
    {panel = panel1, targetW = 300, targetH = 200},
    {panel = panel2, targetW = 400, targetH = 150},
    {panel = panel3, targetW = 250, targetH = 300}
}

animatePanelsSequentially(panels, 1)

-- Use in menu systems for smooth transitions
local function showMenuWithAnimation(menuPanel)
    menuPanel:SetVisible(true)
    lia.derma.animateAppearance(menuPanel, menuPanel:GetWide(), menuPanel:GetTall(), 0.15)
end

-- Animate appearance of settings panels
local settingsFrame = lia.derma.frame(nil, "Settings", 600, 400)
settingsFrame:SetVisible(false)

local function openSettings()
    showMenuWithAnimation(settingsFrame)
end

-- Animate appearance with different easing
local customPanel = vgui.Create("DPanel")
customPanel:SetSize(100, 50)
lia.derma.animateAppearance(customPanel, 300, 200, 0.4, 0.4, function()
    print("Custom panel animation finished")
end, 0.9)
```

---

### approachExp

**Purpose**

Calculates an exponential approach value for smooth transitions between current and target values, commonly used for creating smooth animations and value interpolation.

**Parameters**

* `current` (*number*): The current value.
* `target` (*number*): The target value to approach.
* `speed` (*number*): The speed of the approach (higher values = faster approach).
* `dt` (*number*): The time delta (usually FrameTime()).

**Returns**

* `value` (*number*): The new value after applying exponential approach.

**Realm**

Client.

**Example Usage**

```lua
-- Basic exponential approach
local currentValue = 0
local targetValue = 100
local speed = 3.0

-- In a think hook or animation loop
local dt = FrameTime()
currentValue = lia.derma.approachExp(currentValue, targetValue, speed, dt)

-- Smooth color transition
local currentColor = Color(255, 0, 0)
local targetColor = Color(0, 255, 0)
local transitionSpeed = 2.0

local dt = FrameTime()
currentColor.r = lia.derma.approachExp(currentColor.r, targetColor.r, transitionSpeed, dt)
currentColor.g = lia.derma.approachExp(currentColor.g, targetColor.g, transitionSpeed, dt)
currentColor.b = lia.derma.approachExp(currentColor.b, targetColor.b, transitionSpeed, dt)

-- Smooth position interpolation
local currentPos = {x = 0, y = 0}
local targetPos = {x = 100, y = 200}
local moveSpeed = 4.0

local dt = FrameTime()
currentPos.x = lia.derma.approachExp(currentPos.x, targetPos.x, moveSpeed, dt)
currentPos.y = lia.derma.approachExp(currentPos.y, targetPos.y, moveSpeed, dt)

-- Smooth scale animation
local currentScale = 1.0
local targetScale = 1.5
local scaleSpeed = 2.5

local dt = FrameTime()
currentScale = lia.derma.approachExp(currentScale, targetScale, scaleSpeed, dt)

-- Use in custom animation system
local function animateValue(current, target, speed, dt, callback)
    local newValue = lia.derma.approachExp(current, target, speed, dt)

    if callback then
        callback(newValue)
    end

    return newValue
end

-- Smooth rotation
local currentRotation = 0
local targetRotation = 360
local rotationSpeed = 1.5

local dt = FrameTime()
currentRotation = lia.derma.approachExp(currentRotation, targetRotation, rotationSpeed, dt)

-- Smooth opacity changes
local currentAlpha = 255
local targetAlpha = 0
local fadeSpeed = 3.0

local dt = FrameTime()
currentAlpha = lia.derma.approachExp(currentAlpha, targetAlpha, fadeSpeed, dt)
```

---

### attribBar

**Purpose**

Creates an attribute bar component for displaying character attributes with a progress indicator.

**Parameters**

* `parent` (*Panel*): The parent panel to add the attribute bar to.
* `text` (*string*, optional): The text label to display on the bar.
* `maxValue` (*number*, optional): The maximum value for the progress bar.

**Returns**

* `bar` (*liaAttribBar*): The created attribute bar panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic attribute bar
local healthBar = lia.derma.attribBar(parentPanel, "Health", 100)

-- Create an attribute bar with custom max value
local manaBar = lia.derma.attribBar(parentPanel, "Mana", 200)
manaBar:setValue(150)

-- Use in character creation
local strengthBar = lia.derma.attribBar(charPanel, "Strength", 10)
strengthBar:setValue(8)

-- Dynamic attribute display
local function updateAttributeBar(bar, attributeName, currentValue, maxValue)
    bar:setText(attributeName .. ": " .. currentValue .. "/" .. maxValue)
    bar:setValue(currentValue)
    bar:setMax(maxValue)
end

-- Create multiple attribute bars
local attributes = {"Strength", "Dexterity", "Intelligence", "Wisdom"}
for _, attr in ipairs(attributes) do
    local bar = lia.derma.attribBar(parentPanel, attr, 20)
    updateAttributeBar(bar, attr, math.random(10, 18), 20)
end
```

---

### button

**Purpose**

Creates a customizable button with icon support, hover effects, and theme integration.

**Parameters**

* `parent` (*Panel*): The parent panel to add the button to.
* `icon` (*string*, optional): The material path for the button icon.
* `iconSize` (*number*, optional): The size of the icon (default: 16).
* `color` (*Color*, optional): The base color of the button.
* `radius` (*number*, optional): The corner radius of the button (default: 6).
* `noGradient` (*boolean*, optional): Whether to disable gradient effects.
* `hoverColor` (*Color*, optional): The hover color of the button.
* `noHover` (*boolean*, optional): Whether to disable hover effects.

**Returns**

* `button` (*liaButton*): The created button panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic button
local basicButton = lia.derma.button(parentPanel, "icon16/accept.png", 16, Color(100, 150, 255))

-- Create a button without gradient
local flatButton = lia.derma.button(parentPanel, nil, nil, nil, nil, true)

-- Create a custom colored button
local redButton = lia.derma.button(parentPanel, "icon16/cross.png", 16, Color(200, 100, 100))

-- Create a button with custom hover color
local greenButton = lia.derma.button(parentPanel, "icon16/tick.png", 16, Color(100, 200, 100), 8, false, Color(150, 255, 150))

-- Create a button without hover effects
local noHoverButton = lia.derma.button(parentPanel, nil, nil, nil, nil, nil, nil, true)

-- Use in a menu system
local menuButton = lia.derma.button(mainMenu, "icon16/folder.png", 16)
menuButton:SetText("Open Menu")
menuButton.DoClick = function()
    openSubMenu()
end

-- Create icon-only buttons
local playButton = lia.derma.button(toolbar, "icon16/control_play.png", 16)
local pauseButton = lia.derma.button(toolbar, "icon16/control_pause.png", 16)
local stopButton = lia.derma.button(toolbar, "icon16/control_stop.png", 16)
```

---

### category

**Purpose**

Creates a collapsible category panel for organizing UI elements.

**Parameters**

* `parent` (*Panel*): The parent panel to add the category to.
* `title` (*string*, optional): The title text for the category.
* `expanded` (*boolean*, optional): Whether the category should start expanded.

**Returns**

* `category` (*liaCategory*): The created category panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic category
local settingsCategory = lia.derma.category(parentPanel, "Settings")

-- Create an expanded category
local advancedCategory = lia.derma.category(parentPanel, "Advanced Options", true)

-- Create a collapsed category
local basicCategory = lia.derma.category(parentPanel, "Basic Settings", false)

-- Use categories to organize controls
local function createOptionsPanel()
    local generalCat = lia.derma.category(parentPanel, "General", true)

    local nameEntry = lia.derma.descEntry(generalCat, "Display Name", "Enter your name")
    local themeSelector = lia.derma.slideBox(generalCat, "Theme", 1, 3)

    local privacyCat = lia.derma.category(parentPanel, "Privacy", false)
    local showOnlineCheckbox = lia.derma.checkbox(privacyCat, "Show Online Status")
end

-- Dynamic category management
local categories = {}
local function addCategory(title, content)
    local cat = lia.derma.category(parentPanel, title)
    if content then
        content:SetParent(cat)
    end
    table.insert(categories, cat)
    return cat
end

-- Toggle category expansion
local toggleButton = lia.derma.button(parentPanel)
toggleButton.DoClick = function()
    for _, cat in ipairs(categories) do
        cat:Toggle()
    end
end
```

---

### circle

**Purpose**

Creates a circle drawing object that can be customized with colors, textures, materials, and effects before being rendered.

**Parameters**

* `x` (*number*): The x coordinate of the circle center.
* `y` (*number*): The y coordinate of the circle center.
* `radius` (*number*): The radius of the circle.

**Returns**

* `circle` (*liaCircle*): The circle drawing object with chainable methods for customization.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic circle
lia.derma.circle(ScrW() / 2, ScrH() / 2, 50):Color(Color(255, 100, 100)):Draw()

-- Create a circle with outline
lia.derma.circle(100, 100, 30)
    :Color(Color(100, 200, 100))
    :Outline(2)
    :Draw()

-- Create a textured circle
lia.derma.circle(ScrW() / 2, ScrH() / 2, 40)
    :Texture("vgui/white")
    :Color(Color(150, 150, 255))
    :Draw()

-- Create a circle with blur effect
lia.derma.circle(200, 200, 25)
    :Color(Color(255, 255, 100))
    :Blur(2.0)
    :Draw()

-- Create a shadowed circle
lia.derma.circle(ScrW() / 2, ScrH() / 2, 35)
    :Color(Color(100, 100, 255))
    :Shadow(20, 15)
    :Draw()

-- Create a circle with custom angles (arc)
lia.derma.circle(300, 300, 40)
    :Color(Color(255, 150, 100))
    :StartAngle(45)
    :EndAngle(270)
    :Draw()
```

**Available Chainable Methods**

* `:Color(color)` - Sets the circle color
* `:Texture(texture)` - Sets a texture for the circle
* `:Material(material)` - Sets a material for the circle
* `:Outline(thickness)` - Adds an outline with specified thickness
* `:Blur(intensity)` - Applies blur effect
* `:Shadow(spread, intensity)` - Adds shadow effect
* `:Rotation(angle)` - Rotates the circle
* `:StartAngle(angle)` - Sets the start angle for arc drawing
* `:EndAngle(angle)` - Sets the end angle for arc drawing
* `:Clip(panel)` - Clips drawing to specified panel
* `:Flags(flags)` - Applies drawing flags
* `:Draw()` - Renders the circle

---

### color_picker

**Purpose**

Creates a comprehensive color picker dialog that allows users to select colors using hue, saturation, and value controls with a live preview.

**Parameters**

* `callback` (*function*): The function to call when a color is selected. Receives the selected Color object as parameter.
* `defaultColor` (*Color*, optional): The initial color to display in the picker.

**Returns**

* `frame` (*liaFrame*): The color picker frame dialog.

**Realm**

Client.

**Example Usage**

```lua
-- Basic color picker
lia.derma.color_picker(function(color)
    print("Selected color:", color.r, color.g, color.b)
    myPanel:SetBackgroundColor(color)
end)

-- Color picker with default color
local defaultColor = Color(255, 100, 100)
lia.derma.color_picker(function(color)
    print("New color selected:", color)
    updateThemeAccent(color)
end, defaultColor)

-- Use in theme customization
lia.derma.color_picker(function(color)
    local customTheme = table.Copy(lia.color.getTheme())
    customTheme.accent = color
    lia.color.registerTheme("custom", customTheme)
    lia.color.setTheme("custom")
    print("Theme updated with new accent color")
end)

-- Color picker for item customization
lia.derma.color_picker(function(color)
    currentItem.customColor = color
    itemPreviewPanel:SetColor(color)
    print("Item color updated")
end, currentItem.customColor)

-- Multiple color pickers for different UI elements
local colorButtons = {}
local function createColorPalette()
    local colors = {"Primary", "Secondary", "Accent", "Background"}

    for _, colorName in ipairs(colors) do
        local button = lia.derma.button(parentPanel, nil, nil, Color(100, 100, 100))
        button:SetText(colorName)
        button.DoClick = function()
            lia.derma.color_picker(function(color)
                button:SetColor(color)
                updateColorScheme(colorName:lower(), color)
                print("Updated " .. colorName .. " color")
            end)
        end
        table.insert(colorButtons, button)
    end
end

-- Color picker with validation
lia.derma.color_picker(function(color)
    if color.r > 200 and color.g < 50 and color.b < 50 then
        print("Bright red color selected - applying warning theme")
        applyWarningTheme()
    else
        applyNormalColor(color)
    end
end)
```

---

### derma_menu

**Purpose**

Creates a context menu at the current mouse position with automatic positioning and menu management.

**Parameters**

*None*

**Returns**

* `menu` (*liaDermaMenu*): The created context menu panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic context menu
local menu = lia.derma.derma_menu()
menu:AddOption("Copy", function()
    print("Copy option selected")
end)
menu:AddOption("Paste", function()
    print("Paste option selected")
end)
menu:AddOption("Cut", function()
    print("Cut option selected")
end)

-- Context menu with submenus
local menu = lia.derma.derma_menu()
local editSubmenu = menu:AddSubMenu("Edit")

editSubmenu:AddOption("Undo", function()
    print("Undo selected")
end)
editSubmenu:AddOption("Redo", function()
    print("Redo selected")
end)

menu:AddOption("Delete", function()
    print("Delete selected")
end)

-- Context menu for player interactions
local menu = lia.derma.derma_menu()
local targetPlayer = LocalPlayer()

menu:AddOption("Send Message", function()
    lia.derma.textBox("Send Message", "Enter your message", function(text)
        targetPlayer:ChatPrint(text)
    end)
end)

menu:AddOption("Trade Items", function()
    openTradeWindow(targetPlayer)
end)

menu:AddOption("View Profile", function()
    showPlayerProfile(targetPlayer)
end)

-- Context menu with icons
local menu = lia.derma.derma_menu()
menu:AddOption("Save", function()
    saveDocument()
end):SetIcon("icon16/disk.png")

menu:AddOption("Load", function()
    loadDocument()
end):SetIcon("icon16/folder.png")

menu:AddOption("Settings", function()
    openSettings()
end):SetIcon("icon16/cog.png")

-- Dynamic context menu based on object type
local function createContextMenuForObject(object)
    local menu = lia.derma.derma_menu()

    if object.type == "container" then
        menu:AddOption("Open", function() object:Open() end)
        menu:AddOption("Lock", function() object:Lock() end)
    elseif object.type == "npc" then
        menu:AddOption("Talk", function() object:Talk() end)
        menu:AddOption("Trade", function() object:Trade() end)
    elseif object.type == "item" then
        menu:AddOption("Use", function() object:Use() end)
        menu:AddOption("Drop", function() object:Drop() end)
    end

    return menu
end

-- Context menu with separators
local menu = lia.derma.derma_menu()
menu:AddOption("New", function() print("New") end)
menu:AddOption("Open", function() print("Open") end)
menu:AddSpacer()
menu:AddOption("Save", function() print("Save") end)
menu:AddOption("Save As", function() print("Save As") end)
menu:AddSpacer()
menu:AddOption("Exit", function() print("Exit") end)
```

---

### DrawTip

**Purpose**

Draws a tooltip-style graphic with text, consisting of a rounded rectangle background with a triangular pointer, commonly used for displaying helpful information when hovering over UI elements.

**Parameters**

* `x` (*number*): The x position of the tooltip.
* `y` (*number*): The y position of the tooltip.
* `w` (*number*): The width of the tooltip rectangle.
* `h` (*number*): The height of the tooltip rectangle.
* `text` (*string*): The text to display in the tooltip.
* `font` (*string*): The font to use for the text.
* `textCol` (*Color*): The color of the tooltip text.
* `outlineCol` (*Color*): The color of the tooltip outline/background.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic tooltip
lia.derma.DrawTip(100, 100, 200, 60, "This is a tooltip", "LiliaFont.16", Color(255, 255, 255), Color(50, 50, 50, 200))

-- Tooltip with different colors
lia.derma.DrawTip(ScrW() / 2 - 100, ScrH() / 2, 200, 50, "Hover tooltip", "LiliaFont.20", Color(255, 255, 0), Color(100, 100, 255, 220))

-- Use in button hover effects
local function drawButtonWithTooltip(x, y, w, h, text, tooltipText)
    local isHovered = math.Distance(input.GetCursorPos(), x + w/2, y + h/2) < 100

    lia.derma.draw(8, x, y, w, h, isHovered and Color(150, 150, 255) or Color(100, 100, 200))

    if isHovered and tooltipText then
        lia.derma.DrawTip(x, y - 70, 200, 50, tooltipText, "LiliaFont.16", Color(255, 255, 255), Color(0, 0, 0, 200))
    end

    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawButtonWithTooltip(100, 100, 150, 40, "Hover Me!", "This button does something important")

-- Tooltip for inventory items
local function drawInventoryTooltip(item, x, y)
    if not item then return end

    local tooltipText = item.name .. "\n" .. (item.description or "No description")
    local textWidth = 250
    local textHeight = 80

    lia.derma.DrawTip(x, y - textHeight - 20, textWidth, textHeight, tooltipText, "LiliaFont.16", Color(255, 255, 255), Color(50, 50, 50, 220))
end

-- Tooltip for HUD elements
local function drawHUDTooltip()
    local mouseX, mouseY = input.GetCursorPos()

    -- Health tooltip
    if mouseX > 50 and mouseX < 150 and mouseY > ScrH() - 80 and mouseY < ScrH() - 20 then
        local health = LocalPlayer():Health()
        local maxHealth = LocalPlayer():GetMaxHealth()
        lia.derma.DrawTip(mouseX + 10, mouseY - 60, 200, 40,
                         "Health: " .. health .. "/" .. maxHealth, "LiliaFont.16",
                         Color(255, 255, 255), Color(100, 0, 0, 200))
    end

    -- Armor tooltip
    if mouseX > 200 and mouseX < 300 and mouseY > ScrH() - 80 and mouseY < ScrH() - 20 then
        local armor = LocalPlayer():Armor()
        lia.derma.DrawTip(mouseX + 10, mouseY - 60, 200, 40,
                         "Armor: " .. armor, "LiliaFont.16",
                         Color(255, 255, 255), Color(0, 100, 0, 200))
    end
end

hook.Add("HUDPaint", "DrawHUDTooltips", drawHUDTooltip)

-- Tooltip with multiple lines
lia.derma.DrawTip(200, 200, 250, 100, "Line 1\nLine 2\nLine 3", "LiliaFont.16", Color(255, 255, 255), Color(50, 50, 50, 200))
```

---

### ShadowText

**Purpose**

Draws text with a drop shadow effect by rendering the text twice - once in the shadow color at an offset position, and once in the main color at the original position.

**Parameters**

* `text` (*string*): The text to draw.
* `font` (*string*): The font to use for drawing the text.
* `x` (*number*): The x position to draw the text.
* `y` (*number*): The y position to draw the text.
* `colortext` (*Color*): The main color of the text.
* `colorshadow` (*Color*): The color of the shadow.
* `dist` (*number*, optional): The distance/offset of the shadow in pixels (default: 1).
* `xalign` (*number*, optional): The horizontal alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT).
* `yalign` (*number*, optional): The vertical alignment (TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic shadowed text
lia.derma.ShadowText("Hello World", "LiliaFont.20", 100, 100, Color(255, 255, 255), Color(0, 0, 0), 2)

-- Shadowed text with different colors
lia.derma.ShadowText("Colored Shadow", "LiliaFont.24", ScrW() / 2, ScrH() / 2, Color(255, 100, 100), Color(100, 0, 100), 3, TEXT_ALIGN_CENTER)

-- Shadowed text aligned to different positions
lia.derma.ShadowText("Right Aligned", "LiliaFont.16", ScrW() - 50, 50, Color(100, 255, 100), Color(0, 100, 0), 1, TEXT_ALIGN_RIGHT)

-- Shadowed text with large shadow distance for dramatic effect
lia.derma.ShadowText("DRAMATIC!", "LiliaFont.24", 200, 200, Color(255, 255, 0), Color(255, 0, 0), 5, TEXT_ALIGN_CENTER)

-- Use in UI elements for depth
local function drawShadowedButton(x, y, w, h, text)
    lia.derma.draw(8, x, y, w, h, Color(100, 150, 255))
    lia.derma.ShadowText(text, "LiliaFont.20", x + w/2, y + h/2, Color(255, 255, 255), Color(0, 0, 0), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawShadowedButton(100, 100, 200, 50, "Click Me!")

-- Shadowed text for HUD elements
local function drawPlayerHUD()
    local health = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()

    lia.derma.ShadowText("Health: " .. health .. "/" .. maxHealth, "LiliaFont.20", 100, ScrH() - 100,
                         health > 50 and Color(100, 255, 100) or Color(255, 100, 100),
                         Color(0, 0, 0), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "DrawPlayerHUD", drawPlayerHUD)

-- Shadowed text with custom shadow color and distance
lia.derma.ShadowText("Custom Shadow", "LiliaFont.20", 100, 300, Color(150, 150, 255), Color(50, 50, 150), 4)

-- Multiple shadowed text elements for layered effect
lia.derma.ShadowText("Layer 1", "LiliaFont.24", 300, 300, Color(255, 255, 255), Color(100, 100, 100), 1)
lia.derma.ShadowText("Layer 2", "LiliaFont.24", 302, 302, Color(255, 255, 255), Color(50, 50, 50), 2)
lia.derma.ShadowText("Layer 3", "LiliaFont.24", 304, 304, Color(255, 255, 255), Color(0, 0, 0), 3)

-- Shadowed text for game titles or important messages
lia.derma.ShadowText("IMPORTANT ANNOUNCEMENT", "LiliaFont.24", ScrW() / 2, 150, Color(255, 255, 0), Color(255, 0, 0), 4, TEXT_ALIGN_CENTER)
```

---

### DrawTextOutlined

**Purpose**

Draws text with an outline effect by rendering the text multiple times at offset positions with the specified outline color, creating a bordered appearance.

**Parameters**

* `text` (*string*): The text to draw.
* `font` (*string*): The font to use for drawing the text.
* `x` (*number*): The x position to draw the text.
* `y` (*number*): The y position to draw the text.
* `colour` (*Color*): The main color of the text.
* `xalign` (*number*, optional): The horizontal alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT).
* `outlinewidth` (*number*, optional): The width of the outline in pixels (default: 1).
* `outlinecolour` (*Color*, optional): The color of the outline (default: Color(0, 0, 0, 255)).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw basic outlined text
lia.derma.DrawTextOutlined("Hello World", "LiliaFont.20", 100, 100, Color(255, 255, 255), TEXT_ALIGN_LEFT, 2, Color(0, 0, 0))

-- Draw centered outlined text
lia.derma.DrawTextOutlined("Centered Text", "LiliaFont.24", ScrW() / 2, ScrH() / 2, Color(255, 100, 100), TEXT_ALIGN_CENTER, 3, Color(100, 0, 0))

-- Draw right-aligned outlined text
lia.derma.DrawTextOutlined("Right Aligned", "LiliaFont.16", ScrW() - 50, 50, Color(100, 255, 100), TEXT_ALIGN_RIGHT, 1, Color(0, 100, 0))

-- Draw outlined text with thick outline for emphasis
lia.derma.DrawTextOutlined("IMPORTANT!", "LiliaFont.24", 200, 200, Color(255, 255, 0), TEXT_ALIGN_CENTER, 5, Color(255, 0, 0))

-- Draw outlined text in a custom color scheme
lia.derma.DrawTextOutlined("Custom Colors", "LiliaFont.20", 100, 300, Color(150, 150, 255), TEXT_ALIGN_LEFT, 2, Color(50, 50, 150))

-- Use in UI elements
local function drawOutlinedButton(x, y, w, h, text)
    lia.derma.draw(8, x, y, w, h, Color(100, 150, 255))
    lia.derma.DrawTextOutlined(text, "LiliaFont.20", x + w/2, y + h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
end

drawOutlinedButton(100, 100, 200, 50, "Click Me!")

-- Draw outlined text with different font sizes for headings
lia.derma.DrawTextOutlined("Main Title", "LiliaFont.24", ScrW() / 2, 100, Color(255, 255, 255), TEXT_ALIGN_CENTER, 3, Color(0, 0, 0))
lia.derma.DrawTextOutlined("Subtitle", "LiliaFont.20", ScrW() / 2, 150, Color(200, 200, 200), TEXT_ALIGN_CENTER, 2, Color(50, 50, 50))

-- Draw outlined text for game UI elements
local function drawPlayerHUD()
    local health = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()

    lia.derma.DrawTextOutlined("Health: " .. health .. "/" .. maxHealth, "LiliaFont.20", 100, ScrH() - 100,
                               health > 50 and Color(100, 255, 100) or Color(255, 100, 100),
                               TEXT_ALIGN_LEFT, 2, Color(0, 0, 0))
end

hook.Add("HUDPaint", "DrawPlayerHUD", drawPlayerHUD)
```

---

### drawBlackBlur

**Purpose**

Draws a black blur background effect behind a panel, commonly used for creating modal overlays or darkening the background to focus attention on a specific UI element.

**Parameters**

* `panel` (*Panel*): The panel to draw the blur effect for.
* `amount` (*number*, optional): The blur intensity (default: 6).
* `passes` (*number*, optional): The number of blur passes (default: 5).
* `alpha` (*number*, optional): The alpha transparency of the blur effect (default: 255).
* `darkAlpha` (*number*, optional): The alpha transparency of the black overlay (default: 220).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic black blur effect
local modalPanel = vgui.Create("DPanel")
modalPanel:SetSize(400, 300)
modalPanel:Center()

-- Draw black blur background
lia.derma.drawBlackBlur(modalPanel, 6, 5, 255, 220)

-- Custom blur settings
local settingsPanel = vgui.Create("DFrame")
settingsPanel:SetSize(500, 400)
settingsPanel:Center()
settingsPanel:MakePopup()

lia.derma.drawBlackBlur(settingsPanel, 8, 8, 200, 180)

-- Use in modal dialogs
local function showModalDialog(title, content)
    local frame = lia.derma.frame(nil, title, 400, 300)
    frame:MakePopup()

    -- Draw black blur background for modal effect
    lia.derma.drawBlackBlur(frame, 5, 3, 255, 200)

    -- Add content...
end

-- Blur effect for loading screens
local loadingPanel = vgui.Create("DPanel")
loadingPanel:SetSize(ScrW(), ScrH())

lia.derma.drawBlackBlur(loadingPanel, 10, 10, 150, 100)

-- Custom blur for notifications
local notificationPanel = vgui.Create("DPanel")
notificationPanel:SetSize(300, 100)
notificationPanel:SetPos(ScrW() - 320, 20)

lia.derma.drawBlackBlur(notificationPanel, 4, 4, 255, 180)

-- Use with animation for smooth transitions
local function fadeInWithBlur(panel, duration)
    panel:SetAlpha(0)
    lia.derma.drawBlackBlur(panel, 6, 5, 0, 0) -- Start transparent

    local startTime = CurTime()
    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)

        local blurAlpha = progress * 255
        local darkAlpha = progress * 220

        lia.derma.drawBlackBlur(panel, 6, 5, blurAlpha, darkAlpha)

        if progress >= 1 then
            panel.Think = nil
        end
    end
end

-- Blur effect for inventory screens
local inventoryFrame = lia.derma.frame(nil, "Inventory", 800, 600)
lia.derma.drawBlackBlur(inventoryFrame, 7, 6, 255, 200)
```

---

### drawBlurAt

**Purpose**

Draws a blur effect at specific screen coordinates with customizable parameters, allowing for precise control over blur effects in specific areas of the screen.

**Parameters**

* `x` (*number*): The x coordinate of the blur area.
* `y` (*number*): The y coordinate of the blur area.
* `w` (*number*): The width of the blur area.
* `h` (*number*): The height of the blur area.
* `amount` (*number*, optional): The blur intensity (default: 5).
* `passes` (*number*, optional): The number of blur passes (default: 0.2).
* `alpha` (*number*, optional): The alpha transparency of the blur effect (default: 255).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic blur at specific coordinates
lia.derma.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)

-- Blur with custom settings
lia.derma.drawBlurAt(ScrW() / 2 - 150, ScrH() / 2 - 100, 300, 200, 8, 0.5, 200)

-- Use for highlighting areas
local function highlightArea(x, y, w, h)
    lia.derma.drawBlurAt(x, y, w, h, 3, 0.1, 150)
end

highlightArea(200, 300, 100, 80)

-- Blur effect for UI transitions
local function blurTransitionArea(startX, startY, width, height, progress)
    local blurAmount = progress * 10
    local blurAlpha = progress * 255

    lia.derma.drawBlurAt(startX, startY, width, height, blurAmount, 0.3, blurAlpha)
end

-- Blur specific regions of HUD
local function blurHUDArea()
    -- Blur health area
    lia.derma.drawBlurAt(50, ScrH() - 80, 200, 60, 4, 0.2, 100)

    -- Blur minimap area
    lia.derma.drawBlurAt(ScrW() - 220, 50, 200, 200, 3, 0.15, 80)
end

hook.Add("HUDPaint", "BlurHUDAreas", blurHUDArea)

-- Animated blur effect
local function createAnimatedBlur()
    local startTime = CurTime()
    local duration = 2.0

    local function animateBlur()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)

        local pulseAmount = math.sin(progress * math.pi * 4) * 5 + 7
        local pulseAlpha = (math.sin(progress * math.pi * 2) + 1) * 127 + 128

        lia.derma.drawBlurAt(ScrW() / 2 - 100, ScrH() / 2 - 75, 200, 150, pulseAmount, 0.4, pulseAlpha)

        if progress < 1 then
            timer.Simple(0.016, animateBlur) -- ~60 FPS
        end
    end

    animateBlur()
end

-- Blur for screen effects
lia.derma.drawBlurAt(0, 0, ScrW(), ScrH(), 6, 0.3, 100) -- Full screen blur
lia.derma.drawBlurAt(ScrW() / 4, ScrH() / 4, ScrW() / 2, ScrH() / 2, 4, 0.2, 150) -- Center blur
```

---

### drawEntText

**Purpose**

Draws text above entities in the 3D world with distance-based fading and smooth appearance/disappearance transitions, commonly used for displaying entity names, health, or other information.

**Parameters**

* `ent` (*Entity*): The entity to draw text above.
* `text` (*string*): The text to display above the entity.
* `posY` (*number*, optional): The vertical offset for the text position (default: 0).
* `alphaOverride` (*number*, optional): Override alpha value (default: uses distance-based calculation).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic entity text display
lia.derma.drawEntText(LocalPlayer(), "Player Name", 0)

-- Entity text with offset
lia.derma.drawEntText(someNPC, "NPC Name", 20)

-- Entity text with custom alpha
lia.derma.drawEntText(doorEntity, "Door", 0, 150)

-- Display health above players
local function drawPlayerHealth()
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and ply ~= LocalPlayer() then
            local health = ply:Health()
            local maxHealth = ply:GetMaxHealth()
            local healthText = "HP: " .. health .. "/" .. maxHealth

            -- Color based on health percentage
            local healthPercent = health / maxHealth
            local textColor = healthPercent > 0.5 and "green" or "red"

            lia.derma.drawEntText(ply, healthText, 10)
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "DrawPlayerHealth", drawPlayerHealth)

-- Display item names above dropped items
local function drawItemNames()
    for _, ent in ipairs(ents.FindByClass("lia_item")) do
        if IsValid(ent) then
            local itemName = ent:getItemName and ent:getItemName() or "Unknown Item"
            lia.derma.drawEntText(ent, itemName, 5)
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "DrawItemNames", drawItemNames)

-- Display NPC dialogue options
local function drawNPCDialogue(npc)
    if not IsValid(npc) then return end

    local dialogueOptions = npc:getDialogueOptions and npc:getDialogueOptions()
    if dialogueOptions then
        local text = "Press E to talk"
        lia.derma.drawEntText(npc, text, 15)
    end
end

-- Entity distance-based text with custom logic
local function drawEntityInfo()
    local eyePos = LocalPlayer():EyePos()

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetClass() ~= "worldspawn" then
            local dist = eyePos:Distance(ent:GetPos())

            -- Only show text for entities within range
            if dist < 500 then
                local text = ent:GetClass()

                -- Different text based on entity type
                if ent:IsPlayer() then
                    text = ent:Name()
                elseif ent:IsNPC() then
                    text = "NPC"
                elseif ent:IsVehicle() then
                    text = "Vehicle"
                end

                lia.derma.drawEntText(ent, text, 0)
            end
        end
    end
end

-- Animated entity text that appears/disappears smoothly
local function drawAnimatedEntityText(ent, text)
    local distSqr = LocalPlayer():EyePos():DistToSqr(ent:GetPos())
    local maxDist = 300

    if distSqr < maxDist * maxDist then
        -- Calculate fade based on distance
        local fade = 1 - (math.sqrt(distSqr) / maxDist)
        lia.derma.drawEntText(ent, text, 0, fade * 255)
    end
end

-- Use in entity think hooks for dynamic text
local function updateEntityTexts()
    for _, ent in ipairs(ents.FindByClass("lia_*")) do
        if ent.getDisplayText then
            local text = ent:getDisplayText()
            if text then
                drawAnimatedEntityText(ent, text)
            end
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "UpdateEntityTexts", updateEntityTexts)
```

---

### drawGradient

**Purpose**

Draws a gradient rectangle using predefined gradient materials in different directions (up, down, left, right), providing a simple way to create gradient backgrounds and effects.

**Parameters**

* `_x` (*number*): The x position of the gradient rectangle.
* `_y` (*number*): The y position of the gradient rectangle.
* `_w` (*number*): The width of the gradient rectangle.
* `_h` (*number*): The height of the gradient rectangle.
* `direction` (*number*): The gradient direction (1=up, 2=down, 3=left, 4=right).
* `color_shadow` (*Color*): The color to apply to the gradient.
* `radius` (*number*, optional): The corner radius for the gradient (default: 0).
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic gradient in different directions
lia.derma.drawGradient(100, 100, 200, 100, 1, Color(100, 150, 255)) -- Up gradient
lia.derma.drawGradient(100, 250, 200, 100, 2, Color(255, 100, 100)) -- Down gradient
lia.derma.drawGradient(350, 100, 200, 100, 3, Color(100, 255, 100)) -- Left gradient
lia.derma.drawGradient(350, 250, 200, 100, 4, Color(255, 255, 100)) -- Right gradient

-- Gradient with rounded corners
lia.derma.drawGradient(100, 400, 200, 100, 1, Color(150, 100, 255), 10)

-- Use gradients for backgrounds
local function drawGradientBackground(x, y, w, h, color, direction)
    lia.derma.drawGradient(x, y, w, h, direction or 1, color)
end

drawGradientBackground(50, 50, 300, 200, Color(50, 100, 150), 2)

-- Gradient for button hover effects
local function drawGradientButton(x, y, w, h, text, isHovered)
    local gradientColor = isHovered and Color(150, 200, 255) or Color(100, 150, 255)
    lia.derma.drawGradient(x, y, w, h, 2, gradientColor, 8)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Gradient for progress bars
local function drawGradientProgressBar(x, y, w, h, progress, color)
    -- Background
    lia.derma.drawGradient(x, y, w, h, 1, Color(50, 50, 50), 4)

    -- Progress fill
    local fillWidth = w * math.Clamp(progress, 0, 1)
    lia.derma.drawGradient(x, y, fillWidth, h, 1, color, 4)
end

drawGradientProgressBar(100, 100, 300, 30, 0.7, Color(100, 255, 100))

-- Gradient for HUD elements
local function drawGradientHUD()
    -- Health bar gradient background
    lia.derma.drawGradient(50, ScrH() - 80, 200, 30, 1, Color(100, 0, 0), 4)

    -- Armor bar gradient background
    lia.derma.drawGradient(300, ScrH() - 80, 200, 30, 1, Color(0, 100, 0), 4)

    -- Experience bar gradient
    lia.derma.drawGradient(50, ScrH() - 40, 450, 20, 1, Color(100, 100, 0), 2)
end

hook.Add("HUDPaint", "DrawGradientHUD", drawGradientHUD)

-- Animated gradient effect
local function drawAnimatedGradient()
    local time = CurTime()
    local pulseColor = HSVToColor(time * 50 % 360, 0.8, 1)

    lia.derma.drawGradient(ScrW() / 2 - 150, ScrH() / 2 - 75, 300, 150, 2, pulseColor, 15)
end

-- Gradient for panel backgrounds
local function createGradientPanel(parent, x, y, w, h, color, direction)
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x, y)
    panel:SetSize(w, h)

    panel.Paint = function(self, pw, ph)
        lia.derma.drawGradient(0, 0, pw, ph, direction or 1, color)
    end

    return panel
end

local gradientPanel = createGradientPanel(parentPanel, 50, 50, 200, 100, Color(150, 100, 255), 2)
```

---

### drawSurfaceTexture

**Purpose**

Draws a textured rectangle using Garry's Mod surface functions, providing a simple way to draw textures with custom colors and materials.

**Parameters**

* `material` (*string* or *IMaterial*): The material/texture to draw.
* `color` (*Color*, optional): The color to tint the texture with.
* `x` (*number*): The x position to draw the texture.
* `y` (*number*): The y position to draw the texture.
* `w` (*number*): The width of the texture.
* `h` (*number*): The height of the texture.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw basic texture
lia.derma.drawSurfaceTexture("vgui/white", Color(255, 255, 255), 100, 100, 200, 150)

-- Draw texture with color tint
lia.derma.drawSurfaceTexture("gui/gradient", Color(255, 100, 100), 50, 50, 300, 200)

-- Draw material object
local customMaterial = Material("effects/bubble")
lia.derma.drawSurfaceTexture(customMaterial, Color(100, 255, 100), 200, 200, 100, 100)

-- Use in panel backgrounds
local function createTexturedPanel(parent, x, y, w, h, texture, color)
    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(x, y)
    panel:SetSize(w, h)

    panel.Paint = function(self, pw, ph)
        lia.derma.drawSurfaceTexture(texture, color, 0, 0, pw, ph)
    end

    return panel
end

local texturedPanel = createTexturedPanel(parentPanel, 50, 50, 200, 100, "vgui/white", Color(150, 150, 255))

-- Animated texture effect
local function drawAnimatedTexture()
    local time = CurTime()
    local pulseColor = Color(255, 255, 255, math.sin(time * 3) * 64 + 192)

    lia.derma.drawSurfaceTexture("effects/noise", pulseColor, 100, 100, 200, 200)
end

-- Texture for HUD elements
local function drawTexturedHUD()
    -- Health bar background texture
    lia.derma.drawSurfaceTexture("gui/gradient", Color(100, 0, 0, 150), 50, ScrH() - 80, 200, 30)

    -- Armor bar background texture
    lia.derma.drawSurfaceTexture("gui/gradient", Color(0, 100, 0, 150), 300, ScrH() - 80, 200, 30)

    -- Minimap texture background
    lia.derma.drawSurfaceTexture("vgui/white", Color(0, 0, 0, 100), ScrW() - 220, 50, 200, 200)
end

hook.Add("HUDPaint", "DrawTexturedHUD", drawTexturedHUD)

-- Use with different texture materials
local textures = {
    "vgui/white",
    "gui/gradient",
    "effects/bubble",
    "effects/noise"
}

for i, texture in ipairs(textures) do
    local x = 50 + (i - 1) * 120
    lia.derma.drawSurfaceTexture(texture, Color(255, 255, 255), x, 300, 100, 100)
end

-- Texture for button backgrounds
local function drawTexturedButton(x, y, w, h, text, texture, color)
    lia.derma.drawSurfaceTexture(texture, color, x, y, w, h)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawTexturedButton(100, 100, 200, 50, "Textured Button", "gui/gradient", Color(100, 150, 255))
```

---

### wrapText

**Purpose**

Wraps text to fit within a specified width by breaking it into multiple lines, commonly used for displaying long text in constrained UI spaces.

**Parameters**

* `text` (*string*): The text to wrap.
* `width` (*number*): The maximum width for each line.
* `font` (*string*, optional): The font to use for text measurement (default: "liaChatFont").

**Returns**

* `lines` (*table*): An array of wrapped text lines.
* `maxWidth` (*number*): The maximum width of any single line.

**Realm**

Client.

**Example Usage**

```lua
-- Basic text wrapping
local text = "This is a very long text that needs to be wrapped to fit within the specified width."
local lines, maxWidth = lia.derma.wrapText(text, 300)

for i, line in ipairs(lines) do
    print("Line " .. i .. ": " .. line)
end

-- Use in UI elements
local function drawWrappedText(text, x, y, width, font)
    local lines, maxWidth = lia.derma.wrapText(text, width, font or "LiliaFont.16")

    for i, line in ipairs(lines) do
        draw.SimpleText(line, font or "LiliaFont.16", x, y + (i - 1) * 20, Color(255, 255, 255))
    end

    return #lines * 20 -- Return total height
end

local height = drawWrappedText("This is some long text that will be wrapped across multiple lines", 100, 100, 200)

-- Wrap text for chat messages
local function formatChatMessage(message, maxWidth)
    local lines, _ = lia.derma.wrapText(message, maxWidth)

    local formattedMessage = ""
    for i, line in ipairs(lines) do
        formattedMessage = formattedMessage .. line
        if i < #lines then
            formattedMessage = formattedMessage .. "\n"
        end
    end

    return formattedMessage
end

-- Wrap text for tooltips
local function createWrappedTooltip(x, y, width, text)
    local lines, maxWidth = lia.derma.wrapText(text, width - 20) -- Account for padding

    local tooltipHeight = #lines * 18 + 10
    lia.derma.draw(8, x, y, width, tooltipHeight, Color(50, 50, 50, 220))

    for i, line in ipairs(lines) do
        draw.SimpleText(line, "LiliaFont.16", x + 10, y + 5 + (i - 1) * 18, Color(255, 255, 255))
    end
end

-- Dynamic text wrapping for different screen sizes
local function drawResponsiveText(text, x, y, maxWidth)
    local screenWidth = ScrW()
    local adaptiveWidth = math.min(maxWidth, screenWidth * 0.8)

    local lines, actualMaxWidth = lia.derma.wrapText(text, adaptiveWidth)

    for i, line in ipairs(lines) do
        draw.SimpleText(line, "LiliaFont.20", x, y + (i - 1) * 25, Color(255, 255, 255))
    end

    return #lines * 25, actualMaxWidth
end

-- Wrap text for item descriptions
local function formatItemDescription(item)
    if not item.description then return "" end

    local lines, _ = lia.derma.wrapText(item.description, 250)
    return table.concat(lines, "\n")
end

-- Text wrapping with different fonts
local function getOptimalFontSize(text, maxWidth, maxHeight)
    local fonts = {"LiliaFont.16", "LiliaFont.20", "LiliaFont.24"}

    for _, font in ipairs(fonts) do
        local lines, _ = lia.derma.wrapText(text, maxWidth, font)
        local totalHeight = #lines * surface.GetFontHeight(font)

        if totalHeight <= maxHeight then
            return font, lines
        end
    end

    return "LiliaFont.16", lia.derma.wrapText(text, maxWidth, "LiliaFont.16")
end
```

---

### easeOutCubic

**Purpose**

Calculates an easing value using a cubic out function, providing smooth deceleration for animations and transitions.

**Parameters**

* `t` (*number*): The time value between 0 and 1.

**Returns**

* `value` (*number*): The eased value between 0 and 1.

**Realm**

Client.

**Example Usage**

```lua
-- Basic easing usage
local progress = 0.5
local easedValue = lia.derma.easeOutCubic(progress)

-- Use in animation loop
local startTime = CurTime()
local duration = 2.0

local function animateWithEasing()
    local elapsed = CurTime() - startTime
    local progress = math.min(elapsed / duration, 1)
    local easedProgress = lia.derma.easeOutCubic(progress)

    -- Apply eased progress to animation
    local panel = somePanel
    panel:SetAlpha(easedProgress * 255)
end

-- Custom animation function with easing
local function animatePanel(panel, targetAlpha, duration)
    local startAlpha = panel:GetAlpha()
    local startTime = CurTime()

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = lia.derma.easeOutCubic(progress)

        local currentAlpha = Lerp(easedProgress, startAlpha, targetAlpha)
        panel:SetAlpha(currentAlpha)

        if progress >= 1 then
            panel.Think = nil
        end
    end
end

-- Multiple easing curves comparison
local function compareEasingCurves()
    local curves = {
        "Linear",
        "easeOutCubic",
        "easeInOutCubic"
    }

    for i, curveName in ipairs(curves) do
        local x = 50 + (i - 1) * 150
        local points = {}

        for step = 0, 100 do
            local t = step / 100
            local eased = curveName == "easeOutCubic" and lia.derma.easeOutCubic(t) or
                         (curveName == "easeInOutCubic" and lia.derma.easeInOutCubic(t) or t)

            table.insert(points, {x = x + step, y = 300 - eased * 100})
        end

        -- Draw curve...
    end
end

-- Smooth UI transitions
local function fadeOutPanel(panel, duration, callback)
    local startAlpha = panel:GetAlpha()
    local startTime = CurTime()

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = lia.derma.easeOutCubic(progress)

        local currentAlpha = Lerp(1 - easedProgress, startAlpha, 0)
        panel:SetAlpha(currentAlpha)

        if progress >= 1 then
            panel.Think = nil
            if callback then callback() end
        end
    end
end

-- Easing for movement animations
local function movePanel(panel, targetX, targetY, duration)
    local startX, startY = panel:GetPos()
    local startTime = CurTime()

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = lia.derma.easeOutCubic(progress)

        local currentX = Lerp(easedProgress, startX, targetX)
        local currentY = Lerp(easedProgress, startY, targetY)
        panel:SetPos(currentX, currentY)

        if progress >= 1 then
            panel.Think = nil
        end
    end
end
```

---

### easeInOutCubic

**Purpose**

Calculates an easing value using a cubic in-out function, providing smooth acceleration and deceleration for animations that need to start and end slowly.

**Parameters**

* `t` (*number*): The time value between 0 and 1.

**Returns**

* `value` (*number*): The eased value between 0 and 1.

**Realm**

Client.

**Example Usage**

```lua
-- Basic easing usage
local progress = 0.5
local easedValue = lia.derma.easeInOutCubic(progress)

-- Use in animation loop with smooth start and end
local startTime = CurTime()
local duration = 3.0

local function animateWithSmoothEasing()
    local elapsed = CurTime() - startTime
    local progress = math.min(elapsed / duration, 1)
    local easedProgress = lia.derma.easeInOutCubic(progress)

    -- Apply eased progress to animation
    local panel = somePanel
    local scale = 1 + easedProgress * 0.5 -- Scale from 1 to 1.5
    panel:SetSize(panel.baseWidth * scale, panel.baseHeight * scale)
end

-- Bounce effect using in-out easing
local function createBounceEffect(panel, targetPos, duration)
    local startPos = panel:GetPos()
    local startTime = CurTime()

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)

        -- Use in-out easing for smooth bounce
        local easedProgress = lia.derma.easeInOutCubic(progress)

        -- Create bounce effect by overshooting and returning
        local bounceProgress = easedProgress * 1.2 - 0.1
        bounceProgress = math.max(0, math.min(1, bounceProgress))

        local currentX = Lerp(bounceProgress, startPos.x, targetPos.x)
        local currentY = Lerp(bounceProgress, startPos.y, targetPos.y)
        panel:SetPos(currentX, currentY)

        if progress >= 1 then
            panel.Think = nil
            panel:SetPos(targetPos) -- Ensure final position
        end
    end
end

-- Smooth sliding panel animation
local function slideInPanel(panel, targetX, duration)
    local startX = panel:GetPos()
    local startTime = CurTime()

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = lia.derma.easeInOutCubic(progress)

        local currentX = Lerp(easedProgress, startX, targetX)
        panel:SetPos(currentX, panel:GetY())

        if progress >= 1 then
            panel.Think = nil
        end
    end
end

-- Pulsing animation with in-out easing
local function createPulsingEffect(panel, duration)
    local startTime = CurTime()
    local baseAlpha = 150
    local pulseRange = 100

    panel.Think = function()
        local elapsed = CurTime() - startTime
        local progress = (elapsed % duration) / duration
        local easedProgress = lia.derma.easeInOutCubic(progress)

        -- Create pulsing effect
        local pulseAlpha = baseAlpha + math.sin(easedProgress * math.pi * 2) * pulseRange
        panel:SetAlpha(pulseAlpha)
    end
end

-- Complex animation combining multiple easing types
local function complexAnimation(panel, duration)
    local startTime = CurTime()
    local phases = {
        {duration = duration * 0.3, easing = lia.derma.easeInOutCubic},
        {duration = duration * 0.4, easing = lia.derma.easeOutCubic},
        {duration = duration * 0.3, easing = lia.derma.easeInOutCubic}
    }

    local currentPhase = 1
    local phaseStartTime = startTime

    panel.Think = function()
        local elapsed = CurTime() - phaseStartTime
        local phase = phases[currentPhase]

        if elapsed >= phase.duration then
            currentPhase = currentPhase + 1
            phaseStartTime = CurTime()
            elapsed = 0

            if currentPhase > #phases then
                panel.Think = nil
                return
            end

            phase = phases[currentPhase]
        end

        local progress = elapsed / phase.duration
        local easedProgress = phase.easing(progress)

        -- Apply different effects based on phase
        if currentPhase == 1 then
            panel:SetAlpha(easedProgress * 255)
        elseif currentPhase == 2 then
            local scale = 0.5 + easedProgress * 0.5
            panel:SetSize(panel.baseWidth * scale, panel.baseHeight * scale)
        elseif currentPhase == 3 then
            local offset = (1 - easedProgress) * 50
            panel:SetPos(panel.baseX + offset, panel.baseY)
        end
    end
end
```

---

### draw

**Purpose**

Draws a rounded rectangle with the specified radius for all corners, providing a simple way to create rounded rectangular shapes.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color of the rectangle.
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic rounded rectangle
lia.derma.draw(10, 100, 100, 200, 100, Color(100, 150, 255))

-- Draw a circle using high radius
lia.derma.draw(50, 200, 200, 100, 100, Color(255, 100, 100))

-- Draw with blur effect
lia.derma.draw(8, 50, 50, 150, 80, Color(100, 255, 100), lia.derma.BLUR)

-- Draw with shadow
lia.derma.draw(12, 300, 50, 120, 120, Color(255, 200, 100))
lia.derma.drawShadows(12, 300, 50, 120, 120, Color(0, 0, 0, 100), 20, 15)

-- Draw multiple rounded rectangles
local function drawButton(x, y, w, h, text, color)
    lia.derma.draw(8, x, y, w, h, color)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawButton(100, 200, 120, 40, "Click Me", Color(100, 150, 255))
drawButton(250, 200, 120, 40, "Cancel", Color(200, 100, 100))

-- Draw progress bar background
lia.derma.draw(6, 50, 300, 300, 20, Color(50, 50, 50))

-- Draw progress bar fill
local progress = 0.7 -- 70%
lia.derma.draw(6, 50, 300, 300 * progress, 20, Color(100, 200, 100))

-- Draw with different shapes
lia.derma.draw(15, 100, 100, 100, 100, Color(150, 100, 255), lia.derma.SHAPE_CIRCLE)
lia.derma.draw(15, 220, 100, 100, 100, Color(255, 150, 100), lia.derma.SHAPE_FIGMA)
lia.derma.draw(15, 340, 100, 100, 100, Color(100, 255, 150), lia.derma.SHAPE_IOS)
```

---

### drawBlur

**Purpose**

Draws a blurred rectangle with customizable corner radii, shape, and outline thickness for creating soft, blurred UI elements.

**Parameters**

* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `flags` (*number*, optional): Drawing flags to modify the appearance (shape, corners, etc.).
* `tl` (*number*, optional): Top-left corner radius.
* `tr` (*number*, optional): Top-right corner radius.
* `bl` (*number*, optional): Bottom-left corner radius.
* `br` (*number*, optional): Bottom-right corner radius.
* `thickness` (*number*, optional): Outline thickness if using outline flags.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic blurred rectangle
lia.derma.drawBlur(100, 100, 200, 100, nil, 10, 10, 10, 10)

-- Draw blurred rectangle with different corner radii
lia.derma.drawBlur(50, 200, 150, 80, nil, 5, 15, 20, 10)

-- Draw blurred circle
lia.derma.drawBlur(200, 50, 100, 100, lia.derma.SHAPE_CIRCLE, 50, 50, 50, 50)

-- Draw blurred rectangle with outline
lia.derma.drawBlur(300, 100, 120, 80, nil, 8, 8, 8, 8, 2)

-- Create a glowing effect with blur
local function drawGlowingButton(x, y, w, h, color, glowColor)
    -- Draw glow first (larger, blurred)
    lia.derma.drawBlur(x - 10, y - 10, w + 20, h + 20, nil, 15, 15, 15, 15)
    surface.SetDrawColor(glowColor)

    -- Draw main button
    lia.derma.draw(x, y, w, h, color)
end

drawGlowingButton(100, 300, 150, 40, Color(100, 150, 255), Color(100, 150, 255, 100))

-- Create soft shadow effect
lia.derma.drawBlur(50, 50, 100, 100, nil, 10, 10, 10, 10)
lia.derma.drawBlur(55, 55, 90, 90, nil, 8, 8, 8, 8)

-- Draw multiple blurred elements
local positions = {{100, 150}, {220, 150}, {340, 150}, {100, 270}, {220, 270}, {340, 270}}
for i, pos in ipairs(positions) do
    local color = HSVToColor(i * 60, 0.8, 1)
    lia.derma.drawBlur(pos[1], pos[2], 80, 80, lia.derma.SHAPE_CIRCLE, 40, 40, 40, 40)
    surface.SetDrawColor(color)
end

-- Create blurred background for text
lia.derma.drawBlur(200, 200, 300, 60, nil, 15, 15, 15, 15)
draw.SimpleText("Blurred Background Text", "LiliaFont.24", 350, 230, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
```

---

### drawCircle

**Purpose**

Draws a circle with the specified center position, radius, and color using the optimized circular drawing system.

**Parameters**

* `x` (*number*): The x coordinate of the circle center.
* `y` (*number*): The y coordinate of the circle center.
* `radius` (*number*): The radius of the circle.
* `col` (*Color*): The color of the circle.
* `flags` (*number*, optional): Drawing flags to modify the appearance (blur, outline, etc.).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic circle
lia.derma.drawCircle(ScrW() / 2, ScrH() / 2, 50, Color(255, 100, 100))

-- Draw multiple circles of different sizes and colors
local function drawColorfulCircles()
    local colors = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255), Color(255, 255, 0)}
    for i = 1, 4 do
        local radius = 20 + i * 15
        lia.derma.drawCircle(100 + i * 80, 100, radius, colors[i])
    end
end

drawColorfulCircles()

-- Draw outlined circles
lia.derma.drawCircle(200, 200, 40, Color(100, 200, 100))
lia.derma.drawCircleOutlined(200, 200, 45, Color(50, 150, 50), 3)

-- Draw blurred circles
lia.derma.drawCircle(300, 150, 30, Color(255, 150, 100), lia.derma.BLUR)

-- Draw circle with texture
lia.derma.drawCircleTexture(400, 150, 35, Color(255, 255, 255), "vgui/white")

-- Create animated circles
local time = RealTime()
local pulseRadius = 25 + math.sin(time * 3) * 10
lia.derma.drawCircle(500, 150, pulseRadius, Color(150, 100, 255))

-- Draw circle grid pattern
for x = 1, 5 do
    for y = 1, 3 do
        local circleX = 50 + x * 60
        local circleY = 250 + y * 60
        local color = HSVToColor((x + y) * 30, 0.8, 1)
        lia.derma.drawCircle(circleX, circleY, 20, color)
    end
end

-- Draw target circles (concentric)
local centerX, centerY = 300, 350
for i = 1, 5 do
    local radius = i * 15
    local alpha = 255 - i * 40
    lia.derma.drawCircle(centerX, centerY, radius, Color(255, 100, 100, alpha))
end

-- Interactive circle that follows mouse
local mouseX, mouseY = input.GetCursorPos()
lia.derma.drawCircle(mouseX, mouseY, 20, Color(100, 255, 100))
```

---

### drawCircleMaterial

**Purpose**

Draws a circle using a material for texture mapping, allowing for complex visual effects and detailed circle rendering.

**Parameters**

* `x` (*number*): The x coordinate of the circle center.
* `y` (*number*): The y coordinate of the circle center.
* `radius` (*number*): The radius of the circle.
* `col` (*Color*): The color tint to apply to the material.
* `mat` (*IMaterial*): The material to use for drawing the circle.
* `flags` (*number*, optional): Drawing flags to modify the appearance (blur, outline, etc.).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw circle with a material
local circleMat = Material("vgui/circle")
lia.derma.drawCircleMaterial(ScrW() / 2, ScrH() / 2, 50, Color(255, 255, 255), circleMat)

-- Draw circle with tinted material
local gradientMat = Material("gui/gradient")
lia.derma.drawCircleMaterial(200, 200, 40, Color(255, 100, 100), gradientMat)

-- Draw circle with animated material
local noiseMat = Material("effects/noise")
local time = RealTime()
lia.derma.drawCircleMaterial(300, 150, 30, Color(100, 150, 255, math.sin(time) * 128 + 128), noiseMat)

-- Draw circles with different materials
local materials = {
    Material("vgui/white"),
    Material("gui/center_gradient"),
    Material("effects/bubble"),
    Material("particle/particle_glow_05")
}

for i, mat in ipairs(materials) do
    local x = 100 + i * 80
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawCircleMaterial(x, 100, 25, color, mat)
end

-- Create textured buttons with materials
local function drawMaterialButton(x, y, radius, text, material, color)
    lia.derma.drawCircleMaterial(x, y, radius, color, material)
    draw.SimpleText(text, "LiliaFont.20", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawMaterialButton(200, 250, 30, "Save", Material("icon16/disk.png"), Color(100, 200, 100))
drawMaterialButton(280, 250, 30, "Load", Material("icon16/folder.png"), Color(200, 150, 100))
drawMaterialButton(360, 250, 30, "Delete", Material("icon16/cross.png"), Color(200, 100, 100))

-- Draw circle with material and blur effect
local sparkleMat = Material("effects/sparkle")
lia.derma.drawCircleMaterial(400, 200, 35, Color(255, 255, 150), sparkleMat, lia.derma.BLUR)

-- Interactive material circle that changes color on hover
local hoverX, hoverY = 300, 350
local isHovering = math.Distance(input.GetCursorPos(), hoverX, hoverY) < 40
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawCircleMaterial(hoverX, hoverY, 40, hoverColor, Material("gui/gradient"))
```

---

### drawCircleOutlined

**Purpose**

Draws an outlined circle with the specified center position, radius, color, and outline thickness using the optimized circular drawing system.

**Parameters**

* `x` (*number*): The x coordinate of the circle center.
* `y` (*number*): The y coordinate of the circle center.
* `radius` (*number*): The radius of the circle.
* `col` (*Color*): The color of the circle outline.
* `thickness` (*number*): The thickness of the outline.
* `flags` (*number*, optional): Drawing flags to modify the appearance (blur, etc.).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic outlined circle
lia.derma.drawCircleOutlined(ScrW() / 2, ScrH() / 2, 50, Color(255, 100, 100), 2)

-- Draw multiple outlined circles with different thicknesses
for i = 1, 5 do
    local radius = 20 + i * 10
    local thickness = i
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawCircleOutlined(100 + i * 60, 100, radius, color, thickness)
end

-- Draw outlined circles with blur effect
lia.derma.drawCircleOutlined(300, 150, 40, Color(100, 200, 255), 3, lia.derma.BLUR)

-- Create target-like outlined circles (concentric)
local centerX, centerY = 400, 200
for i = 1, 6 do
    local radius = i * 15
    local thickness = 2
    local alpha = 255 - i * 30
    lia.derma.drawCircleOutlined(centerX, centerY, radius, Color(255, 150, 100, alpha), thickness)
end

-- Draw outlined circle buttons
local function drawOutlinedButton(x, y, radius, text, color, thickness)
    lia.derma.drawCircleOutlined(x, y, radius, color, thickness)
    draw.SimpleText(text, "LiliaFont.20", x, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawOutlinedButton(200, 300, 25, "OK", Color(100, 200, 100), 2)
drawOutlinedButton(280, 300, 25, "Cancel", Color(200, 100, 100), 2)

-- Draw outlined circles with different line styles
lia.derma.drawCircleOutlined(100, 250, 30, Color(255, 255, 100), 1)
lia.derma.drawCircleOutlined(160, 250, 30, Color(255, 150, 255), 3)
lia.derma.drawCircleOutlined(220, 250, 30, Color(150, 255, 255), 5)

-- Interactive outlined circle that changes on hover
local hoverX, hoverY = 350, 300
local distance = math.Distance(input.GetCursorPos(), hoverX, hoverY)
local isHovering = distance < 35
local hoverThickness = isHovering and 4 or 2
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawCircleOutlined(hoverX, hoverY, 35, hoverColor, hoverThickness)

-- Draw outlined circle progress indicator
local progress = 0.75 -- 75%
local circleX, circleY = 450, 300
local radius = 30

-- Draw background circle (full outline)
lia.derma.drawCircleOutlined(circleX, circleY, radius, Color(100, 100, 100), 3)

-- Draw progress arc (partial outline)
-- Note: This would require custom implementation for arc drawing
```

---

### drawCircleTexture

**Purpose**

Draws a circle using a texture for detailed visual effects and pattern mapping, allowing for complex circle rendering with texture support.

**Parameters**

* `x` (*number*): The x coordinate of the circle center.
* `y` (*number*): The y coordinate of the circle center.
* `radius` (*number*): The radius of the circle.
* `col` (*Color*): The color tint to apply to the texture.
* `texture` (*string*): The texture path to use for drawing the circle.
* `flags` (*number*, optional): Drawing flags to modify the appearance (blur, outline, etc.).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw circle with a texture
lia.derma.drawCircleTexture(ScrW() / 2, ScrH() / 2, 50, Color(255, 255, 255), "vgui/white")

-- Draw circle with tinted texture
lia.derma.drawCircleTexture(200, 200, 40, Color(255, 100, 100), "gui/gradient")

-- Draw circles with different textures
local textures = {
    "vgui/white",
    "gui/center_gradient",
    "effects/bubble",
    "particle/particle_glow_05"
}

for i, texture in ipairs(textures) do
    local x = 100 + i * 80
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawCircleTexture(x, 100, 25, color, texture)
end

-- Create textured circle buttons
local function drawTextureButton(x, y, radius, text, texture, color)
    lia.derma.drawCircleTexture(x, y, radius, color, texture)
    draw.SimpleText(text, "LiliaFont.20", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawTextureButton(200, 250, 30, "Save", "icon16/disk.png", Color(100, 200, 100))
drawTextureButton(280, 250, 30, "Load", "icon16/folder.png", Color(200, 150, 100))
drawTextureButton(360, 250, 30, "Delete", "icon16/cross.png", Color(200, 100, 100))

-- Draw circle with texture and blur effect
lia.derma.drawCircleTexture(400, 200, 35, Color(255, 255, 150), "effects/sparkle", lia.derma.BLUR)

-- Animated textured circle
local time = RealTime()
local pulseAlpha = math.sin(time * 2) * 64 + 192
lia.derma.drawCircleTexture(300, 150, 30, Color(100, 150, 255, pulseAlpha), "gui/gradient")

-- Interactive textured circle that changes texture on hover
local hoverX, hoverY = 350, 300
local distance = math.Distance(input.GetCursorPos(), hoverX, hoverY)
local isHovering = distance < 35
local hoverTexture = isHovering and "effects/sparkle" or "gui/gradient"
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawCircleTexture(hoverX, hoverY, 35, hoverColor, hoverTexture)

-- Draw textured circle grid pattern
for x = 1, 4 do
    for y = 1, 3 do
        local circleX = 50 + x * 70
        local circleY = 350 + y * 70
        local texture = (x + y) % 2 == 0 and "vgui/white" or "gui/center_gradient"
        local color = HSVToColor((x + y) * 45, 0.8, 1)
        lia.derma.drawCircleTexture(circleX, circleY, 25, color, texture)
    end
end

-- Create pattern overlay with textured circles
local overlayTexture = "effects/noise"
for i = 1, 20 do
    local randomX = math.random(50, ScrW() - 50)
    local randomY = math.random(50, ScrH() - 50)
    local randomSize = math.random(10, 30)
    lia.derma.drawCircleTexture(randomX, randomY, randomSize, Color(255, 255, 255, 50), overlayTexture)
end
```

---

### drawMaterial

**Purpose**

Draws a rounded rectangle using a material for advanced texture mapping and visual effects, automatically extracting the base texture from the material.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color tint to apply to the material.
* `mat` (*IMaterial*): The material to use for drawing.
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw with a basic material
local testMaterial = Material("vgui/white")
lia.derma.drawMaterial(10, 100, 100, 200, 100, Color(100, 150, 255), testMaterial)

-- Draw with a gradient material
local gradientMat = Material("gui/gradient")
lia.derma.drawMaterial(8, 50, 200, 150, 80, Color(255, 100, 100), gradientMat)

-- Draw with animated material properties
local animatedMat = Material("effects/noise")
local time = RealTime()
local pulseColor = Color(100, 150, 255, math.sin(time * 3) * 128 + 128)
lia.derma.drawMaterial(12, 300, 50, 120, 120, pulseColor, animatedMat)

-- Draw buttons with different materials
local materials = {
    Material("vgui/white"),
    Material("gui/center_gradient"),
    Material("effects/bubble"),
    Material("particle/particle_glow_05")
}

for i, mat in ipairs(materials) do
    local x = 100 + i * 80
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawMaterial(6, x, 100, 60, 40, color, mat)
end

-- Create material-based UI elements
local function drawMaterialButton(x, y, w, h, text, material, color)
    lia.derma.drawMaterial(8, x, y, w, h, color, material)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawMaterialButton(200, 250, 120, 40, "Save", Material("icon16/disk.png"), Color(100, 200, 100))
drawMaterialButton(350, 250, 120, 40, "Load", Material("icon16/folder.png"), Color(200, 150, 100))

-- Draw with material and blur effect
local sparkleMat = Material("effects/sparkle")
lia.derma.drawMaterial(15, 400, 100, 100, 100, Color(255, 255, 150), sparkleMat, lia.derma.BLUR)

-- Interactive material element that changes on hover
local hoverX, hoverY, hoverW, hoverH = 300, 350, 80, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 50
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawMaterial(10, hoverX, hoverY, hoverW, hoverH, hoverColor, Material("gui/gradient"))
```

---

### drawOutlined

**Purpose**

Draws an outlined rounded rectangle with customizable corner radius and outline thickness for creating bordered UI elements.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color of the outline.
* `thickness` (*number*, optional): The thickness of the outline (default: 1).
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic outlined rectangle
lia.derma.drawOutlined(10, 100, 100, 200, 100, Color(255, 100, 100), 2)

-- Draw outlined rectangles with different thicknesses
for i = 1, 5 do
    local thickness = i
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawOutlined(8, 50 + i * 70, 50, 60, 40, color, thickness)
end

-- Draw outlined rectangle with blur effect
lia.derma.drawOutlined(12, 300, 100, 120, 80, Color(100, 200, 255), 3, lia.derma.BLUR)

-- Create outlined buttons
local function drawOutlinedButton(x, y, w, h, text, color, thickness)
    lia.derma.drawOutlined(8, x, y, w, h, color, thickness)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawOutlinedButton(200, 200, 120, 40, "OK", Color(100, 200, 100), 2)
drawOutlinedButton(350, 200, 120, 40, "Cancel", Color(200, 100, 100), 2)

-- Draw interactive outlined element that changes on hover
local hoverX, hoverY, hoverW, hoverH = 250, 300, 100, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 60
local hoverThickness = isHovering and 4 or 2
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawOutlined(10, hoverX, hoverY, hoverW, hoverH, hoverColor, hoverThickness)

-- Draw progress bar with outline
lia.derma.drawOutlined(6, 50, 350, 300, 20, Color(100, 100, 100), 2)
local progress = 0.7 -- 70%
lia.derma.draw(6, 50, 350, 300 * progress, 20, Color(100, 200, 100))

-- Draw outlined shapes with different corner styles
lia.derma.drawOutlined(15, 100, 250, 80, 80, Color(255, 150, 100), 3, lia.derma.SHAPE_CIRCLE)
lia.derma.drawOutlined(15, 200, 250, 80, 80, Color(100, 255, 150), 3, lia.derma.SHAPE_FIGMA)
lia.derma.drawOutlined(15, 300, 250, 80, 80, Color(150, 100, 255), 3, lia.derma.SHAPE_IOS)
```

---

### drawShadows

**Purpose**

Draws drop shadows for rounded rectangles with customizable spread, intensity, and shape flags for creating depth effects.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color of the shadow.
* `spread` (*number*, optional): The spread distance of the shadow (default: 30).
* `intensity` (*number*, optional): The intensity/opacity of the shadow (default: spread * 1.2).
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic shadowed rectangle
lia.derma.drawShadows(10, 100, 100, 200, 100, Color(0, 0, 0, 100), 20, 15)

-- Draw rectangle with shadow and main content
lia.derma.drawShadows(8, 50, 50, 150, 80, Color(0, 0, 0, 150), 25, 20)
lia.derma.draw(8, 50, 50, 150, 80, Color(100, 150, 255))

-- Draw multiple shadowed elements
local shadowColors = {Color(255, 0, 0, 100), Color(0, 255, 0, 100), Color(0, 0, 255, 100)}
for i = 1, 3 do
    local y = 100 + i * 100
    lia.derma.drawShadows(12, 200 + i * 80, y, 100, 60, shadowColors[i], 30, 25)
    lia.derma.draw(12, 200 + i * 80, y, 100, 60, Color(255, 255, 255))
end

-- Create shadowed buttons
local function drawShadowedButton(x, y, w, h, text, shadowColor, mainColor)
    lia.derma.drawShadows(8, x, y, w, h, shadowColor, 20, 15)
    lia.derma.draw(8, x, y, w, h, mainColor)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawShadowedButton(100, 300, 120, 40, "Save", Color(0, 0, 0, 150), Color(100, 200, 100))
drawShadowedButton(250, 300, 120, 40, "Cancel", Color(0, 0, 0, 150), Color(200, 100, 100))

-- Draw shadowed elements with different shapes
lia.derma.drawShadows(15, 100, 200, 80, 80, Color(0, 0, 0, 100), 25, 20, lia.derma.SHAPE_CIRCLE)
lia.derma.draw(15, 100, 200, 80, 80, Color(150, 100, 255))

lia.derma.drawShadows(15, 100, 300, 80, 80, Color(0, 0, 0, 100), 25, 20, lia.derma.SHAPE_FIGMA)
lia.derma.draw(15, 100, 300, 80, 80, Color(255, 150, 100))

-- Interactive shadowed element that changes on hover
local hoverX, hoverY, hoverW, hoverH = 300, 200, 100, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 60
local shadowIntensity = isHovering and 30 or 15
lia.derma.drawShadows(10, hoverX, hoverY, hoverW, hoverH, Color(0, 0, 0, 150), 25, shadowIntensity)
lia.derma.draw(10, hoverX, hoverY, hoverW, hoverH, isHovering and Color(255, 255, 100) or Color(150, 150, 255))
```

---

### drawShadowsOutlined

**Purpose**

Draws an outlined rectangle with drop shadows, combining the effects of `drawShadows` and `drawOutlined` for creating bordered UI elements with depth.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color of the shadow and outline.
* `thickness` (*number*, optional): The thickness of the outline (default: 1).
* `spread` (*number*, optional): The spread distance of the shadow (default: 30).
* `intensity` (*number*, optional): The intensity/opacity of the shadow (default: spread * 1.2).
* `flags` (*number*, optional): Drawing flags to modify the appearance (shape, blur, corners, etc.).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a basic outlined rectangle with shadow
lia.derma.drawShadowsOutlined(10, 100, 100, 200, 100, Color(0, 0, 0, 150), 2, 20, 15)

-- Draw shadowed outlined rectangle with blur effect
lia.derma.drawShadowsOutlined(12, 50, 50, 150, 80, Color(0, 0, 0, 100), 3, 25, 20, lia.derma.BLUR)

-- Create shadowed outlined buttons
local function drawShadowedOutlinedButton(x, y, w, h, text, shadowColor, mainColor, thickness)
    lia.derma.drawShadowsOutlined(8, x, y, w, h, shadowColor, thickness, 20, 15)
    lia.derma.draw(8, x, y, w, h, mainColor)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawShadowedOutlinedButton(100, 300, 120, 40, "Save", Color(0, 0, 0, 150), Color(100, 200, 100), 2)
drawShadowedOutlinedButton(250, 300, 120, 40, "Cancel", Color(0, 0, 0, 150), Color(200, 100, 100), 2)

-- Draw shadowed outlined elements with different shapes
lia.derma.drawShadowsOutlined(15, 100, 200, 80, 80, Color(0, 0, 0, 100), 3, 25, 20, lia.derma.SHAPE_CIRCLE)
lia.derma.draw(15, 100, 200, 80, 80, Color(150, 100, 255))

lia.derma.drawShadowsOutlined(15, 100, 300, 80, 80, Color(0, 0, 0, 100), 3, 25, 20, lia.derma.SHAPE_FIGMA)
lia.derma.draw(15, 100, 300, 80, 80, Color(255, 150, 100))

-- Interactive shadowed outlined element that changes on hover
local hoverX, hoverY, hoverW, hoverH = 300, 200, 100, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 60
local shadowIntensity = isHovering and 30 or 15
local hoverThickness = isHovering and 4 or 2
lia.derma.drawShadowsOutlined(10, hoverX, hoverY, hoverW, hoverH, Color(0, 0, 0, 150), hoverThickness, 25, shadowIntensity)
lia.derma.draw(10, hoverX, hoverY, hoverW, hoverH, isHovering and Color(255, 255, 100) or Color(150, 150, 255))
```

**Available Flags**

* `lia.derma.BLUR` - Applies blur effect to the shadow
* `lia.derma.SHAPE_CIRCLE` - Perfect circle corners
* `lia.derma.SHAPE_FIGMA` - Figma-style rounded corners (default)
* `lia.derma.SHAPE_IOS` - iOS-style rounded corners
* `lia.derma.NO_TL` - Removes top-left corner radius
* `lia.derma.NO_TR` - Removes top-right corner radius
* `lia.derma.NO_BL` - Removes bottom-left corner radius
* `lia.derma.NO_BR` - Removes bottom-right corner radius

---

### drawTexture

**Purpose**

Draws a rounded rectangle using a texture for detailed visual effects and pattern mapping, allowing for complex rectangular rendering with texture support.

**Parameters**

* `radius` (*number*): The corner radius for all four corners.
* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color tint to apply to the texture.
* `texture` (*string*): The texture path to use for drawing.
* `flags` (*number*, optional): Drawing flags to modify the appearance.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw rectangle with a texture
lia.derma.drawTexture(10, 100, 100, 200, 100, Color(255, 255, 255), "vgui/white")

-- Draw rectangle with tinted texture
lia.derma.drawTexture(8, 50, 200, 150, 80, Color(255, 100, 100), "gui/gradient")

-- Draw rectangles with different textures
local textures = {
    "vgui/white",
    "gui/center_gradient",
    "effects/bubble",
    "particle/particle_glow_05"
}

for i, texture in ipairs(textures) do
    local x = 100 + i * 80
    local color = HSVToColor(i * 60, 1, 1)
    lia.derma.drawTexture(6, x, 50, 60, 40, color, texture)
end

-- Create textured buttons
local function drawTextureButton(x, y, w, h, text, texture, color)
    lia.derma.drawTexture(8, x, y, w, h, color, texture)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawTextureButton(200, 150, 120, 40, "Save", "icon16/disk.png", Color(100, 200, 100))
drawTextureButton(350, 150, 120, 40, "Load", "icon16/folder.png", Color(200, 150, 100))

-- Draw rectangle with texture and blur effect
lia.derma.drawTexture(15, 400, 50, 100, 100, Color(255, 255, 150), "effects/sparkle", lia.derma.BLUR)

-- Animated textured rectangle
local time = RealTime()
local pulseAlpha = math.sin(time * 2) * 64 + 192
lia.derma.drawTexture(12, 250, 100, 120, 80, Color(100, 150, 255, pulseAlpha), "gui/gradient")

-- Interactive textured element that changes texture on hover
local hoverX, hoverY, hoverW, hoverH = 300, 250, 100, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 60
local hoverTexture = isHovering and "effects/sparkle" or "gui/gradient"
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.drawTexture(10, hoverX, hoverY, hoverW, hoverH, hoverColor, hoverTexture)

-- Draw textured background pattern
local overlayTexture = "effects/noise"
for i = 1, 20 do
    local randomX = math.random(50, ScrW() - 150)
    local randomY = math.random(50, ScrH() - 100)
    lia.derma.drawTexture(5, randomX, randomY, 100, 60, Color(255, 255, 255, 50), overlayTexture)
end

-- Create progress bar with textured background
lia.derma.drawTexture(6, 50, 300, 300, 20, Color(255, 255, 255), "gui/gradient")
local progress = 0.7 -- 70%
lia.derma.draw(6, 50, 300, 300 * progress, 20, Color(100, 200, 100))
```

---

### drawShadowsEx

**Purpose**

Draws advanced drop shadows for rounded rectangles with full customization of corner radii, shadow properties, and outline thickness for creating sophisticated depth effects.

**Parameters**

* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color of the shadow.
* `flags` (*number*, optional): Drawing flags to modify the appearance (shape, corners, blur, etc.).
* `tl` (*number*, optional): Top-left corner radius.
* `tr` (*number*, optional): Top-right corner radius.
* `bl` (*number*, optional): Bottom-left corner radius.
* `br` (*number*, optional): Bottom-right corner radius.
* `spread` (*number*, optional): The spread distance of the shadow (default: 30).
* `intensity` (*number*, optional): The intensity/opacity of the shadow (default: spread * 1.2).
* `thickness` (*number*, optional): Outline thickness if using outline flags.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw shadow with custom corner radii
lia.derma.drawShadowsEx(100, 100, 200, 100, Color(0, 0, 0, 100), nil, 5, 15, 20, 10, 25, 20)

-- Draw shadowed rectangle with different corner styles
lia.derma.drawShadowsEx(50, 200, 150, 80, Color(0, 0, 0, 150), lia.derma.SHAPE_CIRCLE, 50, 50, 50, 50, 30, 25)
lia.derma.draw(8, 50, 200, 150, 80, Color(100, 150, 255))

-- Draw shadow with blur effect
lia.derma.drawShadowsEx(300, 100, 120, 80, Color(0, 0, 0, 100), lia.derma.BLUR, 8, 8, 8, 8, 25, 20)

-- Create advanced shadowed buttons with individual corner control
local function drawAdvancedShadowedButton(x, y, w, h, text, shadowColor, mainColor, tl, tr, bl, br)
    lia.derma.drawShadowsEx(x, y, w, h, shadowColor, nil, tl, tr, bl, br, 20, 15)
    lia.derma.draw(tl, x, y, w, h, mainColor)
    draw.SimpleText(text, "LiliaFont.20", x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawAdvancedShadowedButton(100, 300, 120, 40, "Rounded", Color(0, 0, 0, 150), Color(100, 200, 100), 8, 8, 8, 8)
drawAdvancedShadowedButton(250, 300, 120, 40, "Mixed", Color(0, 0, 0, 150), Color(200, 100, 100), 5, 15, 20, 10)

-- Draw shadow with outline
lia.derma.drawShadowsEx(200, 200, 100, 60, Color(0, 0, 0, 150), nil, 10, 10, 10, 10, 25, 20, 2)

-- Interactive shadowed element with dynamic properties
local hoverX, hoverY, hoverW, hoverH = 300, 250, 100, 60
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 60
local shadowSpread = isHovering and 35 or 25
local shadowIntensity = isHovering and 30 or 15
lia.derma.drawShadowsEx(hoverX, hoverY, hoverW, hoverH, Color(0, 0, 0, 150), nil, 10, 10, 10, 10, shadowSpread, shadowIntensity)
lia.derma.draw(10, hoverX, hoverY, hoverW, hoverH, isHovering and Color(255, 255, 100) or Color(150, 150, 255))
```

---

### requestString

**Purpose**

Creates a modal dialog for requesting a string input from the user with a title, description, and optional default value.

**Parameters**

* `title` (*string*): The title of the dialog.
* `description` (*string*): The description/placeholder text for the input field.
* `callback` (*function*): The function to call with the entered string (or false if cancelled).
* `defaultValue` (*string*, optional): The default value for the input field.
* `maxLength` (*number*, optional): The maximum length of the input string.

**Returns**

* `frame` (*liaFrame*): The created dialog frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic string input dialog
lia.derma.requestString("Enter Name", "Please enter your name", function(name)
    if name then
        print("User entered:", name)
        playerName = name
    else
        print("User cancelled")
    end
end)

-- String input with default value
lia.derma.requestString("Edit Name", "Current name", function(newName)
    if newName and newName ~= "" then
        updatePlayerName(newName)
    end
end, "Default Name")

-- Password input with length limit
lia.derma.requestString("Set Password", "Enter new password", function(password)
    if password then
        if string.len(password) >= 8 then
            setPlayerPassword(password)
            print("Password updated successfully")
        else
            print("Password must be at least 8 characters")
        end
    end
end, "", 20)

-- Input for item naming
lia.derma.requestString("Name Item", "Enter a name for this item", function(itemName)
    if itemName and itemName ~= "" then
        currentItem.name = itemName
        print("Item renamed to:", itemName)
    end
end, currentItem.name)

-- Sequential input prompts
local function promptForDetails()
    lia.derma.requestString("Enter Title", "What is the title?", function(title)
        if title then
            lia.derma.requestString("Enter Description", "Describe it briefly", function(description)
                if description then
                    lia.derma.requestString("Enter Tags", "Comma-separated tags", function(tags)
                        if tags then
                            saveContent(title, description, tags)
                        end
                    end)
                end
            end)
        end
    end)
end

-- Input with validation
lia.derma.requestString("Enter Steam ID", "Enter Steam ID (STEAM_0:...)", function(steamID)
    if steamID then
        if string.match(steamID, "^STEAM_[01]:[01]:%d+$") then
            connectToSteamID(steamID)
        else
            print("Invalid Steam ID format")
            -- Show dialog again with error message
            timer.Simple(0.1, function()
                lia.derma.requestString("Enter Steam ID", "Invalid format. Use STEAM_0:X:XXXXX", function(newSteamID)
                    if newSteamID and string.match(newSteamID, "^STEAM_[01]:[01]:%d+$") then
                        connectToSteamID(newSteamID)
                    end
                end, steamID)
            end)
        end
    end
end)

-- Input for search functionality
lia.derma.requestString("Search", "Enter search terms", function(searchText)
    if searchText then
        performSearch(searchText)
    end
end)
```

---

### requestBinaryQuestion

**Purpose**

Creates a modal dialog for asking the user a yes/no question with customizable button text and a descriptive question.

**Parameters**

* `title` (*string*): The title of the dialog.
* `question` (*string*): The question text to display.
* `callback` (*function*): The function to call with the user's choice (true for yes, false for no).
* `yesText` (*string*, optional): The text for the yes button (default: "Yes").
* `noText` (*string*, optional): The text for the no button (default: "No").

**Returns**

* `frame` (*liaFrame*): The created dialog frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic yes/no question
lia.derma.requestBinaryQuestion("Confirm Action", "Are you sure you want to proceed?", function(confirmed)
    if confirmed then
        print("User confirmed")
        proceedWithAction()
    else
        print("User cancelled")
    end
end)

-- Custom button text
lia.derma.requestBinaryQuestion("Delete Item", "Do you want to permanently delete this item?", function(delete)
    if delete then
        deleteItem()
    end
end, "Delete", "Cancel")

-- Confirmation for dangerous actions
lia.derma.requestBinaryQuestion("Warning", "This action cannot be undone. Continue?", function(confirmed)
    if confirmed then
        performDangerousAction()
    end
end, "Continue", "Cancel")

-- Use in admin functions
lia.derma.requestBinaryQuestion("Kick Player", "Are you sure you want to kick " .. targetPlayer:Name() .. "?", function(kick)
    if kick then
        kickPlayer(targetPlayer)
    end
end, "Kick", "Cancel")

-- Confirmation for settings changes
lia.derma.requestBinaryQuestion("Reset Settings", "This will reset all settings to default. Continue?", function(reset)
    if reset then
        resetAllSettings()
        print("Settings reset to default")
    end
end, "Reset", "Keep Current")

-- Sequential confirmations
local function confirmMultipleActions()
    lia.derma.requestBinaryQuestion("First Action", "Perform first action?", function(confirmed)
        if confirmed then
            performFirstAction()
            lia.derma.requestBinaryQuestion("Second Action", "Perform second action?", function(confirmed2)
                if confirmed2 then
                    performSecondAction()
                end
            end)
        end
    end)
end

-- Confirmation with custom titles
lia.derma.requestBinaryQuestion("Security Check", "Allow this application to access your files?", function(allow)
    if allow then
        grantFileAccess()
    else
        denyFileAccess()
    end
end, "Allow", "Deny")

-- Use in error handling
local function handleError(errorMessage)
    lia.derma.requestBinaryQuestion("Error Occurred", "An error occurred: " .. errorMessage .. "\nTry again?", function(retry)
        if retry then
            retryOperation()
        else
            cancelOperation()
        end
    end, "Retry", "Cancel")
end
```

---

### openOptionsMenu

**Purpose**

Opens a simple menu dialog with multiple options for user selection, providing a quick way to present choices without complex form handling.

**Parameters**

* `title` (*string*): The title of the options menu.
* `options` (*table*): A table of options where each option can be:
  - A string (option name with callback of the same name)
  - A table with `name` and `callback` keys
  - An array with [name, callback] structure.

**Returns**

* `frame` (*DFrame*): The created options menu frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic options menu with string keys
lia.derma.openOptionsMenu("Choose Action", {
    "Option 1",
    "Option 2",
    "Option 3"
})

-- Options menu with table format
lia.derma.openOptionsMenu("Select Tool", {
    {name = "Hammer", callback = function() print("Selected Hammer") end},
    {name = "Screwdriver", callback = function() print("Selected Screwdriver") end},
    {name = "Wrench", callback = function() print("Selected Wrench") end}
})

-- Options menu with array format
lia.derma.openOptionsMenu("Game Mode", {
    {"Single Player", function() startSinglePlayer() end},
    {"Multiplayer", function() startMultiplayer() end},
    {"Settings", function() openSettings() end}
})

-- Use in context menus
local function showPlayerOptions(player)
    lia.derma.openOptionsMenu("Player Actions", {
        {"Send Message", function() openMessageDialog(player) end},
        {"Trade Items", function() openTradeDialog(player) end},
        {"View Profile", function() openProfile(player) end},
        {"Add Friend", function() addFriend(player) end}
    })
end

-- Options menu for item actions
local function showItemOptions(item)
    lia.derma.openOptionsMenu("Item Actions", {
        {"Use Item", function() useItem(item) end},
        {"Drop Item", function() dropItem(item) end},
        {"Give to Player", function() giveItemToPlayer(item) end}
    })
end

-- Dynamic options based on conditions
local function showConditionalOptions()
    local options = {}

    if canEdit then
        table.insert(options, {"Edit", function() editMode() end})
    end

    if canDelete then
        table.insert(options, {"Delete", function() deleteItem() end})
    end

    table.insert(options, {"Cancel", function() closeMenu() end})

    lia.derma.openOptionsMenu("Actions", options)
end

-- Options menu for admin functions
lia.derma.openOptionsMenu("Admin Tools", {
    {"Kick Player", function() openKickDialog() end},
    {"Ban Player", function() openBanDialog() end},
    {"Mute Player", function() openMuteDialog() end},
    {"Teleport", function() openTeleportDialog() end}
})

-- Options menu for game settings
lia.derma.openOptionsMenu("Graphics Settings", {
    {"Low Quality", function() setGraphicsQuality("low") end},
    {"Medium Quality", function() setGraphicsQuality("medium") end},
    {"High Quality", function() setGraphicsQuality("high") end},
    {"Ultra Quality", function() setGraphicsQuality("ultra") end}
})
```

---

### requestButtons

**Purpose**

Creates a modal dialog with multiple button options for user selection, providing a flexible way to present various choices with custom text and icons.

**Parameters**

* `title` (*string*): The title of the dialog.
* `buttons` (*table*): An array of button definitions where each button can be:
  - A string (button text)
  - A table with `text`, `callback`, and optional `icon` keys
  - An array with [text, callback, icon] structure.
* `callback` (*function*, optional): A function to call with the selected button index and text when a button is clicked.
* `description` (*string*, optional): A description to display above the buttons.

**Returns**

* `frame` (*liaFrame*): The created dialog frame.
* `buttonPanels` (*table*): An array of the created button panels.

**Realm**

Client.

**Example Usage**

```lua
-- Basic button dialog with string buttons
lia.derma.requestButtons("Choose Action", {
    "Option 1",
    "Option 2",
    "Option 3"
}, function(index, text)
    print("Selected option " .. index .. ": " .. text)
end)

-- Button dialog with table format
lia.derma.requestButtons("Select Tool", {
    {text = "Hammer", callback = function() print("Selected Hammer") end, icon = "icon16/hammer.png"},
    {text = "Screwdriver", callback = function() print("Selected Screwdriver") end, icon = "icon16/screwdriver.png"},
    {text = "Wrench", callback = function() print("Selected Wrench") end, icon = "icon16/wrench.png"}
})

-- Button dialog with array format and description
lia.derma.requestButtons("Game Mode", {
    {"Single Player", function() startSinglePlayer() end, "icon16/user.png"},
    {"Multiplayer", function() startMultiplayer() end, "icon16/group.png"},
    {"Settings", function() openSettings() end, "icon16/cog.png"}
}, nil, "Choose your preferred game mode")

-- Use in context menus for player actions
local function showPlayerActionDialog(player)
    lia.derma.requestButtons("Player Actions", {
        {"Send Message", function() openMessageDialog(player) end, "icon16/email.png"},
        {"Trade Items", function() openTradeDialog(player) end, "icon16/arrow_switch.png"},
        {"View Profile", function() openProfile(player) end, "icon16/vcard.png"},
        {"Add Friend", function() addFriend(player) end, "icon16/user_add.png"}
    })
end

-- Button dialog for item actions
local function showItemActionDialog(item)
    lia.derma.requestButtons("Item Actions", {
        {"Use Item", function() useItem(item) end, "icon16/accept.png"},
        {"Drop Item", function() dropItem(item) end, "icon16/cross.png"},
        {"Give to Player", function() giveItemToPlayer(item) end, "icon16/user_go.png"}
    })
end

-- Dynamic buttons based on conditions
local function showConditionalButtons()
    local buttons = {}

    if canEdit then
        table.insert(buttons, {"Edit", function() editMode() end, "icon16/pencil.png"})
    end

    if canDelete then
        table.insert(buttons, {"Delete", function() deleteItem() end, "icon16/delete.png"})
    end

    table.insert(buttons, {"Cancel", function() closeMenu() end, "icon16/cancel.png"})

    lia.derma.requestButtons("Actions", buttons)
end

-- Button dialog for admin functions
lia.derma.requestButtons("Admin Tools", {
    {"Kick Player", function() openKickDialog() end, "icon16/user_delete.png"},
    {"Ban Player", function() openBanDialog() end, "icon16/shield.png"},
    {"Mute Player", function() openMuteDialog() end, "icon16/sound_mute.png"},
    {"Teleport", function() openTeleportDialog() end, "icon16/arrow_right.png"}
})

-- Button dialog for game settings
lia.derma.requestButtons("Graphics Settings", {
    {"Low Quality", function() setGraphicsQuality("low") end},
    {"Medium Quality", function() setGraphicsQuality("medium") end},
    {"High Quality", function() setGraphicsQuality("high") end},
    {"Ultra Quality", function() setGraphicsQuality("ultra") end}
}, function(index, text)
    print("Selected quality: " .. text)
end, "Choose your graphics quality setting")
```

---

### requestDropdown

**Purpose**

Creates a modal dialog with a dropdown selection for choosing from a list of options, providing a compact way to present multiple choices.

**Parameters**

* `title` (*string*): The title of the dialog.
* `options` (*table*): An array of options where each option can be:
  - A string (option text)
  - A table with [displayText, value] structure for display text different from the actual value.
* `callback` (*function*): The function to call with the selected option text and value.
* `defaultValue` (*string* or *table*, optional): The default selected value or [displayText, value] pair.

**Returns**

* `frame` (*liaFrame*): The created dialog frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic dropdown selection
lia.derma.requestDropdown("Select Color", {
    "Red",
    "Green",
    "Blue",
    "Yellow"
}, function(selectedText, selectedValue)
    print("Selected: " .. selectedText)
    setThemeColor(selectedText)
end)

-- Dropdown with different display text and values
lia.derma.requestDropdown("Choose Resolution", {
    {"1920x1080 (Full HD)", "1920x1080"},
    {"2560x1440 (2K)", "2560x1440"},
    {"3840x2160 (4K)", "3840x2160"}
}, function(displayText, value)
    print("Selected resolution: " .. value)
    setGameResolution(value)
end)

-- Dropdown with default value
lia.derma.requestDropdown("Select Quality", {
    "Low",
    "Medium",
    "High",
    "Ultra"
}, function(quality)
    setGraphicsQuality(quality)
end, "Medium")

-- Dropdown for item selection
lia.derma.requestDropdown("Choose Item", {
    {"Health Potion", "health_potion"},
    {"Mana Potion", "mana_potion"},
    {"Stamina Potion", "stamina_potion"}
}, function(displayName, itemID)
    if itemID then
        useItem(itemID)
    end
end)

-- Dropdown for player selection
local players = {}
for _, ply in ipairs(player.GetAll()) do
    if ply ~= LocalPlayer() then
        table.insert(players, {ply:Name(), ply})
    end
end

lia.derma.requestDropdown("Select Player", players, function(playerName, player)
    if player and IsValid(player) then
        openTradeDialog(player)
    end
end)

-- Dropdown for time zone selection
lia.derma.requestDropdown("Select Timezone", {
    {"UTC-8 (Pacific)", "UTC-8"},
    {"UTC-5 (Eastern)", "UTC-5"},
    {"UTC+0 (GMT)", "UTC+0"},
    {"UTC+1 (Central European)", "UTC+1"},
    {"UTC+8 (China)", "UTC+8"}
}, function(displayName, timezone)
    setPlayerTimezone(timezone)
end, {"UTC+0 (GMT)", "UTC+0"})

-- Dropdown for weapon selection
local weapons = {
    {"AK-47", "weapon_ak47"},
    {"M4A1", "weapon_m4a1"},
    {"AWP", "weapon_awp"},
    {"Desert Eagle", "weapon_deagle"}
}

lia.derma.requestDropdown("Choose Weapon", weapons, function(weaponName, weaponClass)
    if weaponClass then
        givePlayerWeapon(weaponClass)
    end
end)
```

---

### requestOptions

**Purpose**

Creates a modal dialog with multiple checkbox options for user selection, allowing users to choose multiple items from a list.

**Parameters**

* `title` (*string*): The title of the dialog.
* `options` (*table*): An array of options where each option can be:
  - A string (option text)
  - A table with [displayText, value] structure for display text different from the actual value.
* `callback` (*function*): The function to call with an array of selected options.
* `defaults` (*table*, optional): An array of default selected values.

**Returns**

* `frame` (*liaFrame*): The created dialog frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic multiple selection
lia.derma.requestOptions("Select Colors", {
    "Red",
    "Green",
    "Blue",
    "Yellow"
}, function(selectedOptions)
    print("Selected colors:", table.concat(selectedOptions, ", "))
    for _, color in ipairs(selectedOptions) do
        enableColorFilter(color)
    end
end)

-- Options with different display text and values
lia.derma.requestOptions("Choose Permissions", {
    {"View Reports", "reports.view"},
    {"Edit Reports", "reports.edit"},
    {"Delete Reports", "reports.delete"},
    {"Manage Users", "users.manage"}
}, function(selectedPermissions)
    for _, permission in ipairs(selectedPermissions) do
        grantUserPermission(permission)
    end
end)

-- Options with default selections
lia.derma.requestOptions("Select Features", {
    "Auto-save",
    "Notifications",
    "Sound Effects",
    "Music",
    "Tooltips"
}, function(selectedFeatures)
    for _, feature in ipairs(selectedFeatures) do
        enableFeature(feature)
    end
end, {"Auto-save", "Notifications"})

-- Use for item selection
lia.derma.requestOptions("Choose Items to Buy", {
    {"Health Potion", "health_potion"},
    {"Mana Potion", "mana_potion"},
    {"Sword", "weapon_sword"},
    {"Shield", "armor_shield"}
}, function(selectedItems)
    for _, itemID in ipairs(selectedItems) do
        purchaseItem(itemID)
    end
end)

-- Options for poll creation
lia.derma.requestOptions("Select Poll Options", {
    "Option A",
    "Option B",
    "Option C",
    "Option D"
}, function(selectedOptions)
    if #selectedOptions >= 2 then
        createPoll(selectedOptions)
    else
        print("Please select at least 2 options")
    end
end)

-- Options for tag selection
lia.derma.requestOptions("Select Tags", {
    {"Action", "action"},
    {"Adventure", "adventure"},
    {"RPG", "rpg"},
    {"Strategy", "strategy"},
    {"Puzzle", "puzzle"}
}, function(selectedTags)
    for _, tag in ipairs(selectedTags) do
        addGameTag(tag)
    end
end, {"action", "adventure"})
```

---

### drawText

**Purpose**

Draws text with advanced formatting options including shadow effects, custom fonts, and alignment, providing enhanced text rendering capabilities.

**Parameters**

* `text` (*string*): The text to draw.
* `x` (*number*): The x position to draw the text.
* `y` (*number*): The y position to draw the text.
* `color` (*Color*, optional): The color of the text (default: white).
* `alignX` (*number*, optional): The horizontal alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT).
* `alignY` (*number*, optional): The vertical alignment (TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM).
* `font` (*string*, optional): The font to use for drawing (default: "LiliaFont.16").
* `alpha` (*number*, optional): The alpha transparency override for the text shadow.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic text drawing
lia.derma.drawText("Hello World", 100, 100, Color(255, 255, 255))

-- Text with custom color and alignment
lia.derma.drawText("Centered Text", ScrW() / 2, ScrH() / 2, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

-- Text with custom font
lia.derma.drawText("Custom Font Text", 100, 200, Color(100, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.24")

-- Right-aligned text
lia.derma.drawText("Right Aligned", ScrW() - 50, 50, Color(255, 255, 100), TEXT_ALIGN_RIGHT)

-- Text for HUD elements
local function drawPlayerHUD()
    local health = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()

    lia.derma.drawText("Health: " .. health .. "/" .. maxHealth, 100, ScrH() - 100,
                       health > 50 and Color(100, 255, 100) or Color(255, 100, 100),
                       TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, "LiliaFont.20")
end

hook.Add("HUDPaint", "DrawPlayerHUD", drawPlayerHUD)

-- Text with custom shadow alpha
lia.derma.drawText("Custom Shadow", 100, 300, Color(150, 150, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.20", 128)

-- Use in UI elements
local function drawTextButton(x, y, w, h, text)
    lia.derma.draw(8, x, y, w, h, Color(100, 150, 255))
    lia.derma.drawText(text, x + w/2, y + h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

drawTextButton(100, 100, 200, 50, "Click Me!")

-- Text for game titles
lia.derma.drawText("MY GAME TITLE", ScrW() / 2, 100, Color(255, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, "LiliaFont.24")

-- Text for status messages
lia.derma.drawText("Ready to Play", ScrW() / 2, ScrH() - 50, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "LiliaFont.20")

-- Text with different vertical alignments
lia.derma.drawText("Top Aligned", 200, 200, Color(255, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
lia.derma.drawText("Center Aligned", 200, 250, Color(150, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
lia.derma.drawText("Bottom Aligned", 200, 300, Color(150, 150, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

-- Text for inventory display
local function drawInventoryText()
    local itemCount = #LocalPlayer():getChar():getInv():getItems()

    lia.derma.drawText("Items: " .. itemCount, 50, 50, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.16")
end

hook.Add("HUDPaint", "DrawInventoryText", drawInventoryText)
```

---

### skinFunc

**Purpose**

Calls a skin function with automatic fallback to the default skin if the function is not available in the current skin, providing safe skin function calling.

**Parameters**

* `name` (*string*): The name of the skin function to call.
* `panel` (*Panel*): The panel to pass to the skin function.
* `a` (*any*, optional): First argument to pass to the skin function.
* `b` (*any*, optional): Second argument to pass to the skin function.
* `c` (*any*, optional): Third argument to pass to the skin function.
* `d` (*any*, optional): Fourth argument to pass to the skin function.
* `e` (*any*, optional): Fifth argument to pass to the skin function.
* `f` (*any*, optional): Sixth argument to pass to the skin function.
* `g` (*any*, optional): Seventh argument to pass to the skin function.

**Returns**

* `result` (*any*): The result of the skin function call, or nil if not found.

**Realm**

Client.

**Example Usage**

```lua
-- Basic skin function call
local skin = lia.derma.skinFunc("Paint", somePanel)

-- Safe skin function calling with fallback
local function safePaintFunction(panel, w, h)
    return lia.derma.skinFunc("Paint", panel, w, h)
end

-- Use in custom panel painting
local customPanel = vgui.Create("DPanel")
customPanel.Paint = function(self, w, h)
    -- Try to call the skin's Paint function, fallback to default if not available
    lia.derma.skinFunc("Paint", self, w, h)

    -- Add custom drawing
    draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 100))
end

-- Skin function for button painting
local customButton = vgui.Create("DButton")
customButton.Paint = function(self, w, h)
    -- Use skin function for base button painting
    lia.derma.skinFunc("Paint", self, w, h)

    -- Add custom hover effect
    if self:IsHovered() then
        draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 255, 50))
    end
end

-- Skin function for frame painting
local customFrame = vgui.Create("DFrame")
customFrame.Paint = function(self, w, h)
    -- Call skin's frame painting function
    lia.derma.skinFunc("Paint", self, w, h)

    -- Add custom title bar styling
    if self.lblTitle then
        self.lblTitle:SetColor(Color(255, 255, 0))
    end
end

-- Use in theme switching
local function switchToCustomSkin()
    -- This function would typically change the active skin
    -- The skinFunc ensures compatibility with different skins

    local testPanel = vgui.Create("DPanel")
    testPanel.Paint = function(self, w, h)
        lia.derma.skinFunc("Paint", self, w, h)
    end
end

-- Skin function for scrollbar painting
local customScrollbar = vgui.Create("DVScrollBar")
customScrollbar.Paint = function(self, w, h)
    lia.derma.skinFunc("Paint", self, w, h)
end

-- Safe skin function calling in hooks
hook.Add("OnSkinChanged", "UpdateSkinFunctions", function()
    -- Reinitialize panels that use skin functions
    -- The skinFunc will automatically use the new skin
    print("Skin changed, skinFunc will use new skin automatically")
end)
```

---

### requestArguments

**Purpose**

Creates a comprehensive form dialog for requesting multiple arguments from the user with different input types (string, boolean, table/dropdown), providing a flexible way to collect complex user input.

**Parameters**

* `title` (*string*): The title of the form dialog.
* `argTypes` (*table*): A table defining the argument types where keys are argument names and values can be:
  - A string specifying the type ("string", "boolean", "table", "int", "number")
  - A table with [type, options] for dropdown types where options is an array of choices
  - A table with [type, options, defaultValue] for types with default values
* `onSubmit` (*function*): The function to call when the form is submitted. Receives (success, results) where results is a table of argument values.
* `defaults` (*table*, optional): A table of default values for arguments.

**Returns**

* `frame` (*liaFrame*): The created form dialog frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic form with different input types
lia.derma.requestArguments("Player Settings", {
    name = "string",
    admin = "boolean",
    team = {"table", {"Red Team", "Blue Team", "Green Team"}},
    level = {"int", nil, 10}
}, function(success, results)
    if success then
        print("Player name:", results.name)
        print("Is admin:", results.admin)
        print("Team:", results.team)
        print("Level:", results.level)
    end
end)

-- Form with default values
lia.derma.requestArguments("Character Creation", {
    name = {"string", nil, "Default Name"},
    class = {"table", {"Warrior", "Mage", "Rogue", "Priest"}},
    strength = {"int", nil, 10},
    intelligence = {"int", nil, 8},
    dexterity = {"int", nil, 12}
}, function(success, results)
    if success then
        createCharacter(results)
    end
end, {
    strength = 15,
    intelligence = 10
})

-- Complex form for item creation
lia.derma.requestArguments("Create Item", {
    name = {"string", nil, "New Item"},
    type = {"table", {
        {"Weapon", "weapon"},
        {"Armor", "armor"},
        {"Consumable", "consumable"},
        {"Quest Item", "quest"}
    }},
    rarity = {"table", {"Common", "Uncommon", "Rare", "Epic", "Legendary"}},
    description = "string",
    value = "int",
    weight = "number"
}, function(success, results)
    if success then
        createGameItem(results)
    end
end)

-- Form for server configuration
lia.derma.requestArguments("Server Settings", {
    serverName = {"string", nil, "My Server"},
    maxPlayers = {"int", nil, 32},
    password = "string",
    pvp = "boolean",
    difficulty = {"table", {"Easy", "Normal", "Hard", "Expert"}},
    autoSave = "boolean"
}, function(success, results)
    if success then
        applyServerSettings(results)
    end
end)

-- Form with validation
lia.derma.requestArguments("User Registration", {
    username = {"string", nil, ""},
    email = "string",
    password = "string",
    confirmPassword = "string",
    age = {"int", nil, 18},
    agreeToTerms = "boolean"
}, function(success, results)
    if success then
        if results.password == results.confirmPassword then
            if results.age >= 13 then
                if results.agreeToTerms then
                    registerUser(results)
                else
                    print("Must agree to terms")
                end
            else
                print("Must be at least 13 years old")
            end
        else
            print("Passwords do not match")
        end
    end
end)

-- Dynamic form based on conditions
local function createDynamicForm()
    local argTypes = {
        title = "string"
    }

    if needsDescription then
        argTypes.description = "string"
    end

    if hasOptions then
        argTypes.category = {"table", {"Category A", "Category B", "Category C"}}
    end

    lia.derma.requestArguments("Dynamic Form", argTypes, function(success, results)
        if success then
            processFormData(results)
        end
    end)
end
```

---

### player_selector

**Purpose**

Creates a comprehensive player selection dialog with search and filtering capabilities, displaying all players with their avatars, names, user groups, and ping information.

**Parameters**

* `callback` (*function*): The function to call when a player is selected. Receives the selected Player object as parameter.
* `validationFunc` (*function*, optional): A function to validate player selection. Should return true if the player can be selected.

**Returns**

* `frame` (*liaFrame*): The player selector frame dialog.

**Realm**

Client.

**Example Usage**

```lua
-- Basic player selector
lia.derma.player_selector(function(player)
    print("Selected player:", player:Name(), player:SteamID())
end)

-- Player selector with validation (only alive players)
lia.derma.player_selector(function(player)
    if IsValid(player) and player:Alive() then
        tradeWithPlayer(player)
    end
end, function(player)
    return player ~= LocalPlayer() and player:Alive()
end)

-- Use in admin functions
lia.derma.player_selector(function(player)
    local menu = lia.derma.derma_menu()
    menu:AddOption("Kick Player", function() kickPlayer(player) end)
    menu:AddOption("Ban Player", function() banPlayer(player) end)
    menu:AddOption("Teleport to Player", function() teleportToPlayer(player) end)
end)

-- Player selector for team assignment
lia.derma.player_selector(function(player)
    local teams = team.GetAllTeams()
    local menu = lia.derma.derma_menu()

    for _, teamInfo in pairs(teams) do
        menu:AddOption("Move to " .. teamInfo.Name, function()
            player:SetTeam(teamInfo.ID)
            print("Moved " .. player:Name() .. " to " .. teamInfo.Name)
        end)
    end
end, function(player)
    return player ~= LocalPlayer()
end)

-- Multiple player selection for group actions
local selectedPlayers = {}
lia.derma.player_selector(function(player)
    if table.HasValue(selectedPlayers, player) then
        table.RemoveByValue(selectedPlayers, player)
        print("Deselected:", player:Name())
    else
        table.insert(selectedPlayers, player)
        print("Selected:", player:Name())
    end
    print("Total selected players:", #selectedPlayers)
end)

-- Player selector with custom validation for specific roles
lia.derma.player_selector(function(player)
    if player:GetUserGroup() == "admin" then
        promotePlayer(player)
    else
        print("Only admins can be promoted")
    end
end, function(player)
    return player:GetUserGroup() == "moderator"
end)

-- Player selector for messaging
lia.derma.player_selector(function(player)
    lia.derma.textBox("Send Message", "Enter your message to " .. player:Name(), function(text)
        net.Start("SendPrivateMessage")
        net.WriteEntity(player)
        net.WriteString(text)
        net.SendToServer()
    end)
end)
```

---

### radial_menu

**Purpose**

Creates a radial/circular menu for quick action selection, displaying options in a circular layout that users can select by clicking on sectors.

**Parameters**

* `options` (*table*): A table of options with the following properties:
  - `title` (*string*, optional): The title displayed in the center of the menu.
  - `desc` (*string*, optional): The description displayed below the title.
  - `radius` (*number*, optional): The radius of the radial menu (default: 280).
  - `inner_radius` (*number*, optional): The inner radius for the center area (default: 96).
  - `disable_background` (*boolean*, optional): Whether to disable the background overlay.
  - `hover_sound` (*string*, optional): Sound to play on option hover.
  - `scale_animation` (*boolean*, optional): Whether to enable scale animation (default: true).
  - Additional options can be added using the returned panel's methods.

**Returns**

* `menu` (*liaRadialPanel*): The created radial menu panel.

**Realm**

Client.

**Example Usage**

```lua
-- Basic radial menu
local options = {
    title = "Actions",
    desc = "Select an option"
}

local menu = lia.derma.radial_menu(options)

-- Add options to the menu
menu:AddOption("Attack", function() print("Attack selected") end, "icon16/gun.png", "Launch an attack")
menu:AddOption("Defend", function() print("Defend selected") end, "icon16/shield.png", "Defend position")
menu:AddOption("Heal", function() print("Heal selected") end, "icon16/heart.png", "Use healing item")
menu:AddOption("Retreat", function() print("Retreat selected") end, "icon16/arrow_left.png", "Retreat from combat")

-- Radial menu with submenus
local mainMenu = lia.derma.radial_menu({
    title = "Main Menu",
    desc = "Choose a category"
})

local combatSubmenu = mainMenu:CreateSubMenu("Combat", "Combat actions")
combatSubmenu:AddOption("Melee Attack", function() print("Melee attack") end, "icon16/sword.png")
combatSubmenu:AddOption("Ranged Attack", function() print("Ranged attack") end, "icon16/gun.png")
combatSubmenu:AddOption("Magic", function() print("Magic attack") end, "icon16/lightning.png")

local utilitySubmenu = mainMenu:CreateSubMenu("Utilities", "Utility actions")
utilitySubmenu:AddOption("Heal", function() print("Heal") end, "icon16/heart.png")
utilitySubmenu:AddOption("Buff", function() print("Buff") end, "icon16/star.png")

mainMenu:AddOption("Combat", nil, "icon16/bomb.png", "Combat submenu", combatSubmenu)
mainMenu:AddOption("Utilities", nil, "icon16/wrench.png", "Utility submenu", utilitySubmenu)

-- Radial menu for spell casting
local spellMenu = lia.derma.radial_menu({
    title = "Spells",
    desc = "Choose a spell to cast",
    radius = 320
})

local spells = {
    {name = "Fireball", icon = "icon16/fire.png", desc = "Deals fire damage"},
    {name = "Ice Bolt", icon = "icon16/weather_snow.png", desc = "Freezes enemies"},
    {name = "Lightning", icon = "icon16/lightning.png", desc = "Chain lightning"},
    {name = "Heal", icon = "icon16/heart.png", desc = "Restores health"},
    {name = "Shield", icon = "icon16/shield.png", desc = "Creates barrier"},
    {name = "Teleport", icon = "icon16/arrow_right.png", desc = "Instant movement"}
}

for _, spell in ipairs(spells) do
    spellMenu:AddOption(spell.name, function() print("Cast " .. spell.name) end, spell.icon, spell.desc)
end

-- Radial menu for emotes
local emoteMenu = lia.derma.radial_menu({
    title = "Emotes",
    desc = "Choose an emote",
    radius = 250
})

local emotes = {
    {name = "Wave", icon = "icon16/user.png"},
    {name = "Dance", icon = "icon16/user_go.png"},
    {name = "Cry", icon = "icon16/user_delete.png"},
    {name = "Laugh", icon = "icon16/user_comment.png"},
    {name = "Bow", icon = "icon16/user_suit.png"},
    {name = "Point", icon = "icon16/user_gray.png"}
}

for _, emote in ipairs(emotes) do
    emoteMenu:AddOption(emote.name, function() RunConsoleCommand("say", "/" .. string.lower(emote.name)) end, emote.icon, emote.name .. " emote")
end

-- Dynamic radial menu creation
local function createRadialMenuForItems(items)
    local menu = lia.derma.radial_menu({
        title = "Items",
        desc = "Select an item to use"
    })

    for _, item in ipairs(items) do
        menu:AddOption(item.name, function() useItem(item) end, item.icon, ITEM.desc)
    end

    return menu
end

-- Custom radial menu with different settings
local customMenu = lia.derma.radial_menu({
    title = "Custom Menu",
    desc = "Custom radial menu",
    radius = 300,
    inner_radius = 120,
    disable_background = false,
    hover_sound = "ui/buttonrollover.wav",
    scale_animation = true
})

customMenu:AddOption("Option 1", function() print("Option 1") end, "icon16/accept.png")
customMenu:AddOption("Option 2", function() print("Option 2") end, "icon16/cancel.png")
customMenu:AddOption("Option 3", function() print("Option 3") end, "icon16/help.png")
```

---

### rect

**Purpose**

Creates a rectangle drawing object that can be customized with colors, textures, materials, corner radii, and effects before being rendered.

**Parameters**

* `x` (*number*): The x position of the rectangle.
* `y` (*number*): The y position of the rectangle.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.

**Returns**

* `rect` (*liaRect*): The rectangle drawing object with chainable methods for customization.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic rectangle
lia.derma.rect(100, 100, 200, 100):Color(Color(100, 150, 255)):Draw()

-- Create a rectangle with rounded corners
lia.derma.rect(50, 200, 150, 80)
    :Color(Color(255, 100, 100))
    :Rad(10)
    :Draw()

-- Create a rectangle with texture
lia.derma.rect(250, 50, 120, 120)
    :Texture("vgui/white")
    :Color(Color(150, 150, 255))
    :Draw()

-- Create a rectangle with material
local gradientMat = Material("gui/gradient")
lia.derma.rect(400, 100, 100, 100)
    :Material(gradientMat)
    :Color(Color(255, 200, 100))
    :Draw()

-- Create a rectangle with blur effect
lia.derma.rect(100, 300, 150, 60)
    :Color(Color(100, 255, 100))
    :Blur(2.0)
    :Draw()

-- Create a shadowed rectangle
lia.derma.rect(300, 250, 120, 80)
    :Color(Color(255, 150, 100))
    :Shadow(20, 15)
    :Draw()

-- Create a rectangle with outline
lia.derma.rect(450, 200, 100, 100)
    :Color(Color(150, 100, 255))
    :Outline(3)
    :Draw()

-- Create rectangles with different corner radii
lia.derma.rect(50, 400, 100, 60):Radii(5, 10, 15, 20):Color(Color(255, 100, 255)):Draw()
lia.derma.rect(200, 400, 100, 60):Radii(20, 5, 10, 15):Color(Color(100, 255, 255)):Draw()
lia.derma.rect(350, 400, 100, 60):Radii(10, 20, 5, 15):Color(Color(255, 255, 100)):Draw()

-- Interactive rectangle that changes color on hover
local hoverX, hoverY, hoverW, hoverH = 500, 350, 80, 50
local distance = math.Distance(input.GetCursorPos(), hoverX + hoverW/2, hoverY + hoverH/2)
local isHovering = distance < 50
local hoverColor = isHovering and Color(255, 255, 100) or Color(150, 150, 255)
lia.derma.rect(hoverX, hoverY, hoverW, hoverH)
    :Color(hoverColor)
    :Rad(8)
    :Draw()

-- Create a progress bar with rectangle
lia.derma.rect(50, 500, 300, 20):Color(Color(50, 50, 50)):Rad(4):Draw()
local progress = 0.7 -- 70%
lia.derma.rect(50, 500, 300 * progress, 20):Color(Color(100, 200, 100)):Rad(4):Draw()
```

**Available Chainable Methods**

* `:Color(color)` - Sets the rectangle color
* `:Texture(texture)` - Sets a texture for the rectangle
* `:Material(material)` - Sets a material for the rectangle
* `:Rad(radius)` - Sets the same radius for all corners
* `:Radii(tl, tr, bl, br)` - Sets individual corner radii
* `:Outline(thickness)` - Adds an outline with specified thickness
* `:Blur(intensity)` - Applies blur effect
* `:Shadow(spread, intensity)` - Adds shadow effect
* `:Rotation(angle)` - Rotates the rectangle
* `:Shape(shape)` - Sets the shape type (circle, figma, ios)
* `:Clip(panel)` - Clips drawing to specified panel
* `:Flags(flags)` - Applies drawing flags
* `:Draw()` - Renders the rectangle

---

### setDefaultShape

**Purpose**

Sets the default shape type for all subsequent drawing operations, affecting the appearance of corners in drawn elements.

**Parameters**

* `shape` (*number*): The shape type to set as default. Available options:
  - `lia.derma.SHAPE_CIRCLE` - Perfect circles
  - `lia.derma.SHAPE_FIGMA` - Figma-style rounded corners (default)
  - `lia.derma.SHAPE_IOS` - iOS-style rounded corners

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Set default shape to circle
lia.derma.setDefaultShape(lia.derma.SHAPE_CIRCLE)

-- All subsequent drawing operations will use circle shape
lia.derma.draw(10, 100, 100, 100, 100, Color(255, 100, 100))
lia.derma.rect(200, 100, 100, 100):Color(Color(100, 255, 100)):Draw()

-- Set default shape to iOS style
lia.derma.setDefaultShape(lia.derma.SHAPE_IOS)

-- All subsequent drawing operations will use iOS-style corners
lia.derma.draw(15, 100, 200, 80, 80, Color(100, 100, 255))
lia.derma.rect(300, 200, 120, 60):Color(Color(255, 150, 100)):Draw()

-- Reset to default Figma style
lia.derma.setDefaultShape(lia.derma.SHAPE_FIGMA)

-- All subsequent drawing operations will use Figma-style corners
lia.derma.draw(12, 50, 300, 150, 80, Color(150, 255, 150))

-- Use in theme or style management
local function applyRoundedTheme()
    lia.derma.setDefaultShape(lia.derma.SHAPE_FIGMA)
    print("Applied rounded theme")
end

local function applySharpTheme()
    lia.derma.setDefaultShape(lia.derma.SHAPE_IOS)
    print("Applied sharp theme")
end

local function applyCircularTheme()
    lia.derma.setDefaultShape(lia.derma.SHAPE_CIRCLE)
    print("Applied circular theme")
end

-- Apply theme based on user preference
local userTheme = "rounded" -- Could come from config or user setting
if userTheme == "rounded" then
    applyRoundedTheme()
elseif userTheme == "sharp" then
    applySharpTheme()
elseif userTheme == "circular" then
    applyCircularTheme()
end
```

---

### setFlag

**Purpose**

Utility function for setting or unsetting specific flags in a flags value, commonly used for modifying drawing behavior in derma operations.

**Parameters**

* `flags` (*number*): The current flags value to modify.
* `flag` (*number* or *string*): The flag to set or unset. Can be a flag constant or a string key from lia.derma.
* `bool` (*boolean*): Whether to set (true) or unset (false) the flag.

**Returns**

* `newFlags` (*number*): The modified flags value.

**Realm**

Client.

**Example Usage**

```lua
-- Set a specific flag
local flags = 0
flags = lia.derma.setFlag(flags, lia.derma.BLUR, true)
flags = lia.derma.setFlag(flags, lia.derma.SHAPE_CIRCLE, true)

-- Use the flags in drawing
lia.derma.draw(10, 100, 100, 200, 100, Color(255, 100, 100), flags)

-- Unset a flag
flags = lia.derma.setFlag(flags, lia.derma.BLUR, false)

-- Set multiple flags at once
local function createFlags(...)
    local flags = 0
    for _, flag in ipairs({...}) do
        flags = lia.derma.setFlag(flags, flag, true)
    end
    return flags
end

local myFlags = createFlags(lia.derma.SHAPE_IOS, lia.derma.BLUR)
lia.derma.draw(12, 200, 100, 150, 80, Color(100, 200, 255), myFlags)

-- Toggle flags
local currentFlags = 0
local function toggleBlur()
    currentFlags = lia.derma.setFlag(currentFlags, lia.derma.BLUR, not lia.derma.setFlag(currentFlags, lia.derma.BLUR, false) == currentFlags)
end

-- Use string keys for flags
flags = lia.derma.setFlag(flags, "BLUR", true)
flags = lia.derma.setFlag(flags, "SHAPE_CIRCLE", true)

-- Combine with drawing operations
local function drawElement(x, y, w, h, color, useBlur, useCircle)
    local flags = 0
    flags = lia.derma.setFlag(flags, lia.derma.BLUR, useBlur)
    flags = lia.derma.setFlag(flags, lia.derma.SHAPE_CIRCLE, useCircle)

    lia.derma.draw(10, x, y, w, h, color, flags)
end

drawElement(50, 50, 100, 100, Color(255, 100, 100), true, false)
drawElement(200, 50, 100, 100, Color(100, 255, 100), false, true)
drawElement(350, 50, 100, 100, Color(100, 100, 255), true, true)

-- Advanced flag management
local flagPresets = {
    normal = 0,
    blurred = lia.derma.BLUR,
    outlined = lia.derma.setFlag(0, lia.derma.BLUR, false), -- This doesn't make sense, need to fix
    shadowed = lia.derma.BLUR, -- Placeholder
    glowing = lia.derma.BLUR
}

local function applyPreset(presetName)
    return flagPresets[presetName] or 0
end

local elementFlags = applyPreset("blurred")
lia.derma.draw(8, 100, 150, 120, 80, Color(255, 200, 100), elementFlags)
```

---

### characterAttribRow

**Purpose**

Creates a row component for displaying character attributes in a structured format.

**Parameters**

* `parent` (*Panel*): The parent panel to add the row to.
* `attributeKey` (*string*, optional): The attribute key/name.
* `attributeData` (*table*, optional): The attribute data containing display information.

**Returns**

* `row` (*liaCharacterAttribsRow*): The created attribute row panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic attribute row
local strengthRow = lia.derma.characterAttribRow(parentPanel, "strength", {
    name = "Strength",
    desc = "Physical power and carrying capacity",
    max = 20,
    value = 15
})

-- Create multiple attribute rows
local attributes = {
    strength = {name = "Strength", desc = "Physical power", max = 20, value = 16},
    dexterity = {name = "Dexterity", desc = "Agility and precision", max = 20, value = 14},
    intelligence = {name = "Intelligence", desc = "Mental capacity", max = 20, value = 18}
}

for key, data in pairs(attributes) do
    local row = lia.derma.characterAttribRow(parentPanel, key, data)
end

-- Use with character attribute system
local function createCharacterSheet(character)
    local attribsPanel = lia.derma.characterAttribs(parentPanel)

    for attributeKey, attributeData in pairs(lia.attributes.list) do
        local currentValue = character:getAttrib(attributeKey, 0)
        local row = lia.derma.characterAttribRow(attribsPanel, attributeKey, attributeData)
        row:setValue(currentValue)
    end
end

-- Dynamic attribute row updates
local function updateAttributeDisplay(row, newValue, maxValue)
    row:setValue(newValue)
    row:setMax(maxValue)
    row:setText(string.format("%s: %d/%d", row.attributeData.name, newValue, maxValue))
end
```

---

### characterAttribs

**Purpose**

Creates a container panel for displaying multiple character attribute rows.

**Parameters**

* `parent` (*Panel*): The parent panel to add the container to.

**Returns**

* `attribsPanel` (*liaCharacterAttribs*): The created attributes container panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a character attributes panel
local attribsPanel = lia.derma.characterAttribs(parentPanel)
attribsPanel:Dock(FILL)

-- Populate with character data
local character = LocalPlayer():getChar()
if character then
    for attributeKey, attributeData in pairs(lia.attributes.list) do
        local currentValue = character:getAttrib(attributeKey, 0)
        local row = lia.derma.characterAttribRow(attribsPanel, attributeKey, attributeData)
        row:setValue(currentValue)
    end
end

-- Create a reusable character sheet
local function createCharacterSheet(parent)
    local sheet = vgui.Create("DPanel", parent)
    sheet:Dock(FILL)

    local title = vgui.Create("DLabel", sheet)
    title:Dock(TOP)
    title:SetText("Character Attributes")
    title:SetFont("LiliaFont.20")

    local attribsContainer = lia.derma.characterAttribs(sheet)

    -- Add attribute rows dynamically
    local character = LocalPlayer():getChar()
    if character then
        for key, data in pairs(lia.attributes.list) do
            local value = character:getAttrib(key, 0)
            local row = lia.derma.characterAttribRow(attribsContainer, key, data)
            row:setValue(value)
        end
    end

    return sheet
end

-- Use in character creation
local creationPanel = lia.derma.frame(nil, "Character Creation", 400, 600)
local attribsSection = lia.derma.characterAttribs(creationPanel)
-- Populate with default values for character creation...
```

---

### checkbox

**Purpose**

Creates a themed checkbox with label for boolean input.

**Parameters**

* `parent` (*Panel*): The parent panel to add the checkbox to.
* `text` (*string*): The label text for the checkbox.
* `convar` (*string*, optional): The console variable to bind the checkbox to.

**Returns**

* `panel` (*Panel*): The container panel.
* `checkbox` (*liaCheckBox*): The actual checkbox element.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic checkbox
local panel, checkbox = lia.derma.checkbox(parentPanel, "Enable Feature")
checkbox:SetChecked(true)

-- Create a checkbox bound to a convar
local _, soundCheckbox = lia.derma.checkbox(parentPanel, "Enable Sound", "lia_enable_sound")

-- Multiple related checkboxes
local options = {
    {"Show Health Bar", "lia_show_health"},
    {"Show Mana Bar", "lia_show_mana"},
    {"Show Minimap", "lia_show_minimap"},
    {"Enable Tooltips", "lia_enable_tooltips"}
}

for _, option in ipairs(options) do
    local _, checkbox = lia.derma.checkbox(parentPanel, option[1], option[2])
end

-- Group checkboxes in a category
local settingsCategory = lia.derma.category(parentPanel, "Display Settings", true)

local showFPS = lia.derma.checkbox(settingsCategory, "Show FPS Counter", "lia_show_fps")
local showPing = lia.derma.checkbox(settingsCategory, "Show Ping", "lia_show_ping")
local showCoords = lia.derma.checkbox(settingsCategory, "Show Coordinates", "lia_show_coords")

-- Use checkbox value in logic
local enableMusic = lia.derma.checkbox(parentPanel, "Enable Background Music")
enableMusic[2].OnChange = function(self, value)
    if value then
        startBackgroundMusic()
    else
        stopBackgroundMusic()
    end
end

-- Create checkbox with custom behavior
local _, debugCheckbox = lia.derma.checkbox(parentPanel, "Debug Mode", "lia_debug_mode")
debugCheckbox.OnChange = function(self, value)
    if value then
        print("Debug mode enabled")
        showDebugInfo()
    else
        print("Debug mode disabled")
        hideDebugInfo()
    end
end
```

---

### colorPicker

**Purpose**

Creates a color picker dialog for selecting colors with hue, saturation, and value controls.

**Parameters**

* `callback` (*function*): The function to call when a color is selected.
* `defaultColor` (*Color*, optional): The initial color to display.

**Returns**

* `frame` (*liaFrame*): The color picker frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic color picker
lia.derma.colorPicker(function(color)
    print("Selected color:", color)
    selectedColor = color
end)

-- Color picker with default color
local defaultColor = Color(255, 100, 100)
lia.derma.colorPicker(function(color)
    myPanel:SetBackgroundColor(color)
end, defaultColor)

-- Use in theme customization
lia.derma.colorPicker(function(color)
    local customTheme = table.Copy(lia.color.getTheme())
    customTheme.accent = color
    lia.color.registerTheme("custom", customTheme)
    lia.color.setTheme("custom")
end)

-- Color picker for item customization
local function createItemColorPicker(item, callback)
    lia.derma.colorPicker(function(color)
        item.customColor = color
        callback(color)
    end, item.customColor)
end

-- Multiple color pickers for different elements
local colorButtons = {}
local function createColorPalette()
    local colors = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"}

    for _, colorName in ipairs(colors) do
        local button = lia.derma.button(parentPanel, nil, nil, Color(100, 100, 100))
        button:SetText(colorName)
        button.DoClick = function()
            lia.derma.colorPicker(function(color)
                button:SetColor(color)
                print("Changed " .. colorName .. " to:", color)
            end)
        end
        table.insert(colorButtons, button)
    end
end
```

---

### dermaMenu

**Purpose**

Creates a context menu at the current mouse position with automatic positioning.

**Parameters**

*None*

**Returns**

* `menu` (*liaDermaMenu*): The created context menu.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic context menu
local menu = lia.derma.dermaMenu()
menu:AddOption("Option 1", function() print("Selected option 1") end)
menu:AddOption("Option 2", function() print("Selected option 2") end)
menu:AddOption("Option 3", function() print("Selected option 3") end)

-- Context menu with submenus
local menu = lia.derma.dermaMenu()
local submenu = menu:AddSubMenu("More Options")

submenu:AddOption("Sub Option 1", function() print("Sub option 1") end)
submenu:AddOption("Sub Option 2", function() print("Sub option 2") end)

menu:AddOption("Regular Option", function() print("Regular option") end)

-- Context menu for player interactions
local menu = lia.derma.dermaMenu()
local targetPlayer = LocalPlayer()

menu:AddOption("Send Message", function()
    lia.derma.textBox("Send Message", "Enter your message", function(text)
        targetPlayer:ChatPrint(text)
    end)
end)

menu:AddOption("Trade Items", function()
    openTradeWindow(targetPlayer)
end)

menu:AddOption("View Profile", function()
    showPlayerProfile(targetPlayer)
end)

-- Dynamic context menu based on object
local function createContextMenuForObject(object)
    local menu = lia.derma.dermaMenu()

    if object.isContainer then
        menu:AddOption("Open", function() object:Open() end)
        menu:AddOption("Lock", function() object:Lock() end)
    end

    if object.isNPC then
        menu:AddOption("Talk", function() object:Talk() end)
        menu:AddOption("Trade", function() object:Trade() end)
    end

    return menu
end

-- Context menu with icons
local menu = lia.derma.dermaMenu()
menu:AddOption("Copy", function() clipboard.Copy() end):SetIcon("icon16/page_copy.png")
menu:AddOption("Paste", function() clipboard.Paste() end):SetIcon("icon16/paste.png")
menu:AddOption("Cut", function() clipboard.Cut() end):SetIcon("icon16/cut.png")
```

---

### descEntry

**Purpose**

Creates a labeled text entry field with placeholder text and optional title.

**Parameters**

* `parent` (*Panel*): The parent panel to add the entry to.
* `title` (*string*, optional): The title label for the entry field.
* `placeholder` (*string*): The placeholder text to display when empty.
* `offTitle` (*boolean*, optional): Whether to disable the title label.

**Returns**

* `entry` (*liaEntry*): The text entry field.
* `entry_bg` (*liaBasePanel*): The background panel (only if title is provided).

**Realm**

Client.

**Example Usage**

```lua
-- Basic text entry with title
local entry = lia.derma.descEntry(parentPanel, "Username", "Enter your username")

-- Text entry without title
local passwordEntry = lia.derma.descEntry(parentPanel, nil, "Enter password", true)

-- Multiple form fields
local formFields = {}
local fields = {
    {"Name", "Enter your full name"},
    {"Email", "Enter your email address"},
    {"Age", "Enter your age"},
    {"Bio", "Tell us about yourself"}
}

for _, field in ipairs(fields) do
    local entry = lia.derma.descEntry(parentPanel, field[1], field[2])
    table.insert(formFields, entry)
end

-- Validate form input
local function validateForm()
    local isValid = true
    for i, entry in ipairs(formFields) do
        local value = entry:GetValue()
        if value == "" then
            entry:SetError("This field is required")
            isValid = false
        else
            entry:ClearError()
        end
    end
    return isValid
end

-- Use in settings panel
local settingsCategory = lia.derma.category(parentPanel, "Account Settings", true)

local usernameEntry = lia.derma.descEntry(settingsCategory, "Username", "Current username")
local emailEntry = lia.derma.descEntry(settingsCategory, "Email", "your@email.com")
local passwordEntry = lia.derma.descEntry(settingsCategory, "New Password", "Enter new password")

-- Auto-save functionality
local function setupAutoSave(entry, convar)
    entry.OnChange = function()
        LocalPlayer():ConCommand(convar .. " " .. entry:GetValue())
    end
end

setupAutoSave(usernameEntry, "lia_username")
setupAutoSave(emailEntry, "lia_email")
```

---

### frame

**Purpose**

Creates a themed frame window with optional close button and animation support.

**Parameters**

* `parent` (*Panel*): The parent panel to add the frame to.
* `title` (*string*, optional): The title text for the frame.
* `width` (*number*, optional): The width of the frame (default: 300).
* `height` (*number*, optional): The height of the frame (default: 200).
* `closeButton` (*boolean*, optional): Whether to show the close button.
* `animate` (*boolean*, optional): Whether to show entrance animation.

**Returns**

* `frame` (*liaFrame*): The created frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic frame
local frame = lia.derma.frame(nil, "My Window", 400, 300)

-- Frame with close button
local frameWithClose = lia.derma.frame(parentPanel, "Settings", 500, 400, true)

-- Frame without close button (modal)
local modalFrame = lia.derma.frame(nil, "Important Notice", 300, 150, false)

-- Animated frame
local animatedFrame = lia.derma.frame(nil, "Loading...", 200, 100, true, true)

-- Custom frame content
local infoFrame = lia.derma.frame(nil, "Player Information", 350, 250, true)
local content = vgui.Create("DPanel", infoFrame)
content:Dock(FILL)
content:DockMargin(10, 10, 10, 10)

local nameLabel = vgui.Create("DLabel", content)
nameLabel:Dock(TOP)
nameLabel:SetText("Player: " .. LocalPlayer():Name())

local steamLabel = vgui.Create("DLabel", content)
steamLabel:Dock(TOP)
steamLabel:DockMargin(0, 5, 0, 0)
steamLabel:SetText("Steam ID: " .. LocalPlayer():SteamID())

-- Frame with custom close behavior
local confirmFrame = lia.derma.frame(nil, "Confirm Action", 300, 120, true)
confirmFrame.OnClose = function()
    print("User cancelled the action")
end

-- Multiple frames management
local frames = {}
local function createTabFrame(title, content)
    local frame = lia.derma.frame(nil, title, 400, 300, true, true)
    local panel = vgui.Create("DPanel", frame)
    panel:Dock(FILL)
    if content then content(panel) end
    table.insert(frames, frame)
    return frame
end
```

---

### panelTabs

**Purpose**

Creates a tabbed panel interface for organizing content into multiple sections.

**Parameters**

* `parent` (*Panel*): The parent panel to add the tabs to.

**Returns**

* `tabs` (*liaTabs*): The created tabbed panel.

**Realm**

Client.

**Example Usage**

```lua
-- Basic tabbed panel
local tabs = lia.derma.panelTabs(parentPanel)

local tab1 = tabs:AddTab("General", createGeneralPanel())
local tab2 = tabs:AddTab("Advanced", createAdvancedPanel())
local tab3 = tabs:AddTab("About", createAboutPanel())

-- Programmatically switch tabs
tabs:ActiveTab("Advanced")

-- Tabs with icons
local tabs = lia.derma.panelTabs(parentPanel)
tabs:AddTab("Home", homePanel, "icon16/house.png")
tabs:AddTab("Settings", settingsPanel, "icon16/cog.png")
tabs:AddTab("Help", helpPanel, "icon16/help.png")

-- Dynamic tab creation
local function createTabbedInterface(data)
    local tabs = lia.derma.panelTabs(parentPanel)

    for title, contentFunc in pairs(data) do
        local panel = contentFunc()
        tabs:AddTab(title, panel)
    end

    return tabs
end

-- Settings tabs
local settingsTabs = lia.derma.panelTabs(settingsPanel)
settingsTabs:AddTab("Graphics", createGraphicsSettings())
settingsTabs:AddTab("Audio", createAudioSettings())
settingsTabs:AddTab("Controls", createControlSettings())
settingsTabs:AddTab("Network", createNetworkSettings())

-- Tab change callback
local tabs = lia.derma.panelTabs(parentPanel)
tabs.OnTabChanged = function(oldTab, newTab)
    print("Switched from", oldTab, "to", newTab)
end
```

---

### playerSelector

**Purpose**

Creates a player selection dialog with search and filtering capabilities.

**Parameters**

* `callback` (*function*): The function to call when a player is selected.
* `validationFunc` (*function*, optional): A function to validate player selection.

**Returns**

* `frame` (*liaFrame*): The player selector frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic player selector
lia.derma.playerSelector(function(player)
    print("Selected player:", player:Name())
end)

-- Player selector with validation
lia.derma.playerSelector(function(player)
    if IsValid(player) and player:Alive() then
        tradeWithPlayer(player)
    end
end, function(player)
    return player ~= LocalPlayer() and player:Alive()
end)

-- Use in admin functions
lia.derma.playerSelector(function(player)
    local menu = lia.derma.dermaMenu()
    menu:AddOption("Kick", function() kickPlayer(player) end)
    menu:AddOption("Ban", function() banPlayer(player) end)
    menu:AddOption("Teleport", function() teleportToPlayer(player) end)
end)

-- Player selector for team assignment
lia.derma.playerSelector(function(player)
    local teams = team.GetAllTeams()
    local menu = lia.derma.dermaMenu()

    for _, teamInfo in pairs(teams) do
        menu:AddOption("Move to " .. teamInfo.Name, function()
            player:SetTeam(teamInfo.ID)
        end)
    end
end, function(player)
    return player ~= LocalPlayer()
end)

-- Multiple player selection
local selectedPlayers = {}
lia.derma.playerSelector(function(player)
    if table.HasValue(selectedPlayers, player) then
        table.RemoveByValue(selectedPlayers, player)
        print("Deselected:", player:Name())
    else
        table.insert(selectedPlayers, player)
        print("Selected:", player:Name())
    end
    print("Selected players:", #selectedPlayers)
end)
```

---

### radialMenu

**Purpose**

Creates a radial/circular menu for quick action selection.

**Parameters**

* `options` (*table*): A table of options with name, icon, and callback properties.

**Returns**

* `menu` (*liaRadialPanel*): The created radial menu.

**Realm**

Client.

**Example Usage**

```lua
-- Basic radial menu
local options = {
    {name = "Attack", icon = "icon16/gun.png", callback = function() attack() end},
    {name = "Defend", icon = "icon16/shield.png", callback = function() defend() end},
    {name = "Heal", icon = "icon16/heart.png", callback = function() heal() end},
    {name = "Retreat", icon = "icon16/arrow_left.png", callback = function() retreat() end}
}

local menu = lia.derma.radialMenu(options)

-- Radial menu with more options
local spellOptions = {
    {name = "Fireball", icon = "icon16/fire.png", callback = function() castFireball() end},
    {name = "Ice Bolt", icon = "icon16/weather_snow.png", callback = function() castIceBolt() end},
    {name = "Lightning", icon = "icon16/lightning.png", callback = function() castLightning() end},
    {name = "Heal", icon = "icon16/heart.png", callback = function() castHeal() end},
    {name = "Shield", icon = "icon16/shield.png", callback = function() castShield() end},
    {name = "Teleport", icon = "icon16/arrow_right.png", callback = function() castTeleport() end}
}

local spellMenu = lia.derma.radialMenu(spellOptions)

-- Dynamic radial menu creation
local function createRadialMenuForItems(items)
    local options = {}

    for _, item in ipairs(items) do
        table.insert(options, {
            name = item.name,
            icon = item.icon,
            callback = function() useItem(item) end
        })
    end

    return lia.derma.radialMenu(options)
end

-- Radial menu for emotes
local emoteOptions = {
    {name = "Wave", icon = "icon16/user.png", callback = function() doEmote("wave") end},
    {name = "Dance", icon = "icon16/user_go.png", callback = function() doEmote("dance") end},
    {name = "Cry", icon = "icon16/user_delete.png", callback = function() doEmote("cry") end},
    {name = "Laugh", icon = "icon16/user_comment.png", callback = function() doEmote("laugh") end}
}

local emoteMenu = lia.derma.radialMenu(emoteOptions)
```

---

### scrollPanel

**Purpose**

Creates a scrollable panel with themed scrollbars.

**Parameters**

* `scrollPanel` (*Panel*): The scroll panel to apply theming to.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Theme an existing scroll panel
local scrollPanel = vgui.Create("DScrollPanel", parent)
lia.derma.scrollPanel(scrollPanel)

-- Create a new themed scroll panel
local scrollPanel = lia.derma.scrollpanel(parentPanel)

-- Use in content creation
local function createScrollableContent()
    local scroll = lia.derma.scrollpanel(parentPanel)
    scroll:Dock(FILL)

    -- Add many items to demonstrate scrolling
    for i = 1, 50 do
        local item = vgui.Create("DButton", scroll)
        item:Dock(TOP)
        item:SetTall(30)
        item:SetText("Item " .. i)
    end

    return scroll
end

-- Scroll panel with custom content
local contentScroll = lia.derma.scrollpanel(parentPanel)
contentScroll:Dock(FILL)

for i = 1, 20 do
    local panel = vgui.Create("DPanel", contentScroll)
    panel:Dock(TOP)
    panel:DockMargin(5, 5, 5, 0)
    panel:SetTall(60)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 150))
    end

    local label = vgui.Create("DLabel", panel)
    label:Dock(FILL)
    label:DockMargin(10, 0, 10, 0)
    label:SetText("Scrollable content item " .. i)
end

-- Nested scroll panels
local outerScroll = lia.derma.scrollpanel(parentPanel)
outerScroll:Dock(FILL)

local innerScroll = lia.derma.scrollpanel(outerScroll)
innerScroll:Dock(TOP)
innerScroll:SetTall(200)
```

---

### scrollpanel

**Purpose**

Creates a new themed scroll panel with automatic scrollbar theming.

**Parameters**

* `parent` (*Panel*): The parent panel to add the scroll panel to.

**Returns**

* `scrollpanel` (*liaScrollPanel*): The created themed scroll panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a themed scroll panel
local scrollPanel = lia.derma.scrollpanel(parentPanel)
scrollPanel:Dock(FILL)

-- Add content to the scroll panel
for i = 1, 100 do
    local button = vgui.Create("DButton", scrollPanel)
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 5)
    button:SetTall(40)
    button:SetText("Button " .. i)
end

-- Scroll panel in a frame
local frame = lia.derma.frame(nil, "Scrollable Content", 300, 400)
local scroll = lia.derma.scrollpanel(frame)

for i = 1, 30 do
    local item = vgui.Create("DPanel", scroll)
    item:Dock(TOP)
    item:DockMargin(5, 5, 5, 0)
    item:SetTall(50)
    item.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, lia.color.theme.panel_alpha[1])
    end
end

-- Dynamic content loading
local function loadMoreContent(scrollPanel, startIndex, count)
    for i = startIndex, startIndex + count - 1 do
        local item = vgui.Create("DLabel", scrollPanel)
        item:Dock(TOP)
        item:DockMargin(5, 5, 5, 0)
        item:SetTall(30)
        item:SetText("Item " .. i)
    end
end

local scrollPanel = lia.derma.scrollpanel(parentPanel)
loadMoreContent(scrollPanel, 1, 50)
```

---

### slideBox

**Purpose**

Creates a slider control with label and value display for numeric input.

**Parameters**

* `parent` (*Panel*): The parent panel to add the slider to.
* `label` (*string*): The label text for the slider.
* `minValue` (*number*): The minimum value of the slider.
* `maxValue` (*number*): The maximum value of the slider.
* `convar` (*string*, optional): The console variable to bind the slider to.
* `decimals` (*number*, optional): The number of decimal places to display.

**Returns**

* `slider` (*DButton*): The created slider control.

**Realm**

Client.

**Example Usage**

```lua
-- Basic slider
local volumeSlider = lia.derma.slideBox(parentPanel, "Volume", 0, 100, "lia_volume")

-- Slider with decimals
local opacitySlider = lia.derma.slideBox(parentPanel, "Opacity", 0, 1, "lia_opacity", 2)

-- Multiple sliders for settings
local sliders = {
    {label = "Master Volume", min = 0, max = 100, convar = "lia_master_volume"},
    {label = "Music Volume", min = 0, max = 100, convar = "lia_music_volume"},
    {label = "SFX Volume", min = 0, max = 100, convar = "lia_sfx_volume"},
    {label = "Mouse Sensitivity", min = 0.1, max = 5.0, convar = "lia_mouse_sensitivity", decimals = 1}
}

for _, sliderInfo in ipairs(sliders) do
    lia.derma.slideBox(parentPanel, sliderInfo.label, sliderInfo.min,
                       sliderInfo.max, sliderInfo.convar, sliderInfo.decimals)
end

-- Custom slider behavior
local customSlider = lia.derma.slideBox(parentPanel, "Custom Value", 0, 100)
customSlider.OnValueChanged = function(value)
    print("Slider value changed to:", value)
    updateBasedOnSlider(value)
end

-- Slider with live preview
local brightnessSlider = lia.derma.slideBox(parentPanel, "Brightness", 0, 2, nil, 1)
brightnessSlider.OnValueChanged = function(value)
    render.SetLightingMode(value)
end

-- Group sliders in categories
local graphicsCategory = lia.derma.category(parentPanel, "Graphics", true)
local resolutionSlider = lia.derma.slideBox(graphicsCategory, "Resolution Scale", 0.5, 2.0, "lia_resolution", 1)
local fpsSlider = lia.derma.slideBox(graphicsCategory, "Max FPS", 30, 300, "lia_max_fps")
```

---

### textBox

**Purpose**

Creates a text input dialog for getting user input with a title and description.

**Parameters**

* `title` (*string*): The title of the dialog.
* `description` (*string*): The placeholder/description text.
* `callback` (*function*): The function to call with the entered text.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic text input
lia.derma.textBox("Enter Name", "Type your name here", function(text)
    print("User entered:", text)
    playerName = text
end)

-- Text input for commands
lia.derma.textBox("Execute Command", "Enter console command", function(command)
    LocalPlayer():ConCommand(command)
end)

-- Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(password)
    if string.len(password) >= 8 then
        setPlayerPassword(password)
        print("Password updated successfully")
    else
        print("Password must be at least 8 characters")
        -- Show the dialog again
        timer.Simple(0.1, function()
            lia.derma.textBox("Set Password", "Enter new password (min 8 chars)", function(newPassword)
                if string.len(newPassword) >= 8 then
                    setPlayerPassword(newPassword)
                else
                    print("Password too short")
                end
            end)
        end)
    end
end)

-- Text input for item naming
lia.derma.textBox("Name Your Item", "Enter a name for this item", function(name)
    if name and name ~= "" then
        currentItem.name = name
        print("Item renamed to:", name)
    else
        print("Invalid name")
    end
end)

-- Multiple text inputs in sequence
local function promptForDetails()
    lia.derma.textBox("Enter Title", "What is the title?", function(title)
        lia.derma.textBox("Enter Description", "Describe it briefly", function(description)
            lia.derma.textBox("Enter Tags", "Comma-separated tags", function(tags)
                saveContent(title, description, tags)
            end)
        end)
    end)
end
```
