--[[
    Hooks:
        AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)

    Purpose:
        Stores a new warning entry for a character and returns the resolved severity level.

    Category:
        Administration - Warnings

    Parameters:
        charID (number|string)
            The character ID receiving the warning.

        warned (string)
            The warned player's display name at the time of issue.

        warnedSteamID (string)
            The warned player's SteamID.

        timestamp (string)
            The timestamp recorded for the warning.

        message (string)
            The warning reason text.

        warner (string)
            The display name of the admin or system issuing the warning.

        warnerSteamID (string)
            The SteamID of the warning issuer.

        severity (string)
            The requested severity level, or `nil` to default to Medium.

    Example Usage:
        ```lua
        hook.Add("AddWarning", "liaExampleAddWarning", function(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
            return "[Reviewed] " .. message
        end)
        ```

    Returns:
        string
            The severity value stored for the warning.

    Realm:
        Server
]]
--[[
    Hooks:
        GetWarnings(charID)

    Purpose:
        Retrieves the stored warnings for a character.

    Category:
        Administration - Warnings

    Parameters:
        charID (number|string)
            The character ID whose warning history should be fetched.

    Example Usage:
        ```lua
        hook.Add("GetWarnings", "liaExampleGetWarnings", function(charID)
            print("[MyModule] handled GetWarnings")
        end)
        ```

    Returns:
        Deferred
            Resolves with a sequential table of warning rows for the character.

    Realm:
        Server
]]
--[[
    Hooks:
        RemoveWarning(charID, index)

    Purpose:
        Removes a stored warning from a character by its list index.

    Category:
        Administration - Warnings

    Parameters:
        charID (number|string)
            The character ID whose warning should be removed.

        index (number)
            The one-based warning index to remove from the fetched warning list.

    Example Usage:
        ```lua
        hook.Add("RemoveWarning", "liaExampleRemoveWarning", function(charID, index)
            print("[MyModule] handled RemoveWarning")
        end)
        ```

    Returns:
        Deferred
            Resolves with the removed warning row, or `nil` when the index is invalid.

    Realm:
        Server
]]
--[[
    Hooks:
        WarningIssued(client, target, reason, severity, count, warnerSteamID, warnedSteamID)

    Purpose:
        Called after a warning is issued so other systems can react or log the event.

    Category:
        Administration - Warnings

    Parameters:
        client (Player)
            The admin or staff member who issued the warning.

        target (Player)
            The player who received the warning.

        reason (string)
            The warning reason text.

        severity (string)
            The stored warning severity.

        count (number)
            The warned player's total warning count after the new warning is added.

        warnerSteamID (string)
            The SteamID of the warning issuer.

        warnedSteamID (string)
            The SteamID of the warned player.

    Example Usage:
        ```lua
        hook.Add("WarningIssued", "liaExampleWarningIssued", function(client, target, reason, severity, count, warnerSteamID, warnedSteamID)
            if not IsValid(client) or reason == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), reason))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        WarningRemoved(client, targetClient, warning, index)

    Purpose:
        Called after a warning is removed so other systems can react or log the event.

    Category:
        Administration - Warnings

    Parameters:
        client (Player)
            The admin or staff member who removed the warning.

        targetClient (Player)
            The player whose warning was removed.

        warning (table)
            The removed warning data passed to listeners.

        index (number)
            The one-based warning index that was removed.

    Example Usage:
        ```lua
        hook.Add("WarningRemoved", "liaExampleWarningRemoved", function(client, targetClient, warning, index)
            if not istable(warning) then return end
            warning.exampleHandled = true
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
MODULE.Name = "@warnsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@warnsModuleName"
MODULE.NetworkStrings = {"liaAllWarnings", "liaPlayerWarnings", "liaRequestAllWarnings", "liaRequestRemoveWarning", "liaRequestWarningsCount", "liaWarningsCount",}
MODULE.Privileges = {
    ["viewPlayerWarnings"] = {
        Name = "@viewPlayerWarnings",
        MinAccess = "admin",
        Category = "@warning",
    },
    ["canRemoveWarns"] = {
        Name = "@canRemoveWarns",
        MinAccess = "superadmin",
        Category = "@warning",
    },
}
