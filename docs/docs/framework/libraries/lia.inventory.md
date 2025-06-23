# lia.inventory

---

Inventory manipulation and helper functions.

The `lia.inventory` library provides robust tools for managing character inventories within the Lilia Framework. It allows developers to create new inventory types, instantiate inventory instances, load and manage inventories from storage, and handle inventory-related operations both on the server and client sides. This library ensures that inventory systems are flexible, scalable, and seamlessly integrated into the broader framework, enhancing the gameplay experience by providing structured and efficient inventory management.

**NOTE:** Ensure that inventory types are uniquely defined and that all required fields are correctly set to prevent conflicts and maintain data integrity. Proper management of server and client realms is crucial for synchronized inventory operations.

---

### **lia.inventory.newType**

**Description:**  
Creates a new inventory type by defining its unique identifier and structure. This function registers the inventory type within the framework, allowing for the instantiation and management of inventories based on the defined type.

**Realm:**  
`Shared`

**Parameters:**  

- `typeID` (`string`):  
  The unique identifier for the new inventory type.

- `invTypeStruct` (`table`):  
  The structure defining the behavior and configuration of the new inventory type. It must adhere to the `InvTypeStructType` structure, ensuring all required fields are present and correctly typed.

**Example Usage:**
```lua
-- Define a new inventory type "backpack" with specific configurations
lia.inventory.newType("backpack", {
    add = function(self, item) 
        table.insert(self.items, item) 
    end,
    remove = function(self, itemID)
        for index, item in ipairs(self.items) do
            if item.id == itemID then
                table.remove(self.items, index)
                break
            end
        end
    end,
    sync = function(self)
        -- Sync inventory with the client
    end,
    typeID = "backpack",
    className = "BackpackInventory"
})
```

---

### **lia.inventory.new**

**Description:**  
Creates a new inventory instance of the specified type. This function initializes the inventory with default settings and prepares it for use within the framework.

**Realm:**  
`Shared`

**Parameters:**  

- `typeID` (`string`):  
  The unique identifier for the type of inventory to create.

**Returns:**  
`Inventory`  
A new instance of the specified inventory type.

**Example Usage:**
```lua
-- Create a new backpack inventory
local backpack = lia.inventory.new("backpack")
backpack:add({id = 1, name = "Health Potion"})
```

---

### **lia.inventory.loadByID**

**Description:**  
Loads an inventory instance by its ID from the cache or default storage if not cached. This function ensures that inventories are efficiently retrieved and instantiated, minimizing database queries by utilizing cached instances when available.

**Realm:**  
`Server`

**Parameters:**  

- `id` (`number`):  
  The ID of the inventory to load.

- `noCache` (`bool`, optional, default `false`):  
  If set to `true`, forces the function to load the inventory from storage even if it is already cached.

**Returns:**  
`Deferred`  
A deferred object that resolves with the loaded inventory instance or `nil` if not found.

**Example Usage:**
```lua
-- Load inventory with ID 5
lia.inventory.loadByID(5):next(function(inventory)
    if inventory then
        print("Inventory loaded:", inventory.id)
    else
        print("Inventory not found.")
    end
end)
```

---

### **lia.inventory.loadFromDefaultStorage**

**Description:**  
Loads an inventory instance from the default storage system. This function is used when no specific storage handler is defined for an inventory type, ensuring that inventories are still accessible even without custom storage implementations.

**Realm:**  
`Server`

**Parameters:**  

- `id` (`number`):  
  The ID of the inventory to load.

- `noCache` (`bool`, optional, default `false`):  
  If set to `true`, forces the function to load the inventory from storage even if it is already cached.

**Returns:**  
`Deferred`  
A deferred object that resolves with the loaded inventory instance or `nil` if not found.

**Example Usage:**
```lua
-- Load inventory with ID 10 from default storage
lia.inventory.loadFromDefaultStorage(10):next(function(inventory)
    if inventory then
        print("Inventory loaded from default storage:", inventory.id)
    else
        print("Inventory not found in default storage.")
    end
end)
```

---

### **lia.inventory.instance**

**Description:**  
Creates and initializes a new inventory instance based on the specified type ID and initial data. This function registers the new inventory within the framework, associating it with a unique ID and preparing it for use.

**Realm:**  
`Server`

**Parameters:**  

- `typeID` (`string`):  
  The ID of the inventory type.

- `initialData` (`table`, optional):  
  Initial data to be assigned to the inventory upon creation.

**Returns:**  
`Deferred`  
A deferred object that resolves with the created inventory instance.

**Example Usage:**
```lua
-- Create a new weapon inventory with initial data
lia.inventory.instance("weapon", {char = 2}):next(function(inventory)
    print("New inventory created with ID:", inventory.id)
end)
```

---

### **lia.inventory.loadAllFromCharID**

**Description:**  
Loads all inventory instances associated with a specific character ID. This function is useful for initializing a character's inventories when they log in or spawn into the game.

**Realm:**  
`Server`

**Parameters:**  

- `charID` (`number`):  
  The character ID for which to load inventory instances.

**Returns:**  
`Deferred`  
A deferred object that resolves with an array of loaded inventory instances.

**Example Usage:**
```lua
-- Load all inventories for character ID 3
lia.inventory.loadAllFromCharID(3):next(function(inventories)
    for _, inventory in ipairs(inventories) do
        print("Loaded inventory ID:", inventory.id)
    end
end)
```

---

### **lia.inventory.deleteByID**

**Description:**  
Deletes an inventory instance by its ID from both the database and the cache. This function ensures that inventories are properly removed, freeing up resources and maintaining database integrity.

**Realm:**  
`Server`

**Parameters:**  

- `id` (`number`):  
  The ID of the inventory to delete.

**Example Usage:**
```lua
-- Delete inventory with ID 7
lia.inventory.deleteByID(7)
print("Inventory 7 has been deleted.")
```

---

### **lia.inventory.cleanUpForCharacter**

**Description:**  
Cleans up all inventory instances associated with a specific character. This function is typically called when a character is deleted or removed from the game, ensuring that all related inventories are properly disposed of.

**Realm:**  
`Server`

**Parameters:**  

- `character` (`Character`):  
  The character for which to clean up inventory instances.

**Example Usage:**
```lua
-- Clean up inventories for a character
lia.inventory.cleanUpForCharacter(playerCharacter)
print("All inventories for the character have been cleaned up.")
```

---

### **lia.inventory.show**

**Description:**  
Displays the graphical representation of an inventory. This function creates a user interface panel that visually represents the inventory's contents, allowing players to interact with their items.

**Realm:**  
`Client`

**Parameters:**  

- `inventory` (`Inventory`):  
  The inventory to display.

- `parent` (`Panel`):  
  The parent panel to which the inventory panel will be attached.

**Returns:**  
`Panel`  
The panel displaying the inventory.

**Example Usage:**
```lua
-- Show the player's backpack inventory
local backpack = player:getChar():getInv("backpack")
if backpack then
    lia.inventory.show(backpack, someParentPanel)
end
```

---

## Variables

### **lia.inventory.types**

**Description:**  
A table that stores all registered inventory types. Each key is the inventory type ID, and the value is the structure defining the inventory's behavior and configuration. This allows for easy retrieval and instantiation of inventories based on their type.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Retrieve the "backpack" inventory type
local backpackType = lia.inventory.types["backpack"]
print("Backpack Config:", backpackType.config)
```

---

### **lia.inventory.instances**

**Description:**  
A table that maps inventory IDs to their corresponding inventory instances. This cache allows for efficient access to inventories without repeatedly querying the database, enhancing performance and reducing latency.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Access inventory instance with ID 4
local inventory = lia.inventory.instances[4]
if inventory then
    print("Inventory ID 4 has", #inventory.items, "items.")
end
```