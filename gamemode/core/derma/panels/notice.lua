local TimeFraction, CurTime = math.TimeFraction, CurTime
local surfaceSetDrawColor, surfaceDrawRect, surfaceDrawOutlinedRect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
local PANEL = {}
function PANEL:Init()
    self:SetSize(256, 36)
    self:SetContentAlignment(5)
    self:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self:SetFont("liaNoticeFont")
    self:SetTextColor(color_white)
    self:SetDrawOnTop(true)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 3, 2)
    derma.SkinHook("Paint", "Panel", self, w, h)
    if self.start then
        local w2 = TimeFraction(self.start, self.endTime, CurTime()) * w
        surfaceSetDrawColor(lia.config.get("Color"))
        surfaceDrawRect(w2, 0, w - w2, h)
    end

    surfaceSetDrawColor(lia.config.get("Color"))
    surfaceDrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaNotice", PANEL, "DLabel")
PANEL = {}
function PANEL:Init()
    self.padding = 80
    self:SetSize(400, 60)
    self:SetContentAlignment(5)
    self.text = self:Add("DLabel")
    self.text:SetText(L("unassigned"))
    self.text:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.text:SetFont("liaMediumFont")
    self.text:SetTextColor(color_white)
    self.text:SetDrawOnTop(true)
    function self.text:Think()
        self:SizeToContents()
        self:Center()
    end
end

function PANEL:CalcWidth(padding)
    self.text:SizeToContents()
    self:SetWide(self.text:GetWide() + padding)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    derma.SkinHook("Paint", "Panel", self, w, h)
    if self.start then
        local w2 = TimeFraction(self.start, self.endTime, CurTime()) * w
        surfaceSetDrawColor(lia.config.get("Color"))
        surfaceDrawRect(w2, 0, w - w2, h)
    end

    surfaceSetDrawColor(lia.config.get("Color"))
    surfaceDrawOutlinedRect(0, 0, w, h)
end

vgui.Register("noticePanel", PANEL, "DPanel")