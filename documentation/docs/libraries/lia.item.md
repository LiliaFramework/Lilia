# Item Library

Comprehensive item registration, instantiation, and management system for the Lilia framework.

---

## Overview

The item library provides comprehensive functionality for managing items in the Lilia framework.

It handles item registration, instantiation, inventory management, and item operations such as

dropping, taking, rotating, and transferring items between players. The library operates on both

server and client sides, with server-side functions handling database operations, item spawning,

and data persistence, while client-side functions manage item interactions and UI operations.

It includes automatic weapon and ammunition generation from Garry's Mod weapon lists, inventory

type registration, and item entity management. The library ensures proper item lifecycle management

from creation to deletion, with support for custom item functions, hooks, and data persistence.

---

### get

**Purpose**

Retrieves an item definition by its unique identifier from either base items or registered items

**When Called**

When you need to get an item definition for registration, instantiation, or reference

---

### getItemByID

**Purpose**

Retrieves an item instance by its ID along with location information

**When Called**

When you need to find an item instance and know where it's located (inventory or world)

---

### getInstancedItemByID

**Purpose**

Retrieves an item instance by its ID without location information

**When Called**

When you only need the item instance and don't care about its location

---

### getItemDataByID

**Purpose**

Retrieves the data table of an item instance by its ID

**When Called**

When you need to access the custom data stored in an item instance

---

### load

**Purpose**

Loads an item definition from a file path and registers it

**When Called**

During item loading process, typically called by lia.item.loadFromDir

---

### isItem

**Purpose**

Checks if an object is a valid item instance

**When Called**

When you need to validate that an object is an item before performing operations

---

### getInv

**Purpose**

Retrieves an inventory instance by its ID

**When Called**

When you need to access an inventory instance for item operations

---

### register

**Purpose**

Registers a new item definition with the item system

**When Called**

During item loading or when creating custom items programmatically

---

### loadFromDir

**Purpose**

Loads all item definitions from a directory structure

**When Called**

During gamemode initialization to load all items from the items directory

---

### new

**Purpose**

Creates a new item instance from an item definition

**When Called**

When you need to create a specific instance of an item with a unique ID

---

### registerInv

**Purpose**

Registers a new inventory type with specified dimensions

**When Called**

During initialization to register custom inventory types

---

### lia.inventory:getWidth

**Purpose**

Registers a new inventory type with specified dimensions

**When Called**

During initialization to register custom inventory types

---

### lia.inventory:getHeight

**Purpose**

Registers a new inventory type with specified dimensions

**When Called**

During initialization to register custom inventory types

---

### newInv

**Purpose**

Creates a new inventory instance for a specific owner

**When Called**

When you need to create a new inventory instance for a player or entity

---

### createInv

**Purpose**

Creates a new inventory instance with specified dimensions and ID

**When Called**

When you need to create a custom inventory with specific dimensions

---

### addWeaponOverride

**Purpose**

Adds override data for a specific weapon class during automatic weapon generation

**When Called**

Before calling lia.item.generateWeapons to customize weapon properties

---

### addWeaponToBlacklist

**Purpose**

Adds a weapon class to the blacklist to prevent it from being automatically generated

**When Called**

Before calling lia.item.generateWeapons to exclude specific weapons

---

### generateWeapons

**Purpose**

Automatically generates item definitions for all weapons in Garry's Mod

**When Called**

During gamemode initialization or when weapons need to be regenerated

---

### generateAmmo

**Purpose**

Automatically generates item definitions for ammunition entities (ARC9 and ARCCW)

**When Called**

During gamemode initialization or when ammunition items need to be regenerated

---

### setItemDataByID

**Purpose**

Sets data for an item instance by its ID on the server

**When Called**

When you need to modify item data from server-side code

**Parameters**

* `false,` (*unknown*): - Save to database
* `true` (*unknown*): - Skip entity check

---

### instance

**Purpose**

Creates a new item instance in a specific inventory with database persistence

**When Called**

When you need to create a new item instance that will be saved to the database

---

### deleteByID

**Purpose**

Deletes an item instance by its ID from both memory and database

**When Called**

When you need to permanently remove an item from the game

---

### loadItemByID

**Purpose**

Loads item instances from the database by their IDs

**When Called**

During server startup or when specific items need to be restored from database

---

### spawn

**Purpose**

Spawns an item entity in the world at a specific position

**When Called**

When you need to create an item that exists as a world entity

---

### restoreInv

**Purpose**

Restores an inventory from the database with specified dimensions

**When Called**

During server startup or when restoring inventories from database

---

