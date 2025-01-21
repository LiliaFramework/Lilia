function MODULE:DrawWatermark()
    if not self:ShouldDrawWatermark() then return end
    local w, h = 64, 64
    local watermarkLogoPath = lia.config.get("WatermarkLogo", "")
    local versionText = tostring(lia.config.get("GamemodeVersion", ""))
    if isstring(watermarkLogoPath) and watermarkLogoPath ~= "" then
        local watermarkLogo = Material(watermarkLogoPath, "smooth")
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
    return lia.config.get("WatermarkEnabled", false) and isstring(lia.config.get("GamemodeVersion", "")) and lia.config.get("GamemodeVersion", "") ~= "" and isstring(lia.config.get("WatermarkLogo", "")) and lia.config.get("WatermarkLogo", "") ~= ""
end
