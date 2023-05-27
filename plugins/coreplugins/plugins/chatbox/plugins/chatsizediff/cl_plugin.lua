function PLUGIN:ChatAddText(text, ...)
    if lia.config.get("chatSizeDiff", true) then
        local chatText = {...}

        local chatMode = #chatText <= 4 and chatText[2] or chatText[3]

        if not chatMode or istable(chatMode) then
            return "<font=liaChatFont>"
        else
            local chatMode = string.lower(chatMode)

            if string.match(chatMode, "yell") then
                return "<font=liaBigChatFont>"
            elseif string.sub(chatMode, 1, 2) == "**" then
                return "<font=liaItalicsChatFont>"
            elseif string.match(chatMode, "whisper") then
                return "<font=liaSmallChatFont>"
            elseif string.match(chatMode, "ooc") or string.match(chatMode, "looc") then
                return "<font=liaChatFont>"
            else
                return "<font=liaMediumChatFont>"
            end
        end
    else
        return text
    end
end