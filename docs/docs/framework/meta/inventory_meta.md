## getData

**Description:**
    Returns a stored data value for this inventory.

---

### Parameters

    * key (string) – Data field key.
    * default (any) – Value if the key does not exist.

---

### Returns

    * any – Stored value or default.

---

**Realm:**
    Shared

---

## extend

**Description:**
    Creates a subclass of the inventory meta table with a new class name.

---

### Parameters

    * className (string) – Name of the subclass meta table.

---

### Returns

    * table – The newly derived inventory table.

---

**Realm:**
    Shared

---

## configure

**Description:**
    Stub for inventory configuration; meant to be overridden.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## addDataProxy

**Description:**
    Adds a proxy function that is called when a data field changes.

---

### Parameters

    * key (string) – Data field to watch.
    * onChange (function) – Callback receiving old and new values.

---

### Returns

---

**Realm:**
    Shared

---

## getItemsByUniqueID

**Description:**
    Returns all items in the inventory matching the given unique ID.

---

### Parameters

    * uniqueID (string) – Item unique identifier.
    * onlyMain (boolean) – Search only the main item list.

---

### Returns

    * table – Table of matching item objects.

---

**Realm:**
    Shared

---

## register

**Description:**
    Registers this inventory type with the lia.inventory system.

---

### Parameters

    * typeID (string) – Unique identifier for this inventory type.

---

### Returns

---

**Realm:**
    Shared

---

## new

**Description:**
    Creates a new inventory of this type.

---

### Parameters

---

### Returns

    * table – New inventory instance.

---

**Realm:**
    Shared

---

## tostring

**Description:**
    Returns a printable representation of this inventory.

---

### Parameters

---

### Returns

    * string – Formatted as "ClassName[id]".

---

**Realm:**
    Shared

---

## getType

**Description:**
    Retrieves the inventory type table from lia.inventory.

---

### Parameters

---

### Returns

    * table – Inventory type definition.

---

**Realm:**
    Shared

---

## onDataChanged

**Description:**
    Called when an inventory data field changes. Executes any
registered proxy callbacks for that field.

---

### Parameters

    * key (string) – Data field key.
    * oldValue (any) – Previous value.
    * newValue (any) – Updated value.

---

### Returns

---

**Realm:**
    Shared

---

## getItems

**Description:**
    Returns all items stored in this inventory.

---

### Parameters

---

### Returns

    * table – Item instance table indexed by itemID.

---

**Realm:**
    Shared

---

## getItemsOfType

**Description:**
    Collects all items that match the given unique ID.

---

### Parameters

    * itemType (string) – Item unique identifier.

---

### Returns

    * table – Array of matching items.

---

**Realm:**
    Shared

---

## getFirstItemOfType

**Description:**
    Retrieves the first item matching the given unique ID.

---

### Parameters

    * itemType (string) – Item unique identifier.

---

### Returns

    * Item|nil – The first matching item or nil.

---

**Realm:**
    Shared

---

## hasItem

**Description:**
    Determines whether the inventory contains an item type.

---

### Parameters

    * itemType (string) – Item unique identifier.

---

### Returns

    * boolean – True if an item is found.

---

**Realm:**
    Shared

---

## getItemCount

**Description:**
    Counts the total quantity of a specific item type.

---

### Parameters

    * itemType (string|nil) – Item unique ID to count. Counts all if nil.

---

### Returns

    * number – Sum of quantities.

---

**Realm:**
    Shared

---

## getID

**Description:**
    Returns the unique database ID of this inventory.

---

### Parameters

---

### Returns

    * number – Inventory identifier.

---

**Realm:**
    Shared

---

## eq

**Description:**
    Compares two inventories by ID for equality.

---

### Parameters

    * other (Inventory) – Other inventory to compare.

---

### Returns

    * boolean – True if both inventories share the same ID.

---

**Realm:**
    Shared

---

## addItem

**Description:**
    Inserts an item instance into this inventory and persists it.

---

### Parameters

    * item (Item) – Item to add.
    * noReplicate (boolean) – Skip network replication when true.

---

### Returns

---

**Realm:**
    Server

---

## removeItem

**Description:**
    Removes an item by ID and optionally deletes it.

---

### Parameters

    * itemID (number) – Unique item identifier.
    * preserveItem (boolean) – Keep item in database when true.

---

### Returns

---

**Realm:**
    Server

---

## syncData

**Description:**
    Sends a single data field to clients.

---

### Parameters

    * key (string) – Field to replicate.
    * recipients (table|nil) – Player recipients.

---

### Returns

---

**Realm:**
    Server

---

## sync

**Description:**
    Sends the entire inventory and its items to players.

---

### Parameters

    * recipients (table|nil) – Player recipients.

---

### Returns

---

**Realm:**
    Server

---

## delete

**Description:**
    Removes this inventory record from the database.

---

### Parameters

---

### Returns

---

**Realm:**
    Server

---

## destroy

**Description:**
    Destroys all items and removes network references.

---

### Parameters

---

### Returns

---

**Realm:**
    Server

---

