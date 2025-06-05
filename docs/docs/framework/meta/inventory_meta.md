---

Holds items within a grid layout.

Inventories are objects that contain `Item`s in a grid layout. Every `Character` will have exactly one inventory attached to it, which is the only inventory that is allowed to hold bags—any item that has its own inventory (i.e., a suitcase). Inventories can be owned by a character, or they can be individually interacted with as standalone objects. For example, the container plugin attaches inventories to props, allowing for items to be stored outside of any character inventories and remain "in the world".

---

## **inventoryMeta:getData**

**Description**

Retrieves data associated with a specified key from the inventory.

**Realm**

`Shared`

**Parameters**

- **key** (`String`): The key for the data.
- **default** (`any`, optional): The default value to return if the key does not exist.

**Returns**

- **any**: The value associated with the key, or the default value if the key does not exist.

**Example**

```lua
local health = inventory:getData("health", 100)
print("Health:", health)
```

---

## **inventoryMeta:extend**

**Description**

Extends the inventory to create a subclass with a specified class name.

**Realm**

`Shared`

**Parameters**

- **className** (`String`): The name of the subclass.

**Returns**

- **Table**: A subclass of the `Inventory` class.

**Example**

```lua
local GridInventory = Inventory:extend("GridInv")
```

---

## **inventoryMeta:configure**

**Description**

Configures the inventory.

This function is meant to be overridden in subclasses to define specific configurations.

**Realm**

`Shared`

**Example**

```lua
function GridInventory:configure()
    -- Custom configuration
end
```

---

## **inventoryMeta:addDataProxy**

**Description**

Adds a data proxy to the inventory for a specified key.

**Realm**

`Shared`

**Parameters**

- **key** (`any`): The key for the data proxy.
- **onChange** (`function`): The function to call when the data associated with the key changes.

**Example**

```lua
inventory:addDataProxy("health", function(old, new)
    print("Health changed from", old, "to", new)
end)
```

---

## **inventoryMeta:getItemsByUniqueID**

**Description**

Retrieves items with a specified unique ID from the inventory.

**Realm**

`Shared`

**Parameters**

- **uniqueID** (`String`): The unique ID of the items to retrieve.
- **onlyMain** (`Boolean`): Whether to retrieve only main items.

**Returns**

- **Table**: An array containing the items with the specified unique ID.

**Example**

```lua
local weapons = inventory:getItemsByUniqueID("weapon_rifle")
for _, weapon in ipairs(weapons) do
    print("Weapon ID:", weapon:getID())
end
```

---

## **inventoryMeta:register**

**Description**

Registers the inventory with a specified type ID.

**Note:** This method sets the inventory's type and configures it accordingly.

**Realm**

`Shared`

**Parameters**

- **typeID** (`String`): The type ID to register the inventory with.

**Example**

```lua
inventory:register("GridInv")
-- This sets the inventory's type to 'grid'
```

---

## **inventoryMeta:new**

**Description**

Creates a new instance of the inventory.

**Realm**

`Shared`

**Returns**

- **Table**: A new instance of the `Inventory` class.

**Example**

```lua
local newInventory = Inventory:new()
```

---

## **inventoryMeta:tostring**

**Description**

Returns a string representation of the inventory.

**Realm**

`Shared`

**Returns**

- **String**: A string representation of the inventory, including its class name and ID.

**Example**

```lua
print(tostring(inventory))
-- Output: "GridInv[123]"
```

---

## **inventoryMeta:getType**

**Description**

Retrieves the type of the inventory.

**Realm**

`Shared`

**Returns**

- **Table**: The type information of the inventory.

**Example**

```lua
local typeInfo = inventory:getType()
print("Inventory Type:", typeInfo.typeID)
```

---

## **inventoryMeta:onDataChanged**

**Description**

Callback function called when data associated with a key changes.

**Realm**

`Shared`

**Parameters**

- **key** (`any`): The key whose data has changed.
- **oldValue** (`any`): The old value of the data.
- **newValue** (`any`): The new value of the data.

**Example**

```lua
function Inventory:onDataChanged(key, oldValue, newValue)
    print(key, "changed from", oldValue, "to", newValue)
end
```

---

## **inventoryMeta:getItems**

**Description**

Retrieves all items in the inventory.

**Realm**

`Shared`

**Returns**

- **Table**: An array containing all items in the inventory.

**Example**

```lua
local items = inventory:getItems()
for _, item in ipairs(items) do
    print("Item ID:", item:getID())
end
```

---

## **inventoryMeta:getItemsOfType**

**Description**

Retrieves items of a specific type from the inventory.

**Realm**

`Shared`

**Parameters**

- **itemType** (`String`): The type of items to retrieve.

**Returns**

- **Table**: An array containing items of the specified type.

**Example**

```lua
local healthPacks = inventory:getItemsOfType("health_pack")
for _, pack in ipairs(healthPacks) do
    print("Health Pack ID:", pack:getID())
end
```

---

## **inventoryMeta:getFirstItemOfType**

**Description**

Retrieves the first item of a specific type from the inventory.

**Realm**

`Shared`

**Parameters**

- **itemType** (`String`): The type of item to retrieve.

**Returns**

- **Table|nil**: The first item of the specified type, or `nil` if not found.

**Example**

```lua
local firstHealthPack = inventory:getFirstItemOfType("health_pack")
if firstHealthPack then
    print("First Health Pack ID:", firstHealthPack:getID())
end
```

---

## **inventoryMeta:hasItem**

**Description**

Checks if the inventory contains an item of a specific type.

**Realm**

`Shared`

**Parameters**

- **itemType** (`String`): The type of item to check for.

**Returns**

- **Boolean**: Returns `true` if the inventory contains an item of the specified type, otherwise `false`.

**Example**

```lua
if inventory:hasItem("health_pack") then
    print("Inventory contains a health pack.")
else
    print("No health packs in inventory.")
end
```

---

## **inventoryMeta:getItemCount**

**Description**

Retrieves the total count of items in the inventory, optionally filtered by item type.

**Realm**

`Shared`

**Parameters**

- **itemType** (`String`, optional): The type of item to count. If `nil`, counts all items.

**Returns**

- **Integer**: The total count of items in the inventory, optionally filtered by item type.

**Example**

```lua
local totalItems = inventory:getItemCount()
print("Total Items:", totalItems)
local healthPackCount = inventory:getItemCount("health_pack")
print("Health Packs:", healthPackCount)
```

---

## **inventoryMeta:getID**

**Description**

Retrieves the ID of the inventory.

**Realm**

`Shared`

**Returns**

- **Integer**: The ID of the inventory.

**Example**

```lua
local invID = inventory:getID()
print("Inventory ID:", invID)
```

---

## **inventoryMeta:eq**

**Description**

Checks if two inventories are equal based on their IDs.

**Realm**

`Shared`

**Parameters**

- **other** (`Inventory`): The other inventory to compare with.

**Returns**

- **Boolean**: Returns `true` if the inventories have the same ID, otherwise `false`.

**Example**

```lua
if inventory1 == inventory2 then
    print("Both inventories are the same.")
else
    print("Inventories are different.")
end
```

---

## **inventoryMeta:addItem**

**Description**

Adds an item to the inventory.

**Realm**

`Server`

**Parameters**

- **item** (`Item`): The item to add to the inventory.
- **noReplicate** (`Boolean`): Set to `true` to prevent `OnItemAdded` from being called on the added item.

**Returns**

- **Inventory**: Returns the inventory itself.

**Example**

```lua
local weapon = lia.item.new("weapon_rifle")
inventory:addItem(weapon)
```

---

## **inventoryMeta:add**

**Description**

Alias for the `addItem` function.

**Realm**

`Server`

**Parameters**

- **item** (`Item`): The item to add to the inventory.

**Returns**

- **Inventory**: Returns the inventory itself.

**Example**

```lua
inventory:add(weapon)
```

---

## **inventoryMeta:syncItemAdded**

**Description**

Synchronizes the addition of an item with clients.

**Realm**

`Server`

**Parameters**

- **item** (`Item`): The item being added.

**Example**

```lua
inventory:syncItemAdded(weapon)
```

---

## **inventoryMeta:initializeStorage**

**Description**

Initializes the storage for the inventory.

**Realm**

`Server`

**Parameters**

- **initialData** (`Table`): Initial data for the inventory.

**Returns**

- **Deferred**: A deferred promise.

**Example**

```lua
local promise = inventory:initializeStorage({char = 1, item1 = "value1"})
promise:next(function(invID)
    print("Inventory initialized with ID:", invID)
end)
```

---

## **inventoryMeta:restoreFromStorage**

**Description**

Restores the inventory from storage.

**Realm**

`Server`

**Example**

```lua
inventory:restoreFromStorage()
```

---

## **inventoryMeta:removeItem**

**Description**

Removes an item from the inventory.

**Realm**

`Server`

**Parameters**

- **itemID** (`int`): The ID of the item to remove.
- **preserveItem** (`Boolean`): Whether to preserve the item's data in the database.

**Returns**

- **Deferred**: A deferred promise.

**Example**

```lua
inventory:removeItem(12345, true):next(function()
    print("Item removed while preserving data.")
end)
```

---

## **inventoryMeta:remove**

**Description**

Alias for the `removeItem` function.

**Realm**

`Server`

**Parameters**

- **itemID** (`int`): The ID of the item to remove.

**Returns**

- **Deferred**: A deferred promise.

**Example**

```lua
inventory:remove(12345):next(function()
    print("Item removed.")
end)
```

---

## **inventoryMeta:setData**

**Description**

Sets data associated with a key in the inventory.

**Realm**

`Server`

**Parameters**

- **key** (`any`): The key to associate the data with.
- **value** (`any`): The value to set for the key.

**Returns**

- **Inventory**: Returns the inventory itself.

**Example**

```lua
inventory:setData("owner", player)
```

---

## **inventoryMeta:canAccess**

**Description**

Checks if a certain action is permitted for the inventory.

**Realm**

`Server`

**Parameters**

- **action** (`String`): The action to check for access.
- **context** (`Table`): Additional context for the access check.

**Returns**

- **Boolean|nil**: Returns `true` if the action is permitted, `false` if denied, or `nil` if not applicable.
- **String** (optional): A reason for the access result.

**Example**

```lua
local canAccess, reason = inventory:canAccess("remove_item", {client = player})
if canAccess then
    print("Access granted.")
else
    print("Access denied:", reason)
end
```

---

## **inventoryMeta:addAccessRule**

**Description**

Adds an access rule to the inventory.

**Realm**

`Server`

**Parameters**

- **rule** (`function`): The access rule function.
- **priority** (`int`, optional): The priority of the access rule.

**Returns**

- **Inventory**: Returns the inventory itself.

**Example**

```lua
inventory:addAccessRule(function(inv, action, context)
    if action == "remove_item" and context.client:IsAdmin() then
        return true
    end
end, 10)
```

---

## **inventoryMeta:removeAccessRule**

**Description**

Removes an access rule from the inventory.

**Realm**

`Server`

**Parameters**

- **rule** (`function`): The access rule function to remove.

**Returns**

- **Inventory**: Returns the inventory itself.

**Example**

```lua
inventory:removeAccessRule(existingRuleFunction)
```

---

## **inventoryMeta:getRecipients**

**Description**

Retrieves the recipients for synchronization.

**Realm**

`Server`

**Returns**

- **Table**: An array containing the recipients for synchronization.

**Example**

```lua
local recipients = inventory:getRecipients()
for _, client in ipairs(recipients) do
    print("Syncing with client:", client:Nick())
end
```

---

## **inventoryMeta:onInstanced**

**Description**

Initializes an instance of the inventory.

**Realm**

`Server`

**Example**

```lua
inventory:onInstanced()
```

---

## **inventoryMeta:onLoaded**

**Description**

Callback function called when the inventory is loaded.

**Realm**

`Server`

**Example**

```lua
function Inventory:onLoaded()
    print("Inventory loaded.")
end
```

---

## **inventoryMeta:loadItems**

**Description**

Loads items from the database into the inventory.

**Realm**

`Server`

**Returns**

- **Deferred**: A deferred promise.

**Example**

```lua
inventory:loadItems():next(function(items)
    print("Items loaded:", #items)
end)
```

---

## **inventoryMeta:onItemsLoaded**

**Description**

Callback function called when items are loaded into the inventory.

**Realm**

`Server`

**Example**

```lua
function Inventory:onItemsLoaded(items)
    print("Loaded", #items, "items into the inventory.")
end
```

---

## **inventoryMeta:instance**

**Description**

Instantiates a new inventory instance.

**Realm**

`Server`

**Parameters**

- **initialData** (`Table`): Initial data for the inventory instance.

**Returns**

- **Table**: The newly instantiated inventory instance.

**Example**

```lua
local instance = inventory:instance({char = 1, item1 = "value1"})
```

---

## **inventoryMeta:syncData**

**Description**

Synchronizes data changes with clients.

**Realm**

`Server`

**Parameters**

- **key** (`any`): The key whose data has changed.
- **recipients** (`Table`): The recipients to synchronize with.

**Example**

```lua
inventory:syncData("health", {client = player})
```

---

## **inventoryMeta:sync**

**Description**

Synchronizes the inventory with clients.

**Realm**

`Server`

**Parameters**

- **recipients** (`Table`, optional): The recipients to synchronize with.

**Example**

```lua
inventory:sync()
```

---

## **inventoryMeta:delete**

**Description**

Deletes the inventory.

**Realm**

`Server`

**Example**

```lua
inventory:delete()
```

---

## **inventoryMeta:destroy**

**Description**

Destroys the inventory and its associated items.

**Realm**

`Server`

**Example**

```lua
inventory:destroy()
```

---

## **inventoryMeta:show**

**Description**

Displays the inventory UI to the specified parent element.

**Realm**

`Client`

**Parameters**

- **parent** (`any`, optional): The parent element to which the inventory UI will be displayed.

**Returns**

- **any**: The result of the `lia.inventory.show` function.

**Example**

```lua
inventory:show(panel)
```

---

## **inventoryMeta:getWidth**

**Description**

Retrieves the width of the inventory grid.

**Realm**

`Shared`

**Returns**

- **Integer**: The width of the inventory grid.

**Example**

```lua
local width = inventory:getWidth()
print("Inventory Width:", width)
```

---

## **inventoryMeta:getHeight**

**Description**

Retrieves the height of the inventory grid.

**Realm**

`Shared`

**Returns**

- **Integer**: The height of the inventory grid.

**Example**

```lua
local height = inventory:getHeight()
print("Inventory Height:", height)
```

---

## **inventoryMeta:getSize**

**Description**

Retrieves the size (width and height) of the inventory grid.

**Realm**

`Shared`

**Returns**

- **Integer**: The width of the inventory grid.
- **Integer**: The height of the inventory grid.

**Example**

```lua
local width, height = inventory:getSize()
print("Inventory Size:", width, "x", height)
```

---

## **inventoryMeta:canItemFitInInventory**

**Description**

Checks if an item can fit in the inventory at a given position.

**Realm**

`Shared`

**Parameters**

- **item** (`Item`): The item to check.
- **x** (`Integer`): The X position in the inventory grid.
- **y** (`Integer`): The Y position in the inventory grid.

**Returns**

- **Boolean**: Whether the item can fit in the inventory.

**Example**

```lua
local canFit = inventory:canItemFitInInventory(item, 2, 3)
if canFit then
    print("Item can fit at position (2,3).")
else
    print("Item cannot fit at position (2,3).")
end
```

---

## **inventoryMeta:canAdd**

**Description**

Checks if an item can fit within the inventory based on its size.

Verifies whether the item's width and height are within the bounds of the inventory dimensions.

**Realm**

`Shared`

**Parameters**

- **item** (`String|Item`): The item to check. This can be a string representing the item type or the item object itself.

**Returns**

- **Boolean**: `true` if the item fits within the inventory dimensions, `false` otherwise.

**Example**

```lua
local canFit = inventory:canAdd("health_pack")
if canFit then
    print("Health pack can be added to the inventory.")
else
    print("Health pack is too large for the inventory.")
end
```

---

## **inventoryMeta:doesItemOverlapWithOther**

**Description**

Checks if an item overlaps with another item in the inventory.

**Realm**

`Shared`

**Parameters**

- **testItem** (`Item`): The item to test for overlap.
- **x** (`Integer`): The X position of the test item in the inventory grid.
- **y** (`Integer`): The Y position of the test item in the inventory grid.
- **item** (`Item`): The item to check against.

**Returns**

- **Boolean**: Whether the test item overlaps with the given item.

**Example**

```lua
local overlaps = inventory:doesItemOverlapWithOther(testItem, 5, 5, existingItem)
if overlaps then
    print("Items overlap.")
else
    print("No overlap detected.")
end
```

---

## **inventoryMeta:doesFitInventory**

**Description**

Checks if an item can fit in the inventory, including within bags.

**Realm**

`Shared`

**Parameters**

- **item** (`Item`): The item to check.

**Returns**

- **Boolean**: Whether the item can fit in the inventory.

**Example**

```lua
local canFit = inventory:doesFitInventory(item)
if canFit then
    print("Item can fit in the inventory or its bags.")
else
    print("No space available for the item.")
end
```

---

## **inventoryMeta:doesItemFitAtPos**

**Description**

Checks if an item fits at a specific position in the inventory.

**Realm**

`Shared`

**Parameters**

- **testItem** (`Item`): The item to check.
- **x** (`Integer`): The X position in the inventory grid.
- **y** (`Integer`): The Y position in the inventory grid.

**Returns**

- **Boolean**: Whether the item fits at the given position.
- **Item** (optional): The item it overlaps with, if any.

**Example**

```lua
local fits, overlappingItem = inventory:doesItemFitAtPos(testItem, 3, 4)
if fits then
    print("Item fits at position (3,4).")
else
    print("Item overlaps with:", overlappingItem:getID())
end
```

---

## **inventoryMeta:findFreePosition**

**Description**

Finds a free position in the inventory where an item can fit.

**Realm**

`Shared`

**Parameters**

- **item** (`Item`): The item to find a position for.

**Returns**

- **Integer|nil**: The X position in the inventory grid, or `nil` if no position is found.
- **Integer|nil**: The Y position in the inventory grid, or `nil` if no position is found.

**Example**

```lua
local x, y = inventory:findFreePosition(item)
if x and y then
    print("Free position found at:", x, y)
else
    print("No free position available for the item.")
end
```

---

## **inventoryMeta:setSize**

**Description**

Sets the size of the inventory grid.

**Realm**

`Server`

**Parameters**

- **w** (`Integer`): The width of the grid.
- **h** (`Integer`): The height of the grid.

**Example**

```lua
inventory:setSize(10, 8)
print("Inventory size set to 10x8.")
```

---

## **inventoryMeta:wipeItems**

**Description**

Removes all items from the inventory.

**Realm**

`Server`

**Example**

```lua
inventory:wipeItems()
print("All items have been removed from the inventory.")
```

---

## **inventoryMeta:setOwner**

**Description**

Sets the owner of the inventory.

If the owner is a player, it sets the inventory's owner to the player's character ID.

**Realm**

`Server`

**Parameters**

- **owner** (`Player|Integer`): The new owner of the inventory (Player object or character ID number).
- **fullUpdate** (`Boolean`, optional): Whether to sync the inventory to the client.

**Example**

```lua
inventory:setOwner(player, true)
print("Inventory owner set to player.")
```

---

## **inventoryMeta:requestTransfer**

**Description**

Requests a transfer of an item to another inventory.

**Realm**

`Client`

**Parameters**

- **itemID** (`Integer`): The ID of the item to transfer.
- **destinationID** (`Integer`): The ID of the destination inventory.
- **x** (`Integer`): The X position in the destination grid.
- **y** (`Integer`): The Y position in the destination grid.

**Example**

```lua
inventory:requestTransfer(456, destinationInventoryID, 2, 3)
print("Transfer request sent for item 456.")
```

---