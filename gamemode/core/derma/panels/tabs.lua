local PANEL = {}
function PANEL:Init()
    self.tabs = {}
    self.active_id = 1
    self.tab_height = 38
    self.animation_speed = 8
    self.tab_style = "modern"
    self.indicator_height = 2
    self._tabButtons = {}
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
    self.tab_order = {}
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

function PANEL:AddTab(name, pan, icon, callback)
    local newId = #self.tabs + 1
    self.tabs[newId] = {
        name = name,
        pan = pan,
        icon = icon,
        callback = callback
    }

    if not IsValid(self.panel_tabs) then
        self.panel_tabs = vgui.Create("Panel", self)
        self.panel_tabs.Paint = nil
    end

    if not IsValid(self.content) then
        self.content = vgui.Create("Panel", self)
        self.content.Paint = nil
    end

    self.tabs[newId].pan:SetParent(self.content)
    self.tabs[newId].pan:Dock(FILL)
    self.tabs[newId].pan:SetVisible(newId == 1 and true or false)
    self:Rebuild()
    return self.tabs[newId]
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
    self.btn_left.DoClick = function() self:ScrollTabs(-1) end
    self.btn_left.Paint = function(_, w, h)
        if self.scroll_offset > 0 then
            draw.SimpleText("◀", "LiliaFont.32", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("◀", "LiliaFont.32", w / 2, h / 2, Color(100, 100, 100, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self.btn_right = vgui.Create("Button", self.panel_tabs)
    self.btn_right:Dock(RIGHT)
    self.btn_right:SetWide(self.nav_button_size)
    self.btn_right:SetTall(self.tab_height - 4)
    self.btn_right:DockMargin("2", "2", "2", "2")
    self.btn_right:SetText("")
    self.btn_right.DoClick = function() self:ScrollTabs(1) end
    self.btn_right.Paint = function(_, w, h)
        local max_scroll = math.max(0, #self.tabs - self.max_visible_tabs)
        if self.scroll_offset < max_scroll then
            draw.SimpleText("▶", "LiliaFont.32", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("▶", "LiliaFont.32", w / 2, h / 2, Color(100, 100, 100, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

function PANEL:ScrollTabs(direction)
    local max_scroll = math.max(0, #self.tabs - self.max_visible_tabs)
    self.scroll_offset = math.Clamp(self.scroll_offset + direction, 0, max_scroll)
    if direction < 0 and self.scroll_offset == 0 then
        lia.websound.playButtonSound("buttons/button10.wav")
    elseif direction > 0 and self.scroll_offset >= max_scroll then
        lia.websound.playButtonSound("buttons/button10.wav")
    else
        lia.websound.playButtonSound("buttons/button14.wav")
    end

    self:UpdateTabVisibility()
end

function PANEL:UpdateTabVisibility()
    self:InvalidateLayout()
end

function PANEL:OnSizeChanged()
    self:InvalidateLayout()
end

function PANEL:Rebuild()
    if not IsValid(self.panel_tabs) then
        self.panel_tabs = vgui.Create("Panel", self)
        self.panel_tabs.Paint = nil
        self.panel_tabs:Dock(TOP)
        self.panel_tabs:DockMargin(0, 0, 0, 4)
        self.panel_tabs:SetTall(self.tab_height)
    else
        local children = self.panel_tabs:GetChildren()
        for _, child in ipairs(children) do
            if child ~= self.btn_left and child ~= self.btn_right then child:Remove() end
        end
    end

    self._tabButtons = {}
    if not IsValid(self.content) then
        self.content = vgui.Create("Panel", self)
        self.content.Paint = nil
        self.content:Dock(FILL)
    end

    if self.tab_style == "modern" then
        local tabWidths = {}
        local baseMargin = 6
        for id, tab in ipairs(self.tabs) do
            surface.SetFont("LiliaFont.18")
            local textW = surface.GetTextSize(tab.name)
            local padding = 16
            local minWidth = 80
            local btnWidth = math.max(minWidth, padding + textW + padding)
            tabWidths[id] = btnWidth
        end

        self._tabWidths = tabWidths
        self._baseMargin = baseMargin
        self:CreateNavigationButtons()
        for id, tab in ipairs(self.tabs) do
            local btnTab = vgui.Create("liaTabButton", self.panel_tabs)
            local btnWidth = tabWidths[id] or 80
            btnTab:Dock(LEFT)
            btnTab:DockMargin(0, 0, id < #self.tabs and baseMargin or 0, 0)
            btnTab:SetTall(34)
            btnTab:SetWide(btnWidth)
            btnTab:SetText(tab.name)
            btnTab:SetActive(self.active_id == id)
            btnTab:SetDoClick(function()
                if self.active_id == id then return end
                self:SetActiveTab(id)
            end)

            btnTab.DoRightClick = function()
                local dm = lia.derma.dermaMenu()
                for k, v in pairs(self.tabs) do
                    dm:AddOption(v.name, function() self:SetActiveTab(k) end, v.icon)
                end
            end

            self._tabButtons[id] = btnTab
        end
    end

    self.content:Dock(FILL)
    self:UpdateTabVisibility()
    self:InvalidateLayout()
end

function PANEL:PerformLayout()
    if self.tab_style == "modern" then
        self.panel_tabs:Dock(TOP)
        self.panel_tabs:DockMargin(0, 0, 0, 4)
        self.panel_tabs:SetTall(self.tab_height)
        if #self.tabs > 0 then
            local totalMinRequiredWidth = 0
            for i = 1, #self.tabs do
                totalMinRequiredWidth = totalMinRequiredWidth + (self._tabWidths[i] or 80)
            end

            local totalMarginsForAll = self._baseMargin * (#self.tabs - 1)
            local totalWidthNeeded = totalMinRequiredWidth + totalMarginsForAll
            local needsNavigation = totalWidthNeeded > self:GetWide()
            if needsNavigation ~= self.needs_navigation then
                self.needs_navigation = needsNavigation
                self:CreateNavigationButtons()
            end

            local navButtonWidth = (needsNavigation and self.nav_button_size * 2) or 0
            local availableWidth = math.max(self:GetWide() - navButtonWidth, 0)
            local maxVisibleTabs = needsNavigation and self.max_visible_tabs or #self.tabs
            local visibleTabs = math.min(maxVisibleTabs, math.max(#self.tabs - self.scroll_offset, 0))
            local startIndex = self.scroll_offset + 1
            local endIndex = math.min(self.scroll_offset + visibleTabs, #self.tabs)
            local children = self.panel_tabs:GetChildren()
            local tab_children = {}
            for _, child in ipairs(children) do
                if child ~= self.btn_left and child ~= self.btn_right then table.insert(tab_children, child) end
            end

            local visibleMargins = self._baseMargin * (visibleTabs - 1)
            local visibleMinWidth = 0
            for i = startIndex, endIndex do
                visibleMinWidth = visibleMinWidth + (self._tabWidths[i] or 80)
            end

            local visibleAvailable = math.max(availableWidth - visibleMargins, 0)
            local visibleExtraSpace = visibleAvailable - visibleMinWidth
            for i, child in ipairs(tab_children) do
                local baseWidth = self._tabWidths[i] or 80
                local finalWidth = baseWidth
                if i >= startIndex and i <= endIndex then
                    if visibleExtraSpace > 0 then
                        local extraPerVisibleTab = math.floor(visibleExtraSpace / visibleTabs)
                        local remainder = visibleExtraSpace % visibleTabs
                        local slotIndex = i - self.scroll_offset
                        finalWidth = baseWidth + extraPerVisibleTab + ((slotIndex <= remainder) and 1 or 0)
                    end

                    child:SetVisible(true)
                    local slotIndex = i - self.scroll_offset
                    child:DockMargin(0, 0, (slotIndex < visibleTabs) and self._baseMargin or 0, 0)
                else
                    child:SetVisible(false)
                end

                child:SetWide(finalWidth)
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
    if isnumber(tab) then
        if not self.tabs[tab] then return end
        for _, tabData in ipairs(self.tabs) do
            if IsValid(tabData.pan) then tabData.pan:SetVisible(false) end
        end

        if IsValid(self.tabs[tab].pan) then self.tabs[tab].pan:SetVisible(true) end
        self.active_id = tab
        local button = self._tabButtons and self._tabButtons[tab] or nil
        if IsValid(button) then self.m_pActiveTab = button end
        if self._tabButtons then
            for id, btn in ipairs(self._tabButtons) do
                if IsValid(btn) and btn.SetActive then btn:SetActive(id == tab) end
            end
        end

        self:UpdateActiveTabVisual()
        if self.tabs[tab] and self.tabs[tab].callback then self.tabs[tab].callback() end
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
    return self.tabs[self.active_id]
end

function PANEL:CloseTab(tab)
    local id
    if isnumber(tab) then
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

function PANEL:SortTabsAlphabetically()
    table.sort(self.tabs, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    self:Rebuild()
end

function PANEL:SetTabOrder(order)
    self.tab_order = order or {}
end

function PANEL:ApplyTabOrdering()
    local orderedTabs = {}
    local unorderedTabs = {}
    for _, tab in ipairs(self.tabs) do
        local forcedPosition = self.tab_order[tab.name]
        if forcedPosition and forcedPosition >= 1 and forcedPosition <= #self.tabs then
            orderedTabs[forcedPosition] = tab
        else
            table.insert(unorderedTabs, tab)
        end
    end

    table.sort(unorderedTabs, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    local resultTabs = {}
    local unorderedIndex = 1
    for i = 1, #self.tabs do
        if orderedTabs[i] then
            table.insert(resultTabs, orderedTabs[i])
        elseif unorderedIndex <= #unorderedTabs then
            table.insert(resultTabs, unorderedTabs[unorderedIndex])
            unorderedIndex = unorderedIndex + 1
        end
    end

    for i = unorderedIndex, #unorderedTabs do
        table.insert(resultTabs, unorderedTabs[i])
    end

    self.tabs = resultTabs
    self:Rebuild()
end

function PANEL:SetFadeTime()
end

function PANEL:SetShowIcons()
end

function PANEL:Clear()
    self.tabs = {}
    self.active_id = 1
    self.scroll_offset = 0
    self.needs_navigation = false
    if self.BaseClass and self.BaseClass.Clear then
        self.BaseClass.Clear(self)
    else
        for _, child in ipairs(self:GetChildren()) do
            child:Remove()
        end
    end
end

vgui.Register("liaTabs", PANEL, "Panel")
