--[[
    Hooks:
        AdminStickAddModels(modList)

    Purpose:
        Allows clientside code to add extra model entries to the admin stick model picker.

    Parameters:
        modList (table)
            The mutable list of model definitions shown by the admin stick UI.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OnAdminStickMenuClosed()

    Purpose:
        Called after the admin stick menu closes.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OpenAdminStickUI(target)

    Purpose:
        Called when the admin stick requests its management UI for a target entity.

    Parameters:
        target (Entity)
            The entity targeted by the admin stick.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        PopulateAdminStick(currentMenu, currentTarget, currentStores)

    Purpose:
        Allows clientside code to add option groups to the admin stick menu for the current target.

    Parameters:
        currentMenu (Panel)
            The admin stick menu panel being populated.

        currentTarget (Entity)
            The entity currently targeted by the admin stick.

        currentStores (table)
            The mutable list of grouped admin stick menu entries.

    Returns:
        nil

    Realm:
        Client
]]
MODULE.Name = "@adminStick"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@adminStickPurpose"
MODULE.Privileges = {
    ["alwaysSpawnAdminStick"] = {
        Name = "@alwaysSpawnAdminStick",
        MinAccess = "superadmin",
        Category = "@adminStick",
    },
}
