--[[
    Folder: Developer - Libraries
    File: lia.chat.md
]]
--[[
    Chat

    Chat helpers for registering chat classes, parsing player messages, formatting timestamps, and sending chat messages to eligible recipients.
]]
--[[
    Overview:
        The chat library centralizes shared chat class registration, message prefix parsing, timestamp formatting, per-class permission and hearing checks, and server-to-client chat dispatch under `lia.chat`.
]]
--[[
    Hooks:
        GetDisplayedName(Player speaker, string chatType)

    Purpose:
        Allows plugins or modules to override the display name used by the default chat output handler.

    Parameters:
        speaker (Player)
            The player whose display name is being requested.

        chatType (string)
            The chat class currently being displayed.

    Returns:
        string|nil
            Return a string to use it as the displayed speaker name. Return nil to use the normal player name or console fallback.

    Realm:
        Client
]]
--[[
    Hooks:
        ChatParsed(Player client, string chatType, string message, boolean anonymous)

    Purpose:
        Allows plugins or modules to adjust a parsed chat message before server dispatch occurs.

    Parameters:
        client (Player)
            The player whose message was parsed.

        chatType (string)
            The detected chat class.

        message (string)
            The parsed message text after prefix handling.

        anonymous (boolean)
            Whether the message is currently marked as anonymous.

    Returns:
        string|nil, string|nil, boolean|nil
            Return a new chat type, message, or anonymous state to override the parsed values. Return nil for any value that should remain unchanged.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnOOCMessageSent(Player client, string message)

    Purpose:
        Called when a player sends an out-of-character chat message.

    Parameters:
        client (Player)
            The player who sent the OOC message.

        message (string)
            The OOC message text.

    Returns:
        None

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerMessageSend(Player speaker, string chatType, string message, boolean anonymous, table|nil receivers)

    Purpose:
        Allows plugins or modules to modify chat message text before it is sent.

    Parameters:
        speaker (Player)
            The player sending the message.

        chatType (string)
            The chat class being sent.

        message (string)
            The message text being processed.

        anonymous (boolean)
            Whether the message is being sent anonymously.

        receivers (table|nil)
            The resolved recipient list when available.

    Returns:
        string|nil
            Return a string to replace the outgoing message text. Return nil to keep the existing text.

    Realm:
        Server
]]
lia.chat = lia.chat or {}
lia.chat.classes = lia.chat.classes or {}
--[[
    Purpose:
        Builds the optional timestamp prefix used in chat output.

    Parameters:
        ooc (boolean|nil)
            Whether the timestamp is being formatted for out-of-character chat spacing.

    Returns:
        string
            The formatted timestamp when chat timestamps are enabled, otherwise an empty string.

    Example Usage:
        ```lua
        chat.AddText(lia.chat.timestamp(false), Color(255, 255, 255), "Message")
        ```

    Realm:
        Shared
]]
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.getHour() .. ")" .. (ooc and "" or " ") or ""
end

--[[
    Purpose:
        Registers a chat class and prepares its defaults, prefixes, callbacks, command aliases, and metadata.

    Parameters:
        chatType (string)
            Unique identifier for the chat class.

        data (table)
            Chat class data, including optional arguments, prefix, desc, radius, onCanHear, onCanSay, color, format, onChatAdd, filter, noSpaceAfter, and deadCanChat fields.

    Returns:
        None

    Example Usage:
        ```lua
        lia.chat.register("radio", {
            prefix = "/r",
            radius = 1000,
            format = "chatRadio"
        })
        ```

    Realm:
        Shared
]]
function lia.chat.register(chatType, data)
    data.arguments = data.arguments or {}
    data.syntax = lia.lang.resolveToken(lia.command.buildSyntaxFromArguments(data.arguments))
    data.desc = isstring(data.desc) and lia.lang.resolveToken(data.desc) or data.desc or ""
    if data.prefix then
        local prefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local processed, lookup = {}, {}
        for _, prefix in ipairs(prefixes) do
            if prefix ~= "" and not lookup[prefix] then
                processed[#processed + 1] = prefix
                lookup[prefix] = true
            end

            local noSlash = prefix:gsub("^/", "")
            if noSlash ~= "" and not lookup[noSlash] and noSlash:sub(1, 1) ~= "/" then
                processed[#processed + 1] = noSlash
                lookup[noSlash] = true
            end
        end

        data.prefix = processed
    end

    if not data.onCanHear then
        if isfunction(data.radius) then
            data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= data.radius() ^ 2 end
        elseif isnumber(data.radius) then
            local range = data.radius ^ 2
            data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range end
        else
            data.onCanHear = function() return true end
        end
    elseif isnumber(data.onCanHear) then
        local range = data.onCanHear ^ 2
        data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range end
    end

    data.onCanSay = data.onCanSay or function(speaker)
        if not data.deadCanChat and not speaker:Alive() then
            speaker:notifyErrorLocalized("noPerm")
            return false
        end
        return true
    end

    data.color = data.color or (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    data.format = data.format or "chatFormat"
    data.onChatAdd = data.onChatAdd or function(speaker, text, anonymous) chat.AddText(lia.chat.timestamp(false), (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), L(data.format, anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or L("console"), text)) end
    if data.prefix then
        local rawPrefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local aliases, lookup = {}, {}
        for _, prefix in ipairs(rawPrefixes) do
            if prefix:sub(1, 1) == "/" then
                local cmd = prefix:gsub("^/", ""):lower()
                local isCommonWord = cmd == "it" or cmd == "me" or cmd == "w" or cmd == "y" or cmd == "a"
                if cmd ~= "" and not lookup[cmd] and not isCommonWord then
                    table.insert(aliases, cmd)
                    lookup[cmd] = true
                end
            end
        end

        if #aliases > 0 then
            lia.command.add(chatType, {
                arguments = data.arguments,
                desc = data.desc,
                alias = aliases,
                onRun = function(client, args)
                    local text = table.concat(args, " ")
                    if SERVER then
                        lia.chat.send(client, chatType, text)
                    else
                        lia.chat.parse(LocalPlayer(), table.concat(args, " "))
                    end
                end
            })
        end
    end

    data.filter = data.filter or "ic"
    lia.chat.classes[chatType] = data
end

--[[
    Purpose:
        Parses raw chat text, detects a matching chat class prefix, runs chat parsing hooks, and optionally sends the message on the server.

    Parameters:
        client (Player)
            The player whose message is being parsed.

        message (string)
            Raw message text entered by the player.

        noSend (boolean|nil)
            If true, parsing returns the resolved values without sending the message.

    Returns:
        string|nil, string|nil, boolean|nil
            The resolved chat type, message text, and anonymous state. Returns nil when the message is empty or whitespace-only.

    Example Usage:
        ```lua
        local chatType, text, anonymous = lia.chat.parse(client, "/ooc Hello", true)
        ```

    Realm:
        Shared
]]
function lia.chat.parse(client, message, noSend)
    local anonymous = false
    local chatType = "ic"
    for k, v in pairs(lia.chat.classes) do
        local isChosen = false
        local chosenPrefix = ""
        local noSpaceAfter = v.noSpaceAfter
        if istable(v.prefix) then
            for _, prefix in ipairs(v.prefix) do
                if message:sub(1, #prefix + (noSpaceAfter and 0 or 1)):lower() == (prefix .. (noSpaceAfter and "" or " ")):lower() then
                    isChosen = true
                    chosenPrefix = prefix .. (v.noSpaceAfter and "" or " ")
                    break
                end
            end
        elseif isstring(v.prefix) then
            isChosen = message:sub(1, #v.prefix + (noSpaceAfter and 0 or 1)):lower() == (v.prefix .. (v.noSpaceAfter and "" or " ")):lower()
            chosenPrefix = v.prefix .. (v.noSpaceAfter and "" or " ")
        end

        if isChosen then
            chatType = k
            message = message:sub(#chosenPrefix + 1)
            if lia.chat.classes[k].noSpaceAfter and message:sub(1, 1):match("%s") then message = message:sub(2) end
            break
        end
    end

    if not message:find("%S") then return end
    local newType, newMsg, newAnon = hook.Run("ChatParsed", client, chatType, message, anonymous)
    chatType = newType or chatType
    message = newMsg or message
    anonymous = newAnon ~= nil and newAnon or anonymous
    if SERVER and not noSend then
        if chatType == "ooc" then hook.Run("OnOOCMessageSent", client, message) end
        lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous)
    end
    return chatType, message, anonymous
end

if SERVER then
    --[[
    Purpose:
        Sends a chat message from a speaker to valid recipients for the chosen chat class.

    Parameters:
        speaker (Player)
            The player sending the message.

        chatType (string)
            The registered chat class identifier to send through.

        text (string)
            The message text to send.

        anonymous (boolean|nil)
            Whether the message should be treated as anonymous.

        receivers (table|Player|nil)
            Optional recipient or recipient list. When omitted, recipients are resolved from the chat class hearing rules.

    Returns:
        None

    Example Usage:
        ```lua
        lia.chat.send(client, "ic", "Hello there.")
        ```

    Realm:
        Server
]]
    function lia.chat.send(speaker, chatType, text, anonymous, receivers)
        local class = lia.chat.classes[chatType]
        if class and class.onCanSay(speaker, text) ~= false then
            if class.onCanHear and not receivers then
                receivers = {}
                for _, v in player.Iterator() do
                    if v:getChar() and class.onCanHear(speaker, v) ~= false then receivers[#receivers + 1] = v end
                end

                if #receivers == 0 then return end
            end

            net.Start("liaChatMsg")
            net.WriteEntity(speaker)
            net.WriteString(chatType)
            net.WriteString(hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text)
            net.WriteBool(anonymous)
            if istable(receivers) then
                net.Send(receivers)
            else
                net.Broadcast()
            end
        end
    end
end