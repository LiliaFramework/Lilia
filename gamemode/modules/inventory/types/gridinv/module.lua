--[[
    Hooks:
        BagInventoryReady(item, inventory)

    Purpose:
        Called after a bag item finishes creating or restoring its nested inventory.

    Parameters:
        item (table)
            The bag item that owns the nested inventory.

        inventory (table)
            The nested bag inventory that is now ready.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        BagInventoryRemoved(item, inventory)

    Purpose:
        Called when a bag item's nested inventory is removed.

    Parameters:
        item (table)
            The bag item losing its nested inventory.

        inventory (table)
            The nested inventory being removed.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        InterceptClickItemIcon(panel, itemIcon, keyCode)

    Purpose:
        Allows clientside code to intercept clicks on a grid inventory item icon before default handling runs.

    Parameters:
        panel (Panel)
            The grid inventory panel receiving the click.

        itemIcon (Panel)
            The clicked item icon panel.

        keyCode (number)
            The mouse key or button code that was pressed.

    Returns:
        boolean|nil
            Return true to indicate the click was fully handled and skip default processing.

    Realm:
        Client
]]
--[[
    Hooks:
        InventoryItemIconCreated(icon, item, panel)

    Purpose:
        Called after a grid inventory item icon panel is created.

    Parameters:
        icon (Panel)
            The newly created item icon panel.

        item (table)
            The inventory item represented by the icon.

        panel (Panel)
            The parent grid inventory panel.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        InventoryPanelCreated(panel, inventory, parent)

    Purpose:
        Called after a grid inventory panel is created.

    Parameters:
        panel (Panel)
            The created inventory panel.

        inventory (table)
            The inventory assigned to the panel.

        parent (Panel|nil)
            The parent panel, if one was provided.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        ItemCombine(client, item, target)

    Purpose:
        Allows code to handle combining one item with another before default transfer behavior continues.

    Parameters:
        client (Player)
            The player attempting the combine action.

        item (table)
            The item being moved or used.

        target (table)
            The item being combined with.

    Returns:
        boolean|nil
            Return true when the combine action was handled successfully.

    Realm:
        Server
]]
--[[
    Hooks:
        OnPlayerLostStackItem(itemTypeOrItem)

    Purpose:
        Called when the grid inventory stack restore flow fails to recover an item.

    Parameters:
        itemTypeOrItem (string|table)
            The item type or item reference that could not be restored.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnRequestItemTransfer(panel, itemID, inventoryID, x, y)

    Purpose:
        Called on the client when a grid inventory panel requests an item transfer.

    Parameters:
        panel (Panel)
            The panel that initiated the transfer request.

        itemID (number)
            The item ID being transferred.

        inventoryID (number|nil)
            The target inventory ID, if applicable.

        x (number)
            The requested destination X slot.

        y (number)
            The requested destination Y slot.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        SetupBagInventoryAccessRules(inventory)

    Purpose:
        Allows code to configure access rules on a newly created bag inventory.

    Parameters:
        inventory (table)
            The bag inventory being initialized.

    Returns:
        nil

    Realm:
        Server
]]
MODULE.name = "@inv"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@inventorySystemDescription"
MODULE.NetworkStrings = {"liaRestoreOverflowItems",}
MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}
