local PANEL = {}
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
    self.Paint = function(s, w, h)
        if not s.active then return end
        local originalPaint = s.BaseClass.Paint
        if originalPaint then originalPaint(s, w, h) end
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
    end

    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(4, 4, 4, 36)
    self.scroll:GetVBar():SetWide(8)
    self.scrollbarShouldBeVisible = false
    self:setScrollbarVisible(false)
    -- Ensure scroll panel is always visible
    self.scroll:SetVisible(true)
    local vbar = self.scroll:GetVBar()
    if IsValid(vbar) then
        local originalPaint = vbar.Paint
        vbar.Paint = function(s, w, h) if self.scrollbarShouldBeVisible and originalPaint then originalPaint(s, w, h) end end
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

function PANEL:setActive(state)
    self.active = state
    if IsValid(self.cls) then self.cls:SetVisible(state) end
    if IsValid(self.top_panel) then self.top_panel:SetVisible(state) end
    self:setScrollbarVisible(state)
    self:SetDraggable(state)
    self:SetMouseInputEnabled(state)
    self:SetKeyboardInputEnabled(state)
    if not state then self:setScrollbarVisible(false) end
    if state then
        self.entry = self:Add("liaEntry")
        self.entry:Dock(BOTTOM)
        self.entry:SetTall(28)
        self.entry.OnRemove = function() hook.Run("FinishChat") end
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
                        self.commandListCreateTime = nil
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
                    self.commandListCreateTime = nil
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
                    self.commandListCreateTime = nil
                end

                self.commandList = vgui.Create("liaScrollPanel")
                local listHeight = math.min(self:GetTall() - 66, 200)
                local listWidth = self:GetWide() - 16
                local chatX, chatY = self:LocalToScreen(0, 0)
                local listY = chatY - listHeight - 4
                if listY < 0 then listY = chatY + self:GetTall() + 4 end
                self.commandList:SetPos(chatX + 4, listY)
                self.commandList:SetSize(listWidth, listHeight)
                self.commandList:GetVBar():SetWide(8)
                self.commandList:MakePopup()
                self.commandList:SetKeyboardInputEnabled(false)
                self.commandListCreateTime = CurTime()
                for cmdName, cmdInfo in SortedPairs(self.commands) do
                    if not tobool(string.find(cmdName, input:sub(2), 1, true)) then continue end
                    local btn = self.commandList:Add("liaButton")
                    btn:SetText("/" .. cmdName .. " - " .. (cmdInfo.desc ~= "" and L(cmdInfo.desc) or L("noDesc")))
                    btn:Dock(TOP)
                    btn:DockMargin(0, 0, 0, 2)
                    btn:SetTall(20)
                    btn.isSelected = false
                    btn.DoClick = function()
                        local syntax = L(cmdInfo.syntax or "")
                        self.text:SetText("/" .. cmdName .. " " .. syntax)
                        self.text:RequestFocus()
                        self.commandList:Remove()
                        self.commandList = nil
                        self.commandListCreateTime = nil
                    end

                    btn:SetTextColor(lia.color.theme.text or Color(255, 255, 255))
                    local originalPaint = btn.Paint
                    btn.Paint = function(s, w, h)
                        if originalPaint then originalPaint(s, w, h) end
                        local highlightColor = lia.color.theme.hover or Color(255, 255, 255, 30)
                        if s.isSelected then draw.RoundedBox(4, 0, 0, w, h, highlightColor) end
                    end
                end

                self.arguments = lia.command.extractArgs(input:sub(2))
            else
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
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
                if IsValid(self.entry) then self.entry:Remove() end
                self.entry = nil
                if IsValid(self.text) then self.text:KillFocus() end
                self.text = nil
                return true
            end

            if entry:GetText():sub(1, 1) == "/" and key == KEY_TAB and IsValid(self.commandList) then
                local canvas = self.commandList:GetCanvas()
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
                local selName = selected:GetText():match("^/([^ ]+)")
                if selName then
                    self.text:SetText("/" .. selName)
                    self.text:SetCaretPos(#self.text:GetText())
                end

                self.commandList:ScrollToChild(selected)
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
                    self.commandListCreateTime = nil
                end
            end

            entry:RequestFocus()
        end

        hook.Run("StartChat")
    end
end

function PANEL:addText(...)
    local markup = "<font=LiliaFont.20>"
    markup = hook.Run("ChatAddText", markup, ...) or markup
    for _, item in ipairs({...}) do
        if item and istable(item) and item.GetName and item.Width and item.Height then
            local matName = item:GetName()
            markup = markup .. "<img=" .. matName .. "," .. item:Width() .. "x" .. item:Height() .. ">"
        elseif IsColor(item) then
            markup = markup .. "<color=" .. item.r .. "," .. item.g .. "," .. item.b .. ">"
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
    local panel = self.scroll:Add("liaMarkupPanel")
    panel:SetWide(self:GetWide() - 16)
    panel:setMarkup(markup)
    panel.originalArgs = {...}
    panel.markupArgs = {
        markup = markup,
        arguments = {...},
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
            -- Show messages for a longer time and with better visibility
            local alpha = (1 - math.TimeFraction(p.start, p.finish, CurTime())) * 255
            p:SetAlpha(math.max(alpha, 0))
        end
    end

    self.list[#self.list + 1] = panel
    panel:SetPos(0, self.lastY)
    self.lastY = self.lastY + panel:GetTall() + 2
    -- Always auto-scroll to new messages, regardless of active state
    timer.Simple(0.01, function() if IsValid(self.scroll) and IsValid(panel) then self.scroll:ScrollToChild(panel) end end)
    -- Ensure the chat panel is visible when new messages arrive
    if not self.active then
        self:SetVisible(true)
        if IsValid(self.scroll) then self.scroll:SetVisible(true) end
        -- Briefly flash the chat to draw attention to new messages
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
            self.commandListCreateTime = nil
        end

        if IsValid(self.entry) then self.entry:Remove() end
        self.entry = nil
        if IsValid(self.text) then self.text:KillFocus() end
        self.text = nil
    end

    if not self.active then self:setScrollbarVisible(false) end
    if self.active and IsValid(self.text) and IsValid(self.commandList) then
        local textHasFocus = self.text:HasFocus()
        local currentText = self.text:GetText()
        local timeSinceCreation = self.commandListCreateTime and (CurTime() - self.commandListCreateTime) or 0
        local isTypingCommand = currentText:sub(1, 1) == "/"
        if not textHasFocus and not isTypingCommand and timeSinceCreation > 0.1 then
            self.commandList:Remove()
            self.commandList = nil
            self.commandListCreateTime = nil
        end
    end
end

function PANEL:Update()
    if IsValid(self) then
        self:Remove()
        vgui.Create("liaChatBox")
    end
end

function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    if IsValid(self.commandList) then
        local canvas = self.commandList:GetCanvas()
        if IsValid(canvas) then
            for _, child in ipairs(canvas:GetChildren()) do
                if IsValid(child) and child.SetTextColor then child:SetTextColor(lia.color.theme.text or Color(255, 255, 255)) end
            end
        end
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
        if item and istable(item) and item.GetName and item.Width and item.Height then
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
    panel:setMarkup(markup)
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
    end

    self:SetDraggable(false)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
    hook.Remove("OnThemeChanged", self)
end

vgui.Register("liaChatBox", PANEL, "liaFrame")
