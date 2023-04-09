function PLUGIN:LoadFonts(font)
    surface.CreateFont("liaSmallChatFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 750
    })

    surface.CreateFont("liaItalicsChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 600,
        italic = true
    })

    surface.CreateFont("liaMediumChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaBigChatFont", {
        font = font,
        size = math.max(ScreenScale(8), 17),
        extended = true,
        weight = 200
    })
end

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