# Item Meta

Item management system for the Lilia framework.

---

## Overview

The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.

---

### isRotated

**Purpose**

Checks if the item is currently rotated in the inventory

**When Called**

When checking item orientation for inventory display or placement

**Returns**

* boolean - True if the item is rotated, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if item is rotated
local isRotated = item:isRotated()

```

**Medium Complexity:**
```lua
-- Medium: Use rotation state for inventory calculations
local width = item:isRotated() and item.height or item.width

```

**High Complexity:**
```lua
-- High: Complex inventory placement logic
if item:isRotated() then
    -- Handle rotated item placement
end

```

---

### getWidth

**Purpose**

Gets the effective width of the item, accounting for rotation

**When Called**

When calculating item dimensions for inventory placement

**Returns**

* number - The effective width of the item (height if rotated)

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item width
local width = item:getWidth()

```

**Medium Complexity:**
```lua
-- Medium: Use width for inventory calculations
local canFit = inventory:canFit(item:getWidth(), item:getHeight())

```

**High Complexity:**
```lua
-- High: Complex inventory placement with rotation
local effectiveWidth = item:isRotated() and item.height or item.width

```

---

### getHeight

**Purpose**

Gets the effective height of the item, accounting for rotation

**When Called**

When calculating item dimensions for inventory placement

**Returns**

* number - The effective height of the item (width if rotated)

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item height
local height = item:getHeight()

```

**Medium Complexity:**
```lua
-- Medium: Use height for inventory calculations
local canFit = inventory:canFit(item:getWidth(), item:getHeight())

```

**High Complexity:**
```lua
-- High: Complex inventory placement with rotation
local effectiveHeight = item:isRotated() and item.width or item.height

```

---

### getQuantity

**Purpose**

Gets the current quantity of the item

**When Called**

When checking item quantity for inventory management or display

**Returns**

* number - The current quantity of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item quantity
local quantity = item:getQuantity()

```

**Medium Complexity:**
```lua
-- Medium: Check if item can be split
if item:getQuantity() > 1 then
    -- Allow splitting
end

```

**High Complexity:**
```lua
-- High: Complex quantity management
local currentQty = item:getQuantity()
local maxQty = item.maxQuantity
if currentQty < maxQty then
    -- Handle stacking
end

```

---

### tostring

**Purpose**

Converts the item to a string representation for debugging

**When Called**

When displaying item information in console or debug output

**Returns**

* string - Formatted string representation of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Print item info
print(item:tostring())

```

**Medium Complexity:**
```lua
-- Medium: Use in debug messages
lia.information("Item: " .. item:tostring())

```

**High Complexity:**
```lua
-- High: Complex logging with item details
lia.logger.info("Processing item: " .. item:tostring())

```

---

### getID

**Purpose**

Gets the unique ID of the item instance

**When Called**

When identifying a specific item instance for operations

**Returns**

* number - The unique ID of the item instance

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item ID
local id = item:getID()

```

**Medium Complexity:**
```lua
-- Medium: Use ID for inventory operations
inventory:removeItem(item:getID())

```

**High Complexity:**
```lua
-- High: Complex item tracking
local itemID = item:getID()
if itemID > 0 then
    -- Handle valid item instance
end

```

---

### getModel

**Purpose**

Gets the model path of the item

**When Called**

When displaying or spawning the item entity

**Returns**

* string - The model path of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item model
local model = item:getModel()

```

**Medium Complexity:**
```lua
-- Medium: Use model for entity creation
local entity = ents.Create("lia_item")
entity:SetModel(item:getModel())

```

**High Complexity:**
```lua
-- High: Complex model validation
local model = item:getModel()
if model and util.IsValidModel(model) then
    -- Handle valid model
end

```

---

### getSkin

**Purpose**

Gets the skin index of the item

**When Called**

When applying visual customization to the item entity

**Returns**

* number - The skin index of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item skin
local skin = item:getSkin()

```

**Medium Complexity:**
```lua
-- Medium: Apply skin to entity
local entity = item:getEntity()
if IsValid(entity) then
    entity:SetSkin(item:getSkin())
end

```

**High Complexity:**
```lua
-- High: Complex skin management
local skin = item:getSkin()
if skin and skin > 0 then
    -- Handle custom skin
end

```

---

### getBodygroups

**Purpose**

Gets the bodygroup data of the item

**When Called**

When applying bodygroup modifications to the item entity

**Returns**

* table - The bodygroup data of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item bodygroups
local bodygroups = item:getBodygroups()

```

**Medium Complexity:**
```lua
-- Medium: Apply bodygroups to entity
local entity = item:getEntity()
if IsValid(entity) then
    for group, value in pairs(item:getBodygroups()) do
        entity:SetBodygroup(group, value)
    end
end

```

**High Complexity:**
```lua
-- High: Complex bodygroup management
local bodygroups = item:getBodygroups()
if bodygroups and next(bodygroups) then
    -- Handle custom bodygroups
end

```

---

### getPrice

**Purpose**

Gets the price of the item, with optional custom calculation

**When Called**

When displaying item price or calculating transaction costs

**Returns**

* number - The calculated price of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item price
local price = item:getPrice()

```

**Medium Complexity:**
```lua
-- Medium: Use price for vendor transactions
local totalCost = item:getPrice() * quantity

```

**High Complexity:**
```lua
-- High: Complex pricing with custom calculation
local basePrice = item.price
local finalPrice = item:getPrice()
if item.calcPrice then
    -- Custom price calculation applied
end

```

---

### call

**Purpose**

Calls a method on the item with context switching

**When Called**

When executing item methods with specific player and entity context

**Parameters**

* `method` (*string*): The method name to call
* `client` (*Player, optional*): The player context for the call
* `entity` (*Entity, optional*): The entity context for the call

**Returns**

* any - The return value(s) from the called method

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Call item method
item:call("onUse", player)

```

**Medium Complexity:**
```lua
-- Medium: Call with context
item:call("onDrop", player, entity, data)

```

**High Complexity:**
```lua
-- High: Complex method calling with hooks
local result = item:call("customAction", player, entity, arg1, arg2)
if result then
    -- Handle result
end

```

---

### getOwner

**Purpose**

Gets the owner of the item (the player who has it in their inventory)

**When Called**

When determining item ownership for permissions or display

**Returns**

* Player - The player who owns the item, or nil if not found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item owner
local owner = item:getOwner()

```

**Medium Complexity:**
```lua
-- Medium: Check ownership for permissions
local owner = item:getOwner()
if owner == player then
    -- Player owns the item
end

```

**High Complexity:**
```lua
-- High: Complex ownership validation
local owner = item:getOwner()
if owner and IsValid(owner) then
    -- Handle valid owner
end

```

---

### getData

**Purpose**

Gets a specific data value from the item

**When Called**

When retrieving stored data from the item

**Parameters**

* `key` (*string*): The data key to retrieve
* `default` (*any, optional*): Default value if key doesn't exist

**Returns**

* any - The data value or default if not found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item data
local value = item:getData("customValue")

```

**Medium Complexity:**
```lua
-- Medium: Get data with default
local durability = item:getData("durability", 100)

```

**High Complexity:**
```lua
-- High: Complex data retrieval
local data = item:getData("complexData", {})
if data and istable(data) then
    -- Handle complex data
end

```

---

### getAllData

**Purpose**

Gets all data from the item, including entity data

**When Called**

When retrieving complete item data for serialization or display

**Returns**

* table - Complete data table combining item and entity data

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get all item data
local data = item:getAllData()

```

**Medium Complexity:**
```lua
-- Medium: Use data for serialization
local serialized = util.TableToJSON(item:getAllData())

```

**High Complexity:**
```lua
-- High: Complex data processing
local allData = item:getAllData()
for key, value in pairs(allData) do
    -- Process each data entry
end

```

---

### hook

**Purpose**

Registers a hook function for the item

**When Called**

When setting up item-specific hook functions

**Parameters**

* `name` (*string*): The hook name to register
* `func` (*function*): The function to call for this hook

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register hook
item:hook("onUse", function(self)
    -- Handle use
end)

```

**Medium Complexity:**
```lua
-- Medium: Register with parameters
item:hook("onDrop", function(self, position)
    -- Handle drop
end)

```

**High Complexity:**
```lua
-- High: Complex hook registration
item:hook("customAction", function(self, data)
    -- Complex hook logic
end)

```

---

### postHook

**Purpose**

Registers a post-hook function for the item

**When Called**

When setting up item-specific post-hook functions that run after main hooks

**Parameters**

* `name` (*string*): The hook name to register
* `func` (*function*): The function to call for this post-hook

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register post-hook
item:postHook("onUse", function(self, result)
    -- Handle after use
end)

```

**Medium Complexity:**
```lua
-- Medium: Register with parameters
item:postHook("onDrop", function(self, result, position)
    -- Handle after drop
end)

```

**High Complexity:**
```lua
-- High: Complex post-hook registration
item:postHook("customAction", function(self, result, data)
    -- Complex post-hook logic
end)

```

---

### onRegistered

**Purpose**

Called when the item is registered in the system

**When Called**

During item registration, typically for precaching models

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Basic registration
function ITEM:onRegistered()
    -- Basic setup
end

```

**Medium Complexity:**
```lua
-- Medium: Model precaching
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
-- High: Complex registration setup
function ITEM:onRegistered()
    -- Complex initialization logic
end

```

---

### onRegistered

**Purpose**

Called when the item is registered in the system

**When Called**

During item registration, typically for precaching models

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Basic registration
function ITEM:onRegistered()
    -- Basic setup
end

```

**Medium Complexity:**
```lua
-- Medium: Model precaching
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
-- High: Complex registration setup
function ITEM:onRegistered()
    -- Complex initialization logic
end

```

---

### onRegistered

**Purpose**

Called when the item is registered in the system

**When Called**

During item registration, typically for precaching models

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Basic registration
function ITEM:onRegistered()
    -- Basic setup
end

```

**Medium Complexity:**
```lua
-- Medium: Model precaching
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
-- High: Complex registration setup
function ITEM:onRegistered()
    -- Complex initialization logic
end

```

---

### onRegistered

**Purpose**

Called when the item is registered in the system

**When Called**

During item registration, typically for precaching models

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Basic registration
function ITEM:onRegistered()
    -- Basic setup
end

```

**Medium Complexity:**
```lua
-- Medium: Model precaching
function ITEM:onRegistered()
    if self.model then
        util.PrecacheModel(self.model)
    end
end

```

**High Complexity:**
```lua
-- High: Complex registration setup
function ITEM:onRegistered()
    -- Complex initialization logic
end

```

---

### print

**Purpose**

Prints item information for debugging

**When Called**

When displaying item information in console or debug output

**Parameters**

* `detail` (*boolean, optional*): Whether to include detailed information

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Print basic info
item:print()

```

**Medium Complexity:**
```lua
-- Medium: Print with details
item:print(true)

```

**High Complexity:**
```lua
-- High: Complex debugging
if debugMode then
    item:print(true)
end

```

---

### printData

**Purpose**

Prints detailed item data for debugging

**When Called**

When displaying complete item data in console or debug output

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Print item data
item:printData()

```

**Medium Complexity:**
```lua
-- Medium: Conditional data printing
if debugMode then
    item:printData()
end

```

**High Complexity:**
```lua
-- High: Complex debugging with data
item:print(true)
item:printData()

```

---

### getName

**Purpose**

Gets the display name of the item

**When Called**

When displaying the item name in UI or inventory

**Returns**

* string - The display name of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item name
local name = item:getName()

```

**Medium Complexity:**
```lua
-- Medium: Use name in UI
local displayText = item:getName() .. " x" .. item:getQuantity()

```

**High Complexity:**
```lua
-- High: Complex name handling
local name = item:getName()
if name and name ~= "invalidName" then
    -- Handle valid name
end

```

---

### getDesc

**Purpose**

Gets the description of the item

**When Called**

When displaying the item description in UI or tooltips

**Returns**

* string - The description of the item

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item description
local desc = item:getDesc()

```

**Medium Complexity:**
```lua
-- Medium: Use description in tooltip
local tooltip = item:getName() .. "\n" .. item:getDesc()

```

**High Complexity:**
```lua
-- High: Complex description handling
local desc = item:getDesc()
if desc and desc ~= "invalidDescription" then
    -- Handle valid description
end

```

---

### removeFromInventory

**Purpose**

Removes the item from its current inventory

**When Called**

When transferring or removing an item from an inventory

**Parameters**

* `preserveItem` (*boolean, optional*): Whether to preserve the item data

**Returns**

* Promise - Promise that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove from inventory
item:removeFromInventory()

```

**Medium Complexity:**
```lua
-- Medium: Remove with preservation
item:removeFromInventory(true)

```

**High Complexity:**
```lua
-- High: Complex removal handling
item:removeFromInventory():next(function()
    -- Handle after removal
end)

```

---

### delete

**Purpose**

Deletes the item from the database and triggers cleanup

**When Called**

When permanently removing an item from the system

**Returns**

* Promise - Promise that resolves when deletion is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Delete item
item:delete()

```

**Medium Complexity:**
```lua
-- Medium: Delete with callback
item:delete():next(function()
    -- Handle after deletion
end)

```

**High Complexity:**
```lua
-- High: Complex deletion handling
item:destroy()
item:delete():next(function()
    -- Handle after deletion
end)

```

---

### remove

**Purpose**

Removes the item from the world and database

**When Called**

When completely removing an item from the game world

**Returns**

* Promise - Promise that resolves when removal is complete

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove item
item:remove()

```

**Medium Complexity:**
```lua
-- Medium: Remove with callback
item:remove():next(function()
    -- Handle after removal
end)

```

**High Complexity:**
```lua
-- High: Complex removal handling
item:remove():next(function()
    -- Handle after removal
end)

```

---

### destroy

**Purpose**

Destroys the item instance and notifies clients

**When Called**

When removing an item instance from memory

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Destroy item
item:destroy()

```

**Medium Complexity:**
```lua
-- Medium: Destroy with cleanup
item:destroy()
item:onDisposed()

```

**High Complexity:**
```lua
-- High: Complex destruction handling
item:destroy()
-- Additional cleanup logic

```

---

### onDisposed

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### getEntity

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### spawn

**Purpose**

Spawns the item as an entity in the world

**When Called**

When creating a physical item entity in the game world

**Parameters**

* `position` (*Vector|Player*): The spawn position or player to drop near
* `angles` (*Angle, optional*): The spawn angles for the entity

**Returns**

* Entity - The spawned item entity, or nil if failed

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Spawn item
local entity = item:spawn(Vector(0, 0, 0))

```

**Medium Complexity:**
```lua
-- Medium: Spawn with angles
local entity = item:spawn(Vector(0, 0, 0), Angle(0, 0, 0))

```

**High Complexity:**
```lua
-- High: Complex spawning with player
local entity = item:spawn(player, Angle(0, 0, 0))
if IsValid(entity) then
    -- Handle spawned entity
end

```

---

### transfer

**Purpose**

Transfers the item to a new inventory

**When Called**

When moving an item between inventories

**Parameters**

* `newInventory` (*Inventory*): The target inventory to transfer to
* `bBypass` (*boolean, optional*): Whether to bypass access checks

**Returns**

* boolean - True if transfer was successful

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Transfer item
item:transfer(targetInventory)

```

**Medium Complexity:**
```lua
-- Medium: Transfer with bypass
item:transfer(targetInventory, true)

```

**High Complexity:**
```lua
-- High: Complex transfer handling
if item:transfer(targetInventory) then
    -- Handle successful transfer
end

```

---

### onInstanced

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### onSync

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### onRemoved

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### onRestored

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### sync

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### setData

**Purpose**

Sets a data value for the item and synchronizes it

**When Called**

When storing or updating item data

**Parameters**

* `key` (*string*): The data key to set
* `value` (*any*): The value to store
* `receivers` (*Player|table, optional*): Specific players to sync to
* `noSave` (*boolean, optional*): Whether to skip database saving
* `noCheckEntity` (*boolean, optional*): Whether to skip entity checks

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set item data
item:setData("customValue", 100)

```

**Medium Complexity:**
```lua
-- Medium: Set data with specific receivers
item:setData("durability", 50, player)

```

**High Complexity:**
```lua
-- High: Complex data setting
item:setData("complexData", data, receivers, false, true)

```

---

### addQuantity

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### setQuantity

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

**Returns**

* boolean - True if sound was played successfully

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play a basic sound
entity:EmitSound("buttons/button15.wav")

```

**Medium Complexity:**
```lua
-- Medium: Play sound with custom volume and distance
entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)

```

**High Complexity:**
```lua
-- High: Play web sound with full parameters
entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)

```

---

### interact

**Purpose**

Handles item interaction with players

**When Called**

When a player interacts with an item (use, drop, etc.)

**Parameters**

* `action` (*string*): The action being performed
* `client` (*Player*): The player performing the action
* `entity` (*Entity, optional*): The item entity if applicable
* `data` (*any, optional*): Additional data for the interaction

**Returns**

* boolean - True if interaction was successful

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Use item
item:interact("use", player)

```

**Medium Complexity:**
```lua
-- Medium: Drop item with data
item:interact("drop", player, entity, position)

```

**High Complexity:**
```lua
-- High: Complex interaction
local success = item:interact("customAction", player, entity, data)
if success then
    -- Handle successful interaction
end

```

---

### getCategory

**Purpose**

Gets the localized category name of the item

**When Called**

When displaying item category in UI or sorting

**Returns**

* string - The localized category name

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get item category
local category = item:getCategory()

```

**Medium Complexity:**
```lua
-- Medium: Use category for sorting
local category = item:getCategory()
if category == "weapons" then
    -- Handle weapon category
end

```

**High Complexity:**
```lua
-- High: Complex category handling
local category = item:getCategory()
local displayName = item:getName() .. " (" .. category .. ")"

```

---

