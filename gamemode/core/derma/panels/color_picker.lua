local PANEL = {}
local color_close = Color(210, 65, 65)
local color_accept = Color(44, 124, 62)
local color_target = Color(255, 255, 255, 200)
function PANEL:Init()
    self.selected_color = Color(255, 255, 255)
    self.hue = 0
    self.saturation = 1
    self.value = 1
    self.callback = nil
    self:DockPadding(10, 10, 10, 10)
    local preview = vgui.Create("liaBasePanel", self)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h)
        lia.rndx.Rect(2, 2, w - 4, h - 4):Rad(16):Color(lia.color.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.rndx.Rect(2, 2, w - 4, h - 4):Rad(16):Color(self.selected_color):Shape(lia.rndx.SHAPE_IOS):Draw()
    end

    self.preview = preview
    local colorField = vgui.Create("liaBasePanel", self)
    colorField:Dock(TOP)
    colorField:SetTall(200)
    colorField:DockMargin(0, 0, 0, 10)
    self.colorField = colorField
    local colorCursor = {
        x = 0,
        y = 0
    }

    local isDraggingColor = false
    colorField.OnMousePressed = function(s, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = true
            s:OnCursorMoved(s:CursorPos())
            surface.PlaySound('garrysmod/ui_click.wav')
        end
    end

    colorField.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingColor = false end end
    colorField.OnCursorMoved = function(s, x, y)
        if isDraggingColor then
            local w, h = s:GetSize()
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)
            colorCursor.x = x
            colorCursor.y = y
            self.saturation = x / w
            self.value = 1 - (y / h)
            self:UpdateColor()
        end
    end

    colorField.Paint = function(_, w, h)
        local segments = 80
        local segmentSize = w / segments
        lia.rndx.Rect(0, 0, w, h):Color(lia.color.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(5, 20):Draw()
        for x = 0, segments do
            for y = 0, segments do
                local s_val = x / segments
                local v_val = 1 - (y / segments)
                local segX = x * segmentSize
                local segY = y * segmentSize
                surface.SetDrawColor(HSVToColor(self.hue, s_val, v_val))
                surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
            end
        end

        lia.rndx.Circle(colorCursor.x, colorCursor.y, 12):Outline(2):Color(color_target):Draw()
    end

    local hueSlider = vgui.Create("liaBasePanel", self)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(20)
    hueSlider:DockMargin(0, 0, 0, 10)
    self.hueSlider = hueSlider
    local huePos = 0
    local isDraggingHue = false
    hueSlider.OnMousePressed = function(s, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = true
            s:OnCursorMoved(s:CursorPos())
            surface.PlaySound('garrysmod/ui_click.wav')
        end
    end

    hueSlider.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingHue = false end end
    hueSlider.OnCursorMoved = function(s, x, _)
        if isDraggingHue then
            local w = s:GetWide()
            x = math.Clamp(x, 0, w)
            huePos = x
            self.hue = (x / w) * 360
            self:UpdateColor()
        end
    end

    hueSlider.Paint = function(_, w, h)
        local segments = 100
        local segmentWidth = w / segments
        lia.rndx.Rect(0, 0, w, h):Color(lia.color.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(5, 20):Draw()
        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth
            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        lia.rndx.Rect(huePos - 2, 0, 4, h):Color(color_target):Draw()
    end

    local btnContainer = vgui.Create("liaBasePanel", self)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)
    btnContainer.Paint = nil
    local btnClose = vgui.Create("liaButton", btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(90)
    btnClose:SetText(L("color_cancel"))
    btnClose:SetColorHover(color_close)
    btnClose.DoClick = function()
        self:Remove()
        surface.PlaySound('garrysmod/ui_click.wav')
    end

    local btnSelect = vgui.Create("liaButton", btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetText(L("color_select"))
    btnSelect:SetColorHover(color_accept)
    btnSelect.DoClick = function()
        if self.callback then self.callback(self.selected_color) end
        self:Remove()
        surface.PlaySound('garrysmod/ui_click.wav')
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = self.saturation * colorField:GetWide()
            colorCursor.y = (1 - self.value) * colorField:GetTall()
            huePos = (self.hue / 360) * hueSlider:GetWide()
        end
    end)
end

function PANEL:UpdateColor()
    self.selected_color = HSVToColor(self.hue, self.saturation, self.value)
    if IsValid(self.preview) then self.preview:InvalidateLayout() end
end

function PANEL:SetColor(color)
    if color then
        local r, g, b = color.r / 255, color.g / 255, color.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        self.hue = h
        self.saturation = s
        self.value = v
        self.selected_color = color
        self:UpdateColor()
    end
end

function PANEL:GetColor()
    return self.selected_color
end

function PANEL:OnCallback(callback)
    self.callback = callback
end

function PANEL:Paint(_, _)
end

function PANEL:SetVector(vec)
    if vec and vec.r and vec.g and vec.b then self:SetColor(Color(vec.r, vec.g, vec.b)) end
end

function PANEL:GetVector()
    local color = self:GetColor()
    if color then return Vector(color.r / 255, color.g / 255, color.b / 255) end
    return Vector(1, 1, 1)
end

function PANEL:SetWangs(wang)
    self.wangs = wang
end

function PANEL:GetWangs()
    return self.wangs or 0
end

function PANEL:SetConVarR(convar)
    self.convarR = convar
    if convar then
        local cvar = GetConVar(convar)
        if cvar then
            local color = self:GetColor()
            if color then cvar:SetInt(color.r) end
        end
    end
end

function PANEL:SetConVarG(convar)
    self.convarG = convar
    if convar then
        local cvar = GetConVar(convar)
        if cvar then
            local color = self:GetColor()
            if color then cvar:SetInt(color.g) end
        end
    end
end

function PANEL:SetConVarB(convar)
    self.convarB = convar
    if convar then
        local cvar = GetConVar(convar)
        if cvar then
            local color = self:GetColor()
            if color then cvar:SetInt(color.b) end
        end
    end
end

function PANEL:SetConVarA(convar)
    self.convarA = convar
    if convar then
        local cvar = GetConVar(convar)
        if cvar then
            local color = self:GetColor()
            if color then cvar:SetInt(color.a or 255) end
        end
    end
end

vgui.Register("liaColorPicker", PANEL, "EditablePanel")
