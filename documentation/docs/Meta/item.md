# Item Meta

Item management system for the Lilia framework.

---

Overview

The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.

---

### isRotated

#### 📋 Purpose
Reports whether the item is stored in a rotated state.

#### ⏰ When Called
Use when calculating grid dimensions or rendering the item icon.

#### ↩️ Returns
* boolean
True if the item is rotated.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if item:isRotated() then swapDims() end

```

---

### getWidth

#### 📋 Purpose
Returns the item's width considering rotation and defaults.

#### ⏰ When Called
Use when placing the item into a grid inventory.

#### ↩️ Returns
* number
Width in grid cells.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local w = item:getWidth()

```

---

### getHeight

#### 📋 Purpose
Returns the item's height considering rotation and defaults.

#### ⏰ When Called
Use when calculating how much vertical space an item needs.

#### ↩️ Returns
* number
Height in grid cells.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local h = item:getHeight()

```

---

### getQuantity

#### 📋 Purpose
Returns the current stack quantity for this item.

#### ⏰ When Called
Use when showing stack counts or validating transfers.

#### ↩️ Returns
* number
Quantity within the stack.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local count = item:getQuantity()

```

---

### tostring

#### 📋 Purpose
Builds a readable string identifier for the item.

#### ⏰ When Called
Use for logging, debugging, or console output.

#### ↩️ Returns
* string
Formatted identifier including uniqueID and item id.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    print(item:tostring())

```

---

### getID

#### 📋 Purpose
Retrieves the numeric identifier for this item instance.

#### ⏰ When Called
Use when persisting, networking, or comparing items.

#### ↩️ Returns
* number
Unique item ID.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local id = item:getID()

```

---

### getModel

#### 📋 Purpose
Returns the model path assigned to this item.

#### ⏰ When Called
Use when spawning an entity or rendering the item icon.

#### ↩️ Returns
* string
Model file path.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local mdl = item:getModel()

```

---

### getSkin

#### 📋 Purpose
Returns the skin index assigned to this item.

#### ⏰ When Called
Use when spawning the entity or applying cosmetics.

#### ↩️ Returns
* number|nil
Skin index or nil when not set.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local skin = item:getSkin()

```

---

### getBodygroups

#### 📋 Purpose
Provides the bodygroup configuration for the item model.

#### ⏰ When Called
Use when spawning or rendering to ensure correct bodygroups.

#### ↩️ Returns
* table
Key-value pairs of bodygroup indexes to values.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local groups = item:getBodygroups()

```

---

### getPrice

#### 📋 Purpose
Calculates the current sale price for the item.

#### ⏰ When Called
Use when selling, buying, or displaying item cost.

#### ↩️ Returns
* number
Price value, possibly adjusted by calcPrice.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local cost = item:getPrice()

```

---

### call

#### 📋 Purpose
Invokes an item method while temporarily setting context.

#### ⏰ When Called
Use when you need to call an item function with player/entity context.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `method` | **string** | Name of the item method to invoke. |
| `client` | **Player|nil** | Player to treat as the caller. |
| `entity` | **Entity|nil** | Entity representing the item. |

#### ↩️ Returns
* any
Return values from the invoked method.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:call("onUse", ply, ent)

```

---

### getOwner

#### 📋 Purpose
Attempts to find the player that currently owns this item.

#### ⏰ When Called
Use when routing notifications or networking to the item owner.

#### ↩️ Returns
* Player|nil
Owning player if found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local owner = item:getOwner()

```

---

### getData

#### 📋 Purpose
Reads a stored data value from the item or its entity.

#### ⏰ When Called
Use for custom item metadata such as durability or rotation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to read. |
| `default` | **any** | Value to return when the key is missing. |

#### ↩️ Returns
* any
Stored value or default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local durability = item:getData("durability", 100)

```

---

### getAllData

#### 📋 Purpose
Returns a merged table of all item data, including entity netvars.

#### ⏰ When Called
Use when syncing the entire data payload to clients.

#### ↩️ Returns
* table
Combined data table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local data = item:getAllData()

```

---

### hook

#### 📋 Purpose
Registers a pre-run hook for an item interaction.

#### ⏰ When Called
Use when adding custom behavior before an action executes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Hook name to bind. |
| `func` | **function** | Callback to execute. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:hook("use", function(itm) end)

```

---

### postHook

#### 📋 Purpose
Registers a post-run hook for an item interaction.

#### ⏰ When Called
Use when you need to react after an action completes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Hook name to bind. |
| `func` | **function** | Callback to execute with results. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:postHook("use", function(itm, result) end)

```

---

### onRegistered

#### 📋 Purpose
Performs setup tasks after an item definition is registered.

#### ⏰ When Called
Automatically invoked once the item type is loaded.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:onRegistered()

```

---

### print

#### 📋 Purpose
Prints a concise or detailed identifier for the item.

#### ⏰ When Called
Use during debugging or admin commands.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `detail` | **boolean** | Include owner and grid info when true. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:print(true)

```

---

### printData

#### 📋 Purpose
Outputs item metadata and all stored data fields.

#### ⏰ When Called
Use for diagnostics to inspect an item's state.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    item:printData()

```

---

### getName

#### 📋 Purpose
Returns the display name of the item.

#### ⏰ When Called
Use for UI labels, tooltips, and logs.

#### ↩️ Returns
* string
Item name.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local name = item:getName()

```

---

### getDesc

#### 📋 Purpose
Returns the description text for the item.

#### ⏰ When Called
Use in tooltips or inventory details.

#### ↩️ Returns
* string
Item description.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local desc = item:getDesc()

```

---

### removeFromInventory

#### 📋 Purpose
Removes the item from its current inventory instance.

#### ⏰ When Called
Use when dropping, deleting, or transferring the item out.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `preserveItem` | **boolean** | When true, keeps the instance for later use. |

#### ↩️ Returns
* Promise
Deferred resolution for removal completion.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:removeFromInventory():next(function() end)

```

---

### delete

#### 📋 Purpose
Deletes the item record from storage after destroying it in-game.

#### ⏰ When Called
Use when an item should be permanently removed.

#### ↩️ Returns
* Promise
Resolves after the database delete and callbacks run.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:delete()

```

---

### remove

#### 📋 Purpose
Removes the world entity, inventory reference, and database entry.

#### ⏰ When Called
Use when the item is consumed or otherwise removed entirely.

#### ↩️ Returns
* Promise
Resolves once removal and deletion complete.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:remove()

```

---

### destroy

#### 📋 Purpose
Broadcasts item deletion to clients and frees the instance.

#### ⏰ When Called
Use internally before removing an item from memory.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:destroy()

```

---

### onDisposed

#### 📋 Purpose
Hook called after an item is destroyed; intended for overrides.

#### ⏰ When Called
Automatically triggered when the item instance is disposed.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onDisposed() end

```

---

### onDisposed

#### 📋 Purpose
Hook called after an item is destroyed; intended for overrides.

#### ⏰ When Called
Automatically triggered when the item instance is disposed.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onDisposed() end

```

---

### getEntity

#### 📋 Purpose
Finds the world entity representing this item instance.

#### ⏰ When Called
Use when needing the spawned entity from the item data.

#### ↩️ Returns
* Entity|nil
Spawned item entity if present.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local ent = item:getEntity()

```

---

### spawn

#### 📋 Purpose
Spawns a world entity for this item at the given position and angle.

#### ⏰ When Called
Use when dropping an item into the world.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | **Vector|table|Entity** | Where to spawn, or the player dropping the item. |
| `angles` | **Angle|Vector|table|nil** | Orientation for the spawned entity. |

#### ↩️ Returns
* Entity|nil
Spawned entity on success.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local ent = item:spawn(ply, Angle(0, 0, 0))

```

---

### transfer

#### 📋 Purpose
Moves the item into another inventory if access rules allow.

#### ⏰ When Called
Use when transferring items between containers or players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `newInventory` | **Inventory** | Destination inventory. |
| `bBypass` | **boolean** | Skip access checks when true. |

#### ↩️ Returns
* boolean
True if the transfer was initiated.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:transfer(otherInv)

```

---

### onInstanced

#### 📋 Purpose
Hook called when a new item instance is created.

#### ⏰ When Called
Automatically invoked after instancing; override to customize.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onInstanced() end

```

---

### onInstanced

#### 📋 Purpose
Hook called when a new item instance is created.

#### ⏰ When Called
Automatically invoked after instancing; override to customize.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onInstanced() end

```

---

### onSync

#### 📋 Purpose
Hook called after the item data is synchronized to clients.

#### ⏰ When Called
Triggered by sync calls; override for custom behavior.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `recipient` | **Player|nil** | The player who received the sync, or nil for broadcast. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onSync(ply) end

```

---

### onSync

#### 📋 Purpose
Hook called after the item data is synchronized to clients.

#### ⏰ When Called
Triggered by sync calls; override for custom behavior.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `recipient` | **Player|nil** | The player who received the sync, or nil for broadcast. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onSync(ply) end

```

---

### onRemoved

#### 📋 Purpose
Hook called after the item has been removed from the world/inventory.

#### ⏰ When Called
Automatically invoked once deletion finishes.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onRemoved() end

```

---

### onRemoved

#### 📋 Purpose
Hook called after the item has been removed from the world/inventory.

#### ⏰ When Called
Automatically invoked once deletion finishes.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onRemoved() end

```

---

### onRestored

#### 📋 Purpose
Hook called after an item is restored from persistence.

#### ⏰ When Called
Automatically invoked after loading an item from the database.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onRestored() end

```

---

### onRestored

#### 📋 Purpose
Hook called after an item is restored from persistence.

#### ⏰ When Called
Automatically invoked after loading an item from the database.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function ITEM:onRestored() end

```

---

### sync

#### 📋 Purpose
Sends this item instance to a recipient or all clients for syncing.

#### ⏰ When Called
Use after creating or updating an item instance.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `recipient` | **Player|nil** | Specific player to sync; broadcasts when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:sync(ply)

```

---

### setData

#### 📋 Purpose
Sets a custom data value on the item, networking and saving as needed.

#### ⏰ When Called
Use when updating item metadata that clients or persistence require.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to set. |
| `value` | **any** | Value to store. |
| `receivers` | **Player|table|nil** | Targets to send the update to; defaults to owner. |
| `noSave` | **boolean** | Skip database write when true. |
| `noCheckEntity` | **boolean** | Skip updating the world entity netvar when true. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:setData("durability", 80, item:getOwner())

```

---

### addQuantity

#### 📋 Purpose
Increases the item quantity by the given amount.

#### ⏰ When Called
Use for stacking items or consuming partial quantities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `quantity` | **number** | Amount to add (can be negative). |
| `receivers` | **Player|table|nil** | Targets to notify; defaults to owner. |
| `noCheckEntity` | **boolean** | Skip updating the entity netvar when true. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:addQuantity(-1, ply)

```

---

### setQuantity

#### 📋 Purpose
Sets the item quantity, updating entities, clients, and storage.

#### ⏰ When Called
Use after splitting stacks or consuming items.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `quantity` | **number** | New stack amount. |
| `receivers` | **Player|table|nil** | Targets to notify; defaults to owner. |
| `noCheckEntity` | **boolean** | Skip updating the world entity netvar when true. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:setQuantity(5, ply)

```

---

### interact

#### 📋 Purpose
Handles an item interaction action, running hooks and callbacks.

#### ⏰ When Called
Use when a player selects an action from an item's context menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | **string** | Action identifier from the item's functions table. |
| `client` | **Player** | Player performing the action. |
| `entity` | **Entity|nil** | World entity representing the item, if any. |
| `data` | **any** | Additional data for multi-option actions. |

#### ↩️ Returns
* boolean
True if the action was processed; false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    item:interact("use", ply, ent)

```

---

### getCategory

#### 📋 Purpose
Returns the item's localized category label.

#### ⏰ When Called
Use when grouping or displaying items by category.

#### ↩️ Returns
* string
Localized category name, or "misc" if undefined.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local category = item:getCategory()

```

---

