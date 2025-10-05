local PANEL = {}
function PANEL:Init()
    self.Items = {}
    self:SetSize(160, 0)
    self:DockPadding(6, 7, 6, 7)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self.MaxTextWidth = 0
    self._openTime = CurTime()
    self.deleteSelf = true
    self.maxHeight = nil
    self.Think = function()
        if CurTime() - self._openTime < 0.1 then return end
        if (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) and not self:IsChildHovered() then self:Remove() end
    end
end

function PANEL:Paint(w, h)
    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont("Fated.18")
    local textW = select(1, surface.GetTextSize(text))
    self.MaxTextWidth = math.max(self.MaxTextWidth or 0, textW)
    local option = vgui.Create("DButton", self)
    option:SetText("")
    option:Dock(TOP)
    option:DockMargin(2, 2, 2, 0)
    option:SetTall(26)
    option.sumTall = 28
    option.Icon = icon
    option.Text = text
    option._submenu = nil
    option._submenu_open = false
    option.DoClick = function()
        if option._submenu then
            if option._submenu_open then
                option:CloseSubMenu()
            else
                option:OpenSubMenu()
            end
            return
        end

        if func then func() end
        surface.PlaySound('button_click.wav')
        local function closeAllMenus(panel)
            while IsValid(panel) do
                if panel:GetName() == 'liaDermaMenu' then
                    local parent = panel:GetParent()
                    panel:Close()
                    panel = parent
                else
                    panel = panel:GetParent()
                end
            end
        end

        closeAllMenus(option)
    end

    function option:AddSubMenu()
        if IsValid(option._submenu) then option._submenu:Remove() end
        local submenu = vgui.Create('liaDermaMenu')
        submenu:SetDrawOnTop(true)
        submenu:SetParent(self:GetParent())
        submenu:SetVisible(false)
        option._submenu = submenu
        option._submenu_open = false
        option.OnRemove = function() if IsValid(submenu) then submenu:Remove() end end
        function option:OpenSubMenu()
            if not IsValid(submenu) then return end
            for _, sibling in ipairs(self:GetParent().Items or {}) do
                if sibling ~= self and sibling.CloseSubMenu then sibling:CloseSubMenu() end
            end

            local x, y = self:LocalToScreen(self:GetWide(), 0)
            submenu:SetPos(x, y)
            submenu:SetVisible(true)
            submenu:MakePopup()
            submenu:SetKeyboardInputEnabled(false)
            option._submenu_open = true
        end

        function option:CloseSubMenu()
            if IsValid(submenu) then submenu:SetVisible(false) end
            option._submenu_open = false
            if submenu.Items then
                for _, item in ipairs(submenu.Items) do
                    if item.CloseSubMenu then item:CloseSubMenu() end
                end
            end
        end

        local function isAnySubmenuHovered(opt)
            if not IsValid(opt) then return false end
            if opt:IsHovered() then return true end
            if opt._submenu and IsValid(opt._submenu) and opt._submenu:IsVisible() then
                if isAnySubmenuHovered(opt._submenu) then return true end
                for _, item in ipairs(opt._submenu.Items or {}) do
                    if isAnySubmenuHovered(item) then return true end
                end
            end
            return false
        end

        option.OnCursorExited = function() timer.Simple(0.15, function() if not isAnySubmenuHovered(option) then option:CloseSubMenu() end end) end
        submenu.OnCursorExited = function() timer.Simple(0.15, function() if not isAnySubmenuHovered(option) then option:CloseSubMenu() end end) end
        return submenu
    end

    option.AddSubMenu = option.AddSubMenu
    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

    local iconMat
    if option.Icon then iconMat = type(option.Icon) == 'IMaterial' and option.Icon or Material(option.Icon) end
    option.Paint = function(pnl, w, h)
        w = w or pnl:GetWide()
        h = h or pnl:GetTall()
        if pnl:IsHovered() then
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
            if pnl._submenu and not pnl._submenu_open then pnl:OpenSubMenu() end
        end

        local textPadding = 14
        if iconMat then
            local iconSize = 16
            lia.derma.drawSurfaceTexture(iconMat, color_white, textPadding, (h - iconSize) * 0.5, iconSize, iconSize)
        end

        local iconW = pnl.Icon and 16 or 0
        local iconTextGap = pnl.Icon and 8 or 0
        local textX = textPadding + (iconW > 0 and (iconW + iconTextGap) or 0)
        draw.SimpleText(pnl.Text, 'Fated.18', textX, h * 0.5, lia.color.ReturnMainAdjustedColors().text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    table.insert(self.Items, option)
    self:UpdateSize()
    return option
end

function PANEL:AddSpacer()
    local spacer = vgui.Create('DPanel', self)
    spacer:Dock(TOP)
    spacer:DockMargin(8, 6, 8, 6)
    spacer:SetTall(1)
    spacer.sumTall = 13
    spacer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Color(lia.color.theme.focus_panel):Draw() end
    table.insert(self.Items, spacer)
    self:UpdateSize()
    return spacer
end

function PANEL:UpdateSize()
    local height = 16
    for _, item in ipairs(self.Items) do
        if IsValid(item) then height = height + item.sumTall end
    end

    local maxWidth = math.max(160, self.MaxTextWidth + 60)
    local limit = self.maxHeight or (ScrH() * 0.8)
    self:SetSize(maxWidth, math.min(height, limit))
end

function PANEL:Open()
    self:SetVisible(true)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)
    self._openTime = CurTime()
end

function PANEL:CloseMenu()
    self:Close()
end

function PANEL:GetDeleteSelf()
    return self.deleteSelf ~= false
end

function PANEL:SetDeleteSelf(deleteSelf)
    self.deleteSelf = tobool(deleteSelf)
end

function PANEL:SetMaxHeight(height)
    self.maxHeight = tonumber(height)
    self:UpdateSize()
end

function PANEL:Clear()
    for _, item in ipairs(self.Items) do
        if IsValid(item) then item:Remove() end
    end

    self.Items = {}
    self.MaxTextWidth = 0
    self:UpdateSize()
end

function PANEL:Close()
    if self.deleteSelf ~= false then
        self:Remove()
    else
        self:SetVisible(false)
    end
end

function PANEL:SetPadding(left, top, right, bottom)
    if bottom == nil and right == nil and top == nil then
        local pad = left or 0
        self:DockPadding(pad, pad, pad, pad)
    else
        self:DockPadding(left or 0, top or 0, right or 0, bottom or 0)
    end
end

vgui.Register('liaDermaMenu', PANEL, 'DPanel')
