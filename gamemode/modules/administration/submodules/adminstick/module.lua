--[[
    Hooks:
        AdminStickAddModels(modList)

    Purpose:
        Allows clientside code to add extra model entries to the admin stick model picker.

    Category:
        Staffing

    Parameters:
        modList (table)
            The mutable list of model definitions shown by the admin stick UI.

    Example Usage:
        ```lua
        hook.Add("AdminStickAddModels", "liaExampleAdminStickAddModels", function(modList)
            print("[MyModule] handled AdminStickAddModels")
        end)
        ```

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

    Category:
        Staffing

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("OnAdminStickMenuClosed", "liaExampleOnAdminStickMenuClosed", function()
            print("[MyModule] handled OnAdminStickMenuClosed")
        end)
        ```

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

    Category:
        Staffing

    Parameters:
        target (Entity)
            The entity targeted by the admin stick.

    Example Usage:
        ```lua
        hook.Add("OpenAdminStickUI", "liaExampleOpenAdminStickUI", function(target)
            if not IsValid(target) then return end
            print(string.format("[MyModule] handled OpenAdminStickUI for %s", target:Name()))
        end)
        ```

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

    Category:
        Staffing

    Parameters:
        currentMenu (Panel)
            The admin stick menu panel being populated.

        currentTarget (Entity)
            The entity currently targeted by the admin stick.

        currentStores (table)
            The mutable list of grouped admin stick menu entries.

    Example Usage:
        ```lua
        hook.Add("PopulateAdminStick", "liaExamplePopulateAdminStick", function(currentMenu, currentTarget, currentStores)
            if not IsValid(currentMenu) then return end
            currentMenu:SetTooltip("PopulateAdminStick handled by MyModule")
        end)
        ```

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
