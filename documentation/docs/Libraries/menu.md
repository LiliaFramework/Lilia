# Menu Library

Interactive 3D context menu system for world and entity interactions in the Lilia framework.

---

Overview

The menu library provides a comprehensive context menu system for the Lilia framework. It enables the creation of interactive context menus that appear in 3D world space or attached to entities, allowing players to interact with objects and perform actions through a visual interface. The library handles menu positioning, animation, collision detection, and user interaction. Menus automatically fade in when the player looks at them and fade out when they look away, with smooth animations and proper range checking. The system supports both world-positioned menus and entity-attached menus with automatic screen space conversion and boundary clamping to ensure menus remain visible and accessible.

---

### lia.menu.add

#### 📋 Purpose
Adds a new interactive context menu to the system that can be displayed in 3D world space or attached to entities.

#### ⏰ When Called
Called when creating context menus for world interactions, entity interactions, or any situation requiring a visual menu interface.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `opts` | **table** | A table containing menu options where keys are display text and values are callback functions. |
| `pos` | **Vector or Entity** | The world position for the menu, or an entity to attach the menu to. |
| `onRemove` | **function** | Optional callback function called when the menu is removed. |

#### ↩️ Returns
* number
The index of the newly added menu in the menu list.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Create a simple menu for an entity
    lia.menu.add({
        ["Open"] = function() print("Opening...") end,
        ["Close"] = function() print("Closing...") end
    }, entity)
    -- Create a world-positioned menu
    lia.menu.add({
        ["Pickup"] = function() print("Picked up!") end
    }, Vector(0, 0, 0))

```

---

### lia.menu.drawAll

#### 📋 Purpose
Renders all active context menus on the screen with smooth animations, range checking, and mouse interaction highlighting.

#### ⏰ When Called
Called every frame during the HUD/rendering phase to draw all active menus. Typically hooked into the drawing system.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Called automatically by the framework's rendering system
    -- Can be manually called if needed for custom rendering setups
    hook.Add("HUDPaint", "DrawMenus", function()
        lia.menu.drawAll()
    end)

```

---

### lia.menu.getActiveMenu

#### 📋 Purpose
Determines which menu item is currently under the mouse cursor and within interaction range.

#### ⏰ When Called
Called when checking for menu interactions, mouse clicks, or determining which menu option the player is hovering over.

#### ↩️ Returns
* number, function or nil
Returns the menu index and the callback function of the active menu item, or nil if no active menu item is found.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Check for menu interactions in a click handler
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex and callback then
        lia.menu.onButtonPressed(menuIndex, callback)
    end
    -- Check if player is hovering over a menu
    local activeMenu = lia.menu.getActiveMenu()
    if activeMenu then
        -- Player is hovering over a menu item
    end

```

---

### lia.menu.onButtonPressed

#### 📋 Purpose
Handles menu button press events by removing the menu and executing the associated callback function.

#### ⏰ When Called
Called when a menu button is clicked to process the interaction and clean up the menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The index of the menu to remove from the menu list. |
| `cb` | **function** | The callback function to execute when the button is pressed. |

#### ↩️ Returns
* boolean
Returns true if a callback was executed, false otherwise.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Handle a menu button press
    local menuIndex, callback = lia.menu.getActiveMenu()
    if menuIndex then
        local success = lia.menu.onButtonPressed(menuIndex, callback)
        if success then
            print("Menu action executed successfully")
        end
    end
    -- Remove a menu without executing callback
    lia.menu.onButtonPressed(specificMenuId)

```

---

