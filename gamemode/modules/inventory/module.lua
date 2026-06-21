--[[
    Hooks:
        InventoryClosed(panel, inventory)

    Purpose:
        Called after an inventory panel is closed.

    Parameters:
        panel (Panel)
            The panel instance that was closed.

        inventory (table)
            The inventory represented by the panel.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        InventoryOpened(panel, inventory)

    Purpose:
        Called after an inventory panel is created and shown.

    Parameters:
        panel (Panel)
            The panel instance that was opened.

        inventory (table)
            The inventory represented by the panel.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)

    Purpose:
        Called after the framework creates a paired inventory view for two inventories.

    Parameters:
        panel1 (Panel)
            The panel for the first inventory.

        panel2 (Panel)
            The panel for the second inventory.

        inventory1 (table)
            The first inventory object.

        inventory2 (table)
            The second inventory object.

    Returns:
        nil

    Realm:
        Client
]]
MODULE.name = "@inv"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@inventorySystemDescription"
MODULE.Privileges = {
    ["noItemCooldown"] = {
        Name = "@noItemCooldown",
        MinAccess = "admin",
        Category = "@categoryStaffManagement"
    }
}

local invType = string.lower(hook.Run("GetDefaultInventoryType") or "gridinv")
lia.module.load(invType, MODULE.folder .. "/types/" .. invType)
