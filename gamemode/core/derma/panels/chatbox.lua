local PANEL = {}
function PANEL:Init()
    local border = 32
    local w, h = ScrW() * 0.4, ScrH() * 0.375
    lia.gui.chat = self
    self:SetSize(w, h)
    self:SetPos(border, ScrH() - h - border)
    self.active = false
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:SetTall(28)
    self.tabs:DockPadding(4, 4, 4, 4)
    self.tabs:SetVisible(false)
    self.commandIndex = 0
    self.commands = lia.command.list
    self.tabs.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    self.arguments = {}
    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(4, 31)
    self.scroll:SetSize(w - 8, h - 66)
    self.scroll:GetVBar():SetWide(0)
    self.lastY = 0
    self.list = {}
    self.filtered = {}
    chat.GetChatBoxPos = function() return self:LocalToScreen(0, 0) end
    chat.GetChatBoxSize = function() return self:GetSize() end
    local buttons = {}
    for _, v in SortedPairsByMemberValue(lia.chat.classes, "filter") do
        if not buttons[v.filter] then
            self:addFilterButton(v.filter)
            buttons[v.filter] = true
        end
    end
end

function PANEL:Paint(w, h)
    if self.active then
        lia.util.drawBlur(self, 10)
        surface.SetDrawColor(250, 250, 250, 2)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

function PANEL:setActive(state)
    self.active = state
    if state then
        self.entry = self:Add("EditablePanel")
        self.entry:SetPos(self.x + 4, self.y + self:GetTall() - 32)
        self.entry:SetWide(self:GetWide() - 8)
        self.entry.OnRemove = function() hook.Run("FinishChat") end
        self.entry:SetTall(28)
        lia.chat.history = lia.chat.history or {}
        self.text = self.entry:Add("DTextEntry")
        self.text:Dock(FILL)
        self.text.History = lia.chat.history
        self.text:SetHistoryEnabled(true)
        self.text:DockMargin(0, 0, 0, 0)
        self.text:SetFont("liaChatFont")
        self.text.OnEnter = function(this)
            local text = this:GetText()
            this:Remove()
            self.tabs:SetVisible(false)
            self.active = false
            if IsValid(self.commandList) then
                self.commandList:Remove()
                self.commandList = nil
            end

            if IsValid(self.entry) then self.entry:Remove() end
            lia.gui.chat = nil
            if text:find("%S") then
                if not (lia.chat.lastLine or ""):find(text, 1, true) then
                    lia.chat.history[#lia.chat.history + 1] = text
                    lia.chat.lastLine = text
                end

                net.Start("msg")
                net.WriteString(text)
                net.SendToServer()
            end
        end

        self.text:SetAllowNonAsciiCharacters(true)
        self.text.Paint = function(this, w, h)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawOutlinedRect(0, 0, w, h)
            this:DrawTextEntryText(Color(255, 255, 255, 200), lia.config.get("Color"), Color(255, 255, 255, 200))
        end

        self.text.OnTextChanged = function(this)
            local text = this:GetText()
            hook.Run("ChatTextChanged", text)
            if text:sub(1, 1) == "/" then
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                end

                self.commandList = self:Add("DScrollPanel")
                self.commandList:SetPos(4, 31)
                self.commandList:SetSize(self:GetWide() - 8, self:GetTall() - 66)
                self.commandList:GetVBar():SetWide(8)
                for commandName, commandData in SortedPairs(self.commands) do
                    if not tobool(commandName:find(text:sub(2))) then continue end
                    local commandButton = self.commandList:Add("DButton")
                    commandButton:SetText("/" .. commandName .. " - " .. (commandData.desc or L("noDesc")))
                    commandButton:Dock(TOP)
                    commandButton:DockMargin(0, 0, 0, 2)
                    commandButton:SetTall(20)
                    commandButton.Paint = function(_, w, h)
                        surface.SetDrawColor(ColorAlpha(color_black, 200))
                        surface.DrawRect(0, 0, w, h)
                    end

                    commandButton.DoClick = function()
                        local commandData = self.commands[commandName]
                        local syntaxPreview = commandData and commandData.syntax or ""
                        self.text:SetText("/" .. commandName .. " " .. syntaxPreview)
                        self.text:RequestFocus()
                        self.commandList:Remove()
                        self.commandList = nil
                    end
                end

                self.arguments = lia.command.extractArgs(text:sub(2))
            else
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                end

                self.commandIndex = 0
            end
        end

        self.entry:MakePopup()
        self.text:RequestFocus()
        self.tabs:SetVisible(true)
        self.text.OnKeyCodeTyped = function(this, key)
            if key == KEY_ESCAPE and IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                    return true
            end

            if this:GetText():sub(1, 1) == "/" and key == KEY_TAB and IsValid(self.commandList) then
                local children = self.commandList:GetCanvas():GetChildren()
                if #children > 0 then
                    self.commandIndex = (self.commandIndex or 0) + 1
                    if self.commandIndex > #children then self.commandIndex = 1 end
                    for i, child in ipairs(children) do
                        child.commandIndex = i
                        if not child.PaintConfigured then
                            child.Paint = function(this, w, h)
                                local isSelected = this.commandIndex == self.commandIndex
                                surface.SetDrawColor(isSelected and ColorAlpha(lia.config.get("Color"), 255) or ColorAlpha(color_black, 200))
                                surface.DrawRect(0, 0, w, h)
                                if IsValid(this.text) then this.text:SetTextColor(isSelected and ColorAlpha(lia.config.get("Color"), 255) or ColorAlpha(color_white, 200)) end
                            end

                            child.PaintConfigured = true
                        end
                    end

                    local selectedCommand = children[self.commandIndex]
                    if IsValid(selectedCommand) then
                        local commandName = selectedCommand:GetText():match("^/([^ ]+)")
                        local commandData = self.commands[commandName]
                        local syntaxPreview = commandData and commandData.syntax or ""
                        self.text:SetText("/" .. commandName .. " " .. syntaxPreview)
                        self.text:SetCaretPos(#self.text:GetText())
                        self.text:RequestFocus()
                    end
                end
                return true
            end
            return DTextEntry.OnKeyCodeTyped(this, key)
        end

        self.text.OnLoseFocus = function(this)
            if IsValid(self.commandList) then
                self.commandList:Remove()
                self.commandList = nil
            end

            this:RequestFocus()
        end

        hook.Run("StartChat")
    end
end

local function OnDrawText(text, font, x, y, color, _, _, alpha)
    alpha = alpha or 255
    surface.SetTextPos(x + 1, y + 1)
    surface.SetTextColor(0, 0, 0, alpha)
    surface.SetFont(font)
    surface.DrawText(text)
    surface.SetTextPos(x, y)
    surface.SetTextColor(color.r, color.g, color.b, alpha)
    surface.SetFont(font)
    surface.DrawText(text)
end

local function PaintFilterButton(this, w, h)
    if this.active then
        surface.SetDrawColor(40, 40, 40)
    else
        local alpha = 120 + math.cos(RealTime() * 5) * 10
        surface.SetDrawColor(ColorAlpha(lia.config.get("Color"), alpha))
    end

    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:addFilterButton(filter)
    local name = L(filter)
    local tab = self.tabs:Add("DButton")
    tab:SetFont("liaChatFont")
    tab:SetText(name:upper())
    tab:SizeToContents()
    tab:DockMargin(0, 0, 3, 0)
    tab:SetWide(tab:GetWide() + 32)
    tab:Dock(LEFT)
    tab:SetTextColor(color_white)
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 200))
    tab.Paint = PaintFilterButton
    tab.DoClick = function(this)
        this.active = not this.active
        local filters = LIA_CVAR_CHATFILTER:GetString():lower()
        if filters == "none" then filters = "" end
        if this.active then
            filters = filters .. filter .. ","
        else
            filters = filters:gsub(filter .. "[,]", "")
            if not filters:find("%S") then filters = "none" end
        end

        self:setFilter(filter, this.active)
        RunConsoleCommand("lia_chatfilter", filters)
    end

    if LIA_CVAR_CHATFILTER:GetString():lower():find(filter) then tab.active = true end
end

function PANEL:addText(...)
    local text = "<font=liaChatFont>"
    if CHAT_CLASS then text = "<font=" .. (CHAT_CLASS.font or "liaChatFont") .. ">" end
    text = hook.Run("ChatAddText", text, ...) or text
    for _, v in ipairs({...}) do
        if type(v) == "IMaterial" then
            local ttx = v:GetName()
            text = text .. "<img=" .. ttx .. "," .. v:Width() .. "x" .. v:Height() .. ">"
        elseif IsColor(v) and v.r and v.g and v.b then
            text = text .. "<color=" .. v.r .. "," .. v.g .. "," .. v.b .. ">"
        elseif type(v) == "Player" then
            local color = team.GetColor(v:Team())
            text = text .. "<color=" .. color.r .. "," .. color.g .. "," .. color.b .. ">" .. v:Name():gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("#", "\226\128\139#")
        else
            text = text .. tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
            text = text:gsub("%b**", function(value)
                local inner = value:sub(2, -2)
                if inner:find("%S") then return "<font=liaChatFontItalics>" .. value:sub(2, -2) .. "</font>" end
            end)
        end
    end

    text = text .. "</font>"
    local panel = self.scroll:Add("liaMarkupPanel")
    panel:SetWide(self:GetWide() - 8)
    panel:setMarkup(text, OnDrawText)
    panel.start = CurTime() + 15
    panel.finish = panel.start + 20
    panel.Think = function(this)
        if self.active then
            this:SetAlpha(255)
        else
            this:SetAlpha((1 - math.TimeFraction(this.start, this.finish, CurTime())) * 255)
        end
    end

    self.list[#self.list + 1] = panel
    local class = CHAT_CLASS and CHAT_CLASS.filter and CHAT_CLASS.filter:lower() or "ic"
    if LIA_CVAR_CHATFILTER:GetString():lower():find(class) then
        self.filtered[panel] = class
        panel:SetVisible(false)
    else
        panel:SetPos(0, self.lastY)
        self.lastY = self.lastY + panel:GetTall()
        self.scroll:ScrollToChild(panel)
    end

    panel.filter = class
    return panel:IsVisible()
end

function PANEL:setFilter(filter, state)
    if state then
        for _, v in ipairs(self.list) do
            if v.filter == filter then
                v:SetVisible(false)
                self.filtered[v] = filter
            end
        end
    else
        for k, v in pairs(self.filtered) do
            if v == filter then
                k:SetVisible(true)
                self.filtered[k] = nil
            end
        end
    end

    self.lastY = 0
    local lastChild
    for _, v in ipairs(self.list) do
        if v:IsVisible() then
            v:SetPos(0, self.lastY)
            self.lastY = self.lastY + v:GetTall() + 2
            lastChild = v
        end
    end

    if IsValid(lastChild) then self.scroll:ScrollToChild(lastChild) end
end

function PANEL:Think()
    if gui.IsGameUIVisible() and self.active then
        self.tabs:SetVisible(false)
        self.active = false
        if IsValid(self.entry) then self.entry:Remove() end
    end

    if self.active and IsValid(self.text) and not self.text:HasFocus() and IsValid(self.commandList) then
        self.commandList:Remove()
        self.commandList = nil
    end
end

vgui.Register("liaChatBox", PANEL, "DPanel")
