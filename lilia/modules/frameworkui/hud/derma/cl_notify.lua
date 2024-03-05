local PANEL = {}
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
        if type(v) == "table" then
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
local darkCol = lia.config.Color
function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(ColorAlpha(lia.config.Color, 5))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(darkCol)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, 0, w, h)
    self.message:Draw(10, 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    local w2 = math.TimeFraction(self.startTime, self.endTime, CurTime()) * w
    surface.SetDrawColor(lia.config.Color)
    surface.DrawRect(w2, h - 2, w - w2, 2)
end

vgui.Register("liaNotify", PANEL, "DPanel")
