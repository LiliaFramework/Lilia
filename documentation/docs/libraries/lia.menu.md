# Menu Library

This page documents the functions for working with 3D context menus and menu management.

---

## Overview

The menu library (`lia.menu`) provides a comprehensive system for managing 3D context menus, menu interactions, and menu rendering in the Lilia framework, enabling intuitive and immersive user interfaces within the 3D game world. This library handles sophisticated menu management with support for dynamic menu generation, context-sensitive options, and real-time menu updates based on player state and environmental conditions. The system features advanced menu interaction with support for various input methods including mouse, keyboard, and gamepad controls, with customizable interaction patterns and accessibility options for different player preferences. It includes comprehensive menu rendering with support for 3D positioning, scaling, and orientation that adapts to different viewing angles and distances for optimal visibility and usability. The library provides robust button management with support for complex button hierarchies, conditional visibility, and dynamic content generation based on available actions and player permissions. Additional features include menu animation systems, sound integration for user feedback, and performance optimization for complex menu structures, making it essential for creating responsive and engaging user interfaces that enhance player interaction and overall gameplay experience.

---

### add

**Purpose**

Adds a new menu to the menu system.

**Parameters**

* `menuData` (*table*): The menu data table containing name, options, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a basic menu
lia.menu.add({
    name = "Test Menu",
    options = {
        {
            text = "Option 1",
            callback = function(client)
                client:notify("Option 1 selected")
            end
        },
        {
            text = "Option 2",
            callback = function(client)
                client:notify("Option 2 selected")
            end
        }
    }
})

-- Add a menu with more options
lia.menu.add({
    name = "Player Menu",
    options = {
        {
            text = "Teleport",
            callback = function(client, target)
                client:SetPos(target:GetPos())
                client:notify("Teleported to " .. target:Name())
            end
        },
        {
            text = "Give Item",
            callback = function(client, target)
                local item = lia.item.new("weapon_pistol")
                target:getChar():getInventory():add(item)
                client:notify("Gave item to " .. target:Name())
            end
        }
    }
})

-- Use in a function
local function createMenu(name, options)
    lia.menu.add({
        name = name,
        options = options
    })
    print("Menu created: " .. name)
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

Gets the currently active menu.

**Parameters**

*None*

**Returns**

* `menu` (*table*): The active menu or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get active menu
local function getActiveMenu()
    return lia.menu.getActiveMenu()
end

-- Use in a function
local function checkMenuActive()
    local menu = lia.menu.getActiveMenu()
    if menu then
        print("Active menu: " .. menu.name)
        return true
    else
        print("No active menu")
        return false
    end
end

-- Use in a function
local function showActiveMenuInfo()
    local menu = lia.menu.getActiveMenu()
    if menu then
        print("Menu: " .. menu.name)
        print("Options: " .. #menu.options)
        return menu
    else
        print("No active menu")
        return nil
    end
end

-- Use in a function
local function getActiveMenuOptions()
    local menu = lia.menu.getActiveMenu()
    return menu and menu.options or {}
end
```

---

### onButtonPressed

**Purpose**

Handles button press events for menus.

**Parameters**

* `button` (*string*): The button that was pressed.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Handle button press
local function onButtonPress(button)
    lia.menu.onButtonPressed(button)
end

-- Use in a function
local function handleMenuInput(button)
    lia.menu.onButtonPressed(button)
end

-- Use in a function
local function processMenuInput(button)
    lia.menu.onButtonPressed(button)
end

-- Use in a function
local function handleMenuNavigation(button)
    lia.menu.onButtonPressed(button)
end
```












