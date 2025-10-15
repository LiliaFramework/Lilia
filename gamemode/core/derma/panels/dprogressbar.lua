local PANEL = {}
function PANEL:Init()
    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 5
    self.Text = L("actionInProgress")
    self.BarColor = lia.config.get("Color")
    self.Fraction = 0
    self.GradientMat = Material("vgui/gradient-d")
    self.Font = "liaSmallFont"
end

function PANEL:GetFraction()
    return self.Fraction or 0
end

function PANEL:SetFraction(fraction)
    self.Fraction = fraction or 0
end

function PANEL:SetProgress(startTime, endTime)
    self.StartTime = startTime or CurTime()
    self.EndTime = endTime or self.StartTime + 5
end

function PANEL:SetText(text)
    self.Text = text or ""
end

function PANEL:SetBarColor(color)
    self.BarColor = color or self.BarColor
end

function PANEL:Paint(w, h)
    local frac = math.Clamp(self.Fraction, 0, 1)
    draw.RoundedBox(0, 0, 0, w, h, Color(35, 35, 35, 100))
    surface.SetDrawColor(0, 0, 0, 120)
    surface.DrawOutlinedRect(0, 0, w, h)
    local fillWidth = (w - 8) * frac
    draw.RoundedBox(0, 4, 4, fillWidth, h - 8, self.BarColor)
    surface.SetMaterial(self.GradientMat)
    surface.SetDrawColor(200, 200, 200, 20)
    surface.DrawTexturedRect(4, 4, fillWidth, h - 8)
    local cx, cy = w * 0.5, h * 0.5
    draw.SimpleText(self.Text, self.Font, cx, cy + 2, Color(20, 20, 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.Text, self.Font, cx, cy, Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("liaDProgressBar", PANEL, "DPanel")
