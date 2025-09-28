local PANEL = {}
function PANEL:Init()
    self.title = ""
    self.expanded = true
    self.categoryColor = table.Copy(lia.color.theme.accent)
    self.headerHeight = 40
    self.contentPadding = 10
    self.animationTime = 0.3
    self.animationStart = 0
    self.contentHeight = 0
    self.header = vgui.Create("liaButton", self)
    self.header:Dock(TOP)
    self.header:DockMargin(0, 0, 0, 5)
    self.header:SetText(self.title or "")
    self.header:SetTall(self.headerHeight)
    self.header.DoClick = function() self:Toggle() end
    self.header.PaintOver = function(_, w, h) self:PaintHeader(w, h) end
    self.content = vgui.Create("liaBasePanel", self)
    self.content:Dock(FILL)
    self.content:DockMargin(self.contentPadding, self.headerHeight + 5, self.contentPadding, self.contentPadding)
    self.content.Paint = nil
end

function PANEL:PaintHeader(w, h)
    local arrowSize = 8
    local arrowX = w - 20
    local arrowY = h * 0.5 - arrowSize * 0.5
    local arrowColor = self.categoryColor
    surface.SetDrawColor(arrowColor.r, arrowColor.g, arrowColor.b, arrowColor.a)
    local poly = {
        {
            x = arrowX,
            y = arrowY
        },
        {
            x = arrowX + arrowSize,
            y = arrowY + arrowSize * 0.5
        },
        {
            x = arrowX,
            y = arrowY + arrowSize
        }
    }

    surface.DrawPoly(poly)
    draw.SimpleText(self.title, "Fated.18", 14, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:Toggle()
    self.expanded = not self.expanded
    self.animationStart = CurTime()
    if self.expanded then
        self.content:Show()
        self.content:InvalidateLayout(true)
    else
        self.content:Hide()
    end

    surface.PlaySound("garrysmod/ui_click.wav")
end

function PANEL:Paint(w, h)
    if not self.expanded then
        local progress = math.Clamp((CurTime() - self.animationStart) / self.animationTime, 0, 1)
        local height = h - self.headerHeight - 5
        local currentHeight = height * (1 - progress)
        if currentHeight > 0 then
            lia.rndx.Rect(0, self.headerHeight + 5, w, currentHeight):Rad(12):Color(lia.color.theme.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(6, 22):Draw()
            lia.rndx.Rect(0, self.headerHeight + 5, w, currentHeight):Rad(12):Color(lia.color.theme.focus_panel):Shape(lia.rndx.SHAPE_IOS):Draw()
        end
    end
end

function PANEL:PerformLayout(_, _)
    self.header:DockMargin(0, 0, 0, 5)
    self.header:SetTall(self.headerHeight)
    if self.expanded then
        self.content:DockMargin(self.contentPadding, self.headerHeight + 5, self.contentPadding, self.contentPadding)
    else
        self.content:DockMargin(self.contentPadding, self.headerHeight + 5, self.contentPadding, 0)
    end
end

function PANEL:SetTitle(title)
    self.title = title
    if IsValid(self.header) then self.header:SetText(title or "") end
end

function PANEL:GetTitle()
    return self.title
end

function PANEL:SetLabel(title)
    self:SetTitle(title)
end

function PANEL:SetCategoryColor(color)
    self.categoryColor = table.Copy(color)
end

function PANEL:GetCategoryColor()
    return self.categoryColor
end

function PANEL:SetExpanded(expanded)
    if self.expanded ~= expanded then
        self.expanded = expanded
        self.animationStart = CurTime()
        if self.expanded then
            self.content:Show()
            self.content:InvalidateLayout(true)
        else
            self.content:Hide()
        end
    end
end

function PANEL:GetExpanded()
    return self.expanded
end

function PANEL:AddItem(item)
    if isstring(item) then
        local label = vgui.Create("liaText", self.content)
        label:SetText(item)
        label:Dock(TOP)
        label:DockMargin(0, 0, 0, 5)
        label:SetTextColor(lia.color.theme.text)
        return label
    else
        item:SetParent(self.content)
        item:Dock(TOP)
        item:DockMargin(0, 0, 0, 5)
        return item
    end
end

function PANEL:Add(item)
    return self:AddItem(item)
end

function PANEL:RemoveItem(panel)
    if IsValid(panel) and panel:GetParent() == self.content then panel:Remove() end
end

function PANEL:SetHeaderHeight(height)
    self.headerHeight = height
    if IsValid(self.header) then self.header:SetTall(height) end
end

function PANEL:GetHeaderHeight()
    return self.headerHeight
end

function PANEL:SetExpanded(expanded)
    if self.expanded ~= expanded then
        self.expanded = expanded
        self.animationStart = CurTime()
        if expanded then
            self.content:Show()
            self.content:InvalidateLayout(true)
        else
            self.content:Hide()
        end
    end
end

function PANEL:GetExpanded()
    return self.expanded
end

function PANEL:Toggle()
    self.expanded = not self.expanded
    self.animationStart = CurTime()
    if self.expanded then
        self.content:Show()
        self.content:InvalidateLayout(true)
    else
        self.content:Hide()
    end

    surface.PlaySound("garrysmod/ui_click.wav")
end

function PANEL:SetShowToggleButton(show)
    self.showToggleButton = show
end

function PANEL:GetShowToggleButton()
    return self.showToggleButton ~= false
end

vgui.Register("liaCategory", PANEL, "Panel")
