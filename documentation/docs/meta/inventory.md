# Inventory Meta

Documentation extracted from inventory.lua comments.

### getData


Purpose:
    Retrieves the value associated with the given key from the inventory's data table.
    If the key does not exist, returns the provided default value.

Parameters:
    key (string) - The key to look up in the data table.
    default (any) - The value to return if the key does not exist.

Returns:
    any - The value associated with the key, or the default value if not found.

Realm:
    Shared.

Example Usage:
    local value = inventory:getData("weight", 0)

---

### extend


Purpose:
    Creates a subclass of the Inventory with the specified class name.

Parameters:
    className (string) - The name of the subclass to create.

Returns:
    table - The new subclass table.

Realm:
    Shared.

Example Usage:
    local MyInventory = Inventory:extend("MyInventory")

---

### configure


Purpose:
    Configures the inventory type.
    This is a hook method intended to be overridden by subclasses to implement custom configuration logic.

Parameters:
    None.

Returns:
    None.

Realm:
    Shared.

Example Usage:
    function MyInventory:configure()
        -- custom configuration
    end

---

### addDataProxy


Purpose:
    Adds a proxy function to be called when the specified data key changes.

Parameters:
    key (string) - The data key to watch.
    onChange (function) - The function to call when the data changes.

Returns:
    None.

Realm:
    Shared.

Example Usage:
    inventory:addDataProxy("weight", function(old, new) print(old, new) end)

---

### getItemsByUniqueID


Purpose:
    Returns a table of items in the inventory that match the given uniqueID.

Parameters:
    uniqueID (string) - The uniqueID of the items to find.
    onlyMain (boolean) - If true, only search the main inventory.

Returns:
    table - A table of matching items.

Realm:
    Shared.

Example Usage:
    local medkits = inventory:getItemsByUniqueID("medkit")

---

### register


Purpose:
    Registers a new inventory type with the given typeID.

Parameters:
    typeID (string) - The unique identifier for this inventory type.

Returns:
    None.

Realm:
    Shared.

Example Usage:
    Inventory:register("my_inventory_type")

---

### new


Purpose:
    Creates a new instance of this inventory type.

Parameters:
    None.

Returns:
    table - The new inventory instance.

Realm:
    Shared.

Example Usage:
    local inv = Inventory:new()

---

### tostring


Purpose:
    Returns a string representation of the inventory.

Parameters:
    None.

Returns:
    string - The string representation.

Realm:
    Shared.

Example Usage:
    print(inventory:tostring())

---

### getType


Purpose:
    Retrieves the inventory type table for this inventory.

Parameters:
    None.

Returns:
    table - The inventory type table.

Realm:
    Shared.

Example Usage:
    local typeTable = inventory:getType()

---

### onDataChanged


Purpose:
    Called when a data key changes value. Invokes any registered proxies.

Parameters:
    key (string) - The data key that changed.
    oldValue (any) - The old value.
    newValue (any) - The new value.

Returns:
    None.

Realm:
    Shared.

Example Usage:
    inventory:onDataChanged("weight", 10, 15)

---

### getItems


Purpose:
    Returns the table of items in this inventory.

Parameters:
    None.

Returns:
    table - The items table.

Realm:
    Shared.

Example Usage:
    local items = inventory:getItems()

---

### getItemsOfType


Purpose:
    Returns a table of items in the inventory that match the given itemType (uniqueID).

Parameters:
    itemType (string) - The uniqueID of the items to find.

Returns:
    table - A table of matching items.

Realm:
    Shared.

Example Usage:
    local bandages = inventory:getItemsOfType("bandage")

---

### getFirstItemOfType


Purpose:
    Returns the first item in the inventory that matches the given itemType (uniqueID).

Parameters:
    itemType (string) - The uniqueID of the item to find.

Returns:
    table|none - The first matching item, or nil if not found.

Realm:
    Shared.

Example Usage:
    local medkit = inventory:getFirstItemOfType("medkit")

---

### hasItem


Purpose:
    Checks if the inventory contains at least one item of the given itemType (uniqueID).

Parameters:
    itemType (string) - The uniqueID of the item to check for.

Returns:
    boolean - True if at least one item is found, false otherwise.

Realm:
    Shared.

Example Usage:
    if inventory:hasItem("keycard") then ...

---

### getItemCount


Purpose:
    Returns the total quantity of items in the inventory, optionally filtered by itemType.

Parameters:
    itemType (string|none) - The uniqueID of the item to count, or nil to count all items.

Returns:
    number - The total quantity.

Realm:
    Shared.

Example Usage:
    local count = inventory:getItemCount("ammo_9mm")

---

### getID


Purpose:
    Returns the unique ID of this inventory.

Parameters:
    None.

Returns:
    number - The inventory ID.

Realm:
    Shared.

Example Usage:
    local id = inventory:getID()

---

### eq


Purpose:
    Checks if this inventory is equal to another by comparing their IDs.

Parameters:
    other (Inventory) - The other inventory to compare.

Returns:
    boolean - True if the IDs match, false otherwise.

Realm:
    Shared.

Example Usage:
    if inventory:eq(otherInventory) then ...

---

### addItem


Purpose:
    Adds an item to the inventory and updates the database.

Parameters:
    item (Item) - The item to add.
    noReplicate (boolean) - If true, do not replicate to clients.

Returns:
    Inventory - The inventory instance.

Realm:
    Server.

Example Usage:
    inventory:addItem(item)

---

### add


Purpose:
    Adds an item to the inventory (alias for addItem).

Parameters:
    item (Item) - The item to add.

Returns:
    Inventory - The inventory instance.

Realm:
    Server.

Example Usage:
    inventory:add(item)

---

### syncItemAdded


Purpose:
    Synchronizes the addition of an item to all relevant clients.

Parameters:
    item (Item) - The item that was added.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:syncItemAdded(item)

---

### initializeStorage


Purpose:
    Initializes persistent storage for the inventory and its initial data.

Parameters:
    initialData (table) - The initial data to store.

Returns:
    deferred - A deferred object resolved with the new inventory ID.

Realm:
    Server.

Example Usage:
    inventory:initializeStorage({char = 1, weight = 10})

---

### restoreFromStorage


Purpose:
    Restores the inventory from persistent storage.
    This is a hook method intended to be overridden by subclasses to implement custom restoration logic.

Parameters:
    None.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:restoreFromStorage()

---

### removeItem


Purpose:
    Removes an item from the inventory and updates the database.

Parameters:
    itemID (number) - The ID of the item to remove.
    preserveItem (boolean) - If true, do not delete the item from the database.

Returns:
    deferred - A deferred object resolved when removal is complete.

Realm:
    Server.

Example Usage:
    inventory:removeItem(123)

---

### remove


Purpose:
    Removes an item from the inventory (alias for removeItem).

Parameters:
    itemID (number) - The ID of the item to remove.

Returns:
    deferred - A deferred object resolved when removal is complete.

Realm:
    Server.

Example Usage:
    inventory:remove(123)

---

### setData


Purpose:
    Sets a data key to a value, updates the database (if persistent), synchronizes the change to clients, and triggers any registered data proxies.
    Special handling for the "char" key updates the character's inventory association.

Parameters:
    key (string) - The data key to set.
    value (any) - The value to set.

Returns:
    Inventory - The inventory instance.

Realm:
    Server.

Example Usage:
    inventory:setData("weight", 20)

---

### canAccess


Purpose:
    Checks if an action can be performed on this inventory, using access rules.

Parameters:
    action (string) - The action to check (e.g., "repl").
    context (table) - Additional context for the check.

Returns:
    booleannone, string|none - True/false and optional reason, or nil if no rule applies.

Realm:
    Server.

Example Usage:
    local can, reason = inventory:canAccess("repl", {client = ply})

---

### addAccessRule


Purpose:
    Adds an access rule to the inventory.

Parameters:
    rule (function) - The rule function to add.
    priority (number|none) - The position to insert the rule at.

Returns:
    Inventory - The inventory instance.

Realm:
    Server.

Example Usage:
    inventory:addAccessRule(myRule, 1)

---

### removeAccessRule


Purpose:
    Removes an access rule from the inventory.

Parameters:
    rule (function) - The rule function to remove.

Returns:
    Inventory - The inventory instance.

Realm:
    Server.

Example Usage:
    inventory:removeAccessRule(myRule)

---

### getRecipients


Purpose:
    Returns a table of clients who can receive inventory updates.

Parameters:
    None.

Returns:
    table - A table of player objects.

Realm:
    Server.

Example Usage:
    local recipients = inventory:getRecipients()

---

### onInstanced


Purpose:
    Called when the inventory is instanced.
    This is a hook method intended to be overridden by subclasses to implement custom initialization logic.

Parameters:
    None.

Returns:
    None.

Realm:
    Server.

Example Usage:
    function Inventory:onInstanced() ... end

---

### onLoaded


Purpose:
    Called when the inventory is loaded.
    This is a hook method intended to be overridden by subclasses to implement custom loading logic.

Parameters:
    None.

Returns:
    None.

Realm:
    Server.

Example Usage:
    function Inventory:onLoaded() ... end

---

### loadItems


Purpose:
    Loads all items for this inventory from the database.

Parameters:
    None.

Returns:
    deferred - A deferred object resolved with the items table.

Realm:
    Server.

Example Usage:
    inventory:loadItems():next(function(items) ... end)

---

### onItemsLoaded


Purpose:
    Called after items are loaded from the database.
    This is a hook method intended to be overridden by subclasses to implement custom item loading logic.

Parameters:
    items (table) - The loaded items.

Returns:
    None.

Realm:
    Server.

Example Usage:
    function Inventory:onItemsLoaded(items) ... end

---

### instance


Purpose:
    Creates a new inventory instance with the given initial data.

Parameters:
    initialData (table) - The initial data for the inventory.

Returns:
    Inventory - The new inventory instance.

Realm:
    Server.

Example Usage:
    local inv = Inventory:instance({char = 1})

---

### syncData


Purpose:
    Synchronizes a data key to clients.

Parameters:
    key (string) - The data key to sync.
    recipients (table|none) - The clients to send to, or nil for all recipients.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:syncData("weight")

---

### sync


Purpose:
    Synchronizes the entire inventory to clients.

Parameters:
    recipients (table|none) - The clients to send to, or nil for all recipients.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:sync()

---

### delete


Purpose:
    Deletes the inventory from the system.

Parameters:
    None.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:delete()

---

### destroy


Purpose:
    Destroys the inventory and all its items, and notifies clients.

Parameters:
    None.

Returns:
    None.

Realm:
    Server.

Example Usage:
    inventory:destroy()

---

### show


Purpose:
    Displays the inventory to the player.

Parameters:
    parent (panel|none) - The parent panel to attach to.

Returns:
    Panel - The inventory UI panel.

Realm:
    Client.

Example Usage:
    inventory:show()

---
