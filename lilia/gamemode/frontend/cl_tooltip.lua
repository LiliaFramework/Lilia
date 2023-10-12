--------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetDrawOnTop(true)
    self.DeleteContentsOnClose = false
    self:SetText("")
    self:SetFont("liaToolTipText")
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:UpdateColours(skin)
    return self:SetTextStyleColor(color_black)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:SetContents(panel, bDelete)
    panel:SetParent(self)
    self.Contents = panel
    self.DeleteContentsOnClose = bDelete or false
    self.Contents:SizeToContents()
    self:InvalidateLayout(true)
    self.Contents:SetVisible(false)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:PerformLayout()
    local override = hook.Run("TooltipLayout", self)
    if override then return end
    if self.Contents then
        self:SetWide(self.Contents:GetWide() + 8)
        self:SetTall(self.Contents:GetTall() + 8)
        self.Contents:SetPos(4, 4)
    else
        local w, h = self:GetContentSize()
        self:SetSize(w + 8, h + 6)
        self:SetContentAlignment(5)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:PositionTooltip()
    if not IsValid(self.TargetPanel) then
        self:Remove()

        return
    end

    self:PerformLayout()
    local x, y = input.GetCursorPos()
    local w, h = self:GetSize()
    local _, ly = self.TargetPanel:LocalToScreen(0, 0)
    y = y - 50
    y = math.min(y, ly - h * 1.5)
    if y < 2 then
        y = 2
    end

    self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()), math.Clamp(y, 0, ScrH() - self:GetTall()))
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
    self:PositionTooltip()
    local override = hook.Run("TooltipPaint", self, w, h)
    if override then return end
    derma.SkinHook("Paint", "Tooltip", self, w, h)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:OpenForPanel(panel)
    self.TargetPanel = panel
    self:PositionTooltip()
    hook.Run("TooltipInitialize", self, panel)
    if 0.01 > 0 then
        self:SetVisible(false)
        timer.Simple(
            0.01,
            function()
                if not IsValid(self) then return end
                if not IsValid(panel) then return end
                self:PositionTooltip()
                self:SetVisible(true)
            end
        )
    end
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:Close()
    if not self.DeleteContentsOnClose and self.Contents then
        self.Contents:SetVisible(false)
        self.Contents:SetParent(nil)
    end

    self:Remove()
end

--------------------------------------------------------------------------------------------------------------------------
derma.DefineControl("DTooltip", "", PANEL, "DLabel")
--------------------------------------------------------------------------------------------------------------------------