function MODULE:ShouldHideBars()
    return self.BarsDisabled
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
    if self:ShouldDrawCrosshair() then self:DrawCrosshair() end
    if self:ShouldDrawVignette() then self:DrawVignette() end
end

function MODULE:ForceDermaSkin()
    return self.DarkTheme and "lilia_darktheme" or "lilia"
end

function MODULE:ShowPlayerCard(target)
    self.F3 = vgui.Create("DFrame")
    self.F3:SetSize(ScrW() * 0.35, ScrH() * 0.25)
    self.F3:Center()
    self.F3:SetTitle(target:Name())
    self.F3:MakePopup()
    local name = self.F3:Add("DLabel")
    name:SetFont("liaMediumFont")
    name:SetPos(ScrW() * 0.35 * 0.5, 30)
    name:SetText(target:Name())
    name:SizeToContents()
    name:SetTextColor(Color(255, 255, 255, 255))
    name:CenterHorizontal()
    local scroll = self.F3:Add("DScrollPanel")
    scroll:SetPos(0, 50)
    scroll:SetSize(ScrW() * 0.35 - 40, ScrH() * 0.25 - 20)
    scroll:Center()
    function scroll:Paint()
    end

    local desc = scroll:Add("DLabel")
    desc:SetPos(0, 0)
    desc:SetFont("liaSmallFont")
    desc:SetText("Description: " .. target:getChar():getDesc())
    desc:SetAutoStretchVertical(true)
    desc:SetWrap(true)
    desc:SetSize(ScrW() * 0.35, 10)
    desc:SetTextColor(Color(255, 255, 255, 255))
    desc:PerformLayout()
    local teamLabel = scroll:Add("DLabel")
    teamLabel:SetPos(0, desc:GetTall() + 10)
    teamLabel:SetFont("liaSmallFont")
    teamLabel:SetText("Team: " .. team.GetName(target:Team()))
    teamLabel:SetTextColor(Color(255, 255, 255, 255))
    teamLabel:PerformLayout()
    local healthLabel = scroll:Add("DLabel")
    healthLabel:SetPos(0, teamLabel:GetTall() + desc:GetTall() + 20)
    healthLabel:SetFont("liaSmallFont")
    healthLabel:SetText("Health: " .. target:Health())
    healthLabel:SetTextColor(Color(255, 255, 255, 255))
    healthLabel:PerformLayout()
    local armorLabel = scroll:Add("DLabel")
    armorLabel:SetPos(0, healthLabel:GetTall() + teamLabel:GetTall() + desc:GetTall() + 30)
    armorLabel:SetFont("liaSmallFont")
    armorLabel:SetText("Armor: " .. target:Armor())
    armorLabel:SetTextColor(Color(255, 255, 255, 255))
    armorLabel:PerformLayout()
    local pingLabel = scroll:Add("DLabel")
    pingLabel:SetPos(0, armorLabel:GetTall() + healthLabel:GetTall() + teamLabel:GetTall() + desc:GetTall() + 40)
    pingLabel:SetFont("liaSmallFont")
    pingLabel:SetText("Ping: " .. target:Ping())
    pingLabel:SetTextColor(Color(255, 255, 255, 255))
    pingLabel:PerformLayout()
end
