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
        surface.SetDrawColor(lia.config.get("Color"))
        surface.DrawRect(w2, 0, w - w2, h)
    end

    surface.SetDrawColor(0, 0, 0, 25)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaNotice", PANEL, "DLabel")
PANEL = {}
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
        surface.SetDrawColor(lia.config.get("Color"))
        surface.DrawRect(w2, 0, w - w2, h)
    end

    surface.SetDrawColor(0, 0, 0, 45)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("noticePanel", PANEL, "DPanel")
PANEL = {}
local baseSizeW, baseSizeH = ScrW() / 5, 20
function PANEL:Init()
    self.message = markup.Parse("")
    self:SetSize(baseSizeW, baseSizeH)
    self.startTime = CurTime()
    self.endTime = CurTime() + 10
end

function PANEL:SetMessage(...)
    local msg = "<font=liaMediumFont>"
    for _, v in ipairs({...}) do
        if istable(v) then
            msg = msg .. "<color=" .. v.r .. "," .. v.g .. "," .. v.b .. ">"
        elseif type(v) == "Player" then
            local col = team.GetColor(v:Team())
            msg = msg .. "<color=" .. col.r .. "," .. col.g .. "," .. col.b .. ">" .. tostring(v:Name()):gsub("<", "&lt;"):gsub(">", "&gt;") .. "</color>"
        else
            msg = msg .. tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
        end
    end

    msg = msg .. "</font>"
    self.message = markup.Parse(msg, baseSizeW - 20)
    local shiftHeight = self.message:GetHeight()
    self:SetHeight(shiftHeight + baseSizeH)
    surface.PlaySound("buttons/lightswitch2.wav")
end

local gradient = Material("vgui/gradient-r")
local darkCol = lia.config.get("Color")
function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(ColorAlpha(lia.config.get("Color"), 5))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(darkCol)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, 0, w, h)
    self.message:Draw(10, 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    local w2 = math.TimeFraction(self.startTime, self.endTime, CurTime()) * w
    surface.SetDrawColor(lia.config.get("Color"))
    surface.DrawRect(w2, h - 2, w - w2, 2)
end

vgui.Register("liaNotify", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    self.type = 1
    self.text = self:Add("DLabel")
    self.text:SetFont("liaNoticeFont")
    self.text:SetContentAlignment(5)
    self.text:SetTextColor(color_white)
    self.text:SizeToContents()
    self.text:Dock(FILL)
    self.text:DockMargin(2, 2, 2, 2)
    self.text:SetExpensiveShadow(1, Color(25, 25, 25, 120))
    self:SetTall(28)
end

function PANEL:setType(value)
    self.type = value
    return
end

function PANEL:setText(value)
    self.text:SetText(value)
end

function PANEL:setFont(value)
    self.text:SetFont(value)
end

function PANEL:Paint()
    self.material = lia.util.getMaterial(lia.notices.Types[self.type].icon)
    local col = lia.notices.Types[self.type].col
    local mat = self.material
    local size = self:GetTall() * .6
    draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), col)
    if mat then
        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(size / 2, self:GetTall() / 2 - size / 2 + 1, size, size)
    end
end

vgui.Register("liaNoticeBar", PANEL, "DPanel")
