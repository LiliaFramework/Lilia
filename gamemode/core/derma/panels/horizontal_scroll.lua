local PANEL = {}
AccessorFunc(PANEL, "padding", "Padding")
AccessorFunc(PANEL, "canvas", "Canvas")
function PANEL:Init()
    self.canvas = self:Add("Panel")
    self.canvas.OnMousePressed = function(_, code) self:OnMousePressed(code) end
    self.canvas:SetMouseInputEnabled(true)
    self.canvas.PerformLayout = function()
        self:PerformLayout()
        self:InvalidateParent()
    end
    self.bar = self:Add("liaHorizontalScrollBar")
    self.bar:Dock(BOTTOM)
    self:SetPadding(0)
    self:SetMouseInputEnabled(true)
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
end
function PANEL:AddItem(item)
    item:SetParent(self.canvas)
end
function PANEL:OnChildAdded(child)
    self:AddItem(child)
end
function PANEL:SizeToContents()
    self:SetSize(self.canvas:GetSize())
end
function PANEL:GetHBar()
    return self.bar
end
function PANEL:OnMouseWheeled(delta)
    self.bar:OnMouseWheeled(delta)
end
function PANEL:OnHScroll(offset)
    self.canvas:SetPos(offset, 0)
end
function PANEL:ScrollToChild(child)
    self:PerformLayout()
    local x = self.canvas:GetChildPosition(child)
    x = x + (child:GetWide() - self:GetWide()) * 0.5
    self.bar:AnimateTo(x, 0.5, 0, 0.5)
end
function PANEL:PerformLayout()
    local w, h = self:GetWide(), self:GetTall()
    local canvas = self.canvas
    canvas:SizeToChildren(true, false)
    local cw = canvas:GetWide()
    local bar = self.bar
    bar:SetUp(w, cw)
    if bar.Enabled then h = h - bar:GetTall() end
    canvas:SetSize(cw, h)
    local x = bar:GetOffset()
    if cw < w then x = (w - cw) * 0.5 end
    canvas:SetPos(x, 0)
end
function PANEL:Clear()
    self.canvas:Clear()
end
vgui.Register("liaHorizontalScroll", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    self.btnLeft = self.btnUp
    self.btnRight = self.btnDown
    self.btnLeft.Paint = function(p, w, h) derma.SkinHook("Paint", "ButtonLeft", p, w, h) end
    self.btnRight.Paint = function(p, w, h) derma.SkinHook("Paint", "ButtonRight", p, w, h) end
end
function PANEL:SetScroll(offset)
    if self.Enabled then
        self.Scroll = math.Clamp(offset, 0, self.CanvasSize)
        self:InvalidateLayout()
        local parent = self:GetParent()
        if parent.OnHScroll then
            parent:OnHScroll(self.Scroll)
        else
            parent:InvalidateLayout()
        end
    else
        self.Scroll = 0
    end
end
function PANEL:OnCursorMoved()
    if not self.Enabled or not self.Dragging then return end
    local x = self:ScreenToLocal(gui.MouseX(), 0) - self.btnLeft:GetWide() - self.HoldPos
    local btnSize = self:GetHideButtons() and 0 or self:GetTall()
    local track = self:GetWide() - btnSize * 2 - self.btnGrip:GetWide()
    self:SetScroll(x * self.CanvasSize / track)
end
function PANEL:Grip()
    self.BaseClass.Grip(self)
    self.HoldPos = self.btnGrip:ScreenToLocal(gui.MouseX(), 0)
end
function PANEL:PerformLayout()
    local h, w = self:GetTall(), self:GetWide()
    local btnSize = self:GetHideButtons() and 0 or h
    local ratio = self.Scroll / self.CanvasSize
    local grip = math.max(self:BarScale() * (w - btnSize * 2), 10)
    local track = w - btnSize * 2 - grip + 1
    self.btnGrip:SetSize(grip, h)
    self.btnGrip:SetPos(btnSize + ratio * track, 0)
    if btnSize > 0 then
        self.btnLeft:SetSize(btnSize, h)
        self.btnLeft:SetPos(0, 0)
        self.btnLeft:SetVisible(true)
        self.btnRight:SetSize(btnSize, h)
        self.btnRight:SetPos(w - btnSize, 0)
        self.btnRight:SetVisible(true)
    else
        self.btnLeft:SetVisible(false)
        self.btnRight:SetVisible(false)
    end
end
vgui.Register("liaHorizontalScrollBar", PANEL, "DVScrollBar")