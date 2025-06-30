# Item Meta

Item objects represent things found in inventories or spawned in the world. This guide describes methods for reading and manipulating item data.

---

## Overview

Item meta functions cover stack counts, categories, weight calculations, and network variables. Items are objects that can exist in inventories or the world, and item instances clone the base properties defined by the item table. These helpers enable consistent interaction across trading, crafting, and interface components.

### getQuantity()

**Description:**

Retrieves how many of this item the stack represents.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Quantity contained in this item instance.

**Example Usage:**

```lua
-- Give the player ammo equal to the stack quantity
player:GiveAmmo(item:getQuantity(), "pistol")
```
---

### eq(other)

**Description:**

Compares this item instance to another by ID.

**Parameters:**

* other (Item) – The other item to compare with.

**Realm:**

* Shared

**Returns:**

* boolean – True if both items share the same ID.

**Example Usage:**

```lua
-- Check if the held item matches the inventory slot
if item:eq(slotItem) then
    print("Same item instance")
end
```
---

### tostring()

**Description:**

Returns a printable representation of this item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* string – Identifier in the form "item[uniqueID][id]".

**Example Usage:**

```lua
-- Log the item identifier during saving
print("Saving " .. item:tostring())
```
---

### getID()

**Description:**

Retrieves the unique identifier of this item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Item database ID.

**Example Usage:**

```lua
-- Use the ID when updating the database
lia.db.updateItem(item:getID(), {price = 50})
```
---

### getModel()

**Description:**

Returns the model path associated with this item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* string – Model path.

**Example Usage:**

```lua
-- Spawn the item's model as a world prop
local prop = ents.Create("prop_physics")
prop:SetModel(item:getModel())
prop:Spawn()
```
---

### getSkin()

**Description:**

Retrieves the skin index this item uses.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Skin ID applied to the model.

**Example Usage:**

```lua
-- Apply the correct skin when displaying the item
model:SetSkin(item:getSkin())
```
---

### getPrice()

**Description:**

Returns the calculated purchase price for the item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – The price value.

**Example Usage:**

```lua
-- Charge the player the item's price before giving it
if char:hasMoney(item:getPrice()) then
    char:takeMoney(item:getPrice())
end
```
---

### call(method, client, entity, ...)

**Description:**

Invokes an item method with the given player and entity context.

**Parameters:**

* method (string) – Method name to run.
* client (Player) – The player performing the action.
* entity (Entity) – Entity representing this item.
* ... – Additional arguments passed to the method.

**Realm:**

* Shared

**Returns:**

* any – Results returned by the called function.

**Example Usage:**

```lua
-- Trigger a custom "use" function when the player presses Use
item:call("use", client, entity)
```
---

### getOwner()

**Description:**

Attempts to find the player currently owning this item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Player|None – The owner if available.

**Example Usage:**

```lua
-- Notify whoever currently owns the item
local owner = item:getOwner()
if IsValid(owner) then
    owner:notify("Your item glows brightly.")
end
```
---

### getData(key, default)

**Description:**

Retrieves a piece of persistent data stored on the item.

**Parameters:**

* key (string) – Data key to read.
* default (any) – Value to return when the key is absent.

**Realm:**

* Shared

**Returns:**

* any – Stored value or default.

**Example Usage:**

```lua
-- Retrieve a custom paint color stored on the item
local color = item:getData("paintColor", Color(255,255,255))
```
---

### getAllData()

**Description:**

Returns a merged table of this item's stored data and any
networked values on its entity.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table – Key/value table of all data fields.

**Example Usage:**

```lua
-- Print all stored data for debugging
PrintTable(item:getAllData())
```
---

### hook(name, func)

**Description:**

Registers a hook callback for this item instance.

**Parameters:**

* name (string) – Hook identifier.
* func (function) – Function to call.

**Realm:**

* Shared
**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Run code when the item is used
item:hook("use", function(ply) ply:ChatPrint("Used!") end)
```
---

### postHook(name, func)

**Description:**

Registers a post-hook callback for this item.

**Parameters:**

* name (string) – Hook identifier.
* func (function) – Function invoked after the main hook.

**Realm:**

* Shared
**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Give a pistol after the item is picked up
item:postHook("pickup", function(ply) ply:Give("weapon_pistol") end)
```
---

### onRegistered()

**Description:**

Called when the item table is first registered.

**Parameters:**

* None

**Realm:**

* Shared
**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Initialize data when the item type loads
item:onRegistered()
```
---

### print(detail)

**Description:**

Prints a simple representation of the item to the console.

**Parameters:**

* detail (boolean) – Include position details when true.

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Output item info while debugging spawn issues
item:print(true)
```
---

### printData()

**Description:**

Debug helper that prints all stored item data.

**Parameters:**

* None

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Dump all stored data to the console
item:printData()
```
---

### addQuantity(quantity, receivers, noCheckEntity)

**Description:**

Increases the stored quantity for this item instance.

**Parameters:**

* quantity (number) – Amount to add.
* receivers (Player|None) – Who to network the change to.
* noCheckEntity (boolean) – Skip entity network update.

**Realm:**

* Server
* Returns:
* None – This function does not return a value.

**Example Usage:**

```lua
-- Combine stacks from a loot drop and notify the owner
item:addQuantity(5, {player})
player:notifyLocalized("item_added", item.name, 5)
```
---

### setQuantity(quantity, receivers, noCheckEntity)

**Description:**

Sets the current stack quantity and replicates the change.

**Parameters:**

* quantity (number) – New amount to store.
* receivers (Player|None) – Recipients to send updates to.
* noCheckEntity (boolean) – Skip entity updates when true.

**Realm:**

* Server
* Returns:
* None – This function does not return a value.

**Example Usage:**

```lua
-- Set quantity to 1 after splitting the stack
item:setQuantity(1, nil, true)
```
---

### getName()

**Description:**

Returns the display name of this item. On the client this value is localized.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* string – Item name.

**Example:**

```lua
-- Inform the player which item they found
client:ChatPrint("Picked up: " .. item:getName())
```
---

### getDesc()

**Description:**

Retrieves the description text for this item.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* string – Item description.

**Example:**

```lua
-- Display a tooltip describing the item
tooltip:AddRowAfter("name", "desc"):SetText(item:getDesc())
```
---

### removeFromInventory(preserveItem)

**Description:**

Removes this item from its inventory without deleting it when `preserveItem` is true.

**Parameters:**

* preserveItem (boolean) – Keep the item saved in the database.

**Realm:**

* Server

**Returns:**

* Deferred – Resolves when the item has been removed.

**Example:**

```lua
-- Unequip and drop the item while keeping it saved
item:removeFromInventory(true):next(function()
    client:ChatPrint("Item unequipped")
end)
```
---

### delete()

**Description:**

Deletes this item from the database after destroying it.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* Deferred – Resolves when deletion completes.

**Example:**

```lua
-- Permanently remove the item from the database
item:delete():next(function()
    print("Item purged")
end)
```
---

### remove()

**Description:**

Destroys the item's entity then removes and deletes it from its inventory.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* Deferred – Resolves when the item has been removed.

**Example:**

```lua
-- Remove the item from the world and database
item:remove():next(function()
    print("Removed and deleted")
end)
```
---

### destroy()

**Description:**

Broadcasts deletion of this item and removes it from memory.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Instantly delete the item across the network
item:destroy()
```
---

### onDisposed()

**Description:**

Callback executed after the item is destroyed.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
function ITEM:onDisposed()
    print(self:getName() .. " was cleaned up")
end
```
---

### getEntity()

**Description:**

Finds the entity spawned for this item, if any.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* Entity|nil – The world entity representing the item.

**Example:**

```lua
-- Grab the world entity to modify it
local ent = item:getEntity()
if IsValid(ent) then
    ent:SetColor(Color(255, 0, 0))
end
```
---

### spawn(position, angles)

**Description:**

Creates a world entity for this item at the specified position.

**Parameters:**

* position (Vector|Player) – Drop position or player dropping the item.
* angles (Angle|None) – Orientation for the entity.

**Realm:**

* Server

**Returns:**

* Entity|nil – The created entity if successful.

**Example:**

```lua
-- Drop the item at the player's feet
item:spawn(client:getItemDropPos(), Angle(0, 0, 0))
```
---

### transfer(newInventory, bBypass)

**Description:**

Moves the item to another inventory, optionally bypassing access checks.

**Parameters:**

* newInventory (Inventory) – Destination inventory.
* bBypass (boolean) – Skip permission checking.

**Realm:**

* Server

**Returns:**

* boolean – True if the transfer was initiated.

**Example:**

```lua
-- Move the item into another container
item:transfer(targetInv):next(function()
    print("Transferred successfully")
end)
```
---

### onInstanced()

**Description:**

Called when a new instance of this item is created.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
function ITEM:onInstanced()
    print(self:getName() .. " instance created")
end
```
---

### onSync(recipient)

**Description:**

Runs after this item is networked to `recipient`.

**Parameters:**

* recipient (Player|None) – Who received the data.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
function ITEM:onSync(ply)
    print("Sent item to", IsValid(ply) and ply:Name() or "all clients")
end
```
---

### onRemoved()

**Description:**

Executed after the item is permanently removed.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
function ITEM:onRemoved()
    print(self.uniqueID .. " permanently deleted")
end
```
---

### onRestored()

**Description:**

Called when the item is restored from the database.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
function ITEM:onRestored()
    print(self:getName() .. " loaded from the database")
end
```
---

### sync(recipient)

**Description:**

Sends this item's data to a player or broadcasts to all.

**Parameters:**

* recipient (Player|None) – Target player or nil for broadcast.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Resend the item data to a specific player
item:sync(player)
```
---

### setData(key, value, receivers, noSave, noCheckEntity)

**Description:**

Sets a data field on the item and optionally networks and saves it.

**Parameters:**

* key (string) – Data key to modify.
* value (any) – New value to store.
* receivers (Player|None) – Who to send the update to.
* noSave (boolean) – Avoid saving to the database.
* noCheckEntity (boolean) – Skip updating the world entity.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Mark the item as legendary and notify the owner
item:setData("rarity", "legendary", player)
```
---

### interact(action, client, entity, data)

**Description:**

Processes an interaction action performed by `client` on this item.

**Parameters:**

* action (string) – Identifier of the interaction.
* client (Player) – Player performing the action.
* entity (Entity|None) – Entity used for the interaction.
* data (table|None) – Extra data passed to the hooks.

**Realm:**

* Server

**Returns:**

* boolean – True if the interaction succeeded.

**Example:**

```lua
-- Trigger the "use" interaction from code
item:interact("use", client, nil)
```
