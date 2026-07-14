--[[
    Hooks:
        ChatAddText(string text, ...)

    Purpose:
        Allows modules to adjust the opening markup prefix used when the custom chatbox builds a rendered message from chat arguments.

    Category:
        Chat

    Parameters:
        text (string)
            The current opening markup prefix that will be prepended before chat arguments are converted into markup.

        ... (any)
            The original chat arguments that will be rendered into the chatbox message.

    Example Usage:
        ```lua
        hook.Add("ChatAddText", "liaExampleChatAddText", function(text, ...)
            return "<font=LiliaFont.24>"
        end)
        ```

    Returns:
        string|nil
            Return a markup prefix string to replace the default opening markup. Return nil to keep the current prefix.

    Realm:
        Client
]]
local PANEL = {}
local function paintChatMarkupText(chatbox, text, font, x, y, color, halign, valign, alpha)
    alpha = alpha or color.a or 255
    surface.SetFont(font)
    if IsValid(chatbox) and not chatbox.active then
        surface.SetTextColor(0, 0, 0, alpha)
        for offsetX = -1, 1 do
            for offsetY = -1, 1 do
                if offsetX ~= 0 or offsetY ~= 0 then
                    surface.SetTextPos(x + offsetX, y + offsetY)
                    surface.DrawText(text)
                end
            end
        end
    end

    surface.SetTextColor(color.r, color.g, color.b, alpha)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

function PANEL:Init()
    local border = 32
    local screenW, screenH = ScrW(), ScrH()
    local width, height = screenW * 0.4, screenH * 0.375
    lia.gui.chat = self
    self:SetSize(width, height)
    self:SetPos(border, screenH - height - border)
    self.active = false
    self.commandIndex = 0
    self.commands = lia.command.list
    self.arguments = {}
    self:SetAlphaBackground(false)
    self:SetTitle("")
    self:SetCenterTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:SetSizable(false)
    self:SetVisible(true)
    local chatIcon = Material("icon16/comments.png")
    self.Paint = function(s, w, h)
        if not s.active then return end
        local theme = lia.color.theme or {}
        local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
        local textColor = theme.text or Color(230, 238, 236)
        lia.derma.rect(0, 0, w, h):Rad(9):Color(Color(2, 13, 18, 248)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(1, 1, w - 2, h - 2):Rad(8):Color(Color(5, 21, 27, 245)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(9):Color(Color(accent.r, accent.g, accent.b, 155)):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
        lia.derma.rect(1, 1, w - 2, 40):Radii(8, 8, 0, 0):Color(Color(2, 14, 18, 252)):Draw()
        surface.SetDrawColor(accent.r, accent.g, accent.b, 105)
        surface.DrawRect(12, 40, w - 24, 1)
        if not chatIcon:IsError() then
            surface.SetMaterial(chatIcon)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 230)
            surface.DrawTexturedRect(14, 12, 16, 16)
        end

        draw.SimpleText("Chat", "LiliaFont.18", 38, 20, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if IsValid(self.btnClose) then
        self.btnClose:SetText("")
        self.btnClose:SetSize(28, 28)
        self.btnClose.Paint = function(button, w, h)
            local theme = lia.color.theme or {}
            local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
            local color = button:IsHovered() and Color(235, 110, 95) or Color(accent.r, accent.g, accent.b, 220)
            surface.SetDrawColor(color)
            surface.DrawLine(9, 9, w - 9, h - 9)
            surface.DrawLine(w - 9, 9, 9, h - 9)
        end
    end

    self.HitTest = function(s, x, y)
        if not s.active then return false end
        return s.BaseClass.HitTest(s, x, y)
    end

    local originalThink = self.Think
    self.Think = function(s)
        if originalThink then originalThink(s) end
        if IsValid(s.cls) then s.cls:SetVisible(s.active) end
        if IsValid(s.top_panel) then s.top_panel:SetVisible(s.active) end
        s:SetDraggable(s.active)
        s:SetMouseInputEnabled(s.active)
        s:SetKeyboardInputEnabled(s.active)
        if IsValid(s.sendButton) and IsValid(s.entry) then
            s.sendButton:SetSize(42, s.entry:GetTall())
            s.sendButton:SetPos(s:GetWide() - 54, s.entry:GetY())
        end
    end

    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(12, 46, 12, 6)
    self.scroll:GetVBar():SetWide(8)
    self.scrollbarShouldBeVisible = false
    self:setScrollbarVisible(false)
    self.scroll:SetVisible(true)
    local vbar = self.scroll:GetVBar()
    if IsValid(vbar) then
        vbar:SetHideButtons(true)
        vbar.Paint = function(_, w, h)
            if not self.scrollbarShouldBeVisible then return end
            surface.SetDrawColor(255, 255, 255, 5)
            surface.DrawRect(math.floor(w * 0.5) - 1, 0, 2, h)
        end

        vbar.btnGrip.Paint = function(button, w, h)
            if not self.scrollbarShouldBeVisible then return end
            local theme = lia.color.theme or {}
            local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
            local alpha = button.Depressed and 230 or button:IsHovered() and 205 or 165
            lia.derma.rect(1, 0, w - 2, h):Rad(4):Color(Color(accent.r, accent.g, accent.b, alpha)):Shape(lia.derma.SHAPE_IOS):Draw()
        end
    end

    self.lastY = 0
    self.list = {}
    chat.GetChatBoxPos = function() return self:LocalToScreen(0, 0) end
    chat.GetChatBoxSize = function() return self:GetSize() end
    hook.Add("OnThemeChanged", self, function() if IsValid(self) then self:OnThemeChanged() end end)
end

function PANEL:setScrollbarVisible(visible)
    if IsValid(self.scroll) and IsValid(self.scroll:GetVBar()) then
        local vbar = self.scroll:GetVBar()
        self.scrollbarShouldBeVisible = visible
        vbar:SetVisible(true)
        if visible then
            vbar:SetWide(8)
        else
            vbar:SetWide(0)
        end
    end
end

function PANEL:updateCommandListLayout()
    if not IsValid(self.commandList) then return end
    local listHeight = math.min(math.max(self:GetTall() * 0.55, 176), 240)
    local listWidth = self:GetWide() - 16
    local chatX, chatY = self:LocalToScreen(0, 0)
    local listX = chatX + 4
    local listY = math.max(8, chatY - listHeight - 6)
    self.commandList:SetSize(listWidth, listHeight)
    self.commandList:SetPos(listX, listY)
end

function PANEL:setActive(state)
    self.active = state
    lia.chat.wasActive = state
    if IsValid(self.cls) then self.cls:SetVisible(state) end
    if IsValid(self.top_panel) then self.top_panel:SetVisible(state) end
    self:setScrollbarVisible(state)
    self:SetDraggable(state)
    self:SetMouseInputEnabled(state)
    self:SetKeyboardInputEnabled(state)
    if not state then self:setScrollbarVisible(false) end
    if state then
        local currentTime = CurTime()
        for _, msgPanel in ipairs(self.list or {}) do
            if IsValid(msgPanel) then
                msgPanel:SetAlpha(255)
                msgPanel.start = currentTime + 8
                msgPanel.finish = msgPanel.start + 12
            end
        end

        self.entry = self:Add("liaEntry")
        self.entry:Dock(BOTTOM)
        self.entry:DockMargin(12, 0, 62, 10)
        self.entry:SetTall(38)
        self.entry:SetFont("LiliaFont.17")
        self.entry:SetPlaceholderText("Enter text...")
        self.entry.OnRemove = function() hook.Run("FinishChat") end
        local textEntry = self.entry.textEntry
        textEntry.PaintOver = function(s, w, h)
            local theme = lia.color.theme or {}
            local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
            local textColor = theme.text or Color(230, 238, 236)
            local focused = s:IsEditing() or s:HasFocus()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(5, 18, 23, 252)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(accent.r, accent.g, accent.b, focused and 180 or 95)):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
            if s:GetText() == "" then draw.SimpleText("Enter text...", "LiliaFont.17", 12, h * 0.5, Color(160, 170, 170, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
            s:DrawTextEntryText(textColor, Color(accent.r, accent.g, accent.b, 70), Color(accent.r, accent.g, accent.b, 255))
        end

        self.sendButton = self:Add("DButton")
        self.sendButton:SetText("")
        self.sendButton:SetSize(42, 38)
        self.sendButton.Paint = function(button, w, h)
            local theme = lia.color.theme or {}
            local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
            local fillAlpha = button.Depressed and 42 or button:IsHovered() and 28 or 10
            local borderAlpha = button.Depressed and 220 or button:IsHovered() and 190 or 125
            local centerX = math.floor(w * 0.5)
            local centerY = math.floor(h * 0.5)
            lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(accent.r, accent.g, accent.b, fillAlpha)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(accent.r, accent.g, accent.b, borderAlpha)):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
            surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
            surface.DrawLine(centerX - 7, centerY - 8, centerX + 6, centerY)
            surface.DrawLine(centerX + 6, centerY, centerX - 7, centerY + 8)
            surface.DrawLine(centerX - 7, centerY - 8, centerX - 3, centerY)
            surface.DrawLine(centerX - 3, centerY, centerX - 7, centerY + 8)
        end

        self.sendButton.DoClick = function() if IsValid(self.text) and self.text.OnEnter then self.text:OnEnter() end end
        lia.chat.history = lia.chat.history or {}
        self.text = self.entry.textEntry
        self.text.History = lia.chat.history
        self.text:SetHistoryEnabled(true)
        self.text:SetAllowNonAsciiCharacters(true)
        self.text.OnEnter = function(entry)
            local input = entry:GetText()
            local isCommand = input:sub(1, 1) == "/"
            if input:find("%S") then
                if not (lia.chat.lastLine or ""):find(input, 1, true) then
                    lia.chat.history[#lia.chat.history + 1] = input
                    lia.chat.lastLine = input
                end

                net.Start("liaMessageData")
                net.WriteString(input)
                net.SendToServer()
            end

            if isCommand then
                timer.Simple(0.1, function()
                    if not IsValid(self) then return end
                    self.active = false
                    if IsValid(self.commandList) then
                        self.commandList:Remove()
                        self.commandList = nil
                        self.commandScroll = nil
                        self.commandListCreateTime = nil
                    end

                    if IsValid(self.sendButton) then
                        self.sendButton:Remove()
                        self.sendButton = nil
                    end

                    if IsValid(self.entry) then self.entry:Remove() end
                    self.entry = nil
                    if IsValid(self.text) then self.text:KillFocus() end
                    self.text = nil
                    self:SetDraggable(false)
                    self:SetMouseInputEnabled(false)
                    self:SetKeyboardInputEnabled(false)
                    gui.EnableScreenClicker(false)
                end)
            else
                self.active = false
                if IsValid(self.cls) then self.cls:SetVisible(false) end
                if IsValid(self.top_panel) then self.top_panel:SetVisible(false) end
                self:setScrollbarVisible(false)
                self:SetDraggable(false)
                self:SetMouseInputEnabled(false)
                self:SetKeyboardInputEnabled(false)
                gui.EnableScreenClicker(false)
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                end

                if IsValid(self.sendButton) then
                    self.sendButton:Remove()
                    self.sendButton = nil
                end

                if IsValid(self.entry) then self.entry:Remove() end
                self.entry = nil
                if IsValid(self.text) then self.text:KillFocus() end
                self.text = nil
            end
        end

        self.text.OnTextChanged = function(entry)
            local input = entry:GetText()
            hook.Run("ChatTextChanged", input)
            if input:sub(1, 1) == "/" then
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                end

                self.commandList = vgui.Create("DPanel")
                self:updateCommandListLayout()
                self.commandList:MakePopup()
                self.commandList:SetKeyboardInputEnabled(false)
                self.commandListCreateTime = CurTime()
                self.commandList.Paint = function(_, w, h)
                    local theme = lia.color.theme or {}
                    local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
                    lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(2, 13, 18, 248)):Shape(lia.derma.SHAPE_IOS):Draw()
                    lia.derma.rect(1, 1, w - 2, h - 2):Rad(7):Color(Color(5, 21, 27, 245)):Shape(lia.derma.SHAPE_IOS):Draw()
                    lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(accent.r, accent.g, accent.b, 125)):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
                    lia.derma.rect(1, 1, w - 2, 42):Radii(7, 7, 0, 0):Color(Color(2, 14, 18, 252)):Draw()
                    draw.SimpleText("COMMANDS", "LiliaFont.18", 18, 22, Color(accent.r, accent.g, accent.b, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 90)
                    surface.DrawRect(14, 42, w - 28, 1)
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 190)
                    surface.DrawRect(18, 43, 74, 1)
                end

                self.commandScroll = self.commandList:Add("liaScrollPanel")
                self.commandScroll:Dock(FILL)
                self.commandScroll:DockMargin(12, 50, 12, 12)
                self.commandScroll:GetVBar():SetWide(8)
                local commandVBar = self.commandScroll:GetVBar()
                if IsValid(commandVBar) then
                    commandVBar:SetHideButtons(true)
                    commandVBar.Paint = function(_, w, h)
                        surface.SetDrawColor(255, 255, 255, 7)
                        surface.DrawRect(math.floor(w * 0.5) - 1, 0, 2, h)
                    end

                    commandVBar.btnGrip.Paint = function(button, w, h)
                        local theme = lia.color.theme or {}
                        local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
                        local alpha = button.Depressed and 230 or button:IsHovered() and 205 or 165
                        lia.derma.rect(1, 0, w - 2, h):Rad(4):Color(Color(accent.r, accent.g, accent.b, alpha)):Shape(lia.derma.SHAPE_IOS):Draw()
                    end
                end

                local commandCount = 0
                local function addCommandRow(commandLabel, descriptionText, onClick)
                    commandCount = commandCount + 1
                    local btn = self.commandScroll:Add("DButton")
                    btn:SetText("")
                    btn.commandLabel = commandLabel
                    btn.descriptionText = descriptionText
                    btn.isSelected = false
                    btn:Dock(TOP)
                    btn:DockMargin(0, 0, 0, 2)
                    btn:SetTall(28)
                    btn.DoClick = onClick
                    btn.Paint = function(s, w, h)
                        local theme = lia.color.theme or {}
                        local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
                        local textColor = theme.text or Color(230, 238, 236)
                        local selected = s.isSelected
                        local hovered = s:IsHovered()
                        if selected or hovered then
                            lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(accent.r, accent.g, accent.b, selected and 42 or 24)):Shape(lia.derma.SHAPE_IOS):Draw()
                            lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(accent.r, accent.g, accent.b, selected and 140 or 85)):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
                        end

                        local commandColumn = math.max(82, math.min(126, w * 0.24))
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                        surface.DrawRect(0, h - 1, w, 1)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 110)
                        surface.DrawRect(commandColumn, 7, 1, h - 14)
                        draw.SimpleText(s.commandLabel, "LiliaFont.17", 10, h * 0.5, Color(accent.r, accent.g, accent.b, selected and 255 or 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(s.descriptionText, "LiliaFont.17", commandColumn + 14, h * 0.5, selected and color_white or textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                    return btn
                end

                local function closeCommandList()
                    if IsValid(self.commandList) then self.commandList:Remove() end
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                    self.commandIndex = 0
                end

                for cmdName, cmdInfo in SortedPairs(self.commands) do
                    if not cmdName:lower():StartWith(input:sub(2):lower()) then continue end
                    local descriptionText = cmdInfo.desc ~= "" and cmdInfo.desc or L("noDesc")
                    addCommandRow("/" .. cmdName, descriptionText, function()
                        local syntax = cmdInfo.syntax or ""
                        self.text:SetText("/" .. cmdName .. " " .. syntax)
                        self.text:RequestFocus()
                        closeCommandList()
                    end)
                end

                for _, chatInfo in SortedPairs(lia.chat.classes) do
                    if not chatInfo.prefix then continue end
                    for _, prefix in ipairs(chatInfo.prefix) do
                        if prefix:sub(1, 1) == "/" then
                            local cmd = prefix:gsub("^/", ""):lower()
                            if cmd ~= "" and not self.commands[cmd] and cmd:StartWith(input:sub(2):lower()) then
                                local descriptionText = chatInfo.desc ~= "" and chatInfo.desc or L("noDesc")
                                addCommandRow(prefix, descriptionText, function()
                                    local syntax = chatInfo.syntax or ""
                                    self.text:SetText(prefix .. " " .. syntax)
                                    self.text:RequestFocus()
                                    closeCommandList()
                                end)
                            end
                        end
                    end
                end

                if commandCount == 0 then addCommandRow("/", "No matching commands.", function() if IsValid(self.text) then self.text:RequestFocus() end end) end
                self.arguments = lia.command.extractArgs(input:sub(2))
            else
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                end

                self.commandIndex = 0
            end
        end

        self:MakePopup()
        self:SetKeyboardInputEnabled(true)
        self.text:RequestFocus()
        self.text.OnKeyCodeTyped = function(entry, key)
            if key == KEY_ESCAPE then
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                end

                self.active = false
                if IsValid(self.cls) then self.cls:SetVisible(false) end
                if IsValid(self.top_panel) then self.top_panel:SetVisible(false) end
                self:setScrollbarVisible(false)
                self:SetDraggable(false)
                self:SetMouseInputEnabled(false)
                self:SetKeyboardInputEnabled(false)
                gui.EnableScreenClicker(false)
                if IsValid(self.sendButton) then
                    self.sendButton:Remove()
                    self.sendButton = nil
                end

                if IsValid(self.entry) then self.entry:Remove() end
                self.entry = nil
                if IsValid(self.text) then self.text:KillFocus() end
                self.text = nil
                return true
            end

            if entry:GetText():sub(1, 1) == "/" and key == KEY_TAB and IsValid(self.commandList) then
                local canvas = IsValid(self.commandScroll) and self.commandScroll:GetCanvas() or nil
                if not IsValid(canvas) then return true end
                local canvasChildren = canvas:GetChildren()
                if #canvasChildren == 0 then return true end
                for _, child in ipairs(canvasChildren) do
                    if IsValid(child) then child.isSelected = false end
                end

                self.commandIndex = (self.commandIndex or 0) + 1
                if self.commandIndex > #canvasChildren then self.commandIndex = 1 end
                local selected = canvasChildren[self.commandIndex]
                if not IsValid(selected) then return true end
                selected.isSelected = true
                local selName = (selected.commandLabel or selected:GetText()):match("^/([^%s]+)")
                if selName then
                    self.text:SetText("/" .. selName)
                    self.text:SetCaretPos(#self.text:GetText())
                end

                if IsValid(self.commandScroll) then self.commandScroll:ScrollToChild(selected) end
                self.text:RequestFocus()
                return true
            end
            return DTextEntry.OnKeyCodeTyped(entry, key)
        end

        self.text.OnLoseFocus = function(entry)
            if IsValid(self.commandList) then
                local currentText = entry:GetText()
                local timeSinceCreation = self.commandListCreateTime and (CurTime() - self.commandListCreateTime) or 0
                local isTypingCommand = currentText:sub(1, 1) == "/"
                if not isTypingCommand and timeSinceCreation > 0.5 then
                    self.commandList:Remove()
                    self.commandList = nil
                    self.commandScroll = nil
                    self.commandListCreateTime = nil
                end
            end

            entry:RequestFocus()
        end

        hook.Run("StartChat")
        if IsValid(self.scroll) and #self.list > 0 then
            local lastPanel = self.list[#self.list]
            if IsValid(lastPanel) then self.scroll:ScrollToChild(lastPanel) end
        end
    end
end

local function appendMarkupItem(markup, item)
    if type(item) == "IMaterial" then return markup .. "<img=" .. item:GetName() .. ",16x16>" end
    if item and istable(item) and item.GetName and item.Width and item.Height then return markup .. "<img=" .. item:GetName() .. "," .. item:Width() .. "x" .. item:Height() .. ">" end
    if IsColor(item) then return markup .. "<color=" .. item.r .. "," .. item.g .. "," .. item.b .. ">" end
    if IsValid(item) and item:IsPlayer() then
        local clr = team.GetColor(item:Team())
        return markup .. "<color=" .. clr.r .. "," .. clr.g .. "," .. clr.b .. ">" .. item:Name():gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("#", "\226\128\139#")
    end

    local str = tostring(item):gsub("<", "&lt;"):gsub(">", "&gt;")
    return markup .. str:gsub("%b**", function(val)
        local inner = val:sub(2, -2)
        if inner:find("%S") then return "<font=LiliaFont.20i>" .. inner .. "</font>" end
    end)
end

function PANEL:addText(...)
    lia.chat = lia.chat or {}
    lia.chat.persistedMessages = lia.chat.persistedMessages or {}
    local shouldPersist = not self.skipPersist
    local argList = {...}
    local markup = "<font=LiliaFont.20>"
    markup = hook.Run("ChatAddText", markup, unpack(argList)) or markup
    for _, item in ipairs(argList) do
        markup = appendMarkupItem(markup, item)
    end

    markup = markup .. "</font>"
    local panel = self.scroll:Add("liaMarkupPanel")
    panel:SetWide(self:GetWide() - 16)
    panel:setMarkup(markup, function(...) paintChatMarkupText(self, ...) end)
    panel.originalArgs = argList
    panel.markupArgs = {
        markup = markup,
        arguments = argList,
        themeState = {
            chatColor = lia.color.theme.chat,
            chatListenColor = lia.color.theme.chatListen
        }
    }

    panel.start = CurTime() + 8
    panel.finish = panel.start + 12
    panel.Think = function(p)
        if self.active then
            p:SetAlpha(255)
        else
            local fraction = math.TimeFraction(p.start, p.finish, CurTime())
            local alpha = 255 - (fraction * 255)
            p:SetAlpha(math.max(alpha, 0))
        end
    end

    self.list[#self.list + 1] = panel
    panel:SetPos(0, self.lastY)
    self.lastY = self.lastY + panel:GetTall() + 2
    timer.Simple(0.01, function() if IsValid(self.scroll) and IsValid(panel) then self.scroll:ScrollToChild(panel) end end)
    if shouldPersist then
        local history = lia.chat.persistedMessages
        history[#history + 1] = {
            arguments = argList
        }

        local maxEntries = 200
        if #history > maxEntries then
            local overflow = #history - maxEntries
            for i = 1, overflow do
                table.remove(history, 1)
            end
        end
    end

    if not self.active then
        self:SetVisible(true)
        if IsValid(self.scroll) then self.scroll:SetVisible(true) end
        self:SetAlpha(255)
        timer.Simple(0.1, function() if IsValid(self) and not self.active then self:SetAlpha(200) end end)
    end
    return panel:IsVisible()
end

function PANEL:Think()
    if gui.IsGameUIVisible() and self.active then
        self.active = false
        if IsValid(self.cls) then self.cls:SetVisible(false) end
        if IsValid(self.top_panel) then self.top_panel:SetVisible(false) end
        self:setScrollbarVisible(false)
        self:SetDraggable(false)
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)
        gui.EnableScreenClicker(false)
        if IsValid(self.commandList) then
            self.commandList:Remove()
            self.commandList = nil
            self.commandScroll = nil
            self.commandListCreateTime = nil
        end

        if IsValid(self.sendButton) then
            self.sendButton:Remove()
            self.sendButton = nil
        end

        if IsValid(self.entry) then self.entry:Remove() end
        self.entry = nil
        if IsValid(self.text) then self.text:KillFocus() end
        self.text = nil
    end

    if not self.active then self:setScrollbarVisible(false) end
    if self.active and IsValid(self.commandList) then self:updateCommandListLayout() end
    if self.active and IsValid(self.text) and IsValid(self.commandList) then
        local textHasFocus = self.text:HasFocus()
        local currentText = self.text:GetText()
        local timeSinceCreation = self.commandListCreateTime and (CurTime() - self.commandListCreateTime) or 0
        local isTypingCommand = currentText:sub(1, 1) == "/"
        if not textHasFocus and not isTypingCommand and timeSinceCreation > 0.1 then
            self.commandList:Remove()
            self.commandList = nil
            self.commandScroll = nil
            self.commandListCreateTime = nil
        end
    end
end

function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    if IsValid(self.commandList) then
        local canvas = IsValid(self.commandScroll) and self.commandScroll:GetCanvas() or nil
        if IsValid(canvas) then
            for _, child in ipairs(canvas:GetChildren()) do
                if IsValid(child) and child.SetTextColor then child:SetTextColor(lia.color.theme.text or Color(255, 255, 255)) end
            end
        end

        self.commandList:InvalidateLayout()
    end

    for _, panel in ipairs(self.list or {}) do
        if IsValid(panel) and panel.markupArgs then self:rebuildPanelMarkup(panel) end
    end
end

function PANEL:rebuildPanelMarkup(panel)
    if not panel.markupArgs or not panel.markupArgs.themeState then return end
    local currentChatColor = lia.color.theme.chat
    local currentChatListenColor = lia.color.theme.chatListen
    local markup = "<font=LiliaFont.20>"
    markup = hook.Run("ChatAddText", markup, unpack(panel.markupArgs.arguments)) or markup
    for _, item in ipairs(panel.markupArgs.arguments) do
        if type(item) == "IMaterial" then
            markup = markup .. "<img=" .. item:GetName() .. ",16x16>"
        elseif item and istable(item) and item.GetName and item.Width and item.Height then
            local matName = item:GetName()
            markup = markup .. "<img=" .. matName .. "," .. item:Width() .. "x" .. item:Height() .. ">"
        elseif IsColor(item) then
            local color = item
            if panel.markupArgs.themeState.chatColor and color.r == panel.markupArgs.themeState.chatColor.r and color.g == panel.markupArgs.themeState.chatColor.g and color.b == panel.markupArgs.themeState.chatColor.b then
                color = currentChatColor
            elseif panel.markupArgs.themeState.chatListenColor and color.r == panel.markupArgs.themeState.chatListenColor.r and color.g == panel.markupArgs.themeState.chatListenColor.g and color.b == panel.markupArgs.themeState.chatListenColor.b then
                color = currentChatListenColor
            end

            markup = markup .. "<color=" .. color.r .. "," .. color.g .. "," .. color.b .. ">"
        elseif IsValid(item) and item:IsPlayer() then
            local clr = team.GetColor(item:Team())
            markup = markup .. "<color=" .. clr.r .. "," .. clr.g .. "," .. clr.b .. ">" .. item:Name():gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("#", "\226\128\139#")
        else
            local str = tostring(item):gsub("<", "&lt;"):gsub(">", "&gt;")
            markup = markup .. str:gsub("%b**", function(val)
                local inner = val:sub(2, -2)
                if inner:find("%S") then return "<font=LiliaFont.20i>" .. inner .. "</font>" end
            end)
        end
    end

    markup = markup .. "</font>"
    panel:setMarkup(markup, function(...) paintChatMarkupText(self, ...) end)
    panel.markupArgs.markup = markup
    panel.markupArgs.themeState = {
        chatColor = currentChatColor,
        chatListenColor = currentChatListenColor
    }
end

function PANEL:OnRemove()
    if IsValid(self.commandList) then
        self.commandList:Remove()
        self.commandList = nil
        self.commandScroll = nil
    end

    self:SetDraggable(false)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
    hook.Remove("OnThemeChanged", self)
end

vgui.Register("liaChatBox", PANEL, "liaFrame")