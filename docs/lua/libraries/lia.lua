--[[
    This file documents lia functions defined within the codebase.

    Generated automatically.
]]
--[[
    lia.include

    Description:
        Includes a Lua file based on its realm. It determines the realm from the file name or provided state,
        and handles server/client inclusion logic.

    Parameters:
        fileName (string) – The path to the Lua file.
        state    (string) – The realm state ("server", "client", "shared", etc.).

    Returns:
        The result of the include, if applicable.

    Realm:
        Depends on the file realm.

    Example Usage:
        lia.include("lilia/gamemode/core/libraries/util.lua", "shared")
]]
--[[
    lia.includeDir

    Description:
        Includes all Lua files in a specified directory.
        If recursive is true, it recursively includes files from subdirectories.
        It determines the base directory based on the active schema or gamemode.

    Parameters:
        directory (string) – The directory path to include.
        fromLua   (boolean) – Whether to use the raw Lua directory path.
        recursive (boolean) – Whether to include files recursively.
        realm     (string) – The realm state to use ("client", "server", "shared").

    Returns:
        nil

    Realm:
        Depends on file inclusion.

    Example Usage:
        lia.includeDir("lilia/gamemode/core/libraries/shared/thirdparty", true, true)
]]
--[[
    lia.includeGroupedDir

    Description:
        Recursively includes all Lua files in a specified directory, preserving alphabetical order within each folder.
        Determines each file’s realm (client, server, or shared) either by forced override or by filename prefix,
        then calls lia.include on each file.

    Parameters:
        dir         (string) – Directory path to load files from (relative to gamemode or schema folder if raw is false).
        raw         (boolean) – If true, uses dir as the literal filesystem path; otherwise prepends the gamemode/schema root.
        recursive   (boolean) – Whether to traverse subdirectories recursively.
        forceRealm  (string) – Optional override for the realm of all included files ("client", "server", or "shared").

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    lia.error(msg)

    Description:
        Prints a colored error message prefixed with "[Lilia]" to the console.

    Parameters:
        msg (string) – Error text to display.

    Returns:
        None

    Realm:
        Shared

    Example Usage:
        lia.error("Invalid configuration detected")
]]
--[[
    lia.deprecated(methodName, callback)

    Description:
        Notifies that a method is deprecated and optionally runs a callback.

    Parameters:
        methodName (string) – Name of the deprecated method.
        callback   (function) – Optional function executed after warning.

    Returns:
        None

    Realm:
        Shared

    Example Usage:
        lia.deprecated("OldFunction")
]]
--[[
    lia.updater(msg)

    Description:
        Prints an updater message in cyan to the console with the Lilia prefix.

    Parameters:
        msg (string) – Update text to display.

    Returns:
        None

    Realm:
        Shared

    Example Usage:
        lia.updater("Loading additional content...")
]]
--[[
    lia.information(msg)

    Description:
        Prints an informational message with the Lilia prefix.

    Parameters:
        msg (string) – Text to print to the console.

    Returns:
        None

    Realm:
        Shared

    Example Usage:
        lia.information("Server started successfully")
]]
--[[
    lia.bootstrap(section, msg)

    Description:
        Logs a bootstrap message with a colored section tag for clarity.

    Parameters:
        section (string) – Category or stage of bootstrap.
        msg     (string) – Message describing the bootstrap step.

    Returns:
        None

    Realm:
        Shared

    Example Usage:
        lia.bootstrap("Database", "Connection established")
]]
--[[
    lia.includeEntities(path)

    Description:
        Includes entity files from the specified directory.
        It checks for standard entity files ("init.lua", "shared.lua", "cl_init.lua"),
        handles the inclusion and registration of entities, weapons, tools, and effects,
        and supports recursive inclusion within entity folders.

    Parameters:
        path (string) – The directory path containing entity files.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.includeEntities("lilia/entities")
]]