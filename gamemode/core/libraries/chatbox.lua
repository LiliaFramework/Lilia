--[[
# Chatbox Library

This page documents the functions for working with chat systems and communication.

---

## Overview

The chatbox library provides a comprehensive chat system for managing different types of communication within the Lilia framework. It handles chat type registration, message formatting, radius-based communication, and provides utilities for creating custom chat channels. The library supports both in-character and out-of-character communication with proper role-playing mechanics.
]]
lia.chat = lia.chat or {}
lia.chat.classes = lia.char.classes or {}
--[[
    lia.chat.timestamp

    Purpose:
        Returns a formatted timestamp string for chat messages, optionally including a space for OOC (out-of-character) messages.
        The timestamp is only shown if the ChatShowTime option is enabled.

    Parameters:
        ooc (boolean) - Whether the message is OOC (affects spacing).

    Returns:
        timestamp (string) - The formatted timestamp string, or an empty string if disabled.

    Realm:
        Shared.

    Example Usage:
        -- Get a timestamp for an IC message
        local ts = lia.chat.timestamp(false)
        -- Get a timestamp for an OOC message
        local tsOOC = lia.chat.timestamp(true)
]]
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.GetHour() .. ")" .. (ooc and "" or " ") or ""
end

--[[
    lia.chat.register

    Purpose:
        Registers a new chat type with the chat system, defining its behavior, appearance, and command aliases.
        Handles prefix processing, hearing/speaking logic, and client-side command registration.

    Parameters:
        chatType (string) - The unique identifier for the chat type (e.g., "ic", "ooc").
        data (table)      - Table describing the chat type's properties (prefix, color, radius, etc).

    Returns:
        None.

    Realm:
        Shared (client and server).

    Example Usage:
        -- Register a new /me chat type for roleplay actions
        lia.chat.register("me", {
            prefix = {"/me", "/action"},
            color = Color(200, 150, 255),
            format = "chatMeFormat",
            radius = 150,
            desc = "Performs an action.",
            arguments = {{name = "action", type = "string"}},
            onChatAdd = function(speaker, text)
                chat.AddText(lia.chat.timestamp(false), Color(200, 150, 255), speaker:Name() .. " " .. text)
            end
        })
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
            speaker:notifyLocalized("noPerm")
            return false
        end
        return true
    end

    data.color = data.color or Color(242, 230, 160)
    data.format = data.format or "chatFormat"
    data.onChatAdd = data.onChatAdd or function(speaker, text, anonymous) chat.AddText(lia.chat.timestamp(false), data.color, L(data.format, anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or L("console"), text)) end
    if CLIENT and data.prefix then
        local rawPrefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local aliases, lookup = {}, {}
        for _, prefix in ipairs(rawPrefixes) do
            local cmd = prefix:gsub("^/", ""):lower()
            if cmd ~= "" and not lookup[cmd] then
                table.insert(aliases, cmd)
                lookup[cmd] = true
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
    lia.chat.parse

    Purpose:
        Parses a chat message to determine its chat type, stripping any recognized prefix and handling anonymous flags.
        Optionally sends the message to the server if not suppressed.

    Parameters:
        client (Player)   - The player sending the message.
        message (string)  - The raw chat message to parse.
        noSend (boolean)  - If true, prevents sending the message to the server (optional).

    Returns:
        chatType (string)   - The determined chat type (e.g., "ic", "ooc").
        message (string)    - The message with the prefix removed.
        anonymous (boolean) - Whether the message is anonymous.

    Realm:
        Shared.

    Example Usage:
        -- Parse a message from a player
        local chatType, msg, anon = lia.chat.parse(ply, "/me waves hello")
        -- Parse a message without sending to server
        local chatType, msg, anon = lia.chat.parse(ply, "/ooc Hello world!", true)
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
    if SERVER and not noSend then lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous) end
    return chatType, message, anonymous
end

if SERVER then
    --[[
        lia.chat.send

        Purpose:
            Sends a chat message to all appropriate receivers based on the chat type's rules.
            Handles message formatting, receiver filtering, and network transmission.

        Parameters:
            speaker (Player)      - The player sending the message.
            chatType (string)     - The chat type identifier (e.g., "ic", "ooc").
            text (string)         - The message text to send.
            anonymous (boolean)   - Whether the message is anonymous.
            receivers (table)     - (Optional) Table of players to receive the message. If nil, will be determined by onCanHear.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Send a message to all players in range
            lia.chat.send(ply, "ic", "Hello, world!", false)
            -- Send an anonymous OOC message to all players
            lia.chat.send(ply, "ooc", "This is a secret.", true)
            -- Send a message to a specific set of receivers
            local targets = {player1, player2}
            lia.chat.send(ply, "ic", "Private message", false, targets)
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

            net.Start("cMsg")
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