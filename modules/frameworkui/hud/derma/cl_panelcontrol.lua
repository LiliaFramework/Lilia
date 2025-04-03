local PANEL = {}
function PANEL:Init()
    self:SetDrawOnTop(true)
    self.DeleteContentsOnClose = false
    self:SetText("")
    self:SetFont("liaToolTipText")
end

function PANEL:UpdateColours()
    return self:SetTextStyleColor(Color(255, 255, 255))
end

function PANEL:SetContents(panel, bDelete)
    panel:SetParent(self)
    self.Contents = panel
    self.DeleteContentsOnClose = bDelete or false
    self.Contents:SizeToContents()
    self:InvalidateLayout(true)
    self.Contents:SetVisible(false)
end

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
    if y < 2 then y = 2 end
    self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()), math.Clamp(y, 0, ScrH() - self:GetTall()))
end

function PANEL:Paint(w, h)
    self:PositionTooltip()
    local override = hook.Run("TooltipPaint", self, w, h)
    if override then return end
    derma.SkinHook("Paint", "Tooltip", self, w, h)
end

function PANEL:OpenForPanel(panel)
    self.TargetPanel = panel
    self:PositionTooltip()
    hook.Run("TooltipInitialize", self, panel)
    if 0.01 > 0 then
        self:SetVisible(false)
        timer.Simple(0.01, function()
            if not IsValid(self) then return end
            if not IsValid(panel) then return end
            self:PositionTooltip()
            self:SetVisible(true)
        end)
    end
end

function PANEL:Close()
    if not self.DeleteContentsOnClose and self.Contents then
        self.Contents:SetVisible(false)
        self.Contents:SetParent(nil)
    end

    self:Remove()
end

derma.DefineControl("DTooltip", "", PANEL, "DLabel")
local tblRow = vgui.RegisterTable({
    Init = function(self)
        self:Dock(TOP)
        self.Label = self:Add("DLabel")
        self.Label:Dock(LEFT)
        self.Label:DockMargin(4, 2, 2, 2)
        self.Container = self:Add("Panel")
        self.Container:Dock(FILL)
    end,
    PerformLayout = function(self)
        self:SetTall(20)
        self.Label:SetWide(self:GetWide() * 0.45)
    end,
    Setup = function(self, rowType, vars)
        self.Container:Clear()
        local Name = "DProperty_" .. rowType
        if not vgui.GetControlTable(Name) then
            if rowType == "Bool" then rowType = "Boolean" end
            if rowType == "Vector" then rowType = "Generic" end
            if rowType == "Angle" then rowType = "Generic" end
            if rowType == "String" then rowType = "Generic" end
            Name = "DProperty_" .. rowType
        end

        if vgui.GetControlTable(Name) then
            self.Inner = self.Container:Add(Name)
        else
            print("DProperties: Failed to create panel (" .. Name .. ")")
        end

        if not IsValid(self.Inner) then self.Inner = self.Container:Add("DProperty_Generic") end
        self.Inner:SetRow(self)
        self.Inner:Dock(FILL)
        self.Inner:Setup(vars)
        self.Inner:SetEnabled(self:IsEnabled())
        self.IsEnabled = function(self) return self.Inner:IsEnabled() end
        self.SetEnabled = function(self, b) self.Inner:SetEnabled(b) end
    end,
    SetValue = function(self, val)
        if self.CacheValue and self.CacheValue == val then return end
        self.CacheValue = val
        if IsValid(self.Inner) then self.Inner:SetValue(val) end
    end,
    Paint = function(self, w, h)
        if not IsValid(self.Inner) then return end
        local Skin = self:GetSkin()
        local editing = self.Inner:IsEditing()
        local disabled = not self.Inner:IsEnabled() or not self:IsEnabled()
        if disabled then
            surface.SetDrawColor(Skin.Colours.Properties.Column_Disabled)
            surface.DrawRect(w * 0.45, 0, w, h)
        elseif editing then
            surface.SetDrawColor(Skin.Colours.Properties.Column_Selected)
            surface.DrawRect(0, 0, w * 0.45, h)
        end

        surface.SetDrawColor(Skin.Colours.Properties.Border)
        surface.DrawRect(w - 1, 0, 1, h)
        surface.DrawRect(w * 0.45, 0, 1, h)
        surface.DrawRect(0, h - 1, w, 1)
        if disabled then
            self.Label:SetTextColor(Skin.Colours.Properties.Label_Disabled)
        elseif editing then
            self.Label:SetTextColor(Skin.Colours.Properties.Label_Selected)
        else
            self.Label:SetTextColor(Skin.Colours.Properties.Label_Normal)
        end
    end
}, "Panel")

local tblCategory = vgui.RegisterTable({
    Init = function(self)
        self:Dock(TOP)
        self.Rows = {}
        self.Header = self:Add("Panel")
        self.Label = self.Header:Add("DLabel")
        self.Label:Dock(FILL)
        self.Label:SetContentAlignment(4)
        self.Expand = self.Header:Add("DExpandButton")
        self.Expand:Dock(LEFT)
        self.Expand:SetSize(16, 16)
        self.Expand:DockMargin(0, 4, 0, 4)
        self.Expand:SetExpanded(true)
        self.Expand.DoClick = function()
            self.Container:SetVisible(not self.Container:IsVisible())
            self.Expand:SetExpanded(self.Container:IsVisible())
            self:InvalidateLayout()
        end

        self.Header:Dock(TOP)
        self.Container = self:Add("Panel")
        self.Container:Dock(TOP)
        self.Container:DockMargin(16, 0, 0, 0)
        self.Container.Paint = function(pnl, w, h)
            surface.SetDrawColor(Color(52, 54, 59, 255))
            surface.DrawRect(0, 0, w, h)
        end
    end,
    PerformLayout = function(self)
        self.Container:SizeToChildren(false, true)
        self:SizeToChildren(false, true)
        local Skin = self:GetSkin()
        self.Label:SetTextColor(Skin.Colours.Properties.Title)
        self.Label:DockMargin(4, 0, 0, 0)
    end,
    GetRow = function(self, name, bCreate)
        if IsValid(self.Rows[name]) then return self.Rows[name] end
        if not bCreate then return end
        local row = self.Container:Add(tblRow)
        row.Label:SetText(name)
        self.Rows[name] = row
        return row
    end,
    Paint = function(self, w, h)
        local Skin = self:GetSkin()
        surface.SetDrawColor(Skin.Colours.Properties.Border)
        surface.DrawRect(0, 0, w, h)
    end
}, "Panel")

local PANEL = {}
function PANEL:Init()
    self.Categories = {}
end

function PANEL:PerformLayout()
    self:SizeToChildren(false, true)
end

function PANEL:Clear()
    self:GetCanvas():Clear()
end

function PANEL:GetCanvas()
    if not IsValid(self.Canvas) then
        self.Canvas = self:Add("DScrollPanel")
        self.Canvas:Dock(FILL)
    end
    return self.Canvas
end

function PANEL:GetCategory(name, bCreate)
    local cat = self.Categories[name]
    if IsValid(cat) then return cat end
    if not bCreate then return end
    cat = self:GetCanvas():Add(tblCategory)
    cat.Label:SetText(name)
    self.Categories[name] = cat
    return cat
end

function PANEL:CreateRow(category, name)
    local cat = self:GetCategory(category, true)
    return cat:GetRow(name, true)
end

derma.DefineControl("DProperties", "", PANEL, "Panel")