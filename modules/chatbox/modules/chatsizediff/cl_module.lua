--------------------------------------------------------------------------------------------------------
function MODULE:ChatAddText(text, ...)
    if lia.config.ChatSizeDiff then
        local chatText = {...}
        local chatModeValue = #chatText <= 4 and chatText[2] or chatText[3]
        if not chatModeValue or istable(chatModeValue) then
            return "<font=liaChatFont>"
        else
            local chatMode = string.lower(chatModeValue)
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
--------------------------------------------------------------------------------------------------------