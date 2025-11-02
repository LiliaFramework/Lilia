# Inventory Meta

Inventory management system for the Lilia framework.

---

Overview

The inventory meta table provides comprehensive functionality for managing inventory data, item storage, and inventory operations in the Lilia framework. It handles inventory creation, item management, data persistence, capacity management, and inventory-specific operations. The meta table operates on both server and client sides, with the server managing inventory storage and validation while the client provides inventory data access and display. It includes integration with the item system for item storage, database system for inventory persistence, character system for character inventories, and network system for inventory synchronization. The meta table ensures proper inventory data synchronization, item capacity management, item validation, and comprehensive inventory lifecycle management from creation to deletion.

---

### getData

**Purpose**

Retrieves data from the inventory's data table with optional default fallback

**When Called**

Whenever inventory data needs to be accessed with a safe default value

**Parameters**

* `key` (*unknown*): The data key to retrieve
* `key` (*unknown*): The data key to retrieve
* `default` (*unknown*): Optional default value if key doesn't exist
* `default` (*unknown*): Optional default value if key doesn't exist

**Returns**

* The data value or default value if key doesn't exist

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local money = inventory:getData("money", 0)

```

**Medium Complexity:**
```lua
local characterName = inventory:getData("charName", "Unknown")
if characterName ~= "Unknown" then
    print("Character: " .. characterName)
end

```

**High Complexity:**
```lua
local settings = {
    autoSave    = inventory:getData("autoSave", true),
    maxSlots    = inventory:getData("maxSlots", 50),
    permissions = inventory:getData("permissions", {})
}
for setting, value in pairs(settings) do
    print(setting .. ": " .. tostring(value))
end

```

---

### logAccess

**Purpose**

Extends a class with the Inventory metatable functionality

**When Called**

During inventory type registration to create specialized inventory types

**Parameters**

* `className` (*unknown*): The name of the class to extend
* `className` (*unknown*): The name of the class to extend

**Returns**

* The extended class with Inventory functionality

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local PlayerInventory = Inventory:extend("PlayerInventory")

```

**Medium Complexity:**
```lua
local CustomInventory = Inventory:extend("Backpack")
CustomInventory.maxSlots = 20

```

**High Complexity:**
```lua
local SecureInventory = Inventory:extend("BankVault")
SecureInventory.accessLevel = "admin"
SecureInventory.auditLog = {}
function SecureInventory:logAccess(player)
    table.insert(self.auditLog, {player = player, time = os.time()})
end

```

---

### extend

**Purpose**

Extends a class with the Inventory metatable functionality

**When Called**

During inventory type registration to create specialized inventory types

**Parameters**

* `className` (*unknown*): The name of the class to extend
* `className` (*unknown*): The name of the class to extend

**Returns**

* The extended class with Inventory functionality

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local PlayerInventory = Inventory:extend("PlayerInventory")

```

**Medium Complexity:**
```lua
local CustomInventory = Inventory:extend("Backpack")
CustomInventory.maxSlots = 20

```

**High Complexity:**
```lua
local SecureInventory = Inventory:extend("BankVault")
SecureInventory.accessLevel = "admin"
SecureInventory.auditLog = {}
function SecureInventory:logAccess(player)
    table.insert(self.auditLog, {player = player, time = os.time()})
end

```

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:configure()
    self.maxWeight = 100
end

```

**Medium Complexity:**
```lua
function PlayerInventory:configure()
    self.config.data["money"] = {default = 0}
    self.config.data["level"] = {default = 1}
end

```

**High Complexity:**
```lua
function AdvancedInventory:configure()
    self.config.data["permissions"] = {default = {}}
    self.config.data["settings"] = {default = {}}
    self:addDataProxy("permissions", function(old, new)
        print("Permissions changed from", old, "to", new)
    end)
end

```

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:configure()
    self.maxWeight = 100
end

```

**Medium Complexity:**
```lua
function PlayerInventory:configure()
    self.config.data["money"] = {default = 0}
    self.config.data["level"] = {default = 1}
end

```

**High Complexity:**
```lua
function AdvancedInventory:configure()
    self.config.data["permissions"] = {default = {}}
    self.config.data["settings"] = {default = {}}
    self:addDataProxy("permissions", function(old, new)
        print("Permissions changed from", old, "to", new)
    end)
end

```

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:configure()
    self.maxWeight = 100
end

```

**Medium Complexity:**
```lua
function PlayerInventory:configure()
    self.config.data["money"] = {default = 0}
    self.config.data["level"] = {default = 1}
end

```

**High Complexity:**
```lua
function AdvancedInventory:configure()
    self.config.data["permissions"] = {default = {}}
    self.config.data["settings"] = {default = {}}
    self:addDataProxy("permissions", function(old, new)
        print("Permissions changed from", old, "to", new)
    end)
end

```

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:configure()
    self.maxWeight = 100
end

```

**Medium Complexity:**
```lua
function PlayerInventory:configure()
    self.config.data["money"] = {default = 0}
    self.config.data["level"] = {default = 1}
end

```

**High Complexity:**
```lua
function AdvancedInventory:configure()
    self.config.data["permissions"] = {default = {}}
    self.config.data["settings"] = {default = {}}
    self:addDataProxy("permissions", function(old, new)
        print("Permissions changed from", old, "to", new)
    end)
end

```

---

### addDataProxy

**Purpose**

Adds a data proxy function that gets called when specific data changes

**When Called**

During inventory configuration to set up data change callbacks

**Parameters**

* `key` (*unknown*): The data key to monitor for changes
* `key` (*unknown*): The data key to monitor for changes
* `onChange` (*unknown*): Function to call when the data changes (oldValue, newValue)
* `onChange` (*unknown*): Function to call when the data changes (oldValue, newValue)

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
inventory:addDataProxy("money", function(old, new)
    print("Money changed from", old, "to", new)
end)

```

**Medium Complexity:**
```lua
inventory:addDataProxy("level", function(old, new)
    if new > old then
        lia.chat.send(nil, "Level up!", player)
    end
end)

```

**High Complexity:**
```lua
local function complexProxy(old, new)
    if new.xp and old.xp and new.xp > old.xp then
        local gained = new.xp - old.xp
        hook.Run("OnPlayerXPGain", player, gained, new.level)
    end
end
inventory:addDataProxy("stats", complexProxy)

```

---

### getItemsByUniqueID

**Purpose**

Retrieves all items with a specific uniqueID from the inventory

**When Called**

When you need to find all instances of a particular item type

**Parameters**

* `uniqueID` (*unknown*): The uniqueID of the item type to find
* `uniqueID` (*unknown*): The uniqueID of the item type to find
* `onlyMain` (*unknown*): Optional boolean to only return items in main inventory slots
* `onlyMain` (*unknown*): Optional boolean to only return items in main inventory slots

**Returns**

* Table of items matching the uniqueID

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local weapons = inventory:getItemsByUniqueID("weapon_pistol")

```

**Medium Complexity:**
```lua
local foodItems = inventory:getItemsByUniqueID("food_apple")
for _, food in ipairs(foodItems) do
    print("Found apple:", food:getID())
end

```

**High Complexity:**
```lua
local allItems = inventory:getItemsByUniqueID("consumable")
local totalValue = 0
for _, item in ipairs(allItems) do
    if item.data and item.data.value then
        totalValue = totalValue + item.data.value
    end
end
print("Total consumable value:", totalValue)

```

---

### register

**Purpose**

Registers this inventory type with the Lilia inventory system

**When Called**

During inventory type definition to make it available for use

**Parameters**

* `typeID` (*unknown*): String identifier for this inventory type
* `typeID` (*unknown*): String identifier for this inventory type

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
MyInventory:register("player")

```

**Medium Complexity:**
```lua
PlayerInventory:register("player_backpack")
BankInventory:register("secure_storage")

```

**High Complexity:**
```lua
local types = {"player", "vehicle", "house", "guild"}
for _, typeName in ipairs(types) do
    local inventoryClass = Inventory:extend(typeName .. "_inventory")
    inventoryClass:register(typeName)
end

```

---

### new

**Purpose**

Creates a new instance of this inventory type

**When Called**

When you need to create a new inventory of this type

**Returns**

* New inventory instance

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local newInventory = MyInventory:new()

```

**Medium Complexity:**
```lua
local playerInv = PlayerInventory:new()
local bankInv = BankInventory:new()

```

**High Complexity:**
```lua
local inventories = {}
for i = 1, 10 do
    inventories[i] = StorageInventory:new()
end

```

---

### tostring

**Purpose**

Returns a string representation of the inventory

**When Called**

For debugging, logging, or display purposes

**Returns**

* String representation of the inventory

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
print(inventory:tostring())

```

**Medium Complexity:**
```lua
lia.chat.send(player, "Inventory: " .. inventory:tostring())

```

**High Complexity:**
```lua
local inventories = {inv1, inv2, inv3}
for i, inv in ipairs(inventories) do
    print("Inventory " .. i .. ": " .. inv:tostring())
end

```

---

### getType

**Purpose**

Gets the inventory type configuration

**When Called**

When you need to access type-specific settings or behavior

**Returns**

* The inventory type configuration table

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local config = inventory:getType()

```

**Medium Complexity:**
```lua
local invType = inventory:getType()
if invType.maxSlots then print("Max slots:", invType.maxSlots) end

```

**High Complexity:**
```lua
local function analyzeInventoryType(inv)
    local config = inv:getType()
    print("Type:", config.typeID)
    print("Data fields:", table.Count(config.data))
    print("Persistent:", config.persistent or false)
end

```

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value
* `newValue` (*unknown*): The new value

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- This is usually called automatically, not manually
inventory:onDataChanged("money", 100, 150)

```

**Medium Complexity:**
```lua
-- Override in subclass for custom behavior
function MyInventory:onDataChanged(key, old, new)
    if key == "level" and new > old then
        print("Level increased!")
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onDataChanged(key, old, new)
    if key == "permissions" then
        hook.Run("OnPermissionsChanged", self, old, new)
    elseif key == "settings" then
        for setting, value in pairs(new) do
            if old[setting] ~= value then
                print("Setting " .. setting .. " changed")
            end
        end
    end
end

```

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value
* `newValue` (*unknown*): The new value

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- This is usually called automatically, not manually
inventory:onDataChanged("money", 100, 150)

```

**Medium Complexity:**
```lua
-- Override in subclass for custom behavior
function MyInventory:onDataChanged(key, old, new)
    if key == "level" and new > old then
        print("Level increased!")
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onDataChanged(key, old, new)
    if key == "permissions" then
        hook.Run("OnPermissionsChanged", self, old, new)
    elseif key == "settings" then
        for setting, value in pairs(new) do
            if old[setting] ~= value then
                print("Setting " .. setting .. " changed")
            end
        end
    end
end

```

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value
* `newValue` (*unknown*): The new value

**Returns**

* Nothing

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- This is usually called automatically, not manually
inventory:onDataChanged("money", 100, 150)

```

**Medium Complexity:**
```lua
-- Override in subclass for custom behavior
function MyInventory:onDataChanged(key, old, new)
    if key == "level" and new > old then
        print("Level increased!")
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onDataChanged(key, old, new)
    if key == "permissions" then
        hook.Run("OnPermissionsChanged", self, old, new)
    elseif key == "settings" then
        for setting, value in pairs(new) do
            if old[setting] ~= value then
                print("Setting " .. setting .. " changed")
            end
        end
    end
end

```

---

### getItems

**Purpose**

Gets all items in the inventory

**When Called**

When you need to iterate through all inventory items

**Returns**

* Table of all items in the inventory

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local items = inventory:getItems()

```

**Medium Complexity:**
```lua
for _, item in pairs(inventory:getItems()) do
    print("Item:", item:getName())
end

```

**High Complexity:**
```lua
local function analyzeInventoryContents(inv)
    local items = inv:getItems()
    local totalValue = 0
    local categories = {}
    for _, item in pairs(items) do
        totalValue = totalValue + (item:getValue() or 0)
        local category = item.category or "misc"
        categories[category] = (categories[category] or 0) + 1
    end
    return totalValue, categories
end

```

---

### getItemsOfType

**Purpose**

Gets all items of a specific type from the inventory

**When Called**

When you need items of a particular type for processing

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to find
* `itemType` (*unknown*): The uniqueID of the item type to find

**Returns**

* Table of items matching the specified type

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local weapons = inventory:getItemsOfType("weapon_pistol")

```

**Medium Complexity:**
```lua
local food = inventory:getItemsOfType("food_apple")
print("Found", #food, "apples")

```

**High Complexity:**
```lua
local function getItemsByRarity(inv, rarity)
    local items = {}
    for _, item in pairs(inv:getItems()) do
        if item.data and item.data.rarity == rarity then
            table.insert(items, item)
        end
    end
    return items
end
local rareItems = getItemsByRarity(inventory, "legendary")

```

---

### getFirstItemOfType

**Purpose**

Gets the first item of a specific type from the inventory

**When Called**

When you need any single item of a type (efficiency over getting all)

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to find
* `itemType` (*unknown*): The uniqueID of the item type to find

**Returns**

* The first item found of the specified type, or nil if none found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local weapon = inventory:getFirstItemOfType("weapon_pistol")

```

**Medium Complexity:**
```lua
local apple = inventory:getFirstItemOfType("food_apple")
if apple then apple:use(player) end

```

**High Complexity:**
```lua
local function findBestTool(inv, toolType)
    local tools = inv:getItemsOfType(toolType)
    local bestTool = nil
    local bestLevel = 0
    for _, tool in ipairs(tools) do
        if tool.data and tool.data.level > bestLevel then
            bestTool = tool
            bestLevel = tool.data.level
        end
    end
    return bestTool
end
local bestPickaxe = findBestTool(inventory, "tool_pickaxe")

```

---

### hasItem

**Purpose**

Checks if the inventory contains at least one item of a specific type

**When Called**

For quick boolean checks before performing actions

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to check for
* `itemType` (*unknown*): The uniqueID of the item type to check for

**Returns**

* Boolean indicating if the item type exists in inventory

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
if inventory:hasItem("food_apple") then print("Has apple!") end

```

**Medium Complexity:**
```lua
if inventory:hasItem("weapon_pistol") then
    player:giveWeapon("weapon_pistol")
end

```

**High Complexity:**
```lua
local function canCraftRecipe(inv, recipe)
    for _, ingredient in ipairs(recipe.ingredients) do
        if not inv:hasItem(ingredient.id) then
            return false, "Missing: " .. ingredient.name
        end
    end
    return true
end
local canCraft, reason = canCraftRecipe(inventory, woodRecipe)

```

---

### getItemCount

**Purpose**

Counts total quantity of items of a specific type in the inventory

**When Called**

When you need to know how many of a particular item type exist

**Parameters**

* `itemType` (*unknown*): Optional uniqueID of item type to count, nil for all items
* `itemType` (*unknown*): Optional uniqueID of item type to count, nil for all items

**Returns**

* Number representing total quantity of specified item type

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local appleCount = inventory:getItemCount("food_apple")

```

**Medium Complexity:**
```lua
local totalFood = inventory:getItemCount("food")
local totalWeapons = inventory:getItemCount("weapon")

```

**High Complexity:**
```lua
local function calculateInventoryWeight(inv)
    local totalWeight = 0
    for _, item in pairs(inv:getItems()) do
        local itemWeight = item:getWeight and item:getWeight() or 1
        totalWeight = totalWeight + (itemWeight * item:getQuantity())
    end
    return totalWeight
end
local weight = calculateInventoryWeight(inventory)

```

---

### getID

**Purpose**

Gets the unique ID of this inventory instance

**When Called**

When you need to reference this specific inventory instance

**Returns**

* The inventory's unique ID number

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local id = inventory:getID()

```

**Medium Complexity:**
```lua
print("Inventory ID:", inventory:getID())

```

**High Complexity:**
```lua
local function transferItems(fromInv, toInv, itemType)
    local items = fromInv:getItemsOfType(itemType)
    for _, item in ipairs(items) do
        fromInv:removeItem(item:getID())
        toInv:addItem(item)
    end
    print("Transferred", #items, "items between inventories", fromInv:getID(), "and", toInv:getID())
end

```

---

### addItem

**Purpose**

Adds an item to the inventory with optional replication control

**When Called**

When items need to be added to an inventory instance

**Parameters**

* `item` (*unknown*): The item instance to add
* `item` (*unknown*): The item instance to add
* `noReplicate` (*unknown*): Optional boolean to skip network synchronization
* `noReplicate` (*unknown*): Optional boolean to skip network synchronization

**Returns**

* The inventory instance for method chaining

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:addItem(myItem)

```

**Medium Complexity:**
```lua
local weapon = lia.item.new("weapon_pistol", 1)
player:getInventory():addItem(weapon)

```

**High Complexity:**
```lua
local function addItemsToInventory(inv, itemList)
    for _, itemData in ipairs(itemList) do
        local item = lia.item.new(itemData.uniqueID, itemData.id)
        if item then
            inv:addItem(item, false) -- Force replication
        end
    end
end
addItemsToInventory(playerInventory, lootTable)

```

---

### add

**Purpose**

Alias for addItem method for convenience

**When Called**

Alternative method name for adding items

**Parameters**

* `item` (*unknown*): The item instance to add
* `item` (*unknown*): The item instance to add

**Returns**

* The inventory instance for method chaining

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:add(myItem)

```

**Medium Complexity:**
```lua
playerInventory:add(lia.item.new("food_apple", 1))

```

**High Complexity:**
```lua
local items = {weapon = "weapon_pistol", armor = "armor_helmet"}
for slot, uniqueID in pairs(items) do
    local item = lia.item.new(uniqueID, slot .. "_id")
    inventory:add(item)
end

```

---

### syncItemAdded

**Purpose**

Synchronizes newly added items to appropriate clients

**When Called**

Automatically called when items are added to inventory

**Parameters**

* `item` (*unknown*): The item that was added
* `item` (*unknown*): The item that was added

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Usually called automatically by addItem
inventory:syncItemAdded(item)

```

**Medium Complexity:**
```lua
local item = lia.item.new("weapon_sniper", 1)
inventory:addItem(item)
-- syncItemAdded is called automatically

```

**High Complexity:**
```lua
local function batchAddItems(inv, items)
    for _, item in ipairs(items) do
        inv:addItem(item, true) -- Don't replicate individually
    end
    -- Manually sync all at once
    for _, item in pairs(inv:getItems()) do
        inv:syncItemAdded(item)
    end
end

```

---

### initializeStorage

**Purpose**

Initializes inventory storage in the database

**When Called**

When creating new persistent inventories

**Parameters**

* `initialData` (*unknown*): Initial data to store with the inventory
* `initialData` (*unknown*): Initial data to store with the inventory

**Returns**

* Deferred object that resolves when storage is initialized

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
local deferred = inventory:initializeStorage({char = characterID})
deferred:next(function(id) print("Created inventory:", id) end)

```

**Medium Complexity:**
```lua
local initialData = {
    char        = player:getCharacter():getID(),
    permissions = {"read", "write"}
}
inventory:initializeStorage(initialData)

```

**High Complexity:**
```lua
local function createGuildInventory(guildData)
    local inventory = lia.inventory.new("guild_storage")
    local initialData = {
        char        = guildData.leaderID,
        guildID     = guildData.id,
        accessLevel = "member",
        maxSlots    = guildData.tier * 50
    }
    return inventory:initializeStorage(initialData)
end
local deferred = createGuildInventory(guildInfo)

```

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom restoration logic
function MyInventory:restoreFromStorage()
    -- Custom restoration code here
end

```

**Medium Complexity:**
```lua
function SecureInventory:restoreFromStorage()
    -- Load encryption keys, permissions, etc.
    self.encryptionKey = self:getData("encryptionKey")
end

```

**High Complexity:**
```lua
function AdvancedInventory:restoreFromStorage()
    -- Restore complex state from multiple data sources
    self:loadAccessRules()
    self:restoreItemStates()
    self:validateIntegrity()
end

```

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom restoration logic
function MyInventory:restoreFromStorage()
    -- Custom restoration code here
end

```

**Medium Complexity:**
```lua
function SecureInventory:restoreFromStorage()
    -- Load encryption keys, permissions, etc.
    self.encryptionKey = self:getData("encryptionKey")
end

```

**High Complexity:**
```lua
function AdvancedInventory:restoreFromStorage()
    -- Restore complex state from multiple data sources
    self:loadAccessRules()
    self:restoreItemStates()
    self:validateIntegrity()
end

```

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom restoration logic
function MyInventory:restoreFromStorage()
    -- Custom restoration code here
end

```

**Medium Complexity:**
```lua
function SecureInventory:restoreFromStorage()
    -- Load encryption keys, permissions, etc.
    self.encryptionKey = self:getData("encryptionKey")
end

```

**High Complexity:**
```lua
function AdvancedInventory:restoreFromStorage()
    -- Restore complex state from multiple data sources
    self:loadAccessRules()
    self:restoreItemStates()
    self:validateIntegrity()
end

```

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom restoration logic
function MyInventory:restoreFromStorage()
    -- Custom restoration code here
end

```

**Medium Complexity:**
```lua
function SecureInventory:restoreFromStorage()
    -- Load encryption keys, permissions, etc.
    self.encryptionKey = self:getData("encryptionKey")
end

```

**High Complexity:**
```lua
function AdvancedInventory:restoreFromStorage()
    -- Restore complex state from multiple data sources
    self:loadAccessRules()
    self:restoreItemStates()
    self:validateIntegrity()
end

```

---

### removeItem

**Purpose**

Removes an item from the inventory with optional preservation

**When Called**

When items need to be removed from inventory

**Parameters**

* `itemID` (*unknown*): The ID of the item to remove
* `itemID` (*unknown*): The ID of the item to remove
* `preserveItem` (*unknown*): Optional boolean to preserve item data in database
* `preserveItem` (*unknown*): Optional boolean to preserve item data in database

**Returns**

* Deferred object that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:removeItem(12345)

```

**Medium Complexity:**
```lua
local itemID = playerInventory:getFirstItemOfType("food_apple"):getID()
inventory:removeItem(itemID)

```

**High Complexity:**
```lua
local function removeItemsByType(inv, itemType, preserve)
    local items = inv:getItemsOfType(itemType)
    local deferreds = {}
    for _, item in ipairs(items) do
        deferreds[#deferreds + 1] = inv:removeItem(item:getID(), preserve)
    end
    return deferreds
end
local deferreds = removeItemsByType(inventory, "expired_food", true)

```

---

### remove

**Purpose**

Alias for removeItem method for convenience

**When Called**

Alternative method name for removing items

**Parameters**

* `itemID` (*unknown*): The ID of the item to remove
* `itemID` (*unknown*): The ID of the item to remove

**Returns**

* Deferred object that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:remove(12345)

```

**Medium Complexity:**
```lua
local item = inventory:getFirstItemOfType("weapon_knife")
if item then inventory:remove(item:getID()) end

```

**High Complexity:**
```lua
local function clearInventoryOfType(inv, itemType)
    local items = inv:getItemsOfType(itemType)
    for _, item in ipairs(items) do
        inv:remove(item:getID())
    end
end
clearInventoryOfType(playerInventory, "contraband")

```

---

### setData

**Purpose**

Sets data for the inventory and persists to database

**When Called**

When inventory data needs to be updated

**Parameters**

* `key` (*unknown*): The data key to set
* `key` (*unknown*): The data key to set
* `value` (*unknown*): The value to set for the key
* `value` (*unknown*): The value to set for the key

**Returns**

* The inventory instance for method chaining

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:setData("money", 1000)

```

**Medium Complexity:**
```lua
inventory:setData("permissions", {"read", "write", "admin"})

```

**High Complexity:**
```lua
local function updateInventoryStats(inv, stats)
    for statName, statValue in pairs(stats) do
        inv:setData(statName, statValue)
    end
    -- Trigger custom update logic
    inv:onStatsUpdated(stats)
end
updateInventoryStats(guildInventory, {level = 5, members = 25})

```

---

### canAccess

**Purpose**

Checks if an action is allowed on this inventory

**When Called**

Before performing actions that require access control

**Parameters**

* `action` (*unknown*): The action to check (e.g., "repl", "add", "remove")
* `action` (*unknown*): The action to check (e.g., "repl", "add", "remove")
* `context` (*unknown*): Optional context table with additional information
* `context` (*unknown*): Optional context table with additional information

**Returns**

* Boolean indicating if action is allowed, and optional reason string

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
local canAccess, reason = inventory:canAccess("repl")
if not canAccess then print("Access denied:", reason) end

```

**Medium Complexity:**
```lua
local canAdd, reason = inventory:canAccess("add", {client = player})
if canAdd then inventory:addItem(item) end

```

**High Complexity:**
```lua
local function checkInventoryPermissions(inv, player, action)
    local context = {
        client   = player,
        itemType = "weapon",
        quantity = 1,
        time     = os.time()
    }
    local allowed, reason = inv:canAccess(action, context)
    if not allowed then
        lia.log.add(player, "inventory_denied", action, reason)
    end
    return allowed, reason
end
local canTake, reason = checkInventoryPermissions(bankInv, robber, "remove")

```

---

### addAccessRule

**Purpose**

Adds an access control rule to the inventory

**When Called**

During inventory configuration to set up access control

**Parameters**

* `rule` (*unknown*): Function that takes (inventory, action, context) and returns bool, string
* `rule` (*unknown*): Function that takes (inventory, action, context) and returns bool, string
* `priority` (*unknown*): Optional priority number for rule evaluation order
* `priority` (*unknown*): Optional priority number for rule evaluation order

**Returns**

* The inventory instance for method chaining

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:addAccessRule(function(inv, action, context)
    if action == "repl" then return true end
end)

```

**Medium Complexity:**
```lua
inventory:addAccessRule(function(inv, action, context)
    if context.client == inv:getOwner() then
        return true, "Owner access"
    end
end)

```

**High Complexity:**
```lua
local function complexAccessRule(inv, action, context)
    local client = context.client
    if not client then return false, "No client provided" end
    -- Check if client is admin
    if client:isAdmin() then return true, "Admin access" end
    -- Check time-based restrictions
    local currentHour = os.date("%H", os.time())
    if action == "remove" and currentHour < 6 then
        return false, "Withdrawals not allowed before 6 AM"
    end
    -- Check item-specific rules
    if context.itemType == "weapon" then
        if not client:hasFlag("can_carry_weapons") then
            return false, "No weapon permit"
        end
    end
    return true
end
inventory:addAccessRule(complexAccessRule)

```

---

### removeAccessRule

**Purpose**

Removes an access control rule from the inventory

**When Called**

When access rules need to be removed or updated

**Parameters**

* `rule` (*unknown*): The rule function to remove
* `rule` (*unknown*): The rule function to remove

**Returns**

* The inventory instance for method chaining

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:removeAccessRule(myRule)

```

**Medium Complexity:**
```lua
local rules = inventory.config.accessRules
for i, rule in ipairs(rules) do
    if rule == tempAccessRule then
        inventory:removeAccessRule(rule)
        break
    end
end

```

**High Complexity:**
```lua
local function cleanupAccessRules(inv)
    local rules = inv.config.accessRules
    local currentTime = os.time()
    for i = #rules, 1, -1 do
        local rule = rules[i]
        -- Remove expired temporary rules
        if rule.expiry and rule.expiry < currentTime then
            inv:removeAccessRule(rule)
        end
    end
end
cleanupAccessRules(guildInventory)

```

---

### getRecipients

**Purpose**

Gets list of clients that should receive inventory updates

**When Called**

When synchronizing inventory changes to clients

**Returns**

* Table of client entities that can access this inventory

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
local recipients = inventory:getRecipients()

```

**Medium Complexity:**
```lua
local players = inventory:getRecipients()
for _, client in ipairs(players) do
    client:ChatPrint("Inventory updated")
end

```

**High Complexity:**
```lua
local function sendCustomNotification(inv, message)
    local recipients = inv:getRecipients()
    net.Start("CustomInventoryNotification")
    net.WriteString(message)
    net.Send(recipients)
end
sendCustomNotification(bankInventory, "Security alert triggered!")

```

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom initialization
function MyInventory:onInstanced()
    print("New inventory created")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onInstanced()
    self:addAccessRule(function(inv, action, context)
        return context.client == inv:getOwner()
    end)
end

```

**High Complexity:**
```lua
function SecureInventory:onInstanced()
    -- Initialize security features
    self.securityLevel = self:getData("securityLevel", 1)
    self.accessLog = {}
    self.failedAttempts = 0
    -- Set up monitoring
    self:addAccessRule(function(inv, action, context)
        if action == "remove" and inv.securityLevel > 3 then
            table.insert(inv.accessLog, {
                client = context.client,
                action = action,
                time   = os.time()
            })
        end
        return true
    end)
end

```

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom initialization
function MyInventory:onInstanced()
    print("New inventory created")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onInstanced()
    self:addAccessRule(function(inv, action, context)
        return context.client == inv:getOwner()
    end)
end

```

**High Complexity:**
```lua
function SecureInventory:onInstanced()
    -- Initialize security features
    self.securityLevel = self:getData("securityLevel", 1)
    self.accessLog = {}
    self.failedAttempts = 0
    -- Set up monitoring
    self:addAccessRule(function(inv, action, context)
        if action == "remove" and inv.securityLevel > 3 then
            table.insert(inv.accessLog, {
                client = context.client,
                action = action,
                time   = os.time()
            })
        end
        return true
    end)
end

```

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom initialization
function MyInventory:onInstanced()
    print("New inventory created")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onInstanced()
    self:addAccessRule(function(inv, action, context)
        return context.client == inv:getOwner()
    end)
end

```

**High Complexity:**
```lua
function SecureInventory:onInstanced()
    -- Initialize security features
    self.securityLevel = self:getData("securityLevel", 1)
    self.accessLog = {}
    self.failedAttempts = 0
    -- Set up monitoring
    self:addAccessRule(function(inv, action, context)
        if action == "remove" and inv.securityLevel > 3 then
            table.insert(inv.accessLog, {
                client = context.client,
                action = action,
                time   = os.time()
            })
        end
        return true
    end)
end

```

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Override in subclass for custom initialization
function MyInventory:onInstanced()
    print("New inventory created")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onInstanced()
    self:addAccessRule(function(inv, action, context)
        return context.client == inv:getOwner()
    end)
end

```

**High Complexity:**
```lua
function SecureInventory:onInstanced()
    -- Initialize security features
    self.securityLevel = self:getData("securityLevel", 1)
    self.accessLog = {}
    self.failedAttempts = 0
    -- Set up monitoring
    self:addAccessRule(function(inv, action, context)
        if action == "remove" and inv.securityLevel > 3 then
            table.insert(inv.accessLog, {
                client = context.client,
                action = action,
                time   = os.time()
            })
        end
        return true
    end)
end

```

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onLoaded()
    print("Inventory loaded from storage")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onLoaded()
    -- Restore character-specific settings
    local char = self:getCharacter()
    if char then
        self:setData("lastSeen", os.time())
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onLoaded()
    -- Validate inventory integrity
    self:validateItemStates()
    self:restoreAccessRules()
    self:checkForExpiredItems()
    -- Initialize advanced features
    if self:getData("autoSort") then
        self:sortItems()
    end
end

```

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onLoaded()
    print("Inventory loaded from storage")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onLoaded()
    -- Restore character-specific settings
    local char = self:getCharacter()
    if char then
        self:setData("lastSeen", os.time())
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onLoaded()
    -- Validate inventory integrity
    self:validateItemStates()
    self:restoreAccessRules()
    self:checkForExpiredItems()
    -- Initialize advanced features
    if self:getData("autoSort") then
        self:sortItems()
    end
end

```

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onLoaded()
    print("Inventory loaded from storage")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onLoaded()
    -- Restore character-specific settings
    local char = self:getCharacter()
    if char then
        self:setData("lastSeen", os.time())
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onLoaded()
    -- Validate inventory integrity
    self:validateItemStates()
    self:restoreAccessRules()
    self:checkForExpiredItems()
    -- Initialize advanced features
    if self:getData("autoSort") then
        self:sortItems()
    end
end

```

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onLoaded()
    print("Inventory loaded from storage")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onLoaded()
    -- Restore character-specific settings
    local char = self:getCharacter()
    if char then
        self:setData("lastSeen", os.time())
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onLoaded()
    -- Validate inventory integrity
    self:validateItemStates()
    self:restoreAccessRules()
    self:checkForExpiredItems()
    -- Initialize advanced features
    if self:getData("autoSort") then
        self:sortItems()
    end
end

```

---

### loadItems

**Purpose**

Loads items from database storage

**When Called**

When inventory needs to be populated from persistent storage

**Returns**

* Deferred object that resolves with loaded items

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:loadItems():next(function(items)
    print("Loaded", #items, "items")
end)

```

**Medium Complexity:**
```lua
playerInventory:loadItems():next(function(items)
    for _, item in pairs(items) do
        if item.uniqueID == "weapon" then
            player:giveWeapon(item.data.weaponClass)
        end
    end
end)

```

**High Complexity:**
```lua
local function loadInventoryWithValidation(inv)
    return inv:loadItems():next(function(items)
        -- Validate loaded items
        local validItems = {}
        local invalidCount = 0
        for _, item in pairs(items) do
            if inv:validateItem(item) then
                table.insert(validItems, item)
            else
                invalidCount = invalidCount + 1
                lia.log.add(nil, "invalid_item", item:getID(), inv:getID())
            end
        end
        if invalidCount > 0 then
            lia.log.add(nil, "inventory_validation", inv:getID(), invalidCount .. " invalid items")
        end
        return validItems
    end)
end
loadInventoryWithValidation(playerInventory)

```

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items
* `items` (*unknown*): Table of loaded items

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onItemsLoaded(items)
    print("Loaded", #items, "items")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onItemsLoaded(items)
    for _, item in pairs(items) do
        if item.uniqueID == "quest_item" then
            hook.Run("OnQuestItemLoaded", self:getOwner(), item)
        end
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onItemsLoaded(items)
    -- Categorize items
    self.itemCategories = {}
    for _, item in pairs(items) do
        local category = item.category or "misc"
        if not self.itemCategories[category] then
            self.itemCategories[category] = {}
        end
        table.insert(self.itemCategories[category], item)
    end
    -- Initialize item relationships
    for _, item in pairs(items) do
        item:onInventoryLoaded(self)
    end
    -- Validate inventory constraints
    self:validateInventoryConstraints()
end

```

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items
* `items` (*unknown*): Table of loaded items

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onItemsLoaded(items)
    print("Loaded", #items, "items")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onItemsLoaded(items)
    for _, item in pairs(items) do
        if item.uniqueID == "quest_item" then
            hook.Run("OnQuestItemLoaded", self:getOwner(), item)
        end
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onItemsLoaded(items)
    -- Categorize items
    self.itemCategories = {}
    for _, item in pairs(items) do
        local category = item.category or "misc"
        if not self.itemCategories[category] then
            self.itemCategories[category] = {}
        end
        table.insert(self.itemCategories[category], item)
    end
    -- Initialize item relationships
    for _, item in pairs(items) do
        item:onInventoryLoaded(self)
    end
    -- Validate inventory constraints
    self:validateInventoryConstraints()
end

```

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items
* `items` (*unknown*): Table of loaded items

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onItemsLoaded(items)
    print("Loaded", #items, "items")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onItemsLoaded(items)
    for _, item in pairs(items) do
        if item.uniqueID == "quest_item" then
            hook.Run("OnQuestItemLoaded", self:getOwner(), item)
        end
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onItemsLoaded(items)
    -- Categorize items
    self.itemCategories = {}
    for _, item in pairs(items) do
        local category = item.category or "misc"
        if not self.itemCategories[category] then
            self.itemCategories[category] = {}
        end
        table.insert(self.itemCategories[category], item)
    end
    -- Initialize item relationships
    for _, item in pairs(items) do
        item:onInventoryLoaded(self)
    end
    -- Validate inventory constraints
    self:validateInventoryConstraints()
end

```

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items
* `items` (*unknown*): Table of loaded items

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
function MyInventory:onItemsLoaded(items)
    print("Loaded", #items, "items")
end

```

**Medium Complexity:**
```lua
function PlayerInventory:onItemsLoaded(items)
    for _, item in pairs(items) do
        if item.uniqueID == "quest_item" then
            hook.Run("OnQuestItemLoaded", self:getOwner(), item)
        end
    end
end

```

**High Complexity:**
```lua
function AdvancedInventory:onItemsLoaded(items)
    -- Categorize items
    self.itemCategories = {}
    for _, item in pairs(items) do
        local category = item.category or "misc"
        if not self.itemCategories[category] then
            self.itemCategories[category] = {}
        end
        table.insert(self.itemCategories[category], item)
    end
    -- Initialize item relationships
    for _, item in pairs(items) do
        item:onInventoryLoaded(self)
    end
    -- Validate inventory constraints
    self:validateInventoryConstraints()
end

```

---

### instance

**Purpose**

Creates a new instance of this inventory type with initial data

**When Called**

When creating configured inventory instances

**Parameters**

* `initialData` (*unknown*): Initial data for the inventory instance
* `initialData` (*unknown*): Initial data for the inventory instance

**Returns**

* New inventory instance

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
local inventory = MyInventory:instance({char = playerID})

```

**Medium Complexity:**
```lua
local bank = BankInventory:instance({
    char        = characterID,
    accessLevel = "premium"
})

```

**High Complexity:**
```lua
local function createComplexInventory(typeClass, config)
    local inventory = typeClass:instance({
        char        = config.ownerID,
        permissions = config.permissions,
        settings    = config.settings,
        maxSlots    = config.maxSlots or 50
    })
    -- Configure based on type
    if config.secure then
        inventory:addAccessRule(function(inv, action, context)
            if action == "remove" and not context.client:isAdmin() then
                return false, "Secure inventory - admin access required"
            end
            return true
        end)
    end
    return inventory
end
local secureBank = createComplexInventory(BankInventory, {
    ownerID = playerID,
    secure  = true,
    maxSlots = 100
})

```

---

### syncData

**Purpose**

Synchronizes inventory data changes to clients

**When Called**

When inventory data changes and needs to be replicated

**Parameters**

* `key` (*unknown*): The data key that changed
* `key` (*unknown*): The data key that changed
* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients
* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:syncData("money")

```

**Medium Complexity:**
```lua
inventory:setData("level", 5)
-- syncData is called automatically

```

**High Complexity:**
```lua
local function updateInventoryData(inv, updates)
    local recipients = inv:getRecipients()
    for key, value in pairs(updates) do
        inv:setData(key, value)
        -- Additional custom sync logic
        if key == "permissions" then
            inv:syncData(key, recipients) -- Force immediate sync
        end
    end
end
updateInventoryData(guildInventory, {level = 5, memberCount = 25})

```

---

### sync

**Purpose**

Synchronizes entire inventory state to clients

**When Called**

When clients need full inventory state (initial load, resync)

**Parameters**

* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients
* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:sync()

```

**Medium Complexity:**
```lua
local recipients = inventory:getRecipients()
inventory:sync(recipients)

```

**High Complexity:**
```lua
local function fullInventorySync(inv, targetClients)
    -- Send full inventory state
    inv:sync(targetClients)
    -- Send additional metadata if needed
    for _, client in ipairs(targetClients) do
        net.Start("InventoryMetadata")
        net.WriteType(inv:getID())
        net.WriteTable(inv:getData())
        net.Send(client)
    end
end
fullInventorySync(playerInventory, {admin1, admin2})

```

---

### delete

**Purpose**

Deletes the inventory from the system

**When Called**

When inventory should be permanently removed

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:delete()

```

**Medium Complexity:**
```lua
if inventory:getItemCount() == 0 then
    inventory:delete()
end

```

**High Complexity:**
```lua
local function safelyDeleteInventory(inv)
    -- Archive inventory data first
    inv:archiveData()
    -- Remove all items
    for _, item in pairs(inv:getItems()) do
        inv:removeItem(item:getID())
    end
    -- Clear access rules
    inv.config.accessRules = {}
    -- Finally delete
    inv:delete()
end
safelyDeleteInventory(oldInventory)

```

---

### destroy

**Purpose**

Destroys the inventory and all its items

**When Called**

When inventory and all contents should be completely removed

**Returns**

* Nothing

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
inventory:destroy()

```

**Medium Complexity:**
```lua
if shouldDestroy then
    inventory:destroy()
end

```

**High Complexity:**
```lua
local function cleanupPlayerInventory(player)
    local inventory = player:getInventory()
    if inventory then
        -- Log destruction reason
        lia.log.add(player, "inventory_destroyed", reason)
        -- Transfer important items to bank first
        local bankItems = {"important_document", "rare_item"}
        for _, itemType in ipairs(bankItems) do
            local items = inventory:getItemsOfType(itemType)
            for _, item in ipairs(items) do
                inventory:removeItem(item:getID())
                bankInventory:addItem(item)
            end
        end
        -- Destroy remaining inventory
        inventory:destroy()
    end
end
cleanupPlayerInventory(leavingPlayer)

```

---

### show

**Purpose**

Shows the inventory panel to the player

**When Called**

When player opens inventory interface

**Parameters**

* `parent` (*unknown*): Optional parent panel for the inventory UI
* `parent` (*unknown*): Optional parent panel for the inventory UI

**Returns**

* The created inventory panel

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
inventory:show()

```

**Medium Complexity:**
```lua
local panel = inventory:show(myCustomParent)

```

**High Complexity:**
```lua
local function createCustomInventoryUI(inv)
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("Custom Inventory")
    local inventoryPanel = inv:show(frame)
    inventoryPanel:Dock(FILL)
    -- Add custom buttons
    local sortButton = vgui.Create("DButton", frame)
    sortButton:Dock(BOTTOM)
    sortButton:SetText("Sort Items")
    sortButton.DoClick = function()
        net.Start("InventorySort")
        net.WriteType(inv:getID())
        net.SendToServer()
    end
    return frame
end
local ui = createCustomInventoryUI(playerInventory)
ui:MakePopup()

```

---

