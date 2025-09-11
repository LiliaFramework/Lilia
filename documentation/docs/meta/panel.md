# Panel Meta

This page documents methods available on the `Panel` meta table, representing UI panels in the Lilia framework.

---

## Overview

The `Panel` meta table extends Garry's Mod's base panel functionality with Lilia-specific features including inventory change listening, scaled positioning, and automatic hook management. These methods provide enhanced UI capabilities for creating responsive and interactive interfaces within the Lilia framework, particularly for inventory management and other game systems.

---

### panelMeta:liaListenForInventoryChanges

**Purpose**

Sets up the panel to automatically listen for inventory changes and call appropriate methods.

**Parameters**

* `inventory` (*Inventory*): The inventory to listen for changes on.

**Returns**

*None.*

**Realm**

Client.

**Notes**

This method listens for the following inventory events:
- InventoryInitialized
- InventoryDeleted
- InventoryDataChanged
- InventoryItemAdded
- InventoryItemRemoved
- ItemDataChanged

When these events occur, corresponding methods on the panel will be called (e.g., InventoryItemAdded, InventoryItemRemoved, etc.).

**Example Usage**

```lua
local function setupInventoryPanel(panel, inventory)
    panel:liaListenForInventoryChanges(inventory)
    print("Panel is now listening for inventory changes!")
end

local function createInventoryInterface(inventory)
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()
    
    setupInventoryPanel(frame, inventory)
    return frame
end

concommand.Add("create_inventory_panel", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            createInventoryInterface(inv)
        end
    end
end)
```

---

### panelMeta:liaDeleteInventoryHooks

**Purpose**

Removes all inventory-related hooks from the panel.

**Parameters**

* `id` (*number|nil*): Specific inventory ID to remove hooks for, or nil for all.

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function cleanupInventoryPanel(panel, inventoryID)
    panel:liaDeleteInventoryHooks(inventoryID)
    print("Cleaned up inventory hooks for panel!")
end

local function removeInventoryInterface(panel)
    cleanupInventoryPanel(panel)
    panel:Remove()
end

concommand.Add("remove_inventory_panel", function(ply)
    local panels = vgui.GetWorldPanel():GetChildren()
    for _, panel in ipairs(panels) do
        if panel:GetName() == "InventoryFrame" then
            removeInventoryInterface(panel)
            break
        end
    end
end)
```

---

### panelMeta:SetScaledPos

**Purpose**

Sets the panel's position using scaled coordinates for different screen resolutions.

**Parameters**

* `x` (*number*): The scaled X position.
* `y` (*number*): The scaled Y position.

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function createScaledPanel()
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:SetScaledPos(100, 100)
    frame:MakePopup()
    
    print("Panel positioned at scaled coordinates!")
    return frame
end

concommand.Add("create_scaled_panel", function(ply)
    createScaledPanel()
end)
```

---

### panelMeta:SetScaledSize

**Purpose**

Sets the panel's size using scaled dimensions for different screen resolutions.

**Parameters**

* `w` (*number*): The scaled width.
* `h` (*number*): The scaled height.

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function createResponsivePanel()
    local frame = vgui.Create("DFrame")
    frame:SetScaledSize(400, 300)
    frame:Center()
    frame:MakePopup()
    
    print("Panel sized for current screen resolution!")
    return frame
end

concommand.Add("create_responsive_panel", function(ply)
    createResponsivePanel()
end)
```

---
