function MODULE:DrawWatermark()
    if not self:ShouldDrawWatermark() then return end
    local w, h = 64, 64
    local watermarkLogo = Material(self.WatermarkLogo, "smooth")
    local versionText = tostring(self.GamemodeVersion)
    if isstring(self.WatermarkLogo) and self.WatermarkLogo ~= "" then
        surface.SetMaterial(watermarkLogo)
        surface.SetDrawColor(255, 255, 255, 80)
        surface.DrawTexturedRect(5, ScrH() - h - 5, w, h)
    end

    if versionText ~= "" then
        surface.SetFont("WB_XLarge")
        local _, textHeight = surface.GetTextSize(versionText)
        surface.SetTextColor(255, 255, 255, 80)
        surface.SetTextPos(15 + w, ScrH() - h / 2 - textHeight / 2)
        surface.DrawText(versionText)
    end
end

function MODULE:ShouldDrawWatermark()
    return self.WatermarkEnabled and isstring(self.GamemodeVersion) and self.GamemodeVersion ~= "" and isstring(self.WatermarkLogo) and self.WatermarkLogo ~= ""
end
