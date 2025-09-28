local PANEL = {}
function PANEL:Init()
    self:SetText("")
    self:SetToggle(true)
    self:SetSize(24, 24)
    self.checked = false
    self.text = ""
    self.textColor = color_white
    self.textFont = "DermaDefault"
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:SetTextColor(color)
    self.textColor = color
end

function PANEL:SetTextFont(font)
    self.textFont = font
end

function PANEL:SetChecked(state)
    self.checked = state and true or false
    self:SetSelected(self.checked)
    if self.OnChange then self.OnChange(self, self.checked) end
end

function PANEL:GetChecked()
    return self.checked
end

function PANEL:DoClick()
    self:SetChecked(not self.checked)
end

function PANEL:Paint()
    local icon = self.checked and "checkbox.png" or "unchecked.png"
    local w, h = self:GetSize()
    lia.util.drawTexture(icon, color_white, 0, 0, w, h)
    if self.text and self.text ~= "" then
        surface.SetFont(self.textFont)
        surface.SetTextColor(self.textColor)
        surface.SetTextPos(28, 2)
        surface.DrawText(self.text)
    end
    return true
end

vgui.Register("liaSimpleCheckbox", PANEL, "liaButton")
PANEL = {}
function PANEL:Init()
    self.text = ''
    self.convar = ''
    self.value = false
    self:SetText('')
    self:SetCursor("hand")
    self:SetTall(36)
    self._circle = 0
    self._circleEased = 0
    self._circleColor = table.Copy(lia.color.theme.gray)
    self.toggle = vgui.Create("liaButton", self)
    self.toggle:Dock(RIGHT)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 14, 0)
    self.toggle:SetText('')
    self.toggle:SetCursor("hand")
    self.toggle.Paint = nil
    self.toggle.DoClick = function()
        if self.convar ~= '' then LocalPlayer():ConCommand(self.convar .. ' ' .. (self.value and 0 or 1)) end
        self:SetValue(not self.value)
        self:OnChange(self.value)
        surface.PlaySound('garrysmod/ui_click.wav')
    end
end

function PANEL:OnMousePressed(mcode)
    if mcode == MOUSE_LEFT then self.toggle:DoClick() end
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:SetValue(val)
    self.value = tobool(val)
end

function PANEL:GetBool()
    return self.value
end

function PANEL:SetConvar(convar)
    local c = GetConVar(convar)
    if c then self.value = c:GetBool() end
    self.convar = convar
end

function PANEL:OnChange(_)
end

function PANEL:GetChecked()
    return self:GetBool()
end

function PANEL:SetChecked(state)
    self:SetValue(tobool(state))
end

function PANEL:Toggle()
    self:SetChecked(not self:GetChecked())
end

function PANEL:Paint(w, h)
    if lia.config.get("uiDepthEnabled", true) then lia.rndx.DrawShadows(12, 0, 0, w, h, lia.color.theme.window_shadow, 6, 22, lia.rndx.SHAPE_IOS) end
    lia.rndx.Draw(12, 0, 0, w, h, lia.color.theme.focus_panel, lia.rndx.SHAPE_IOS)
    local textX = 14
    draw.SimpleText(self.text, 'Fated.18', textX, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PaintOver(_, _)
    local tw, th = self.toggle:GetWide(), self.toggle:GetTall()
    local tx, ty = self.toggle:GetPos()
    local ft = FrameTime()
    local target = self.value and 1 or 0
    local circleSpeed = 8
    self._circle = lia.util.approachExp(self._circle, target, circleSpeed, ft)
    if math.abs(self._circle - target) < 0.001 then self._circle = target end
    self._circleEased = lia.util.easeInOutCubic(self._circle)
    local trackW = tw - 10
    local trackH = 18
    local trackX = tx + (tw - trackW) / 2
    local trackY = ty + (th - trackH) / 2
    lia.rndx.Draw(trackH / 2, trackX, trackY + 1, trackW, trackH - 2, lia.color.theme.toggle, lia.rndx.SHAPE_IOS)
    local circleSize = 20
    local pad = 0
    local textMargin = 14
    local x0_base = trackX + pad - (circleSize * 0.5) + 0.5
    local x1 = trackX + trackW - pad - (circleSize * 0.5) - 0.5
    local x0_align = textMargin - (circleSize * 0.5)
    local x0 = math.max(x0_base, x0_align)
    local circleXPrec = x0 + (x1 - x0) * self._circleEased
    local circleCenterX = circleXPrec + circleSize * 0.5
    local circleCenterY = trackY + trackH * 0.5
    local baseCircle = self.value and lia.color.theme.accent or lia.color.theme.gray
    local circleCol = table.Copy(baseCircle)
    circleCol.a = 255
    self._circleColor = lia.color.Lerp(12, self._circleColor, circleCol)
    lia.rndx.DrawCircle(circleCenterX, circleCenterY, circleSize, self._circleColor)
    lia.rndx.DrawCircle(circleCenterX, circleCenterY + 2, circleSize * 1.05, lia.color.theme.window_shadow)
end

function PANEL:PerformLayout(_, _)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 14, 0)
end

vgui.Register("liaCheckBox", PANEL, "Panel")
