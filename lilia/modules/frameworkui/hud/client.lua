function MODULE:ShouldHideBars()
    if self.BarsDisabled then return false end
end

function MODULE:HUDShouldDraw(element)
    if table.HasValue(self.HiddenHUDElements, element) then return false end
end

function MODULE:HUDPaintBackground()
    if self:ShouldDrawBranchWarning() then self:DrawBranchWarning() end
    if self:ShouldDrawBlur() then self:DrawBlur() end
    self:RenderEntities()
end

function MODULE:HUDPaint()
    local weapon = LocalPlayer():GetActiveWeapon()
    if self:ShouldDrawAmmo(weapon) then self:DrawAmmo(weapon) end
    if self:ShouldDrawAmmoHUD() then self:DrawCrosshair() end
    if self:ShouldDrawVignette() then self:DrawVignette() end
end

function MODULE:ForceDermaSkin()
    return self.DarkTheme and "lilia_darktheme" or "lilia"
end