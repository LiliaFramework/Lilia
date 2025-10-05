local PANEL = {}
function PANEL:Init()
    self.choices = {}
    self.selected = nil
    self.opened = false
    self:SetTall(26)
    self:SetText("")
    self.font = "Fated.18"
    self.hoverAnim = 0
    self.OnSelect = function() end
    self.btn = vgui.Create("DButton", self)
    self.btn:Dock(FILL)
    self.btn:SetText("")
    self.btn:SetCursor("hand")
    self.btn.Paint = function(_, w, h)
        if self.btn:IsHovered() then
            self.hoverAnim = math.Clamp(self.hoverAnim + FrameTime() * 4, 0, 1)
        else
            self.hoverAnim = math.Clamp(self.hoverAnim - FrameTime() * 8, 0, 1)
        end

        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.focus_panel):Shape(lia.derma.SHAPE_IOS):Draw()
        if self.hoverAnim > 0 then lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(lia.color.theme.button_hovered.r, lia.color.theme.button_hovered.g, lia.color.theme.button_hovered.b, self.hoverAnim * 255)):Shape(lia.derma.SHAPE_IOS):Draw() end
        draw.SimpleText(self.selected or self.placeholder or L("choose"), self.font, 12, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
        if self.opened then
            self:CloseMenu()
        else
            self:OpenMenu()
            surface.PlaySound("button_click.wav")
        end
    end
end

function PANEL:AddChoice(text, data)
    table.insert(self.choices, {
        text = text,
        data = data
    })

    -- Force UI refresh after adding choices to ensure proper sizing
    if IsValid(self.menu) and self.opened then
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:SetValue(val)
    self.selected = val
end

function PANEL:ChooseOption(text, index)
    self.selected = text
    if self.convar then RunConsoleCommand(self.convar, tostring(text)) end
    if self.OnSelect then
        local actualIndex = index or 0
        local choiceData = nil
        if actualIndex > 0 and self.choices[actualIndex] then choiceData = self.choices[actualIndex].data end
        self.OnSelect(actualIndex, text, choiceData)
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
    local itemHeight = 26
    local maxMenuHeight = 200 -- Maximum height before scrolling
    local numChoices = #self.choices
    -- Calculate optimal width based on option text lengths
    surface.SetFont(self.font)
    local maxTextWidth = 0
    for _, choice in ipairs(self.choices) do
        local textWidth = surface.GetTextSize(choice.text)
        if textWidth > maxTextWidth then maxTextWidth = textWidth end
    end

    -- Add padding for text and ensure minimum width
    local optimalWidth = math.max(self:GetWide(), maxTextWidth + 40) -- 40px padding for text
    local menuWidth = math.min(optimalWidth, ScrW() * 0.4) -- Cap at 40% of screen width
    -- Calculate if we need scrolling
    local needsScroll = numChoices * (itemHeight + 2) > maxMenuHeight - (menuPadding * 2) - 2
    if needsScroll then
        -- Use scroll panel for many options
        self.menu = vgui.Create("liaScrollPanel")
        self.menu:SetSize(menuWidth, maxMenuHeight)
        local x, y = self:LocalToScreen(0, self:GetTall())
        if y + maxMenuHeight > ScrH() - 10 then y = y - maxMenuHeight - self:GetTall() end
        self.menu:SetPos(x, y)
        self.menu:SetDrawOnTop(true)
        self.menu:MakePopup()
        self.menu:SetKeyboardInputEnabled(false)
        -- Create a container for the options
        local container = vgui.Create("DPanel", self.menu)
        container:Dock(FILL)
        container:DockPadding(menuPadding, menuPadding, menuPadding, menuPadding)
        container.Paint = function(_, w, h)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        surface.SetFont(self.font)
        for i, choice in ipairs(self.choices) do
            local option = vgui.Create("DButton", container)
            option:SetText("")
            option:Dock(TOP)
            option:DockMargin(2, 2, 2, 0)
            option:SetTall(itemHeight)
            option:SetCursor("hand")
            option.Paint = function(s, w, h)
                local isSelected = self.selected == choice.text
                local isHovered = s:IsHovered()
                -- Draw background for selected option (full box)
                if isSelected then
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.theme):Shape(lia.derma.SHAPE_IOS):Draw()
                elseif isHovered then
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
                end

                -- Draw text
                local textColor = isSelected and lia.color.theme.text_entry or lia.color.theme.text
                draw.SimpleText(choice.text, "Fated.18", 14, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            option.DoClick = function()
                self:ChooseOption(choice.text, i)
                self:CloseMenu()
                surface.PlaySound("button_click.wav")
            end
        end
    else
        -- Use regular panel for few options
        local menuHeight = (numChoices * (itemHeight + 2)) + (menuPadding * 2) + 2
        self.menu = vgui.Create("DPanel")
        self.menu:SetSize(menuWidth, menuHeight)
        local x, y = self:LocalToScreen(0, self:GetTall())
        if y + menuHeight > ScrH() - 10 then y = y - menuHeight - self:GetTall() end
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
            local option = vgui.Create("DButton", self.menu)
            option:SetText("")
            option:Dock(TOP)
            option:DockMargin(2, 2, 2, 0)
            option:SetTall(itemHeight)
            option:SetCursor("hand")
            option.Paint = function(s, w, h)
                local isSelected = self.selected == choice.text
                local isHovered = s:IsHovered()
                -- Draw background for selected option (full box)
                if isSelected then
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.theme):Shape(lia.derma.SHAPE_IOS):Draw()
                elseif isHovered then
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
                end

                -- Draw text
                local textColor = isSelected and lia.color.theme.text_entry or lia.color.theme.text
                draw.SimpleText(choice.text, "Fated.18", 14, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            option.DoClick = function()
                self:ChooseOption(choice.text, i)
                self:CloseMenu()
                surface.PlaySound("button_click.wav")
            end
        end
    end

    self.opened = true
    local oldMouseDown = false
    self.menu.Think = function()
        if not self.menu:IsVisible() then return end
        local mouseDown = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)
        if mouseDown and not oldMouseDown then
            local mx, my = gui.MousePos()
            local menuX, menuY = self.menu:LocalToScreen(0, 0)
            if not (mx >= menuX and mx <= menuX + self.menu:GetWide() and my >= menuY and my <= menuY + self.menu:GetTall()) then self:CloseMenu() end
        end

        oldMouseDown = mouseDown
    end

    self.menu.OnRemove = function() self.opened = false end
end

function PANEL:CloseMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    self.opened = false
end

function PANEL:OnRemove()
    self:CloseMenu()
end

function PANEL:GetOptionData(index)
    return self.choices[index] and self.choices[index].data or nil
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

function PANEL:GetSelectedText()
    return self.selected
end

function PANEL:IsMenuOpen()
    return self.opened
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:RefreshDropdown()
    -- Force refresh of dropdown if it's currently open
    if IsValid(self.menu) and self.opened then
        self:CloseMenu()
        self:OpenMenu()
    end
end

function PANEL:FinishAddingOptions()
    -- This method can be called after all options have been added
    -- to ensure the dropdown is properly sized
    self:RefreshDropdown()
end

vgui.Register("liaComboBox", PANEL, "Panel")
