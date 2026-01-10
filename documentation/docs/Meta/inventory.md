# Inventory Meta

Inventory management system for the Lilia framework.

---

Overview

The inventory meta table provides comprehensive functionality for managing inventory data, item storage, and inventory operations in the Lilia framework. It handles inventory creation, item management, data persistence, capacity management, and inventory-specific operations. The meta table operates on both server and client sides, with the server managing inventory storage and validation while the client provides inventory data access and display. It includes integration with the item system for item storage, database system for inventory persistence, character system for character inventories, and network system for inventory synchronization. The meta table ensures proper inventory data synchronization, item capacity management, item validation, and comprehensive inventory lifecycle management from creation to deletion.

---

### getData

#### 📋 Purpose
Retrieves a stored data value on the inventory.

#### ⏰ When Called
Use whenever reading custom inventory metadata.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to read. |
| `default` | **any** | Value returned when the key is missing. |

#### ↩️ Returns
* any
Stored value or the provided default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local owner = inv:getData("char")

```

---

### extend

#### 📋 Purpose
Creates a subclass of Inventory with its own metatable.

#### ⏰ When Called
Use when defining a new inventory type.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `className` | **string** | Registry name for the new subclass. |

#### ↩️ Returns
* table
Newly created subclass table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local Backpack = Inventory:extend("liaBackpack")

```

---

### configure

#### 📋 Purpose
Sets up inventory defaults; meant to be overridden.

#### ⏰ When Called
Invoked during type registration to configure behavior.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    function Inventory:configure() self.config.size = {4,4} end

```

---

### configure

#### 📋 Purpose
Sets up inventory defaults; meant to be overridden.

#### ⏰ When Called
Invoked during type registration to configure behavior.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    function Inventory:configure() self.config.size = {4,4} end

```

---

### addDataProxy

#### 📋 Purpose
Registers a proxy callback for a specific data key.

#### ⏰ When Called
Use when you need to react to data changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to watch. |
| `onChange` | **function** | Callback receiving old and new values. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    inv:addDataProxy("locked", function(o,n) end)

```

---

### getItemsByUniqueID

#### 📋 Purpose
Returns all items in the inventory matching a uniqueID.

#### ⏰ When Called
Use when finding all copies of a specific item type.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Item unique identifier. |
| `onlyMain` | **boolean** | Restrict search to main inventory when true. |

#### ↩️ Returns
* table
Array of matching item instances.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local meds = inv:getItemsByUniqueID("medkit")

```

---

### register

#### 📋 Purpose
Registers this inventory type with the system.

#### ⏰ When Called
Invoke once per subclass to set type ID and defaults.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | Unique identifier for this inventory type. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    Inventory:register("bag")

```

---

### new

#### 📋 Purpose
Creates a new instance of this inventory type.

#### ⏰ When Called
Use when a character or container needs a fresh inventory.

#### ↩️ Returns
* table
Deferred inventory instance creation.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local inv = Inventory:new()

```

---

### tostring

#### 📋 Purpose
Formats the inventory as a readable string with its ID.

#### ⏰ When Called
Use for logging or debugging output.

#### ↩️ Returns
* string
Localized class name and ID.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    print(inv:tostring())

```

---

### getType

#### 📋 Purpose
Returns the inventory type definition table.

#### ⏰ When Called
Use when accessing type-level configuration.

#### ↩️ Returns
* table
Registered inventory type data.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local typeData = inv:getType()

```

---

### onDataChanged

#### 📋 Purpose
Fires proxy callbacks when a tracked data value changes.

#### ⏰ When Called
Internally after setData updates.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key that changed. |
| `oldValue` | **any** | Previous value. |
| `newValue` | **any** | New value. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    inv:onDataChanged("locked", false, true)

```

---

### getItems

#### 📋 Purpose
Returns the table of item instances in this inventory.

#### ⏰ When Called
Use when iterating all items.

#### ↩️ Returns
* table
Item instances keyed by item ID.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for id, itm in pairs(inv:getItems()) do end

```

---

### getItemsOfType

#### 📋 Purpose
Collects items of a given type from the inventory.

#### ⏰ When Called
Use when filtering for a specific item uniqueID.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemType` | **string** | Unique item identifier to match. |

#### ↩️ Returns
* table
Array of matching items.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local foods = inv:getItemsOfType("food")

```

---

### getFirstItemOfType

#### 📋 Purpose
Returns the first item matching a uniqueID.

#### ⏰ When Called
Use when only one instance of a type is needed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemType` | **string** | Unique item identifier to find. |

#### ↩️ Returns
* table|nil
Item instance or nil if none found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local gun = inv:getFirstItemOfType("pistol")

```

---

### hasItem

#### 📋 Purpose
Checks whether the inventory contains an item type.

#### ⏰ When Called
Use before consuming or requiring an item.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemType` | **string** | Unique item identifier to check. |

#### ↩️ Returns
* boolean
True if at least one matching item exists.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if inv:hasItem("keycard") then unlock() end

```

---

### getItemCount

#### 📋 Purpose
Counts items, optionally filtering by uniqueID.

#### ⏰ When Called
Use for capacity checks or UI badge counts.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemType` | **string|nil** | Unique ID to filter by; nil counts all. |

#### ↩️ Returns
* number
Total quantity of matching items.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ammoCount = inv:getItemCount("ammo")

```

---

### getID

#### 📋 Purpose
Returns the numeric identifier for this inventory.

#### ⏰ When Called
Use when networking, saving, or comparing inventories.

#### ↩️ Returns
* number
Inventory ID.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local id = inv:getID()

```

---

### addItem

#### 📋 Purpose
Inserts an item into this inventory and persists its invID.

#### ⏰ When Called
Use when adding an item to the inventory on the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item instance to add. |
| `noReplicate` | **boolean** | Skip replication hooks when true. |

#### ↩️ Returns
* Inventory
The inventory for chaining.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:addItem(item)

```

---

### add

#### 📋 Purpose
Alias to addItem for convenience.

#### ⏰ When Called
Use wherever you would call addItem.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item instance to add. |

#### ↩️ Returns
* Inventory
The inventory for chaining.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:add(item)

```

---

### syncItemAdded

#### 📋 Purpose
Notifies clients about an item newly added to this inventory.

#### ⏰ When Called
Invoked after addItem to replicate state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item instance already inserted. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:syncItemAdded(item)

```

---

### initializeStorage

#### 📋 Purpose
Creates a database record for a new inventory and its data.

#### ⏰ When Called
Use during initial inventory creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `initialData` | **table** | Key/value pairs to seed invdata rows; may include char. |

#### ↩️ Returns
* Promise
Resolves with new inventory ID.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:initializeStorage({char = charID})

```

---

### restoreFromStorage

#### 📋 Purpose
Hook for restoring inventory data from storage.

#### ⏰ When Called
Override to load custom data during restoration.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:restoreFromStorage() end

```

---

### restoreFromStorage

#### 📋 Purpose
Hook for restoring inventory data from storage.

#### ⏰ When Called
Override to load custom data during restoration.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:restoreFromStorage() end

```

---

### removeItem

#### 📋 Purpose
Removes an item from this inventory and updates clients/DB.

#### ⏰ When Called
Use when deleting or moving items out of the inventory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | ID of the item to remove. |
| `preserveItem` | **boolean** | Keep the instance and DB row when true. |

#### ↩️ Returns
* Promise
Resolves after removal finishes.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:removeItem(itemID)

```

---

### remove

#### 📋 Purpose
Alias for removeItem.

#### ⏰ When Called
Use interchangeably with removeItem.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | ID of the item to remove. |

#### ↩️ Returns
* Promise
Resolves after removal.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:remove(id)

```

---

### setData

#### 📋 Purpose
Updates inventory data, persists it, and notifies listeners.

#### ⏰ When Called
Use to change stored metadata such as character assignment.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to set. |
| `value` | **any** | New value or nil to delete. |

#### ↩️ Returns
* Inventory
The inventory for chaining.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:setData("locked", true)

```

---

### canAccess

#### 📋 Purpose
Evaluates access rules for a given action context.

#### ⏰ When Called
Use before allowing inventory interactions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | **string** | Action name (e.g., "repl", "transfer"). |
| `context` | **table** | Additional data such as client. |

#### ↩️ Returns
* boolean|nil, string|nil
Decision and optional reason if a rule handled it.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local ok = inv:canAccess("repl", {client = ply})

```

---

### addAccessRule

#### 📋 Purpose
Inserts an access rule into the rule list.

#### ⏰ When Called
Use when configuring permissions for this inventory type.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule` | **function** | Function returning decision and reason. |
| `priority` | **number|nil** | Optional insert position. |

#### ↩️ Returns
* Inventory
The inventory for chaining.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:addAccessRule(myRule, 1)

```

---

### removeAccessRule

#### 📋 Purpose
Removes a previously added access rule.

#### ⏰ When Called
Use when unregistering dynamic permission logic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule` | **function** | The rule function to remove. |

#### ↩️ Returns
* Inventory
The inventory for chaining.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:removeAccessRule(myRule)

```

---

### getRecipients

#### 📋 Purpose
Determines which players should receive inventory replication.

#### ⏰ When Called
Use before sending inventory data to clients.

#### ↩️ Returns
* table
List of player recipients allowed by access rules.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local recips = inv:getRecipients()

```

---

### onInstanced

#### 📋 Purpose
Hook called when an inventory instance is created.

#### ⏰ When Called
Override to perform custom initialization.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onInstanced() end

```

---

### onInstanced

#### 📋 Purpose
Hook called when an inventory instance is created.

#### ⏰ When Called
Override to perform custom initialization.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onInstanced() end

```

---

### onLoaded

#### 📋 Purpose
Hook called after inventory data is loaded.

#### ⏰ When Called
Override to react once storage data is retrieved.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onLoaded() end

```

---

### onLoaded

#### 📋 Purpose
Hook called after inventory data is loaded.

#### ⏰ When Called
Override to react once storage data is retrieved.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onLoaded() end

```

---

### loadItems

#### 📋 Purpose
Loads item instances from the database into this inventory.

#### ⏰ When Called
Use during inventory initialization to restore contents.

#### ↩️ Returns
* Promise
Resolves with the loaded items table.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:loadItems():next(function(items) end)

```

---

### onItemsLoaded

#### 📋 Purpose
Hook called after items are loaded into the inventory.

#### ⏰ When Called
Override to run logic after contents are ready.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `items` | **table** | Loaded items table. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onItemsLoaded(items) end

```

---

### onItemsLoaded

#### 📋 Purpose
Hook called after items are loaded into the inventory.

#### ⏰ When Called
Override to run logic after contents are ready.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `items` | **table** | Loaded items table. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    function Inventory:onItemsLoaded(items) end

```

---

### instance

#### 📋 Purpose
Creates and registers an inventory instance with initial data.

#### ⏰ When Called
Use to instantiate a server-side inventory of this type.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `initialData` | **table** | Data used during creation (e.g., char assignment). |

#### ↩️ Returns
* Promise
Resolves with the new inventory instance.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    Inventory:instance({char = charID})

```

---

### syncData

#### 📋 Purpose
Sends a single inventory data key to recipients.

#### ⏰ When Called
Use after setData to replicate a specific field.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Data key to send. |
| `recipients` | **Player|table|nil** | Targets to notify; defaults to recipients with access. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:syncData("locked")

```

---

### sync

#### 📋 Purpose
Sends full inventory state and contained items to recipients.

#### ⏰ When Called
Use when initializing or resyncing an inventory for clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `recipients` | **Player|table|nil** | Targets to receive the update; defaults to access list. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:sync(ply)

```

---

### delete

#### 📋 Purpose
Deletes this inventory via the inventory manager.

#### ⏰ When Called
Use when permanently removing an inventory record.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:delete()

```

---

### destroy

#### 📋 Purpose
Clears inventory items, removes it from cache, and notifies clients.

#### ⏰ When Called
Use when unloading or destroying an inventory instance.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    inv:destroy()

```

---

### show

#### 📋 Purpose
Opens the inventory UI on the client.

#### ⏰ When Called
Use to display this inventory to the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parent` | **Panel** | Optional parent panel. |

#### ↩️ Returns
* Panel
The created inventory panel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    inv:show()

```

---

