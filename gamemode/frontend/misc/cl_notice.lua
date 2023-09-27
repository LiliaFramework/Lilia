
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
    surface.SetDrawColor(230, 230, 230, 10)
    surface.DrawRect(0, 0, w, h)
    if self.start then
        local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
        surface.SetDrawColor(lia.config.Color)
        surface.DrawRect(w2, 0, w - w2, h)
    end

    surface.SetDrawColor(0, 0, 0, 25)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaNotice", PANEL, "DLabel")

local PANEL = {}

function PANEL:Init()
    self.padding = 60
    self:SetSize(256, 36)
    self:SetContentAlignment(5)
    self.text = self:Add("DLabel")
    self.text:SetText("Unassigned")
    self.text:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.text:SetFont("liaMediumFont")
    self.text:SetTextColor(color_white)
    self.text:SetDrawOnTop(true)
    function self.text.Think(this)
        this:SizeToContents()
        this:Center()
    end
end

function PANEL:CalcWidth(padding)
    self.text:SizeToContents()
    self:SetWide(self.text:GetWide() + padding)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(230, 230, 230, 10)
    surface.DrawRect(0, 0, w, h)
    if self.start then
        local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
        surface.SetDrawColor(lia.config.Color)
        surface.DrawRect(w2, 0, w - w2, h)
    end

    surface.SetDrawColor(0, 0, 0, 45)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("noticePanel", PANEL, "DPanel")
