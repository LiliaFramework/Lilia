# Inventory Panel Library

This page documents the inventory management panel components for the Lilia framework.

---

## Overview

The inventory panel library provides a comprehensive set of UI components for managing player inventories, items, and grid-based storage systems. These panels handle item display, drag-and-drop functionality, grid organization, and inventory management interfaces.

---

### liaInventory

**Purpose**

Main inventory panel that displays a player's complete inventory with item management capabilities.

**When Called**

This panel is called when:
- Players need to view their inventory
- Inventory management interfaces are opened
- Item organization and storage is required

**Parameters**

* `inventory` (*table*): Player inventory data.
* `title` (*string*): Inventory panel title.
* `canDrop` (*boolean*): Whether items can be dropped from inventory.

**Returns**

* `panel` (*Panel*): The created inventory panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create player inventory panel
local inventory = vgui.Create("liaInventory")
inventory:setInventory(playerInventory)
inventory:setTitle("My Inventory")

-- Create inventory with drop capability
local droppableInventory = vgui.Create("liaInventory")
droppableInventory:setInventory(playerInventory)
droppableInventory:setCanDrop(true)
```

---

### liaItemIcon

**Purpose**

Displays individual items with visual representation, tooltips, and drag-and-drop functionality.

**When Called**

This panel is called when:
- Individual items need to be displayed
- Item icons are required in lists or grids
- Drag-and-drop item interactions are needed

**Parameters**

* `itemID` (*number*): Unique item instance ID.
* `itemTable` (*table*): Item configuration data.
* `size` (*number*): Icon size in pixels.

**Returns**

* `panel` (*Panel*): The created item icon panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create item icon
local itemIcon = vgui.Create("liaItemIcon")
itemIcon:setItem(itemID, itemData)
itemIcon:setSize(64, 64)

-- Create item icon with custom size
local largeIcon = vgui.Create("liaItemIcon")
largeIcon:setItem(itemID, itemData)
largeIcon:setSize(128, 128)
```

---

### liaGridInventory

**Purpose**

Grid-based inventory panel that organizes items in a structured layout with drag-and-drop support.

**When Called**

This panel is called when:
- Grid-based item organization is needed
- Visual inventory layout management is required
- Drag-and-drop inventory interactions are needed

**Parameters**

* `gridWidth` (*number*): Number of grid columns.
* `gridHeight` (*number*): Number of grid rows.
* `iconSize` (*number*): Size of each inventory slot.

**Returns**

* `panel` (*Panel*): The created grid inventory panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create 5x4 grid inventory
local gridInv = vgui.Create("liaGridInventory")
gridInv:setGridSize(5, 4, 64)
gridInv:setInventory(playerInventory)

-- Create larger grid with bigger icons
local largeGrid = vgui.Create("liaGridInventory")
largeGrid:setGridSize(8, 6, 80)
```

---

### liaGridInventoryPanel

**Purpose**

Advanced grid inventory panel with slot management and item placement validation.

**When Called**

This panel is called when:
- Complex inventory grid management is needed
- Item placement validation is required
- Advanced inventory slot interactions are needed

**Parameters**

* `inventory` (*table*): Inventory data to display.
* `gridWidth` (*number*): Grid width in slots.
* `gridHeight` (*number*): Grid height in slots.

**Returns**

* `panel` (*Panel*): The created grid inventory panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create advanced grid inventory
local gridPanel = vgui.Create("liaGridInventoryPanel")
gridPanel:setInventory(playerInventory)
gridPanel:setGridSize(6, 8)

-- Handle item placement
gridPanel.onItemPlaced = function(x, y, item)
    print("Item placed at " .. x .. "," .. y)
end
```

---

### liaItemList

**Purpose**

Displays items in a list format with sorting and filtering capabilities.

**When Called**

This panel is called when:
- Items need to be displayed in a list view
- Item sorting and filtering is required
- Tabular item display is needed

**Parameters**

* `items` (*table*): Array of items to display.
* `columns` (*table*): Column definitions for the list.
* `sortable` (*boolean*): Whether columns are sortable.

**Returns**

* `panel` (*Panel*): The created item list panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create item list with default columns
local itemList = vgui.Create("liaItemList")
itemList:setItems(playerItems)

-- Create custom column list
local customList = vgui.Create("liaItemList")
customList:setColumns({
    {name = "Name", width = 200},
    {name = "Type", width = 100},
    {name = "Value", width = 80}
})
customList:setItems(categorizedItems)
```

---

### liaItemSelector

**Purpose**

Provides item selection interface with list view and confirmation capabilities.

**When Called**

This panel is called when:
- Item selection dialogs are needed
- Multiple item selection is required
- Item selection with confirmation is needed

**Parameters**

* `items` (*table*): Items available for selection.
* `multiSelect` (*boolean*): Whether multiple selection is allowed.
* `onSelect` (*function*): Callback when items are selected.

**Returns**

* `panel` (*Panel*): The created item selector panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create single-item selector
local selector = vgui.Create("liaItemSelector")
selector:setItems(availableItems)
selector:setTitle("Select Item")
selector.onSelect = function(selectedItem)
    print("Selected: " .. selectedItem.name)
end

-- Create multi-item selector
local multiSelector = vgui.Create("liaItemSelector")
multiSelector:setItems(availableItems)
multiSelector:setMultiSelect(true)
multiSelector.onSelect = function(selectedItems)
    print("Selected " .. #selectedItems .. " items")
end
```

---

### liaGridInvItem

**Purpose**

Individual item component within grid inventory systems with drag-and-drop support.

**When Called**

This panel is called when:
- Individual items in grid layouts need special handling
- Custom item behavior in grids is required
- Grid-specific item interactions are needed

**Parameters**

* `item` (*table*): Item data for the grid item.
* `gridX` (*number*): Grid X position.
* `gridY` (*number*): Grid Y position.

**Returns**

* `panel` (*Panel*): The created grid item panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create grid item component
local gridItem = vgui.Create("liaGridInvItem")
gridItem:setItem(itemData)
gridItem:setGridPosition(2, 3)

-- Handle grid item interactions
gridItem.onDragStart = function()
    print("Started dragging grid item")
end
```

---

### liaItemIcon

**Purpose**

Displays item icons with visual representation, hover effects, and interaction handling.

**When Called**

This panel is called when:
- Item icons need to be displayed outside of inventories
- Custom item icon layouts are required
- Item visual representation is needed

**Parameters**

* `itemTable` (*table*): Item configuration data.
* `size` (*number*): Icon display size.
* `showTooltip` (*boolean*): Whether to show item tooltips.

**Returns**

* `panel` (*Panel*): The created item icon panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create basic item icon
local icon = vgui.Create("liaItemIcon")
icon:setItem(itemData)
icon:setSize(48, 48)

-- Create icon without tooltip
local silentIcon = vgui.Create("liaItemIcon")
silentIcon:setItem(itemData)
silentIcon:setShowTooltip(false)
```

---

### liaInventory

**Purpose**

Main inventory management interface with full item interaction capabilities.

**When Called**

This panel is called when:
- Complete inventory management is needed
- Item organization interfaces are required
- Advanced inventory features are needed

**Parameters**

* `inventory` (*table*): Player inventory data.
* `readOnly` (*boolean*): Whether inventory is read-only.
* `searchable` (*boolean*): Whether inventory has search functionality.

**Returns**

* `panel` (*Panel*): The created inventory panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create full inventory interface
local inventory = vgui.Create("liaInventory")
inventory:setInventory(playerInventory)
inventory:setSearchable(true)

-- Create read-only inventory
local readOnlyInv = vgui.Create("liaInventory")
readOnlyInv:setInventory(playerInventory)
readOnlyInv:setReadOnly(true)
```

---

### liaItemList

**Purpose**

Displays items in a structured list format with sorting and selection capabilities.

**When Called**

This panel is called when:
- Items need to be displayed in list format
- Sortable item lists are required
- Item selection from lists is needed

**Parameters**

* `items` (*table*): Items to display in the list.
* `columns` (*table*): Column configuration for the list.
* `onItemSelect` (*function*): Callback when items are selected.

**Returns**

* `panel` (*Panel*): The created item list panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create sortable item list
local itemList = vgui.Create("liaItemList")
itemList:setItems(playerItems)
itemList:setSortable(true)

-- Handle item selection
itemList.onItemSelect = function(item)
    print("Selected item: " .. item.name)
end
```
