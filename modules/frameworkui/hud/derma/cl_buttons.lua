local animDuration = 0.3
local function PaintButton(self, w, h)
    local r, g, b = lia.config.get("Color")
    if self.Base then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(1, 1, w - 2, h - 2)
    end

    draw.SimpleText(self:GetText(), self:GetFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if self:IsHovered() or self:IsSelected() then
        self.startTime = self.startTime or CurTime()
        local elapsed = CurTime() - self.startTime
        local anim = math.min(w, elapsed / animDuration * w) / 2
        surface.SetDrawColor(r, g, b)
        surface.DrawLine(w / 2 - anim, h - 1, w / 2 + anim, h - 1)
    else
        self.startTime = nil
    end
    return true
end

local function RegisterButton(name, font, base)
    local PANEL = {}
    function PANEL:Init()
        self:SetFont(font)
        self.Selected = false
        self.Base = base
    end

    function PANEL:SetSelected(state)
        self.Selected = state
    end

    function PANEL:IsSelected()
        return self.Selected
    end

    function PANEL:Paint(w, h)
        return PaintButton(self, w, h)
    end

    vgui.Register(name, PANEL, "DButton")
end

RegisterButton("liaNoBGButton", "liaBigFont", false)
RegisterButton("liaBigButton", "liaBigFont", true)
RegisterButton("liaMediumButton", "liaMediumFont", true)
RegisterButton("liaSmallButton", "liaSmallFont", true)
