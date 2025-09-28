local PANEL = {}
function PANEL:Init()
    self.tabs = {}
    self.active_id = 1
    self.tab_height = 38
    self.animation_speed = 12
    self.tab_style = "modern"
    self.indicator_height = 2
    self.indicator_x = 0
    self.indicator_w = 0
    self.indicator_target_x = 0
    self.indicator_target_w = 0
    self.panel_tabs = vgui.Create("liaBasePanel", self)
    self.panel_tabs.Paint = nil
    self.content = vgui.Create("liaBasePanel", self)
    self.content.Paint = nil
end

function PANEL:Think()
    if self.indicator_x == nil then self.indicator_x = 0 end
    if self.indicator_w == nil then self.indicator_w = 0 end
    if self.indicator_target_x == nil then self.indicator_target_x = 0 end
    if self.indicator_target_w == nil then self.indicator_target_w = 0 end
    self.indicator_x = lia.util.approachExp(self.indicator_x, self.indicator_target_x, self.animation_speed, FrameTime())
    self.indicator_w = lia.util.approachExp(self.indicator_w, self.indicator_target_w, self.animation_speed, FrameTime())
    if math.abs(self.indicator_x - self.indicator_target_x) < 0.5 then self.indicator_x = self.indicator_target_x end
    if math.abs(self.indicator_w - self.indicator_target_w) < 0.5 then self.indicator_w = self.indicator_target_w end
end

function PANEL:SetTabStyle(_)
    self.tab_style = "modern"
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

local color_btn_hovered = Color(255, 255, 255, 10)
function PANEL:Rebuild()
    self.panel_tabs:Clear()
    for id, tab in ipairs(self.tabs) do
        local btnTab = vgui.Create("liaButton", self.panel_tabs)
        tab._btn = btnTab
        if self.tab_style == "modern" then
            surface.SetFont('Fated.18')
            local textW = select(1, surface.GetTextSize(tab.name))
            local iconW = tab.icon and 16 or 0
            local iconTextGap = tab.icon and 8 or 0
            local padding = 16
            local btnWidth = padding + iconW + iconTextGap + textW + padding
            btnTab:Dock(LEFT)
            btnTab:DockMargin(0, 0, 6, 0)
            btnTab:SetTall(34)
            btnTab:SetWide(btnWidth)
        else
            btnTab:Dock(TOP)
            btnTab:DockMargin(0, 0, 0, 6)
            btnTab:SetTall(34)
        end

        btnTab:SetText('')
        btnTab.DoClick = function()
            self.tabs[self.active_id].pan:SetVisible(false)
            tab.pan:SetVisible(true)
            self.active_id = id
            if self.tab_style == 'modern' and tab._btn and IsValid(tab._btn) then
                self.indicator_target_x = tab._btn:GetX()
                self.indicator_target_w = tab._btn:GetWide()
            end

            surface.PlaySound('garrysmod/ui_click.wav')
        end

        btnTab.DoRightClick = function()
            local dm = vgui.Create("liaDermaMenu")
            for k, _ in pairs(self.tabs) do
                dm:AddOption(tab.name, function()
                    self.tabs[self.active_id].pan:SetVisible(false)
                    tab.pan:SetVisible(true)
                    self.active_id = k
                    if self.tab_style == 'modern' and tab._btn then
                        self.indicator_target_x = tab._btn:GetX()
                        self.indicator_target_w = tab._btn:GetWide()
                    end
                end, tab.icon)
            end
        end

        btnTab.Paint = function(s, w, h)
            local isActive = self.active_id == id
            local colorText = isActive and lia.color.theme.accent or lia.color.theme.text
            local colorIcon = isActive and lia.color.theme.accent or Color(255, 255, 255)
            if self.tab_style == 'modern' then
                if s:IsHovered() then lia.rndx.Draw(16, 0, 0, w, h, color_btn_hovered, lia.rndx.SHAPE_IOS + (isActive and lia.rndx.NO_BL + lia.rndx.NO_BR or 0)) end
                local padding = 16
                local iconW = tab.icon and 16 or 0
                local iconTextGap = tab.icon and 8 or 0
                local textX = padding + (iconW > 0 and (iconW + iconTextGap) or 0)
                if tab.icon then lia.rndx.DrawMaterial(0, padding, (h - 16) * 0.5, 16, 16, colorIcon, tab.icon) end
                draw.SimpleText(tab.name, 'Fated.18', textX, h * 0.5, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                if s:IsHovered() then lia.rndx.Draw(24, 0, 0, w, h, color_btn_hovered, lia.rndx.SHAPE_IOS) end
                draw.SimpleText(tab.name, 'Fated.18', 34, h * 0.5 - 1, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                if tab.icon then
                    lia.rndx.DrawMaterial(0, 9, 9, 16, 16, colorIcon, tab.icon)
                else
                    lia.rndx.Draw(24, 9, 9, 16, 16, colorIcon, lia.rndx.SHAPE_IOS)
                end
            end
        end

        self.panel_tabs.Paint = function(_, _, h) if self.tab_style == 'modern' and self.indicator_w > 0 then lia.rndx.Draw(0, self.indicator_x, h - self.indicator_height, self.indicator_w, self.indicator_height, lia.color.theme.accent) end end
    end
end

function PANEL:PerformLayout(_, _)
    if self.tab_style == 'modern' then
        self.panel_tabs:Dock(TOP)
        self.panel_tabs:DockMargin(0, 0, 0, 4)
        self.panel_tabs:SetTall(self.tab_height)
    else
        self.panel_tabs:Dock(LEFT)
        self.panel_tabs:DockMargin(0, 0, 4, 0)
        self.panel_tabs:SetWide(190)
    end

    self.content:Dock(FILL)
    if self.tab_style == 'modern' then
        local activeBtn = nil
        if self.tabs[self.active_id] then activeBtn = self.tabs[self.active_id]._btn end
        if IsValid(activeBtn) then
            self.indicator_target_x = activeBtn:GetX()
            self.indicator_target_w = activeBtn:GetWide()
            if self.indicator_w == 0 and self.indicator_x == 0 then
                self.indicator_x = self.indicator_target_x
                self.indicator_w = self.indicator_target_w
            end
        else
            self.indicator_target_x = 0
            self.indicator_target_w = 0
        end
    end
end

function PANEL:AddSheet(name, panel, icon, _, _, _)
    self:AddTab(name, panel, icon)
    return #self.tabs
end

function PANEL:GetActiveTab()
    return self.active_id
end

function PANEL:SetActiveTab(tab)
    if tab and tab <= #self.tabs then
        self.active_id = tab
        for i, tabData in ipairs(self.tabs) do
            if tabData.pan then tabData.pan:SetVisible(i == tab) end
        end

        if self.tab_style == 'modern' and self.tabs[tab] and self.tabs[tab]._btn then
            self.indicator_target_x = self.tabs[tab]._btn:GetX()
            self.indicator_target_w = self.tabs[tab]._btn:GetWide()
        end
    end
end

function PANEL:GetItems()
    local items = {}
    for i, tab in ipairs(self.tabs) do
        items[i] = {
            Tab = tab._btn,
            Panel = tab.pan,
            Name = tab.name
        }
    end
    return items
end

function PANEL:SetPadding(padding)
    self.padding = padding
end

function PANEL:GetPadding()
    return self.padding or 0
end

vgui.Register("liaTabs", PANEL, "Panel")
