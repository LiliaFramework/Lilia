lia.chat = lia.chat or {}
lia.chat.classes = lia.chat.classes or {}
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.GetHour() .. ")" .. (ooc and "" or " ") or ""
end

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

    data.color = data.color or Color(242, 230, 160)
    data.format = data.format or "chatFormat"
    data.onChatAdd = data.onChatAdd or function(speaker, text, anonymous) chat.AddText(lia.chat.timestamp(false), data.color, L(data.format, anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or L("console"), text)) end
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
