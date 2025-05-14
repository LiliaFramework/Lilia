---

Interactable entities that can be held in inventories.

Items are objects that are contained inside of an `Inventory`, or as standalone entities if they are dropped in the world. They usually have functionality that provides more gameplay aspects to the schema.

For an item to have an actual presence, they need to be instanced (usually by spawning them). Items describe the properties, while instances are a clone of these properties that can have their own unique data (e.g., an ID card will have the same name but different numerical IDs). You can think of items as the class, while instances are objects of the `Item` class.

---

## **itemMeta:eq**

**Description**

Compares this item with another item for equality based on their unique IDs.

**Realm**

`Shared`

**Parameters**

- **other** (`Item`): The other item to compare against.

**Returns**

- **Boolean**: `true` if both items have the same database ID, otherwise `false`.

**Example**

```lua
local item1 = lia.item.instances[1]
local item2 = lia.item.instances[2]

if item1 == item2 then
    print("Items are equal.")
else
    print("Items are not equal.")
end
```

---

## **itemMeta:tostring**

**Description**

Generates a human-readable string representation of the item.

**Realm**

`Shared`

**Returns**

- **String**: A string in the format `"item[uniqueID][ID]"`.

**Example**

```lua
local item = lia.item.instances[1]
print(tostring(item))
-- Output: "item[exampleUniqueID][1]"
```

---

## **itemMeta:getQuantity**

**Description**

Retrieves the quantity of this item. For items with `id == 0`, it returns the `maxQuantity`.

**Realm**

`Shared`

**Returns**

- **Integer**: The current quantity of the item.

**Example**

```lua
local item = lia.item.instances[1]
local qty = item:getQuantity()
print("Item quantity:", qty)
```

---

## **itemMeta:getID**

**Description**

Gets this item's database ID, which is guaranteed to be unique.

**Realm**

`Shared`

**Returns**

- **Integer**: The unique database ID of the item.

**Example**

```lua
local item = lia.item.instances[1]
print("Item ID:", item:getID())
```

---

## **itemMeta:getModel**

**Description**

Returns the model path for this item.

**Realm**

`Shared`

**Returns**

- **String**: The model path of the item.

**Example**

```lua
local item = lia.item.instances[1]
print("Item model:", item:getModel())
```

---

## **itemMeta:getSkin**

**Description**

Retrieves the skin index used by this item (if any).

**Realm**

`Shared`

**Returns**

- **Integer**: The skin index of the item.

**Example**

```lua
local item = lia.item.instances[1]
print("Item skin:", item:getSkin())
```

---

## **itemMeta:getPrice**

**Description**

Returns the price of the item. If a `calcPrice` method exists on the item, it is used to compute a dynamic price.

**Realm**

`Shared`

**Returns**

- **Float**: The price of the item.

**Example**

```lua
local item = lia.item.instances[1]
local price = item:getPrice()
print("Item price:", price)
```

---

## **itemMeta:call**

**Description**

Invokes one of the item's methods dynamically. Sets `self.player` and `self.entity` temporarily while the method is called.

**Realm**

`Shared`

**Parameters**

1. **method** (`String`): The name of the method to invoke on the item.  
2. **client** (`Player`, optional): The player related to this call, if any.  
3. **entity** (`Entity`, optional): The entity related to this call, if any.  
4. **...**: Additional parameters passed to the invoked method.

**Returns**

- **any**: The return values of the invoked method, if any.

**Example**

```lua
local item = lia.item.instances[1]
item:call("use", player, entity, "someArgument")
```

---

## **itemMeta:getOwner**

**Description**

Retrieves the player who currently owns this item, if any. Ownership is determined by whichever inventory contains this item, or by a direct check for the item ID within the player's inventory.

**Realm**

`Shared`

**Returns**

- **Player|nil**: The owner of this item, or `nil` if no owner is found.

**Example**

```lua
local item = lia.item.instances[1]
local owner = item:getOwner()
if owner then
    print("Item is owned by:", owner:Nick())
else
    print("No valid owner found.")
end
```

---

## **itemMeta:getData**

**Description**

Retrieves a stored data value from the item's internal `data` table (or from the item's entity network vars if it exists in the world).

**Realm**

`Shared`

**Parameters**

1. **key** (`String`): The key under which the value is stored.  
2. **default** (`any`, optional): The fallback value if no data is found.

**Returns**

- **any**: The stored value for the specified key, or `default` if none exists.

**Example**

```lua
local item = lia.item.instances[1]
local health = item:getData("health", 100)
print("Item Health:", health)
```

---

## **itemMeta:getAllData**

**Description**

Combines and returns all stored data from this item, including data from its entity if it exists in the world.

**Realm**

`Shared`

**Returns**

- **table**: A table containing all data related to the item.

**Example**

```lua
local item = lia.item.instances[1]
local fullData = item:getAllData()
PrintTable(fullData)
```

---

## **itemMeta:hook**

**Description**

Assigns a function to be executed when a particular event (hook) occurs on this item.

**Realm**

`Shared`

**Parameters**

1. **name** (`String`): The name of the event (e.g., `"onUse"`).  
2. **func** (`function`): The function to be called when the event occurs.

**Example**

```lua
local item = lia.item.instances[1]
item:hook("onUse", function(it)
    print("Item was used.")
end)
```

---

## **itemMeta:postHook**

**Description**

Assigns a function to be executed after a particular hook runs.

**Realm**

`Shared`

**Parameters**

1. **name** (`String`): The name of the event (e.g., `"onUse"`).  
2. **func** (`function`): The function to be called after the original hook is executed.

**Example**

```lua
local item = lia.item.instances[1]
item:postHook("onUse", function(it, result)
    print("Item post-use logic executed.")
end)
```

---

## **itemMeta:onRegistered**

**Description**

Called when the item is registered. Useful for post-registration tasks.

**Realm**

`Shared`

**Example**

```lua
function ITEM:onRegistered()
    print("Item has been registered.")
end
```

---

## **itemMeta:print**

**Description**

Utility function to print basic item info (and optionally details like owner and inventory position).

**Realm**

`Shared`

**Parameters**

1. **detail** (`boolean`, optional): Whether or not to include extra information (owner, grid position).

**Example**

```lua
local item = lia.item.instances[1]
item:print()        -- Prints basic info
item:print(true)    -- Prints extended info
```

---

## **itemMeta:printData**

**Description**

Utility function that prints all stored data related to this item. Useful for debugging.

**Realm**

`Shared`

**Example**

```lua
local item = lia.item.instances[1]
item:printData()
```

---

## **itemMeta:getName**

**Description**

Retrieves the name of the item. On the server, it returns `ITEM.name` directly; on the client, it may be localized.

**Realm**

`Server` (or `Client`, or `Shared` depending on usage)

**Returns**

- **String**: The name of the item (or localized name on the client).

**Example**

```lua
local item = lia.item.instances[1]
print("Item name:", item:getName())
```

---

## **itemMeta:getDesc**

**Description**

Retrieves the description of the item. On the server, returns `ITEM.desc` directly; on the client, may be localized.

**Realm**

`Server` (or `Client` or `Shared`)

**Returns**

- **String**: The item's description (potentially localized on the client).

**Example**

```lua
local item = lia.item.instances[1]
print("Item description:", item:getDesc())
```

---

## **itemMeta:removeFromInventory**

**Description**

Removes this item from its current inventory. Optionally, the removal can preserve the item in the database.

**Realm**

`Server`

**Parameters**

1. **preserveItem** (`boolean`, optional): If `true`, the item is not fully deleted from the database.

**Returns**

- **Deferred**: A deferred object that resolves once the item is removed from the inventory.

**Example**

```lua
local item = lia.item.instances[1]
item:removeFromInventory(true):next(function()
    print("Item removed while preserving data.")
end)
```

---

## **itemMeta:delete**

**Description**

Deletes the item from the database (and memory). After calling this, the item no longer exists persistently.

**Realm**

`Server`

**Returns**

- **Deferred**: A deferred object that resolves when the item is successfully removed from the database.

**Example**

```lua
local item = lia.item.instances[1]
item:delete():next(function()
    print("Item deleted from database.")
end)
```

---

## **itemMeta:remove**

**Description**

Removes the item from the game world, its inventory, and then proceeds to delete it from the database.

**Realm**

`Server`

**Returns**

- **Deferred**: A deferred object that resolves when removal is complete and the item is deleted.

**Example**

```lua
local item = lia.item.instances[1]
item:remove():next(function()
    print("Item fully removed from the world and database.")
end)
```

---

## **itemMeta:destroy**

**Description**

Destroys the item instance in memory and notifies connected clients to remove the item. **This does not remove the record from the database**.

**Realm**

`Server`

**Example**

```lua
local item = lia.item.instances[1]
item:destroy()
-- The item is gone from memory and clients are instructed to remove it.
```

---

## **itemMeta:onDisposed**

**Description**

Called when the item is disposed (i.e., destroyed and removed from memory).

**Realm**

`Server`

**Example**

```lua
function ITEM:onDisposed()
    print("Item has been disposed of.")
end
```

---

## **itemMeta:getEntity**

**Description**

Finds the corresponding world entity (`ents.FindByClass("lia_item")`) for this item, if it exists.

**Realm**

`Server`

**Returns**

- **Entity|nil**: The item entity if found, otherwise `nil`.

**Example**

```lua
local item = lia.item.instances[1]
local entity = item:getEntity()
if IsValid(entity) then
    print("Found item entity in the world.")
else
    print("Item entity not found.")
end
```

---

## **itemMeta:spawn**

**Description**

Spawns this item into the game world as a physical entity. If an entity already exists for the item, it is removed before spawning a new one.

**Realm**

`Server`

**Parameters**

1. **position** (`Vector` or `Player`): The position to spawn the item, or a `Player` from which the spawn position will be derived.  
2. **angles** (`Angle`, optional): The angles at which the entity should spawn.

**Returns**

- **Entity**: The newly created item entity.

**Example**

```lua
local item = lia.item.instances[1]
local spawnPos = Vector(0, 0, 0)
local spawnedEntity = item:spawn(spawnPos, Angle(0, 0, 0))
```

---

## **itemMeta:transfer**

**Description**

Moves this item to another inventory.

**Realm**

`Server`

**Parameters**

1. **newInventory** (`Inventory`): The target inventory to transfer to.  
2. **bBypass** (`boolean`, optional): If `true`, bypasses access checks.

**Returns**

- **Boolean**: `true` if transfer began successfully, otherwise `false`.

**Example**

```lua
local item = lia.item.instances[1]
local targetInv = lia.inventory.instances[2]
local success = item:transfer(targetInv)
if success then
    print("Item transferred successfully.")
else
    print("Item transfer failed.")
end
```

---

## **itemMeta:onInstanced**

**Description**

Called when the item is created/instanced. Useful for performing operations right after the item is first spawned in memory.

**Realm**

`Server`

**Example**

```lua
function ITEM:onInstanced()
    print("Item instance created.")
end
```

---

## **itemMeta:onSync**

**Description**

Called when the item data is synced to a specific recipient or broadcast to all players.

**Realm**

`Server`

**Parameters**

- **recipient** (`Player`, optional): The player receiving the item data. Could be `nil` if broadcasted to all.

**Example**

```lua
function ITEM:onSync(recipient)
    if recipient then
        print("Item synced to:", recipient:Nick())
    else
        print("Item synced to all players.")
    end
end
```

---

## **itemMeta:onRemoved**

**Description**

Called when the item is removed from the database (e.g., after a full delete).

**Realm**

`Server`

**Example**

```lua
function ITEM:onRemoved()
    print("Item removed from database.")
end
```

---

## **itemMeta:onRestored**

**Description**

Called when the item is restored (for instance, from a saved database state).

**Realm**

`Server`

**Example**

```lua
function ITEM:onRestored()
    print("Item was restored from the database.")
end
```

---

## **itemMeta:sync**

**Description**

Synchronizes this item's data with one or more players. If `recipient` is `nil`, the data is broadcast to all players.

**Realm**

`Server`

**Parameters**

- **recipient** (`Player`, optional): The player to synchronize with. If `nil`, broadcasts to all.

**Example**

```lua
local item = lia.item.instances[1]
-- Sync to a specific player
item:sync(somePlayer)
-- Or sync to everyone
item:sync()
```

---

## **itemMeta:setData**

**Description**

Sets or updates a key-value pair within the item's data table, optionally updates the network data, and writes to the database.

**Realm**

`Server`

**Parameters**

1. **key** (`String`): The key to store the value under.  
2. **value** (`any`): The value to set. If `nil`, the key is removed.  
3. **receivers** (`table|Player`, optional): Who should receive the data update. Defaults to the item owner if not provided.  
4. **noSave** (`boolean`, optional): If `true`, does not save to the database.  
5. **noCheckEntity** (`boolean`, optional): If `true`, skips updating any existing entity netvars.

**Example**

```lua
local item = lia.item.instances[1]
-- Set "health" to 100 and broadcast to the owner
item:setData("health", 100)

-- Set "armor" to 50 and only send updates to a specific player
item:setData("armor", 50, {somePlayer})
```

---

## **itemMeta:addQuantity**

**Description**

Adds a specified amount to this item's current quantity.

**Realm**

`Server`

**Parameters**

1. **quantity** (`int`): The amount to add.  
2. **receivers** (`table|Player`, optional): Recipients for quantity change updates.  
3. **noCheckEntity** (`boolean`, optional): If `true`, skip updating the entity netvar.

**Example**

```lua
local item = lia.item.instances[1]
item:addQuantity(5, {player1, player2})
```

---

## **itemMeta:setQuantity**

**Description**

Directly sets the quantity for this item to a specified value.

**Realm**

`Server`

**Parameters**

1. **quantity** (`int`): The new quantity.  
2. **receivers** (`table|Player`, optional): Recipients for quantity change updates.  
3. **noCheckEntity** (`boolean`, optional): If `true`, skip updating the entity netvar.

**Example**

```lua
local item = lia.item.instances[1]
item:setQuantity(10, {player1, player2})
```

---

## **itemMeta:interact**

**Description**

Handles an interaction action (e.g. `"use"`, `"drop"`, etc.) performed by a player on this item. Checks for relevant hooks, conditions, and then removes the item if interaction is successful and not returning a promise.

**Realm**

`Server`

**Parameters**

1. **action** (`String`): The name of the interaction action (e.g., `"use"`).  
2. **client** (`Player`): The player interacting with the item.  
3. **entity** (`Entity`, optional): The entity linked to this interaction.  
4. **data** (`Table`, optional): Any additional data associated with the interaction.

**Returns**

- **Boolean**: `true` if the interaction was successfully processed, `false` otherwise.

**Example**

```lua
local item = lia.item.instances[1]
local success = item:interact("use", player, item:getEntity())
if success then
    print("Item use interaction completed successfully.")
else
    print("Item use interaction failed.")
end
```

---