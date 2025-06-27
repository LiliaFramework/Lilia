--[[
    lia.option.add(key, name, desc, default, callback, data)

       Description:
          Adds a configuration option to the lia.option system.

       Parameters:
          key (string) — The unique key for the option.
          name (string) — The display name of the option.
          desc (string) — A brief description of the option's purpose.
          default (any) — The default value for this option.
          callback (function) — A function to call when the option’s value changes (optional).
          data (table) — Additional data describing the option (e.g., min, max, type, category, visible, shouldNetwork).

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        -- This snippet demonstrates a common usage of lia.option.add
        lia.option.add("showHints", "Show Hints", "Display hints", true)
]]

--[[
    lia.option.set(key, value)

       Description:
          Sets the value of a specified option, saves locally, and optionally networks to the server.

       Parameters:
          key (string) — The unique key identifying the option.
          value (any) — The new value to assign to this option.

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        -- This snippet demonstrates a common usage of lia.option.set
        lia.option.set("showHints", false)
]]

--[[
    lia.option.get(key, default)

       Description:
          Retrieves the value of a specified option, or returns a default if it doesn't exist.

       Parameters:
          key (string) — The unique key identifying the option.
          default (any) — The value to return if the option is not found.

    Returns:
        (any) The current value of the option or the provided default.

    Realm:
        Client

    Example Usage:
        -- This snippet demonstrates a common usage of lia.option.get
        local show = lia.option.get("showHints", true)
]]

--[[
    lia.option.save()

       Description:
          Saves all current option values to a file, named based on the server IP, within the active gamemode folder.

       Parameters:
          None

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        -- This snippet demonstrates a common usage of lia.option.save
        lia.option.save()
]]

--[[
    lia.option.load()

       Description:
          Loads saved option values from disk based on server IP and applies them to lia.option.stored.

       Parameters:
          None

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        -- This snippet demonstrates a common usage of lia.option.load
        lia.option.load()
]]
