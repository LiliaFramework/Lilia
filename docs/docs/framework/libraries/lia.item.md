# lia.item

---

Inventory manipulation and helper functions.

The `lia.item` library provides comprehensive tools for managing items within the Lilia Framework. It allows developers to create, retrieve, and manipulate items, handle inventory interactions, and manage item instances efficiently. This library ensures that items are consistently managed on a per-character basis, enhancing both gameplay mechanics and administrative control.

---
## Functions

### **lia.item.get**

**Description:**  
Retrieves an item table based on its unique identifier. This function allows access to all properties and methods associated with a specific item.

**Realm:**  
`Shared`

**Parameters:**  

- `identifier` (`string`):  
  Unique ID of the item.

**Returns:**  
`table|nil` - The item table if found, otherwise `nil`.

**Example Usage:**
```lua
local item = lia.item.get("health_potion")
if item then
    print("Item Name:", item.name)
end
```

---

### **lia.item.getItemByID**

**Description:**  
Retrieves an item instance by its ID and determines its current location (e.g., inventory, world).

**Realm:**  
`Shared`

**Parameters:**  

- `itemID` (`number`):  
  The ID of the item instance.

**Returns:**  
`table|nil, string|nil` - Returns a table containing the item instance and its location if found, otherwise `nil` and an error message.

**Example Usage:**
```lua
local itemInfo, location = lia.item.getItemByID(42)
if itemInfo then
    print("Item Location:", location)
    print("Item Name:", itemInfo.item.name)
else
    print("Error:", location)
end
```

---

### **lia.item.getInstancedItemByID**

**Description:**  
Retrieves an instanced item by its ID.

**Realm:**  
`Shared`

**Parameters:**  

- `itemID` (`number`):  
  The ID of the item instance.

**Returns:**  
`table|nil, string|nil` - Returns the item instance if found, otherwise `nil` and an error message.

**Example Usage:**
```lua
local item, err = lia.item.getInstancedItemByID(42)
if item then
    print("Instanced Item Name:", item.name)
else
    print("Error:", err)
end
```

---

### **lia.item.getItemDataByID**

**Description:**  
Retrieves an item's data by its ID.

**Realm:**  
`Shared`

**Parameters:**  

- `itemID` (`number`):  
  The ID of the item instance.

**Returns:**  
`table|nil, string|nil` - Returns the item's data table if found, otherwise `nil` and an error message.

**Example Usage:**
```lua
local data, err = lia.item.getItemDataByID(42)
if data then
    print("Item Data:", data.description)
else
    print("Error:", err)
end
```

---

### **lia.item.load**

**Description:**  
Loads an item from a Lua file. It registers the item within the framework, ensuring it adheres to the defined structure and base type.

**Realm:**  
`Shared`

**Parameters:**  

- `path` (`string`):  
  The path to the Lua file.

- `baseID` (`string`):  
  The base ID of the item.

- `isBaseItem` (`bool`):  
  Indicates whether the item is a base item.

**Example Usage:**
```lua
-- Load a base item
lia.item.load("path/to/sh_base_medkit.lua", nil, true)

-- Load a derived item
lia.item.load("path/to/sh_health_potion.lua", "base_medkit", false)
```

---

### **lia.item.isItem**

**Description:**  
Checks if a given object is recognized as an item within the framework.

**Realm:**  
`Shared`

**Parameters:**  

- `object` (`table`):  
  The object to check.

**Returns:**  
`bool` - `true` if the object is an item, `false` otherwise.

**Example Usage:**
```lua
local obj = someObject
if lia.item.isItem(obj) then
    print("Object is a valid item.")
else
    print("Object is not an item.")
end
```

---

### **lia.item.register**

**Description:**  
Registers a new item within the framework. This function ensures that the item is properly integrated, adhering to its base type and defined structure.

**Realm:**  
`Shared`

**Parameters:**  

- `uniqueID` (`string`):  
  The unique ID of the item.

- `baseID` (`string`):  
  The base ID of the item.

- `isBaseItem` (`bool`):  
  Indicates if the item is a base item.

- `path` (`string`):  
  The file path of the item.

- `luaGenerated` (`bool`):  
  Indicates if the item is Lua-generated.

**Returns:**  
`table` - The registered item table.

**Example Usage:**
```lua
-- Register a new item
local newItem = lia.item.register("health_potion", "base_medkit", false, "path/to/sh_health_potion.lua")
print("Registered Item:", newItem.name)
```

---

### **lia.item.loadFromDir**

**Description:**  
Loads items from a specified directory. It first loads base items, then derived items, ensuring that all items are registered correctly.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`):  
  The directory path containing the item Lua files.

**Example Usage:**
```lua
-- Load all items from the items directory
lia.item.loadFromDir("lilia/gamemode/items")
```

---

### **lia.item.new**

**Description:**  
Creates a new item instance based on its unique ID and assigns it a specific ID within the framework.

**Realm:**  
`Shared`

**Parameters:**  

- `uniqueID` (`string`):  
  The unique ID of the item.

- `id` (`number`):  
  The ID of the item instance.

**Returns:**  
`table` - The new item instance.

**Example Usage:**
```lua
-- Create a new item instance
local item = lia.item.new("health_potion", 101)
print("New Item ID:", item.id)
```

---

### **lia.item.registerInv**

**Description:**  
Registers a new inventory type with specified dimensions. This function extends the `GridInv` metatable to include custom inventory types.

**Realm:**  
`Shared`

**Parameters:**  

- `invType` (`string`):  
  The inventory type identifier.

- `w` (`number`):  
  The width of the inventory.

- `h` (`number`):  
  The height of the inventory.

**Example Usage:**
```lua
-- Register a new inventory type "backpack" with dimensions 4x4
lia.item.registerInv("backpack", 4, 4)
```

---

### **lia.item.newInv**

**Description:**  
Creates a new inventory instance for a specified owner and inventory type. This function initializes the inventory and syncs it with the owner if applicable.

**Realm:**  
`Shared`

**Parameters:**  

- `owner` (`number`):  
  The owner (character ID) of the inventory.

- `invType` (`string`):  
  The inventory type identifier.

- `callback` (`function`):  
  The callback function to execute after the inventory is created.

**Example Usage:**
```lua
-- Create a new backpack inventory for character ID 5
lia.item.newInv(5, "backpack", function(inventory)
    print("New Backpack Inventory Created with ID:", inventory.id)
end)
```

---

### **lia.item.getInv**

**Description:**  
Retrieves an inventory by its ID.

**Realm:**  
`Shared`

**Parameters:**  

- `invID` (`number`):  
  The ID of the inventory.

**Returns:**  
`table|nil` - The inventory object if found, otherwise `nil`.

**Example Usage:**
```lua
local inventory = lia.item.getInv(10)
if inventory then
    print("Inventory Type:", inventory.invType)
end
```

---

### **lia.item.createInv**

**Description:**  
Creates a new inventory instance with specified dimensions and assigns it a unique ID.

**Realm:**  
`Shared`

**Parameters:**  

- `w` (`number`):  
  The width of the inventory.

- `h` (`number`):  
  The height of the inventory.

- `id` (`number`):  
  The unique ID to assign to the inventory.

**Returns:**  
`table` - The new inventory instance.

**Example Usage:**
```lua
-- Create a new 5x5 inventory with ID 20
local newInventory = lia.item.createInv(5, 5, 20)
print("Created Inventory ID:", newInventory.id)
```

---

### **lia.item.setItemDataByID** *(Server Only)*

**Description:**  
Sets the data of an item by its ID. This function updates specific data fields of an item and optionally notifies receivers or skips saving to the database.

**Realm:**  
`Server`

**Parameters:**  

- `itemID` (`number`):  
  The ID of the item instance.

- `key` (`string`):  
  The data key to set.

- `value` (`any`):  
  The value to assign to the data key.

- `receivers` (`table`, optional):  
  A table of receivers for network updates.

- `noSave` (`bool`, optional):  
  If `true`, skips saving the data to the database.

- `noCheckEntity` (`bool`, optional):  
  If `true`, skips entity checks.

**Returns:**  
`bool, string|nil` - `true` if successful, otherwise `false` and an error message.

**Example Usage:**
```lua
-- Set the "description" data field of item ID 42
local success, err = lia.item.setItemDataByID(42, "description", "A shiny health potion.")
if success then
    print("Item data updated successfully.")
else
    print("Error updating item data:", err)
end
```

---

### **lia.item.instance** *(Server Only)*

**Description:**  
Instantiates an item and adds it to an inventory. This function handles the creation of item instances, assigns them to inventories, and manages their placement within the inventory grid.

**Realm:**  
`Server`

**Parameters:**  

- `index` (`number|string`):  
  The inventory index or unique ID.

- `uniqueID` (`string`):  
  The unique ID of the item.

- `itemData` (`table`):  
  The item data.

- `x` (`number`):  
  The x-coordinate within the inventory grid.

- `y` (`number`):  
  The y-coordinate within the inventory grid.

- `callback` (`function`):  
  The callback function to execute after instantiation.

**Returns:**  
`table` - A deferred promise that resolves with the instantiated item.

**Example Usage:**
```lua
-- Instantiate a health potion in inventory ID 5 at position (2,3)
lia.item.instance(5, "health_potion", {quantity = 10}, 2, 3, function(item)
    print("Instantiated Item ID:", item.id)
end)
```

---

### **lia.item.deleteByID** *(Server Only)*

**Description:**  
Deletes an item by its ID from both the database and the cache. This function ensures that items are properly removed, freeing up resources and maintaining database integrity.

**Realm:**  
`Server`

**Parameters:**  

- `id` (`number`):  
  The ID of the item to delete.

**Example Usage:**
```lua
-- Delete item with ID 15
lia.item.deleteByID(15)
print("Item 15 has been deleted.")
```

---

### **lia.item.loadItemByID** *(Server Only)*

**Description:**  
Loads an item by its ID from the database and instantiates it within the framework. This function is used to restore items that exist in the database but are not currently loaded into memory.

**Realm:**  
`Server`

**Parameters:**  

- `itemIndex` (`number|table`):  
  The item ID or a table of item IDs to load.

**Example Usage:**
```lua
-- Load a single item by ID
lia.item.loadItemByID(42)

-- Load multiple items by IDs
lia.item.loadItemByID({43, 44, 45})
```

---

### **lia.item.spawn** *(Server Only)*

**Description:**  
Instances and spawns a given item type in the game world. This function creates an item instance, assigns it to a position and angle in the world, and optionally executes a callback upon creation.

**Realm:**  
`Server`

**Parameters:**  

- `uniqueID` (`string`):  
  Unique ID of the item.

- `position` (`Vector`):  
  The position where the item's entity will be spawned.

- `callback` (`function`, optional):  
  Function to call when the item entity is created.

- `angles` (`Angle`, optional, default `Angle(0,0,0)`):  
  The angles at which the item's entity will spawn.

- `data` (`table`, optional):  
  Additional data for this item instance.

**Returns:**  
`table` - A deferred promise that resolves with the spawned item and its entity.

**Example Usage:**
```lua
-- Spawn a health potion at a specific position
lia.item.spawn("health_potion", Vector(0, 0, 100), function(item, entity)
    print("Spawned Item ID:", item.id, "at Entity:", entity)
end, Angle(0, 0, 0), {quantity = 5})
```

---

### **lia.item.restoreInv** *(Server Only)*

**Description:**  
Restores an inventory with specified dimensions. This function is used to reset or modify the dimensions of an existing inventory, ensuring that it aligns with the desired configuration.

**Realm:**  
`Server`

**Parameters:**  

- `invID` (`number`):  
  The ID of the inventory to restore.

- `w` (`number`):  
  The new width of the inventory.

- `h` (`number`):  
  The new height of the inventory.

- `callback` (`function`):  
  The callback function to execute after restoration.

**Example Usage:**
```lua
-- Restore inventory ID 10 to dimensions 6x6
lia.item.restoreInv(10, 6, 6, function(inventory)
    print("Inventory 10 has been restored to 6x6.")
end)
```

---

## Variables

### **lia.item.list**

**Description:**  
A table that stores all registered items. Each key is the item's unique identifier, and the value is the item's definition table. This allows for easy retrieval and management of items based on their unique IDs.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access the "health_potion" item
local healthPotion = lia.item.list["health_potion"]
print("Health Potion Description:", healthPotion.desc)
```

---

### **lia.item.base**

**Description:**  
A table that stores base item definitions. Base items serve as templates for derived items, providing common properties and functionalities that can be extended or overridden.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access the base_medkit item
local baseMedkit = lia.item.base["base_medkit"]
print("Base Medkit Description:", baseMedkit.desc)
```

---

### **lia.item.instances**

**Description:**  
A table that maps item IDs to their corresponding item instances. This cache allows for efficient access to items without repeatedly querying the database, enhancing performance and reducing latency.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access item instance with ID 42
local item = lia.item.instances[42]
if item then
    print("Item ID 42:", item.name)
end
```

---

### **lia.item.inventories**

**Description:**  
A reference to `lia.inventory.instances`, linking item inventories to their corresponding instances. This association facilitates efficient inventory management and item placement within inventories.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access all inventory instances
for invID, inventory in pairs(lia.item.inventories) do
    print("Inventory ID:", invID, "Type:", inventory.invType)
end
```

---

### **lia.item.inventoryTypes**

**Description:**  
A table that stores all registered inventory types related to items. Each key is the inventory type identifier, and the value contains configuration and behavior definitions for that inventory type.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access the "backpack" inventory type
local backpackType = lia.item.inventoryTypes["backpack"]
print("Backpack Inventory Width:", backpackType:getWidth())
```

--