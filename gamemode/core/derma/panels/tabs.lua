local PANEL = {}
function PANEL:Init()
    self.tabs = {}
    self.active_id = 1
    self.tab_height = 38
    self.animation_speed = 8
    self.tab_style = "modern"
    self.indicator_height = 2
    self.panel_tabs = vgui.Create("Panel", self)
    self.panel_tabs.Paint = nil
    self.content = vgui.Create("Panel", self)
    self.content.Paint = nil
end
function PANEL:SetTabStyle(style)
    self.tab_style = style
    self:Rebuild()
end
function PANEL:SetTabHeight(height)
    self.tab_height = height
    self:Rebuild()
end
function PANEL:SetIndicatorHeight(height)
    self.indicator_height = height
    self:Rebuild()
end
function PANEL:AddTab(name, pan, icon)
    local newId = #self.tabs + 1
    self.tabs[newId] = {
        name = name,
        pan = pan,
        icon = icon
    }
    self.tabs[newId].pan:SetParent(self.content)
    self.tabs[newId].pan:Dock(FILL)
    self.tabs[newId].pan:SetVisible(newId == 1 and true or false)
    self:Rebuild()
end
function PANEL:AddSheet(label, panel, material)
    local newId = #self.tabs + 1
    self:AddTab(label, panel, material)
    return {
        Button = self.panel_tabs:GetChildren()[newId],
        Panel = panel
    }
end
function PANEL:Rebuild()
    self.panel_tabs:Clear()
    if self.tab_style == 'modern' then
        local tabWidths = {}
        local baseMargin = 6
        for id, tab in ipairs(self.tabs) do
            surface.SetFont('LiliaFont.18')
            local textW = surface.GetTextSize(tab.name)
            local iconW = tab.icon and 16 or 0
            local iconTextGap = tab.icon and 8 or 0
            local padding = 16
            local minWidth = 80
            local btnWidth = math.max(minWidth, padding + iconW + iconTextGap + textW + padding)
            tabWidths[id] = btnWidth
        end
        self._tabWidths = tabWidths
        self._baseMargin = baseMargin
        for id, tab in ipairs(self.tabs) do
            local btnTab = vgui.Create('Button', self.panel_tabs)
            local btnWidth = tabWidths[id] or 80
            btnTab:Dock(LEFT)
            btnTab:DockMargin(0, 0, id < #self.tabs and baseMargin or 0, 0)
            btnTab:SetTall(34)
            btnTab:SetWide(btnWidth)
            btnTab:SetText('')
            btnTab.DoClick = function()
                self.tabs[self.active_id].pan:SetVisible(false)
                tab.pan:SetVisible(true)
                self.active_id = id
                surface.PlaySound('button_click.wav')
            end
            btnTab.DoRightClick = function()
                local dm = lia.derma.dermaMenu()
                for k, v in pairs(self.tabs) do
                    dm:AddOption(v.name, function()
                        self.tabs[self.active_id].pan:SetVisible(false)
                        v.pan:SetVisible(true)
                        self.active_id = k
                    end, v.icon)
                end
            end
            btnTab.Paint = function(_, w, h)
                local isActive = self.active_id == id
                local colorText = isActive and lia.color.theme.theme or lia.color.theme.text
                local colorIcon = isActive and lia.color.theme.theme or color_white
                if self.tab_style == 'modern' then
                    if isActive then lia.derma.rect(0, h - self.indicator_height, w, self.indicator_height):Color(lia.color.theme.theme):Draw() end
                    local iconW = tab.icon and 16 or 0
                    local iconTextGap = tab.icon and 8 or 0
                    local contentWidth = iconW + iconTextGap + surface.GetTextSize(tab.name)
                    local startX = (w - contentWidth) / 2
                    local textX = startX + (iconW > 0 and (iconW + iconTextGap) or 0)
                    if tab.icon then lia.derma.drawMaterial(0, startX, (h - 16) * 0.5, 16, 16, colorIcon, tab.icon) end
                    draw.SimpleText(tab.name, 'LiliaFont.18', textX, h * 0.5, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    local iconW = tab.icon and 16 or 0
                    local iconTextGap = tab.icon and 8 or 0
                    local contentWidth = iconW + iconTextGap + surface.GetTextSize(tab.name)
                    local startX = (w - contentWidth) / 2
                    local textX = startX + (iconW > 0 and (iconW + iconTextGap) or 0)
                    if tab.icon then
                        lia.derma.drawMaterial(0, startX, (h - 16) * 0.5, 16, 16, colorIcon, tab.icon)
                    else
                        lia.derma.rect(startX, (h - 16) * 0.5, 16, 16):Rad(24):Color(colorIcon):Shape(lia.derma.SHAPE_IOS):Draw()
                    end
                    draw.SimpleText(tab.name, 'LiliaFont.18', textX, h * 0.5 - 1, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
    function PANEL:PerformLayout()
        if self.tab_style == 'modern' then
            self.panel_tabs:Dock(TOP)
            self.panel_tabs:DockMargin(0, 0, 0, 4)
            self.panel_tabs:SetTall(self.tab_height)
            if self._tabWidths and #self.tabs > 0 then
                local totalTabsWidth = 0
                for _, width in pairs(self._tabWidths) do
                    totalTabsWidth = totalTabsWidth + width
                end
                local availableWidth = self:GetWide()
                local totalMargins = self._baseMargin * (#self.tabs - 1)
                local extraSpace = availableWidth - totalTabsWidth - totalMargins
                if extraSpace > 0 and #self.tabs > 1 then
                    local extraPerTab = math.floor(extraSpace / #self.tabs)
                    local adjustedWidths = {}
                    for tabId, baseWidth in pairs(self._tabWidths) do
                        adjustedWidths[tabId] = baseWidth + extraPerTab
                    end
                    local remainder = extraSpace % #self.tabs
                    if remainder > 0 then
                        for remainderId = 1, math.min(remainder, #self.tabs) do
                            adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                        end
                    end
                    local children = self.panel_tabs:GetChildren()
                    for childId, child in ipairs(children) do
                        if adjustedWidths[childId] then child:SetWide(adjustedWidths[childId]) end
                    end
                end
            end
        else
            self.panel_tabs:Dock(LEFT)
            self.panel_tabs:DockMargin(0, 0, 4, 0)
            local maxWidth = 0
            for _, classicTab in ipairs(self.tabs) do
                surface.SetFont('LiliaFont.18')
                local textW = surface.GetTextSize(classicTab.name)
                local iconW = classicTab.icon and 16 or 0
                local iconTextGap = classicTab.icon and 8 or 0
                local padding = 16
                local minWidth = 120
                local btnWidth = math.max(minWidth, padding + iconW + iconTextGap + textW + padding)
                maxWidth = math.max(maxWidth, btnWidth)
            end
            self.panel_tabs:SetWide(math.max(190, maxWidth))
        end
    end
    self.content:Dock(FILL)
end
function PANEL:SetActiveTab(tab)
    if type(tab) == 'number' then
        if not self.tabs[tab] then return end
        if self.tabs[self.active_id] and IsValid(self.tabs[self.active_id].pan) then self.tabs[self.active_id].pan:SetVisible(false) end
        if IsValid(self.tabs[tab].pan) then self.tabs[tab].pan:SetVisible(true) end
        self.active_id = tab
        local button = self.panel_tabs:GetChild(tab)
        if IsValid(button) then self.m_pActiveTab = button end
    else
        for searchId, data in ipairs(self.tabs) do
            if data.pan == tab or self.panel_tabs:GetChild(searchId) == tab then
                self:SetActiveTab(searchId)
                break
            end
        end
    end
end
function PANEL:GetActiveTab()
    return self.panel_tabs:GetChild(self.active_id)
end
function PANEL:CloseTab(tab)
    local id
    if type(tab) == 'number' then
        id = tab
    else
        for k, data in ipairs(self.tabs) do
            if data.pan == tab or self.panel_tabs:GetChild(k) == tab then
                id = k
                break
            end
        end
    end
    if not id or not self.tabs[id] then return end
    local panel = self.tabs[id].pan
    if IsValid(panel) then panel:Remove() end
    table.remove(self.tabs, id)
    self.active_id = math.Clamp(self.active_id, 1, #self.tabs)
    self:Rebuild()
end
function PANEL:SetFadeTime()
end
function PANEL:SetShowIcons()
end
vgui.Register('liaTabs', PANEL, 'Panel')