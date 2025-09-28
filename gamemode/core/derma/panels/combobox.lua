local PANEL = {}
function PANEL:Init()
    self.choices = {}
    self.selected = nil
    self.opened = false
    self:SetTall(26)
    self:SetText('')
    self.font = 'Fated.18'
    self.hoverAnim = 0
    self.OnSelect = function(_, _, _) end
    self.btn = vgui.Create("liaButton", self)
    self.btn:Dock(FILL)
    self.btn:SetText('')
    self.btn:SetCursor("hand")
    self.btn.Paint = function(_, w, h)
        if self.btn:IsHovered() then
            self.hoverAnim = math.Clamp(self.hoverAnim + FrameTime() * 4, 0, 1)
        else
            self.hoverAnim = math.Clamp(self.hoverAnim - FrameTime() * 8, 0, 1)
        end

        local themeColors = lia.color.theme
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(themeColors.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.rndx.Draw(16, 0, 0, w, h, themeColors.focus_panel, lia.rndx.SHAPE_IOS)
        if self.hoverAnim > 0 then
            local themeColors = lia.color.theme
            lia.rndx.Rect(0, 0, w, h):Rad(16):Color(Color(themeColors.hover.r, themeColors.hover.g, themeColors.hover.b, self.hoverAnim * 255)):Shape(lia.rndx.SHAPE_IOS):Draw()
        end

        draw.SimpleText(self.selected or self.placeholder or L("combobox_select"), self.font, 12, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
            surface.PlaySound('garrysmod/ui_click.wav')
        end
    end
end

function PANEL:AddChoice(text, data)
    table.insert(self.choices, {
        text = text,
        data = data
    })
end

function PANEL:SetValue(val)
    self.selected = val
end

function PANEL:GetValue()
    return self.selected
end

function PANEL:SetPlaceholder(text)
    self.placeholder = text
end

function PANEL:OpenMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    local menuPadding = 6
    local itemHeight = 26
    local menuHeight = (#self.choices * (itemHeight + 2)) + (menuPadding * 2) + 2
    local x, y = self:LocalToScreen(0, self:GetTall())
    self.menu = vgui.Create("liaBasePanel")
    self.menu:SetSize(self:GetWide(), menuHeight)
    if y + menuHeight > ScrH() - 10 then y = y - menuHeight - self:GetTall() end
    self.menu:SetPos(x, y)
    self.menu:SetDrawOnTop(true)
    self.menu:MakePopup()
    self.menu:SetKeyboardInputEnabled(false)
    self.menu:DockPadding(menuPadding, menuPadding, menuPadding, menuPadding)
    self.menu._anim = 0
    self.menu._animTarget = 1
    self.menu._animSpeed = 18
    self.menu._animEased = 0
    self.menu._closing = false
    self.menu._disableBlur = false
    self.menu:SetAlpha(0)
    self.menu.Paint = function(s, w, h)
        local aMul = s._animEased or ((s:GetAlpha() or 255) / 255)
        local blurMul
        if s._closing or s._disableBlur or s._animTarget == 0 then
            blurMul = 0
        else
            local fadeStart = 0.3
            blurMul = math.Clamp((aMul - fadeStart) / (1 - fadeStart), 0, 1)
        end

        local shadowSpread = math.max(0, math.floor(10 * blurMul))
        local shadowIntensity = math.max(0, math.floor(16 * blurMul))
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(shadowSpread, shadowIntensity):Draw()
        if not s._disableBlur then lia.rndx.Rect(0, 0, w, h):Rad(16):Shape(lia.rndx.SHAPE_IOS):Blur(blurMul):Draw() end
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background):Shape(lia.rndx.SHAPE_IOS):Draw()
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background):Shape(lia.rndx.SHAPE_IOS):Outline(1):Draw()
    end

    surface.SetFont(self.font)
    for i, choice in ipairs(self.choices) do
        local option = vgui.Create("liaButton", self.menu)
        option:SetText('')
        option:Dock(TOP)
        option:DockMargin(2, 2, 2, 0)
        option:SetTall(itemHeight)
        option:SetCursor("hand")
        option.Paint = function(s, w, h)
            if s:IsHovered() then lia.rndx.Draw(16, 0, 0, w, h, lia.color.theme.hover, lia.rndx.SHAPE_IOS) end
            draw.SimpleText(choice.text, 'Fated.18', 14, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if self.selected == choice.text then lia.rndx.Draw(0, 4, h * 0.5 - 1, 4, 2, lia.color.theme.accent) end
        end

        option.DoClick = function()
            self.selected = choice.text
            if self.menu and IsValid(self.menu) then
                self.menu._closing = true
                self.menu._animTarget = 0
                self.menu._disableBlur = true
            end

            if self.OnSelect then self.OnSelect(i, choice.text, choice.data) end
            surface.PlaySound('garrysmod/ui_click.wav')
        end
    end

    self.opened = true
    local oldMouseDown = false
    self.menu.Think = function(s)
        local ft = FrameTime()
        s._anim = lia.util.approachExp(s._anim or 0, s._animTarget or 1, s._animSpeed or 18, ft)
        s._animEased = s._anim
        s:SetAlpha(math.floor(255 * s._animEased + 0.5))
        if s._targetX and s._targetY then
            local offsetY = 6 * (1 - s._animEased)
            s:SetPos(s._targetX, s._targetY + offsetY)
        end

        if s._closing and s._animEased <= 0.005 then
            s:Remove()
            return
        end

        if not s:IsVisible() then return end
        local mouseDown = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)
        if mouseDown and not oldMouseDown then
            local mx, my = gui.MousePos()
            local x, y = s:LocalToScreen(0, 0)
            if not (mx >= x and mx <= x + s:GetWide() and my >= y and my <= y + s:GetTall()) then
                s._closing = true
                s._animTarget = 0
                s._disableBlur = true
            end
        end

        oldMouseDown = mouseDown
    end

    self.menu.OnRemove = function() if IsValid(self) then self.opened = false end end
    lia.util.clampMenuPosition(self.menu)
    self.menu._targetX, self.menu._targetY = self.menu:GetPos()
    if not self.menu._initPosSet then
        self.menu:SetPos(self.menu._targetX, self.menu._targetY + 6)
        self.menu._initPosSet = true
    end
end

function PANEL:CloseMenu()
    if IsValid(self.menu) then
        if not self.menu._closing then
            self.menu._closing = true
            self.menu._animTarget = 0
            self.menu._disableBlur = true
        end
    end

    self.opened = false
end

function PANEL:OnRemove()
    self:CloseMenu()
end

function PANEL:GetOptionText(index)
    if self.choices[index] then return self.choices[index].text end
    return ""
end

function PANEL:GetOptionData(index)
    if self.choices[index] then return self.choices[index].data end
    return nil
end

function PANEL:GetSelectedID()
    for i, choice in ipairs(self.choices) do
        if choice.data == self.selected then return i end
    end
    return nil
end

function PANEL:GetSelected()
    local selectedID = self:GetSelectedID()
    if selectedID then return self.choices[selectedID].text, self.choices[selectedID].data end
    return "", nil
end

function PANEL:SetSelected(index)
    if self.choices[index] then self.selected = self.choices[index].data end
end

function PANEL:ChooseOptionID(index)
    self:SetSelected(index)
end

function PANEL:ChooseOption(text)
    for i, choice in ipairs(self.choices) do
        if choice.text == text then
            self.selected = choice.data
            break
        end
    end
end

function PANEL:Clear()
    self.choices = {}
    self.selected = nil
end

function PANEL:GetOptionTextByData(data)
    for i, choice in ipairs(self.choices) do
        if choice.data == data then return choice.text end
    end
    return ""
end

function PANEL:IsMenuOpen()
    return self.opened or false
end

function PANEL:SetSortItems(sort)
    self.sortItems = sort
end

vgui.Register("liaComboBox", PANEL, "Panel")
