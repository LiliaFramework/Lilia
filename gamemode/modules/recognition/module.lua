--[[
    Hooks:
        CharForceRecognized(ply, range)

    Purpose:
        Called after the recognition system force-recognizes nearby players for a speaker.

    Parameters:
        ply (Player)
            The player who triggered forced recognition.

        range (string)
            The recognition range key that was used, such as `whisper`, `normal`, `talk`, or `yell`.

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

    Parameters:
        chatType (string)
            The chat class unique ID being checked.

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

    Parameters:
        ply (Player)
            The player whose recognition data was updated.

    Returns:
        nil

    Realm:
        Client / Server
]]
MODULE.name = "@recognition"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@recognitionSystemDescription"
MODULE.NetworkStrings = {"liaRgnDone",}
