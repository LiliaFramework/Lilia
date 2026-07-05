--[[
    Hooks:
        CharForceRecognized(ply, range)

    Purpose:
        Called after the recognition system force-recognizes nearby players for a speaker.

    Category:
        Recognition

    Parameters:
        ply (Player)
            The player who triggered forced recognition.

        range (string)
            The recognition range key that was used, such as `whisper`, `normal`, `talk`, or `yell`.

    Example Usage:
        ```lua
        hook.Add("CharForceRecognized", "liaExampleCharForceRecognized", function(ply, range)
            if not IsValid(ply) then return end
            print(string.format("[MyModule] handled CharForceRecognized for %s", ply:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        IsRecognizedChatType(chatType)

    Purpose:
        Lets code mark additional chat types as recognized chat for unknown-name masking.

    Category:
        Recognition

    Parameters:
        chatType (string)
            The chat class unique ID being checked.

    Example Usage:
        ```lua
        hook.Add("IsRecognizedChatType", "liaExampleIsRecognizedChatType", function(chatType)
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return true to treat the chat type as recognition-sensitive.

    Realm:
        Client
]]
--[[
    Hooks:
        OnCharRecognized(ply)

    Purpose:
        Called after a player recognizes another character through the recognition system.

    Category:
        Recognition

    Parameters:
        ply (Player)
            The player whose recognition data was updated.

    Example Usage:
        ```lua
        hook.Add("OnCharRecognized", "liaExampleOnCharRecognized", function(ply)
            if not IsValid(ply) then return end
            print(string.format("[MyModule] handled OnCharRecognized for %s", ply:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Shared
]]
MODULE.name = "@recognition"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@recognitionSystemDescription"
MODULE.NetworkStrings = {"liaRgnDone",}
