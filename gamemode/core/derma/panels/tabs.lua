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
    self.scroll_offset = 0
    self.max_visible_tabs = 5
    self.nav_button_size = 24
    self.btn_left = nil
    self.btn_right = nil
    self.needs_navigation = false
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
function PANEL:CreateNavigationButtons()
    if self.btn_left then
        self.btn_left:Remove()
        self.btn_right:Remove()
    end
    if not self.needs_navigation then return end
    self.btn_left = vgui.Create("Button", self.panel_tabs)
    self.btn_left:Dock(LEFT)
    self.btn_left:SetWide(self.nav_button_size)
    self.btn_left:SetTall(self.tab_height - 4)
    self.btn_left:DockMargin("2", "2", "2", "2")
    self.btn_left:SetText("")
    self.btn_left.DoClick = function()
        self:ScrollTabs(-1)
    end
    self.btn_left.Paint = function(_, w, h)
        if self.scroll_offset > 0 then
            draw.SimpleText("◀", "LiliaFont.18", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("◀", "LiliaFont.18", w / 2, h / 2, Color(100, 100, 100, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    self.btn_right = vgui.Create("Button", self.panel_tabs)
    self.btn_right:Dock(RIGHT)
    self.btn_right:SetWide(self.nav_button_size)
    self.btn_right:SetTall(self.tab_height - 4)
    self.btn_right:DockMargin("2", "2", "2", "2")
    self.btn_right:SetText("")
    self.btn_right.DoClick = function()
        self:ScrollTabs(1)
    end
    self.btn_right.Paint = function(_, w, h)
        local max_scroll = math.max(0, #self.tabs - self.max_visible_tabs)
        if self.scroll_offset < max_scroll then
            draw.SimpleText("▶", "LiliaFont.18", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("▶", "LiliaFont.18", w / 2, h / 2, Color(100, 100, 100, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end
function PANEL:ScrollTabs(direction)
    local max_scroll = math.max(0, #self.tabs - self.max_visible_tabs)
    self.scroll_offset = math.Clamp(self.scroll_offset + direction, 0, max_scroll)
    if direction < 0 and self.scroll_offset == 0 then
        surface.PlaySound("buttons/button10.wav")
    elseif direction > 0 and self.scroll_offset >= max_scroll then
        surface.PlaySound("buttons/button10.wav")
    else
        surface.PlaySound("buttons/button14.wav")
    end
    self:UpdateTabVisibility()
end
function PANEL:UpdateTabVisibility()
    self:InvalidateLayout()
end
function PANEL:Rebuild()
    self.panel_tabs:Clear()
    self.needs_navigation = #self.tabs > self.max_visible_tabs
    if self.tab_style == "modern" then
        local tabWidths = {}
        local baseMargin = 6
        for id, tab in ipairs(self.tabs) do
            surface.SetFont("LiliaFont.18")
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
        self:CreateNavigationButtons()
        for id, tab in ipairs(self.tabs) do
            local btnTab = vgui.Create("Button", self.panel_tabs)
            local btnWidth = tabWidths[id] or 80
            btnTab:Dock(LEFT)
            btnTab:DockMargin(0, 0, id < #self.tabs and baseMargin or 0, 0)
            btnTab:SetTall(34)
            btnTab:SetWide(btnWidth)
            btnTab:SetText("")
            btnTab.DoClick = function()
                self.tabs[self.active_id].pan:SetVisible(false)
                tab.pan:SetVisible(true)
                self.active_id = id
                surface.PlaySound("button_click.wav")
                self:UpdateActiveTabVisual()
            end
            btnTab.DoRightClick = function()
                local dm = lia.derma.dermaMenu()
                for k, v in pairs(self.tabs) do
                    dm:AddOption(v.name, function()
                        self.tabs[self.active_id].pan:SetVisible(false)
                        v.pan:SetVisible(true)
                        self.active_id = k
                        self:UpdateActiveTabVisual()
                    end, v.icon)
                end
            end
            btnTab.Paint = function(_, w, h)
                local isActive = self.active_id == id
                local colorText = isActive and lia.color.theme.theme or lia.color.theme.text
                local colorIcon = isActive and lia.color.theme.theme or color_white
                if self.tab_style == "modern" then
                    if isActive then lia.derma.rect(0, h - self.indicator_height, w, self.indicator_height):Color(lia.color.theme.theme):Draw() end
                    local iconW = tab.icon and 16 or 0
                    local iconTextGap = tab.icon and 8 or 0
                    local contentWidth = iconW + iconTextGap + surface.GetTextSize(tab.name)
                    local startX = (w - contentWidth) / 2
                    local textX = startX + (iconW > 0 and (iconW + iconTextGap) or 0)
                    if tab.icon then lia.derma.drawMaterial(0, startX, (h - 16) * 0.5, 16, 16, colorIcon, tab.icon) end
                    draw.SimpleText(tab.name, "LiliaFont.18", textX, h * 0.5, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
                    draw.SimpleText(tab.name, "LiliaFont.18", textX, h * 0.5 - 1, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
    function PANEL:PerformLayout()
        if self.tab_style == "modern" then
            self.panel_tabs:Dock(TOP)
            self.panel_tabs:DockMargin(0, 0, 0, 4)
            self.panel_tabs:SetTall(self.tab_height)
            if #self.tabs > 0 then
                local navButtonWidth = (self.needs_navigation and self.nav_button_size * 2) or 0
                local availableWidth = self:GetWide() - navButtonWidth
                local visibleTabs = self.needs_navigation and self.max_visible_tabs or #self.tabs
                visibleTabs = math.min(visibleTabs, math.max(#self.tabs - self.scroll_offset, 0))
                if visibleTabs > 0 then
                    local totalMargins = self._baseMargin * (visibleTabs - 1)
                    local widthPool = math.max(availableWidth - totalMargins, 0)
                    local widthPerTab = math.floor(widthPool / visibleTabs)
                    local remainder = widthPool % visibleTabs
                    local children = self.panel_tabs:GetChildren()
                    local tab_children = {}
                    for _, child in ipairs(children) do
                        if child != self.btn_left and child != self.btn_right then
                            table.insert(tab_children, child)
                        end
                    end
                    local startIndex = self.scroll_offset + 1
                    local endIndex = self.scroll_offset + visibleTabs
                    for i, child in ipairs(tab_children) do
                        if i >= startIndex and i <= endIndex then
                            child:SetVisible(true)
                            local slotIndex = i - self.scroll_offset
                            local finalWidth = widthPerTab + ((slotIndex <= remainder) and 1 or 0)
                            child:SetWide(finalWidth)
                            child:DockMargin(0, 0, (slotIndex < visibleTabs) and self._baseMargin or 0, 0)
                        else
                            child:SetVisible(false)
                        end
                    end
                end
            end
        else
            self.panel_tabs:Dock(LEFT)
            self.panel_tabs:DockMargin(0, 0, 4, 0)
            local maxWidth = 0
            for _, classicTab in ipairs(self.tabs) do
                surface.SetFont("LiliaFont.18")
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
    self:UpdateTabVisibility()
    end
function PANEL:UpdateActiveTabVisual()
    if self.needs_navigation then
        local max_scroll = math.max(0, #self.tabs - self.max_visible_tabs)
        if self.active_id <= self.scroll_offset then
            self.scroll_offset = math.max(0, self.active_id - 1)
        elseif self.active_id > self.scroll_offset + self.max_visible_tabs then
            self.scroll_offset = math.min(max_scroll, self.active_id - self.max_visible_tabs)
        end
        self:UpdateTabVisibility()
    end
end
function PANEL:SetActiveTab(tab)
    if type(tab) == "number" then
        if not self.tabs[tab] then return end
        if self.tabs[self.active_id] and IsValid(self.tabs[self.active_id].pan) then self.tabs[self.active_id].pan:SetVisible(false) end
        if IsValid(self.tabs[tab].pan) then self.tabs[tab].pan:SetVisible(true) end
        self.active_id = tab
        local button = self.panel_tabs:GetChild(tab)
        if IsValid(button) then self.m_pActiveTab = button end
        self:UpdateActiveTabVisual()
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
    if type(tab) == "number" then
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
vgui.Register("liaTabs", PANEL, "Panel")