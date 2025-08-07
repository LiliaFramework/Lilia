local PANEL = {}
function PANEL:Init()
    local border = 32
    local screenW, screenH = ScrW(), ScrH()
    local width, height = screenW * 0.4, screenH * 0.375
    lia.gui.chat = self
    self:SetSize(width, height)
    self:SetPos(border, screenH - height - border)
    self.active = false
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:SetTall(28)
    self.tabs:DockPadding(4, 4, 4, 4)
    self.tabs:SetVisible(false)
    self.commandIndex = 0
    self.commands = lia.command.list
    self.tabs.Paint = function(_, tabW, tabH)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, tabW, tabH)
    end

    self.arguments = {}
    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(4, 31)
    self.scroll:SetSize(width - 8, height - 66)
    self.scroll:GetVBar():SetWide(0)
    self.lastY = 0
    self.list = {}
    self.filtered = {}
    chat.GetChatBoxPos = function() return self:LocalToScreen(0, 0) end
    chat.GetChatBoxSize = function() return self:GetSize() end
    local seenFilters = {}
    for _, classData in SortedPairsByMemberValue(lia.chat.classes, "filter") do
        if not seenFilters[classData.filter] then
            self:addFilterButton(classData.filter)
            seenFilters[classData.filter] = true
        end
    end
end

function PANEL:Paint(panelW, panelH)
    if self.active then
        lia.util.drawBlur(self, 10)
        surface.SetDrawColor(250, 250, 250, 2)
        surface.DrawRect(0, 0, panelW, panelH)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawOutlinedRect(0, 0, panelW, panelH)
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
        self.text.OnEnter = function(entry)
            local input = entry:GetText()
            entry:Remove()
            self.tabs:SetVisible(false)
            self.active = false
            if IsValid(self.commandList) then
                self.commandList:Remove()
                self.commandList = nil
            end

            if IsValid(self.entry) then self.entry:Remove() end
            lia.gui.chat = nil
            if input:find("%S") then
                if not (lia.chat.lastLine or ""):find(input, 1, true) then
                    lia.chat.history[#lia.chat.history + 1] = input
                    lia.chat.lastLine = input
                end

                net.Start("msg")
                net.WriteString(input)
                net.SendToServer()
            end
        end

        self.text:SetAllowNonAsciiCharacters(true)
        self.text.Paint = function(entry, txtW, txtH)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, txtW, txtH)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawOutlinedRect(0, 0, txtW, txtH)
            entry:DrawTextEntryText(Color(255, 255, 255, 200), lia.config.get("Color"), Color(255, 255, 255, 200))
        end

        self.text.OnTextChanged = function(entry)
            local input = entry:GetText()
            hook.Run("ChatTextChanged", input)
            if input:sub(1, 1) == "/" then
                if IsValid(self.commandList) then
                    self.commandList:Remove()
                    self.commandList = nil
                end

                self.commandList = self:Add("DScrollPanel")
                self.commandList:SetPos(4, 31)
                self.commandList:SetSize(self:GetWide() - 8, self:GetTall() - 66)
                self.commandList:GetVBar():SetWide(8)
                for cmdName, cmdInfo in SortedPairs(self.commands) do
                    if not tobool(string.find(cmdName, input:sub(2), 1, true)) then continue end
                    local btn = self.commandList:Add("DButton")
                    btn:SetText("/" .. cmdName .. " - " .. (cmdInfo.desc ~= "" and L(cmdInfo.desc) or L("noDesc")))
                    btn:Dock(TOP)
                    btn:DockMargin(0, 0, 0, 2)
                    btn:SetTall(20)
                    btn.Paint = function(_, bw, bh)
                        surface.SetDrawColor(ColorAlpha(color_black, 200))
                        surface.DrawRect(0, 0, bw, bh)
                    end

                    btn.DoClick = function()
                        local syntax = L(cmdInfo.syntax or "")
                        self.text:SetText("/" .. cmdName .. " " .. syntax)
                        self.text:RequestFocus()
                        self.commandList:Remove()
                        self.commandList = nil
                    end
                end

                self.arguments = lia.command.extractArgs(input:sub(2))
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
        self.text.OnKeyCodeTyped = function(entry, key)
            if key == KEY_ESCAPE and IsValid(self.commandList) then
                self.commandList:Remove()
                self.commandList = nil
                return true
            end

            if entry:GetText():sub(1, 1) == "/" and key == KEY_TAB and IsValid(self.commandList) then
                local canvasChildren = self.commandList:GetCanvas():GetChildren()
                if #canvasChildren > 0 then
                    self.commandIndex = (self.commandIndex or 0) + 1
                    if self.commandIndex > #canvasChildren then self.commandIndex = 1 end
                    for idx, listChild in ipairs(canvasChildren) do
                        listChild.commandIndex = idx
                        if not listChild.PaintConfigured then
                            listChild.Paint = function(btn, bw, bh)
                                local isSel = btn.commandIndex == self.commandIndex
                                surface.SetDrawColor(isSel and ColorAlpha(lia.config.get("Color"), 255) or ColorAlpha(color_black, 200))
                                surface.DrawRect(0, 0, bw, bh)
                                if IsValid(btn.text) then btn.text:SetTextColor(isSel and ColorAlpha(lia.config.get("Color"), 255) or ColorAlpha(color_white, 200)) end
                            end

                            listChild.PaintConfigured = true
                        end
                    end

                    local selected = canvasChildren[self.commandIndex]
                    if IsValid(selected) then
                        local selName = selected:GetText():match("^/([^ ]+)")
                        self.text:SetText("/" .. (selName or ""))
                        self.text:SetCaretPos(#self.text:GetText())
                        self.text:RequestFocus()
                    end
                end
                return true
            end
            return DTextEntry.OnKeyCodeTyped(entry, key)
        end

        self.text.OnLoseFocus = function(entry)
            if IsValid(self.commandList) then
                self.commandList:Remove()
                self.commandList = nil
            end

            entry:RequestFocus()
        end

        hook.Run("StartChat")
    end
end

local function OnDrawText(txt, fontName, xPos, yPos, clr, _, _, alpha)
    alpha = alpha or 255
    surface.SetTextPos(xPos + 1, yPos + 1)
    surface.SetTextColor(0, 0, 0, alpha)
    surface.SetFont(fontName)
    surface.DrawText(txt)
    surface.SetTextPos(xPos, yPos)
    surface.SetTextColor(clr.r, clr.g, clr.b, alpha)
    surface.SetFont(fontName)
    surface.DrawText(txt)
end

local function PaintFilterButton(btn, btnW, btnH)
    if btn.active then
        surface.SetDrawColor(40, 40, 40)
    else
        local alpha = 120 + math.cos(RealTime() * 5) * 10
        surface.SetDrawColor(ColorAlpha(lia.config.get("Color"), alpha))
    end

    surface.DrawRect(0, 0, btnW, btnH)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawOutlinedRect(0, 0, btnW, btnH)
end

function PANEL:addFilterButton(filter)
    local tab = self.tabs:Add("DButton")
    tab:SetFont("liaChatFont")
    tab:SetText(L(filter):upper())
    tab:SizeToContents()
    tab:DockMargin(0, 0, 3, 0)
    tab:SetWide(tab:GetWide() + 32)
    tab:Dock(LEFT)
    tab:SetTextColor(color_white)
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 200))
    tab.Paint = PaintFilterButton
    tab.DoClick = function(selfBtn)
        selfBtn.active = not selfBtn.active
        local filters = LIA_CVAR_CHATFILTER:GetString():lower()
        if filters == "none" then filters = "" end
        if selfBtn.active then
            filters = filters .. filter .. ","
        else
            filters = filters:gsub(filter .. "[,]", "")
            if not filters:find("%S") then filters = "none" end
        end

        self:setFilter(filter, selfBtn.active)
        RunConsoleCommand("lia_chatfilter", filters)
    end

    if LIA_CVAR_CHATFILTER:GetString():lower():find(filter) then tab.active = true end
end

function PANEL:addText(...)
    local markup = "<font=liaChatFont>"
    if CHAT_CLASS then markup = "<font=" .. (CHAT_CLASS.font or "liaChatFont") .. ">" end
    markup = hook.Run("ChatAddText", markup, ...) or markup
    for _, item in ipairs({...}) do
        if type(item) == "IMaterial" then
            local matName = item:GetName()
            markup = markup .. "<img=" .. matName .. "," .. item:Width() .. "x" .. item:Height() .. ">"
        elseif IsColor(item) then
            markup = markup .. "<color=" .. item.r .. "," .. item.g .. "," .. item.b .. ">"
        elseif type(item) == "Player" then
            local clr = team.GetColor(item:Team())
            markup = markup .. "<color=" .. clr.r .. "," .. clr.g .. "," .. clr.b .. ">" .. item:Name():gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("#", "\226\128\139#")
        else
            local str = tostring(item):gsub("<", "&lt;"):gsub(">", "&gt;")
            markup = markup .. str:gsub("%b**", function(val)
                local inner = val:sub(2, -2)
                if inner:find("%S") then return "<font=liaChatFontItalics>" .. inner .. "</font>" end
            end)
        end
    end

    markup = markup .. "</font>"
    local panel = self.scroll:Add("liaMarkupPanel")
    panel:SetWide(self:GetWide() - 8)
    panel:setMarkup(markup, OnDrawText)
    panel.start = CurTime() + 15
    panel.finish = panel.start + 20
    panel.Think = function(p) p:SetAlpha(self.active and 255 or (1 - math.TimeFraction(p.start, p.finish, CurTime())) * 255) end
    self.list[#self.list + 1] = panel
    local cls = CHAT_CLASS and CHAT_CLASS.filter and CHAT_CLASS.filter:lower() or "ic"
    panel.filter = cls
    if LIA_CVAR_CHATFILTER:GetString():lower():find(cls) then
        self.filtered[panel] = cls
        panel:SetVisible(false)
    else
        panel:SetPos(0, self.lastY)
        self.lastY = self.lastY + panel:GetTall()
        self.scroll:ScrollToChild(panel)
    end
    return panel:IsVisible()
end

function PANEL:setFilter(filter, state)
    if state then
        for _, pnl in ipairs(self.list) do
            if pnl.filter == filter then
                pnl:SetVisible(false)
                self.filtered[pnl] = filter
            end
        end
    else
        for pnl, f in pairs(self.filtered) do
            if f == filter then
                pnl:SetVisible(true)
                self.filtered[pnl] = nil
            end
        end
    end

    self.lastY = 0
    local lastChild
    for _, pnl in ipairs(self.list) do
        if pnl:IsVisible() then
            pnl:SetPos(0, self.lastY)
            self.lastY = self.lastY + pnl:GetTall() + 2
            lastChild = pnl
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
