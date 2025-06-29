# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `lia.item.get`

    
    Description:
    Retrieves an item definition by its identifier, checking both lia.item.base and lia.item.list.
    
    Parameters:
    identifier (string) – The unique identifier of the item.
    
    Returns:
    The item table if found, otherwise nil.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.get
    local itemDef = lia.item.get("testItem")

### `lia.item.getItemByID`

    
    Description:
    Retrieves an item instance by its numeric item ID. Also determines whether it's in an inventory
    or in the world.
    
    Parameters:
    itemID (number) – The numeric item ID.
    
    Returns:
    A table containing 'item' (the item object) and 'location' (the string location) if found,
    otherwise nil and an error message.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.getItemByID
    local result = lia.item.getItemByID(42)
    if result then
    print("Item location: " .. result.location)
    end

### `lia.item.getInstancedItemByID`

    
    Description:
    Retrieves the item instance table itself by its numeric ID without additional location info.
    
    Parameters:
    itemID (number) – The numeric item ID.
    
    Returns:
    The item instance table if found, otherwise nil and an error message.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.getInstancedItemByID
    local itemInstance = lia.item.getInstancedItemByID(42)
    if itemInstance then
    print("Got item: " .. itemInstance.name)
    end

### `lia.item.getItemDataByID`

    
    Description:
    Retrieves the 'data' table of an item instance by its numeric item ID.
    
    Parameters:
    itemID (number) – The numeric item ID.
    
    Returns:
    The data table if found, otherwise nil and an error message.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.getItemDataByID
    local data = lia.item.getItemDataByID(42)
    if data then
    print("Item data found.")
    end

### `lia.item.load`

    
    Description:
    Processes the item file path to generate a uniqueID, and calls lia.item.register
    to register the item. Used for loading items from directory structures.
    
    Parameters:
    path (string) – The path to the Lua file for the item.
    baseID (string) – The base item's uniqueID to inherit from.
    isBaseItem (boolean) – Whether this item is a base item.
    
    Returns:
    None
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.load
    lia.item.load("items/base/sh_item_base.lua", nil, true)

### `lia.item.isItem`

    
    Description:
    Checks if the given object is recognized as an item (via isItem flag).
    
    Parameters:
    object (any) – The object to check.
    
    Returns:
    true if the object is an item, false otherwise.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.isItem
    local result = lia.item.isItem(myObject)
    if result then
    print("It's an item!")
    end

### `lia.item.getInv`

    
    Description:
    Retrieves an inventory table by its ID from lia.item.inventories.
    
    Parameters:
    id (number) – The ID of the inventory to retrieve.
    
    Returns:
    The inventory table if found, otherwise nil.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.getInv
    local inv = lia.item.getInv(5)
    if inv then
    print("Got inventory with ID 5")
    end

### `lia.item.register`

    
    Description:
    Registers a new item or base item with a unique ID. This sets up the meta table
    and merges data from the specified base. Optionally includes the file if provided.
    
    Parameters:
    uniqueID (string) – The unique identifier for the item.
    baseID (string) – The unique identifier of the base item.
    isBaseItem (boolean) – Whether this should be registered as a base item.
    path (string) – The optional path to the item file for inclusion.
    luaGenerated (boolean) – True if the item is generated in code without file.
    
    Returns:
    The registered item table.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.register
    lia.item.register("special_item", "base_item", false, "path/to/item.lua")

### `lia.item.loadFromDir`

    
    Description:
    Loads item Lua files from a specified directory. Base items are loaded first,
    then any folders (with base_ prefix usage), and finally any loose Lua files.
    
    Parameters:
    directory (string) – The path to the directory containing item files.
    
    Returns:
    None
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.loadFromDir
    lia.item.loadFromDir("lilia/gamemode/items")

### `lia.item.new`

    
    Description:
    Creates an item instance (not in the database) from a registered item definition.
    The new item is stored in lia.item.instances using the provided item ID.
    
    Parameters:
    uniqueID (string) – The unique identifier of the item definition.
    id (number) – The numeric ID for this new item instance.
    
    Returns:
    The newly created item instance.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.new
    local newItem = lia.item.new("testItem", 101)
    print(newItem.id) -- 101

### `lia.item.registerInv`

    
    Description:
    Registers an inventory type with a given width and height. The inventory type
    becomes accessible for creation or usage in the system.
    
    Parameters:
    invType (string) – The inventory type name (identifier).
    w (number) – The width of this inventory type.
    h (number) – The height of this inventory type.
    
    Returns:
    None
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.registerInv
    lia.item.registerInv("smallInv", 4, 4)

### `lia.item.newInv`

    
    Description:
    Asynchronously creates a new inventory (with a specific invType) and associates it
    with the given character owner. Once created, it syncs the inventory to the owner if online.
    
    Parameters:
    owner (number) – The character ID who owns this inventory.
    invType (string) – The inventory type (must be registered first).
    callback (function) – Optional callback function receiving the new inventory.
    
    Returns:
    None (asynchronous, uses a deferred internally).
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.newInv
    lia.item.newInv(10, "smallInv", function(inventory)
    print("New inventory created:", inventory.id)
    end)

### `lia.item.createInv`

    
    Description:
    Creates a new GridInv instance with a specified width, height, and ID,
    then caches it in lia.inventory.instances.
    
    Parameters:
    w (number) – The width of the inventory.
    h (number) – The height of the inventory.
    id (number) – The numeric ID to assign to this inventory.
    
    Returns:
    The newly created GridInv instance.
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.createInv
    local inv = lia.item.createInv(6, 6, 200)
    print("Created inventory with ID:", inv.id)

### `lia.item.setItemDataByID`

    
    Description:
    Sets a specific key-value in the data table of an item instance by its numeric ID.
    Optionally notifies receivers about the change.
    
    Parameters:
    itemID (number) – The numeric item ID.
    key (string) – The data key to set.
    value (any) – The value to set for the specified key.
    receivers (table) – Optional table of players to receive the update.
    noSave (boolean) – If true, won't save the data to the database immediately.
    noCheckEntity (boolean) – If true, won't check if the item entity is valid.
    
    Returns:
    true if successful, false and error message if item not found.
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.setItemDataByID
    local success, err = lia.item.setItemDataByID(50, "durability", 90)
    if not success then
    print("Error:", err)
    end

### `lia.item.instance`

    
    Description:
    Asynchronously creates a new item in the database, optionally assigned to an inventory.
    Once the item is created, a new item object is constructed and returned via a deferred.
    
    Parameters:
    index (number) – The inventory ID to place the item into (or 0/NULL if none).
    uniqueID (string) – The item definition's unique ID.
    itemData (table) – The data table to store on the item.
    x (number) – Optional grid X position (for grid inventories).
    y (number) – Optional grid Y position.
    callback (function) – Optional callback with the newly created item.
    
    Returns:
    A deferred object that resolves to the new item.
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.instance
    lia.item.instance(1, "testItem", {someKey = "someValue"}):next(function(item)
    print("Item created with ID:", item.id)
    end)

### `lia.item.deleteByID`

    
    Description:
    Deletes an item from the system (database and memory) by its numeric ID.
    
    Parameters:
    id (number) – The numeric item ID to delete.
    
    Returns:
    None
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.deleteByID
    lia.item.deleteByID(42)

### `lia.item.loadItemByID`

    
    Description:
    Loads items from the database by a given ID or set of IDs, creating the corresponding
    item instances in memory. This is commonly used during inventory or character loading.
    
    Parameters:
    itemIndex (number or table) – Either a single numeric item ID or a table of numeric item IDs.
    
    Returns:
    None (asynchronous query).
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.loadItemByID
    lia.item.loadItemByID(42)
    -- or
    lia.item.loadItemByID({10, 11, 12})

### `lia.item.spawn`

    
    Description:
    Creates a new item instance (not in an inventory) and spawns a corresponding
    entity in the world at the specified position/angles.
    
    Parameters:
    uniqueID (string) – The unique ID of the item definition.
    position (Vector) – The spawn position in the world.
    callback (function) – Optional callback when the item and entity are created.
    angles (Angle) – Optional spawn angles.
    data (table) – Additional data to set on the item.
    
    Returns:
    A deferred object if callback is not given, otherwise none.
    
    Realm:
    Server
    
    Example Usage:
    -- Spawn an item and use a callback to access the spawned entity
    lia.item.spawn("testItem", Vector(0, 0, 0), function(item, ent)
    print("Spawned", item.uniqueID, "at", ent:GetPos())
    end)

### `lia.item.restoreInv`

    
    Description:
    Restores an existing inventory by loading it through lia.inventory.loadByID,
    then sets its width/height data, optionally providing a callback once loaded.
    
    Parameters:
    invID (number) – The inventory ID to restore.
    w (number) – Width to set for the inventory.
    h (number) – Height to set for the inventory.
    callback (function) – Optional function to call once the inventory is restored.
    
    Returns:
    None (asynchronous call).
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.item.restoreInv
    lia.item.restoreInv(101, 5, 5, function(inv)
    print("Restored inventory with ID 101.")
    end)
