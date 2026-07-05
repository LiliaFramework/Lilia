--[[
    Hooks:
        CreateLogsUI(panel, categories)

    Purpose:
        Builds or refreshes the clientside log viewer interface for the admin panel.

    Category:
        Administration - Logs

    Parameters:
        panel (Panel)
            The parent panel that should contain the logs UI.

        categories (table)
            The ordered list of translated log categories to show as tabs.

    Example Usage:
        ```lua
        hook.Add("CreateLogsUI", "liaExampleCreateLogsUI", function(panel, categories)
            categories[#categories + 1] = {
                category = "custom",
                name = "Custom Logs"
            }
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OnServerLog(Player client, string logType, string logString, string category)

    Purpose:
        Called whenever a server log entry is created through lia.log.add.

    Category:
        Administration - Logs

    Parameters:
        client (Player)
            The player associated with the log entry. May be invalid or nil for console/system logs.

        logType (string)
            The internal log type identifier used to generate the log message.

        logString (string)
            The final formatted log message.

        category (string)
            The translated category name assigned to the log entry.

    Example Usage:
        ```lua
        hook.Add("OnServerLog", "liaExampleOnServerLog", function(client, logType, logString, category)
            if not IsValid(client) or logString == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), logString))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerSeeLogs(Player client)

    Purpose:
        Determines whether a player is allowed to receive and view server log entries.

    Category:
        Administration - Logs

    Parameters:
        client (Player)
            The player whose log-viewing permission should be checked.

    Example Usage:
        ```lua
        hook.Add("CanPlayerSeeLogs", "liaExampleCanPlayerSeeLogs", function(client)
            return true
        end)
        ```

    Returns:
        boolean
            True if admin console log networking is enabled and the player has the canSeeLogs privilege.

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerSeeLogCategory(client, category)

    Purpose:
        Determines whether a player is allowed to see a specific translated log category.

    Category:
        Administration - Logs

    Parameters:
        client (Player)
            The player whose category visibility should be checked.

        category (string)
            The translated log category name being evaluated.

    Example Usage:
        ```lua
        hook.Add("CanPlayerSeeLogCategory", "liaExampleCanPlayerSeeLogCategory", function(client, category)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to hide the category from the player.

    Realm:
        Shared
]]
--[[
    Hooks:
        ReadLogEntries(category, page)

    Purpose:
        Loads a page of stored log rows for a translated log category.

    Category:
        Administration - Logs

    Parameters:
        category (string)
            The translated log category to read from storage.

        page (number)
            The one-based page number to fetch.

    Example Usage:
        ```lua
        hook.Add("ReadLogEntries", "liaExampleReadLogEntries", function(category, page)
            print("[MyModule] handled ReadLogEntries")
        end)
        ```

    Returns:
        Deferred
            Resolves with a table containing the page of log rows and pagination metadata.

    Realm:
        Server
]]
MODULE.Name = "@logs"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@categoryLogging"
MODULE.NetworkStrings = {"liaSendLogs", "liaSendLogsCategories", "liaSendLogsCategoriesRequest", "liaSendLogsRequest",}
MODULE.Privileges = {
    ["canSeeLogs"] = {
        Name = "@canSeeLogs",
        MinAccess = "superadmin",
        Category = "@categoryLogging",
    },
}
