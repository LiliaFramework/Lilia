# lia.menu

---

Entity menu manipulation.

The `lia.menu` library allows you to open a context menu with arbitrary options. When a player selects an option from the menu, the corresponding callback function is executed. This facilitates interactive menus for entities, enhancing user experience by providing accessible and dynamic options directly within the game interface.

---

## Functions

### **lia.menu.add**

**Description:**  
Adds a menu with the provided options at a specified position. The menu can be associated with a world position or an entity. An optional callback can be executed when the menu is removed.

**Realm:**  
`Client`

**Parameters:**  

- `options` (`table`):  
  Table containing the menu options. Each key-value pair represents an option identifier and its corresponding action.

- `position` (`Vector|Entity`):  
  Position of the menu. This can be a `Vector` representing a world position or an `Entity` to attach the menu to.

- `onRemove` (`function`, optional):  
  Callback function to execute when the menu is removed.

**Returns:**  
`number` - The index of the added menu in the `lia.menu.list` table.

**Example Usage:**
```lua
-- Add a context menu with options "Take" and "Drop" at a specific position
lia.menu.add({
    ["Take"] = function()
        -- Code to take the item
    end,
    ["Drop"] = function()
        -- Code to drop the item
    end
}, Vector(100, 200, 300), function()
    print("Menu has been removed.")
end)
```

---

### **lia.menu.drawAll**

**Description:**  
Draws all active menus currently on the screen. This function should be called every frame to render the menus based on their positions and states.

**Realm:**  
`Client`

**Example Usage:**
```lua
-- Hook the drawAll function to the HUDPaint event
hook.Add("HUDPaint", "DrawAllMenus", function()
    lia.menu.drawAll()
end)
```

---

### **lia.menu.getActiveMenu**

**Description:**  
Retrieves the index and the chosen option of the active menu, if any. This function checks if the player's cursor is within any active menu and returns the relevant information.

**Realm:**  
`Client`

**Returns:**  
`number|nil, string|nil`  
Returns the index of the active menu in the `lia.menu.list` table and the chosen option. If no menu is active, returns `nil, nil`.

**Example Usage:**
```lua
-- Check if a menu option was selected
local menuIndex, chosenOption = lia.menu.getActiveMenu()
if chosenOption then
    print("Selected Option:", chosenOption)
    -- Execute the corresponding callback
    lia.menu.onButtonPressed(menuIndex, function()
        print("Option executed.")
    end)
end
```

---

### **lia.menu.onButtonPressed**

**Description:**  
Executes a callback function when a menu button is pressed and removes the menu from the active list.

**Realm:**  
`Client`

**Parameters:**  

- `menu` (`number`):  
  The index of the menu to remove from the `lia.menu.list` table.

- `callback` (`function`):  
  The callback function to execute upon button press.

**Returns:**  
`bool` - `True` if a callback was provided and executed, `false` otherwise.

**Example Usage:**
```lua
-- Execute a callback when a menu option is pressed
lia.menu.onButtonPressed(menuIndex, function()
    print("Menu option has been selected and executed.")
end)
```