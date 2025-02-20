lia.chat = lia.chat or {}
lia.chat.classes = lia.char.classes or {}
lia.chat.aliases = lia.chat.aliases or {}
local DUMMY_COMMAND = {
    onRun = function() end
}

function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.GetFormattedDate(nil, false, false, false, false, true) .. ")" .. (ooc and "" or " ") or ""
end

function lia.chat.register(chatType, data)
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

    if not data.onCanSay then
        data.onCanSay = function(speaker)
            if not data.deadCanChat and not speaker:Alive() then
                speaker:notifyLocalized("noPerm")
                return false
            end
            return true
        end
    end

    data.color = data.color or Color(242, 230, 160)
    if not data.onChatAdd then
        data.format = data.format or "%s: \"%s\""
        data.onChatAdd = function(speaker, text, anonymous)
            local color = data.color
            local name = anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or "Console"
            if data.onGetColor then color = data.onGetColor(speaker, text) end
            local timestamp = lia.chat.timestamp(false)
            chat.AddText(timestamp, color, string.format(data.format, name, text))
        end
    end

    if CLIENT and data.prefix then
        if istable(data.prefix) then
            for _, v in ipairs(data.prefix) do
                if v:sub(1, 1) == "/" then lia.command.add(v:sub(2), DUMMY_COMMAND) end
            end
        else
            lia.command.add(chatType, DUMMY_COMMAND)
        end
    end

    data.filter = data.filter or "ic"
    lia.chat.classes[chatType] = data
    if data.alias then
        if istable(data.alias) then
            for _, alias in ipairs(data.alias) do
                lia.chat.aliases[alias:lower()] = chatType
            end
        else
            lia.chat.aliases[tostring(data.alias):lower()] = chatType
        end
    end
end

function lia.chat.parse(client, message, noSend)
    local anonymous = false
    local chatType = "ic"
    for k, v in pairs(lia.chat.classes) do
        local isChosen = false
        local chosenPrefix = ""
        local noSpaceAfter = v.noSpaceAfter
        if istable(v.prefix) then
            for _, prefix in ipairs(v.prefix) do
                if message:sub(1, #prefix + (noSpaceAfter and 0 or 1)):lower() == prefix .. (noSpaceAfter and "" or " "):lower() then
                    isChosen = true
                    chosenPrefix = prefix .. (v.noSpaceAfter and "" or " ")
                    break
                end
            end
        elseif isstring(v.prefix) then
            isChosen = message:sub(1, #v.prefix + (noSpaceAfter and 0 or 1)):lower() == v.prefix .. (noSpaceAfter and "" or " "):lower()
            chosenPrefix = v.prefix .. (v.noSpaceAfter and "" or " ")
        end

        if isChosen then
            chatType = k
            message = message:sub(#chosenPrefix + 1)
            if lia.chat.classes[k].noSpaceAfter and message:sub(1, 1):match("%s") then message = message:sub(2) end
            break
        end
    end

    if chatType == "ic" then
        local firstWord = message:match("^(%S+)")
        if firstWord then
            local aliasType = lia.chat.aliases[firstWord:lower()]
            if aliasType then
                chatType = aliasType
                message = message:sub(#firstWord + 1)
                if message:sub(1, 1):match("%s") then message = message:sub(2) end
            end
        end
    end

    if not message:find("%S") then return end
    if SERVER and not noSend then lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous) end
    return chatType, message, anonymous
end

if SERVER then
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