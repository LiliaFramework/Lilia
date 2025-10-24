# Inventory Meta

Inventory management system for the Lilia framework.

---

## Overview

The inventory meta table provides comprehensive functionality for managing inventory data, item storage, and inventory operations in the Lilia framework. It handles inventory creation, item management, data persistence, capacity management, and inventory-specific operations. The meta table operates on both server and client sides, with the server managing inventory storage and validation while the client provides inventory data access and display. It includes integration with the item system for item storage, database system for inventory persistence, character system for character inventories, and network system for inventory synchronization. The meta table ensures proper inventory data synchronization, item capacity management, item validation, and comprehensive inventory lifecycle management from creation to deletion.

---

### getData

**Purpose**

Retrieves data from the inventory's data table with optional default fallback

**When Called**

Whenever inventory data needs to be accessed with a safe default value

**Parameters**

* `key` (*unknown*): The data key to retrieve
* `default` (*unknown*): Optional default value if key doesn't exist

---

### logAccess

**Purpose**

Extends a class with the Inventory metatable functionality

**When Called**

During inventory type registration to create specialized inventory types

**Parameters**

* `className` (*unknown*): The name of the class to extend

---

### extend

**Purpose**

Extends a class with the Inventory metatable functionality

**When Called**

During inventory type registration to create specialized inventory types

**Parameters**

* `className` (*unknown*): The name of the class to extend

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

---

### configure

**Purpose**

Configures the inventory type with default settings and rules

**When Called**

During inventory type registration, allows customization of inventory behavior

---

### addDataProxy

**Purpose**

Adds a data proxy function that gets called when specific data changes

**When Called**

During inventory configuration to set up data change callbacks

**Parameters**

* `key` (*unknown*): The data key to monitor for changes
* `onChange` (*unknown*): Function to call when the data changes (oldValue, newValue)

---

### getItemsByUniqueID

**Purpose**

Retrieves all items with a specific uniqueID from the inventory

**When Called**

When you need to find all instances of a particular item type

**Parameters**

* `uniqueID` (*unknown*): The uniqueID of the item type to find
* `onlyMain` (*unknown*): Optional boolean to only return items in main inventory slots

---

### register

**Purpose**

Registers this inventory type with the Lilia inventory system

**When Called**

During inventory type definition to make it available for use

**Parameters**

* `typeID` (*unknown*): String identifier for this inventory type

---

### new

**Purpose**

Creates a new instance of this inventory type

**When Called**

When you need to create a new inventory of this type

---

### tostring

**Purpose**

Returns a string representation of the inventory

**When Called**

For debugging, logging, or display purposes

---

### getType

**Purpose**

Gets the inventory type configuration

**When Called**

When you need to access type-specific settings or behavior

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value

---

### onDataChanged

**Purpose**

Called when inventory data changes, triggers proxy functions

**When Called**

Automatically when setData is called and data changes

**Parameters**

* `key` (*unknown*): The data key that changed
* `oldValue` (*unknown*): The previous value
* `newValue` (*unknown*): The new value

---

### getItems

**Purpose**

Gets all items in the inventory

**When Called**

When you need to iterate through all inventory items

---

### getItemsOfType

**Purpose**

Gets all items of a specific type from the inventory

**When Called**

When you need items of a particular type for processing

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to find

---

### getFirstItemOfType

**Purpose**

Gets the first item of a specific type from the inventory

**When Called**

When you need any single item of a type (efficiency over getting all)

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to find

---

### hasItem

**Purpose**

Checks if the inventory contains at least one item of a specific type

**When Called**

For quick boolean checks before performing actions

**Parameters**

* `itemType` (*unknown*): The uniqueID of the item type to check for

---

### getItemCount

**Purpose**

Counts total quantity of items of a specific type in the inventory

**When Called**

When you need to know how many of a particular item type exist

**Parameters**

* `itemType` (*unknown*): Optional uniqueID of item type to count, nil for all items

---

### getID

**Purpose**

Gets the unique ID of this inventory instance

**When Called**

When you need to reference this specific inventory instance

---

### addItem

**Purpose**

Adds an item to the inventory with optional replication control

**When Called**

When items need to be added to an inventory instance

**Parameters**

* `item` (*unknown*): The item instance to add
* `noReplicate` (*unknown*): Optional boolean to skip network synchronization

---

### add

**Purpose**

Alias for addItem method for convenience

**When Called**

Alternative method name for adding items

**Parameters**

* `item` (*unknown*): The item instance to add

---

### syncItemAdded

**Purpose**

Synchronizes newly added items to appropriate clients

**When Called**

Automatically called when items are added to inventory

**Parameters**

* `item` (*unknown*): The item that was added

---

### initializeStorage

**Purpose**

Initializes inventory storage in the database

**When Called**

When creating new persistent inventories

**Parameters**

* `initialData` (*unknown*): Initial data to store with the inventory

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

---

### restoreFromStorage

**Purpose**

Placeholder for restoring inventory from storage

**When Called**

When loading existing inventories from database

---

### removeItem

**Purpose**

Removes an item from the inventory with optional preservation

**When Called**

When items need to be removed from inventory

**Parameters**

* `itemID` (*unknown*): The ID of the item to remove
* `preserveItem` (*unknown*): Optional boolean to preserve item data in database

---

### remove

**Purpose**

Alias for removeItem method for convenience

**When Called**

Alternative method name for removing items

**Parameters**

* `itemID` (*unknown*): The ID of the item to remove

---

### setData

**Purpose**

Sets data for the inventory and persists to database

**When Called**

When inventory data needs to be updated

**Parameters**

* `key` (*unknown*): The data key to set
* `value` (*unknown*): The value to set for the key

---

### canAccess

**Purpose**

Checks if an action is allowed on this inventory

**When Called**

Before performing actions that require access control

**Parameters**

* `action` (*unknown*): The action to check (e.g., "repl", "add", "remove")
* `context` (*unknown*): Optional context table with additional information

---

### addAccessRule

**Purpose**

Adds an access control rule to the inventory

**When Called**

During inventory configuration to set up access control

**Parameters**

* `rule` (*unknown*): Function that takes (inventory, action, context) and returns bool, string
* `priority` (*unknown*): Optional priority number for rule evaluation order

---

### removeAccessRule

**Purpose**

Removes an access control rule from the inventory

**When Called**

When access rules need to be removed or updated

**Parameters**

* `rule` (*unknown*): The rule function to remove

---

### getRecipients

**Purpose**

Gets list of clients that should receive inventory updates

**When Called**

When synchronizing inventory changes to clients

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

---

### onInstanced

**Purpose**

Called when inventory instance is created

**When Called**

Automatically when inventory instances are created

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

---

### onLoaded

**Purpose**

Called when inventory is loaded from storage

**When Called**

Automatically when persistent inventories are loaded

---

### loadItems

**Purpose**

Loads items from database storage

**When Called**

When inventory needs to be populated from persistent storage

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items

---

### onItemsLoaded

**Purpose**

Called after items are loaded from storage

**When Called**

Automatically after loadItems completes successfully

**Parameters**

* `items` (*unknown*): Table of loaded items

---

### instance

**Purpose**

Creates a new instance of this inventory type with initial data

**When Called**

When creating configured inventory instances

**Parameters**

* `initialData` (*unknown*): Initial data for the inventory instance

---

### syncData

**Purpose**

Synchronizes inventory data changes to clients

**When Called**

When inventory data changes and needs to be replicated

**Parameters**

* `key` (*unknown*): The data key that changed
* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients

---

### sync

**Purpose**

Synchronizes entire inventory state to clients

**When Called**

When clients need full inventory state (initial load, resync)

**Parameters**

* `recipients` (*unknown*): Optional specific clients to send to, defaults to all recipients

---

### delete

**Purpose**

Deletes the inventory from the system

**When Called**

When inventory should be permanently removed

---

### destroy

**Purpose**

Destroys the inventory and all its items

**When Called**

When inventory and all contents should be completely removed

---

### show

**Purpose**

Shows the inventory panel to the player

**When Called**

When player opens inventory interface

**Parameters**

* `parent` (*unknown*): Optional parent panel for the inventory UI

---

