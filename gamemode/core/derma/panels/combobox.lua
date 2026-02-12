local PANEL = {}
function PANEL:Init()
    self.choices = {}
    self.selected = nil
    self.opened = false
    self:SetText("")
    self.font = "LiliaFont.18"
    self.hoverAnim = 0
    self.OnSelect = function() end
    self.OnMenuOpened = function() end
    self.btn = vgui.Create("DButton", self)
    self.btn:Dock(FILL)
    self.btn:SetText("")
    self.btn:SetCursor("hand")
    self.btn.Paint = function(_, w, h)
        if not IsValid(self) then return end
        if self.btn:IsHovered() then
            self.hoverAnim = math.Clamp(self.hoverAnim + FrameTime() * 4, 0, 1)
        else
            self.hoverAnim = math.Clamp(self.hoverAnim - FrameTime() * 8, 0, 1)
        end

        local bgColor = Color(25, 28, 35, 250)
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        local base = ColorAlpha(bgColor, 200)
        if self.btn.Depressed then
            base = ColorAlpha(accentColor, 220)
        elseif self.btn.Hovered then
            base = ColorAlpha(accentColor, 180)
        end

        lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
        local outline = accentColor or ColorAlpha(Color(255, 255, 255), 30)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(outline):Outline(1):Draw()
        draw.SimpleText(self.selected or self.placeholder or "", self.font, 12, h * 0.5, self:GetTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local arrowSize = 6
        local arrowX = w - 16
        local arrowY = h / 2
        local arrowColor = ColorAlpha(lia.color.theme.text, 180 + self.hoverAnim * 75)
        surface.SetDrawColor(arrowColor)
        draw.NoTexture()
        if not self.opened then
            surface.DrawPoly({
                {
                    x = arrowX - arrowSize,
                    y = arrowY - arrowSize / 2
                },
                {
                    x = arrowX + arrowSize,
                    y = arrowY - arrowSize / 2
                },
                {
                    x = arrowX,
                    y = arrowY + arrowSize / 2
                }
            })
        end
    end

    self.btn.DoClick = function()
        if not IsValid(self) then return end
        if self.opened then
            self:CloseMenu()
        else
            self:OpenMenu()
            lia.websound.playButtonSound()
        end
    end
end

function PANEL:AddChoice(text, data, tooltip)
    table.insert(self.choices, {
        text = text,
        data = data,
        tooltip = tooltip
    })

    if not self.opened then
        self:AutoSize()
        self:RefreshDropdown()
    else
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:AddSpacer(text)
    table.insert(self.choices, {
        text = text or "",
        data = nil,
        spacer = true
    })

    if not self.opened then
        self:AutoSize()
        self:RefreshDropdown()
    else
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:SetValue(val)
    self.selected = val
end

function PANEL:ChooseOption(text, index)
    if not IsValid(self) then return end
    self.selected = text
    if self.convar then RunConsoleCommand(self.convar, tostring(text)) end
    if self.OnSelect then
        local actualIndex = index or 0
        local choiceData = nil
        if actualIndex > 0 and self.choices[actualIndex] then choiceData = self.choices[actualIndex].data end
        self:OnSelect(actualIndex, text, choiceData)
    end
end

function PANEL:ChooseOptionID(index)
    local choice = self.choices[index]
    if not choice then return end
    self:ChooseOption(choice.text, index)
end

function PANEL:ChooseOptionData(data)
    for i, choice in ipairs(self.choices) do
        if choice.data == data then
            self:ChooseOption(choice.text, i)
            return
        end
    end
end

function PANEL:GetValue()
    return self.selected
end

function PANEL:SetPlaceholder(text)
    self.placeholder = text
end

function PANEL:Clear()
    self.choices = {}
    self.selected = nil
    if IsValid(self.menu) then self.menu:Remove() end
end

function PANEL:OpenMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    local menuPadding = 6
    local itemHeight = 32
    local numChoices = #self.choices
    local calculatedHeight = numChoices * (itemHeight + 2) + (menuPadding * 2) + 2
    surface.SetFont(self.font)
    local maxTextWidth = 0
    for _, choice in ipairs(self.choices) do
        local textWidth = surface.GetTextSize(choice.text)
        if textWidth > maxTextWidth then maxTextWidth = textWidth end
    end

    local optimalWidth = math.max(self:GetWide(), maxTextWidth + 40)
    local menuWidth = math.min(optimalWidth, ScrW() * 0.4)
    local sx, sy = self:LocalToScreen(0, self:GetTall())
    local spaceBelow = ScrH() - sy - 10
    local spaceAbove = (sy - self:GetTall()) - 10
    local maxAvailable = math.max(spaceBelow, spaceAbove)
    local menuHeight = math.Clamp(calculatedHeight, 0, math.max(0, maxAvailable))
    local needsScroll = calculatedHeight > menuHeight
    if needsScroll then
        self.menu = vgui.Create("liaScrollPanel")
        self.menu:SetSize(menuWidth, menuHeight)
        local x, y = sx, sy
        if spaceBelow < menuHeight then y = sy - menuHeight - self:GetTall() end
        self.menu:SetPos(x, y)
        self.menu:SetDrawOnTop(true)
        self.menu:MakePopup()
        self.menu:SetKeyboardInputEnabled(false)
        self.menu.Paint = function(_, w, h)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        local canvas = self.menu:GetCanvas()
        if IsValid(canvas) then canvas:DockPadding(menuPadding, menuPadding, menuPadding, menuPadding) end
        surface.SetFont(self.font)
        for i, choice in ipairs(self.choices) do
            if choice.spacer then
                local spacer = self.menu:Add("DPanel")
                spacer:Dock(TOP)
                spacer:DockMargin(2, 2, 2, 0)
                spacer:SetTall(8)
                spacer.Paint = function(_, w, h)
                    if not IsValid(self) then return end
                    surface.SetDrawColor(lia.color.theme.text:Unpack())
                    surface.DrawRect(0, h * 0.5 - 1, w, 2)
                end
            else
                local option = self.menu:Add("DButton")
                option:SetText("")
                option:Dock(TOP)
                option:DockMargin(2, 2, 2, 0)
                option:SetTall(itemHeight)
                option:SetCursor("hand")
                if choice.tooltip and choice.tooltip ~= "" then option:SetTooltip(choice.tooltip) end
                option.Paint = function(s, w, h)
                    if not IsValid(self) then return end
                    local isSelected = self.selected == choice.text
                    local isHovered = s:IsHovered()
                    if isSelected then
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(25, 28, 35, 220)):Shape(lia.derma.SHAPE_IOS):Draw()
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(ColorAlpha(lia.color.theme.theme or Color(116, 185, 255), 50)):Shape(lia.derma.SHAPE_IOS):Draw()
                    elseif isHovered then
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
                    end

                    local textColor = isSelected and lia.color.theme.text_entry or lia.color.theme.text
                    draw.SimpleText(choice.text, "LiliaFont.18", 14, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                option.DoClick = function()
                    if not IsValid(self) then return end
                    self:ChooseOption(choice.text, i)
                    self:CloseMenu()
                    lia.websound.playButtonSound()
                end
            end
        end
    else
        menuHeight = (numChoices * (itemHeight + 2)) + (menuPadding * 2) + 2
        self.menu = vgui.Create("DPanel")
        self.menu:SetSize(menuWidth, menuHeight)
        local x, y = sx, sy
        if spaceBelow < menuHeight then y = sy - menuHeight - self:GetTall() end
        self.menu:SetPos(x, y)
        self.menu:SetDrawOnTop(true)
        self.menu:MakePopup()
        self.menu:SetKeyboardInputEnabled(false)
        self.menu:DockPadding(menuPadding, menuPadding, menuPadding, menuPadding)
        self.menu.Paint = function(_, w, h)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        surface.SetFont(self.font)
        for i, choice in ipairs(self.choices) do
            if choice.spacer then
                local spacer = vgui.Create("DPanel", self.menu)
                spacer:Dock(TOP)
                spacer:DockMargin(2, 2, 2, 0)
                spacer:SetTall(8)
                spacer.Paint = function(_, w, h)
                    if not IsValid(self) then return end
                    surface.SetDrawColor(lia.color.theme.text:Unpack())
                    surface.DrawRect(0, h * 0.5 - 1, w, 2)
                end
            else
                local option = vgui.Create("DButton", self.menu)
                option:SetText("")
                option:Dock(TOP)
                option:DockMargin(2, 2, 2, 0)
                option:SetTall(itemHeight)
                option:SetCursor("hand")
                if choice.tooltip and choice.tooltip ~= "" then option:SetTooltip(choice.tooltip) end
                option.Paint = function(s, w, h)
                    if not IsValid(self) then return end
                    local isSelected = self.selected == choice.text
                    local isHovered = s:IsHovered()
                    if isSelected then
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(25, 28, 35, 220)):Shape(lia.derma.SHAPE_IOS):Draw()
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(ColorAlpha(lia.color.theme.theme or Color(116, 185, 255), 50)):Shape(lia.derma.SHAPE_IOS):Draw()
                    elseif isHovered then
                        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
                    end

                    local textColor = isSelected and lia.color.theme.text_entry or lia.color.theme.text
                    draw.SimpleText(choice.text, "LiliaFont.18", 14, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                option.DoClick = function()
                    if not IsValid(self) then return end
                    self:ChooseOption(choice.text, i)
                    self:CloseMenu()
                    lia.websound.playButtonSound()
                end
            end
        end
    end

    self.opened = true
    local oldMouseDown = false
    if IsValid(self.menu) then
        self.menu.Think = function()
            if not IsValid(self.menu) or not self.menu:IsVisible() then return end
            local mouseDown = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)
            if mouseDown and not oldMouseDown then
                local mx, my = gui.MousePos()
                local menuX, menuY = self.menu:LocalToScreen(0, 0)
                if not (mx >= menuX and mx <= menuX + self.menu:GetWide() and my >= menuY and my <= menuY + self.menu:GetTall()) then self:CloseMenu() end
            end

            oldMouseDown = mouseDown
        end

        self.menu.OnRemove = function() if IsValid(self) then self.opened = false end end
        if self.OnMenuOpened then self:OnMenuOpened() end
    end
end

function PANEL:CloseMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    if IsValid(self) then self.opened = false end
end

function PANEL:OnRemove()
    if IsValid(self) then self:CloseMenu() end
end

function PANEL:GetOptionData(index)
    return self.choices[index] and self.choices[index].data or nil
end

function PANEL:GetOptionText(index)
    return self.choices[index] and self.choices[index].text or nil
end

function PANEL:GetOptionTextByData(data)
    for _, choice in ipairs(self.choices) do
        if choice.data == data then return choice.text end
    end
    return nil
end

function PANEL:SetConVar(cvar)
    self.convar = cvar
end

function PANEL:GetSelectedID()
    if not self.selected then return nil end
    for i, choice in ipairs(self.choices) do
        if choice.text == self.selected then return i end
    end
end

function PANEL:GetSelectedData()
    local id = self:GetSelectedID()
    return id and self:GetOptionData(id) or nil
end

function PANEL:CheckConVarChanges()
    if not self.convar then return end
    local convar = GetConVar(self.convar)
    if convar then
        local convarValue = convar:GetString()
        if convarValue and convarValue ~= self.selected then self.selected = convarValue end
    end
end

function PANEL:GetSelectedText()
    return self.selected
end

function PANEL:GetSelected()
    return self.selected
end

function PANEL:GetSortItems()
    return self.sortItems or false
end

function PANEL:SetSortItems(sort)
    self.sortItems = sort or false
    if self.sortItems then table.sort(self.choices, function(a, b) return a.text < b.text end) end
end

function PANEL:RemoveChoice(indexOrValue)
    if isnumber(indexOrValue) then
        if indexOrValue >= 1 and indexOrValue <= #self.choices then table.remove(self.choices, indexOrValue) end
    else
        for i, choice in ipairs(self.choices) do
            if choice.text == indexOrValue then
                table.remove(self.choices, i)
                break
            end
        end
    end

    if not self.opened then
        self:AutoSize()
        self:RefreshDropdown()
    else
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:IsMenuOpen()
    return self.opened
end

function PANEL:SetFont(font)
    self.font = font
    self:AutoSize()
    self:RefreshDropdown()
end

function PANEL:RefreshDropdown()
    if IsValid(self.menu) and self.opened then
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:AutoSize()
    surface.SetFont(self.font)
    local _, fontHeight = surface.GetTextSize("Ag")
    local padding = 12
    local optimalHeight = fontHeight + padding
    if not self.userSetHeight then self:SetTall(optimalHeight, true) end
    if #self.choices == 0 then return end
    local maxTextWidth = 0
    for _, choice in ipairs(self.choices) do
        local textWidth = surface.GetTextSize(choice.text)
        if textWidth > maxTextWidth then maxTextWidth = textWidth end
    end

    local optimalWidth = math.max(150, maxTextWidth + 50)
    local cappedWidth = math.min(optimalWidth, ScrW() * 0.5)
    if cappedWidth > self:GetWide() then
        self:SetWide(cappedWidth)
        local parent = self:GetParent()
        if parent then
            if parent.InvalidateLayout then parent:InvalidateLayout() end
            local grandparent = parent:GetParent()
            if grandparent and grandparent.InvalidateLayout then grandparent:InvalidateLayout() end
        end
    end
end

function PANEL:FinishAddingOptions()
    self:RefreshDropdown()
    local parent = self:GetParent()
    if not (parent and parent.ClassName == "DPanel" and self:GetDock() == TOP) then self:AutoSize() end
end

function PANEL:SetTall(tall, internal)
    local meta = getmetatable(self)
    local baseSetTall = nil
    if meta and meta.BaseClass and meta.BaseClass.SetTall then
        baseSetTall = meta.BaseClass.SetTall
    elseif self.BaseClass and self.BaseClass.SetTall then
        baseSetTall = self.BaseClass.SetTall
    else
        local panelTable = vgui.GetControlTable("Panel")
        if panelTable and panelTable.SetTall then baseSetTall = panelTable.SetTall end
    end

    if baseSetTall then
        baseSetTall(self, tall)
    else
        self:SetSize(self:GetWide(), tall)
    end

    if not internal then self.userSetHeight = true end
end

function PANEL:RecalculateSize()
    self:AutoSize()
end

function PANEL:PostInit()
    if not self.postInitDone then
        self:AutoSize()
        self.postInitDone = true
    end
end

function PANEL:SetTextColor(color)
    self.textColor = color
end

function PANEL:GetTextColor()
    return self.textColor or lia.color.theme.text
end

vgui.Register("liaComboBox", PANEL, "Panel")
