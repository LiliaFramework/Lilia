local PANEL = {}
function PANEL:Init()
    self.value = 0
    self.min = 0
    self.max = 1
    self.decimals = 0
    self.hoverAnim = 0
    self.dragging = false
    self.font = "LiliaFont.18"
    self.text = ""
    self:SetTall(60)
    self.track = vgui.Create("DPanel", self)
    self.track:Dock(TOP)
    self.track:DockMargin(10, 20, 10, 10)
    self.track:SetTall(20)
    self.slider = vgui.Create("DButton", self.track)
    self.slider:Dock(TOP)
    self.slider:DockMargin(0, 0, 0, 0)
    self.slider:SetTall(20)
    self.slider:SetText("")
    self.slider:SetCursor("hand")
    self.slider.Paint = function(s, w, h)
        local trackWidth = w
        local sliderWidth = 20
        local sliderHeight = h
        local sliderX = ((self.value - self.min) / (self.max - self.min)) * (trackWidth - sliderWidth)
        lia.derma.rect(0, 0, trackWidth, sliderHeight):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(3, 10):Draw()
        lia.derma.rect(0, 0, trackWidth, sliderHeight):Rad(16):Color(lia.color.theme.slider_track or Color(60, 60, 60)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(sliderX, 0, sliderWidth, sliderHeight):Rad(16):Color(lia.color.theme.theme):Shape(lia.derma.SHAPE_IOS):Shadow(3, 10):Draw()
        if s:IsHovered() or self.dragging then
            self.hoverAnim = math.Clamp(self.hoverAnim + FrameTime() * 8, 0, 1)
        else
            self.hoverAnim = math.Clamp(self.hoverAnim - FrameTime() * 8, 0, 1)
        end

        if self.hoverAnim > 0 then lia.derma.rect(sliderX, 0, sliderWidth, sliderHeight):Rad(16):Color(Color(lia.color.theme.button_hovered.r, lia.color.theme.button_hovered.g, lia.color.theme.button_hovered.b, self.hoverAnim * 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    end

    self.slider.OnMousePressed = function(_, mouseCode)
        if mouseCode == MOUSE_LEFT then
            self.dragging = true
            self:OnDragStart()
        end
    end

    self.slider.OnMouseReleased = function(_, mouseCode)
        if mouseCode == MOUSE_LEFT then
            self.dragging = false
            self:OnDragEnd()
        end
    end

    self.slider.Think = function(s)
        if self.dragging then
            local parent = s:GetParent()
            local trackWidth = parent:GetWide()
            local sliderWidth = 20
            local fraction = math.Clamp(x / (trackWidth - sliderWidth), 0, 1)
            local newValue = self.min + (self.max - self.min) * fraction
            if self.decimals == 0 then
                newValue = math.Round(newValue)
            else
                newValue = math.Round(newValue, self.decimals)
            end

            if newValue ~= self.value then
                self.value = newValue
                self:OnValueChanged(self.value)
            end
        end
    end

    self.valueLabel = vgui.Create("DLabel", self)
    self.valueLabel:Dock(TOP)
    self.valueLabel:DockMargin(10, 5, 10, 0)
    self.valueLabel:SetTall(20)
    self.valueLabel:SetContentAlignment(5)
    self.valueLabel:SetFont("LiliaFont.16")
end

function PANEL:PerformLayout()
    self.slider:Dock(TOP)
    self.slider:DockMargin(0, 0, 0, 0)
    self.slider:SetTall(20)
end

function PANEL:Paint(w, h)
    lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 150)):Shape(lia.derma.SHAPE_IOS):Draw()
    if IsValid(self.valueLabel) then
        local displayValue = self.decimals == 0 and math.Round(self.value) or math.Round(self.value, self.decimals)
        self.valueLabel:SetText(self.text .. displayValue)
        self.valueLabel:SetTextColor(lia.color.theme.text)
    end
end

function PANEL:SetMin(min)
    self.min = min
    self:UpdateSliderPosition()
end

function PANEL:GetMin()
    return self.min
end

function PANEL:SetMax(max)
    self.max = max
    self:UpdateSliderPosition()
end

function PANEL:GetMax()
    return self.max
end

function PANEL:SetDecimals(decimals)
    self.decimals = decimals
end

function PANEL:GetDecimals()
    return self.decimals
end

function PANEL:SetValue(value)
    self.value = math.Clamp(value, self.min, self.max)
    self:UpdateSliderPosition()
end

function PANEL:GetValue()
    return self.value
end

function PANEL:SetText(text)
    self.text = text or ""
end

function PANEL:GetText()
    return self.text
end

function PANEL:UpdateSliderPosition()
    if IsValid(self.slider) then
        local sliderWidth = 20
        self.slider:SetWide(sliderWidth)
    end
end

function PANEL:OnValueChanged()
end

function PANEL:OnDragStart()
end

function PANEL:OnDragEnd()
end

vgui.Register("liaNumSlider", PANEL, "Panel")
