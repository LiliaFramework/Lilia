lia.chat = lia.chat or {}
lia.chat.classes = lia.char.classes or {}

local DUMMY_COMMAND = {
    syntax = "<string text>",
    onRun = function() end
}

if not lia.command then
    include("sh_command.lua")
end

-- Returns a timestamp
function lia.chat.timestamp(ooc)
    return lia.config.get("chatShowTime") and (ooc and " " or "") .. "(" .. lia.date.getFormatted("%H:%M") .. ")" .. (ooc and "" or " ") or ""
end

-- Registers a new chat type with the information provided.
function lia.chat.register(chatType, data)
    if not data.onCanHear then
        -- Let's see first if a dynamic radius has been set.
        if isfunction(data.radius) then
            -- If this is the case, then it gives the same situation where onCanHear property is a number.
            -- But instead of entering a static number, the radius function will be called each time.
            -- This can be useful if you want it to be linked to a variable that can be changed.
            data.onCanHear = function(speaker, listener)
                -- Squared distances will always perform better than standard distances.
                return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.radius() ^ 2)
            end
        elseif isnumber(data.radius) then
            -- To avoid confusion, the radius can be a static number.
            -- In this case, we use the same method as the one used for the "onCanHear" property.
            local range = data.radius ^ 2

            data.onCanHear = function(speaker, listener)
                return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range
            end
        else
            -- Have a substitute if the canHear and radius properties are not found.
            data.onCanHear = function(speaker, listener)
                -- The speaker will be heard by everyone.
                return true
            end
        end
    elseif isnumber(data.onCanHear) then
        -- Use the value as a range and create a function to compare distances.
        local range = data.onCanHear ^ 2

        data.onCanHear = function(speaker, listener)
            -- Length2DSqr is faster than Length2D, so just check the squares.
            return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range
        end
    end

    -- Allow players to use this chat type by default.
    if not data.onCanSay then
        data.onCanSay = function(speaker, text)
            if not data.deadCanChat and not speaker:Alive() then
                speaker:notifyLocalized("noPerm")

                return false
            end

            return true
        end
    end

    -- Chat text color.
    data.color = data.color or Color(242, 230, 160)

    if not data.onChatAdd then
        data.format = data.format or "%s: \"%s\""

        data.onChatAdd = function(speaker, text, anonymous)
            local color = data.color
            local name = anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or (IsValid(speaker) and speaker:Name() or "Console")

            if data.onGetColor then
                color = data.onGetColor(speaker, text)
            end

            local timestamp = lia.chat.timestamp(false)
            local translated = L2(chatType .. "Format", name, text)
            chat.AddText(timestamp, color, translated or string.format(data.format, name, text))
        end
    end

    if CLIENT and data.prefix then
        if type(data.prefix) == "table" then
            for _, v in ipairs(data.prefix) do
                if v:sub(1, 1) == "/" then
                    lia.command.add(v:sub(2), DUMMY_COMMAND)
                end
            end
        else
            lia.command.add(chatType, DUMMY_COMMAND)
        end
    end

    data.filter = data.filter or "ic"
    -- Add the chat type to the list of classes.
    lia.chat.classes[chatType] = data
end

-- Identifies which chat mode should be used.
function lia.chat.parse(client, message, noSend)
    local anonymous = false
    local chatType = "ic"

    -- Loop through all chat classes and see if the message contains their prefix.
    for k, v in pairs(lia.chat.classes) do
        local isChosen = false
        local chosenPrefix = ""
        local noSpaceAfter = v.noSpaceAfter

        -- Check through all prefixes if the chat type has more than one.
        if type(v.prefix) == "table" then
            for _, prefix in ipairs(v.prefix) do
                -- Checking if the start of the message has the prefix.
                if message:sub(1, #prefix + (noSpaceAfter and 0 or 1)):lower() == prefix .. (noSpaceAfter and "" or " "):lower() then
                    isChosen = true
                    chosenPrefix = prefix .. (v.noSpaceAfter and "" or " ")
                    break
                end
            end
            -- Otherwise the prefix itself is checked.
        elseif type(v.prefix) == "string" then
            isChosen = message:sub(1, #v.prefix + (noSpaceAfter and 1 or 0)):lower() == v.prefix .. (noSpaceAfter and "" or " "):lower()
            chosenPrefix = v.prefix .. (v.noSpaceAfter and "" or " ")
        end

        -- If the checks say we have the proper chat type, then the chat type is the chosen one!
        -- If this is not chosen, the loop continues. If the loop doesn't find the correct chat
        -- type, then it falls back to IC chat as seen by the chatType variable above.
        if isChosen then
            -- Set the chat type to the chosen one.
            chatType = k
            -- Remove the prefix from the chat type so it does not show in the message.
            message = message:sub(#chosenPrefix + 1)

            if lia.chat.classes[k].noSpaceAfter and message:sub(1, 1):match("%s") then
                message = message:sub(2)
            end

            break
        end
    end

    if not message:find("%S") then return end

    -- Only send if needed.
    if SERVER and not noSend then
        -- Send the correct chat type out so other player see the message.
        lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous)
    end
    -- Return the chosen chat type and the message that was sent if needed for some reason.
    -- This would be useful if you want to send the message on your own.

    return chatType, message, anonymous
end

if SERVER then
    -- Send a chat message using the specified chat type.
    function lia.chat.send(speaker, chatType, text, anonymous, receivers)
        local class = lia.chat.classes[chatType]

        if class and class.onCanSay(speaker, text) ~= false then
            if class.onCanHear and not receivers then
                receivers = {}

                for _, v in ipairs(player.GetAll()) do
                    if v:getChar() and class.onCanHear(speaker, v) ~= false then
                        receivers[#receivers + 1] = v
                    end
                end

                if #receivers == 0 then return end
            end

            netstream.Start(receivers, "cMsg", speaker, chatType, hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text, anonymous)
        end
    end
else
    -- Call onChatAdd for the appropriate chatType.
    netstream.Hook("cMsg", function(client, chatType, text, anonymous)
        if IsValid(client) then
            local class = lia.chat.classes[chatType]
            text = hook.Run("OnChatReceived", client, chatType, text, anonymous) or text

            if class then
                CHAT_CLASS = class
                class.onChatAdd(client, text, anonymous)

                if CONFIG.CustomChatSound and CONFIG.CustomChatSound ~= "" then
                    surface.PlaySound(CONFIG.CustomChatSound)
                else
                    chat.PlaySound()
                end

                CHAT_CLASS = nil
            end
        end
    end)
end
