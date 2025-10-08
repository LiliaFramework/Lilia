local PANEL = {}
function PANEL:Init()
    self.Items = {}
    self:SetSize(200, 0)
    self:DockPadding(6, 7, 6, 7)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(true)
    self:SetDrawOnTop(true)
    self:SetZPos(10000)
    self.MaxTextWidth = 0
    self.MaxIconWidth = 0
    self._openTime = CurTime()
    self.deleteSelf = true
    self.maxHeight = nil
    self.Think = function()
        if CurTime() - self._openTime < 0.1 then return end
        if (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) and not self:IsChildHovered() then
            local anySubmenuHovered = false
            for _, item in ipairs(self.Items or {}) do
                if IsValid(item) and item._submenu and item._submenu_open and IsValid(item._submenu) and item._submenu:IsHovered() then
                    anySubmenuHovered = true
                    break
                end
            end

            if not anySubmenuHovered then self:Remove() end
        end
    end

    self.OnKeyCodePressed = function(panel, keyCode)
        local focusedItem = nil
        local focusedIndex = 1
        for i, item in ipairs(panel.Items) do
            if IsValid(item) and item:IsHovered() then
                focusedItem = item
                focusedIndex = i
                break
            end
        end

        if keyCode == KEY_DOWN then
            local nextIndex = focusedIndex + 1
            if nextIndex > #panel.Items then nextIndex = 1 end
            for i = nextIndex, #panel.Items do
                local item = panel.Items[i]
                if IsValid(item) and item.SetHovered then
                    item:SetHovered(true)
                    if focusedItem then focusedItem:SetHovered(false) end
                    break
                end
            end
        elseif keyCode == KEY_UP then
            local prevIndex = focusedIndex - 1
            if prevIndex < 1 then prevIndex = #panel.Items end
            for i = prevIndex, 1, -1 do
                local item = panel.Items[i]
                if IsValid(item) and item.SetHovered then
                    item:SetHovered(true)
                    if focusedItem then focusedItem:SetHovered(false) end
                    break
                end
            end
        elseif keyCode == KEY_RIGHT and focusedItem and focusedItem._submenu then
            if not focusedItem._submenu_open then focusedItem:OpenSubMenu() end
        elseif keyCode == KEY_LEFT then
            if focusedItem and focusedItem._submenu and focusedItem._submenu_open then
                focusedItem:CloseSubMenu()
            else
                panel:Remove()
            end
        elseif keyCode == KEY_ENTER or keyCode == KEY_SPACE then
            if focusedItem then focusedItem:DoClick() end
        elseif keyCode == KEY_ESCAPE then
            panel:Remove()
        end
    end
end

function PANEL:Paint(w, h)
    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont('LiliaFont.18')
    local textW = select(1, surface.GetTextSize(text))
    local iconW = icon and 16 or 0
    self.MaxTextWidth = math.max(self.MaxTextWidth or 0, textW)
    self.MaxIconWidth = math.max(self.MaxIconWidth or 0, iconW)
    local option = vgui.Create('DButton', self)
    option:SetText('')
    option:Dock(TOP)
    option:DockMargin(2, 2, 2, 0)
    option:SetTall(26)
    option.sumTall = 28
    option.Icon = icon
    option.Text = text
    option.Func = func
    option.OnMousePressed = function(_, keyCode) if keyCode == MOUSE_LEFT then option:DoClick() end end
    option.IconWidth = icon and 16 or 0
    option._cachedIconMat = nil
    function option:SetImage(newIcon)
        option.Icon = newIcon
        option._cachedIconMat = nil
        local newIconWidth = newIcon and 16 or 0
        if IsValid(option:GetParent()) then
            local parent = option:GetParent()
            if parent.MaxIconWidth then
                parent.MaxIconWidth = math.max(parent.MaxIconWidth, newIconWidth)
                parent:UpdateSize()
            end
        end
    end

    function option:SetIcon(newIcon)
        return option:SetImage(newIcon)
    end

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

        if option.Func then
            option.Func()
            surface.PlaySound('button_click.wav')
        end

        timer.Simple(0.01, function()
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
        end)
    end

    option.OnKeyCodePressed = function(panel, keyCode)
        if keyCode == KEY_RIGHT and panel._submenu then
            if not panel._submenu_open then panel:OpenSubMenu() end
        elseif keyCode == KEY_LEFT and panel._submenu and panel._submenu_open then
            panel:CloseSubMenu()
        elseif keyCode == KEY_ENTER or keyCode == KEY_SPACE then
            panel:DoClick()
        end
    end

    function option:AddSubMenu()
        if IsValid(option._submenu) then option._submenu:Remove() end
        local submenu = vgui.Create("liaDermaMenu")
        submenu:SetDrawOnTop(true)
        submenu:SetParent(nil)
        submenu:SetVisible(false)
        submenu:SetZPos(10000)
        option._submenu = submenu
        option._submenu_open = false
        option.OnRemove = function()
            if IsValid(submenu) then
                if option._submenu_open then option:CloseSubMenu() end
                submenu:Remove()
                submenu = nil
            end
        end

        function option:OpenSubMenu()
            if not IsValid(submenu) then return end
            for _, sibling in ipairs(self:GetParent().Items or {}) do
                if IsValid(sibling) and sibling ~= self and sibling.CloseSubMenu then sibling:CloseSubMenu() end
            end

            local parentX, parentY = self:LocalToScreen(self:GetWide(), 0)
            local submenuWidth, submenuHeight = submenu:GetSize()
            local screenWidth, screenHeight = ScrW(), ScrH()
            local x, y = parentX, parentY
            if parentX + submenuWidth > screenWidth - 10 then x = parentX - submenuWidth - self:GetWide() end
            if parentY + submenuHeight > screenHeight - 10 then y = parentY - submenuHeight + self:GetTall() end
            if y < 10 then y = 10 end
            if x < 10 then x = 10 end
            submenu:SetPos(x, y)
            submenu:MakePopup()
            submenu:SetVisible(true)
            submenu:SetKeyboardInputEnabled(false)
            submenu:SetMouseInputEnabled(true)
            submenu:SetAlpha(255)
            option._submenu_open = true
        end

        function option:CloseSubMenu()
            if IsValid(submenu) then
                submenu:SetVisible(false)
                submenu:SetAlpha(0)
            end

            option._submenu_open = false
            if submenu and submenu.Items then
                for _, item in ipairs(submenu.Items) do
                    if IsValid(item) and item.CloseSubMenu then item:CloseSubMenu() end
                end
            end
        end

        function option:GetSubMenu()
            return option._submenu
        end

        function option:IsSubMenuOpen()
            return option._submenu_open and IsValid(option._submenu) and option._submenu:IsVisible()
        end

        function option:ToggleSubMenu()
            if option._submenu_open then
                option:CloseSubMenu()
            else
                option:OpenSubMenu()
            end
        end

        function option:SetSubMenuPositionMode(mode)
            option._submenu_position_mode = mode or 'auto'
        end

        function option:GetSubMenuPositionMode()
            return option._submenu_position_mode or 'auto'
        end

        local function isAnySubmenuHovered(opt)
            if not IsValid(opt) then return false end
            if opt:IsHovered() then return true end
            if opt._submenu and IsValid(opt._submenu) and opt._submenu:IsVisible() then
                if isAnySubmenuHovered(opt._submenu) then return true end
                for _, item in ipairs(opt._submenu.Items or {}) do
                    if IsValid(item) and isAnySubmenuHovered(item) then return true end
                end
            end
            return false
        end

        option.OnCursorExited = function() timer.Simple(0.3, function() if IsValid(option) and not isAnySubmenuHovered(option) then option:CloseSubMenu() end end) end
        submenu.OnCursorExited = function() timer.Simple(0.3, function() if IsValid(option) and not isAnySubmenuHovered(option) then option:CloseSubMenu() end end) end
        return submenu
    end

    option.AddSubMenu = option.AddSubMenu
    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

    option.Paint = function(pnl, w, h)
        w = w or pnl:GetWide()
        h = h or pnl:GetTall()
        local colors = lia.color.ReturnMainAdjustedColors()
        if pnl:IsHovered() then
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw()
            if pnl._submenu and not pnl._submenu_open and not pnl._hoverTimer then
                pnl._hoverTimer = timer.Simple(0.1, function()
                    if IsValid(pnl) and pnl:IsHovered() and pnl._submenu and not pnl._submenu_open then pnl:OpenSubMenu() end
                    if IsValid(pnl) then pnl._hoverTimer = nil end
                end)
            end
        else
            if pnl._hoverTimer then
                timer.Remove(pnl._hoverTimer)
                pnl._hoverTimer = nil
            end
        end

        local textPadding = 14
        local iconMat = pnl._cachedIconMat
        if pnl.Icon and not iconMat then
            iconMat = type(pnl.Icon) == 'IMaterial' and pnl.Icon or Material(pnl.Icon)
            pnl._cachedIconMat = iconMat
        end

        if iconMat then
            local iconSize = 16
            lia.derma.drawSurfaceTexture(iconMat, color_white, textPadding, (h - iconSize) * 0.5, iconSize, iconSize)
        end

        local currentIconWidth = pnl.Icon and 16 or 0
        local iconTextGap = currentIconWidth > 0 and 8 or 0
        local textX = textPadding + currentIconWidth + iconTextGap
        if pnl._submenu then
            local arrowSize = 16
            local arrowX = w - arrowSize - 8
            local arrowY = h * 0.5
            local arrowSymbol = pnl._submenu_open and "◄" or "►"
            draw.SimpleText(arrowSymbol, 'LiliaFont.16', arrowX, arrowY, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if currentIconWidth > 0 then
            local parent = pnl:GetParent()
            if IsValid(parent) and parent.MaxIconWidth and currentIconWidth > parent.MaxIconWidth then
                parent.MaxIconWidth = currentIconWidth
                parent:UpdateSize()
            end
        end

        draw.SimpleText(pnl.Text, 'LiliaFont.18', textX, h * 0.5, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

function PANEL:AddSubMenu(text, func, icon)
    local option = self:AddOption(text, func, icon)
    local submenu = option:AddSubMenu()
    return submenu, option
end

function PANEL:AddSubMenuSeparator()
    if not IsValid(self) then return end
    local spacer = vgui.Create('DPanel', self)
    spacer:Dock(TOP)
    spacer:DockMargin(8, 3, 8, 3)
    spacer:SetTall(1)
    spacer.sumTall = 7
    spacer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Color(lia.color.theme.accent):Draw() end
    table.insert(self.Items, spacer)
    self:UpdateSize()
    return spacer
end

function PANEL:CloseAllSubMenus()
    for _, item in ipairs(self.Items or {}) do
        if IsValid(item) and item.CloseSubMenu then item:CloseSubMenu() end
    end
end

function PANEL:GetAllSubMenus()
    local submenus = {}
    for _, item in ipairs(self.Items or {}) do
        if IsValid(item) and item._submenu then table.insert(submenus, item._submenu) end
    end
    return submenus
end

function PANEL:UpdateSize()
    local height = 16
    for _, item in ipairs(self.Items) do
        if IsValid(item) then height = height + item.sumTall end
    end

    local iconExtra = self.MaxIconWidth > 0 and (self.MaxIconWidth + 8) or 0
    local maxWidth = math.max(200, self.MaxTextWidth + 60 + iconExtra)
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
    self:CloseAllSubMenus()
    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            if item._submenu and IsValid(item._submenu) then
                item._submenu:Remove()
                item._submenu = nil
            end

            item:Remove()
        end
    end

    self.Items = {}
    self.MaxTextWidth = 0
    self.MaxIconWidth = 0
    self:UpdateSize()
end

function PANEL:Close()
    self:CloseAllSubMenus()
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
