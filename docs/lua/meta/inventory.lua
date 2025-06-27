--[[
    getData(key, default)

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
        local result = inv:getData(key, default)
]]
--[[
    extend(className)

    Description:
        Creates a subclass of the inventory meta table with a new class name.

    Parameters:
        className (string) – Name of the subclass meta table.

    Realm:
        Shared

    Returns:
        table – The newly derived inventory table.

    Example Usage:
        local result = inv:extend(className)
]]
--[[
    configure()

    Description:
        Stub for inventory configuration; meant to be overridden.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        local result = inv:configure()
]]
--[[
    addDataProxy(key, onChange)

    Description:
        Adds a proxy function that is called when a data field changes.

    Parameters:
        key (string) – Data field to watch.
        onChange (function) – Callback receiving old and new values.

    Realm:
        Shared

    Example Usage:
        local result = inv:addDataProxy(key, onChange)
]]
--[[
    getItemsByUniqueID(uniqueID, onlyMain)

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
        local result = inv:getItemsByUniqueID(uniqueID, onlyMain)
]]
--[[
    register(typeID)

    Description:
        Registers this inventory type with the lia.inventory system.

    Parameters:
        typeID (string) – Unique identifier for this inventory type.

    Realm:
        Shared

    Example Usage:
        local result = inv:register(typeID)
]]
--[[
    new()

    Description:
        Creates a new inventory of this type.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – New inventory instance.

    Example Usage:
        local result = inv:new()
]]
--[[
    tostring()

    Description:
        Returns a printable representation of this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Formatted as "ClassName[id]".

    Example Usage:
        local result = inv:tostring()
]]
--[[
    getType()

    Description:
        Retrieves the inventory type table from lia.inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Inventory type definition.

    Example Usage:
        local result = inv:getType()
]]
--[[
    onDataChanged(key, oldValue, newValue)

    Description:
        Called when an inventory data field changes. Executes any
        registered proxy callbacks for that field.

    Parameters:
        key (string) – Data field key.
        oldValue (any) – Previous value.
        newValue (any) – Updated value.

    Realm:
        Shared

    Example Usage:
        local result = inv:onDataChanged(key, oldValue, newValue)
]]
--[[
    getItems()

    Description:
        Returns all items stored in this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Item instance table indexed by itemID.

    Example Usage:
        local result = inv:getItems()
]]
--[[
    getItemsOfType(itemType)

    Description:
        Collects all items that match the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        table – Array of matching items.

    Example Usage:
        local result = inv:getItemsOfType(itemType)
]]
--[[
    getFirstItemOfType(itemType)

    Description:
        Retrieves the first item matching the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        Item|nil – The first matching item or nil.

    Example Usage:
        local result = inv:getFirstItemOfType(itemType)
]]
--[[
    hasItem(itemType)

    Description:
        Determines whether the inventory contains an item type.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        boolean – True if an item is found.

    Example Usage:
        local result = inv:hasItem(itemType)
]]
--[[
    getItemCount(itemType)

    Description:
        Counts the total quantity of a specific item type.

    Parameters:
        itemType (string|nil) – Item unique ID to count. Counts all if nil.

    Realm:
        Shared

    Returns:
        number – Sum of quantities.

    Example Usage:
        local result = inv:getItemCount(itemType)
]]
--[[
    getID()

    Description:
        Returns the unique database ID of this inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Inventory identifier.

    Example Usage:
        local result = inv:getID()
]]
--[[
    eq(other)

    Description:
        Compares two inventories by ID for equality.

    Parameters:
        other (Inventory) – Other inventory to compare.

    Realm:
        Shared

    Returns:
        boolean – True if both inventories share the same ID.

    Example Usage:
        local result = inv:eq(other)
]]
--[[
        addItem(item, noReplicate)

        Description:
            Inserts an item instance into this inventory and persists it.

        Parameters:
            item (Item) – Item to add.
            noReplicate (boolean) – Skip network replication when true.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Insert a new item without sending it to clients
        local result = inv:addItem(item, noReplicate)
    ]]
--[[
        removeItem(itemID, preserveItem)

        Description:
            Removes an item by ID and optionally deletes it.

        Parameters:
            itemID (number) – Unique item identifier.
            preserveItem (boolean) – Keep item in database when true.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Remove an item and keep it saved if preserveItem is true
        local result = inv:removeItem(itemID, preserveItem)
    ]]
--[[
        syncData(key, recipients)

        Description:
            Sends a single data field to clients.

        Parameters:
            key (string) – Field to replicate.
            recipients (table|nil) – Player recipients.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Replicate a single field to the given players
        local result = inv:syncData(key, recipients)
    ]]
--[[
        sync(recipients)

        Description:
            Sends the entire inventory and its items to players.

        Parameters:
            recipients (table|nil) – Player recipients.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Send the entire inventory to specified players
        local result = inv:sync(recipients)
    ]]
--[[
        delete()

        Description:
            Removes this inventory record from the database.

    Parameters:
        None

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Remove the inventory permanently from the database
        local result = inv:delete()
    ]]
--[[
        destroy()

        Description:
            Destroys all items and removes network references.

    Parameters:
        None

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Completely clear the inventory and its items
        local result = inv:destroy()
    ]]
