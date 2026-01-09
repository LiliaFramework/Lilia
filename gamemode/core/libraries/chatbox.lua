--[[
    Folder: Libraries
    File: chat.md
]]
--[[
    Chatbox Library

    Comprehensive chat system management with message routing and formatting for the Lilia framework.
]]
--[[
    Overview:
        The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework. It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing, distance-based hearing mechanics, and chat formatting. The library operates on both server and client sides, with the server managing message distribution and validation, while the client handles parsing and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based communication, and integration with the command system for chat-based commands.
]]
lia.chat = lia.chat or {}
lia.chat.classes = lia.chat.classes or {}
--[[
    Purpose:
        Prepend a timestamp to chat messages based on option settings.

    When Called:
        During chat display formatting (client) to show the time.

    Parameters:
        ooc (boolean)
            Whether the chat is OOC (affects spacing).

    Returns:
        string
            Timestamp text or empty string.

    Realm:
        Shared (used clientside)

    Example Usage:
        ```lua
        chat.AddText(lia.chat.timestamp(false), Color(255,255,255), message)
        ```
]]
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.getHour() .. ")" .. (ooc and "" or " ") or ""
end

--[[
    Purpose:
        Register a chat class (IC/OOC/whisper/custom) with prefixes and rules.

    When Called:
        On initialization to add new chat types and bind aliases/commands.

    Parameters:
        chatType (string)
        data (table)
            Fields: prefix, radius/onCanHear, onCanSay, format, color, arguments, etc.

    Returns:
        nil

    Realm:
        Shared (prefix commands created clientside)

    Example Usage:
        ```lua
        lia.chat.register("yell", {
            prefix = {"/y", "/yell"},
            radius = 600,
            format = "chatYellFormat",
            arguments = {{name = "message", type = "string"}},
            onChatAdd = function(speaker, text) chat.AddText(Color(255,200,120), "[Y] ", speaker:Name(), ": ", text) end
        })
        ```
]]
function lia.chat.register(chatType, data)
    data.arguments = data.arguments or {}
    data.syntax = L(lia.command.buildSyntaxFromArguments(data.arguments))
    data.desc = data.desc or ""
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
    if CLIENT and data.prefix then
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
                onRun = function(_, args) lia.chat.parse(LocalPlayer(), table.concat(args, " ")) end
            })
        end
    end

    data.filter = data.filter or "ic"
    lia.chat.classes[chatType] = data
end

--[[
    Purpose:
        Parse a raw chat message to determine chat type, strip prefixes, and send.

    When Called:
        On client (local send) and server (routing) before dispatching chat.

    Parameters:
        client (Player)
        message (string)
        noSend (boolean|nil)
            If true, do not forward to recipients (client-side parsing only).

    Returns:
        string, string, boolean
            chatType, message, anonymous

    Realm:
        Shared

    Example Usage:
        ```lua
        -- client
        lia.chat.parse(LocalPlayer(), "/y Hello there!")
        -- server hook
        hook.Add("PlayerSay", "LiliaChatParse", function(ply, txt)
            if lia.chat.parse(ply, txt) then return "" end
        end)
        ```
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
        Send a chat message to eligible listeners, honoring canHear/canSay rules.

    When Called:
        Server-side after parsing chat or programmatic chat generation.

    Parameters:
        speaker (Player)
        chatType (string)
        text (string)
        anonymous (boolean)
        receivers (table|nil)
            Optional explicit receiver list.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.chat.send(ply, "ic", "Hello world", false)
        ```
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
