# Item Meta

Item objects represent things found in inventories or spawned in the world.

This guide describes methods for reading and manipulating item data.

---

## Overview

Item-meta functions cover stack counts, categories, weight calculations, and network variables.

Items can exist in inventories or the world, and item instances clone the base properties defined by the item table.

These helpers enable consistent interaction across trading, crafting, and interface components.

---

### isRotated

**Purpose**

Checks if the item is currently rotated.

**Parameters**

* None

**Returns**

* boolean - True if the item is rotated, false otherwise.

**Realm**

`Shared.`

**Example Usage**

```lua
if item:isRotated() then
print("The item is rotated!")
end
```

---

### getWidth

**Purpose**

Returns the width of the item, taking into account its rotation.

**Parameters**

* None

**Returns**

* number - The width of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
local width = item:getWidth()
print("Item width: " .. width)
```

---

### getHeight

**Purpose**

Returns the height of the item, taking into account its rotation.

**Parameters**

* None

**Returns**

* number - The height of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
local height = item:getHeight()
print("Item height: " .. height)
```

---

### getQuantity

**Purpose**

Returns the current quantity of the item.

**Parameters**

* None

**Returns**

* number - The quantity of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print("You have " .. item:getQuantity() .. " of this item.")
```

---

### eq

**Purpose**

Checks if this item is equal to another item by comparing their IDs.

**Parameters**

* other (Item) - The other item to compare.

**Returns**

* boolean - True if the items are equal, false otherwise.

**Realm**

`Shared.`

**Example Usage**

```lua
if item:eq(otherItem) then
print("These items are the same instance.")
end
```

---

### tostring

**Purpose**

Returns a string representation of the item.

**Parameters**

* None

**Returns**

* string - The string representation of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print(item:tostring())
```

---

### getID

**Purpose**

Returns the ID of the item.

**Parameters**

* None

**Returns**

* number - The ID of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print("Item ID: " .. item:getID())
```

---

### getModel

**Purpose**

Returns the model of the item.

**Parameters**

* None

**Returns**

* string - The model path of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print("Model path: " .. item:getModel())
```

---

### getSkin

**Purpose**

Returns the skin index of the item.

**Parameters**

* None

**Returns**

* number - The skin index.

**Realm**

`Shared.`

**Example Usage**

```lua
print("Skin index: " .. tostring(item:getSkin()))
```

---

### getPrice

**Purpose**

Returns the price of the item, using a custom calculation if available.

**Parameters**

* None

**Returns**

* number - The price of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print("Item price: " .. item:getPrice())
```

---

### call

**Purpose**

Calls a method on the item, temporarily setting the player and entity context.

**Parameters**

* method (string) - The method name to call.
* client (Player) - The player context.
* entity (Entity) - The entity context.
* ... - Additional arguments to pass to the method.

**Returns**

* ... - The return values of the called method.

**Realm**

`Shared.`

**Example Usage**

```lua
item:call("onUse", client, entity, arg1, arg2)
```

---

### getOwner

**Purpose**

Returns the player who owns this item.

**Parameters**

* None

**Returns**

* Player - The owner of the item, or nil if not found.

**Realm**

`Shared.`

**Example Usage**

```lua
local owner = item:getOwner()
if owner then
print("Item owner: " .. owner:Name())
end
```

---

### getData

**Purpose**

Returns the value of a data key for this item, checking both local and entity data.

**Parameters**

* key (string) - The data key to retrieve.
* default (any) - The default value if the key is not found.

**Returns**

* any - The value of the data key, or the default.

**Realm**

`Shared.`

**Example Usage**

```lua
local durability = item:getData("durability", 100)
```

---

### getAllData

**Purpose**

Returns a table containing all data for this item, including entity data.

**Parameters**

* None

**Returns**

* table - A table of all data for the item.

**Realm**

`Shared.`

**Example Usage**

```lua
PrintTable(item:getAllData())
```

---

### hook

**Purpose**

Registers a hook function for a specific event on this item.

**Parameters**

* name (string) - The name of the hook/event.
* func (function) - The function to call.

**Returns**

* None

**Realm**

`Shared.`

**Example Usage**

```lua
item:hook("onUse", function(self, data) print("Used!") end)
```

---

### postHook

**Purpose**

Registers a post-hook function for a specific event on this item.

**Parameters**

* name (string) - The name of the post-hook/event.
* func (function) - The function to call.

**Returns**

* None

**Realm**

`Shared.`

**Example Usage**

```lua
item:postHook("onUse", function(self, result, data) print("Post-use!") end)
```

---

### onRegistered

**Purpose**

Called when the item is registered. Precaches the model if set.

**Parameters**

* None

**Returns**

* None

**Realm**

`Shared.`

**Example Usage**

```lua
-- Called automatically when the item is registered.
```

---

### print

**Purpose**

Prints information about the item to the console.

**Parameters**

* detail (boolean) - Whether to print detailed information.

**Returns**

* None

**Realm**

`Shared.`

**Example Usage**

```lua
item:print(true)
```

---

### printData

**Purpose**

Prints all data associated with the item to the console.

**Parameters**

* None

**Returns**

* None

**Realm**

`Shared.`

**Example Usage**

```lua
item:printData()
```

---

### getName

**Purpose**

Returns the name of the item.

**Parameters**

* None

**Returns**

* string - The name of the item.

**Realm**

`Server.`

**Example Usage**

```lua
print(item:getName())
```

---

### getDesc

**Purpose**

Returns the description of the item.

**Parameters**

* None

**Returns**

* string - The description of the item.

**Realm**

`Server.`

**Example Usage**

```lua
print(item:getDesc())
```

---

### removeFromInventory

**Purpose**

Removes the item from its inventory.

**Parameters**

* preserveItem (boolean) - Whether to preserve the item instance.

**Returns**

* Deferred - A deferred object that resolves when removal is complete.

**Realm**

`Server.`

**Example Usage**

```lua
item:removeFromInventory(true):next(function() print("Removed!") end)
```

---

### delete

**Purpose**

Deletes the item from the database and calls onRemoved.

**Parameters**

* None

**Returns**

* Deferred - A deferred object that resolves when deletion is complete.

**Realm**

`Server.`

**Example Usage**

```lua
item:delete():next(function() print("Deleted!") end)
```

---

### remove

**Purpose**

Removes the item from the world and inventory, then deletes it.

**Parameters**

* None

**Returns**

* Deferred - A deferred object that resolves when removal is complete.

**Realm**

`Server.`

**Example Usage**

```lua
item:remove():next(function() print("Item fully removed!") end)
```

---

### destroy

**Purpose**

Destroys the item instance and notifies clients.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
item:destroy()
```

---

### onDisposed

**Purpose**

Called when the item is disposed.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
-- Override in your item definition if needed.
```

---

### getEntity

**Purpose**

Returns the entity associated with this item.

**Parameters**

* None

**Returns**

* Entity - The entity, or nil if not found.

**Realm**

`Server.`

**Example Usage**

```lua
local ent = item:getEntity()
if ent then print("Entity found!") end
```

---

### spawn

**Purpose**

Spawns the item as an entity in the world.

**Parameters**

* position (Vector or table or Player) - The position or player to drop at.
* angles (Angle or table) - The angles to spawn with.

**Returns**

* Entity - The spawned entity, or nil if failed.

**Realm**

`Server.`

**Example Usage**

```lua
local ent = item:spawn(Vector(0,0,0))
```

---

### transfer

**Purpose**

Transfers the item to a new inventory.

**Parameters**

* newInventory (Inventory) - The inventory to transfer to.
* bBypass (boolean) - Whether to bypass access checks.

**Returns**

* boolean - True if transfer started, false otherwise.

**Realm**

`Server.`

**Example Usage**

```lua
item:transfer(newInventory)
```

---

### onInstanced

**Purpose**

Called when the item is instanced.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
-- Override in your item definition if needed.
```

---

### onSync

**Purpose**

Called when the item is synced to a client.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
-- Override in your item definition if needed.
```

---

### onRemoved

**Purpose**

Called when the item is removed.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
-- Override in your item definition if needed.
```

---

### onRestored

**Purpose**

Called when the item is restored.

**Parameters**

* None

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
-- Override in your item definition if needed.
```

---

### sync

**Purpose**

Syncs the item instance to a recipient or all clients.

**Parameters**

* recipient (Player) - The player to sync to, or nil for all.

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
item:sync(client)
```

---

### setData

**Purpose**

Sets a data key for the item and syncs it to clients and the database.

**Parameters**

* key (string) - The data key.
* value (any) - The value to set.
* receivers (Player or table) - The recipients to sync to.
* noSave (boolean) - If true, do not save to the database.
* noCheckEntity (boolean) - If true, do not update the entity.

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
item:setData("durability", 50)
```

---

### addQuantity

**Purpose**

Adds to the item's quantity and updates clients/entities.

**Parameters**

* quantity (number) - The amount to add.
* receivers (Player or table) - The recipients to sync to.
* noCheckEntity (boolean) - If true, do not update the entity.

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
item:addQuantity(5)
```

---

### setQuantity

**Purpose**

Sets the item's quantity and updates clients/entities and the database.

**Parameters**

* quantity (number) - The new quantity.
* receivers (Player or table) - The recipients to sync to.
* noCheckEntity (boolean) - If true, do not update the entity.

**Returns**

* None

**Realm**

`Server.`

**Example Usage**

```lua
item:setQuantity(10)
```

---

### interact

**Purpose**

Handles a player interaction with the item.

**Parameters**

* action (string) - The action to perform.
* client (Player) - The player interacting.
* entity (Entity) - The entity involved.
* data (any) - Additional data for the interaction.

**Returns**

* boolean - True if the interaction was successful, false otherwise.

**Realm**

`Server.`

**Example Usage**

```lua
item:interact("use", client, entity, data)
```

---

### getName

**Purpose**

Returns the name of the item.

**Parameters**

* None

**Returns**

* string - The name of the item.

**Realm**

`Client.`

**Example Usage**

```lua
print(item:getName())
```

---

### getDesc

**Purpose**

Returns the description of the item.

**Parameters**

* None

**Returns**

* string - The description of the item.

**Realm**

`Client.`

**Example Usage**

```lua
print(item:getDesc())
```

---

### getCategory

**Purpose**

Returns the category of the item with automatic localization.

**Parameters**

* None

**Returns**

* string - The localized category of the item.

**Realm**

`Shared.`

**Example Usage**

```lua
print("Item category: " .. item:getCategory())
```

---

