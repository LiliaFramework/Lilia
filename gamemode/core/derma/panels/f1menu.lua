local PANEL = {}
local function localizeMenuLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
end

function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:SetSize(ScrW() * 0.85, ScrH() * 0.8)
    self:SetPos(50, 50)
    self.Paint = function() end
    self.CharacterInformation = {}
    local scroll = vgui.Create("liaScrollPanel", self)
    scroll:Dock(FILL)
    scroll:InvalidateLayout(true)
    if not IsValid(scroll.VBar) then scroll:PerformLayout() end
    local canvas = scroll:GetCanvas()
    canvas:DockPadding(8, 10, 8, 20)
    canvas.Paint = function() end
    self.content = canvas
    hook.Run("LoadCharInformation")
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    local function tryGenerate()
        if not IsValid(self) then return end
        local client = LocalPlayer()
        local char = client:getChar()
        local info = self.CharacterInformation or {}
        if char and not table.IsEmpty(info) then
            self:GenerateSections()
            self:Refresh()
        else
            timer.Simple(0.1, tryGenerate)
        end
    end

    timer.Simple(0.1, tryGenerate)
    timer.Create("liaCharInfo_UpdateValues", 1, 0, function()
        if IsValid(self) then
            self:setup()
        else
            timer.Remove("liaCharInfo_UpdateValues")
        end
    end)
end

function PANEL:CreateTextEntryWithBackgroundAndLabel(parent, name, labelText, marginBot, valueFunc)
    local entry = parent:Add("DPanel")
    entry:Dock(TOP)
    entry:DockMargin(0, 0, 0, marginBot or 0)
    entry:SetTall(35)
    entry.Paint = function(_, w, h)
        local bgColor = Color(35, 38, 45, 180)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local lbl = entry:Add("DLabel")
    lbl:Dock(LEFT)
    lbl:SetFont("LiliaFont.17")
    lbl:SetText(labelText or "")
    lbl:SizeToContents()
    local lw, _ = lbl:GetSize()
    lbl:SetWide(lw + 20)
    lbl:DockMargin(8, 0, 10, 0)
    lbl:SetContentAlignment(5)
    lbl:SetTextColor(lia.color.theme.text or Color(210, 235, 235))
    local txt = entry:Add("liaEntry")
    txt:Dock(FILL)
    txt:DockMargin(0, 4, 8, 4)
    txt:SetFont("LiliaFont.17")
    txt:SetTall(27)
    local isDesc = (name or ""):lower() == "desc"
    txt.textEntry:SetEditable(isDesc)
    if isfunction(valueFunc) then
        local v = valueFunc()
        if isstring(v) then txt:SetValue(v) end
    end

    txt.lastValue = nil
    txt.action = function(value)
        if isDesc and isstring(value) then
            if txt.lastValue == value then return end
            local trimmedValue = string.Trim(value)
            local valueWithoutSpaces = string.gsub(trimmedValue, "%s", "")
            local minLength = lia.config.get("MinDescLen", 16)
            if #valueWithoutSpaces < minLength then
                local now = CurTime()
                txt.lastErrorTime = txt.lastErrorTime or 0
                if now - txt.lastErrorTime > 1 then
                    LocalPlayer():notifyErrorLocalized("descMinLen", minLength)
                    txt.lastErrorTime = now
                end
                return
            end

            txt.lastValue = value
            lia.command.send("chardesc", value)
        end
    end

    self[name] = txt
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minFunc, maxFunc, margin, valueFunc)
    local entry = parent:Add("DPanel")
    entry:Dock(TOP)
    entry:DockMargin(0, margin or 0, 0, margin or 0)
    entry:SetTall(40)
    entry.Paint = function(_, w, h)
        local bgColor = Color(35, 38, 45, 180)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local lbl = entry:Add("DLabel")
    lbl:Dock(LEFT)
    lbl:SetFont("LiliaFont.17")
    lbl:SetText(labelText or "")
    lbl:SizeToContents()
    lbl:SetWide(lbl:GetWide() + 20)
    lbl:DockMargin(8, 0, 10, 0)
    lbl:SetContentAlignment(5)
    lbl:SetTextColor(lia.color.theme.text or Color(210, 235, 235))
    local bar = entry:Add("liaProgressBar")
    bar:Dock(FILL)
    bar:DockMargin(0, 6, 8, 6)
    bar:SetBarColor(lia.color.theme.theme or lia.config.get("Color"))
    bar.Think = function(barSelf)
        local mn = isfunction(minFunc) and minFunc() or tonumber(minFunc) or 0
        local mx = isfunction(maxFunc) and maxFunc() or tonumber(maxFunc) or 1
        local val = isfunction(valueFunc) and valueFunc() or tonumber(valueFunc) or 0
        local frac = mx > mn and math.Clamp((val - mn) / (mx - mn), 0, 1) or 0
        barSelf:SetFraction(frac)
        local text = L("barProgress", math.Round(val), math.Round(mx))
        barSelf:SetText(text)
    end

    local originalPaint = bar.Paint
    bar.Paint = function(barSelf, w, h) originalPaint(barSelf, w, h) end
    parent[name] = bar
    return bar
end

function PANEL:AddSpacer(parent, height)
    local sp = parent:Add("DPanel")
    sp:Dock(TOP)
    sp:SetTall(height)
    sp.Paint = function() end
end

function PANEL:GenerateSections()
    local secs = {}
    if table.IsEmpty(self.CharacterInformation) then return end
    for name, data in pairs(self.CharacterInformation) do
        secs[#secs + 1] = {
            name = name,
            data = data
        }
    end

    table.sort(secs, function(a, b) return a.data.priority < b.data.priority end)
    for i, sec in ipairs(secs) do
        local container = self:CreateSection(self.content, sec.name)
        local fields = isfunction(sec.data.fields) and sec.data.fields() or sec.data.fields
        for _, f in ipairs(fields) do
            if f.type == "text" then
                self:CreateTextEntryWithBackgroundAndLabel(container, f.name, L(f.label or ""), 5, f.value)
            elseif f.type == "bar" then
                self:CreateFillableBarWithBackgroundAndLabel(container, f.name, L(f.label or ""), f.min, f.max, 5, f.value)
            end

            self:AddSpacer(container, 5)
        end

        if i < #secs then
            self:AddSpacer(container, 10)
        else
            self:AddSpacer(container, 15)
        end
    end
end

function PANEL:CreateSection(parent, title)
    local frame = parent:Add("DPanel")
    frame:Dock(TOP)
    frame:DockMargin(0, 10, 0, 10)
    frame:SetTall(200)
    frame.Paint = function(_, w, h)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        draw.SimpleText(L(title), "LiliaFont.18", w / 2, 10, lia.color.theme.text or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local header = vgui.Create("DPanel", frame)
    header:SetTall(35)
    header:Dock(TOP)
    header:DockPadding(0, 0, 0, 0)
    header.Paint = function() end
    local contents = frame:Add("DPanel")
    contents:Dock(FILL)
    contents:DockPadding(8, 8, 8, 10)
    contents.Paint = function() end
    frame.PerformLayout = function(f)
        local estimatedHeight = 35
        for _, child in ipairs(contents:GetChildren()) do
            if IsValid(child) then
                estimatedHeight = estimatedHeight + child:GetTall()
                if child.GetDockMargin then
                    local _, top, _, bottom = child:GetDockMargin()
                    if top then estimatedHeight = estimatedHeight + top end
                    if bottom then estimatedHeight = estimatedHeight + bottom end
                end
            end
        end

        estimatedHeight = estimatedHeight + 10
        f:SetTall(math.max(100, estimatedHeight))
    end
    return contents
end

function PANEL:OnRemove()
    hook.Remove("OnThemeChanged", self)
end

function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    self:Refresh()
end

function PANEL:Refresh()
    self:ApplyCurrentTheme()
    self.content:Clear()
    self:GenerateSections()
    self:setup()
end

function PANEL:ApplyCurrentTheme()
    local currentTheme = lia.color.getCurrentTheme()
    if currentTheme and lia.color.themes[currentTheme] then lia.color.theme = table.Copy(lia.color.themes[currentTheme]) end
end

function PANEL:setup()
    if table.IsEmpty(self.CharacterInformation) then return end
    for _, data in pairs(self.CharacterInformation) do
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, f in ipairs(fields) do
            local ctrl = self[f.name]
            if ctrl and f.type == "text" and f.name:lower() ~= "desc" then ctrl:SetValue(f.value()) end
        end
    end
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")
PANEL = {}
function PANEL:Init()
    lia.gui.menu = self
    hook.Run("F1MenuOpened", self)
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.noAnchor = CurTime() + 0.4
    self.anchorMode = true
    self.invKey = lia.keybind.get(L("openInventory"), KEY_I)
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    local topBar = self:Add("DPanel")
    topBar:Dock(TOP)
    topBar:SetTall(70)
    topBar:DockPadding(30, 10, 30, 10)
    local iconMat = Material("lilia.png")
    local schemaIconMat = SCHEMA and SCHEMA.icon and Material(SCHEMA.icon, "smooth") or nil
    local schemaName = SCHEMA and SCHEMA.name or nil
    topBar.Paint = function(pnl, w, h)
        local accentColor = lia.color.theme.accent or lia.color.theme.theme or lia.config.get("Color")
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(0):Color(bgColor):Draw()
        lia.derma.rect(0, h - 4, w, 4):Color(accentColor):Draw()
        local glowColor = Color(accentColor.r, accentColor.g, accentColor.b, 8)
        lia.derma.rect(1, 1, w - 2, h - 2):Color(glowColor):Outline(1):Draw()
        if schemaIconMat and schemaName then
            local iconSize = h * 0.5
            surface.SetMaterial(schemaIconMat)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(30, (h - iconSize) * 0.5, iconSize, iconSize)
            surface.SetFont("LiliaFont.25")
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

    local tabsPanel = topBar:Add("liaTabs")
    tabsPanel:Dock(FILL)
    local leftMargin = 0
    if schemaIconMat and schemaName then
        local iconSize = topBar:GetTall() * 0.5
        surface.SetFont("LiliaFont.25")
        local textW = surface.GetTextSize(L(schemaName))
        leftMargin = math.ceil(iconSize + 10 + textW + 20)
    end

    tabsPanel:DockMargin(leftMargin, 5, 80, 5)
    self.tabs = tabsPanel
    local panel = self:Add("EditablePanel")
    panel:Dock(FILL)
    local mX, mY = ScrW() * 0.05, ScrH() * 0.05
    panel:DockMargin(mX, mY, mX, mY)
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.25, 0)
    panel.Paint = function() end
    self.panelWrapper = panel
    local contentPanel = panel:Add("EditablePanel")
    contentPanel:Dock(FILL)
    contentPanel.Paint = function() end
    self.panel = contentPanel
    local btnDefs = {}
    hook.Run("CreateMenuButtons", btnDefs)
    local tabKeys = {}
    for k in pairs(btnDefs) do
        tabKeys[#tabKeys + 1] = k
    end

    table.sort(tabKeys, function(a, b)
        local aName = tostring(localizeMenuLabel(btnDefs[a].name)):lower()
        local bName = tostring(localizeMenuLabel(btnDefs[b].name)):lower()
        return aName < bName
    end)

    self.tabList = {}
    self._tabIndex = {}
    local tabIndex = 0
    for _, key in ipairs(tabKeys) do
        local tabDef = btnDefs[key]
        if tabDef.shouldShow and not tabDef.shouldShow() then continue end
        local name = tabDef.name
        local cb = tabDef.func
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

        tabIndex = tabIndex + 1
        self._tabIndex[key] = tabIndex
        self.tabList[key] = self:addTab(key, name, cb)
    end

    self:MakePopup()
    local defaultTab = lia.config.get("DefaultMenuTab", "@you")
    print("[liaMenu] lia.config.get DefaultMenuTab =", defaultTab)
    print("[liaMenu] tabList keys:")
    for k in pairs(self.tabList) do
        print("  ->", k)
    end
    if not self.tabList[defaultTab] then
        print("[liaMenu] defaultTab not found in tabList, falling back")
        if self.tabList["@you"] then
            defaultTab = "@you"
        else
            local allKeys = {}
            for k in pairs(self.tabList) do
                allKeys[#allKeys + 1] = k
            end

            if #allKeys > 0 then defaultTab = allKeys[math.random(#allKeys)] end
        end
    end

    print("[liaMenu] final defaultTab =", defaultTab)
    if defaultTab then self:setActiveTab(defaultTab) end
    timer.Simple(0.1, function() if IsValid(self) then self:UpdateTabColors() end end)
end

function PANEL:SwitchTabContent(name, callback)
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    if not callback then return end
    local wrapper = self.panelWrapper
    if not IsValid(wrapper) then return end
    local oldPanel = self.panel
    wrapper:InvalidateLayout(true)
    if wrapper.PerformLayout then wrapper:PerformLayout() end
    local w, h = wrapper:GetSize()
    local oldKey = self.activeTabKey
    local oldIndex = oldKey and self._tabIndex and self._tabIndex[oldKey] or nil
    local newIndex = self._tabIndex and self._tabIndex[name] or nil
    local dir = 1
    if oldIndex and newIndex then dir = (newIndex > oldIndex) and 1 or -1 end
    if IsValid(oldPanel) then
        for _, child in ipairs(oldPanel:GetChildren()) do
            if IsValid(child) then child:SetVisible(false) end
        end
    end

    local newPanel = wrapper:Add("EditablePanel")
    newPanel:Dock(NODOCK)
    newPanel:SetSize(w, h)
    newPanel:SetPos(dir * w, 0)
    newPanel:SetAlpha(0)
    newPanel.Paint = function() end
    self.panel = newPanel
    self.activeTabKey = name
    self:UpdateTabColors()
    self:ApplyCurrentTheme()
    callback(newPanel)
    newPanel:InvalidateLayout(true)
    if newPanel.PerformLayout then newPanel:PerformLayout() end
    local time = 0.35
    local ease = 0.15
    if IsValid(oldPanel) then
        oldPanel:Dock(NODOCK)
        oldPanel:MoveTo(-dir * w, 0, time, 0, ease, function() if IsValid(oldPanel) then oldPanel:Remove() end end)
        oldPanel:AlphaTo(0, time, 0)
    end

    newPanel:MoveTo(0, 0, time, 0, ease, function() if IsValid(newPanel) then newPanel:Dock(FILL) end end)
    newPanel:AlphaTo(255, time, 0)
end

function PANEL:addTab(key, name, callback)
    local contentPanel = vgui.Create("EditablePanel")
    contentPanel:Dock(FILL)
    contentPanel.Paint = function() end
    local wrappedCallback = function() self:SwitchTabContent(key, callback) end
    self.tabs:AddTab(localizeMenuLabel(name), contentPanel, nil, wrappedCallback)
    local tabData = {
        name = name,
        panel = contentPanel,
        callback = callback
    }

    if not self.tabList then self.tabList = {} end
    self.tabList[key] = tabData
    return tabData
end

function PANEL:setActiveTab(key)
    local tabData = self.tabList[key]
    if tabData and IsValid(tabData.panel) then
        for i, tabInfo in ipairs(self.tabs.tabs) do
            if tabInfo.pan == tabData.panel then
                self.tabs:SetActiveTab(i)
                return
            end
        end
        return
    end

    for i, tabInfo in ipairs(self.tabs.tabs) do
        if tabInfo.name == key or L(tabInfo.name) == key then
            self.tabs:SetActiveTab(i)
            return
        end
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
    hook.Remove("OnThemeChanged", self)
end

function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    self:UpdateTabColors()
end

function PANEL:ApplyCurrentTheme()
    local currentTheme = lia.color.getCurrentTheme()
    if currentTheme and lia.color.themes[currentTheme] then lia.color.theme = table.Copy(lia.color.themes[currentTheme]) end
end

function PANEL:UpdateTabColors()
end

function PANEL:OnKeyCodePressed(key)
    self.noAnchor = CurTime() + 0.5
    if key == KEY_F1 or key == self.invKey then self:remove() end
end

function PANEL:Update()
    if self:IsVisible() and not self.closing then
        self:InvalidateLayout(true)
        for _, child in pairs(self:GetChildren()) do
            if IsValid(child) then child:InvalidateLayout(true) end
        end
    end
end

function PANEL:Think()
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then
        self:remove()
        return
    end

    if input.IsKeyDown(KEY_F1) and CurTime() > self.noAnchor and self.anchorMode then
        self.anchorMode = false
        lia.websound.playButtonSound("buttons/lightswitch2.wav")
    end

    if not self.anchorMode and not input.IsKeyDown(KEY_F1) and not IsValid(self.info) then self:remove() end
end

function PANEL:Paint()
    lia.util.drawBlackBlur(self, 1, 4, 255, 220)
end

vgui.Register("liaMenu", PANEL, "EditablePanel")
PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    local w, h = self:GetParent():GetSize()
    self:SetSize(w, h)
    self.selectedClassModels = self.selectedClassModels or {}
    local frame = self:Add("liaFrame")
    frame:Dock(FILL)
    frame:DockMargin(10, 10, 10, 10)
    frame:DockPadding(10, 10, 10, 10)
    frame:SetTitle("")
    frame:LiteMode()
    frame:DisableCloseBtn()
    self.frame = frame
    self.sidebar = frame:Add("liaScrollPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(240)
    self.sidebar:DockMargin(0, 0, 10, 0)
    self.sidebar.Paint = function() end
    local sidebarCanvas = self.sidebar:GetCanvas()
    if IsValid(sidebarCanvas) then
        sidebarCanvas:DockPadding(4, 4, 4, 4)
        sidebarCanvas.Paint = function() end
    end

    self.mainContent = frame:Add("liaScrollPanel")
    self.mainContent:Dock(FILL)
    self.mainContent:DockMargin(0, 0, 0, 0)
    self.mainContent.Paint = function() end
    local mainCanvas = self.mainContent:GetCanvas()
    if IsValid(mainCanvas) then
        mainCanvas:DockPadding(6, 6, 6, 6)
        mainCanvas.Paint = function() end
    end

    self.tabList = {}
    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    local list = {}
    for _, cl in pairs(lia.class.list) do
        if cl.faction == client:Team() then list[#list + 1] = cl end
    end

    table.sort(list, function(a, b) return L(a.name or "") < L(b.name or "") end)
    self.sidebar:Clear()
    self.tabList = {}
    local firstBtn = nil
    for _, cl in ipairs(list) do
        local canBe = lia.class.canBe(LocalPlayer(), cl.index)
        local btn = self.sidebar:Add("liaTabButton")
        btn:Dock(TOP)
        btn:DockMargin(4, 4, 4, 4)
        btn:SetTall(34)
        btn:SetText(cl.name and L(cl.name) or L("unnamed"))
        btn:SetActive(false)
        if cl.desc and cl.desc ~= L("noDesc") then btn:SetTooltip(L(cl.desc)) end
        btn:SetDoClick(function()
            for _, b in ipairs(self.tabList) do
                if IsValid(b) then b:SetActive(b == btn) end
            end

            self:populateClassDetails(cl, canBe)
        end)

        self.tabList[#self.tabList + 1] = btn
        if not firstBtn then firstBtn = btn end
    end

    if IsValid(firstBtn) then timer.Simple(0, function() if IsValid(firstBtn) then firstBtn:DoClick() end end) end
end

function PANEL:populateClassDetails(cl, canBe)
    local canvas = self.mainContent:GetCanvas()
    if IsValid(canvas) then
        canvas:Clear()
    else
        self.mainContent:Clear()
    end

    local parent = IsValid(canvas) and canvas or self.mainContent
    local container = parent:Add("DPanel")
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, 0)
    container:DockPadding(10, 10, 10, 10)
    container:SetTall(math.max(self.mainContent:GetTall(), 200))
    container.Paint = function(_, w, h)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    container.Think = function(s)
        if not IsValid(self) or not IsValid(self.mainContent) then return end
        local targetTall = math.max(self.mainContent:GetTall(), 200)
        if s:GetTall() ~= targetTall then s:SetTall(targetTall) end
    end

    local header = container:Add("DPanel")
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 10)
    header:SetTall(56)
    header.Paint = function() end
    local title = header:Add("DLabel")
    title:Dock(FILL)
    title:SetFont("LiliaFont.25")
    title:SetText(cl.name and L(cl.name) or L("unnamed"))
    title:SetTextColor(lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().text or color_white)
    title:SetContentAlignment(4)
    local body = container:Add("DPanel")
    body:Dock(FILL)
    body.Paint = function() end
    local right = body:Add("liaScrollPanel")
    right:Dock(RIGHT)
    right:SetWide(320)
    right:DockMargin(10, 0, 0, 0)
    right.Paint = function() end
    local rightCanvas = right:GetCanvas()
    if IsValid(rightCanvas) then
        rightCanvas:DockPadding(0, 0, 0, 0)
        rightCanvas.Paint = function() end
    end

    right.Think = function(s)
        local cnv = s:GetCanvas()
        if not IsValid(cnv) then return end
        local vbarW = (IsValid(s.VBar) and s.VBar:GetWide()) or 0
        local targetW = math.max(s:GetWide() - vbarW - 2, 1)
        if cnv:GetWide() ~= targetW then cnv:SetWide(targetW) end
        local totalH = 0
        for _, child in ipairs(cnv:GetChildren()) do
            if IsValid(child) then
                totalH = totalH + child:GetTall()
                if child.GetDockMargin then
                    local _, top, _, bottom = child:GetDockMargin()
                    if top then totalH = totalH + top end
                    if bottom then totalH = totalH + bottom end
                end
            end
        end

        local minH = math.max(s:GetTall(), 1)
        local targetH = math.max(totalH, minH)
        if cnv:GetTall() ~= targetH then cnv:SetTall(targetH) end
    end

    local rightParent = IsValid(rightCanvas) and rightCanvas or right
    if cl.logo then
        local logoWrap = rightParent:Add("DPanel")
        logoWrap:Dock(TOP)
        logoWrap:DockMargin(0, 0, 0, 10)
        logoWrap:SetTall(140)
        logoWrap.Paint = function() end
        local img = logoWrap:Add("DImage")
        img:SetSize(128, 128)
        img:SetImage(cl.logo)
        img:SetKeepAspect(true)
        logoWrap.PerformLayout = function(s, w, h) if IsValid(img) then img:SetPos(math.floor((w - img:GetWide()) * 0.5), math.floor((h - img:GetTall()) * 0.5)) end end
    end

    local left = body:Add("liaScrollPanel")
    left:Dock(FILL)
    left.Paint = function() end
    local leftCanvas = left:GetCanvas()
    if IsValid(leftCanvas) then
        leftCanvas:DockPadding(0, 0, 0, 0)
        leftCanvas.Paint = function() end
    end

    self:createModelPanel(rightParent, cl)
    self:addJoinButton(rightParent, cl, canBe)
    self:addClassDetails(left, cl)
    container.PerformLayout = function(s)
        s:SizeToChildren(false, true)
        s:SetTall(math.max(s:GetTall(), body:GetTall() + header:GetTall() + 30))
    end
end

function PANEL:createModelPanel(parent, cl)
    local container = parent:Add("DPanel")
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, 10)
    container:SetTall(420)
    container.Paint = function() end
    local panel = container:Add("liaModelPanel")
    panel:Dock(FILL)
    panel:SetFOV(35)
    local basePaint = panel.Paint
    panel.Paint = function(s, modelW, modelH)
        local bgColor = Color(35, 38, 45, 180)
        lia.derma.rect(0, 0, modelW, modelH):Rad(10):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        if basePaint then basePaint(s, modelW, modelH) end
    end

    local function getModels(mdl)
        local models = {}
        if isstring(mdl) and mdl ~= "" then
            models[#models + 1] = mdl
        elseif istable(mdl) then
            local function gather(tbl)
                for _, v in pairs(tbl) do
                    if isstring(v) then
                        models[#models + 1] = v
                    elseif istable(v) then
                        gather(v)
                    end
                end
            end

            gather(mdl)
        end
        return models
    end

    local availableModels = getModels(cl.model or cl.models)
    if #availableModels == 0 then availableModels = {LocalPlayer():GetModel()} end
    panel.currentModelIndex = 1
    panel.availableModels = availableModels
    panel.classData = cl
    local function updateModel()
        local model = panel.availableModels[panel.currentModelIndex]
        if util and util.IsValidModel and not util.IsValidModel(model) then model = LocalPlayer():GetModel() end
        panel:SetModel(model)
        panel:fitFOV()
        self.selectedClassModels = self.selectedClassModels or {}
        self.selectedClassModels[cl.index] = model
        local function applyEntitySettings()
            local ent = panel.Entity
            if not IsValid(ent) then return end
            ent:SetSkin(panel.classData.skin or 0)
            for _, bg in ipairs(panel.classData.bodyGroups or {}) do
                ent:SetBodygroup(bg.id, bg.value or 0)
            end

            for i, mat in ipairs(panel.classData.subMaterials or {}) do
                ent:SetSubMaterial(i - 1, mat)
            end
        end

        applyEntitySettings()
        timer.Simple(0, function() if IsValid(panel) then applyEntitySettings() end end)
        timer.Simple(0.1, function() if IsValid(panel) then applyEntitySettings() end end)
    end

    updateModel()
    panel.rotationAngle = 45
    if #availableModels > 1 then
        local arrowSize, arrowSpace = 32, 8
        local function newArrow(sign, xOffset)
            local btn = container:Add("liaBigButton")
            btn:SetSize(arrowSize, arrowSize)
            btn:SetPos(xOffset, (container:GetTall() - arrowSize) * 0.5)
            btn:SetFont("LiliaFont.24")
            btn:SetShowLine(false)
            btn:SetText(sign)
            btn.DoClick = function()
                if #panel.availableModels <= 1 then return end
                panel.currentModelIndex = panel.currentModelIndex + (sign == "<" and -1 or 1)
                if panel.currentModelIndex < 1 then panel.currentModelIndex = #panel.availableModels end
                if panel.currentModelIndex > #panel.availableModels then panel.currentModelIndex = 1 end
                lia.websound.playButtonSound("buttons/button14.wav")
                updateModel()
            end
            return btn
        end

        panel.leftArrow = newArrow("<", arrowSpace)
        panel.rightArrow = newArrow(">", container:GetWide() - arrowSize - arrowSpace)
        container.PerformLayout = function(s)
            if IsValid(panel.leftArrow) then panel.leftArrow:SetPos(arrowSpace, (s:GetTall() - arrowSize) * 0.5) end
            if IsValid(panel.rightArrow) then panel.rightArrow:SetPos(s:GetWide() - arrowSize - arrowSpace, (s:GetTall() - arrowSize) * 0.5) end
        end
    end

    panel.LayoutEntity = function(_, ent)
        if not IsValid(ent) then return end
        if input.IsKeyDown(KEY_A) then
            panel.rotationAngle = panel.rotationAngle - 0.5
        elseif input.IsKeyDown(KEY_D) then
            panel.rotationAngle = panel.rotationAngle + 0.5
        end

        ent:SetAngles(Angle(0, panel.rotationAngle, 0))
    end
    return panel.availableModels[panel.currentModelIndex]
end

function PANEL:addClassDetails(parent, cl)
    local client = LocalPlayer()
    local maxH, maxA, maxJ = client:GetMaxHealth(), client:GetMaxArmor(), client:GetJumpPower()
    local run, walk = lia.config.get("RunSpeed"), lia.config.get("WalkSpeed")
    local function add(text)
        local row = parent:Add("DPanel")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 8)
        row:DockPadding(10, 8, 10, 8)
        row.Paint = function(_, w, h)
            local rowBg = Color(35, 38, 45, 180)
            lia.derma.rect(0, 0, w, h):Rad(10):Color(rowBg):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        local lbl = row:Add("DLabel")
        lbl:Dock(FILL)
        lbl:SetFont("LiliaFont.18")
        lbl:SetText(text)
        local textColor = lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().text or color_white
        lbl:SetTextColor(textColor)
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        row.PerformLayout = function(s)
            if not IsValid(lbl) then return end
            lbl:SetWide(s:GetWide() - 20)
            lbl:SizeToContentsY()
            s:SetTall(lbl:GetTall() + 16)
        end
    end

    add(L("name") .. ": " .. (cl.name and L(cl.name) or L("unnamed")))
    add(L("desc") .. ": " .. (cl.desc and L(cl.desc) or L("noDesc")))
    local facName = team.GetName(cl.faction)
    add(L("faction") .. ": " .. (facName and L(facName) or L("none")))
    add(L("isDefault") .. ": " .. (cl.isDefault and L("yes") or L("no")))
    add(L("baseHealth") .. ": " .. tostring(cl.health or maxH))
    add(L("baseArmor") .. ": " .. tostring(cl.armor or maxA))
    local function getWeaponClassList(weps)
        if isstring(weps) then return {weps} end
        if not istable(weps) then return {} end
        local out = {}
        if #weps > 0 then
            for _, v in ipairs(weps) do
                if isstring(v) then
                    out[#out + 1] = v
                elseif istable(v) then
                    local cn = v.class or v.weapon or v.name
                    if isstring(cn) then out[#out + 1] = cn end
                end
            end
        else
            for _, v in pairs(weps) do
                if isstring(v) then
                    out[#out + 1] = v
                elseif istable(v) then
                    local cn = v.class or v.weapon or v.name
                    if isstring(cn) then out[#out + 1] = cn end
                end
            end
        end
        return out
    end

    local wepClasses = getWeaponClassList(cl.weapons)
    local weaponNames = {}
    for _, className in ipairs(wepClasses) do
        local stored = weapons.GetStored and weapons.GetStored(className) or nil
        local printName = stored and (stored.PrintName or stored.Name) or nil
        weaponNames[#weaponNames + 1] = printName and tostring(printName) ~= "" and tostring(printName) or tostring(className)
    end

    add(L("weapons") .. ": " .. (#weaponNames > 0 and table.concat(weaponNames, ", ") or L("none")))
    add(L("modelScale") .. ": " .. tostring(cl.scale or 1))
    local rs = cl.runSpeedMultiplier and math.Round(run * cl.runSpeed) or cl.runSpeed or run
    add(L("runSpeed") .. ": " .. tostring(rs))
    local ws = cl.walkSpeedMultiplier and math.Round(walk * cl.walkSpeed) or cl.walkSpeed or walk
    add(L("walkSpeed") .. ": " .. tostring(ws))
    local jp = cl.jumpPowerMultiplier and math.Round(maxJ * cl.jumpPower) or cl.jumpPower or maxJ
    add(L("jumpPower") .. ": " .. tostring(jp))
    local bloodMap = {
        [-1] = L("bloodNo"),
        [0] = L("bloodRed"),
        [1] = L("bloodYellow"),
        [2] = L("bloodGreenRed"),
        [3] = L("bloodSparks"),
        [4] = L("bloodAntlion"),
        [5] = L("bloodZombie"),
        [6] = L("bloodAntlionBright")
    }

    add(L("bloodColor") .. ": " .. (bloodMap[cl.bloodcolor] or L("bloodRed")))
end

function PANEL:addJoinButton(parent, cl, canBe)
    local isCurrent = LocalPlayer():getChar() and LocalPlayer():getChar():getClass() == cl.index
    local btn = parent:Add("liaMediumButton")
    if isCurrent and istable(cl.model) then
        btn:SetText(L("changeModel"))
    else
        btn:SetText(isCurrent and L("alreadyInClass") or L("joinClass"))
    end

    btn:SetTall(45)
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, 0)
    local textColor = lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().text or color_white
    local accentColor = lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().accent or Color(100, 150, 255)
    btn:SetTextColor(textColor)
    btn:SetFont("LiliaFont.25")
    btn:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    btn:SetContentAlignment(5)
    btn.Paint = function(panel, w, h)
        local baseColor = Color(45, 45, 45, 200)
        local hoverColor = Color(55, 55, 55, 220)
        if panel:IsHovered() and not panel:GetDisabled() then baseColor = hoverColor end
        if panel:GetDisabled() then baseColor = Color(35, 35, 35, 150) end
        lia.derma.rect(0, 0, w, h):Rad(6):Color(baseColor):Shape(lia.derma.SHAPE_IOS):Shadow(panel:IsHovered() and not panel:GetDisabled() and 3 or 2, panel:IsHovered() and not panel:GetDisabled() and 8 or 4):Draw()
        if canBe and not isCurrent then
            lia.derma.rect(0, 0, w, h):Rad(6):Color(accentColor):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(2, 2, w - 4, h - 4):Rad(4):Color(baseColor):Shape(lia.derma.SHAPE_IOS):Draw()
        end
    end

    btn:SetDisabled((not canBe and not isCurrent) or (isCurrent and not istable(cl.model)))
    btn.DoClick = function()
        lia.websound.playButtonSound()
        if isCurrent then
            if istable(cl.model) then lia.command.send("beclass", cl.index, self.selectedClassModels and self.selectedClassModels[cl.index] or nil) end
            return
        end

        if not canBe then return end
        if istable(cl.model) then
            lia.command.send("beclass", cl.index, self.selectedClassModels and self.selectedClassModels[cl.index] or nil)
        else
            lia.command.send("beclass", cl.index)
        end

        timer.Simple(0.1, function()
            if IsValid(self) then
                self:loadClasses()
                self.mainContent:Clear()
            end
        end)
    end
end

vgui.Register("liaClasses", PANEL, "EditablePanel")
hook.Add("LoadCharInformation", "liaF1MenuGeneralInfo", function()
    hook.Run("AddSection", L("generalInfo"), Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", L("generalInfo"), "name", L("name"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getName() or L("unknown")
    end)

    hook.Run("AddTextField", L("generalInfo"), "desc", L("desc"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getDesc() or ""
    end)

    hook.Run("AddTextField", L("generalInfo"), "money", L("money"), function()
        local client = LocalPlayer()
        return client and lia.currency.get(client:getChar():getMoney()) or lia.currency.get(0)
    end)

    hook.Run("AddTextField", L("generalInfo"), "playTime", L("playtime"), function()
        local client = LocalPlayer()
        return client and lia.time.formatDHM(client:getPlayTime()) or L("loading")
    end)
end)

hook.Add("AddSection", "liaF1MenuAddSection", function(sectionName, color, priority, location)
    if IsValid(lia.gui.info) then
        local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
        if not lia.gui.info.CharacterInformation[localizedSectionName] then
            lia.gui.info.CharacterInformation[localizedSectionName] = {
                fields = {},
                color = color or Color(255, 255, 255),
                priority = priority or 999,
                location = location or 1
            }
        else
            local info = lia.gui.info.CharacterInformation[localizedSectionName]
            info.color = color or info.color
            info.priority = priority or info.priority
            info.location = location or info.location
        end
    end
end)

hook.Add("AddTextField", "liaF1MenuAddTextField", function(sectionName, fieldName, labelText, valueFunc)
    if IsValid(lia.gui.info) then
        local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
        local localizedLabel = isstring(labelText) and L(labelText) or labelText
        local section = lia.gui.info.CharacterInformation[localizedSectionName]
        if section then
            for _, field in ipairs(section.fields) do
                if field.name == fieldName then return end
            end

            table.insert(section.fields, {
                type = "text",
                name = fieldName,
                label = localizedLabel,
                value = valueFunc or function() return "" end
            })
        end
    end
end)

hook.Add("AddTextField", "liaF1MenuAddTextField", function(sectionName, fieldName, labelText, valueFunc)
    if IsValid(lia.gui.info) then
        local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
        local localizedLabel = isstring(labelText) and L(labelText) or labelText
        local section = lia.gui.info.CharacterInformation[localizedSectionName]
        if section then
            for _, field in ipairs(section.fields) do
                if field.name == fieldName then return end
            end

            table.insert(section.fields, {
                type = "text",
                name = fieldName,
                label = localizedLabel,
                value = valueFunc or function() return "" end
            })
        end
    end
end)

hook.Add("AddBarField", "liaF1MenuAddBarField", function(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    if IsValid(lia.gui.info) then
        local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
        local localizedLabel = isstring(labelText) and L(labelText) or labelText
        local section = lia.gui.info.CharacterInformation[localizedSectionName]
        if section then
            for _, field in ipairs(section.fields) do
                if field.name == fieldName then return end
            end

            table.insert(section.fields, {
                type = "bar",
                name = fieldName,
                label = localizedLabel,
                min = minFunc or function() return 0 end,
                max = maxFunc or function() return 100 end,
                value = valueFunc or function() return 0 end
            })
        end
    end
end)

hook.Add("PlayerBindPress", "liaF1MenuPlayerBindPress", function(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end)

hook.Add("CreateMenuButtons", "liaF1MenuCreateMenuButtons", function(tabs)
    tabs["@you"] = {
        name = "@you",
        func = function(statusPanel)
            statusPanel.info = vgui.Create("liaCharInfo", statusPanel)
            statusPanel.info:Dock(FILL)
            statusPanel.info:setup()
            statusPanel.info:SetAlpha(0)
            statusPanel.info:AlphaTo(255, 0.5)
        end
    }

    tabs["@information"] = {
        name = "@information",
        func = function(infoTabPanel)
            local frame = infoTabPanel:Add("liaFrame")
            frame:Dock(FILL)
            frame:DockPadding(10, 10, 10, 10)
            frame:SetTitle("")
            frame:DisableCloseBtn()
            local pages = {}
            hook.Run("CreateInformationButtons", pages)
            if not pages then return end
            for i = #pages, 1, -1 do
                if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
            end

            table.sort(pages, function(a, b)
                local an = tostring(localizeMenuLabel(a.name)):lower()
                local bn = tostring(localizeMenuLabel(b.name)):lower()
                return an < bn
            end)

            local tabContainer = vgui.Create("DPanel", frame)
            tabContainer:Dock(TOP)
            tabContainer:SetTall(40)
            tabContainer.Paint = function() end
            local contentArea = vgui.Create("DPanel", frame)
            contentArea:Dock(FILL)
            contentArea.Paint = function() end
            local activeTab = 1
            local tabButtons = {}
            local tabPanels = {}
            local baseTabWidths = {}
            local baseMargin = 8
            for i, page in ipairs(pages) do
                surface.SetFont("LiliaFont.18")
                local textWidth = surface.GetTextSize(localizeMenuLabel(page.name))
                local iconWidth = 0
                local padding = 20
                local minWidth = 80
                local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
                baseTabWidths[i] = btnWidth
            end

            for i, page in ipairs(pages) do
                local tabButton = vgui.Create("liaTabButton", tabContainer)
                tabButton:Dock(LEFT)
                tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
                tabButton:SetTall(36)
                tabButton:SetText(localizeMenuLabel(page.name))
                tabButton:SetActive(i == 1)
                tabButton:SetWide(baseTabWidths[i] or 80)
                tabButton:SetDoClick(function()
                    if activeTab == i then return end
                    lia.websound.playButtonSound()
                    if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                    activeTab = i
                    tabPanels[i]:SetVisible(true)
                    for j, btn in ipairs(tabButtons) do
                        if IsValid(btn) then btn:SetActive(j == i) end
                    end

                    if page.drawFunc then page.drawFunc(tabPanels[i]) end
                end)

                tabButtons[i] = tabButton
                local contentPanel = vgui.Create("DPanel", contentArea)
                contentPanel:Dock(TOP)
                contentPanel:SetVisible(i == 1)
                contentPanel.Paint = function() end
                contentPanel.PerformLayout = function(s) if IsValid(frame) and IsValid(tabContainer) then s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) end end
                tabPanels[i] = contentPanel
            end

            local function AdjustTabWidths()
                if not IsValid(tabContainer) then return end
                local totalTabsWidth = 0
                for _, width in pairs(baseTabWidths) do
                    totalTabsWidth = totalTabsWidth + width
                end

                local availableWidth = tabContainer:GetWide()
                local totalMargins = baseMargin * (#pages - 1)
                local extraSpace = availableWidth - totalTabsWidth - totalMargins
                if extraSpace > 0 then
                    local extraPerTab = math.floor(extraSpace / #pages)
                    local adjustedWidths = {}
                    for tabId, baseWidth in pairs(baseTabWidths) do
                        adjustedWidths[tabId] = baseWidth + extraPerTab
                    end

                    local remainder = extraSpace % #pages
                    if remainder > 0 then
                        for remainderId = 1, math.min(remainder, #pages) do
                            adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                        end
                    end

                    for childId, child in ipairs(tabContainer:GetChildren()) do
                        if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                    end
                end
            end

            local originalPerformLayout = tabContainer.PerformLayout
            tabContainer.PerformLayout = function(s, w, h)
                if originalPerformLayout then originalPerformLayout(s, w, h) end
                timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
            end

            if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
        end
    }

    tabs["@settings"] = {
        name = "@settings",
        func = function(settingsPanel)
            local frame = settingsPanel:Add("liaFrame")
            frame:Dock(FILL)
            frame:DockMargin(10, 10, 10, 10)
            frame:SetTitle(L("settings"))
            frame:LiteMode()
            frame:DisableCloseBtn()
            local pages = {}
            hook.Run("PopulateConfigurationButtons", pages)
            if not pages then return end
            for i = #pages, 1, -1 do
                if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
            end

            table.sort(pages, function(a, b)
                local an = tostring(localizeMenuLabel(a.name)):lower()
                local bn = tostring(localizeMenuLabel(b.name)):lower()
                return an < bn
            end)

            local tabContainer = vgui.Create("DPanel", frame)
            tabContainer:Dock(TOP)
            tabContainer:SetTall(40)
            tabContainer.Paint = function() end
            local contentArea = vgui.Create("liaScrollPanel", frame)
            contentArea:Dock(FILL)
            local activeTab = 1
            local tabButtons = {}
            local tabPanels = {}
            local baseTabWidths = {}
            local baseMargin = 8
            for i, page in ipairs(pages) do
                surface.SetFont("LiliaFont.18")
                local textWidth = surface.GetTextSize(localizeMenuLabel(page.name))
                local iconWidth = 0
                local padding = 20
                local minWidth = 80
                local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
                baseTabWidths[i] = btnWidth
            end

            for i, page in ipairs(pages) do
                local tabButton = vgui.Create("liaTabButton", tabContainer)
                tabButton:Dock(LEFT)
                tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
                tabButton:SetTall(36)
                tabButton:SetText(localizeMenuLabel(page.name))
                tabButton:SetActive(i == 1)
                tabButton:SetWide(baseTabWidths[i] or 80)
                tabButton:SetDoClick(function()
                    if activeTab == i then return end
                    lia.websound.playButtonSound()
                    if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                    activeTab = i
                    tabPanels[i]:SetVisible(true)
                    for j, btn in ipairs(tabButtons) do
                        if IsValid(btn) then btn:SetActive(j == i) end
                    end

                    if page.drawFunc then page.drawFunc(tabPanels[i]) end
                end)

                tabButtons[i] = tabButton
                local contentPanel = vgui.Create("DPanel", contentArea)
                contentPanel:Dock(TOP)
                contentPanel:SetVisible(i == 1)
                contentPanel.Paint = function() end
                contentPanel.PerformLayout = function(s) if IsValid(frame) and IsValid(tabContainer) then s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) end end
                tabPanels[i] = contentPanel
            end

            local function AdjustTabWidths()
                if not IsValid(tabContainer) then return end
                local totalTabsWidth = 0
                for _, width in pairs(baseTabWidths) do
                    totalTabsWidth = totalTabsWidth + width
                end

                local availableWidth = tabContainer:GetWide()
                local totalMargins = baseMargin * (#pages - 1)
                local extraSpace = availableWidth - totalTabsWidth - totalMargins
                if extraSpace > 0 then
                    local extraPerTab = math.floor(extraSpace / #pages)
                    local adjustedWidths = {}
                    for tabId, baseWidth in pairs(baseTabWidths) do
                        adjustedWidths[tabId] = baseWidth + extraPerTab
                    end

                    local remainder = extraSpace % #pages
                    if remainder > 0 then
                        for remainderId = 1, math.min(remainder, #pages) do
                            adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                        end
                    end

                    for childId, child in ipairs(tabContainer:GetChildren()) do
                        if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                    end
                end
            end

            local originalPerformLayout = tabContainer.PerformLayout
            tabContainer.PerformLayout = function(s, w, h)
                if originalPerformLayout then originalPerformLayout(s, w, h) end
                timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
            end

            if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
        end
    }

    local adminPages = {}
    hook.Run("PopulateAdminTabs", adminPages)
    if not table.IsEmpty(adminPages) then
        tabs["@admin"] = {
            name = "@admin",
            func = function(adminPanel)
                local frame = adminPanel:Add("liaFrame")
                frame:Dock(FILL)
                frame:DockMargin(10, 10, 10, 10)
                frame:SetTitle(L("admin"))
                frame:LiteMode()
                frame:DisableCloseBtn()
                local pages = {}
                hook.Run("PopulateAdminTabs", pages)
                if table.IsEmpty(pages) then return end
                for i = #pages, 1, -1 do
                    if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
                end

                table.sort(pages, function(a, b)
                    local an = tostring(localizeMenuLabel(a.name)):lower()
                    local bn = tostring(localizeMenuLabel(b.name)):lower()
                    return an < bn
                end)

                table.insert(pages, 1, {
                    name = "onlineStaff",
                    icon = "icon16/user.png",
                    drawFunc = function(panel)
                        panel.originalStaffData = {}
                        panel.filteredStaffData = {}
                        local function filterStaffData(searchText)
                            searchText = tostring(searchText or "")
                            if searchText == "" then
                                panel.filteredStaffData = panel.originalStaffData
                            else
                                panel.filteredStaffData = {}
                                local searchLower = searchText:lower()
                                for _, staffInfo in ipairs(panel.originalStaffData) do
                                    local nameMatch = staffInfo.name and staffInfo.name:lower():find(searchLower, 1, true)
                                    local usergroupMatch = staffInfo.usergroup and staffInfo.usergroup:lower():find(searchLower, 1, true)
                                    local characterMatch = staffInfo.characterName and staffInfo.characterName:lower():find(searchLower, 1, true)
                                    if nameMatch or usergroupMatch or characterMatch then panel.filteredStaffData[#panel.filteredStaffData + 1] = staffInfo end
                                end
                            end
                            return panel.filteredStaffData
                        end

                        local function createStaffTable(staffData)
                            panel:Clear()
                            local searchEntry = panel:Add("liaEntry")
                            searchEntry:Dock(TOP)
                            searchEntry:DockMargin(0, 20, 0, 15)
                            searchEntry:SetTall(30)
                            searchEntry:SetFont("LiliaFont.17")
                            searchEntry:SetPlaceholderText(L("searchStaff"))
                            searchEntry:SetTextColor(Color(200, 200, 200))
                            searchEntry.OnTextChanged = function(_, value)
                                local filteredData = filterStaffData(value or "")
                                updateStaffTable(filteredData)
                            end

                            local staffTable = panel:Add("liaTable")
                            staffTable:Dock(FILL)
                            panel.staffTable = staffTable
                            staffTable:AddColumn(L("name"), nil, TEXT_ALIGN_LEFT, true)
                            staffTable:AddColumn(L("usergroup"), nil, TEXT_ALIGN_LEFT, true)
                            staffTable:AddColumn(L("staffOnDuty", ""), 100, TEXT_ALIGN_CENTER, true)
                            function updateStaffTable(dataToShow)
                                staffTable:Clear()
                                local staffFound = false
                                if dataToShow then
                                    for _, staffInfo in ipairs(dataToShow) do
                                        staffFound = true
                                        staffTable:AddLine(staffInfo.name .. " (" .. staffInfo.characterName .. ")", staffInfo.usergroup, staffInfo.isStaffOnDuty and L("yes") or L("no"))
                                    end
                                end

                                if not staffFound then staffTable:AddLine(L("noStaffCurrentlyOnline"), "", "") end
                                staffTable:ForceCommit()
                            end

                            panel.updateStaffTable = updateStaffTable
                            updateStaffTable(staffData)
                        end

                        panel.PerformLayout = function(s)
                            if IsValid(s.staffTable) and s.staffTable.CalculateColumnWidths and s.staffTable.RebuildRows then
                                s.staffTable:CalculateColumnWidths()
                                s.staffTable:RebuildRows()
                            end
                        end

                        panel.resizeTimer = nil
                        panel.OnSizeChanged = function(s)
                            if IsValid(s.staffTable) and s.staffTable.CalculateColumnWidths and s.staffTable.RebuildRows then
                                if s.resizeTimer then timer.Remove(s.resizeTimer) end
                                s.resizeTimer = "liaStaffTableResize_" .. CurTime()
                                timer.Create(s.resizeTimer, 0.1, 1, function()
                                    if IsValid(s) and IsValid(s.staffTable) then
                                        s.staffTable:CalculateColumnWidths()
                                        s.staffTable:RebuildRows()
                                    end
                                end)
                            end
                        end

                        local function onStaffDataReceived(staffData)
                            if IsValid(panel) then
                                panel.originalStaffData = staffData or {}
                                panel.filteredStaffData = panel.originalStaffData
                                if panel.updateStaffTable then
                                    panel.updateStaffTable(panel.filteredStaffData)
                                else
                                    createStaffTable(panel.filteredStaffData)
                                end
                            end
                        end

                        hook.Add("OnlineStaffDataReceived", "liaF1MenuStaffData", onStaffDataReceived)
                        net.Start("liaRequestOnlineStaffData")
                        net.SendToServer()
                        panel.refreshTimer = timer.Create("liaAdminStaffTableRefresh", 30, 0, function()
                            if IsValid(panel) then
                                net.Start("liaRequestOnlineStaffData")
                                net.SendToServer()
                            else
                                timer.Remove("liaAdminStaffTableRefresh")
                            end
                        end)

                        panel.OnRemove = function()
                            hook.Remove("OnlineStaffDataReceived", "liaF1MenuStaffData")
                            if timer.Exists("liaAdminStaffTableRefresh") then timer.Remove("liaAdminStaffTableRefresh") end
                            if panel.resizeTimer and timer.Exists(panel.resizeTimer) then timer.Remove(panel.resizeTimer) end
                            panel.staffTable = nil
                        end
                    end
                })

                local tabContainer = vgui.Create("DPanel", frame)
                tabContainer:Dock(TOP)
                tabContainer:SetTall(40)
                tabContainer.Paint = function() end
                local contentArea = vgui.Create("liaScrollPanel", frame)
                contentArea:Dock(FILL)
                local activeTab = 1
                local tabButtons = {}
                local tabPanels = {}
                local baseTabWidths = {}
                local baseMargin = 8
                for i, page in ipairs(pages) do
                    surface.SetFont("LiliaFont.18")
                    local textWidth = surface.GetTextSize(localizeMenuLabel(page.name))
                    local iconWidth = 0
                    local padding = 20
                    local minWidth = 80
                    local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
                    baseTabWidths[i] = btnWidth
                end

                for i, page in ipairs(pages) do
                    local tabButton = vgui.Create("liaTabButton", tabContainer)
                    tabButton:Dock(LEFT)
                    tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
                    tabButton:SetTall(36)
                    tabButton:SetText(localizeMenuLabel(page.name))
                    tabButton:SetActive(i == 1)
                    tabButton:SetWide(baseTabWidths[i] or 80)
                    tabButton:SetDoClick(function()
                        if activeTab == i then return end
                        lia.websound.playButtonSound()
                        if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                        activeTab = i
                        tabPanels[i]:SetVisible(true)
                        for j, btn in ipairs(tabButtons) do
                            if IsValid(btn) then btn:SetActive(j == i) end
                        end

                        if page.drawFunc then page.drawFunc(tabPanels[i]) end
                    end)

                    tabButtons[i] = tabButton
                    local contentPanel = vgui.Create("DPanel", contentArea)
                    contentPanel:Dock(TOP)
                    contentPanel:SetVisible(i == 1)
                    contentPanel.Paint = function() end
                    contentPanel.PerformLayout = function(s) if IsValid(frame) and IsValid(tabContainer) then s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) end end
                    tabPanels[i] = contentPanel
                end

                local function AdjustTabWidths()
                    if not IsValid(tabContainer) then return end
                    local totalTabsWidth = 0
                    for _, width in pairs(baseTabWidths) do
                        totalTabsWidth = totalTabsWidth + width
                    end

                    local availableWidth = tabContainer:GetWide()
                    local totalMargins = baseMargin * (#pages - 1)
                    local extraSpace = availableWidth - totalTabsWidth - totalMargins
                    if extraSpace > 0 and #pages > 1 then
                        local extraPerTab = math.floor(extraSpace / #pages)
                        local adjustedWidths = {}
                        for tabId, baseWidth in pairs(baseTabWidths) do
                            adjustedWidths[tabId] = baseWidth + extraPerTab
                        end

                        local remainder = extraSpace % #pages
                        if remainder > 0 then
                            for remainderId = 1, math.min(remainder, #pages) do
                                adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                            end
                        end

                        for childId, child in ipairs(tabContainer:GetChildren()) do
                            if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                        end
                    end
                end

                local originalPerformLayout = tabContainer.PerformLayout
                tabContainer.PerformLayout = function(s, w, h)
                    if originalPerformLayout then originalPerformLayout(s, w, h) end
                    timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
                end

                if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then timer.Simple(0.01, function() if IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end end) end
            end
        }
    end

    local hasThemesPrivilege = IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("accessEditConfigurationMenu") or false
    if hasThemesPrivilege then
        tabs["@themes"] = {
            name = "@themes",
            func = function(themesPanel)
                local frame = themesPanel:Add("liaFrame")
                frame:Dock(FILL)
                frame:DockMargin(10, 10, 10, 10)
                frame:SetTitle(L("themes"))
                frame:LiteMode()
                frame:DisableCloseBtn()
                local sheet = frame:Add("liaTabs")
                sheet:Dock(FILL)
                local function getLocalizedThemeName(themeID)
                    local properCaseName = themeID:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
                    local localizationKey = "theme" .. properCaseName:gsub(" ", ""):gsub("-", "")
                    return L(localizationKey) or themeID
                end

                local function prettify(name)
                    name = name:gsub("_", " ")
                    return name:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
                end

                local themeIDs = lia.color.getAllThemes()
                table.sort(themeIDs, function(a, b) return getLocalizedThemeName(a) < getLocalizedThemeName(b) end)
                local currentTheme = lia.color.getCurrentTheme()
                local statusUpdaters = {}
                local activeTabIndex
                for i, themeID in ipairs(themeIDs) do
                    local themeData = lia.color.themes[themeID]
                    if istable(themeData) then
                        local displayName = getLocalizedThemeName(themeID)
                        local page = vgui.Create("DPanel")
                        page:SetPaintBackground(false)
                        page:DockPadding(12, 12, 12, 12)
                        local header = page:Add("DPanel")
                        header:Dock(TOP)
                        header:SetTall(60)
                        header:SetPaintBackground(false)
                        local applyButton = header:Add("liaButton")
                        applyButton:Dock(TOP)
                        applyButton:DockMargin(0, 5, 0, 0)
                        applyButton:SetWide(200)
                        applyButton:SetTall(35)
                        applyButton:CenterHorizontal()
                        applyButton:SetText(L("apply"))
                        local scroll = page:Add("liaScrollPanel")
                        scroll:Dock(FILL)
                        local entries = {}
                        for key, value in pairs(themeData) do
                            if lia.color.isColor(value) then
                                entries[#entries + 1] = {
                                    name = key,
                                    colors = {value}
                                }
                            elseif istable(value) then
                                local colors = {}
                                for _, subValue in ipairs(value) do
                                    if lia.color.isColor(subValue) then colors[#colors + 1] = subValue end
                                end

                                if #colors > 0 then
                                    entries[#entries + 1] = {
                                        name = key,
                                        colors = colors
                                    }
                                end
                            end
                        end

                        table.sort(entries, function(a, b) return a.name < b.name end)
                        for _, entry in ipairs(entries) do
                            local row = scroll:Add("DPanel")
                            row:Dock(TOP)
                            row:DockMargin(0, 0, 0, 8)
                            row:SetTall(80)
                            row.Paint = function(_, w, h)
                                draw.RoundedBox(8, 0, 0, w, h, Color(24, 24, 24, 220))
                                draw.SimpleText(prettify(entry.name), "LiliaFont.17", 12, 12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                local swatchSize = h - 34
                                local gap = 10
                                local totalWidth = (#entry.colors * (swatchSize + gap)) - gap
                                local startX = w - totalWidth - 12
                                local swatchY = (h - swatchSize) * 0.5
                                for idx, col in ipairs(entry.colors) do
                                    local x = startX + (idx - 1) * (swatchSize + gap)
                                    draw.RoundedBox(6, x - 2, swatchY - 2, swatchSize + 4, swatchSize + 4, Color(200, 200, 200, 255))
                                    draw.RoundedBox(6, x, swatchY, swatchSize, swatchSize, col)
                                    surface.SetDrawColor(255, 255, 255, 255)
                                    surface.DrawOutlinedRect(x, swatchY, swatchSize, swatchSize)
                                    surface.DrawOutlinedRect(x + 1, swatchY + 1, swatchSize - 2, swatchSize - 2)
                                end
                            end
                        end

                        sheet:AddTab(displayName, page)
                        local function updateStatus()
                            local isActive = currentTheme == themeID
                            if IsValid(applyButton) then
                                applyButton:SetEnabled(not isActive)
                                applyButton:SetText(isActive and L("currentlySelected") or L("apply"))
                            end
                        end

                        table.insert(statusUpdaters, updateStatus)
                        updateStatus()
                        applyButton.DoClick = function()
                            if currentTheme == themeID then return end
                            lia.websound.playButtonSound()
                            net.Start("liaCfgSet")
                            net.WriteString("Theme")
                            net.WriteString(L("theme"))
                            net.WriteType(themeID)
                            net.SendToServer()
                        end

                        if themeID == currentTheme and not activeTabIndex then activeTabIndex = i end
                    end
                end

                if activeTabIndex then sheet:SetActiveTab(activeTabIndex) end
            end
        }
    end
end)

hook.Add("CanDisplayCharInfo", "liaF1MenuCanDisplayCharInfo", function(name)
    local client = LocalPlayer()
    if not client then return true end
    local character = client:getChar()
    if not character then return true end
    if not lia.class or not lia.class.list then return true end
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end)