# Item Meta

This page documents methods available on the `Item` meta table, representing items in the Lilia framework.

---

## Overview

The `Item` meta table provides comprehensive item management functionality including data storage, networking, interaction handling, spawning, and inventory management. These methods form the foundation for the item system within the Lilia framework, supporting both server-side persistence and client-side synchronization for items that can be stored, used, and manipulated by players.

---

### isRotated

**Purpose**

Checks if the item is currently rotated in the inventory.

**Parameters**

*None.*

**Returns**

* `isRotated` (*boolean*): True if the item is rotated.

**Realm**

Shared.

**Example Usage**

```lua
local function checkItemRotation(item, player)
    if item:isRotated() then
        if IsValid(player) then
            player:ChatPrint("This item is rotated!")
        end
        return true
    else
        if IsValid(player) then
            player:ChatPrint("This item is not rotated.")
        end
        return false
    end
end

concommand.Add("check_rotation", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            checkItemRotation(item, ply)
            break
        end
    end
end)
```

---

### getWidth

**Purpose**

Gets the width of the item, accounting for rotation.

**Parameters**

*None.*

**Returns**

* `width` (*number*): The item's width.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemDimensions(item, player)
    local width = item:getWidth()
    local height = item:getHeight()
    if IsValid(player) then
        player:ChatPrint("Item dimensions: " .. width .. "x" .. height)
    end
end

concommand.Add("item_dimensions", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemDimensions(item, ply)
            break
        end
    end
end)
```

---

### getHeight

**Purpose**

Gets the height of the item, accounting for rotation.

**Parameters**

*None.*

**Returns**

* `height` (*number*): The item's height.

**Realm**

Shared.

**Example Usage**

```lua
local function checkItemSize(item, player)
    local width = item:getWidth()
    local height = item:getHeight()
    local totalSize = width * height
    
    if IsValid(player) then
        player:ChatPrint("Item size: " .. totalSize .. " slots")
    end
end

concommand.Add("item_size", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            checkItemSize(item, ply)
            break
        end
    end
end)
```

---

### getQuantity

**Purpose**

Gets the quantity of the item.

**Parameters**

*None.*

**Returns**

* `quantity` (*number*): The item's quantity.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemQuantity(item, player)
    local quantity = item:getQuantity()
    if IsValid(player) then
        player:ChatPrint("Item quantity: " .. quantity)
    end
end

concommand.Add("item_quantity", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemQuantity(item, ply)
            break
        end
    end
end)
```

---

### eq

**Purpose**

Checks if two items are equal by comparing their IDs.

**Parameters**

* `other` (*Item*): The other item to compare with.

**Returns**

* `isEqual` (*boolean*): True if the items are equal.

**Realm**

Shared.

**Example Usage**

```lua
local function compareItems(item1, item2, player)
    if item1:eq(item2) then
        if IsValid(player) then
            player:ChatPrint("These are the same item!")
        end
        return true
    else
        if IsValid(player) then
            player:ChatPrint("These are different items.")
        end
        return false
    end
end

concommand.Add("compare_items", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        local itemList = {}
        for _, item in pairs(items) do
            table.insert(itemList, item)
        end
        if #itemList >= 2 then
            compareItems(itemList[1], itemList[2], ply)
        end
    end
end)
```

---

### tostring

**Purpose**

Returns a string representation of the item.

**Parameters**

*None.*

**Returns**

* `representation` (*string*): String representation of the item.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemInfo(item, player)
    local info = item:tostring()
    if IsValid(player) then
        player:ChatPrint("Item: " .. info)
    end
end

concommand.Add("item_info", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemInfo(item, ply)
            break
        end
    end
end)
```

---

### getID

**Purpose**

Gets the unique identifier of the item.

**Parameters**

*None.*

**Returns**

* `id` (*number*): The item's unique ID.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemID(item, player)
    local id = item:getID()
    if IsValid(player) then
        player:ChatPrint("Item ID: " .. id)
    end
end

concommand.Add("item_id", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemID(item, ply)
            break
        end
    end
end)
```

---

### getModel

**Purpose**

Gets the model path of the item.

**Parameters**

*None.*

**Returns**

* `model` (*string*): The item's model path.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemModel(item, player)
    local model = item:getModel()
    if IsValid(player) then
        player:ChatPrint("Item model: " .. (model or "No model"))
    end
end

concommand.Add("item_model", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemModel(item, ply)
            break
        end
    end
end)
```

---

### getSkin

**Purpose**

Gets the skin index of the item.

**Parameters**

*None.*

**Returns**

* `skin` (*number*): The item's skin index.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemSkin(item, player)
    local skin = item:getSkin()
    if IsValid(player) then
        player:ChatPrint("Item skin: " .. (skin or 0))
    end
end

concommand.Add("item_skin", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemSkin(item, ply)
            break
        end
    end
end)
```

---

### getPrice

**Purpose**

Gets the price of the item, including any calculated price modifications.

**Parameters**

*None.*

**Returns**

* `price` (*number*): The item's price.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemPrice(item, player)
    local price = item:getPrice()
    if IsValid(player) then
        player:ChatPrint("Item price: " .. price .. " money")
    end
end

concommand.Add("item_price", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemPrice(item, ply)
            break
        end
    end
end)
```

---

### call

**Purpose**

Calls a method on the item with proper context setup.

**Parameters**

* `method` (*string*): The method name to call.
* `client` (*Player|nil*): The client context for the method.
* `entity` (*Entity|nil*): The entity context for the method.
* `...` (*any*): Additional arguments to pass to the method.

**Returns**

* `results` (*any*): The results from the method call.

**Realm**

Shared.

**Example Usage**

```lua
local function useItemMethod(item, methodName, player, entity)
    local results = {item:call(methodName, player, entity)}
    if IsValid(player) then
        player:ChatPrint("Called method " .. methodName .. " on item")
    end
    return unpack(results)
end

concommand.Add("call_item_method", function(ply, cmd, args)
    local char = ply:getChar()
    local methodName = args[1]
    if char and methodName then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            useItemMethod(item, methodName, ply)
            break
        end
    end
end)
```

---

### getOwner

**Purpose**

Gets the player who owns this item.

**Parameters**

*None.*

**Returns**

* `owner` (*Player|nil*): The item owner if found.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemOwner(item, player)
    local owner = item:getOwner()
    if IsValid(player) then
        if IsValid(owner) then
            player:ChatPrint("Item owner: " .. owner:Name())
        else
            player:ChatPrint("Item has no owner.")
        end
    end
end

concommand.Add("item_owner", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemOwner(item, ply)
            break
        end
    end
end)
```

---

### getData

**Purpose**

Gets data associated with the item by key.

**Parameters**

* `key` (*string*): The data key to retrieve.
* `default` (*any*): Default value if the key doesn't exist.

**Returns**

* `value` (*any*): The data value or default.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemData(item, key, player)
    local value = item:getData(key, "not set")
    if IsValid(player) then
        player:ChatPrint(key .. ": " .. tostring(value))
    end
end

concommand.Add("item_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    if char and key then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemData(item, key, ply)
            break
        end
    end
end)
```

---

### getAllData

**Purpose**

Gets all data associated with the item, including entity data.

**Parameters**

*None.*

**Returns**

* `data` (*table*): All item data.

**Realm**

Shared.

**Example Usage**

```lua
local function displayAllItemData(item, player)
    local data = item:getAllData()
    if IsValid(player) then
        player:ChatPrint("Item data:")
        for key, value in pairs(data) do
            player:ChatPrint("  " .. key .. ": " .. tostring(value))
        end
    end
end

concommand.Add("all_item_data", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayAllItemData(item, ply)
            break
        end
    end
end)
```

---

### hook

**Purpose**

Adds a hook function to the item.

**Parameters**

* `name` (*string*): The hook name.
* `func` (*function*): The hook function.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupItemHook(item, hookName, hookFunction)
    item:hook(hookName, hookFunction)
    print("Added hook " .. hookName .. " to item " .. item:getID())
end

concommand.Add("add_item_hook", function(ply, cmd, args)
    local char = ply:getChar()
    local hookName = args[1]
    if char and hookName then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            setupItemHook(item, hookName, function(self, ...)
                print("Hook " .. hookName .. " called on item " .. self:getID())
            end)
            break
        end
    end
end)
```

---

### postHook

**Purpose**

Adds a post-hook function to the item.

**Parameters**

* `name` (*string*): The hook name.
* `func` (*function*): The post-hook function.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupItemPostHook(item, hookName, hookFunction)
    item:postHook(hookName, hookFunction)
    print("Added post-hook " .. hookName .. " to item " .. item:getID())
end

concommand.Add("add_item_post_hook", function(ply, cmd, args)
    local char = ply:getChar()
    local hookName = args[1]
    if char and hookName then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            setupItemPostHook(item, hookName, function(self, result, ...)
                print("Post-hook " .. hookName .. " called on item " .. self:getID() .. " with result: " .. tostring(result))
            end)
            break
        end
    end
end)
```

---

### onRegistered

**Purpose**

Called when the item is registered (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupItemRegistration(item)
    function item:onRegistered()
        print("Item " .. self.uniqueID .. " has been registered!")
        -- Custom registration logic here
    end
end

hook.Add("ItemRegistered", "SetupItemRegistration", function(item)
    setupItemRegistration(item)
end)
```

---

### print

**Purpose**

Prints information about the item to the console.

**Parameters**

* `detail` (*boolean|nil*): Whether to print detailed information.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function printItemInfo(item, detailed)
    item:print(detailed)
end

concommand.Add("print_item", function(ply, cmd, args)
    local char = ply:getChar()
    local detailed = tobool(args[1])
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            printItemInfo(item, detailed)
            break
        end
    end
end)
```

---

### printData

**Purpose**

Prints all item data to the console.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function printItemData(item)
    item:printData()
end

concommand.Add("print_item_data", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            printItemData(item)
            break
        end
    end
end)
```

---

### getName

**Purpose**

Gets the display name of the item.

**Parameters**

*None.*

**Returns**

* `name` (*string*): The item's display name.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemName(item, player)
    local name = item:getName()
    if IsValid(player) then
        player:ChatPrint("Item name: " .. name)
    end
end

concommand.Add("item_name", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemName(item, ply)
            break
        end
    end
end)
```

---

### getDesc

**Purpose**

Gets the description of the item.

**Parameters**

*None.*

**Returns**

* `description` (*string*): The item's description.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemDescription(item, player)
    local description = item:getDesc()
    if IsValid(player) then
        player:ChatPrint("Item description: " .. description)
    end
end

concommand.Add("item_desc", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemDescription(item, ply)
            break
        end
    end
end)
```

---

### removeFromInventory

**Purpose**

Removes the item from its current inventory.

**Parameters**

* `preserveItem` (*boolean|nil*): Whether to preserve the item instance.

**Returns**

* `promise` (*Promise*): Promise that resolves when removal is complete.

**Realm**

Server.

**Example Usage**

```lua
local function removeItemFromInventory(item, player)
    item:removeFromInventory():next(function()
        if IsValid(player) then
            player:ChatPrint("Item removed from inventory!")
        end
    end)
end

concommand.Add("remove_item_from_inv", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            removeItemFromInventory(item, ply)
            break
        end
    end
end)
```

---

### delete

**Purpose**

Deletes the item from the database and destroys it.

**Parameters**

*None.*

**Returns**

* `promise` (*Promise*): Promise that resolves when deletion is complete.

**Realm**

Server.

**Example Usage**

```lua
local function deleteItem(item, player)
    item:delete():next(function()
        if IsValid(player) then
            player:ChatPrint("Item deleted!")
        end
    end)
end

concommand.Add("delete_item", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            deleteItem(item, ply)
            break
        end
    end
end)
```

---

### remove

**Purpose**

Removes the item from the world and inventory, then deletes it.

**Parameters**

*None.*

**Returns**

* `promise` (*Promise*): Promise that resolves when removal is complete.

**Realm**

Server.

**Example Usage**

```lua
local function removeItem(item, player)
    item:remove():next(function()
        if IsValid(player) then
            player:ChatPrint("Item removed!")
        end
    end)
end

concommand.Add("remove_item", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            removeItem(item, ply)
            break
        end
    end
end)
```

---

### destroy

**Purpose**

Destroys the item instance and notifies clients.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function destroyItem(item, player)
    item:destroy()
    if IsValid(player) then
        player:ChatPrint("Item destroyed!")
    end
end

concommand.Add("destroy_item", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            destroyItem(item, ply)
            break
        end
    end
end)
```

---

### onDisposed

**Purpose**

Called when the item is disposed (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemDisposal(item)
    function item:onDisposed()
        print("Item " .. self:getID() .. " has been disposed!")
        -- Custom disposal logic here
    end
end

hook.Add("ItemCreated", "SetupItemDisposal", function(item)
    setupItemDisposal(item)
end)
```

---

### getEntity

**Purpose**

Gets the world entity associated with this item.

**Parameters**

*None.*

**Returns**

* `entity` (*Entity|nil*): The item entity if it exists in the world.

**Realm**

Server.

**Example Usage**

```lua
local function checkItemEntity(item, player)
    local entity = item:getEntity()
    if IsValid(player) then
        if IsValid(entity) then
            player:ChatPrint("Item has a world entity at position: " .. tostring(entity:GetPos()))
        else
            player:ChatPrint("Item is not in the world.")
        end
    end
end

concommand.Add("check_item_entity", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            checkItemEntity(item, ply)
            break
        end
    end
end)
```

---

### spawn

**Purpose**

Spawns the item as a world entity.

**Parameters**

* `position` (*Vector|Player*): Position to spawn at, or player to drop near.
* `angles` (*Angle|nil*): Angles for the spawned entity.

**Returns**

* `entity` (*Entity|nil*): The spawned entity if successful.

**Realm**

Server.

**Example Usage**

```lua
local function spawnItemInWorld(item, position, angles, player)
    local entity = item:spawn(position, angles)
    if IsValid(entity) then
        if IsValid(player) then
            player:ChatPrint("Item spawned in world!")
        end
        return entity
    else
        if IsValid(player) then
            player:ChatPrint("Failed to spawn item.")
        end
        return nil
    end
end

concommand.Add("spawn_item", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            local pos = ply:getItemDropPos()
            local ang = ply:EyeAngles()
            spawnItemInWorld(item, pos, ang, ply)
            break
        end
    end
end)
```

---

### transfer

**Purpose**

Transfers the item to a new inventory.

**Parameters**

* `newInventory` (*Inventory*): The inventory to transfer to.
* `bBypass` (*boolean|nil*): Whether to bypass access checks.

**Returns**

* `success` (*boolean*): True if the transfer was successful.

**Realm**

Server.

**Example Usage**

```lua
local function transferItemToInventory(item, newInventory, player)
    if item:transfer(newInventory) then
        if IsValid(player) then
            player:ChatPrint("Item transferred successfully!")
        end
        return true
    else
        if IsValid(player) then
            player:ChatPrint("Failed to transfer item.")
        end
        return false
    end
end

concommand.Add("transfer_item", function(ply, cmd, args)
    local char = ply:getChar()
    local targetID = tonumber(args[1])
    if char and targetID then
        local inv = char:getInv()
        local targetInv = lia.inventory.instances[targetID]
        local items = inv:getItems()
        for _, item in pairs(items) do
            if targetInv then
                transferItemToInventory(item, targetInv, ply)
            end
            break
        end
    end
end)
```

---

### onInstanced

**Purpose**

Called when the item is instantiated (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemInstance(item)
    function item:onInstanced()
        print("Item " .. self:getID() .. " has been instantiated!")
        -- Custom instantiation logic here
    end
end

hook.Add("ItemCreated", "SetupItemInstance", function(item)
    setupItemInstance(item)
end)
```

---

### onSync

**Purpose**

Called when the item is synchronized (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemSync(item)
    function item:onSync()
        print("Item " .. self:getID() .. " has been synchronized!")
        -- Custom sync logic here
    end
end

hook.Add("ItemCreated", "SetupItemSync", function(item)
    setupItemSync(item)
end)
```

---

### onRemoved

**Purpose**

Called when the item is removed (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemRemoval(item)
    function item:onRemoved()
        print("Item " .. self:getID() .. " has been removed!")
        -- Custom removal logic here
    end
end

hook.Add("ItemCreated", "SetupItemRemoval", function(item)
    setupItemRemoval(item)
end)
```

---

### onRestored

**Purpose**

Called when the item is restored from storage (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemRestoration(item)
    function item:onRestored(inventory)
        print("Item " .. self:getID() .. " has been restored to inventory " .. inventory:getID())
        -- Custom restoration logic here
    end
end

hook.Add("ItemCreated", "SetupItemRestoration", function(item)
    setupItemRestoration(item)
end)
```

---

### sync

**Purpose**

Synchronizes the item data with clients.

**Parameters**

* `recipient` (*Player|nil*): Specific client to sync with, or nil for all clients.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncItemToPlayer(item, player)
    item:sync(player)
    if IsValid(player) then
        player:ChatPrint("Item synchronized!")
    end
end

concommand.Add("sync_item", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            syncItemToPlayer(item, ply)
            break
        end
    end
end)
```

---

### setData

**Purpose**

Sets data for the item and handles networking and persistence.

**Parameters**

* `key` (*string*): The data key to set.
* `value` (*any*): The value to set.
* `receivers` (*table|nil*): Specific clients to send updates to.
* `noSave` (*boolean|nil*): Whether to skip database saving.
* `noCheckEntity` (*boolean|nil*): Whether to skip entity data checking.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setItemCustomData(item, key, value, player)
    item:setData(key, value, {player})
    if IsValid(player) then
        player:ChatPrint("Set " .. key .. " to " .. tostring(value))
    end
end

concommand.Add("set_item_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    local value = args[2]
    if char and key and value then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            setItemCustomData(item, key, value, ply)
            break
        end
    end
end)
```

---

### addQuantity

**Purpose**

Adds to the item's quantity.

**Parameters**

* `quantity` (*number*): The amount to add.
* `receivers` (*table|nil*): Specific clients to send updates to.
* `noCheckEntity` (*boolean|nil*): Whether to skip entity data checking.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function addItemQuantity(item, amount, player)
    item:addQuantity(amount, {player})
    if IsValid(player) then
        player:ChatPrint("Added " .. amount .. " to item quantity!")
    end
end

concommand.Add("add_item_quantity", function(ply, cmd, args)
    local char = ply:getChar()
    local amount = tonumber(args[1])
    if char and amount then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            addItemQuantity(item, amount, ply)
            break
        end
    end
end)
```

---

### setQuantity

**Purpose**

Sets the item's quantity to a specific value.

**Parameters**

* `quantity` (*number*): The new quantity value.
* `receivers` (*table|nil*): Specific clients to send updates to.
* `noCheckEntity` (*boolean|nil*): Whether to skip entity data checking.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setItemQuantity(item, quantity, player)
    item:setQuantity(quantity, {player})
    if IsValid(player) then
        player:ChatPrint("Set item quantity to " .. quantity)
    end
end

concommand.Add("set_item_quantity", function(ply, cmd, args)
    local char = ply:getChar()
    local quantity = tonumber(args[1])
    if char and quantity then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            setItemQuantity(item, quantity, ply)
            break
        end
    end
end)
```

---

### interact

**Purpose**

Handles item interaction with proper permission checks and hook execution.

**Parameters**

* `action` (*string*): The action to perform.
* `client` (*Player*): The client performing the action.
* `entity` (*Entity|nil*): The entity context for the interaction.
* `data` (*any*): Additional data for the interaction.

**Returns**

* `success` (*boolean*): True if the interaction was successful.

**Realm**

Server.

**Example Usage**

```lua
local function interactWithItem(item, action, player, entity)
    if item:interact(action, player, entity) then
        player:ChatPrint("Item interaction successful!")
        return true
    else
        player:ChatPrint("Item interaction failed!")
        return false
    end
end

concommand.Add("interact_item", function(ply, cmd, args)
    local char = ply:getChar()
    local action = args[1]
    if char and action then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            interactWithItem(item, action, ply)
            break
        end
    end
end)
```

---

### getCategory

**Purpose**

Gets the localized category name of the item.

**Parameters**

*None.*

**Returns**

* `category` (*string*): The item's category name.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemCategory(item, player)
    local category = item:getCategory()
    if IsValid(player) then
        player:ChatPrint("Item category: " .. category)
    end
end

concommand.Add("item_category", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        local items = inv:getItems()
        for _, item in pairs(items) do
            displayItemCategory(item, ply)
            break
        end
    end
end)
```

---
