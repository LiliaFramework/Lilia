local MODULE = MODULE
lia.chat = lia.chat or {}
lia.chat.persistedMessages = lia.chat.persistedMessages or {}
chat.liaAddText = chat.liaAddText or chat.AddText
local function createShadowed(panel, args)
    if not (IsValid(panel) and IsValid(panel.scroll)) then return false end
    if not (istable(args) and #args >= 3 and IsColor(args[1]) and isstring(args[2]) and IsColor(args[3])) then return false end
    local labelColor = args[1]
    local labelText = args[2]
    local textColor = args[3]
    local messageText = ""
    for i = 4, #args do
        if isstring(args[i]) then messageText = messageText .. args[i] end
    end

    local paintedPanel = vgui.Create("liaPaintedNotification", panel.scroll)
    paintedPanel:SetNotification(labelText, labelColor, messageText, textColor)
    paintedPanel:SetWide(panel:GetWide() - 16)
    paintedPanel.start = CurTime() + 8
    paintedPanel.finish = paintedPanel.start + 12
    paintedPanel.Think = function(p)
        if panel.active then
            p:SetAlpha(255)
        else
            local fraction = math.TimeFraction(p.start, p.finish, CurTime())
            local alpha = 255 - (fraction * 255)
            p:SetAlpha(math.max(alpha, 0))
        end
    end

    panel.list = panel.list or {}
    panel.list[#panel.list + 1] = paintedPanel
    paintedPanel:SetPos(0, panel.lastY or 0)
    panel.lastY = (panel.lastY or 0) + paintedPanel:GetTall() + 2
    timer.Simple(0.01, function() if IsValid(panel.scroll) and IsValid(paintedPanel) then panel.scroll:ScrollToChild(paintedPanel) end end)
    return true
end

function MODULE:CreateChat()
    if IsValid(self.panel) then return end
    if IsValid(lia.gui.chat) then
        self.panel = lia.gui.chat
        return
    end

    self.panel = vgui.Create("liaChatBox")
    self.panel.skipPersist = true
    hook.Run("ChatboxPanelCreated", self.panel)
    for _, entry in ipairs(lia.chat.persistedMessages or {}) do
        if istable(entry) and entry.arguments then
            if entry.shadowed then
                createShadowed(self.panel, entry.arguments)
            else
                self.panel:addText(unpack(entry.arguments))
            end
        end
    end

    self.panel.skipPersist = false
    if lia.chat.wasActive then self.panel:setActive(true) end
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
    lia.chat.persistedMessages = {}
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
    if not IsValid(MODULE.panel) then MODULE:CreateChat() end
    local show = true
    if IsValid(MODULE.panel) then show = MODULE.panel:addText(...) end
    if show then
        chat.liaAddText(...)
        hook.Run("ChatboxTextAdded", ...)
    end
end

function MODULE:ChatText(_, _, text, messageType)
    if messageType ~= "none" then return end
    local hadPanel = IsValid(self.panel)
    if not hadPanel then
        local prevActive = lia.chat.wasActive
        lia.chat.wasActive = false
        self:CreateChat()
        lia.chat.wasActive = prevActive
    end

    if not IsValid(self.panel) then return end
    local wasActive = self.panel.active
    self.panel:addText(text)
    if not wasActive and self.panel.active then self.panel:setActive(false) end
    if lia.config.get("CustomChatSound", "") and lia.config.get("CustomChatSound", "") ~= "" then
        surface.PlaySound(lia.config.get("CustomChatSound", ""))
    else
        chat.PlaySound()
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
