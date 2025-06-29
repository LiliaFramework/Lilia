# Inventory Meta

This document describes the methods available on inventory objects.

---

## Overview

These meta functions extend standard inventory objects with convenience helpers used throughout Lilia.

---

### `getData(key, default)`

    Description:
        Returns a stored data value for this inventory.

    Parameters:
        key (string) – Data field key.
        default (any) – Value if the key does not exist.

    Realm:
        Shared

    Returns:
        any – Stored value or default.

    Example Usage:
        -- Read how many times the container was opened
        local opens = inv:getData("openCount", 0)

### `extend(className)`

    Description:
        Creates a subclass of the inventory meta table with a new class name.

    Parameters:
        className (string) – Name of the subclass meta table.

    Realm:
        Shared

    Returns:
        table – The newly derived inventory table.

    Example Usage:
        -- Define a subclass for weapon crates and register it
        local WeaponInv = inv:extend("WeaponInventory")
        function WeaponInv:configure()
            self:addSlot("Ammo")
            self:addSlot("Weapons")
        end
        WeaponInv:register("weapon_inv")

### `configure()`

    Description:
        Stub for inventory configuration; meant to be overridden.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Called from a subclass to set up custom slots
        function WeaponInv:configure()
            self:addSlot("Ammo")
            self:addSlot("Weapons")
        end

### `addDataProxy(key, onChange)`

    Description:
        Adds a proxy function that is called when a data field changes.

    Parameters:
        key (string) – Data field to watch.
        onChange (function) – Callback receiving old and new values.

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Track changes to the "locked" data field
        inv:addDataProxy("locked", function(old, new)
            print("Locked state changed", old, new)
            hook.Run("ChestLocked", inv, new)
        end)

### `getItemsByUniqueID(uniqueID, onlyMain)`

    Description:
        Returns all items in the inventory matching the given unique ID.

    Parameters:
        uniqueID (string) – Item unique identifier.
        onlyMain (boolean) – Search only the main item list.

    Realm:
        Shared

    Returns:
        table – Table of matching item objects.

    Example Usage:
        -- Get all ammo boxes stored in the main list
        local ammo = inv:getItemsByUniqueID("ammo_box", true)

### `register(typeID)`

    Description:
        Registers this inventory type with the lia.inventory system.

    Parameters:
        typeID (string) – Unique identifier for this inventory type.

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Register and then immediately create the inventory type
        WeaponInv:register("weapon_inv")
        local chestInv = WeaponInv:new()

### `new()`

    Description:
        Creates a new inventory of this type.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – New inventory instance.

    Example Usage:
        -- Create an inventory and attach it to a spawned chest entity
        local chest = ents.Create("prop_physics")
        chest:SetModel("models/props_junk/wood_crate001a.mdl")
        chest:Spawn()
        chest.inv = WeaponInv:new()

### `tostring()`

    Description:
        Returns a printable representation of this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Formatted as "ClassName[id]".

    Example Usage:
        -- Print the identifier when debugging
        print("Inventory: " .. inv:tostring())

### `getType()`

    Description:
        Retrieves the inventory type table from lia.inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Inventory type definition.

    Example Usage:
        -- Read slot data from the type definition
        local def = inv:getType()

### `onDataChanged(key, oldValue, newValue)`

    Description:
        Called when an inventory data field changes. Executes any
        registered proxy callbacks for that field.

    Parameters:
        key (string) – Data field key.
        oldValue (any) – Previous value.
        newValue (any) – Updated value.

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- React when the stored credit amount changes
        inv:onDataChanged("credits", 0, 100)

### `getItems()`

    Description:
        Returns all items stored in this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Item instance table indexed by itemID.

    Example Usage:
        -- Sum the weight of all items
        for _, itm in pairs(inv:getItems()) do
            totalWeight = totalWeight + itm.weight
        end

### `getItemsOfType(itemType)`

    Description:
        Collects all items that match the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        table – Array of matching items.

    Example Usage:
        -- List all medkits currently in the inventory
        local kits = inv:getItemsOfType("medkit")

### `getFirstItemOfType(itemType)`

    Description:
        Retrieves the first item matching the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        Item|None – The first matching item or None.

    Example Usage:
        -- Grab the first pistol found in the inventory
        local pistol = inv:getFirstItemOfType("pistol")

### `hasItem(itemType)`

    Description:
        Determines whether the inventory contains an item type.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        boolean – True if an item is found.

    Example Usage:
        -- See if any health potion exists
        if inv:hasItem("health_potion") then ... end

### `getItemCount(itemType)`

    Description:
        Counts the total quantity of a specific item type.

    Parameters:
        itemType (string|None) – Item unique ID to count. Counts all if nil.

    Realm:
        Shared

    Returns:
        number – Sum of quantities.

    Example Usage:
        -- Count the total number of bullets
        local ammoTotal = inv:getItemCount("bullet")

### `getID()`

    Description:
        Returns the unique database ID of this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Inventory identifier.

    Example Usage:
        -- Store the inventory ID on its container entity
        entity:setNetVar("invID", inv:getID())

### `eq(other)`

    Description:
        Compares two inventories by ID for equality.

    Parameters:
        other (Inventory) – Other inventory to compare.

    Realm:
        Shared

    Returns:
        boolean – True if both inventories share the same ID.

    Example Usage:
        -- Check if two chests share the same inventory record
        if inv:eq(other) then
            print("Duplicate inventory")
        end

### `addItem(item, noReplicate)`

        Description:
            Inserts an item instance into this inventory and persists it.

        Parameters:
            item (Item) – Item to add.
            noReplicate (boolean) – Skip network replication when true.

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Add a looted item to the inventory
        inv:addItem(item, false)

### `removeItem(itemID, preserveItem)`

        Description:
            Removes an item by ID and optionally deletes it.

        Parameters:
            itemID (number) – Unique item identifier.
            preserveItem (boolean) – Keep item in database when true.

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Remove an item but keep it saved for later
        inv:removeItem(itemID, true)

### `syncData(key, recipients)`

        Description:
            Sends a single data field to clients.

        Parameters:
            key (string) – Field to replicate.
            recipients (table|None) – Player recipients.

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Sync the locked state to nearby players
        inv:syncData("locked", recipients)

### `sync(recipients)`

        Description:
            Sends the entire inventory and its items to players.

        Parameters:
            recipients (table|None) – Player recipients.

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Send all items to the owner after they join
        inv:sync({owner})

### `delete()`

        Description:
            Removes this inventory record from the database.

    Parameters:
        None

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Permanently delete a chest inventory on cleanup
        inv:delete()

### `destroy()`

        Description:
            Destroys all items and removes network references.

    Parameters:
        None

        Realm:
            Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Clear all items when the container entity is removed
        inv:destroy()

