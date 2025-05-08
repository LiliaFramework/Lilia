local PANEL = {}
function PANEL:Init()
    lia.gui.menu = self
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.noAnchor = CurTime() + 0.4
    self.anchorMode = true
    self.invKey = lia.keybind.get("Open Inventory", KEY_I)
    local sidebar = self:Add("DPanel")
    sidebar:Dock(RIGHT)
    sidebar:SetWide(200)
    sidebar.Paint = function() end
    self.sidebar = sidebar
    local scroll = sidebar:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:SetPadding(30)
    scroll:DockMargin(0, 20, 0, 0)
    scroll:SetPaintBackground(false)
    self.scroll = scroll
    local tabs = scroll:Add("DListLayout")
    tabs:Dock(FILL)
    self.tabs = tabs
    local panel = self:Add("EditablePanel")
    panel:Dock(FILL)
    panel:SetAlpha(0)
    panel.Paint = function() end
    self.panel = panel
    local btnDefs = {}
    hook.Run("CreateMenuButtons", btnDefs)
    local keys = {}
    for key in pairs(btnDefs) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b) return #L(a) < #L(b) end)
    self.tabList = {}
    for _, key in ipairs(keys) do
        local cb = btnDefs[key]
        if type(cb) == "string" then
            local body = cb
            if body:sub(1, 4) == "http" then
                cb = function(p)
                    local html = p:Add("DHTML")
                    html:Dock(FILL)
                    html:OpenURL(body)
                end
            else
                cb = function(p)
                    local html = p:Add("DHTML")
                    html:Dock(FILL)
                    html:SetHTML(body)
                end
            end
        end

        local tab = self:addTab(key, cb, key)
        self.tabList[key] = tab
    end

    self:MakePopup()
    self:setActiveTab(L("status"))
end

function PANEL:addTab(name, callback, uniqueID)
    local colors = lia.color.ReturnMainAdjustedColors()
    local text = L(name)
    local tab = self.tabs:Add("liaSmallButton")
    tab:SetText(text)
    tab:SetFont("liaMediumFont")
    tab:SetTextColor(colors.text)
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    tab:SetContentAlignment(5)
    tab:Dock(TOP)
    tab:SetTall(50)
    tab:DockMargin(0, 0, 10, 10)
    tab.text_color = colors.text
    tab.DoClick = function()
        if IsValid(lia.gui.info) then lia.gui.info:Remove() end
        for _, t in pairs(self.tabList) do
            t:SetSelected(false)
        end

        tab:SetSelected(true)
        self.activeTab = tab
        lastMenuTab = uniqueID
        self.panel:Clear()
        self.panel:AlphaTo(255, 0.3, 0)
        if callback then callback(self.panel) end
    end
    return tab
end

function PANEL:setActiveTab(key)
    local tab = self.tabList[key]
    if IsValid(tab) then
        tab:DoClick()
        tab:SetSelected(true)
    end
end

function PANEL:remove()
    CloseDermaMenus()
    if not self.closing then
        self:AlphaTo(0, 0.25, 0, function() self:Remove() end)
        self.closing = true
    end
end

function PANEL:OnKeyCodePressed(key)
    self.noAnchor = CurTime() + 0.5
    if key == KEY_F1 or key == self.invKey then self:remove() end
end

function PANEL:Update()
    self:Remove()
    vgui.Create("liaMenu")
end

function PANEL:Think()
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then
        self:remove()
        return
    end

    if input.IsKeyDown(KEY_F1) and CurTime() > self.noAnchor and self.anchorMode then
        self.anchorMode = false
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    if not self.anchorMode and not input.IsKeyDown(KEY_F1) and not IsValid(self.info) then self:remove() end
end

function PANEL:Paint()
    lia.util.drawBlur(self)
end

vgui.Register("liaMenu", PANEL, "EditablePanel")