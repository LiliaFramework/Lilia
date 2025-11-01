# Item Meta

Item management system for the Lilia framework.

---

Overview

The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.

---

### isRotated

**Purpose**

Checks if the item is currently rotated in the inventory grid

**When Called**

When determining item dimensions or display orientation

**Returns**

* Boolean indicating if the item is rotated

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
if item:isRotated() then
    print("Item is rotated")
end

```

**Medium Complexity:**
```lua
local width = item:isRotated() and item:getHeight() or item:getWidth()
local height = item:isRotated() and item:getWidth() or item:getHeight()

```

**High Complexity:**
```lua
local function getItemDisplaySize(item)
    if item:isRotated() then
        return item:getHeight(), item:getWidth()
    else
        return item:getWidth(), item:getHeight()
    end
end
local displayW, displayH = getItemDisplaySize(myItem)

```

---

### getWidth

**Purpose**

Gets the current width of the item considering rotation

**When Called**

When determining item grid space requirements or display size

**Returns**

* Number representing the item's width in grid units

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local width = item:getWidth()

```

**Medium Complexity:**
```lua
if item:getWidth() > maxWidth then
    print("Item too wide for slot")
end

```

**High Complexity:**
```lua
local function canPlaceItem(inventory, item, x, y)
    local width = item:getWidth()
    local height = item:getHeight()
    return inventory:canPlaceAt(x, y, width, height)
end
if canPlaceItem(myInventory, myItem, 1, 1) then
    inventory:placeItem(myItem, 1, 1)
end

```

---

### getHeight

**Purpose**

Gets the current height of the item considering rotation

**When Called**

When determining item grid space requirements or display size

**Returns**

* Number representing the item's height in grid units

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local height = item:getHeight()

```

**Medium Complexity:**
```lua
local totalSpace = item:getWidth() * item:getHeight()

```

**High Complexity:**
```lua
local function calculateInventorySpace(items)
    local totalWidth = 0
    local totalHeight = 0
    for _, item in ipairs(items) do
        totalWidth = math.max(totalWidth, item:getWidth())
        totalHeight = totalHeight + item:getHeight()
    end
    return totalWidth, totalHeight
end
local neededW, neededH = calculateInventorySpace(selectedItems)

```

---

### getQuantity

**Purpose**

Gets the current quantity of the item

**When Called**

When checking how many of this item exist, for display or validation

**Returns**

* Number representing the item's current quantity

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local count = item:getQuantity()

```

**Medium Complexity:**
```lua
if item:getQuantity() >= requiredAmount then
    useItem(item)
end

```

**High Complexity:**
```lua
local function calculateTotalValue(items)
    local total = 0
    for _, item in ipairs(items) do
        local quantity = item:getQuantity()
        local value = item:getPrice() or 0
        total = total + (quantity * value)
    end
    return total
end
local inventoryValue = calculateTotalValue(playerInventory:getItems())

```

---

### tostring

**Purpose**

Creates a string representation of the item for debugging/logging

**When Called**

For logging, debugging, or console output

**Returns**

* String representation of the item

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
print(item:tostring())

```

**Medium Complexity:**
```lua
lia.information("Processing " .. item:tostring())

```

**High Complexity:**
```lua
local function logItemTransaction(item, action, player)
    local logEntry = string.format("[%s] %s performed %s on %s",
    os.date("%H:%M:%S"),
    player:GetName(),
    action,
    item:tostring()
    )
    file.Append("item_transactions.txt", logEntry .. "\n")
end
logItemTransaction(myItem, "used", player)

```

---

### getID

**Purpose**

Gets the unique instance ID of this item

**When Called**

When you need to reference this specific item instance

**Returns**

* Number representing the item's unique ID

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local itemID = item:getID()

```

**Medium Complexity:**
```lua
if item:getID() == targetID then
    selectItem(item)
end

```

**High Complexity:**
```lua
local function findItemByID(inventory, targetID)
    for _, item in pairs(inventory:getItems()) do
        if item:getID() == targetID then
            return item
        end
    end
    return nil
end
local foundItem = findItemByID(playerInventory, 12345)

```

---

### getModel

**Purpose**

Gets the model path for the item

**When Called**

When displaying the item or creating item entities

**Returns**

* String representing the item's model path

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local model = item:getModel()

```

**Medium Complexity:**
```lua
if item:getModel() then
    entity:SetModel(item:getModel())
end

```

**High Complexity:**
```lua
local function createItemEntity(item, position)
    local ent = ents.Create("prop_physics")
    ent:SetModel(item:getModel() or "models/error.mdl")
    ent:SetPos(position)
    ent:Spawn()
    if item:getSkin() then
        ent:SetSkin(item:getSkin())
    end
    return ent
end
local itemEntity = createItemEntity(myItem, Vector(0, 0, 0))

```

---

### getSkin

**Purpose**

Gets the skin index for the item's model

**When Called**

When setting up item display or entity appearance

**Returns**

* Number representing the skin index, or nil if none set

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local skin = item:getSkin()

```

**Medium Complexity:**
```lua
if item:getSkin() then
    entity:SetSkin(item:getSkin())
end

```

**High Complexity:**
```lua
local function applyItemAppearance(entity, item)
    entity:SetModel(item:getModel())
    entity:SetSkin(item:getSkin() or 0)
    for k, v in pairs(item:getBodygroups()) do
        entity:SetBodygroup(k, v)
    end
    entity:SetColor(item:getData("color", Color(255, 255, 255)))
end
applyItemAppearance(myEntity, myItem)

```

---

### getBodygroups

**Purpose**

Gets the bodygroup settings for the item's model

**When Called**

When setting up item display or entity appearance

**Returns**

* Table of bodygroup settings, empty table if none set

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local bodygroups = item:getBodygroups()

```

**Medium Complexity:**
```lua
for id, value in pairs(item:getBodygroups()) do
    entity:SetBodygroup(id, value)
end

```

**High Complexity:**
```lua
local function applyBodygroups(entity, bodygroups)
    for bodygroupID, bodygroupValue in pairs(bodygroups) do
        if isstring(bodygroupID) then
            -- Handle named bodygroups
            local id = entity:FindBodygroupByName(bodygroupID)
            if id ~= -1 then
                entity:SetBodygroup(id, bodygroupValue)
            end
            else
                entity:SetBodygroup(bodygroupID, bodygroupValue)
            end
        end
    end
    applyBodygroups(myEntity, item:getBodygroups())

```

---

### getPrice

**Purpose**

Gets the current price of the item, potentially calculated dynamically

**When Called**

When selling, trading, or displaying item value

**Returns**

* Number representing the item's price

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local price = item:getPrice()

```

**Medium Complexity:**
```lua
if player:getMoney() >= item:getPrice() then
    player:buyItem(item)
end

```

**High Complexity:**
```lua
local function calculateTotalCost(items)
    local total = 0
    for _, item in ipairs(items) do
        local price = item:getPrice()
        local quantity = item:getQuantity()
        total = total + (price * quantity)
    end
    -- Apply bulk discount
    if #items > 5 then
        total = total * 0.9
    end
    return total
end
local cost = calculateTotalCost(selectedItems)

```

---

### call

**Purpose**

Calls an item method with specified player and entity context

**When Called**

When executing item functions that need player/entity context

**Parameters**

* `method` (*unknown*): String name of the method to call
* `method` (*unknown*): String name of the method to call
* `client` (*unknown*): Player entity to set as context
* `client` (*unknown*): Player entity to set as context
* `entity` (*unknown*): Entity to set as context
* `entity` (*unknown*): Entity to set as context
* `...` (*unknown*): Additional arguments to pass to the method

**Returns**

* The return values from the called method

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
item:call("use", player)

```

**Medium Complexity:**
```lua
local success = item:call("canUse", player, entity)
if success then
    item:call("onUse", player, entity)
end

```

**High Complexity:**
```lua
local function executeItemAction(item, action, player, entity, ...)
    local canRun, reason = item:call("can" .. action, player, entity, ...)
    if canRun then
        local result = {item:call("on" .. action, player, entity, ...)}
        hook.Run("OnItem" .. action, item, player, entity, unpack(result))
        return true, unpack(result)
        else
            player:notifyError(reason or "Cannot perform action")
            return false
        end
    end
    local success, data = executeItemAction(myItem, "Use", player, nil, target)

```

---

### getOwner

**Purpose**

Gets the player who owns this item

**When Called**

When you need to determine item ownership or permissions

**Returns**

* Player entity who owns the item, or nil if not found

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local owner = item:getOwner()

```

**Medium Complexity:**
```lua
if item:getOwner() == player then
    allowModification = true
end

```

**High Complexity:**
```lua
local function canPlayerAccessItem(player, item)
    local owner = item:getOwner()
    if not owner then return false end
        -- Check if player is the owner
        if owner == player then return true end
            -- Check if player has admin permissions
            if player:isAdmin() then return true end
                -- Check if item is in shared inventory
                local inventory = lia.inventory.instances[item.invID]
                if inventory and inventory:getData("shared") then
                    return inventory:canAccess("view", {client = player})
                end
                return false
            end
            if canPlayerAccessItem(client, myItem) then
                -- Allow access
            end

```

---

### getData

**Purpose**

Retrieves data from the item's data table with fallback to entity data

**When Called**

When accessing item-specific data or configuration

**Parameters**

* `key` (*unknown*): The data key to retrieve
* `key` (*unknown*): The data key to retrieve
* `default` (*unknown*): Optional default value if key doesn't exist
* `default` (*unknown*): Optional default value if key doesn't exist

**Returns**

* The data value or default value if key doesn't exist

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local durability = item:getData("durability", 100)

```

**Medium Complexity:**
```lua
local color = item:getData("color", Color(255, 255, 255))
entity:SetColor(color)

```

**High Complexity:**
```lua
local function applyItemModifiers(entity, item)
    -- Apply durability-based modifications
    local durability = item:getData("durability", 100)
    local maxDurability = item:getData("maxDurability", 100)
    local durabilityPercent = durability / maxDurability
    -- Reduce effectiveness based on durability
    if item.damage then
        entity:SetHealth(entity:GetMaxHealth() * durabilityPercent)
    end
    -- Apply custom modifiers
    local modifiers = item:getData("modifiers", {})
    for modifierType, modifierValue in pairs(modifiers) do
        applyModifier(entity, modifierType, modifierValue * durabilityPercent)
    end
end
applyItemModifiers(myEntity, myItem)

```

---

### getAllData

**Purpose**

Gets all data associated with the item from both item and entity

**When Called**

When you need a complete view of all item data

**Returns**

* Table containing all item data

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local allData = item:getAllData()

```

**Medium Complexity:**
```lua
local data = item:getAllData()
for key, value in pairs(data) do
    print(key .. ": " .. tostring(value))
end

```

**High Complexity:**
```lua
local function serializeItemForSave(item)
    local data = item:getAllData()
    -- Remove runtime-only data
    data.entity = nil
    data.player = nil
    -- Add metadata
    data.savedAt = os.time()
    data.version = "1.0"
    return util.TableToJSON(data)
end
local serializedData = serializeItemForSave(myItem)
file.Write("item_backup.txt", serializedData)

```

---

### hook

**Purpose**

Registers a hook function to be called before item actions

**When Called**

During item configuration to add custom behavior

**Parameters**

* `name` (*unknown*): String name of the hook (e.g., "use", "drop")
* `name` (*unknown*): String name of the hook (e.g., "use", "drop")
* `func` (*unknown*): Function to call when the hook is triggered
* `func` (*unknown*): Function to call when the hook is triggered

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
item:hook("use", function(item)
print("Item used!")
end)

```

**Medium Complexity:**
```lua
item:hook("drop", function(item)
if item:getData("soulbound") then
    return false -- Prevent dropping
end
end)

```

**High Complexity:**
```lua
item:hook("use", function(item)
-- Check cooldown
local lastUsed = item:getData("lastUsed", 0)
local cooldown = item:getData("cooldown", 60)
if CurTime() - lastUsed < cooldown then
    item.player:notifyError("Item is on cooldown")
    return false
end
-- Update last used time
item:setData("lastUsed", CurTime())
-- Apply custom effects
applyItemEffect(item.player, item.uniqueID)
end)

```

---

### postHook

**Purpose**

Registers a post-hook function to be called after item actions

**When Called**

During item configuration to add cleanup or follow-up behavior

**Parameters**

* `name` (*unknown*): String name of the hook (e.g., "use", "drop")
* `name` (*unknown*): String name of the hook (e.g., "use", "drop")
* `func` (*unknown*): Function to call after the hook is triggered
* `func` (*unknown*): Function to call after the hook is triggered

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
item:postHook("use", function(item)
print("Item use completed")
end)

```

**Medium Complexity:**
```lua
item:postHook("drop", function(item)
lia.log.add(item.player, "item_dropped", item:getName())
end)

```

**High Complexity:**
```lua
item:postHook("use", function(item, result)
-- Log usage statistics
local stats = lia.data.get("item_usage_stats", {})
stats[item.uniqueID] = (stats[item.uniqueID] or 0) + 1
lia.data.set("item_usage_stats", stats)
-- Apply post-use effects
if result == true and item:getData("consumable") then
    item:addQuantity(-1)
end
-- Trigger achievements
if stats[item.uniqueID] >= 100 then
    item.player:unlockAchievement("frequent_user")
end
end)

```

---

### onRegistered

**Purpose**

Called when the item is registered with the system

**When Called**

Automatically during item registration

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRegistered()
    print("Item registered: " .. self.uniqueID)
end

```

**Medium Complexity:**
```lua
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRegistered()
    -- Precache model
    if self.model then
        util.PrecacheModel(self.model)
    end
    -- Register with item categories
    if self.category then
        local categories = lia.data.get("item_categories", {})
        categories[self.category] = categories[self.category] or {}
        table.insert(categories[self.category], self.uniqueID)
        lia.data.set("item_categories", categories)
    end
    -- Set up default data
    self.defaultData = self.defaultData or {}
    for key, value in pairs(self.defaultData) do
        if self:getData(key) == nil then
            self:setData(key, value)
        end
    end
end

```

---

### onRegistered

**Purpose**

Called when the item is registered with the system

**When Called**

Automatically during item registration

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRegistered()
    print("Item registered: " .. self.uniqueID)
end

```

**Medium Complexity:**
```lua
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRegistered()
    -- Precache model
    if self.model then
        util.PrecacheModel(self.model)
    end
    -- Register with item categories
    if self.category then
        local categories = lia.data.get("item_categories", {})
        categories[self.category] = categories[self.category] or {}
        table.insert(categories[self.category], self.uniqueID)
        lia.data.set("item_categories", categories)
    end
    -- Set up default data
    self.defaultData = self.defaultData or {}
    for key, value in pairs(self.defaultData) do
        if self:getData(key) == nil then
            self:setData(key, value)
        end
    end
end

```

---

### onRegistered

**Purpose**

Called when the item is registered with the system

**When Called**

Automatically during item registration

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRegistered()
    print("Item registered: " .. self.uniqueID)
end

```

**Medium Complexity:**
```lua
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRegistered()
    -- Precache model
    if self.model then
        util.PrecacheModel(self.model)
    end
    -- Register with item categories
    if self.category then
        local categories = lia.data.get("item_categories", {})
        categories[self.category] = categories[self.category] or {}
        table.insert(categories[self.category], self.uniqueID)
        lia.data.set("item_categories", categories)
    end
    -- Set up default data
    self.defaultData = self.defaultData or {}
    for key, value in pairs(self.defaultData) do
        if self:getData(key) == nil then
            self:setData(key, value)
        end
    end
end

```

---

### onRegistered

**Purpose**

Called when the item is registered with the system

**When Called**

Automatically during item registration

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRegistered()
    print("Item registered: " .. self.uniqueID)
end

```

**Medium Complexity:**
```lua
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRegistered()
    -- Precache model
    if self.model then
        util.PrecacheModel(self.model)
    end
    -- Register with item categories
    if self.category then
        local categories = lia.data.get("item_categories", {})
        categories[self.category] = categories[self.category] or {}
        table.insert(categories[self.category], self.uniqueID)
        lia.data.set("item_categories", categories)
    end
    -- Set up default data
    self.defaultData = self.defaultData or {}
    for key, value in pairs(self.defaultData) do
        if self:getData(key) == nil then
            self:setData(key, value)
        end
    end
end

```

---

### print

**Purpose**

Prints basic item information to the server console

**When Called**

For debugging or logging item state

**Parameters**

* `detail` (*unknown*): Optional boolean to show detailed information
* `detail` (*unknown*): Optional boolean to show detailed information

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
item:print()

```

**Medium Complexity:**
```lua
item:print(true) -- Show detailed info

```

**High Complexity:**
```lua
local function debugInventory(inventory)
    for _, item in pairs(inventory:getItems()) do
        item:print(true)
        print("---")
    end
end
debugInventory(player:getInventory())

```

---

### printData

**Purpose**

Prints all item data to the server console

**When Called**

For detailed debugging of item data

**Returns**

* Nothing

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
item:printData()

```

**Medium Complexity:**
```lua
if item:getData("debug") then
    item:printData()
end

```

**High Complexity:**
```lua
local function auditItemData(item)
    item:printData()
    -- Check for invalid data
    local data = item:getAllData()
    for key, value in pairs(data) do
        if istable(value) and table.Count(value) > 100 then
            lia.log.add(nil, "large_data_warning", item:getID(), key, table.Count(value))
        end
    end
end
auditItemData(suspiciousItem)

```

---

### getName

**Purpose**

Gets the display name of the item

**When Called**

When displaying item names in UI or chat

**Returns**

* String representing the item's name

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local name = item:getName()

```

**Medium Complexity:**
```lua
chat.AddText(Color(255, 255, 255), "You received: ", item:getName())

```

**High Complexity:**
```lua
local function formatItemName(item)
    local name = item:getName()
    local quality = item:getData("quality")
    if quality then
        local colors = {
        common = Color(255, 255, 255),
        rare = Color(0, 255, 255),
        epic = Color(255, 0, 255),
        legendary = Color(255, 165, 0)
        }
        return colors[quality], name
    end
    return Color(255, 255, 255), name
end
local color, displayName = formatItemName(myItem)

```

---

### getDesc

**Purpose**

Gets the description of the item

**When Called**

When displaying item details or tooltips

**Returns**

* String representing the item's description

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local desc = item:getDesc()

```

**Medium Complexity:**
```lua
print("Item description: " .. item:getDesc())

```

**High Complexity:**
```lua
local function getFormattedDescription(item)
    local desc = item:getDesc()
    -- Add dynamic information
    if item:getData("durability") then
        local durability = item:getData("durability", 100)
        local maxDurability = item:getData("maxDurability", 100)
        desc = desc .. string.format("\nDurability: %d/%d", durability, maxDurability)
    end
    if item:getData("level") then
        desc = desc .. string.format("\nRequired Level: %d", item:getData("level"))
    end
    return desc
end
local fullDesc = getFormattedDescription(myItem)

```

---

### removeFromInventory

**Purpose**

Removes the item from its current inventory without deleting it

**When Called**

When transferring items between inventories or temporarily removing them

**Parameters**

* `preserveItem` (*unknown*): Optional boolean to preserve item data in database
* `preserveItem` (*unknown*): Optional boolean to preserve item data in database

**Returns**

* Deferred object that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:removeFromInventory()

```

**Medium Complexity:**
```lua
item:removeFromInventory(true):next(function()
print("Item removed but preserved")
end)

```

**High Complexity:**
```lua
local function transferItem(item, fromInv, toInv)
    return item:removeFromInventory(true):next(function()
    return toInv:add(item)
end):next(function()
lia.log.add(nil, "item_transferred",
item:getID(), fromInv:getID(), toInv:getID())
end)
end
transferItem(myItem, playerInv, bankInv)

```

---

### delete

**Purpose**

Permanently deletes the item from the database and system

**When Called**

When completely removing an item from the game world

**Returns**

* Deferred object that resolves when deletion is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:delete()

```

**Medium Complexity:**
```lua
item:delete():next(function()
print("Item permanently deleted")
end)

```

**High Complexity:**
```lua
local function safelyDeleteExpiredItems()
    local expiredItems = lia.db.select("*", "items", "expiry_date < " .. os.time())
    expiredItems:next(function(results)
    for _, row in ipairs(results.results or {}) do
        local item = lia.item.instances[tonumber(row.itemID)]
        if item then
            -- Log deletion reason
            lia.log.add(nil, "expired_item_deleted", row.itemID, row.uniqueID)
            -- Delete the item
            item:delete()
        end
    end
end)
end
safelyDeleteExpiredItems()

```

---

### remove

**Purpose**

Completely removes the item from the world, inventory, and database

**When Called**

When an item is used up, destroyed, or needs to be completely eliminated

**Returns**

* Deferred object that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:remove()

```

**Medium Complexity:**
```lua
item:remove():next(function()
player:notify("Item consumed")
end)

```

**High Complexity:**
```lua
local function consumeItemWithEffects(item, player)
    -- Apply item effects before removal
    if item.onConsume then
        item:call("onConsume", player)
    end
    -- Remove the item
    return item:remove():next(function()
    -- Post-consumption effects
    if item:getData("reusable") then
        -- Create a new instance if reusable
        local newItem = lia.item.new(item.uniqueID, 1)
        player:getInventory():add(newItem)
    end
    -- Trigger achievements
    local consumedCount = player:getData("items_consumed", 0) + 1
    player:setData("items_consumed", consumedCount)
    if consumedCount >= 100 then
        player:unlockAchievement("consumptive")
    end
end)
end
consumeItemWithEffects(myItem, player)

```

---

### destroy

**Purpose**

Destroys the item instance and notifies all clients to remove it

**When Called**

When an item needs to be removed from the game world immediately

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:destroy()

```

**Medium Complexity:**
```lua
if item:getData("temporary") then
    item:destroy()
end

```

**High Complexity:**
```lua
local function destroyItemsInRadius(position, radius)
    local items = ents.FindInSphere(position, radius)
    local destroyedCount = 0
    for _, ent in ipairs(items) do
        if ent:GetClass() == "lia_item" and ent.liaItemID then
            local item = lia.item.instances[ent.liaItemID]
            if item then
                -- Log destruction
                lia.log.add(nil, "area_destruction", item:getID(), item:getName())
                item:destroy()
                destroyedCount = destroyedCount + 1
            end
        end
    end
    lia.chat.send(nil, "Destroyed " .. destroyedCount .. " items in area")
    return destroyedCount
end
destroyItemsInRadius(explosionPos, 500)

```

---

### onDisposed

**Purpose**

Called when the item is disposed/destroyed

**When Called**

Automatically when destroy() is called

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onDisposed()
    -- Cleanup code here
end

```

**Medium Complexity:**
```lua
function ITEM:onDisposed()
    -- Clean up associated entities
    if self.associatedEntity then
        SafeRemoveEntity(self.associatedEntity)
    end
end

```

**High Complexity:**
```lua
function ITEM:onDisposed()
    -- Comprehensive cleanup
    if self.temporaryEntities then
        for _, ent in ipairs(self.temporaryEntities) do
            SafeRemoveEntity(ent)
        end
        self.temporaryEntities = nil
    end
    -- Remove from global item lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[self:getID()] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log disposal
    lia.log.add(nil, "item_disposed", self:getID(), self.uniqueID)
    -- Trigger disposal hooks
    hook.Run("OnItemDisposed", self)
end

```

---

### onDisposed

**Purpose**

Called when the item is disposed/destroyed

**When Called**

Automatically when destroy() is called

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onDisposed()
    -- Cleanup code here
end

```

**Medium Complexity:**
```lua
function ITEM:onDisposed()
    -- Clean up associated entities
    if self.associatedEntity then
        SafeRemoveEntity(self.associatedEntity)
    end
end

```

**High Complexity:**
```lua
function ITEM:onDisposed()
    -- Comprehensive cleanup
    if self.temporaryEntities then
        for _, ent in ipairs(self.temporaryEntities) do
            SafeRemoveEntity(ent)
        end
        self.temporaryEntities = nil
    end
    -- Remove from global item lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[self:getID()] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log disposal
    lia.log.add(nil, "item_disposed", self:getID(), self.uniqueID)
    -- Trigger disposal hooks
    hook.Run("OnItemDisposed", self)
end

```

---

### onDisposed

**Purpose**

Called when the item is disposed/destroyed

**When Called**

Automatically when destroy() is called

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onDisposed()
    -- Cleanup code here
end

```

**Medium Complexity:**
```lua
function ITEM:onDisposed()
    -- Clean up associated entities
    if self.associatedEntity then
        SafeRemoveEntity(self.associatedEntity)
    end
end

```

**High Complexity:**
```lua
function ITEM:onDisposed()
    -- Comprehensive cleanup
    if self.temporaryEntities then
        for _, ent in ipairs(self.temporaryEntities) do
            SafeRemoveEntity(ent)
        end
        self.temporaryEntities = nil
    end
    -- Remove from global item lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[self:getID()] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log disposal
    lia.log.add(nil, "item_disposed", self:getID(), self.uniqueID)
    -- Trigger disposal hooks
    hook.Run("OnItemDisposed", self)
end

```

---

### onDisposed

**Purpose**

Called when the item is disposed/destroyed

**When Called**

Automatically when destroy() is called

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onDisposed()
    -- Cleanup code here
end

```

**Medium Complexity:**
```lua
function ITEM:onDisposed()
    -- Clean up associated entities
    if self.associatedEntity then
        SafeRemoveEntity(self.associatedEntity)
    end
end

```

**High Complexity:**
```lua
function ITEM:onDisposed()
    -- Comprehensive cleanup
    if self.temporaryEntities then
        for _, ent in ipairs(self.temporaryEntities) do
            SafeRemoveEntity(ent)
        end
        self.temporaryEntities = nil
    end
    -- Remove from global item lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[self:getID()] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log disposal
    lia.log.add(nil, "item_disposed", self:getID(), self.uniqueID)
    -- Trigger disposal hooks
    hook.Run("OnItemDisposed", self)
end

```

---

### getEntity

**Purpose**

Gets the world entity associated with this item instance

**When Called**

When you need to manipulate the physical item entity in the world

**Returns**

* Entity object if found, nil otherwise

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
local entity = item:getEntity()

```

**Medium Complexity:**
```lua
local entity = item:getEntity()
if entity then
    entity:SetPos(newPosition)
end

```

**High Complexity:**
```lua
local function teleportItemToPlayer(item, player)
    local entity = item:getEntity()
    if entity then
        -- Remove from inventory first
        item:removeFromInventory(true):next(function()
        -- Teleport entity to player
        entity:SetPos(player:GetPos() + Vector(0, 0, 50))
        entity:SetVelocity(Vector(0, 0, 0))
        -- Log the action
        lia.log.add(player, "item_teleported", item:getID(), item:getName())
    end)
    else
        player:notifyError("Item has no physical entity")
    end
end
teleportItemToPlayer(myItem, player)

```

---

### spawn

**Purpose**

Creates a physical entity for the item in the world

**When Called**

When dropping items or spawning them in the world

**Parameters**

* `position` (*unknown*): Position to spawn the item (Vector, table, or Player entity)
* `position` (*unknown*): Position to spawn the item (Vector, table, or Player entity)
* `angles` (*unknown*): Optional angles for the spawned item
* `angles` (*unknown*): Optional angles for the spawned item

**Returns**

* The created entity

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:spawn(Vector(0, 0, 0))

```

**Medium Complexity:**
```lua
item:spawn(player:GetPos() + Vector(0, 0, 50), Angle(0, 0, 0))

```

**High Complexity:**
```lua
local function dropItemWithPhysics(item, player, force)
    -- Remove from inventory
    item:removeFromInventory(true):next(function()
    -- Spawn with physics
    local entity = item:spawn(player:GetPos() + Vector(0, 50, 0))
    if entity and IsValid(entity:GetPhysicsObject()) then
        -- Apply throw force
        local phys = entity:GetPhysicsObject()
        phys:ApplyForceCenter(player:GetAimVector() * force)
        -- Add some spin
        phys:AddAngleVelocity(VectorRand() * 100)
        -- Log the drop
        lia.log.add(player, "item_dropped", item:getID(), item:getName())
    end
end)
end
dropItemWithPhysics(myItem, player, 1000)

```

---

### transfer

**Purpose**

Transfers the item from its current inventory to a new inventory

**When Called**

When moving items between inventories (trading, storing, etc.)

**Parameters**

* `newInventory` (*unknown*): The inventory to transfer the item to
* `newInventory` (*unknown*): The inventory to transfer the item to
* `bBypass` (*unknown*): Optional boolean to bypass access control checks
* `bBypass` (*unknown*): Optional boolean to bypass access control checks

**Returns**

* Boolean indicating if transfer was successful

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:transfer(otherInventory)

```

**Medium Complexity:**
```lua
if item:transfer(bankInventory) then
    player:notify("Item stored in bank")
end

```

**High Complexity:**
```lua
local function tradeItems(player1, player2, itemID, payment)
    local item = player1:getInventory():getItems()[itemID]
    if not item then return false, "Item not found" end
        -- Check if player2 has enough money
        if player2:getMoney() < payment then
            return false, "Insufficient funds"
        end
        -- Transfer item
        if item:transfer(player2:getInventory()) then
            -- Handle payment
            player2:addMoney(-payment)
            player1:addMoney(payment)
            -- Log the trade
            lia.log.add(nil, "item_trade",
            item:getID(), player1:GetName(), player2:GetName(), payment)
            return true
            else
                return false, "Transfer failed"
            end
        end
        local success, reason = tradeItems(seller, buyer, itemID, 500)

```

---

### onInstanced

**Purpose**

Called when the item instance is first created

**When Called**

Automatically when item instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onInstanced()
    print("New item instance created")
end

```

**Medium Complexity:**
```lua
function ITEM:onInstanced()
    -- Set default data for new instances
    if not self:getData("created") then
        self:setData("created", os.time())
    end
end

```

**High Complexity:**
```lua
function ITEM:onInstanced()
    -- Initialize complex item state
    self:setData("durability", self:getData("maxDurability", 100))
    self:setData("serialNumber", "SN-" .. self:getID())
    -- Register with item tracking system
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[self:getID()] = {
    uniqueID = self.uniqueID,
    created = os.time(),
    owner = self:getOwner() and self:getOwner():GetName() or "unknown"
    }
    lia.data.set("item_tracking", trackingData)
    -- Apply category-specific initialization
    if self.category == "weapons" then
        self:setData("ammo", self:getData("maxAmmo", 30))
        elseif self.category == "armor" then
            self:setData("protection", self:getData("maxProtection", 50))
        end
    end

```

---

### onInstanced

**Purpose**

Called when the item instance is first created

**When Called**

Automatically when item instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onInstanced()
    print("New item instance created")
end

```

**Medium Complexity:**
```lua
function ITEM:onInstanced()
    -- Set default data for new instances
    if not self:getData("created") then
        self:setData("created", os.time())
    end
end

```

**High Complexity:**
```lua
function ITEM:onInstanced()
    -- Initialize complex item state
    self:setData("durability", self:getData("maxDurability", 100))
    self:setData("serialNumber", "SN-" .. self:getID())
    -- Register with item tracking system
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[self:getID()] = {
    uniqueID = self.uniqueID,
    created = os.time(),
    owner = self:getOwner() and self:getOwner():GetName() or "unknown"
    }
    lia.data.set("item_tracking", trackingData)
    -- Apply category-specific initialization
    if self.category == "weapons" then
        self:setData("ammo", self:getData("maxAmmo", 30))
        elseif self.category == "armor" then
            self:setData("protection", self:getData("maxProtection", 50))
        end
    end

```

---

### onInstanced

**Purpose**

Called when the item instance is first created

**When Called**

Automatically when item instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onInstanced()
    print("New item instance created")
end

```

**Medium Complexity:**
```lua
function ITEM:onInstanced()
    -- Set default data for new instances
    if not self:getData("created") then
        self:setData("created", os.time())
    end
end

```

**High Complexity:**
```lua
function ITEM:onInstanced()
    -- Initialize complex item state
    self:setData("durability", self:getData("maxDurability", 100))
    self:setData("serialNumber", "SN-" .. self:getID())
    -- Register with item tracking system
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[self:getID()] = {
    uniqueID = self.uniqueID,
    created = os.time(),
    owner = self:getOwner() and self:getOwner():GetName() or "unknown"
    }
    lia.data.set("item_tracking", trackingData)
    -- Apply category-specific initialization
    if self.category == "weapons" then
        self:setData("ammo", self:getData("maxAmmo", 30))
        elseif self.category == "armor" then
            self:setData("protection", self:getData("maxProtection", 50))
        end
    end

```

---

### onInstanced

**Purpose**

Called when the item instance is first created

**When Called**

Automatically when item instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onInstanced()
    print("New item instance created")
end

```

**Medium Complexity:**
```lua
function ITEM:onInstanced()
    -- Set default data for new instances
    if not self:getData("created") then
        self:setData("created", os.time())
    end
end

```

**High Complexity:**
```lua
function ITEM:onInstanced()
    -- Initialize complex item state
    self:setData("durability", self:getData("maxDurability", 100))
    self:setData("serialNumber", "SN-" .. self:getID())
    -- Register with item tracking system
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[self:getID()] = {
    uniqueID = self.uniqueID,
    created = os.time(),
    owner = self:getOwner() and self:getOwner():GetName() or "unknown"
    }
    lia.data.set("item_tracking", trackingData)
    -- Apply category-specific initialization
    if self.category == "weapons" then
        self:setData("ammo", self:getData("maxAmmo", 30))
        elseif self.category == "armor" then
            self:setData("protection", self:getData("maxProtection", 50))
        end
    end

```

---

### onSync

**Purpose**

Called when the item is synchronized to clients

**When Called**

Automatically when item data is sent to clients

**Parameters**

* `recipient` (*unknown*): Optional specific client to sync to
* `recipient` (*unknown*): Optional specific client to sync to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Custom sync logic
end

```

**Medium Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Send additional data to specific client
    if recipient then
        net.Start("CustomItemData")
        net.WriteType(self:getID())
        net.WriteTable(self:getAllData())
        net.Send(recipient)
    end
end

```

**High Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Advanced sync with filtering
    local dataToSend = {}
    -- Only send sensitive data to item owner
    if recipient == self:getOwner() then
        dataToSend = self:getAllData()
        else
            -- Filter out sensitive data for other players
            for key, value in pairs(self:getAllData()) do
                if not self.sensitiveDataKeys[key] then
                    dataToSend[key] = value
                end
            end
        end
        -- Send filtered data
        net.Start("FilteredItemData")
        net.WriteType(self:getID())
        net.WriteTable(dataToSend)
        net.Send(recipient)
    end

```

---

### onSync

**Purpose**

Called when the item is synchronized to clients

**When Called**

Automatically when item data is sent to clients

**Parameters**

* `recipient` (*unknown*): Optional specific client to sync to
* `recipient` (*unknown*): Optional specific client to sync to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Custom sync logic
end

```

**Medium Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Send additional data to specific client
    if recipient then
        net.Start("CustomItemData")
        net.WriteType(self:getID())
        net.WriteTable(self:getAllData())
        net.Send(recipient)
    end
end

```

**High Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Advanced sync with filtering
    local dataToSend = {}
    -- Only send sensitive data to item owner
    if recipient == self:getOwner() then
        dataToSend = self:getAllData()
        else
            -- Filter out sensitive data for other players
            for key, value in pairs(self:getAllData()) do
                if not self.sensitiveDataKeys[key] then
                    dataToSend[key] = value
                end
            end
        end
        -- Send filtered data
        net.Start("FilteredItemData")
        net.WriteType(self:getID())
        net.WriteTable(dataToSend)
        net.Send(recipient)
    end

```

---

### onSync

**Purpose**

Called when the item is synchronized to clients

**When Called**

Automatically when item data is sent to clients

**Parameters**

* `recipient` (*unknown*): Optional specific client to sync to
* `recipient` (*unknown*): Optional specific client to sync to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Custom sync logic
end

```

**Medium Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Send additional data to specific client
    if recipient then
        net.Start("CustomItemData")
        net.WriteType(self:getID())
        net.WriteTable(self:getAllData())
        net.Send(recipient)
    end
end

```

**High Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Advanced sync with filtering
    local dataToSend = {}
    -- Only send sensitive data to item owner
    if recipient == self:getOwner() then
        dataToSend = self:getAllData()
        else
            -- Filter out sensitive data for other players
            for key, value in pairs(self:getAllData()) do
                if not self.sensitiveDataKeys[key] then
                    dataToSend[key] = value
                end
            end
        end
        -- Send filtered data
        net.Start("FilteredItemData")
        net.WriteType(self:getID())
        net.WriteTable(dataToSend)
        net.Send(recipient)
    end

```

---

### onSync

**Purpose**

Called when the item is synchronized to clients

**When Called**

Automatically when item data is sent to clients

**Parameters**

* `recipient` (*unknown*): Optional specific client to sync to
* `recipient` (*unknown*): Optional specific client to sync to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Custom sync logic
end

```

**Medium Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Send additional data to specific client
    if recipient then
        net.Start("CustomItemData")
        net.WriteType(self:getID())
        net.WriteTable(self:getAllData())
        net.Send(recipient)
    end
end

```

**High Complexity:**
```lua
function ITEM:onSync(recipient)
    -- Advanced sync with filtering
    local dataToSend = {}
    -- Only send sensitive data to item owner
    if recipient == self:getOwner() then
        dataToSend = self:getAllData()
        else
            -- Filter out sensitive data for other players
            for key, value in pairs(self:getAllData()) do
                if not self.sensitiveDataKeys[key] then
                    dataToSend[key] = value
                end
            end
        end
        -- Send filtered data
        net.Start("FilteredItemData")
        net.WriteType(self:getID())
        net.WriteTable(dataToSend)
        net.Send(recipient)
    end

```

---

### onRemoved

**Purpose**

Called when the item is permanently removed from the system

**When Called**

Automatically when delete() completes

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRemoved()
    print("Item permanently removed")
end

```

**Medium Complexity:**
```lua
function ITEM:onRemoved()
    -- Clean up references
    lia.data.delete("item_" .. self:getID())
end

```

**High Complexity:**
```lua
function ITEM:onRemoved()
    -- Comprehensive cleanup
    local itemID = self:getID()
    -- Remove from tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID] = nil
    lia.data.set("item_tracking", trackingData)
    -- Remove from category lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[itemID] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log permanent removal
    lia.log.add(nil, "item_permanently_removed", itemID, self.uniqueID)
    -- Notify administrators of rare item removal
    if self:getData("rarity") == "legendary" then
        lia.chat.send(lia.util.getAdmins(), "Legendary item permanently removed: " .. self:getName())
    end
end

```

---

### onRemoved

**Purpose**

Called when the item is permanently removed from the system

**When Called**

Automatically when delete() completes

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRemoved()
    print("Item permanently removed")
end

```

**Medium Complexity:**
```lua
function ITEM:onRemoved()
    -- Clean up references
    lia.data.delete("item_" .. self:getID())
end

```

**High Complexity:**
```lua
function ITEM:onRemoved()
    -- Comprehensive cleanup
    local itemID = self:getID()
    -- Remove from tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID] = nil
    lia.data.set("item_tracking", trackingData)
    -- Remove from category lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[itemID] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log permanent removal
    lia.log.add(nil, "item_permanently_removed", itemID, self.uniqueID)
    -- Notify administrators of rare item removal
    if self:getData("rarity") == "legendary" then
        lia.chat.send(lia.util.getAdmins(), "Legendary item permanently removed: " .. self:getName())
    end
end

```

---

### onRemoved

**Purpose**

Called when the item is permanently removed from the system

**When Called**

Automatically when delete() completes

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRemoved()
    print("Item permanently removed")
end

```

**Medium Complexity:**
```lua
function ITEM:onRemoved()
    -- Clean up references
    lia.data.delete("item_" .. self:getID())
end

```

**High Complexity:**
```lua
function ITEM:onRemoved()
    -- Comprehensive cleanup
    local itemID = self:getID()
    -- Remove from tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID] = nil
    lia.data.set("item_tracking", trackingData)
    -- Remove from category lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[itemID] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log permanent removal
    lia.log.add(nil, "item_permanently_removed", itemID, self.uniqueID)
    -- Notify administrators of rare item removal
    if self:getData("rarity") == "legendary" then
        lia.chat.send(lia.util.getAdmins(), "Legendary item permanently removed: " .. self:getName())
    end
end

```

---

### onRemoved

**Purpose**

Called when the item is permanently removed from the system

**When Called**

Automatically when delete() completes

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRemoved()
    print("Item permanently removed")
end

```

**Medium Complexity:**
```lua
function ITEM:onRemoved()
    -- Clean up references
    lia.data.delete("item_" .. self:getID())
end

```

**High Complexity:**
```lua
function ITEM:onRemoved()
    -- Comprehensive cleanup
    local itemID = self:getID()
    -- Remove from tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID] = nil
    lia.data.set("item_tracking", trackingData)
    -- Remove from category lists
    if self.category then
        local categoryItems = lia.data.get("category_items_" .. self.category, {})
        categoryItems[itemID] = nil
        lia.data.set("category_items_" .. self.category, categoryItems)
    end
    -- Log permanent removal
    lia.log.add(nil, "item_permanently_removed", itemID, self.uniqueID)
    -- Notify administrators of rare item removal
    if self:getData("rarity") == "legendary" then
        lia.chat.send(lia.util.getAdmins(), "Legendary item permanently removed: " .. self:getName())
    end
end

```

---

### onRestored

**Purpose**

Called when the item is loaded from the database

**When Called**

Automatically when item data is restored from storage

**Parameters**

* `inventory` (*unknown*): The inventory this item belongs to
* `inventory` (*unknown*): The inventory this item belongs to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRestored(inventory)
    print("Item restored from database")
end

```

**Medium Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Validate restored data
    if self:getData("durability") and self:getData("durability") < 0 then
        self:setData("durability", 0)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Comprehensive restoration logic
    local itemID = self:getID()
    -- Restore complex relationships
    self:restoreOwnershipLinks()
    self:restoreEnchantments()
    self:validateDataIntegrity()
    -- Update tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID].restored = os.time()
    trackingData[itemID].inventory = inventory:getID()
    lia.data.set("item_tracking", trackingData)
    -- Apply restoration effects
    if self:getData("temporary") then
        local expiryTime = self:getData("expiryTime")
        if expiryTime and expiryTime < os.time() then
            -- Item has expired, schedule removal
            timer.Simple(0, function()
            if IsValid(self) then
                self:remove()
                lia.log.add(nil, "expired_item_removed_on_restore", itemID)
            end
        end)
    end
end
-- Trigger restoration hooks
hook.Run("OnItemRestored", self, inventory)
end

```

---

### onRestored

**Purpose**

Called when the item is loaded from the database

**When Called**

Automatically when item data is restored from storage

**Parameters**

* `inventory` (*unknown*): The inventory this item belongs to
* `inventory` (*unknown*): The inventory this item belongs to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRestored(inventory)
    print("Item restored from database")
end

```

**Medium Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Validate restored data
    if self:getData("durability") and self:getData("durability") < 0 then
        self:setData("durability", 0)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Comprehensive restoration logic
    local itemID = self:getID()
    -- Restore complex relationships
    self:restoreOwnershipLinks()
    self:restoreEnchantments()
    self:validateDataIntegrity()
    -- Update tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID].restored = os.time()
    trackingData[itemID].inventory = inventory:getID()
    lia.data.set("item_tracking", trackingData)
    -- Apply restoration effects
    if self:getData("temporary") then
        local expiryTime = self:getData("expiryTime")
        if expiryTime and expiryTime < os.time() then
            -- Item has expired, schedule removal
            timer.Simple(0, function()
            if IsValid(self) then
                self:remove()
                lia.log.add(nil, "expired_item_removed_on_restore", itemID)
            end
        end)
    end
end
-- Trigger restoration hooks
hook.Run("OnItemRestored", self, inventory)
end

```

---

### onRestored

**Purpose**

Called when the item is loaded from the database

**When Called**

Automatically when item data is restored from storage

**Parameters**

* `inventory` (*unknown*): The inventory this item belongs to
* `inventory` (*unknown*): The inventory this item belongs to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRestored(inventory)
    print("Item restored from database")
end

```

**Medium Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Validate restored data
    if self:getData("durability") and self:getData("durability") < 0 then
        self:setData("durability", 0)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Comprehensive restoration logic
    local itemID = self:getID()
    -- Restore complex relationships
    self:restoreOwnershipLinks()
    self:restoreEnchantments()
    self:validateDataIntegrity()
    -- Update tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID].restored = os.time()
    trackingData[itemID].inventory = inventory:getID()
    lia.data.set("item_tracking", trackingData)
    -- Apply restoration effects
    if self:getData("temporary") then
        local expiryTime = self:getData("expiryTime")
        if expiryTime and expiryTime < os.time() then
            -- Item has expired, schedule removal
            timer.Simple(0, function()
            if IsValid(self) then
                self:remove()
                lia.log.add(nil, "expired_item_removed_on_restore", itemID)
            end
        end)
    end
end
-- Trigger restoration hooks
hook.Run("OnItemRestored", self, inventory)
end

```

---

### onRestored

**Purpose**

Called when the item is loaded from the database

**When Called**

Automatically when item data is restored from storage

**Parameters**

* `inventory` (*unknown*): The inventory this item belongs to
* `inventory` (*unknown*): The inventory this item belongs to

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function ITEM:onRestored(inventory)
    print("Item restored from database")
end

```

**Medium Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Validate restored data
    if self:getData("durability") and self:getData("durability") < 0 then
        self:setData("durability", 0)
    end
end

```

**High Complexity:**
```lua
function ITEM:onRestored(inventory)
    -- Comprehensive restoration logic
    local itemID = self:getID()
    -- Restore complex relationships
    self:restoreOwnershipLinks()
    self:restoreEnchantments()
    self:validateDataIntegrity()
    -- Update tracking systems
    local trackingData = lia.data.get("item_tracking", {})
    trackingData[itemID].restored = os.time()
    trackingData[itemID].inventory = inventory:getID()
    lia.data.set("item_tracking", trackingData)
    -- Apply restoration effects
    if self:getData("temporary") then
        local expiryTime = self:getData("expiryTime")
        if expiryTime and expiryTime < os.time() then
            -- Item has expired, schedule removal
            timer.Simple(0, function()
            if IsValid(self) then
                self:remove()
                lia.log.add(nil, "expired_item_removed_on_restore", itemID)
            end
        end)
    end
end
-- Trigger restoration hooks
hook.Run("OnItemRestored", self, inventory)
end

```

---

### sync

**Purpose**

Synchronizes item instance data to clients

**When Called**

When item data needs to be sent to clients

**Parameters**

* `recipient` (*unknown*): Optional specific client to sync to, broadcasts if nil
* `recipient` (*unknown*): Optional specific client to sync to, broadcasts if nil

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:sync()

```

**Medium Complexity:**
```lua
item:sync(specificPlayer)

```

**High Complexity:**
```lua
local function syncItemToGroup(item, players)
    -- Send different data based on player permissions
    for _, player in ipairs(players) do
        if player:canAccessItem(item) then
            item:sync(player)
            else
                -- Send limited data
                net.Start("liaItemLimited")
                net.WriteUInt(item:getID(), 32)
                net.WriteString(item:getName())
                net.Send(player)
            end
        end
    end
    syncItemToGroup(myItem, nearbyPlayers)

```

---

### setData

**Purpose**

Sets item data and synchronizes changes to clients and database

**When Called**

When item data needs to be updated and persisted

**Parameters**

* `key` (*unknown*): The data key to set
* `key` (*unknown*): The data key to set
* `value` (*unknown*): The value to set
* `value` (*unknown*): The value to set
* `receivers` (*unknown*): Optional specific clients to notify
* `receivers` (*unknown*): Optional specific clients to notify
* `noSave` (*unknown*): Optional boolean to skip database saving
* `noSave` (*unknown*): Optional boolean to skip database saving
* `noCheckEntity` (*unknown*): Optional boolean to skip entity data sync
* `noCheckEntity` (*unknown*): Optional boolean to skip entity data sync

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:setData("durability", 50)

```

**Medium Complexity:**
```lua
item:setData("owner", player:GetName())
item:setData("acquired", os.time())

```

**High Complexity:**
```lua
local function applyDamageToItem(item, damage)
    local currentDurability = item:getData("durability", 100)
    local newDurability = math.max(0, currentDurability - damage)
    -- Set durability and sync to all players
    item:setData("durability", newDurability)
    -- If item is broken, apply broken effects
    if newDurability == 0 then
        item:setData("broken", true)
        item:setData("repairCost", item:getData("baseRepairCost", 100) * 2)
        -- Notify owner
        local owner = item:getOwner()
        if owner then
            owner:notify("Your " .. item:getName() .. " has broken!")
        end
    end
    -- Log damage
    lia.log.add(nil, "item_damaged", item:getID(), damage, newDurability)
end
applyDamageToItem(myItem, 25)

```

---

### addQuantity

**Purpose**

Adds to the item's quantity and synchronizes the change

**When Called**

When increasing item stack size

**Parameters**

* `quantity` (*unknown*): Amount to add to the quantity
* `quantity` (*unknown*): Amount to add to the quantity
* `receivers` (*unknown*): Optional specific clients to notify
* `receivers` (*unknown*): Optional specific clients to notify
* `noCheckEntity` (*unknown*): Optional boolean to skip entity sync
* `noCheckEntity` (*unknown*): Optional boolean to skip entity sync

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:addQuantity(5)

```

**Medium Complexity:**
```lua
item:addQuantity(1, player) -- Notify specific player

```

**High Complexity:**
```lua
local function combineStacks(item1, item2)
    if item1.uniqueID == item2.uniqueID then
        local combinedQuantity = item1:getQuantity() + item2:getQuantity()
        local maxStack = item1.maxQuantity or 1
        if combinedQuantity <= maxStack then
            -- Combine into one stack
            item1:setQuantity(combinedQuantity)
            item2:remove()
            return true, "Items combined successfully"
            else
                -- Fill first stack and adjust second
                local overflow = combinedQuantity - maxStack
                item1:setQuantity(maxStack)
                item2:setQuantity(overflow)
                return true, "Items partially combined"
            end
        end
        return false, "Items cannot be combined"
    end
    local success, message = combineStacks(stack1, stack2)

```

---

### setQuantity

**Purpose**

Sets the item's quantity and synchronizes the change

**When Called**

When changing item stack size or count

**Parameters**

* `quantity` (*unknown*): New quantity value
* `quantity` (*unknown*): New quantity value
* `receivers` (*unknown*): Optional specific clients to notify
* `receivers` (*unknown*): Optional specific clients to notify
* `noCheckEntity` (*unknown*): Optional boolean to skip entity sync
* `noCheckEntity` (*unknown*): Optional boolean to skip entity sync

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:setQuantity(10)

```

**Medium Complexity:**
```lua
item:setQuantity(0) -- Remove all items from stack

```

**High Complexity:**
```lua
local function splitStack(item, splitAmount)
    local currentQuantity = item:getQuantity()
    if splitAmount >= currentQuantity then
        return false, "Cannot split more than available"
    end
    -- Create new item instance
    local newItem = lia.item.new(item.uniqueID, 1)
    newItem:setQuantity(splitAmount)
    newItem:setData("splitFrom", item:getID())
    -- Reduce original stack
    item:setQuantity(currentQuantity - splitAmount)
    -- Add new stack to same inventory
    local inventory = lia.inventory.instances[item.invID]
    if inventory then
        inventory:add(newItem)
        return true, newItem
    end
    return false, "Failed to add split item to inventory"
end
local success, newStack = splitStack(myItem, 5)

```

---

### interact

**Purpose**

Handles player interaction with items (use, drop, etc.)

**When Called**

When a player attempts to interact with an item

**Parameters**

* `action` (*unknown*): The interaction action (e.g., "use", "drop")
* `action` (*unknown*): The interaction action (e.g., "use", "drop")
* `client` (*unknown*): The player performing the action
* `client` (*unknown*): The player performing the action
* `entity` (*unknown*): Optional entity involved in the interaction
* `entity` (*unknown*): Optional entity involved in the interaction
* `data` (*unknown*): Optional additional data for the interaction
* `data` (*unknown*): Optional additional data for the interaction

**Returns**

* Boolean indicating if the interaction was successful

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
item:interact("use", player)

```

**Medium Complexity:**
```lua
item:interact("drop", player, nil, {position = dropPos})

```

**High Complexity:**
```lua
local function handleComplexInteraction(item, action, player, entity, data)
    -- Pre-interaction validation
    if action == "use" and item:getData("cooldown") then
        local lastUsed = item:getData("lastUsed", 0)
        if CurTime() - lastUsed < item:getData("cooldown") then
            player:notifyError("Item is on cooldown")
            return false
        end
    end
    -- Perform interaction
    local success = item:interact(action, player, entity, data)
    if success then
        -- Post-interaction effects
        if action == "use" then
            item:setData("lastUsed", CurTime())
            item:setData("uses", item:getData("uses", 0) + 1)
            -- Check for breakage
            if item:getData("uses") >= item:getData("maxUses", 100) then
                player:notify("Your " .. item:getName() .. " has broken!")
                item:setData("broken", true)
            end
        end
        -- Log the interaction
        lia.log.add(player, "item_interaction", action, item:getID(), item:getName())
    end
    return success
end
local success = handleComplexInteraction(myItem, "use", player)

```

---

### getCategory

**Purpose**

Gets the localized category name for the item

**When Called**

When displaying or organizing items by category

**Returns**

* String representing the localized category name

**Realm**

Both

**Example Usage**

**Low Complexity:**
```lua
local category = item:getCategory()

```

**Medium Complexity:**
```lua
if item:getCategory() == "weapons" then
    -- Handle weapon-specific logic
end

```

**High Complexity:**
```lua
local function organizeItemsByCategory(items)
    local categories = {}
    for _, item in ipairs(items) do
        local category = item:getCategory()
        categories[category] = categories[category] or {}
        table.insert(categories[category], item)
    end
    -- Sort categories alphabetically
    local sortedCategories = {}
    for categoryName, categoryItems in pairs(categories) do
        table.insert(sortedCategories, {
        name = categoryName,
        items = categoryItems,
        count = #categoryItems
        })
    end
    table.sort(sortedCategories, function(a, b) return a.name < b.name end)
    return sortedCategories
end
local organizedItems = organizeItemsByCategory(playerInventory:getItems())

```

---

