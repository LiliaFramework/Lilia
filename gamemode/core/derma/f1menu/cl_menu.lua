local PANEL = {}
function PANEL:Init()
    lia.module.list["f1menu"].CharacterInformation = {}
    lia.gui.menu = self
    hook.Run("F1MenuOpened", self)
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.noAnchor = CurTime() + 0.4
    self.anchorMode = true
    self.invKey = lia.keybind.get(L("openInventory"), KEY_I)
    local baseBtnW, btnH, spacing = 150, 40, 20
    self.baseBtnW = baseBtnW
    local topBar = self:Add("DPanel")
    topBar:Dock(TOP)
    topBar:SetTall(70)
    topBar:DockPadding(30, 10, 30, 10)
    local iconMat = Material("lilia.png", "smooth")
    local schemaIconMat = SCHEMA and SCHEMA.icon and Material(SCHEMA.icon, "smooth") or nil
    local schemaName = SCHEMA and SCHEMA.name or nil
    topBar.Paint = function(pnl, w, h)
        lia.util.drawBlur(pnl)
        surface.SetDrawColor(34, 34, 34, 220)
        surface.DrawRect(0, 0, w, h)
        local col = lia.config.get("Color")
        surface.SetDrawColor(col.r, col.g, col.b, 255)
        surface.DrawRect(0, h - 4, w, 4)
        if schemaIconMat and schemaName then
            local iconSize = h * 0.5
            surface.SetMaterial(schemaIconMat)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(30, (h - iconSize) * 0.5, iconSize, iconSize)
            surface.SetFont("liaMediumFont")
            surface.SetTextColor(255, 255, 255)
            local txt = L(schemaName)
            local _, th = surface.GetTextSize(txt)
            surface.SetTextPos(30 + iconSize + 10, (h - th) * 0.5)
            surface.DrawText(txt)
        end

        surface.SetMaterial(iconMat)
        surface.SetDrawColor(255, 255, 255)
        local baseSize = h - 10
        local iconSize = baseSize * 0.9
        local iconY = (h - iconSize) * 0.5
        surface.DrawTexturedRect(w - iconSize - 20, iconY, iconSize, iconSize)
    end

    local leftArrow = topBar:Add("liaSmallButton")
    leftArrow:Dock(LEFT)
    leftArrow:DockMargin(0, 0, spacing, 0)
    leftArrow:SetWide(40)
    leftArrow:SetText("<")
    leftArrow:SetFont("liaMediumFont")
    leftArrow:SetTextColor(color_white)
    leftArrow:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    local rightArrow = topBar:Add("liaSmallButton")
    rightArrow:Dock(RIGHT)
    rightArrow:DockMargin(spacing, 0, 0, 0)
    rightArrow:SetWide(40)
    rightArrow:SetText(">")
    rightArrow:SetFont("liaMediumFont")
    rightArrow:SetTextColor(color_white)
    rightArrow:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    local tabsContainer = topBar:Add("Panel")
    tabsContainer:Dock(FILL)
    function tabsContainer:PerformLayout(w, h)
        local btns = self:GetChildren()
        local totalW = -spacing
        for _, btn in ipairs(btns) do
            totalW = totalW + (btn.calcW or baseBtnW) + spacing
        end

        local overflow = totalW - w
        if overflow > 0 then
            leftArrow:SetVisible(true)
            rightArrow:SetVisible(true)
            self.tabOffset = math.Clamp(self.tabOffset or 0, -overflow, 0)
        else
            leftArrow:SetVisible(false)
            rightArrow:SetVisible(false)
            self.tabOffset = 0
        end

        local x = (w - totalW) * 0.5 + (self.tabOffset or 0)
        for _, btn in ipairs(btns) do
            local bW = btn.calcW or baseBtnW
            btn:SetSize(bW, btnH)
            btn:SetPos(x, (h - btnH) * 0.5)
            x = x + bW + spacing
        end
    end

    leftArrow.DoClick = function()
        tabsContainer.tabOffset = (tabsContainer.tabOffset or 0) + baseBtnW + spacing
        tabsContainer:InvalidateLayout()
    end

    rightArrow.DoClick = function()
        tabsContainer.tabOffset = (tabsContainer.tabOffset or 0) - (baseBtnW + spacing)
        tabsContainer:InvalidateLayout()
    end

    self.tabs = tabsContainer
    local panel = self:Add("EditablePanel")
    panel:Dock(FILL)
    local mX, mY = ScrW() * 0.05, ScrH() * 0.05
    panel:DockMargin(mX, mY, mX, mY)
    panel:SetAlpha(0)
    panel.Paint = function() end
    self.panel = panel
    local btnDefs = {}
    hook.Run("CreateMenuButtons", btnDefs)
    local tabKeys = {}
    for k in pairs(btnDefs) do
        tabKeys[#tabKeys + 1] = k
    end

    table.sort(tabKeys, function(a, b)
        local aName, bName = tostring(L(a)):lower(), tostring(L(b)):lower()
        return aName < bName
    end)

    self.tabList = {}
    for _, key in ipairs(tabKeys) do
        local cb = btnDefs[key]
        if isstring(cb) then
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

        self.tabList[key] = self:addTab(key, cb)
    end

    self:MakePopup()
    local defaultTab = lia.config.get("DefaultMenuTab", "you")
    if not self.tabList[defaultTab] then
        if self.tabList["you"] then
            defaultTab = "you"
        else
            local allKeys = {}
            for k in pairs(self.tabList) do
                allKeys[#allKeys + 1] = k
            end

            if #allKeys > 0 then defaultTab = allKeys[math.random(#allKeys)] end
        end
    end

    if defaultTab then self:setActiveTab(defaultTab) end
end

function PANEL:addTab(name, callback)
    local colors = lia.color.ReturnMainAdjustedColors()
    local tab = self.tabs:Add("liaSmallButton")
    tab:SetText(L(name))
    tab:SetFont("liaMediumFont")
    surface.SetFont(tab:GetFont())
    local tw = select(1, surface.GetTextSize(tab:GetText()))
    tab.calcW = math.max(self.baseBtnW or 150, tw + 20)
    tab:SetTextColor(colors.text)
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    tab:SetContentAlignment(5)
    tab.DoClick = function()
        if IsValid(lia.gui.info) then lia.gui.info:Remove() end
        for _, t in pairs(self.tabList) do
            t:SetSelected(false)
        end

        tab:SetSelected(true)
        self.activeTab = tab
        self.panel:Clear()
        self.panel:AlphaTo(255, 0.3, 0)
        if callback then
            callback(self.panel)
            self.panel:InvalidateLayout(true)
        end
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

function PANEL:OnRemove()
    hook.Run("F1MenuClosed")
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