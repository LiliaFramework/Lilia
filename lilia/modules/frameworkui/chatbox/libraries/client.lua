local MODULE = MODULE
chat.liaAddText = chat.liaAddText or chat.AddText
LIA_CVAR_CHATFILTER = CreateClientConVar("lia_chatfilter", "", true, false)
function MODULE:createChat()
    if IsValid(self.panel) then return end
    self.panel = vgui.Create("liaChatBox")
end

function MODULE:InitPostEntity()
    self:createChat()
end

function MODULE:PlayerBindPress(_, bind, pressed)
    bind = bind:lower()
    if bind:find("messagemode") and pressed then
        if not self.panel.active then self.panel:setActive(true) end
        return true
    end
end

function MODULE:HUDShouldDraw(element)
    if element == "CHudChat" then return false end
end

function chat.AddText(...)
    local show = true
    if IsValid(MODULE.panel) then show = MODULE.panel:addText(...) end
    if show then chat.liaAddText(...) end
end

function MODULE:ChatText(_, _, text, messageType)
    if messageType == "none" and IsValid(self.panel) then
        self.panel:addText(text)
        if self.CustomChatSound and self.CustomChatSound ~= "" then
            surface.PlaySound(self.CustomChatSound)
        else
            chat.PlaySound()
        end
    end
end

function MODULE:ChatAddText(text, ...)
    if self.ChatSizeDiff then
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

concommand.Add("fixchatplz", function()
    if IsValid(MODULE.panel) then
        MODULE.panel:Remove()
        MODULE:createChat()
    end
end)
