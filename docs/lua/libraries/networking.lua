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

    Example Usage:
        -- Start a new round and notify clients of the round number
        local round = getNetVar("round", 0) + 1
        setNetVar("round", round)
        hook.Run("RoundStarted", round)
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

    Example Usage:
        -- Inform a joining player of the current round
        hook.Add("PlayerInitialSpawn", "ShowRound", function(ply)
            local round = getNetVar("round", 0)
            ply:ChatPrint("Current round: " .. round)
        end)
]]