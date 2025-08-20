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

local function RegisterButton(name, defaultFont, useBase)
    local PANEL = {}
    PANEL.DefaultFont = defaultFont or name:match("lia(%w+)Button") .. "Font"
    PANEL.Base = useBase
    function PANEL:Init()
        self:SetFont(self.DefaultFont)
        self.Selected = false
    end

    function PANEL:SetFont(font)
        self.ButtonFont = font
    end

    function PANEL:GetFont()
        return self.ButtonFont
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

RegisterButton("liaHugeButton", "liaHugeFont", true)
RegisterButton("liaBigButton", "liaBigFont", true)
RegisterButton("liaMediumButton", "liaMediumFont", true)
RegisterButton("liaSmallButton", "liaSmallFont", true)
RegisterButton("liaMiniButton", "liaMiniFont", true)
RegisterButton("liaNoBGButton", "liaBigFont", false)
