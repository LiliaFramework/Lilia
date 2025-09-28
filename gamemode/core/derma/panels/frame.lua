local PANEL = {}
local mat_close = Material("close_button.png")
function PANEL:Init()
    self.bool_alpha = true
    self.bool_lite = false
    self.title = L("frame_title")
    self.center_title = ""
    self:DockPadding(6, 30, 6, 6)
    self.top_panel = vgui.Create("liaButton", self)
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

    self.top_panel.Think = function(_)
        if self.Dragging then
            local mouseX, mouseY = gui.MousePos()
            local newPosX, newPosY = mouseX - self.Dragging[1], mouseY - self.Dragging[2]
            self:SetPos(newPosX, newPosY)
        end
    end

    self.cls = vgui.Create("liaButton", self)
    self.cls:SetText("")
    self.cls.Paint = function(_, w, h) lia.rndx.Rect(2, 2, w - 4, h - 4):Color(lia.color.theme.header_text):Material(mat_close):Draw() end
    self.cls.DoClick = function()
        self:AlphaTo(0, 0.1, 0, function() self:Remove() end)
        surface.PlaySound("garrysmod/ui_click.wav")
    end

    self.cls.DoRightClick = function()
        local DM = vgui.Create("liaDermaMenu")
        DM:AddOption(L("frame_alpha"), function() self.bool_alpha = not self.bool_alpha end, self.bool_alpha and "icon16/bullet_green.png" or "icon16/bullet_red.png")
        local boolInput = self:IsKeyboardInputEnabled()
        DM:AddOption(L("frame_move_from_menu"), function() self:SetKeyboardInputEnabled(not boolInput) end, not boolInput and "icon16/bullet_green.png" or "icon16/bullet_red.png")
        DM:AddOption(L("frame_close_window"), function() self:Remove() end, "icon16/cross.png")
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
    lia.util.animateAppearance(self, self:GetWide(), self:GetTall(), 0.3, 0.2)
end

function PANEL:DisableCloseBtn()
    self.cls:SetVisible(false)
end

function PANEL:ShowCloseButton(show)
    if show then
        self.cls:SetVisible(true)
    else
        self.cls:SetVisible(false)
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
    col = col or lia.color.theme.accent
    surface.SetFont("Fated.20")
    local tw, th = surface.GetTextSize(text)
    local mp = vgui.Create("liaBasePanel", self)
    mp:SetSize(tw + 16, th + 8)
    mp:SetMouseInputEnabled(false)
    local startY = self:GetTall() + mp:GetTall()
    local endY = self:GetTall() - mp:GetTall() - 16
    mp:SetPos((self:GetWide() - mp:GetWide()) * 0.5, startY)
    mp:SetAlpha(0)
    mp.Paint = function(_, w, h)
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(col):Shadow(7, 20):Outline(3):Clip(self):Draw()
        lia.rndx.Rect(0, 0, w, h):Rad(16):Color(col):Draw()
        draw.SimpleText(text, "Fated.20", w * 0.5, h * 0.5 - 1, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    lia.rndx.Rect(0, 0, w, h):Rad(6):Color(lia.color.theme.window_shadow):Shadow(10, 16):Shape(lia.rndx.SHAPE_IOS):Draw()
    if not self.bool_lite then lia.rndx.Rect(0, 0, w, 24):Radii(6, 6, 0, 0):Color(lia.color.theme.header):Draw() end
    local headerTall = self.bool_lite and 0 or 24
    if self.bool_alpha and lia.config.get("uiBlurEnabled", true) then lia.rndx.Rect(0, headerTall, w, h - headerTall):Radii(self.bool_lite and 6 or 0, self.bool_lite and 6 or 0, 6, 6):Blur():Draw() end
    lia.rndx.Rect(0, headerTall, w, h - headerTall):Radii(self.bool_lite and 6 or 0, self.bool_lite and 6 or 0, 6, 6):Color(self.bool_alpha and lia.color.theme.background_alpha or lia.color.theme.background):Draw()
    if not self.bool_lite then
        if self.center_title ~= "" then draw.SimpleText(self.center_title, "Fated.20b", w * 0.5, 12, lia.color.theme.header_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        draw.SimpleText(self.title, "Fated.16", 6, 4, lia.color.theme.header_text)
    end
end

function PANEL:PerformLayout(w, _)
    self.top_panel:SetSize(w, 24)
    self.cls:SetSize(20, 20)
    self.cls:SetPos(w - 22, 2)
end

function PANEL:Center()
    self:CenterHorizontal()
    self:CenterVertical()
    self:InvalidateLayout()
end

function PANEL:Close()
    self:AlphaTo(0, 0.1, 0, function() self:Remove() end)
    surface.PlaySound("garrysmod/ui_click.wav")
end

function PANEL:GetBackgroundBlur()
    return self.bool_alpha or false
end

function PANEL:GetDeleteOnClose()
    return true
end

function PANEL:GetDraggable()
    return self.top_panel and self.top_panel:IsVisible() or false
end

function PANEL:GetIsMenu()
    return false
end

function PANEL:GetMinHeight()
    return self.m_MinHeight or 100
end

function PANEL:GetMinWidth()
    return self.m_MinWidth or 200
end

function PANEL:GetPaintShadow()
    return not self.bool_lite
end

function PANEL:GetScreenLock()
    return self.screenLock or false
end

function PANEL:GetSizable()
    return self.sizable or false
end

function PANEL:GetTitle()
    return self.title or L("frame_title")
end

function PANEL:IsActive()
    return self:HasFocus() or self:HasHierarchicalFocus()
end

function PANEL:OnClose()
end

function PANEL:SetBackgroundBlur(blur)
    self.bool_alpha = blur
end

function PANEL:SetDeleteOnClose(_)
end

function PANEL:SetDraggable(draggable)
    if self.top_panel then self.top_panel:SetVisible(draggable) end
end

function PANEL:SetIcon(path)
    self.iconPath = path
end

function PANEL:SetIsMenu(isMenu)
    self.isMenu = isMenu
end

function PANEL:SetMinHeight(minH)
    self.m_MinHeight = minH
end

function PANEL:SetMinWidth(minW)
    self.m_MinWidth = minW
end

function PANEL:SetPaintShadow(shouldPaint)
    self.bool_lite = not shouldPaint
end

function PANEL:SetScreenLock(lock)
    self.screenLock = lock
end

function PANEL:SetSizable(sizable)
    self.sizable = sizable
end

function PANEL:ShowCloseButton(show)
    if self.cls then self.cls:SetVisible(show) end
end

vgui.Register("liaFrame", PANEL, "EditablePanel")
