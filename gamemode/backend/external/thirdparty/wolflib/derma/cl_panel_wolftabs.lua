--------------------------------------------------------------------------------------------------------
local PANEL = {}

--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self.tabs = {}
    self.btnTextCol = color_black
    self.btnCol = Color(245, 245, 245)
    self.wpPnlType = "DPanel"
    self.cpCall = nil
    --GET/SET
    AccessorFunc(self, "btnTxtCol", "TextColor")
    AccessorFunc(self, "btnCol", "ButtonColor")
    -- AccessorFunc(self, "wpPnlType", "PanelType", FORCE_STRING)
end

--------------------------------------------------------------------------------------------------------
--Get/Set of pnl type
function PANEL:SetPanelType(pt, setCall)
    self.wpPnlType = pt
    self.cpCall = setCall
end

--------------------------------------------------------------------------------------------------------
function PANEL:GetPanelType()
    return self.wpPnlType, self.cpCall
end

--------------------------------------------------------------------------------------------------------
function PANEL:AddTab(title, onClick)
    self.tabs[#self.tabs + 1] = {
        name = title,
        onClick = onClick
    }
end

--------------------------------------------------------------------------------------------------------
function PANEL:WorkPanel()
    if self.wp and IsValid(self.wp) then
        self.wp:Remove()
    end

    local panel, cCall = self:GetPanelType()
    self.wp = self:Add(panel)
    self.wp:SetSize(self:GetWide(), self:GetTall() - self.scroll:GetTall())
    self.wp:SetPos(0, self.scroll:GetTall())
    self.wp.Paint = nil

    return self.wp
end

--------------------------------------------------------------------------------------------------------
function PANEL:SwitchTab(onClick)
    local er = nil

    if self.OnTabSwitch then
        er = self.OnTabSwitch()
    end

    local wp = self:WorkPanel()

    function wp.Reopen()
        self.SwitchTab(self, onClick)
    end

    onClick(wp, er) --Open Tab

    if self.OnTabSwitchFinished then
        self.OnTabSwitchFinished(er)
    end
end

--------------------------------------------------------------------------------------------------------
function PANEL:ShowTabs()
    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetSize(self:GetWide(), 35)
    self.list = self.scroll:Add("DIconLayout")
    self.list:SetSize(self.scroll:GetSize())
    self.curSel = nil

    --Displaying tabs
    for k, v in pairs(self.tabs) do
        local t = self.list:Add("DButton")
        t:SetText(v.name)
        t:SetFont("WB_Small")
        t:SetColor(self:GetTextColor())
        t:SetSize(self.list:GetWide() / #self.tabs, self.list:GetTall())
        t:SetColorAcc(self:GetButtonColor())
        t:SetupHover(getHovCol(self:GetButtonColor()))

        function t.Paint(this, w, h)
            if self.curSel == this then
                surface.SetDrawColor(this.hoverCol)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(BC_NEUTRAL)
                surface.DrawRect(0, h - 1, w, 1)
            else
                surface.SetDrawColor(this.color)
                surface.DrawRect(0, 0, w, h)
            end
        end

        function t.DoClick(this)
            self.curSel = this
            self:SwitchTab(v.onClick)
        end

        --Open first tab automatically
        if k == 1 then
            t:DoClick()
        end
    end
end

--------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
end

--------------------------------------------------------------------------------------------------------
vgui.Register("WTabs", PANEL, "DPanel")
--------------------------------------------------------------------------------------------------------