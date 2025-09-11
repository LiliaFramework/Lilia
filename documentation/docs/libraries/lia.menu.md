# Menu Library

This page documents the functions for working with 3D context menus and menu management.

---

## Overview

The menu library (`lia.menu`) provides a comprehensive system for managing 3D context menus, menu interactions, and menu rendering in the Lilia framework, enabling intuitive and immersive user interfaces within the 3D game world. This library handles sophisticated menu management with support for dynamic menu generation, context-sensitive options, and real-time menu updates based on player state and environmental conditions. The system features advanced menu interaction with support for various input methods including mouse, keyboard, and gamepad controls, with customizable interaction patterns and accessibility options for different player preferences. It includes comprehensive menu rendering with support for 3D positioning, scaling, and orientation that adapts to different viewing angles and distances for optimal visibility and usability. The library provides robust button management with support for complex button hierarchies, conditional visibility, and dynamic content generation based on available actions and player permissions. Additional features include menu animation systems, sound integration for user feedback, and performance optimization for complex menu structures, making it essential for creating responsive and engaging user interfaces that enhance player interaction and overall gameplay experience.

---

### lia.menu.add

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

### lia.menu.drawAll

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

### lia.menu.getActiveMenu

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

### lia.menu.onButtonPressed

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

---

### lia.menu.open

**Purpose**

Opens a menu for a client.

**Parameters**

* `client` (*Player*): The client to open the menu for.
* `menuName` (*string*): The name of the menu to open.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Open menu for client
local function openMenu(client, menuName)
    lia.menu.open(client, menuName)
end

-- Use in a function
local function openPlayerMenu(client, target)
    lia.menu.open(client, "Player Menu")
    print("Player menu opened for " .. client:Name())
end

-- Use in a function
local function openTestMenu(client)
    lia.menu.open(client, "Test Menu")
    print("Test menu opened for " .. client:Name())
end

-- Use in a function
local function openMenuForAll(menuName)
    for _, client in ipairs(player.GetAll()) do
        lia.menu.open(client, menuName)
    end
    print("Menu opened for all players: " .. menuName)
end
```

---

### lia.menu.close

**Purpose**

Closes the active menu for a client.

**Parameters**

* `client` (*Player*): The client to close the menu for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Close menu for client
local function closeMenu(client)
    lia.menu.close(client)
end

-- Use in a function
local function closePlayerMenu(client)
    lia.menu.close(client)
    print("Menu closed for " .. client:Name())
end

-- Use in a function
local function closeAllMenus()
    for _, client in ipairs(player.GetAll()) do
        lia.menu.close(client)
    end
    print("All menus closed")
end

-- Use in a function
local function closeMenuIfOpen(client)
    local menu = lia.menu.getActiveMenu()
    if menu then
        lia.menu.close(client)
        print("Menu closed for " .. client:Name())
    end
end
```

---

### lia.menu.isOpen

**Purpose**

Checks if a menu is open for a client.

**Parameters**

* `client` (*Player*): The client to check.

**Returns**

* `isOpen` (*boolean*): True if a menu is open.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if menu is open
local function isMenuOpen(client)
    return lia.menu.isOpen(client)
end

-- Use in a function
local function checkMenuStatus(client)
    if lia.menu.isOpen(client) then
        print("Menu is open for " .. client:Name())
        return true
    else
        print("No menu open for " .. client:Name())
        return false
    end
end

-- Use in a function
local function showMenuStatus(client)
    local isOpen = lia.menu.isOpen(client)
    client:notify("Menu status: " .. (isOpen and "Open" or "Closed"))
end

-- Use in a function
local function checkAllMenus()
    for _, client in ipairs(player.GetAll()) do
        if lia.menu.isOpen(client) then
            print("Menu open for " .. client:Name())
        end
    end
end
```

---

### lia.menu.getMenu

**Purpose**

Gets a menu by name.

**Parameters**

* `menuName` (*string*): The menu name.

**Returns**

* `menu` (*table*): The menu data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get menu by name
local function getMenu(menuName)
    return lia.menu.getMenu(menuName)
end

-- Use in a function
local function checkMenuExists(menuName)
    local menu = lia.menu.getMenu(menuName)
    if menu then
        print("Menu exists: " .. menuName)
        return true
    else
        print("Menu not found: " .. menuName)
        return false
    end
end

-- Use in a function
local function showMenuInfo(menuName)
    local menu = lia.menu.getMenu(menuName)
    if menu then
        print("Menu: " .. menuName)
        print("Options: " .. #menu.options)
        return menu
    else
        print("Menu not found")
        return nil
    end
end

-- Use in a function
local function getMenuOptions(menuName)
    local menu = lia.menu.getMenu(menuName)
    return menu and menu.options or {}
end
```

---

### lia.menu.getAll

**Purpose**

Gets all registered menus.

**Parameters**

*None*

**Returns**

* `menus` (*table*): Table of all menus.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all menus
local function getAllMenus()
    return lia.menu.getAll()
end

-- Use in a function
local function showAllMenus()
    local menus = lia.menu.getAll()
    print("Available menus:")
    for _, menu in ipairs(menus) do
        print("- " .. menu.name)
    end
end

-- Use in a function
local function getMenuCount()
    local menus = lia.menu.getAll()
    return #menus
end

-- Use in a function
local function getMenusByCategory(category)
    local menus = lia.menu.getAll()
    local filtered = {}
    for _, menu in ipairs(menus) do
        if menu.category == category then
            table.insert(filtered, menu)
        end
    end
    return filtered
end
```

---

### lia.menu.remove

**Purpose**

Removes a menu from the system.

**Parameters**

* `menuName` (*string*): The menu name to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a menu
local function removeMenu(menuName)
    lia.menu.remove(menuName)
end

-- Use in a function
local function removeOldMenu(menuName)
    lia.menu.remove(menuName)
    print("Menu removed: " .. menuName)
end

-- Use in a function
local function cleanupOldMenus()
    local oldMenus = {"old_menu1", "old_menu2", "old_menu3"}
    for _, menu in ipairs(oldMenus) do
        lia.menu.remove(menu)
    end
    print("Old menus cleaned up")
end

-- Use in a function
local function removeMenusByCategory(category)
    local menus = lia.menu.getAll()
    for _, menu in ipairs(menus) do
        if menu.category == category then
            lia.menu.remove(menu.name)
        end
    end
    print("Menus removed for category: " .. category)
end
```

---

### lia.menu.clear

**Purpose**

Clears all menus from the system.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Clear all menus
local function clearAllMenus()
    lia.menu.clear()
end

-- Use in a function
local function resetMenuSystem()
    lia.menu.clear()
    print("Menu system reset")
end

-- Use in a function
local function reloadMenus()
    lia.menu.clear()
    -- Re-register default menus
    lia.menu.add({name = "Test Menu", options = {}})
    print("Menus reloaded")
end

-- Use in a command
lia.command.add("resetmenus", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.menu.clear()
        client:notify("All menus cleared")
    end
})
```

---

### lia.menu.setPosition

**Purpose**

Sets the position of a menu.

**Parameters**

* `client` (*Player*): The client to set the position for.
* `position` (*Vector*): The menu position.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set menu position
local function setMenuPosition(client, position)
    lia.menu.setPosition(client, position)
end

-- Use in a function
local function setMenuAtPlayer(client)
    local position = client:GetPos() + client:GetForward() * 100
    lia.menu.setPosition(client, position)
    print("Menu position set for " .. client:Name())
end

-- Use in a function
local function setMenuAtTarget(client, target)
    local position = target:GetPos() + target:GetForward() * 50
    lia.menu.setPosition(client, position)
    print("Menu position set at target")
end

-- Use in a function
local function setMenuAtEntity(client, entity)
    local position = entity:GetPos() + entity:GetUp() * 50
    lia.menu.setPosition(client, position)
    print("Menu position set at entity")
end
```

---

### lia.menu.getPosition

**Purpose**

Gets the position of a menu.

**Parameters**

* `client` (*Player*): The client to get the position for.

**Returns**

* `position` (*Vector*): The menu position.

**Realm**

Shared.

**Example Usage**

```lua
-- Get menu position
local function getMenuPosition(client)
    return lia.menu.getPosition(client)
end

-- Use in a function
local function showMenuPosition(client)
    local position = lia.menu.getPosition(client)
    if position then
        print("Menu position for " .. client:Name() .. ": " .. tostring(position))
        return position
    else
        print("No menu position for " .. client:Name())
        return nil
    end
end

-- Use in a function
local function checkMenuPosition(client)
    local position = lia.menu.getPosition(client)
    if position then
        local distance = client:GetPos():Distance(position)
        print("Menu distance: " .. distance)
        return distance
    else
        print("No menu position")
        return nil
    end
end

-- Use in a function
local function getMenuPositionIfOpen(client)
    if lia.menu.isOpen(client) then
        return lia.menu.getPosition(client)
    else
        return nil
    end
end
```

---

### lia.menu.setSize

**Purpose**

Sets the size of a menu.

**Parameters**

* `client` (*Player*): The client to set the size for.
* `size` (*Vector*): The menu size.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set menu size
local function setMenuSize(client, size)
    lia.menu.setSize(client, size)
end

-- Use in a function
local function setMenuSizeSmall(client)
    lia.menu.setSize(client, Vector(200, 150, 0))
    print("Menu size set to small for " .. client:Name())
end

-- Use in a function
local function setMenuSizeLarge(client)
    lia.menu.setSize(client, Vector(400, 300, 0))
    print("Menu size set to large for " .. client:Name())
end

-- Use in a function
local function setMenuSizeCustom(client, width, height)
    lia.menu.setSize(client, Vector(width, height, 0))
    print("Menu size set to " .. width .. "x" .. height .. " for " .. client:Name())
end
```

---

### lia.menu.getSize

**Purpose**

Gets the size of a menu.

**Parameters**

* `client` (*Player*): The client to get the size for.

**Returns**

* `size` (*Vector*): The menu size.

**Realm**

Shared.

**Example Usage**

```lua
-- Get menu size
local function getMenuSize(client)
    return lia.menu.getSize(client)
end

-- Use in a function
local function showMenuSize(client)
    local size = lia.menu.getSize(client)
    if size then
        print("Menu size for " .. client:Name() .. ": " .. tostring(size))
        return size
    else
        print("No menu size for " .. client:Name())
        return nil
    end
end

-- Use in a function
local function checkMenuSize(client)
    local size = lia.menu.getSize(client)
    if size then
        local area = size.x * size.y
        print("Menu area: " .. area)
        return area
    else
        print("No menu size")
        return nil
    end
end

-- Use in a function
local function getMenuSizeIfOpen(client)
    if lia.menu.isOpen(client) then
        return lia.menu.getSize(client)
    else
        return nil
    end
end
```

---

### lia.menu.setVisible

**Purpose**

Sets the visibility of a menu.

**Parameters**

* `client` (*Player*): The client to set visibility for.
* `visible` (*boolean*): Whether the menu should be visible.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set menu visibility
local function setMenuVisibility(client, visible)
    lia.menu.setVisible(client, visible)
end

-- Use in a function
local function showMenu(client)
    lia.menu.setVisible(client, true)
    print("Menu shown for " .. client:Name())
end

-- Use in a function
local function hideMenu(client)
    lia.menu.setVisible(client, false)
    print("Menu hidden for " .. client:Name())
end

-- Use in a function
local function toggleMenuVisibility(client)
    local current = lia.menu.isVisible(client)
    lia.menu.setVisible(client, not current)
    print("Menu visibility toggled for " .. client:Name())
end
```

---

### lia.menu.isVisible

**Purpose**

Checks if a menu is visible.

**Parameters**

* `client` (*Player*): The client to check.

**Returns**

* `isVisible` (*boolean*): True if the menu is visible.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if menu is visible
local function isMenuVisible(client)
    return lia.menu.isVisible(client)
end

-- Use in a function
local function checkMenuVisibility(client)
    if lia.menu.isVisible(client) then
        print("Menu is visible for " .. client:Name())
        return true
    else
        print("Menu is not visible for " .. client:Name())
        return false
    end
end

-- Use in a function
local function showMenuVisibilityStatus(client)
    local isVisible = lia.menu.isVisible(client)
    client:notify("Menu visibility: " .. (isVisible and "Visible" or "Hidden"))
end

-- Use in a function
local function checkAllMenuVisibility()
    for _, client in ipairs(player.GetAll()) do
        if lia.menu.isVisible(client) then
            print("Menu visible for " .. client:Name())
        end
    end
end
```