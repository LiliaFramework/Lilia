--[[
    getQuantity()

    Description:
        Retrieves how many of this item the stack represents.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Quantity contained in this item instance.

    Example Usage:
        local result = item:getQuantity()
]]
--[[
    eq(other)

    Description:
        Compares this item instance to another by ID.

    Parameters:
        other (Item) – The other item to compare with.

    Realm:
        Shared

    Returns:
        boolean – True if both items share the same ID.

    Example Usage:
        local result = item:eq(other)
]]
--[[
    tostring()

    Description:
        Returns a printable representation of this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Identifier in the form "item[uniqueID][id]".

    Example Usage:
        local result = item:tostring()
]]
--[[
    getID()

    Description:
        Retrieves the unique identifier of this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Item database ID.

    Example Usage:
        local result = item:getID()
]]
--[[
    getModel()

    Description:
        Returns the model path associated with this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Model path.

    Example Usage:
        local result = item:getModel()
]]
--[[
    getSkin()

    Description:
        Retrieves the skin index this item uses.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Skin ID applied to the model.

    Example Usage:
        local result = item:getSkin()
]]
--[[
    getPrice()

    Description:
        Returns the calculated purchase price for the item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – The price value.

    Example Usage:
        local result = item:getPrice()
]]
--[[
    call(method, client, entity, ...)

    Description:
        Invokes an item method with the given player and entity context.

    Parameters:
        method (string) – Method name to run.
        client (Player) – The player performing the action.
        entity (Entity) – Entity representing this item.
        ... – Additional arguments passed to the method.

    Realm:
        Shared

    Returns:
        any – Results returned by the called function.

    Example Usage:
        local result = item:call(method, client, entity, ...)
]]
--[[
    getOwner()

    Description:
        Attempts to find the player currently owning this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|nil – The owner if available.

    Example Usage:
        local result = item:getOwner()
]]
--[[
    getData(key, default)

    Description:
        Retrieves a piece of persistent data stored on the item.

    Parameters:
        key (string) – Data key to read.
        default (any) – Value to return when the key is absent.

    Realm:
        Shared

    Returns:
        any – Stored value or default.

    Example Usage:
        local result = item:getData(key, default)
]]
--[[
    getAllData()

    Description:
        Returns a merged table of this item's stored data and any
        networked values on its entity.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Key/value table of all data fields.

    Example Usage:
        local result = item:getAllData()
]]
--[[
    hook(name, func)

    Description:
        Registers a hook callback for this item instance.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function to call.

    Realm:
        Shared

    Example Usage:
        local result = item:hook(name, func)
]]
--[[
    postHook(name, func)

    Description:
        Registers a post-hook callback for this item.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function invoked after the main hook.

    Realm:
        Shared

    Example Usage:
        local result = item:postHook(name, func)
]]
--[[
    onRegistered()

    Description:
        Called when the item table is first registered.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        local result = item:onRegistered()
]]
--[[
    print(detail)

    Description:
        Prints a simple representation of the item to the console.

    Parameters:
        detail (boolean) – Include position details when true.

    Realm:
        Server

    Example Usage:
        local result = item:print(detail)
]]
--[[
    printData()

    Description:
        Debug helper that prints all stored item data.

    Parameters:
        None

    Realm:
        Server

    Example Usage:
        local result = item:printData()
]]
--[[
        addQuantity(quantity, receivers, noCheckEntity)

        Description:
            Increases the stored quantity for this item instance.

        Parameters:
            quantity (number) – Amount to add.
            receivers (Player|nil) – Who to network the change to.
            noCheckEntity (boolean) – Skip entity network update.

        Realm:
            Server

    Example Usage:
        local result = item:addQuantity(quantity, receivers, noCheckEntity)
    ]]
--[[
        setQuantity(quantity, receivers, noCheckEntity)

        Description:
            Sets the current stack quantity and replicates the change.

        Parameters:
            quantity (number) – New amount to store.
            receivers (Player|nil) – Recipients to send updates to.
            noCheckEntity (boolean) – Skip entity updates when true.

        Realm:
            Server

    Example Usage:
        local result = item:setQuantity(quantity, receivers, noCheckEntity)
    ]]
