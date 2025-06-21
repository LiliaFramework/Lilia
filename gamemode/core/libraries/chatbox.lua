lia.chat = lia.chat or {}
lia.chat.classes = lia.char.classes or {}
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
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.GetHour() .. ")" .. (ooc and "" or " ") or ""
end

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
function lia.chat.register(chatType, data)
    data.syntax = data.syntax or ""
    data.desc = data.desc or ""
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
    data.format = data.format or "%s: \"%s\""
    data.onChatAdd = data.onChatAdd or function(speaker, text, anonymous)
        local name = anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or "Console"
        chat.AddText(lia.chat.timestamp(false), data.color, string.format(data.format, name, text))
    end

    if CLIENT and data.prefix then
        local rawPrefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local aliases = {}
        for _, prefix in ipairs(rawPrefixes) do
            local cmd = prefix:gsub("^/", ""):lower()
            if cmd ~= "" then table.insert(aliases, cmd) end
        end

        if #aliases > 0 then
            lia.command.add(chatType, {
                syntax = data.syntax,
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
    if SERVER and not noSend then lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous) end
    return chatType, message, anonymous
end

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

            netstream.Start(receivers, "cMsg", speaker, chatType, hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text, anonymous)
        end
    end
end
