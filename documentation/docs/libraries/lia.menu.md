# Menu Library

This page documents the functions for working with 3D context menus and menu management.

---

## Overview

The menu library (`lia.menu`) provides a comprehensive system for managing 3D context menus, menu interactions, and menu rendering in the Lilia framework, enabling intuitive and immersive user interfaces within the 3D game world. This library handles sophisticated menu management with support for dynamic menu generation, context-sensitive options, and real-time menu updates based on player state and environmental conditions. The system features advanced menu interaction with support for various input methods including mouse, keyboard, and gamepad controls, with customizable interaction patterns and accessibility options for different player preferences. It includes comprehensive menu rendering with support for 3D positioning, scaling, and orientation that adapts to different viewing angles and distances for optimal visibility and usability. The library provides robust button management with support for complex button hierarchies, conditional visibility, and dynamic content generation based on available actions and player permissions. Additional features include menu animation systems, sound integration for user feedback, and performance optimization for complex menu structures, making it essential for creating responsive and engaging user interfaces that enhance player interaction and overall gameplay experience.

---

### add

**Purpose**

Adds a new 3D context menu at a specific position or attached to an entity.

**Parameters**

* `opts` (*table*): The menu options table containing key-value pairs for menu items.
* `pos` (*Vector* or *Entity*, optional): The position to show the menu, or an entity to attach it to.
* `onRemove` (*function*, optional): Callback function called when the menu is removed.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Add a basic menu at a position
lia.menu.add({
    ["Option 1"] = function()
        LocalPlayer():notify("Option 1 selected")
    end,
    ["Option 2"] = function()
        LocalPlayer():notify("Option 2 selected")
    end
}, Vector(0, 0, 0))

-- Add a menu attached to an entity
local function addEntityMenu(entity)
    lia.menu.add({
        ["Examine"] = function()
            LocalPlayer():notify("Examining " .. entity:GetClass())
        end,
        ["Use"] = function()
            LocalPlayer():notify("Using " .. entity:GetClass())
        end,
        ["Destroy"] = function()
            LocalPlayer():notify("Destroying " .. entity:GetClass())
        end
    }, entity)
end

-- Add a menu with removal callback
local function addMenuWithCallback()
    lia.menu.add({
        ["Save Game"] = function()
            LocalPlayer():notify("Game saved!")
        end,
        ["Load Game"] = function()
            LocalPlayer():notify("Game loaded!")
        end
    }, Vector(100, 200, 50), function()
        print("Menu was removed")
    end)
end

-- Use in a function
local function createContextMenu(entity, options)
    lia.menu.add(options, entity)
    print("Context menu created for " .. entity:GetClass())
end
```

---

### drawAll

**Purpose**

Draws all active menus.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw all menus
local function drawAllMenus()
    lia.menu.drawAll()
end

-- Use in a hook
hook.Add("HUDPaint", "DrawMenus", function()
    lia.menu.drawAll()
end)

-- Use in a function
local function renderMenus()
    lia.menu.drawAll()
end

-- Use in a function
local function drawMenusWithBlur()
    lia.util.drawBlur(0, 0, ScrW(), ScrH())
    lia.menu.drawAll()
end
```

---

### getActiveMenu

**Purpose**

Gets the currently active menu and the selected item if the mouse is hovering over it.

**Parameters**

*None*

**Returns**

* `menuIndex` (*number*): The index of the active menu in the menu list.
* `callback` (*function*): The callback function of the hovered menu item, or nil if no item is hovered.

**Realm**

Client.

**Example Usage**

```lua
-- Get active menu and selected item
local function getActiveMenuAndItem()
    return lia.menu.getActiveMenu()
end

-- Use in a function
local function checkMenuInteraction()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex then
        print("Active menu index: " .. menuIndex)
        if callback then
            print("Hovered item has callback")
            -- The callback can be called later when button is pressed
            return menuIndex, callback
        else
            print("No item hovered")
            return menuIndex, nil
        end
    else
        print("No active menu")
        return nil, nil
    end
end

-- Use in a function
local function getHoveredMenuItem()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if callback then
        print("Currently hovering over a menu item")
        return callback
    else
        print("Not hovering over any menu item")
        return nil
    end
end

-- Use in a function
local function handleMenuSelection()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if callback then
        -- Execute the callback when item is selected
        callback()
        print("Menu item executed")
    end
end
```

---

### onButtonPressed

**Purpose**

Handles button press events for menus and executes the selected menu item callback.

**Parameters**

* `id` (*number*): The index of the menu in the menu list.
* `cb` (*function*): The callback function to execute for the selected menu item.

**Returns**

* `success` (*boolean*): True if a menu item was executed, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Handle button press for menu selection
local function handleMenuButtonPress()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if callback then
        local success = lia.menu.onButtonPressed(menuIndex, callback)
        if success then
            print("Menu item executed successfully")
        end
    end
end

-- Use in a function
local function processMenuSelection()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex and callback then
        lia.menu.onButtonPressed(menuIndex, callback)
        print("Menu selection processed")
    end
end

-- Use in a function
local function executeMenuAction()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if callback then
        local executed = lia.menu.onButtonPressed(menuIndex, callback)
        if executed then
            print("Menu action executed")
        else
            print("Menu action failed")
        end
    end
end

-- Use in a function
local function handleMenuInteraction()
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex and callback then
        lia.menu.onButtonPressed(menuIndex, callback)
        print("Menu interaction completed")
    end
end
```












