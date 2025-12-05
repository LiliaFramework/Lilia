local MODULE = MODULE
chat.liaAddText = chat.liaAddText or chat.AddText
function MODULE:CreateChat()
    if IsValid(self.panel) then return end
    if IsValid(lia.gui.chat) then
        self.panel = lia.gui.chat
        return
    end

    self.panel = vgui.Create("liaChatBox")
    hook.Run("ChatboxPanelCreated", self.panel)
end

function MODULE:InitPostEntity()
    self:CreateChat()
end

local function RegenChat()
    for _, panel in ipairs(vgui.GetAll()) do
        if IsValid(panel) and panel:GetName() == "liaChatBox" then panel:Remove() end
    end

    MODULE.panel = nil
    lia.gui.chat = nil
    MODULE:CreateChat()
end

function MODULE:PlayerBindPress(_, bind, pressed)
    bind = bind:lower()
    if bind:find("messagemode") and pressed then
        if not IsValid(self.panel) then self:CreateChat() end
        if not self.panel.active then self.panel:setActive(true) end
        return true
    end
end

function chat.AddText(...)
    local show = true
    if IsValid(MODULE.panel) then show = MODULE.panel:addText(...) end
    if show then
        chat.liaAddText(...)
        hook.Run("ChatboxTextAdded", ...)
    end
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
    if not chatMode or istable(chatMode) then return "<font=LiliaFont.22>" end
    chatMode = string.lower(chatMode)
    if string.find(chatMode, "yell", 1, true) then
        return "<font=LiliaFont.26b>"
    elseif string.sub(chatMode, 1, 2) == "**" then
        return "<font=LiliaFont.23i>"
    elseif string.find(chatMode, "whisper", 1, true) then
        return "<font=LiliaFont.20>"
    elseif string.find(chatMode, "ooc", 1, true) or string.find(chatMode, "looc", 1, true) then
        return "<font=LiliaFont.22>"
    else
        return "<font=LiliaFont.24>"
    end
end

net.Receive("liaRegenChat", RegenChat)
