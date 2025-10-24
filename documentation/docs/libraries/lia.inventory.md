# Inventory Library

Comprehensive inventory system management with multiple storage types for the Lilia framework.

---

## Overview

The inventory library provides comprehensive functionality for managing inventory systems

in the Lilia framework. It handles inventory type registration, instance creation, storage

management, and database persistence. The library operates on both server and client sides,

with the server managing inventory data persistence, loading, and storage registration,

while the client handles inventory panel display and user interaction. It supports multiple

inventory types, storage containers, vehicle trunks, and character-based inventory management.

The library ensures proper data validation, caching, and cleanup for optimal performance.

---

### newType

**Purpose**

Registers a new inventory type with the system

**When Called**

During module initialization or when defining custom inventory types

**Parameters**

* `typeID` (*string*): Unique identifier for the inventory type
* `invTypeStruct` (*table*): Structure containing inventory type configuration

---

### new

**Purpose**

Creates a new inventory instance of the specified type

**When Called**

When creating inventory instances for players, storage containers, or vehicles

**Parameters**

* `typeID` (*string*): The inventory type identifier to create an instance of

---

### loadByID

**Purpose**

Loads an inventory instance by its ID from storage or cache

**When Called**

When accessing an existing inventory that may be cached or needs to be loaded from database

**Parameters**

* `id` (*number*): The inventory ID to load
* `noCache` (*boolean, optional*): If true, bypasses cache and forces reload from storage

---

### loadFromDefaultStorage

**Purpose**

Loads an inventory from the default database storage system

**When Called**

When loadByID cannot find a custom loader and needs to use default storage

**Parameters**

* `id` (*number*): The inventory ID to load from database
* `noCache` (*boolean, optional*): If true, bypasses cache and forces reload from database

---

### instance

**Purpose**

Creates a new inventory instance and initializes it in storage

**When Called**

When creating new inventories that need to be persisted to database

**Parameters**

* `typeID` (*string*): The inventory type identifier
* `initialData` (*table, optional*): Initial data to store with the inventory

---

### loadAllFromCharID

**Purpose**

Loads all inventories associated with a specific character ID

**When Called**

When a character logs in or when accessing all character inventories

**Parameters**

* `charID` (*number*): The character ID to load inventories for

---

### deleteByID

**Purpose**

Permanently deletes an inventory and all its associated data from the database

**When Called**

When removing inventories that are no longer needed or during cleanup operations

**Parameters**

* `id` (*number*): The inventory ID to delete

---

### cleanUpForCharacter

**Purpose**

Destroys all inventory instances associated with a character

**When Called**

When a character is deleted or during character cleanup operations

**Parameters**

* `character` (*table*): The character object containing inventory references

---

### checkOverflow

**Purpose**

Checks for and handles inventory overflow when inventory size changes

**When Called**

When an inventory's dimensions are reduced and items may no longer fit

**Parameters**

* `inv` (*table*): The inventory instance to check for overflow
* `character` (*table*): The character object to store overflow items with
* `oldW` (*number*): The previous width of the inventory
* `oldH` (*number*): The previous height of the inventory

---

### registerStorage

**Purpose**

Registers a storage container model with inventory configuration

**When Called**

During module initialization to register storage containers like crates, lockers, etc.

**Parameters**

* `model` (*string*): The model path of the storage container
* `data` (*table*): Configuration data containing name, invType, and invData

---

### getStorage

**Purpose**

Retrieves storage configuration data for a specific model

**When Called**

When checking if a model has registered storage or accessing storage configuration

**Parameters**

* `model` (*string*): The model path to look up storage data for

---

### registerTrunk

**Purpose**

Registers a vehicle class with trunk inventory configuration

**When Called**

During module initialization to register vehicle trunks

**Parameters**

* `vehicleClass` (*string*): The vehicle class name
* `data` (*table*): Configuration data containing name, invType, and invData

---

### getTrunk

**Purpose**

Retrieves trunk configuration data for a specific vehicle class

**When Called**

When checking if a vehicle has a trunk or accessing trunk configuration

**Parameters**

* `vehicleClass` (*string*): The vehicle class name to look up trunk data for

---

### getAllTrunks

**Purpose**

Retrieves all registered vehicle trunk configurations

**When Called**

When needing to iterate through all available vehicle trunks

---

### getAllStorage

**Purpose**

Retrieves all registered storage configurations with optional trunk filtering

**When Called**

When needing to iterate through all available storage containers

**Parameters**

* `includeTrunks` (*boolean, optional*): If false, excludes vehicle trunks from results

---

### show

**Purpose**

Displays an inventory panel to the client

**When Called**

When a player opens an inventory (player inventory, storage container, etc.)

**Parameters**

* `inventory` (*table*): The inventory instance to display
* `parent` (*panel, optional*): Parent panel to attach the inventory panel to
* `closeBtn:SetPos(panel:GetWide()` (*unknown*): 80, 10)

---

### lia.panel:OnRemove

**Purpose**

Displays an inventory panel to the client

**When Called**

When a player opens an inventory (player inventory, storage container, etc.)

**Parameters**

* `inventory` (*table*): The inventory instance to display
* `parent` (*panel, optional*): Parent panel to attach the inventory panel to
* `closeBtn:SetPos(panel:GetWide()` (*unknown*): 80, 10)

---

