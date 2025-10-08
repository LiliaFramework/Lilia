local min, clamp = math.min, math.Clamp
local inputGetCursorPos, isValid = input.GetCursorPos, IsValid
local timerSimple = timer.Simple
local surfaceSetDrawColor, surfaceDrawRect = surface.SetDrawColor, surface.DrawRect
local TooltipPanel = {}
function TooltipPanel:Init()
    self:SetDrawOnTop(true)
    self.DeleteContentsOnClose = false
    self:SetText("")
    self:SetFont("LiliaFont.20")
end

function TooltipPanel:UpdateColours()
    return self:SetTextStyleColor(Color(255, 255, 255))
end

function TooltipPanel:SetContents(panel, bDelete)
    panel:SetParent(self)
    self.Contents = panel
    self.DeleteContentsOnClose = bDelete or false
    panel:SizeToContents()
    self:InvalidateLayout(true)
    panel:SetVisible(false)
end

function TooltipPanel:PerformLayout()
    if hook.Run("TooltipLayout", self) then return end
    if self.Contents then
        local w, h = self.Contents:GetWide(), self.Contents:GetTall()
        self:SetSize(w + 8, h + 8)
        self.Contents:SetPos(4, 4)
    else
        local w, h = self:GetContentSize()
        self:SetSize(w + 8, h + 6)
        self:SetContentAlignment(5)
    end
end

function TooltipPanel:PositionTooltip()
    if not isValid(self.TargetPanel) then
        self:Remove()
        return
    end

    self:PerformLayout()
    local x, y = inputGetCursorPos()
    local w, h = self:GetSize()
    local _, ly = self.TargetPanel:LocalToScreen(0, 0)
    y = min(y - 50, ly - h * 1.5)
    if y < 2 then y = 2 end
    self:SetPos(clamp(x - w * 0.5, 0, ScrW() - w), clamp(y, 0, ScrH() - h))
end

function TooltipPanel:Paint(w, h)
    self:PositionTooltip()
    if hook.Run("TooltipPaint", self, w, h) then return end
    derma.SkinHook("Paint", "Tooltip", self, w, h)
end

function TooltipPanel:OpenForPanel(panel)
    self.TargetPanel = panel
    self:PositionTooltip()
    hook.Run("TooltipInitialize", self, panel)
    self:SetVisible(false)
    timerSimple(0.01, function()
        if not isValid(self) or not isValid(panel) then return end
        self:PositionTooltip()
        self:SetVisible(true)
    end)
end

function TooltipPanel:Close()
    if not self.DeleteContentsOnClose and isValid(self.Contents) then
        self.Contents:SetVisible(false)
        self.Contents:SetParent(nil)
    end

    self:Remove()
end

derma.DefineControl("DTooltip", "", TooltipPanel, "DLabel")
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
        local rt, name = rowType, "DProperty_" .. rowType
        if not vgui.GetControlTable(name) then
            if rt == "Bool" then
                rt = "Boolean"
            elseif rt == "Vector" or rt == "Angle" or rt == "String" then
                rt = "Generic"
            end

            name = "DProperty_" .. rt
        end

        if vgui.GetControlTable(name) then
            self.Inner = self.Container:Add(name)
        else
            self.Inner = self.Container:Add("DProperty_Generic")
        end

        self.Inner:SetRow(self)
        self.Inner:Dock(FILL)
        self.Inner:Setup(vars)
        self.Inner:SetEnabled(self:IsEnabled())
        self.IsEnabled = function() return self.Inner:IsEnabled() end
        self.SetEnabled = function(_, b) self.Inner:SetEnabled(b) end
    end,
    SetValue = function(self, val)
        if self.CacheValue == val then return end
        self.CacheValue = val
        if isValid(self.Inner) then self.Inner:SetValue(val) end
    end,
    Paint = function(self, w, h)
        if not isValid(self.Inner) then return end
        local skin = self:GetSkin()
        local editing = self.Inner:IsEditing()
        local disabled = not self.Inner:IsEnabled() or not self:IsEnabled()
        if disabled then
            surfaceSetDrawColor(skin.Colours.Properties.Column_Disabled)
            surfaceDrawRect(w * 0.45, 0, w, h)
        elseif editing then
            surfaceSetDrawColor(skin.Colours.Properties.Column_Selected)
            surfaceDrawRect(0, 0, w * 0.45, h)
        end

        surfaceSetDrawColor(skin.Colours.Properties.Border)
        surfaceDrawRect(w - 1, 0, 1, h)
        surfaceDrawRect(w * 0.45, 0, 1, h)
        surfaceDrawRect(0, h - 1, w, 1)
        local col = disabled and skin.Colours.Properties.Label_Disabled or editing and skin.Colours.Properties.Label_Selected or skin.Colours.Properties.Label_Normal
        self.Label:SetTextColor(col)
    end
}, "Panel")

local tblCategory = vgui.RegisterTable({
    Init = function(self)
        self:Dock(TOP)
        self.Rows = {}
        self.Header = self:Add("Panel")
        self.Header:Dock(TOP)
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

        self.Container = self:Add("Panel")
        self.Container:Dock(TOP)
        self.Container:DockMargin(16, 0, 0, 0)
        self.Container.Paint = function(_, w, h)
            surfaceSetDrawColor(52, 54, 59, 255)
            surfaceDrawRect(0, 0, w, h)
        end
    end,
    PerformLayout = function(self)
        self.Container:SizeToChildren(false, true)
        self:SizeToChildren(false, true)
        local skin = self:GetSkin()
        self.Label:SetTextColor(skin.Colours.Properties.Title)
        self.Label:DockMargin(4, 0, 0, 0)
    end,
    GetRow = function(self, name, bCreate)
        local row = self.Rows[name]
        if isValid(row) then return row end
        if not bCreate then return end
        row = self.Container:Add(tblRow)
        row.Label:SetText(name)
        self.Rows[name] = row
        return row
    end,
    Paint = function(self, w, h)
        local skin = self:GetSkin()
        surfaceSetDrawColor(skin.Colours.Properties.Border)
        surfaceDrawRect(0, 0, w, h)
    end
}, "Panel")

local PropertiesPanel = {}
function PropertiesPanel:Init()
    self.Categories = {}
end

function PropertiesPanel:PerformLayout()
    self:SizeToChildren(false, true)
end

function PropertiesPanel:Clear()
    if isValid(self.Canvas) then self.Canvas:Clear() end
end

function PropertiesPanel:GetCanvas()
    if not isValid(self.Canvas) then
        self.Canvas = self:Add("liaScrollPanel")
        self.Canvas:Dock(FILL)
    end
    return self.Canvas
end

function PropertiesPanel:GetCategory(name, bCreate)
    local cat = self.Categories[name]
    if isValid(cat) then return cat end
    if not bCreate then return end
    cat = self:GetCanvas():Add(tblCategory)
    cat.Label:SetText(name)
    self.Categories[name] = cat
    return cat
end

function PropertiesPanel:CreateRow(category, name)
    return self:GetCategory(category, true):GetRow(name, true)
end

derma.DefineControl("DProperties", "", PropertiesPanel, "Panel")
