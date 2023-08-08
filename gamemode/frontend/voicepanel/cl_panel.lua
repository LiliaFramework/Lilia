--------------------------------------------------------------------------------------------------------
local PANEL = {}
local nsVoicePanels = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    local hi = vgui.Create("DLabel", self)
    hi:SetFont("liaIconsMedium")
    hi:Dock(LEFT)
    hi:DockMargin(8, 0, 8, 0)
    hi:SetTextColor(color_white)
    hi:SetText("i")
    hi:SetWide(30)

    self.LabelName = vgui.Create("DLabel", self)
    self.LabelName:SetFont("liaMediumFont")
    self.LabelName:Dock(FILL)
    self.LabelName:DockMargin(0, 0, 0, 0)
    self.LabelName:SetTextColor(color_white)

    self.Color = color_transparent

    self:SetSize(280, 32 + 8)
    self:DockPadding(4, 4, 4, 4)
    self:DockMargin(2, 2, 2, 2)
    self:Dock(BOTTOM)
end
--------------------------------------------------------------------------------------------------------
function PANEL:Setup(client)
    self.client = client
    self.name = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:Nick()
    self.LabelName:SetText(self.name)
    self:InvalidateLayout()
end
--------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
    if (!IsValid(self.client)) then return end

    lia.util.drawBlur(self, 1, 2)

    surface.SetDrawColor(0, 0, 0, 50 + self.client:VoiceVolume() * 50)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(255, 255, 255, 50 + self.client:VoiceVolume() * 120)
    surface.DrawOutlinedRect(0, 0, w, h)
end
--------------------------------------------------------------------------------------------------------
function PANEL:Think()
    if (IsValid(self.client)) then
        self.LabelName:SetText(self.name)
    end

    if (self.fadeAnim) then
        self.fadeAnim:Run()
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:FadeOut(anim, delta, data)
    if (anim.Finished) then
        if (IsValid(nsVoicePanels[self.client])) then
            nsVoicePanels[self.client]:Remove()
            nsVoicePanels[self.client] = nil
            return
        end
        return
    end

    self:SetAlpha(255 - (255 * (delta * 2)))
end
--------------------------------------------------------------------------------------------------------
vgui.Register("VoicePanel", PANEL, "DPanel")
--------------------------------------------------------------------------------------------------------