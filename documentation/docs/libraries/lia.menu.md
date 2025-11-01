# Menu Library

Interactive 3D context menu system for world and entity interactions in the Lilia framework.

---

Overview

The menu library provides a comprehensive context menu system for the Lilia framework. It enables the creation of interactive context menus that appear in 3D world space or attached to entities, allowing players to interact with objects and perform actions through a visual interface. The library handles menu positioning, animation, collision detection, and user interaction. Menus automatically fade in when the player looks at them and fade out when they look away, with smooth animations and proper range checking. The system supports both world-positioned menus and entity-attached menus with automatic screen space conversion and boundary clamping to ensure menus remain visible and accessible.

---

### add

**Purpose**

Creates and adds a new context menu to the menu system

**When Called**

When you need to display a context menu with options for player interaction

**Parameters**

* `opts` (*table*): Table of menu options where keys are display text and values are callback functions
* `pos` (*Vector|Entity, optional*): World position or entity to attach menu to. If entity, menu attaches to entity's local position
* `onRemove` (*function, optional*): Callback function called when menu is removed

**Returns**

* (number) Index of the created menu in the menu list

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Create a basic context menu
lia.menu.add({
["Use"] = function() print("Used item") end,
["Drop"] = function() print("Dropped item") end
})

```

**Medium Complexity:**
```lua
-- Medium: Create menu attached to an entity
local ent = Entity(1)
lia.menu.add({
["Open"] = function() ent:Use() end,
["Examine"] = function() print("Examining entity") end,
["Destroy"] = function() ent:Remove() end
}, ent)

```

**High Complexity:**
```lua
-- High: Create menu with custom position and cleanup
local menuData = {
["Option 1"] = function()
RunConsoleCommand("say", "Selected option 1")
end,
["Option 2"] = function()
RunConsoleCommand("say", "Selected option 2")
end,
["Cancel"] = function()
print("Menu cancelled")
end
}
local cleanupFunc = function()
print("Menu was removed")
end
local menuIndex = lia.menu.add(menuData, Vector(100, 200, 50), cleanupFunc)

```

---

### drawAll

**Purpose**

Renders all active context menus with animations and interaction detection

**When Called**

Called every frame from the HUD rendering system to draw all menus

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Called automatically by the framework
-- This function is typically called from hooks like HUDPaint
hook.Add("HUDPaint", "MenuDraw", lia.menu.drawAll)

```

**Medium Complexity:**
```lua
-- Medium: Custom rendering with additional checks
hook.Add("HUDPaint", "CustomMenuDraw", function()
if not LocalPlayer():Alive() then return end
    lia.menu.drawAll()
end)

```

**High Complexity:**
```lua
-- High: Conditional rendering with performance optimization
local lastDrawTime = 0
hook.Add("HUDPaint", "OptimizedMenuDraw", function()
local currentTime = RealTime()
if currentTime - lastDrawTime < 0.016 then return end -- Limit to ~60fps
    if #lia.menu.list > 0 then
        lia.menu.drawAll()
        lastDrawTime = currentTime
    end
end)

```

---

### getActiveMenu

**Purpose**

Gets the currently active menu item that the player is hovering over

**When Called**

When checking for menu interaction, typically from input handling systems

**Returns**

* (number, function|nil) Menu index and callback function if menu item is hovered, nil otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player is hovering over a menu
local menuIndex, callback = lia.menu.getActiveMenu()
if callback then
    print("Player is hovering over menu item")
end

```

**Medium Complexity:**
```lua
-- Medium: Handle menu interaction with validation
hook.Add("PlayerButtonDown", "MenuInteraction", function(ply, button)
if button == MOUSE_LEFT then
    local menuIndex, callback = lia.menu.getActiveMenu()
    if callback then
        callback()
        print("Menu item activated")
    end
end
end)

```

**High Complexity:**
```lua
-- High: Advanced menu interaction with cooldown and logging
local lastMenuTime = 0
hook.Add("PlayerButtonDown", "AdvancedMenuInteraction", function(ply, button)
if button == MOUSE_LEFT then
    local currentTime = RealTime()
    if currentTime - lastMenuTime < 0.1 then return end -- Prevent spam
        local menuIndex, callback = lia.menu.getActiveMenu()
        if callback then
            lastMenuTime = currentTime
            callback()
            -- Log the interaction
            print(string.format("Menu interaction at time %f, menu index %d", currentTime, menuIndex))
        end
    end
end)

```

---

### onButtonPressed

**Purpose**

Handles button press events for menu items and removes the menu

**When Called**

When a menu item is clicked or activated by player input

**Parameters**

* `id` (*number*): Index of the menu to remove from the menu list
* `cb` (*function, optional*): Callback function to execute when button is pressed

**Returns**

* (boolean) True if callback was executed, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove menu and execute callback
local menuIndex = 1
local success = lia.menu.onButtonPressed(menuIndex, function()
print("Menu button pressed!")
end)

```

**Medium Complexity:**
```lua
-- Medium: Handle menu interaction with validation
hook.Add("PlayerButtonDown", "MenuButtonPress", function(ply, button)
if button == MOUSE_LEFT then
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex and callback then
        local success = lia.menu.onButtonPressed(menuIndex, callback)
        if success then
            print("Menu interaction successful")
        end
    end
end
end)

```

**High Complexity:**
```lua
-- High: Advanced menu handling with error checking and logging
local function handleMenuPress(menuIndex, callback)
    if not menuIndex or menuIndex <= 0 then
        print("Invalid menu index")
        return false
    end
    if not callback or type(callback) ~= "function" then
        print("Invalid callback function")
        return false
    end
    local success = lia.menu.onButtonPressed(menuIndex, function()
    local success, err = pcall(callback)
    if not success then
        print("Menu callback error: " .. tostring(err))
    end
end)
return success
end
-- Usage
local menuIndex, callback = lia.menu.getActiveMenu()
if menuIndex then
    handleMenuPress(menuIndex, callback)
end

```

---

