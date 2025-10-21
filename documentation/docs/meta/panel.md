# Panel Meta Table

This file extends the base Panel metatable in Garry's Mod with additional functionality

---

### panelMeta:liaListenForInventoryChanges

**Purpose**

Sets up event listeners for inventory changes on a panel

**When Called**

When a UI panel needs to respond to inventory modifications, typically during panel initialization

**Parameters**

* `inventory` (*unknown*): The inventory object to listen for changes on

**Returns**

* Nothing

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set up inventory listening for a basic panel
panel:liaListenForInventoryChanges(playerInventory)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set up inventory listening with conditional setup
if playerInventory then
characterPanel:liaListenForInventoryChanges(playerInventory)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Set up inventory listening for multiple panels with error handling
local panels = {inventoryPanel, characterPanel, equipmentPanel}
for _, pnl in ipairs(panels) do
if IsValid(pnl) and playerInventory then
pnl:liaListenForInventoryChanges(playerInventory)
end
end
```
```

---

### listenForInventoryChange

**Purpose**

Sets up event listeners for inventory changes on a panel

**When Called**

When a UI panel needs to respond to inventory modifications, typically during panel initialization

**Parameters**

* `inventory` (*unknown*): The inventory object to listen for changes on

**Returns**

* Nothing

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set up inventory listening for a basic panel
panel:liaListenForInventoryChanges(playerInventory)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set up inventory listening with conditional setup
if playerInventory then
characterPanel:liaListenForInventoryChanges(playerInventory)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Set up inventory listening for multiple panels with error handling
local panels = {inventoryPanel, characterPanel, equipmentPanel}
for _, pnl in ipairs(panels) do
if IsValid(pnl) and playerInventory then
pnl:liaListenForInventoryChanges(playerInventory)
end
end
```
```

---

### panelMeta:liaDeleteInventoryHooks

**Purpose**

Removes inventory change event listeners from a panel

**When Called**

When a panel no longer needs to listen to inventory changes, during cleanup, or when switching inventories

**Returns**

* Nothing

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Remove hooks for a specific inventory
panel:liaDeleteInventoryHooks(inventoryID)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Clean up hooks when closing a panel
if IsValid(panel) then
panel:liaDeleteInventoryHooks()
end
```
```

**High Complexity:**
```lua
```lua
-- High: Clean up multiple panels with different inventory IDs
local panels = {inventoryPanel, equipmentPanel, storagePanel}
local inventoryIDs = {playerInvID, equipmentInvID, storageInvID}
for i, pnl in ipairs(panels) do
if IsValid(pnl) then
pnl:liaDeleteInventoryHooks(inventoryIDs[i])
end
end
```
```

---

### panelMeta:setScaledPos

**Purpose**

Sets the position of a panel with automatic screen scaling

**When Called**

When positioning UI elements that need to adapt to different screen resolutions

**Parameters**

* `x` (*unknown*): The horizontal position value to be scaled
* `y` (*unknown*): The vertical position value to be scaled

**Returns**

* Nothing

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Position a button at scaled coordinates
button:setScaledPos(100, 50)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Position panel based on screen dimensions
local x = ScrW() * 0.5 - 200
local y = ScrH() * 0.3
panel:setScaledPos(x, y)
```
```

**High Complexity:**
```lua
```lua
-- High: Position multiple panels with responsive layout
local panels = {mainPanel, sidePanel, footerPanel}
local positions = {
{ScrW() * 0.1, ScrH() * 0.1},
{ScrW() * 0.7, ScrH() * 0.1},
{ScrW() * 0.1, ScrH() * 0.8}
}
for i, pnl in ipairs(panels) do
if IsValid(pnl) then
pnl:setScaledPos(positions[i][1], positions[i][2])
end
end
```
```

---

### panelMeta:setScaledSize

**Purpose**

Sets the size of a panel with automatic screen scaling

**When Called**

When sizing UI elements that need to adapt to different screen resolutions

**Parameters**

* `w` (*unknown*): The width value to be scaled
* `h` (*unknown*): The height value to be scaled

**Returns**

* Nothing

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Set panel size with scaled dimensions
panel:setScaledSize(400, 300)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Set size based on screen proportions
local w = ScrW() * 0.8
local h = ScrH() * 0.6
panel:setScaledSize(w, h)
```
```

**High Complexity:**
```lua
```lua
-- High: Set sizes for multiple panels with responsive layout
local panels = {mainPanel, sidePanel, footerPanel}
local sizes = {
{ScrW() * 0.7, ScrH() * 0.6},
{ScrW() * 0.25, ScrH() * 0.6},
{ScrW() * 0.95, ScrH() * 0.1}
}
for i, pnl in ipairs(panels) do
if IsValid(pnl) then
pnl:setScaledSize(sizes[i][1], sizes[i][2])
end
end
```
```

---

