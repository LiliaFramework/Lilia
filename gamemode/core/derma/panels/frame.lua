local PANEL = {}
function PANEL:Init()
    self.bool_alpha = true
    self.bool_lite = false
    self.title = L("title")
    self.center_title = ""
    self.blurAmount = 6
    self.blurPasses = 0
    self.blurAlpha = 255
    self.sizable = false
    self.deleteOnClose = true
    self.screenLock = false
    self.backgroundBlur = false
    self.backgroundBlurTime = 0
    self.minWidth = 120
    self.minHeight = 80
    self.iconMat = nil
    self.panelColor = lia.color.theme.panel[1]
    self:DockPadding(6, 30, 6, 6)
    self.top_panel = vgui.Create("DButton", self)
    self.top_panel:SetText("")
    self.top_panel:SetCursor("sizeall")
    self.top_panel.Paint = nil
    self.top_panel.OnMousePressed = function(s, key)
        if key == MOUSE_LEFT then
            self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
            s:MouseCapture(true)
            self:SetAlpha(200)
        end
    end

    self.top_panel.OnMouseReleased = function(s, key)
        if key == MOUSE_LEFT then
            self.Dragging = nil
            s:MouseCapture(false)
            self:SetAlpha(255)
        end
    end

    self.top_panel.Think = function()
        if self.Dragging then
            local mouseX, mouseY = gui.MousePos()
            local newPosX, newPosY = mouseX - self.Dragging[1], mouseY - self.Dragging[2]
            self:SetPos(newPosX, newPosY)
        end
    end

    self.cls = vgui.Create('Button', self)
    self.cls:SetText('')
    self.cls.Paint = function(_, w, h)
        lia.derma.rect(2, 2, w - 4, h - 4):Color(lia.color.theme.header_text):Draw()
        draw.SimpleText("✕", "lia.18", w * 0.5, h * 0.5, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.cls.DoClick = function()
        surface.PlaySound('button_click.wav')
        if self.deleteOnClose then
            self:AlphaTo(0, 0.1, 0, function() if IsValid(self) then self:Remove() end end)
        else
            self:SetVisible(false)
        end
    end

    self.cls.DoRightClick = function()
        local DM = lia.derma.dermaMenu()
        DM:AddOption(L("transparency"), function() self.bool_alpha = not self.bool_alpha end, self.bool_alpha and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
        local boolInput = self:IsKeyboardInputEnabled()
        DM:AddOption(L("moveFromMenu"), function() self:SetKeyBoardInputEnabled(not boolInput) end, not boolInput and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
        DM:AddOption(L("closeWindow"), function() self:Remove() end, 'icon16/cross.png')
    end

    self.resizer = vgui.Create('DButton', self)
    self.resizer:SetText('')
    self.resizer:SetCursor('sizenwse')
    self.resizer:SetVisible(false)
    self.resizer.Paint = function(_, w, h)
        if not self.sizable then return end
        draw.NoTexture()
        surface.SetDrawColor(lia.color.theme.focus_panel)
        surface.DrawRect(0, 0, w, h)
    end

    self.resizer.OnMousePressed = function(_, key)
        if key ~= MOUSE_LEFT or not self.sizable then return end
        self.resizing = {
            startX = gui.MouseX(),
            startY = gui.MouseY(),
            startW = self:GetWide(),
            startH = self:GetTall()
        }

        self.resizer:MouseCapture(true)
    end

    self.resizer.OnMouseReleased = function(_, key)
        if key ~= MOUSE_LEFT then return end
        self.resizing = nil
        self.resizer:MouseCapture(false)
    end
end

function PANEL:SetAlphaBackground(is_alpha)
    self.bool_alpha = is_alpha
end

function PANEL:SetTitle(title)
    self.title = title
end

function PANEL:SetCenterTitle(center_title)
    self.center_title = center_title
end

function PANEL:ShowAnimation()
    lia.util.animateAppearance(self, self:GetWide(), self:GetTall(), 0.1, 0.2)
end

function PANEL:DisableCloseBtn()
    self.cls:SetVisible(false)
end

function PANEL:ShowCloseButton(show)
    self.cls:SetVisible(show ~= false)
end

function PANEL:SetSizable(sizable)
    self.sizable = tobool(sizable)
    if IsValid(self.resizer) then self.resizer:SetVisible(self.sizable) end
end

function PANEL:SetDeleteOnClose(deleteOnClose)
    self.deleteOnClose = tobool(deleteOnClose)
end

function PANEL:SetScreenLock(locked)
    self.screenLock = tobool(locked)
    if locked then self:EnsureVisible() end
end

function PANEL:SetBackgroundBlur(enable)
    self.backgroundBlur = tobool(enable)
    if enable then self.backgroundBlurTime = SysTime() end
end

function PANEL:SetMinWidth(width)
    self.minWidth = tonumber(width) or self.minWidth
    if self:GetWide() < self.minWidth then
        self._sizeClamp = true
        self:SetWide(self.minWidth)
        self._sizeClamp = nil
    end
end

function PANEL:SetMinHeight(height)
    self.minHeight = tonumber(height) or self.minHeight
    if self:GetTall() < self.minHeight then
        self._sizeClamp = true
        self:SetTall(self.minHeight)
        self._sizeClamp = nil
    end
end

function PANEL:SetIcon(iconPath)
    if not iconPath or iconPath == '' then
        self.iconMat = nil
        return
    end

    if type(iconPath) == 'IMaterial' then
        self.iconMat = iconPath
    else
        self.iconMat = Material(iconPath)
    end
end

function PANEL:SetDraggable(is_draggable)
    self.top_panel:SetVisible(is_draggable)
end

function PANEL:LiteMode()
    self.bool_lite = true
    self:DockPadding(6, 6, 6, 6)
    self.cls:SetZPos(2)
end

function PANEL:Notify(text, duration, col)
    if IsValid(self.messagePanel) then self.messagePanel:Remove() end
    duration = duration or 2
    col = col or lia.color.theme.theme
    surface.SetFont('LiliaFont.20')
    local tw, th = surface.GetTextSize(text)
    local mp = vgui.Create('DPanel', self)
    mp:SetSize(tw + 16, th + 8)
    mp:SetMouseInputEnabled(false)
    local startY = self:GetTall() + mp:GetTall()
    local endY = self:GetTall() - mp:GetTall() - 16
    mp:SetPos((self:GetWide() - mp:GetWide()) * 0.5, startY)
    mp:SetAlpha(0)
    mp.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(16):Color(col):Shadow(7, 20):Outline(3):Clip(self):Draw()
        lia.derma.rect(0, 0, w, h):Rad(16):Color(col):Draw()
        draw.SimpleText(text, 'LiliaFont.20', w * 0.5, h * 0.5 - 1, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    mp:MoveTo(mp.x, endY, 0.3, 0, 0.7)
    mp:AlphaTo(255, 0.3, 0, function()
        timer.Simple(duration, function()
            if not IsValid(mp) then return end
            mp:AlphaTo(0, 0.25, 0, function() if IsValid(mp) then mp:Remove() end end)
        end)
    end)

    self.messagePanel = mp
end

function PANEL:Paint(w, h)
    if self.backgroundBlur then Derma_DrawBackgroundBlur(self, self.backgroundBlurTime) end
    lia.derma.rect(0, 0, w, h):Rad(6):Color(lia.color.theme.window_shadow):Shadow(10, 16):Shape(lia.derma.SHAPE_IOS):Draw()
    if not self.bool_lite then lia.derma.rect(0, 0, w, 24):Radii(6, 6, 0, 0):Color(lia.color.theme.header):Draw() end
    local headerTall = self.bool_lite and 0 or 24
    if self.bool_alpha then
        local blurAmount = self.blurAmount or 6
        local blurPasses = self.blurPasses or 0
        local blurAlpha = self.blurAlpha or 255
        lia.util.drawBlur(self, blurAmount, blurPasses, blurAlpha)
    end

    local radiusTop = self.bool_lite and 6 or 0
    lia.derma.rect(0, headerTall, w, h - headerTall):Radii(radiusTop, radiusTop, 6, 6):Color(self.bool_alpha and lia.color.theme.background_alpha or self.panelColor):Draw()
    if not self.bool_lite then
        if self.iconMat then
            surface.SetMaterial(self.iconMat)
            surface.SetDrawColor(lia.color.theme.header_text)
            surface.DrawTexturedRect(6, 4, 16, 16)
        end

        if self.center_title ~= '' then draw.SimpleText(self.center_title, 'LiliaFont.20b', w * 0.5, 12, lia.color.theme.header_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        local titleOffset = self.iconMat and 26 or 6
        draw.SimpleText(self.title, 'LiliaFont.16', titleOffset, 4, lia.color.theme.header_text)
    end
end

function PANEL:PerformLayout(w, h)
    self.top_panel:SetSize(w, 24)
    self.cls:SetSize(20, 20)
    self.cls:SetPos(w - 22, 2)
    if IsValid(self.resizer) then
        self.resizer:SetSize(14, 14)
        self.resizer:SetPos(w - 14, h - 14)
        self.resizer:SetVisible(self.sizable)
    end
end

function PANEL:EnsureVisible()
    local x, y = self:GetPos()
    local w, h = self:GetSize()
    local scrW, scrH = ScrW(), ScrH()
    local newX = math.Clamp(x, 0, math.max(scrW - w, 0))
    local newY = math.Clamp(y, 0, math.max(scrH - h, 0))
    if newX ~= x or newY ~= y then self:SetPos(newX, newY) end
end

function PANEL:Think()
    if self.resizing and self.sizable then
        local mx, my = gui.MousePos()
        local deltaX = mx - self.resizing.startX
        local deltaY = my - self.resizing.startY
        local newW = math.max(self.resizing.startW + deltaX, self.minWidth)
        local newH = math.max(self.resizing.startH + deltaY, self.minHeight)
        self._sizeClamp = true
        self:SetSize(newW, newH)
        self._sizeClamp = nil
    end

    if self.screenLock then self:EnsureVisible() end
end

function PANEL:OnSizeChanged(w, h)
    if self._sizeClamp then return end
    local newW = math.max(w, self.minWidth or w)
    local newH = math.max(h, self.minHeight or h)
    if newW ~= w or newH ~= h then
        self._sizeClamp = true
        self:SetSize(newW, newH)
        self._sizeClamp = nil
    end
end

vgui.Register('liaFrame', PANEL, 'EditablePanel')
