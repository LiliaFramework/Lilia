function MODULE:DrawWatermark()
    local w, h = 64, 64
    surface.SetMaterial(Material(SCHEMA.Logo))
    surface.SetDrawColor(255, 255, 255, 80)
    surface.DrawTexturedRect(5, ScrH() - h - 5, w, h)
    surface.SetTextColor(255, 255, 255, 80)
    surface.SetFont("WB_XLarge")
    local _, th = surface.GetTextSize(SCHEMA.Version)
    surface.SetTextPos(15 + w, ScrH() + 15 - h / 2 - th / 2)
    surface.DrawText(SCHEMA.Version)
end

function MODULE:ShouldDrawWatermark()
    return SCHEMA.Version and isstring(SCHEMA.Version) and SCHEMA.Logo and isstring(SCHEMA.Logo) and self.WatermarkEnabled
end