--[[
    Hooks:
        CanManageFilteredWords(client)

    Purpose:
        Determines whether a player is allowed to manage the chat filter word list.

    Parameters:
        client (Player)
            The player whose chat filter management permission should be checked.

    Returns:
        boolean
            True if the player has the manageChatFilter privilege.

    Realm:
        Server
]]
--[[
    Hooks:
        ChatboxTextAdded(...)

    Purpose:
        Called on the client after a new chat line is added to the chatbox.

    Parameters:
        ... (vararg)
            The formatted chatbox text arguments that were added.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        ChatParsed(client, chatType, message, anonymous)

    Purpose:
        Allows code to adjust a parsed chat message before it is dispatched.

    Parameters:
        client (Player)
            The player who sent the message.

        chatType (string)
            The parsed chat class unique ID.

        message (string)
            The parsed message text.

        anonymous (boolean)
            Whether the message is currently treated as anonymous.

    Returns:
        string|nil, string|nil, boolean|nil
            Return replacement values for the chat type, message, or anonymous state.

    Realm:
        Shared
]]
--[[
    Hooks:
        GetOOCDelay(speaker)

    Purpose:
        Allows code to override the out-of-character chat cooldown for a player.

    Parameters:
        speaker (Player)
            The player attempting to send an OOC message.

    Returns:
        number|nil
            Return a replacement OOC delay in seconds.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnOOCMessageSent(client, message)

    Purpose:
        Called after an out-of-character message is accepted for sending.

    Parameters:
        client (Player)
            The player who sent the OOC message.

        message (string)
            The message text that was sent.

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    Hooks:
        PlayerMessageSend(client, chatType, message, anonymous, receivers)

    Purpose:
        Allows code to adjust the final chat message text before recipients receive it.

    Parameters:
        client (Player)
            The player who sent the message.

        chatType (string)
            The chat class unique ID being used.

        message (string)
            The message text that is about to be sent.

        anonymous (boolean)
            Whether the message is anonymous.

        receivers (table|nil)
            The resolved recipient list when available.

    Returns:
        string|nil
            Return replacement message text to override the final output.

    Realm:
        Client / Server
]]
MODULE.name = "@chatboxModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@chatSystemDescription"
MODULE.NetworkStrings = {"liaChatboxAddFilteredWord", "liaChatboxRemoveFilteredWord", "liaChatboxRequestFilteredWords", "liaChatboxSyncFilteredWords"}
MODULE.Privileges = {
    ["noOOCCooldown"] = {
        Name = "@noOOCCooldown",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["adminChat"] = {
        Name = "@adminChat",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["localEventChat"] = {
        Name = "@localEventChat",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["eventChat"] = {
        Name = "@eventChat",
        MinAccess = "admin",
        Category = "@categoryChat",
    },
    ["accessHelpChat"] = {
        Name = "@accessHelpChat",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["bypassOOCBlock"] = {
        Name = "@bypassOOCBlockPrivilege",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
    ["manageChatFilter"] = {
        Name = "@manageChatFilter",
        MinAccess = "superadmin",
        Category = "@categoryChat",
    },
}
