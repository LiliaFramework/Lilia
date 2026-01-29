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
    self._scrollPanel = nil
    self._usingScroll = false
    if RegisterDermaMenuForClose then RegisterDermaMenuForClose(self) end
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

            if not anySubmenuHovered then
                if self.deleteSelf ~= false then
                    self:Remove()
                else
                    self:Hide()
                end
            end
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
    local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 90)
    local backgroundPanel = lia.color.theme and lia.color.theme.background_panelpopup or Color(20, 28, 28)
    lia.derma.rect(0, 0, w, h):Rad(16):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
    lia.derma.rect(0, 0, w, h):Rad(16):Color(backgroundPanel):Shape(lia.derma.SHAPE_IOS):Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont("LiliaFont.18")
    local textW = select(1, surface.GetTextSize(text))
    local iconW = icon and 16 or 0
    self.MaxTextWidth = math.max(self.MaxTextWidth or 0, textW)
    self.MaxIconWidth = math.max(self.MaxIconWidth or 0, iconW)
    local parentPanel = self._usingScroll and self._scrollPanel or self
    local option = vgui.Create("DButton", parentPanel)
    option:SetText("")
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
            lia.websound.playButtonSound()
        end

        timer.Simple(0.01, function()
            local function closeAllMenus(panel)
                while IsValid(panel) do
                    if panel:GetName() == "liaDermaMenu" then
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
            option._submenu_position_mode = mode or "auto"
        end

        function option:GetSubMenuPositionMode()
            return option._submenu_position_mode or "auto"
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
        local textColor = lia.color.theme and lia.color.theme.text or Color(210, 235, 235)
        if pnl:IsHovered() then
            local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 35)
            local hoverColor = lia.color.theme and lia.color.theme.hover or Color(60, 140, 140, 90)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(hoverColor):Shape(lia.derma.SHAPE_IOS):Draw()
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
            iconMat = type(pnl.Icon) == "IMaterial" and pnl.Icon or Material(pnl.Icon)
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
            draw.SimpleText(arrowSymbol, "LiliaFont.16", arrowX, arrowY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if currentIconWidth > 0 then
            local parent = pnl:GetParent()
            if IsValid(parent) and parent.MaxIconWidth and currentIconWidth > parent.MaxIconWidth then
                parent.MaxIconWidth = currentIconWidth
                parent:UpdateSize()
            end
        end

        draw.SimpleText(pnl.Text, "LiliaFont.18", textX, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    table.insert(self.Items, option)
    self:UpdateSize()
    return option
end

function PANEL:AddSpacer()
    local parentPanel = self._usingScroll and self._scrollPanel or self
    local spacer = vgui.Create("DPanel", parentPanel)
    spacer:Dock(TOP)
    spacer:DockMargin(8, 6, 8, 6)
    spacer:SetTall(1)
    spacer.sumTall = 13
    local focusPanelColor = lia.color.theme and lia.color.theme.focus_panel or Color(48, 72, 72)
    spacer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Color(focusPanelColor):Draw() end
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
    local parentPanel = self._usingScroll and self._scrollPanel or self
    local spacer = vgui.Create("DPanel", parentPanel)
    spacer:Dock(TOP)
    spacer:DockMargin(8, 3, 8, 3)
    spacer:SetTall(1)
    spacer.sumTall = 7
    local accentColor = lia.color.theme and lia.color.theme.accent or Color(60, 140, 140)
    spacer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Color(accentColor):Draw() end
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
    if height > limit then
        if not self._usingScroll then
            self._usingScroll = true
            self._scrollPanel = vgui.Create("liaScrollPanel", self)
            self._scrollPanel:Dock(FILL)
            self._scrollPanel:DockMargin(0, 0, 0, 0)
            for _, item in ipairs(self.Items) do
                if IsValid(item) then item:SetParent(self._scrollPanel) end
            end
        end

        self:SetSize(maxWidth, limit)
    else
        if self._usingScroll then
            self._usingScroll = false
            for _, item in ipairs(self.Items) do
                if IsValid(item) then item:SetParent(self) end
            end

            if IsValid(self._scrollPanel) then
                self._scrollPanel:Remove()
                self._scrollPanel = nil
            end
        end

        self:SetSize(maxWidth, height)
    end
end

function PANEL:Open(x, y, skipanimation, ownerpanel)
    if RegisterDermaMenuForClose then RegisterDermaMenuForClose(self) end
    if x and y then
        self:SetPos(x, y)
    else
        x = x or gui.MouseX()
        y = y or gui.MouseY()
        self:SetPos(x, y)
    end

    self:InvalidateLayout(true)
    local w, h = self:GetWide(), self:GetTall()
    self:SetSize(w, h)
    local screenW, screenH = ScrW(), ScrH()
    local posX, posY = self:GetPos()
    if posY + h > screenH then
        if ownerpanel then
            local _, ownerH = ownerpanel:GetSize()
            posY = posY + ownerH - h
        else
            posY = screenH - h
        end
    end

    if posX + w > screenW then posX = screenW - w end
    if posY < 1 then posY = 1 end
    if posX < 1 then posX = 1 end
    local p = self:GetParent()
    if IsValid(p) and p:IsModal() then
        posX, posY = p:ScreenToLocal(posX, posY)
        if posY + h > p:GetTall() then posY = p:GetTall() - h end
        if posX + w > p:GetWide() then posX = p:GetWide() - w end
        if posY < 1 then posY = 1 end
        if posX < 1 then posX = 1 end
        self:SetPos(posX, posY)
    else
        self:SetPos(posX, posY)
        self:MakePopup()
    end

    self:SetVisible(true)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)
    self._openTime = CurTime()
    if not skipanimation then
        self:SetAlpha(0)
        self:AlphaTo(255, 0.1, 0)
    else
        self:SetAlpha(255)
    end

    if IsValid(ownerpanel) then self.ownerPanel = ownerpanel end
end

function PANEL:Open()
    self:SetVisible(true)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)
    self._openTime = CurTime()
    if not self:GetParent() or not self:GetParent():IsModal() then self:MakePopup() end
end

function PANEL:CloseMenu()
    self:Close()
end

function PANEL:GetOpenSubMenu()
    for _, item in ipairs(self.Items) do
        if IsValid(item) and item._submenu and item._submenu_open and IsValid(item._submenu) then return item._submenu end
    end
    return nil
end

function PANEL:GetDeleteSelf()
    if self.deleteSelf == nil then return true end
    return self.deleteSelf == true
end

function PANEL:SetDeleteSelf(deleteSelf)
    self.deleteSelf = tobool(deleteSelf)
end

function PANEL:SetMaxHeight(height)
    self.maxHeight = tonumber(height)
    self:UpdateSize()
end

function PANEL:AddCVar(name, convar, on, off, funcFunction)
    local option = self:AddOption(name, function()
        local value = GetConVar(convar):GetBool() and on or off
        RunConsoleCommand(convar, value)
        if funcFunction then funcFunction(value) end
    end)

    option.ConVar = convar
    option.ConVarOn = on
    option.ConVarOff = off
    return option
end

function PANEL:AddPanel(pnl)
    local parentPanel = self._usingScroll and self._scrollPanel or self
    pnl:SetParent(parentPanel)
    pnl:Dock(TOP)
    pnl:DockMargin(2, 2, 2, 0)
    table.insert(self.Items, pnl)
    self:UpdateSize()
    return pnl
end

function PANEL:GetChild(childIndex)
    if not childIndex or childIndex < 1 then return nil end
    return self.Items[childIndex]
end

function PANEL:ChildCount()
    return #self.Items
end

function PANEL:GetDrawBorder()
    return self.drawBorder or false
end

function PANEL:GetDrawColumn()
    return self.drawColumn or false
end

function PANEL:GetMinimumWidth()
    return self.minimumWidth or 120
end

function PANEL:ClearHighlights()
    for _, item in ipairs(self.Items) do
        if IsValid(item) and item.SetHovered then item:SetHovered(false) end
    end
end

function PANEL:Hide()
    self:CloseAllSubMenus()
    self:SetVisible(false)
end

function PANEL:HighlightItem(item)
    if not IsValid(item) then return end
    self:ClearHighlights()
    item:SetHovered(true)
end

function PANEL:OptionSelected(option)
    if option and IsValid(option) and option.Func then option:DoClick() end
end

function PANEL:OptionSelectedInternal(option)
    self:OptionSelected(option, option.Text)
end

function PANEL:SetDrawBorder(bool)
    self.drawBorder = tobool(bool)
end

function PANEL:SetDrawColumn(drawColumn)
    self.drawColumn = tobool(drawColumn)
end

function PANEL:SetMinimumWidth(minWidth)
    self.minimumWidth = tonumber(minWidth) or 120
    self:UpdateSize()
end

function PANEL:SetOpenSubMenu(item)
    if IsValid(item) and item._submenu and not item._submenu_open then item:OpenSubMenu() end
end

function PANEL:AddItem(pnl)
    return self:AddPanel(pnl)
end

function PANEL:GetCanvas()
    return self.canvas
end

function PANEL:GetPadding()
    return self.padding or 0
end

function PANEL:GetVBar()
    return self.vbar
end

function PANEL:InnerWidth()
    local padding = self:GetPadding()
    return self:GetWide() - (padding * 2)
end

function PANEL:PerformLayoutInternal()
end

function PANEL:Rebuild()
    self:UpdateSize()
end

function PANEL:ScrollToChild(panel)
    if not IsValid(panel) then return end
    local canvas = self:GetCanvas()
    if not IsValid(canvas) then return end
    local panelY = panel:GetY()
    local canvasY = canvas:GetY()
    local scrollY = panelY - canvasY
    local vbar = self:GetVBar()
    if IsValid(vbar) then vbar:AnimateTo(scrollY, 0.5, 0, 0.5) end
end

function PANEL:SetCanvas(canvas)
    if IsValid(self.canvas) then self.canvas:Remove() end
    self.canvas = canvas
    if IsValid(canvas) then
        canvas:SetParent(self)
        canvas:Dock(FILL)
    end
end

function PANEL:SetPadding(padding)
    self.padding = tonumber(padding) or 0
    self:DockPadding(self.padding, self.padding, self.padding, self.padding)
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
    if IsValid(self._scrollPanel) then
        self._scrollPanel:Remove()
        self._scrollPanel = nil
        self._usingScroll = false
    end

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

vgui.Register("liaDermaMenu", PANEL, "DPanel")
if not _liaDermaMenuOverride then
    _liaDermaMenuOverride = true
    local oldDermaMenu = DermaMenu
    function DermaMenu(parentmenu, parent)
        if not parentmenu then
            if oldDermaMenu and type(oldDermaMenu) == "function" then
                oldDermaMenu(false)
            elseif CloseDermaMenus then
                CloseDermaMenus()
            end
        end

        local menu = vgui.Create("liaDermaMenu", parent)
        if not IsValid(menu) then
            ErrorNoHalt("[Lilia] Failed to create liaDermaMenu! Falling back to DMenu.\n")
            if oldDermaMenu and type(oldDermaMenu) == "function" then
                return oldDermaMenu(parentmenu, parent)
            else
                return vgui.Create("DMenu", parent)
            end
        end
        return menu
    end
end
