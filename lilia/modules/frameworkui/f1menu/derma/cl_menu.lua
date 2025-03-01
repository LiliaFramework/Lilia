local PANEL = {}
function PANEL:addTab(name, callback, uniqueID)
    local MenuColors = lia.color.ReturnMainAdjustedColors()
    name = L(name)
    local tab = self.tabs:Add("DButton")
    tab:SetText(name)
    tab:SetTextColor(MenuColors.text)
    tab:SetFont("liaMediumFont")
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    tab:SetContentAlignment(5)
    tab:SetTall(50)
    tab:Dock(TOP)
    tab:DockMargin(0, 0, 10, 10)
    tab.text_color = MenuColors.text
    tab.Paint = function(me, w, h)
        local hovered = me:IsHovered()
        if hovered then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            local underlineY = h - 4
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end

        if self.activeTab == me then
            surface.SetDrawColor(color_white)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    tab.DoClick = function(this)
        if IsValid(lia.gui.info) then lia.gui.info:Remove() end
        self.panel:Clear()
        self.panel:AlphaTo(255, 0.5, 0.1)
        self.activeTab = this
        lastMenuTab = uniqueID
        if callback then callback(self.panel, this) end
    end

    self.tabList[name] = tab
    return tab
end

function PANEL:setActiveTab(key)
    if IsValid(self.tabList[key]) then self.tabList[key]:DoClick() end
end

function PANEL:remove()
    CloseDermaMenus()
    if not self.closing then
        self:AlphaTo(0, 0.25, 0, function() self:Remove() end)
        self.closing = true
    end
end

function PANEL:Init()
    lia.gui.menu = self
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.sidebar = self:Add("DPanel")
    self.sidebar:SetSize(200, ScrH())
    self.sidebar:Dock(RIGHT)
    self.sidebar.Paint = function() end
    self.scroll = self.sidebar:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:SetPadding(10)
    self.scroll:SetPaintBackground(false)
    self.tabs = self.scroll:Add("DListLayout")
    self.tabs:Dock(FILL)
    local spacerHeight = 20
    local spacer = self.tabs:Add("DPanel")
    spacer:Dock(TOP)
    spacer:SetTall(spacerHeight)
    spacer.Paint = function() end
    self.tabs.Paint = function() end
    self.panel = self:Add("EditablePanel")
    self.panel:Dock(FILL)
    self.panel:SetAlpha(0)
    self.panel.Paint = function() end
    local tabs = {}
    hook.Run("CreateMenuButtons", tabs)
    local tabNames = {}
    for name, _ in pairs(tabs) do
        table.insert(tabNames, name)
    end

    table.sort(tabNames, function(a, b) return string.len(L(a)) < string.len(L(b)) end)
    self.tabList = {}
    for _, name in ipairs(tabNames) do
        local callback = tabs[name]
        if isstring(callback) then
            local body = callback
            if body:sub(1, 4) == "http" then
                callback = function(panel)
                    local html = panel:Add("DHTML")
                    html:Dock(FILL)
                    html:OpenURL(body)
                end
            else
                callback = function(panel)
                    local html = panel:Add("DHTML")
                    html:Dock(FILL)
                    html:SetHTML(body)
                end
            end
        end

        local tab = self:addTab(L(name), callback, name)
        self.tabList[name] = tab
    end

    self.noAnchor = CurTime() + 0.4
    self.anchorMode = true
    self:MakePopup()
    self:setActiveTab("Status")
end

function PANEL:OnKeyCodePressed(key)
    self.noAnchor = CurTime() + 0.5
    if key == KEY_F1 then self:remove() end
end

function PANEL:Update()
    self:Remove()
    vgui.Create("liaMenu")
end

function PANEL:Think()
    local key = input.IsKeyDown(KEY_F1)
    if key and (self.noAnchor or CurTime() + 0.4) < CurTime() and self.anchorMode then
        self.anchorMode = false
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    if not self.anchorMode then
        if IsValid(self.info) then return end
        if not key then self:remove() end
    end
end

function PANEL:Paint()
    lia.util.drawBlur(self)
end

vgui.Register("liaMenu", PANEL, "EditablePanel")
