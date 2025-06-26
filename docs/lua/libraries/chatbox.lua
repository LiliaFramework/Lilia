--[[
    lia.chat.timestamp(ooc)

    Description:
        Returns a formatted timestamp if chat timestamps are enabled.

    Parameters:
        ooc (boolean) – True for out-of-character messages.

    Returns:
        string – Formatted time string or an empty string.

    Realm:
        Shared
]]

--[[
    lia.chat.register(chatType, data)

    Description:
        Registers a new chat class and sets up command aliases.

    Parameters:
        chatType (string) – Identifier for the chat class.
        data (table) – Table of chat class properties.

    Returns:
        nil

    Realm:
        Shared
]]

--[[
    lia.chat.parse(client, message, noSend)

    Description:
        Parses chat text for the proper chat type and optionally sends it.

    Parameters:
        client (Player) – Player sending the message.
        message (string) – The chat text.
        noSend (boolean) – Suppress sending when true.

    Returns:
        chatType (string), text (string), anonymous (boolean)

    Realm:
        Shared
]]

--[[
    lia.chat.send(speaker, chatType, text, anonymous, receivers)

    Description:
        Broadcasts a chat message to all eligible receivers.

    Parameters:
        speaker (Player) – The message sender.
        chatType (string) – Chat class identifier.
        text (string) – Message text.
        anonymous (boolean) – Whether the sender is anonymous.
        receivers (table) – Optional list of target players.

    Returns:
        nil

    Realm:
        Server
]]
