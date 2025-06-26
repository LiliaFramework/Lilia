## getQuantity

**Description:**
    Retrieves how many of this item the stack represents.

---

### Parameters

---

### Returns

    * number – Quantity contained in this item instance.

---

**Realm:**
    Shared

---

## eq

**Description:**
    Compares this item instance to another by ID.

---

### Parameters

    * other (Item) – The other item to compare with.

---

### Returns

    * boolean – True if both items share the same ID.

---

**Realm:**
    Shared

---

## tostring

**Description:**
    Returns a printable representation of this item.

---

### Parameters

---

### Returns

    * string – Identifier in the form "item[uniqueID][id]".

---

**Realm:**
    Shared

---

## getID

**Description:**
    Retrieves the unique identifier of this item.

---

### Parameters

---

### Returns

    * number – Item database ID.

---

**Realm:**
    Shared

---

## getModel

**Description:**
    Returns the model path associated with this item.

---

### Parameters

---

### Returns

    * string – Model path.

---

**Realm:**
    Shared

---

## getSkin

**Description:**
    Retrieves the skin index this item uses.

---

### Parameters

---

### Returns

    * number – Skin ID applied to the model.

---

**Realm:**
    Shared

---

## getPrice

**Description:**
    Returns the calculated purchase price for the item.

---

### Parameters

---

### Returns

    * number – The price value.

---

**Realm:**
    Shared

---

## call

**Description:**
    Invokes an item method with the given player and entity context.

---

### Parameters

    * method (string) – Method name to run.
    * client (Player) – The player performing the action.
    * entity (Entity) – Entity representing this item.
    * ... – Additional arguments passed to the method.

---

### Returns

    * any – Results returned by the called function.

---

**Realm:**
    Shared

---

## getOwner

**Description:**
    Attempts to find the player currently owning this item.

---

### Parameters

---

### Returns

    * Player|nil – The owner if available.

---

**Realm:**
    Shared

---

## getData

**Description:**
    Retrieves a piece of persistent data stored on the item.

---

### Parameters

    * key (string) – Data key to read.
    * default (any) – Value to return when the key is absent.

---

### Returns

    * any – Stored value or default.

---

**Realm:**
    Shared

---

## getAllData

**Description:**
    Returns a merged table of this item's stored data and any
networked values on its entity.

---

### Parameters

---

### Returns

    * table – Key/value table of all data fields.

---

**Realm:**
    Shared

---

## hook

**Description:**
    Registers a hook callback for this item instance.

---

### Parameters

    * name (string) – Hook identifier.
    * func (function) – Function to call.

---

### Returns

---

**Realm:**
    Shared

---

## postHook

**Description:**
    Registers a post-hook callback for this item.

---

### Parameters

    * name (string) – Hook identifier.
    * func (function) – Function invoked after the main hook.

---

### Returns

---

**Realm:**
    Shared

---

## onRegistered

**Description:**
    Called when the item table is first registered.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## print

**Description:**
    Prints a simple representation of the item to the console.

---

### Parameters

    * detail (boolean) – Include position details when true.

---

### Returns

---

**Realm:**
    Server

---

## printData

**Description:**
    Debug helper that prints all stored item data.

---

### Parameters

---

### Returns

---

**Realm:**
    Server

---

## addQuantity

**Description:**
    Increases the stored quantity for this item instance.

---

### Parameters

    * quantity (number) – Amount to add.
    * receivers (Player|nil) – Who to network the change to.
    * noCheckEntity (boolean) – Skip entity network update.

---

### Returns

---

**Realm:**
    Server

---

## setQuantity

**Description:**
    Sets the current stack quantity and replicates the change.

---

### Parameters

    * quantity (number) – New amount to store.
    * receivers (Player|nil) – Recipients to send updates to.
    * noCheckEntity (boolean) – Skip entity updates when true.

---

### Returns

---

**Realm:**
    Server

---

