local PANEL = {}
local function getHovCol(col)
    if not col then return end
    return Color(col.r + 10, col.g + 10, col.b + 10, col.a)
end

function PANEL:Init()
    self:SetFont("WB_Small")
    self:SetTextColor(color_black)
    AccessorFunc(self, round, "Round")
    self.round = 4
    self.corners = {true, true, true, true}
    self.accentColor = Color(235, 235, 235)
    self.custHovCol = nil
    self.switchTextColor = false
    self:ReloadColors()
end

function PANEL:ReloadColors()
    self:SetColorAcc(self.accentColor)
    self:SetupHover(self.custHovCol or getHovCol(self.accentColor))
    local colAvg = (self.accentColor.r + self.accentColor.g + self.accentColor.b) / 3
    if colAvg > 155 then
        self:SetTextColor(color_black)
    else
        self:SetTextColor(color_white)
    end
end

function PANEL:SetAccentColor(col, hov, switchTextColor)
    if self.accentColor == col then return end
    if hov then self.custHovCol = hov end
    self.accentColor = col
    self.switchTextColor = switchTextColor or false
    self:ReloadColors()
end

function PANEL:SetupHover(hoverCol)
    if not self.GetColor or not self.SetColor or not self.color then self:SetColorAcc() end
    self.hoverCol = hoverCol
    local function tcolSwitch(this)
        if this.switchTextColor then
            local ncol = nil
            local tcol = this:GetTextColor()
            if tcol == color_black then ncol = color_white end
            if tcol == color_white then ncol = color_black end
            this:SetTextColor(ncol)
        end
    end

    function self:OnCursorEntered()
        if self:GetDisabled() then return end
        self:ColorTo(hoverCol, 0.15)
        tcolSwitch(self)
    end

    function self:OnCursorExited()
        if self:GetDisabled() then return end
        self:ColorTo(self.defaultColor, 0.15)
        tcolSwitch(self)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(self.round, 0, 0, w, h, self.color, unpack(self.corners))
end

vgui.Register("WButton", PANEL, "DButton")
PANEL = {}
function PANEL:Init()
    self:SetFont("WB_Small")
    self:SetColor(color_black)
end

function PANEL:FontSize(fs)
    self:SetFont("WB_" .. fs)
end

function PANEL:PerformLayout()
    self:SizeToContents()
end

vgui.Register("WLabel", PANEL, "DLabel")