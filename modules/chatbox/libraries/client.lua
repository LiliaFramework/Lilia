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

function MODULE:OnReloaded()
    RunConsoleCommand("fixchatplz")
end

function MODULE:PlayerBindPress(_, bind, pressed)
    bind = bind:lower()
    if bind:find("messagemode") and pressed then
        if not self.panel.active then self.panel:setActive(true) end
        return true
    end
end

function chat.AddText(...)
    local show = true
    if IsValid(MODULE.panel) then show = MODULE.panel:addText(...) end
    if show then chat.liaAddText(...) end
end

function MODULE:ChatText(_, _, text, messageType)
    if messageType == "none" and IsValid(self.panel) then
        self.panel:addText(text)
        if lia.config.get("CustomChatSound", "") and lia.config.get("CustomChatSound", "") ~= "" then
            surface.PlaySound(lia.config.get("CustomChatSound", ""))
        else
            chat.PlaySound()
        end
    end
end

function MODULE:ChatAddText(text, ...)
    if not lia.config.get("ChatSizeDiff", false) then return text end
    local chatArgs = {...}
    local chatMode = #chatArgs <= 4 and chatArgs[2] or chatArgs[3]
    if not chatMode or istable(chatMode) then return "<font=liaChatFont>" end
    chatMode = string.lower(chatMode)
    if string.find(chatMode, "yell", 1, true) then
        return "<font=liaBigChatFont>"
    elseif string.sub(chatMode, 1, 2) == "**" then
        return "<font=liaItalicsChatFont>"
    elseif string.find(chatMode, "whisper", 1, true) then
        return "<font=liaSmallChatFont>"
    elseif string.find(chatMode, "ooc", 1, true) or string.find(chatMode, "looc", 1, true) then
        return "<font=liaChatFont>"
    else
        return "<font=liaMediumChatFont>"
    end
end

concommand.Add("fixchatplz", function()
    if IsValid(MODULE.panel) then
        MODULE.panel:Remove()
        MODULE:createChat()
    end
end)
