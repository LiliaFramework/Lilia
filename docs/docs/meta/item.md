# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `getQuantity()`

    Description:
        Retrieves how many of this item the stack represents.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Quantity contained in this item instance.

    Example Usage:
        -- Give the player ammo equal to the stack quantity
        player:GiveAmmo(item:getQuantity(), "pistol")

### `eq(other)`

    Description:
        Compares this item instance to another by ID.

    Parameters:
        other (Item) – The other item to compare with.

    Realm:
        Shared

    Returns:
        boolean – True if both items share the same ID.

    Example Usage:
        -- Check if the held item matches the inventory slot
        if item:eq(slotItem) then
            print("Same item instance")
        end

### `tostring()`

    Description:
        Returns a printable representation of this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Identifier in the form "item[uniqueID][id]".

    Example Usage:
        -- Log the item identifier during saving
        print("Saving " .. item:tostring())

### `getID()`

    Description:
        Retrieves the unique identifier of this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Item database ID.

    Example Usage:
        -- Use the ID when updating the database
        lia.db.updateItem(item:getID(), {price = 50})

### `getModel()`

    Description:
        Returns the model path associated with this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Model path.

    Example Usage:
        -- Spawn the item's model as a world prop
        local prop = ents.Create("prop_physics")
        prop:SetModel(item:getModel())
        prop:Spawn()

### `getSkin()`

    Description:
        Retrieves the skin index this item uses.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Skin ID applied to the model.

    Example Usage:
        -- Apply the correct skin when displaying the item
        model:SetSkin(item:getSkin())

### `getPrice()`

    Description:
        Returns the calculated purchase price for the item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – The price value.

    Example Usage:
        -- Charge the player the item's price before giving it
        if char:hasMoney(item:getPrice()) then
            char:takeMoney(item:getPrice())
        end

### `call(method, client, entity, ...)`

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
        -- Trigger a custom "use" function when the player presses Use
        item:call("use", client, entity)

### `getOwner()`

    Description:
        Attempts to find the player currently owning this item.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|None – The owner if available.

    Example Usage:
        -- Notify whoever currently owns the item
        local owner = item:getOwner()
        if IsValid(owner) then
            owner:notify("Your item glows brightly.")
        end

### `getData(key, default)`

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
        -- Retrieve a custom paint color stored on the item
        local color = item:getData("paintColor", Color(255,255,255))

### `getAllData()`

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
        -- Print all stored data for debugging
        PrintTable(item:getAllData())

### `hook(name, func)`

    Description:
        Registers a hook callback for this item instance.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function to call.

    Realm:
        Shared
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Run code when the item is used
        item:hook("use", function(ply) ply:ChatPrint("Used!") end)

### `postHook(name, func)`

    Description:
        Registers a post-hook callback for this item.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function invoked after the main hook.

    Realm:
        Shared
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Give a pistol after the item is picked up
        item:postHook("pickup", function(ply) ply:Give("weapon_pistol") end)

### `onRegistered()`

    Description:
        Called when the item table is first registered.

    Parameters:
        None

    Realm:
        Shared
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Initialize data when the item type loads
        item:onRegistered()

### `print(detail)`

    Description:
        Prints a simple representation of the item to the console.

    Parameters:
        detail (boolean) – Include position details when true.

    Realm:
        Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Output item info while debugging spawn issues
        item:print(true)

### `printData()`

    Description:
        Debug helper that prints all stored item data.

    Parameters:
        None

    Realm:
        Server
    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Dump all stored data to the console
        item:printData()

### `addQuantity(quantity, receivers, noCheckEntity)`

        Description:
            Increases the stored quantity for this item instance.

        Parameters:
            quantity (number) – Amount to add.
            receivers (Player|None) – Who to network the change to.
            noCheckEntity (boolean) – Skip entity network update.

        Realm:
            Server
        Returns:
            None – This function does not return a value.

    Example Usage:
        -- Combine stacks from a loot drop and notify the owner
        item:addQuantity(5, {player})
        player:notifyLocalized("item_added", item.name, 5)

### `setQuantity(quantity, receivers, noCheckEntity)`

        Description:
            Sets the current stack quantity and replicates the change.

        Parameters:
            quantity (number) – New amount to store.
            receivers (Player|None) – Recipients to send updates to.
            noCheckEntity (boolean) – Skip entity updates when true.

        Realm:
            Server
        Returns:
            None – This function does not return a value.

    Example Usage:
        -- Set quantity to 1 after splitting the stack
        item:setQuantity(1, nil, true)

