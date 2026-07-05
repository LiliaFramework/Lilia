--[[
    Hooks:
        BagInventoryReady(item, inventory)

    Purpose:
        Called after a bag item finishes creating or restoring its nested inventory.

    Category:
        Inventory

    Parameters:
        item (table)
            The bag item that owns the nested inventory.

        inventory (table)
            The nested bag inventory that is now ready.

    Example Usage:
        ```lua
        hook.Add("BagInventoryReady", "liaExampleBagInventoryReady", function(item, inventory)
            print("[MyModule] handled BagInventoryReady")
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        item (table)
            The bag item losing its nested inventory.

        inventory (table)
            The nested inventory being removed.

    Example Usage:
        ```lua
        hook.Add("BagInventoryRemoved", "liaExampleBagInventoryRemoved", function(item, inventory)
            print("[MyModule] handled BagInventoryRemoved")
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The grid inventory panel receiving the click.

        itemIcon (Panel)
            The clicked item icon panel.

        keyCode (number)
            The mouse key or button code that was pressed.

    Example Usage:
        ```lua
        hook.Add("InterceptClickItemIcon", "liaExampleInterceptClickItemIcon", function(panel, itemIcon, keyCode)
            return true
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        icon (Panel)
            The newly created item icon panel.

        item (table)
            The inventory item represented by the icon.

        panel (Panel)
            The parent grid inventory panel.

    Example Usage:
        ```lua
        hook.Add("InventoryItemIconCreated", "liaExampleInventoryItemIconCreated", function(icon, item, panel)
            if not IsValid(panel) then return end
            panel:SetTooltip("InventoryItemIconCreated handled by MyModule")
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The created inventory panel.

        inventory (table)
            The inventory assigned to the panel.

        parent (Panel|nil)
            The parent panel, if one was provided.

    Example Usage:
        ```lua
        hook.Add("InventoryPanelCreated", "liaExampleInventoryPanelCreated", function(panel, inventory, parent)
            if not IsValid(panel) then return end
            panel:SetTooltip("InventoryPanelCreated handled by MyModule")
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting the combine action.

        item (table)
            The item being moved or used.

        target (table)
            The item being combined with.

    Example Usage:
        ```lua
        hook.Add("ItemCombine", "liaExampleItemCombine", function(client, item, target)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        itemTypeOrItem (string|table)
            The item type or item reference that could not be restored.

    Example Usage:
        ```lua
        hook.Add("OnPlayerLostStackItem", "liaExampleOnPlayerLostStackItem", function(itemTypeOrItem)
            print("[MyModule] handled OnPlayerLostStackItem")
        end)
        ```

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

    Category:
        Inventory

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

    Example Usage:
        ```lua
        hook.Add("OnRequestItemTransfer", "liaExampleOnRequestItemTransfer", function(panel, itemID, inventoryID, x, y)
            if not IsValid(panel) then return end
            panel:SetTooltip("OnRequestItemTransfer handled by MyModule")
        end)
        ```

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

    Category:
        Inventory

    Parameters:
        inventory (table)
            The bag inventory being initialized.

    Example Usage:
        ```lua
        hook.Add("SetupBagInventoryAccessRules", "liaExampleSetupBagInventoryAccessRules", function(inventory)
            print("[MyModule] handled SetupBagInventoryAccessRules")
        end)
        ```

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
