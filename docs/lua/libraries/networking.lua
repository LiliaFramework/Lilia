--[[
    setNetVar(key, value, receiver)

    Description:
        Stores a global networked variable and broadcasts it to clients. When a
        receiver is specified the update is only sent to those players.

    Parameters:
        key (string) – Name of the variable.
        value (any) – Value to store.
        receiver (Player|table|nil) – Optional receiver(s) for the update.

    Realm:
        Server

    Returns:
        nil
]]

--[[
    getNetVar(key, default)

    Description:
        Retrieves a global networked variable previously set by setNetVar.

    Parameters:
        key (string) – Variable name.
        default (any) – Fallback value if the variable is not set.

    Realm:
        Shared

    Returns:
        any – Stored value or default.
]]

