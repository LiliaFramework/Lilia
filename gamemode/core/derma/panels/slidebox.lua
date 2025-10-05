﻿local PANEL = {}
function PANEL:Init()
    self.text = ""
    self.min_value = 0
    self.max_value = 1
    self.decimals = 0
    self.convar = nil
    self.value = 0
    self.smoothPos = 0
    self.targetPos = 0
    self.dragging = false
    self.hover = false
    self:SetTall(60)
    self.OnValueChanged = function() end
    self._convar_last = nil
    self._convar_timer = self:CreateConVarSyncTimer()
    self._dragAlpha = 255
end

function PANEL:CreateConVarSyncTimer()
    return timer.Create("liaSlideBoxSync" .. tostring(self), 0.1, 0, function()
        if not IsValid(self) or not self.convar then return end
        local cvar = GetConVar(self.convar)
        if not cvar then return end
        local val = cvar:GetFloat()
        if self._convar_last ~= val then
            self._convar_last = val
            self:SetValue(val, true)
        end
    end)
end

function PANEL:OnRemove()
    timer.Remove('liaSlideBoxSync' .. tostring(self))
end

function PANEL:SetRange(min_value, max_value, decimals)
    self.min_value = min_value
    self.max_value = max_value
    self.decimals = decimals or 0
    self:SetValue(self.value or min_value)
end

function PANEL:SetConvar(convar)
    self.convar = convar
    local cvar = GetConVar(convar)
    if cvar then
        self:SetValue(cvar:GetFloat(), true)
        self._convar_last = cvar:GetFloat()
    end
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:SetValue(val, fromConVar)
    val = math.Clamp(val, self.min_value, self.max_value)
    if self.decimals > 0 then
        val = math.Round(val, self.decimals)
    else
        val = math.Round(val)
    end

    self.value = val
    local progress = (val - self.min_value) / (self.max_value - self.min_value)
    self.targetPos = math.Clamp((self:GetWide() - 32) * progress, 0, self:GetWide() - 32)
    if self.convar and not fromConVar then
        RunConsoleCommand(self.convar, tostring(val))
        self._convar_last = val
    end

    if self.OnValueChanged then self:OnValueChanged(val) end
end

function PANEL:GetValue()
    return self.value
end

function PANEL:UpdateSliderByCursorPos(x)
    local progress = math.Clamp(x / (self:GetWide() - 32), 0, 1)
    local new_value = self.min_value + (progress * (self.max_value - self.min_value))
    if self.decimals > 0 then
        new_value = math.Round(new_value, self.decimals)
    else
        new_value = math.Round(new_value)
    end

    self:SetValue(new_value)
end

function PANEL:Paint(w)
    local padX = 16
    local padTop = 2
    local barY = 32
    local barH = 6
    local barR = barH / 2
    local handleW, handleH = 14, 14
    local handleR = handleH / 2
    local textFont = 'Fated.18'
    local minmaxFont = 'Fated.14'
    local valueFont = 'Fated.16'
    local minmaxPadY = 12
    draw.SimpleText(self.text, textFont, padX, padTop, lia.color.theme.text)
    local barStart = padX + handleW / 2
    local barEnd = w - padX - handleW / 2
    local barW = barEnd - barStart
    local progress = (self.value - self.min_value) / (self.max_value - self.min_value)
    local activeW = math.Clamp(barW * progress, 0, barW)
    lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.window_shadow):Shadow(5, 20):Draw()
    lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.focus_panel):Draw()
    lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.button_shadow):Draw()
    lia.derma.rect(barStart, barY, self.smoothPos, barH):Rad(barR):Color(lia.color.theme.theme):Draw()
    self.smoothPos = Lerp(FrameTime() * 12, self.smoothPos or 0, activeW)
    local handleX = barStart + self.smoothPos
    local handleY = barY + barH / 2
    lia.derma.drawShadows(handleR, handleX - handleW / 2, handleY - handleH / 2, handleW, handleH, lia.color.theme.window_shadow, 3, 10)
    local targetAlpha = self.dragging and 100 or 255
    self._dragAlpha = Lerp(FrameTime() * 10, self._dragAlpha, targetAlpha)
    local colorText = Color(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, self._dragAlpha)
    lia.derma.rect(handleX - handleW / 2, handleY - handleH / 2, handleW, handleH):Rad(handleR):Color(colorText):Draw()
    draw.SimpleText(self.value, valueFont, barEnd + handleW / 2 + 15, barY + barH / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.min_value, minmaxFont, barStart, barY + barH + minmaxPadY - 4, lia.color.theme.gray, TEXT_ALIGN_LEFT)
    draw.SimpleText(self.max_value, minmaxFont, barEnd, barY + barH + minmaxPadY - 4, lia.color.theme.gray, TEXT_ALIGN_RIGHT)
end

function PANEL:OnMousePressed(mcode)
    if mcode == MOUSE_LEFT then
        local x = self:CursorPos()
        self:UpdateSliderByCursorPos(x)
        self.dragging = true
        self:MouseCapture(true)
        self.ripple_x = x
        self.ripple_anim = 0
        self.ripple_active = true
    end
end

function PANEL:OnMouseReleased(mcode)
    if mcode == MOUSE_LEFT then
        self.dragging = false
        self:MouseCapture(false)
    end
end

function PANEL:OnCursorMoved(x)
    if self.dragging then self:UpdateSliderByCursorPos(x) end
end

function PANEL:OnCursorEntered()
    self.hover = true
end

function PANEL:OnCursorExited()
    self.hover = false
end

vgui.Register('liaSlideBox', PANEL, 'Panel')
