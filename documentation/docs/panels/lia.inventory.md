# Inventory Panels Library

A comprehensive collection of panels for managing character inventories, items, and storage systems within the Lilia framework.

---

## Overview

The inventory panel library provides all the necessary components for item management, from basic inventory displays to advanced grid-based storage systems. These panels handle item display, drag-and-drop functionality, tooltips, context menus, and integrate with Lilia's item system to provide a seamless inventory management experience.

---

### liaInventory

**Purpose**

Main inventory frame for characters. It listens for network updates and renders items in the layout provided by its subclass.

**When Called**

This panel is called when:
- Displaying character inventory contents
- Managing item storage and organization
- Providing inventory management interface
- Handling item-related user interactions

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic inventory
local inventory = vgui.Create("liaInventory")
inventory:SetSize(400, 300)
inventory:Center()
inventory:MakePopup()

-- Usually accessed through framework
if lia.gui.inventory and IsValid(lia.gui.inventory) then
    lia.gui.inventory:RefreshInventory()
end
```

---

### liaGridInventory

**Purpose**

Subclass of `liaInventory` that arranges item icons into a fixed grid. Often used for storage containers or equipment screens.

**When Called**

This panel is called when:
- Displaying grid-based item layouts
- Managing container or storage inventories
- Providing organized item display systems
- Creating structured inventory interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a grid inventory
local gridInventory = vgui.Create("liaGridInventory")
gridInventory:SetSize(400, 300)
gridInventory:Center()
gridInventory:MakePopup()

-- Configure grid layout
gridInventory:SetGridSize(5, 4) -- 5 columns, 4 rows
gridInventory:SetupGrid()
```

---

### liaGridInvItem

**Purpose**

Specialized icon used by `liaGridInventory`. Supports drag-and-drop for moving items between slots.

**When Called**

This panel is called when:
- Displaying individual items in grid inventories
- Managing drag-and-drop item interactions
- Providing interactive item slots
- Handling item movement between containers

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by grid inventory systems
-- No manual creation needed - part of inventory framework

-- Custom grid item for advanced inventory systems
local gridItem = vgui.Create("liaGridInvItem")
gridItem:SetItem(itemTable)
gridItem:SetupDragDrop()
```

---

### liaGridInventoryPanel

**Purpose**

Container responsible for laying out `liaGridInvItem` icons in rows and columns. Handles drag-and-drop and keeps the grid in sync with item data.

**When Called**

This panel is called when:
- Managing grid-based item containers
- Coordinating multiple item displays
- Providing structured item organization
- Handling complex inventory layouts

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by grid inventory systems
-- No manual creation needed - part of inventory framework

-- Custom grid container for advanced inventory management
local gridContainer = vgui.Create("liaGridInventoryPanel")
gridContainer:SetupGrid(6, 5) -- 6 columns, 5 rows
gridContainer:PopulateWithItems(inventoryItems)
```

---

### liaItemIcon

**Purpose**

Spawn icon specialised for Lilia item tables. Displays custom tooltips and supports right-click menus.

**When Called**

This panel is called when:
- Displaying item icons in various contexts
- Providing item previews and information
- Managing item tooltips and context menus
- Creating item selection interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `getItem()` – returns the associated item table if available.
- `setItemType(itemTypeOrID)` – assigns an item by unique ID or type string and updates the model and tooltip.
- `openActionMenu()` – builds and shows the context menu for the item.
- `updateTooltip()` – refreshes the tooltip text using the current item data.
- `ItemDataChanged()` – hook that re-runs `updateTooltip` when the item data changes.

**Example Usage**

```lua
-- Create an item icon
local icon = vgui.Create("liaItemIcon")
icon:SetSize(64, 64)
icon:setItemType("weapon_pistol")
icon.DoRightClick = function()
    icon:openActionMenu()
end

-- Access item data
local item = icon:getItem()
if item then
    print("Item name:", item.name)
end
```

---
