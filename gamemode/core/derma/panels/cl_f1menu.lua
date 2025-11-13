local PANEL = {}
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
    for _, module in pairs(lia.module.list) do
        if module.LoadCharInformation then module:LoadCharInformation() end
    end

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
    entry.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel_alpha[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
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

    txt.action = function(value) if isDesc and isstring(value) then lia.command.send("chardesc", value) end end
    self[name] = txt
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minFunc, maxFunc, margin, valueFunc)
    local entry = parent:Add("DPanel")
    entry:Dock(TOP)
    entry:DockMargin(0, margin or 0, 0, margin or 0)
    entry:SetTall(40)
    entry.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel_alpha[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
    local lbl = entry:Add("DLabel")
    lbl:Dock(LEFT)
    lbl:SetFont("LiliaFont.17")
    lbl:SetText(labelText or "")
    lbl:SizeToContents()
    lbl:SetWide(lbl:GetWide() + 20)
    lbl:DockMargin(8, 0, 10, 0)
    lbl:SetContentAlignment(5)
    lbl:SetTextColor(lia.color.theme.text or Color(210, 235, 235))
    local bar = entry:Add("DPanel")
    bar:Dock(FILL)
    bar:DockMargin(0, 6, 8, 6)
    bar.Paint = function(_, w, h)
        local mn = isfunction(minFunc) and minFunc() or tonumber(minFunc) or 0
        local mx = isfunction(maxFunc) and maxFunc() or tonumber(maxFunc) or 1
        local val = isfunction(valueFunc) and valueFunc() or tonumber(valueFunc) or 0
        local frac = mx > mn and math.Clamp((val - mn) / (mx - mn), 0, 1) or 0
        lia.derma.rect(0, 0, w, h):Rad(6):Color(lia.color.theme.focus_panel):Shape(lia.derma.SHAPE_IOS):Draw()
        if frac > 0 then lia.derma.rect(0, 0, w * frac, h):Rad(6):Color(lia.color.theme.theme):Shape(lia.derma.SHAPE_IOS):Draw() end
        local text = L("barProgress", math.Round(val), math.Round(mx))
        draw.SimpleText(text, "LiliaFont.17", w / 2, h / 2, lia.color.theme.text or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

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
    local maxSectionHeight = ScrH() * 0.45
    frame.Paint = function(_, w)
        draw.SimpleText(L(title), "LiliaFont.17", w / 2, 8, lia.color.theme.text or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        surface.SetDrawColor(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, 100)
        surface.DrawLine(12, 28, w - 12, 28)
    end

    local header = vgui.Create("DPanel", frame)
    header:SetTall(35)
    header:Dock(TOP)
    header:DockPadding(0, 0, 0, 0)
    header.Paint = function() end
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll.Paint = function() end
    local contents = scroll:GetCanvas()
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
        f:SetTall(math.max(100, math.min(estimatedHeight, maxSectionHeight)))
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
    local baseBtnW, btnH, spacing = 150, 40, 20
    self.baseBtnW = baseBtnW
    local topBar = self:Add("DPanel")
    topBar:Dock(TOP)
    topBar:SetTall(70)
    topBar:DockPadding(30, 10, 30, 10)
    local iconMat = Material("lilia.png")
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

    local leftArrow = topBar:Add("liaSmallButton")
    leftArrow:Dock(LEFT)
    leftArrow:DockMargin(0, 0, spacing, 0)
    leftArrow:SetWide(40)
    leftArrow:SetText(L("previousArrow"))
    leftArrow:SetFont("LiliaFont.25")
    leftArrow:SetTextColor(color_white)
    leftArrow:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    local rightArrow = topBar:Add("liaSmallButton")
    rightArrow:Dock(RIGHT)
    rightArrow:DockMargin(spacing, 0, 0, 0)
    rightArrow:SetWide(40)
    rightArrow:SetText(L("nextArrow"))
    rightArrow:SetFont("LiliaFont.25")
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
        lia.websound.playButtonSound()
        tabsContainer.tabOffset = (tabsContainer.tabOffset or 0) + baseBtnW + spacing
        tabsContainer:InvalidateLayout()
    end

    rightArrow.DoClick = function()
        lia.websound.playButtonSound()
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
    timer.Simple(0.1, function() if IsValid(self) then self:UpdateTabColors() end end)
end

function PANEL:addTab(name, callback)
    local tab = self.tabs:Add("liaSmallButton")
    tab:SetText(L(name))
    tab:SetFont("LiliaFont.25")
    surface.SetFont(tab:GetFont())
    local tw = select(1, surface.GetTextSize(tab:GetText()))
    tab.calcW = math.max(self.baseBtnW or 150, tw + 20)
    tab:SetTextColor(lia.color.theme.text or Color(210, 235, 235))
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    tab:SetContentAlignment(5)
    tab.DoClick = function()
        lia.websound.playButtonSound()
        if IsValid(lia.gui.info) then lia.gui.info:Remove() end
        for _, t in pairs(self.tabList) do
            t:SetSelected(false)
        end

        tab:SetSelected(true)
        self.activeTab = tab
        self.panel:Clear()
        self.panel:AlphaTo(255, 0.3, 0)
        if callback then
            self:UpdateTabColors()
            self:ApplyCurrentTheme()
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
        return
    end

    for _, tabPanel in pairs(self.tabList) do
        if IsValid(tabPanel) and tabPanel:GetText() == key then
            tabPanel:DoClick()
            tabPanel:SetSelected(true)
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
    if not self.tabList then return end
    local textColor = lia.color.theme.text or Color(210, 235, 235)
    for _, tab in pairs(self.tabList) do
        if IsValid(tab) then tab:SetTextColor(textColor) end
    end
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
    self.sidebar = self:Add("liaScrollPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(220)
    self.sidebar:DockMargin(20, 20, 0, 20)
    self.sidebar.Paint = function(_, sidebarW, sidebarH)
        local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 90)
        local backgroundPanel = lia.color.theme and lia.color.theme.background_panelpopup or Color(20, 28, 28)
        lia.derma.rect(0, 0, sidebarW, sidebarH):Rad(12):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(8, 16):Draw()
        lia.derma.rect(0, 0, sidebarW, sidebarH):Rad(12):Color(backgroundPanel):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    self.mainContent = self:Add("liaScrollPanel")
    self.mainContent:Dock(FILL)
    self.mainContent:DockMargin(10, 10, 10, 10)
    self.mainContent.Paint = function(_, contentW, contentH)
        local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 90)
        local backgroundPanel = lia.color.theme and lia.color.theme.background_panelpopup or Color(20, 28, 28)
        lia.derma.rect(0, 0, contentW, contentH):Rad(12):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(8, 16):Draw()
        lia.derma.rect(0, 0, contentW, contentH):Rad(12):Color(backgroundPanel):Shape(lia.derma.SHAPE_IOS):Draw()
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
    for _, cl in ipairs(list) do
        local canBe = lia.class.canBe(LocalPlayer(), cl.index)
        local btn = self.sidebar:Add("liaMediumButton")
        btn:SetText(cl.name and L(cl.name) or L("unnamed"))
        btn:SetTall(50)
        btn:Dock(TOP)
        btn:DockMargin(5, 5, 5, 5)
        local textColor = lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().text or color_white
        btn:SetTextColor(textColor)
        btn:SetFont("LiliaFont.25")
        btn:SetExpensiveShadow(1, Color(0, 0, 0, 100))
        btn.DoClick = function()
            lia.websound.playButtonSound()
            for _, b in ipairs(self.tabList) do
                b:SetSelected(b == btn)
            end

            self:populateClassDetails(cl, canBe)
        end

        self.tabList[#self.tabList + 1] = btn
    end
end

function PANEL:populateClassDetails(cl, canBe)
    self.mainContent:Clear()
    local container = self.mainContent:Add("DPanel")
    container:Dock(TOP)
    container:DockMargin(10, 10, 10, 10)
    container:SetTall(800)
    container.Paint = function(_, w, h)
        local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 90)
        local backgroundPanel = lia.color.theme and lia.color.theme.background_panelpopup or Color(20, 28, 28)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 12):Draw()
        lia.derma.rect(0, 0, w, h):Rad(8):Color(backgroundPanel):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    if cl.logo then
        local img = container:Add("DImage")
        img:SetImage(cl.logo)
        img:setScaledSize(128, 128)
        img.Think = function() img:SetPos(container:GetWide() - img:GetWide() - 10, 10) end
    end

    self:createModelPanel(container, cl)
    self:addClassDetails(container, cl)
    self:addJoinButton(container, cl, canBe)
end

function PANEL:createModelPanel(parent, cl)
    local sizeX, sizeY = 300, 600
    local panel = parent:Add("liaModelPanel")
    panel:Dock(RIGHT)
    panel:DockMargin(10, 20, 20, 20)
    panel:SetWide(sizeX)
    panel:SetTall(sizeY)
    panel:SetFOV(35)
    panel.Paint = function(_, modelW, modelH)
        local windowShadow = lia.color.theme and lia.color.theme.window_shadow or Color(18, 32, 32, 90)
        local backgroundPanel = lia.color.theme and lia.color.theme.background_panelpopup or Color(20, 28, 28)
        lia.derma.rect(0, 0, modelW, modelH):Rad(8):Color(windowShadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 12):Draw()
        lia.derma.rect(0, 0, modelW, modelH):Rad(8):Color(backgroundPanel):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local function getModel(mdl)
        if isstring(mdl) then return mdl end
        if istable(mdl) then
            local models = {}
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
            if #models > 0 then return models[math.random(#models)] end
        end
    end

    local model = getModel(cl.model) or LocalPlayer():GetModel()
    panel:SetModel(model)
    panel.rotationAngle = 45
    local ent = panel.Entity
    ent:SetSkin(cl.skin or 0)
    for _, bg in ipairs(cl.bodyGroups or {}) do
        ent:SetBodygroup(bg.id, bg.value or 0)
    end

    for i, mat in ipairs(cl.subMaterials or {}) do
        ent:SetSubMaterial(i - 1, mat)
    end

    panel.Think = function()
        if IsValid(ent) then
            if input.IsKeyDown(KEY_A) then
                panel.rotationAngle = panel.rotationAngle - 0.5
            elseif input.IsKeyDown(KEY_D) then
                panel.rotationAngle = panel.rotationAngle + 0.5
            end

            ent:SetAngles(Angle(0, panel.rotationAngle, 0))
        end
    end
end

function PANEL:addClassDetails(parent, cl)
    local client = LocalPlayer()
    local maxH, maxA, maxJ = client:GetMaxHealth(), client:GetMaxArmor(), client:GetJumpPower()
    local run, walk = lia.config.get("RunSpeed"), lia.config.get("WalkSpeed")
    local function add(text)
        local lbl = parent:Add("DLabel")
        lbl:SetFont("LiliaFont.25")
        lbl:SetText(text)
        local textColor = lia.color.returnMainAdjustedColors and lia.color.returnMainAdjustedColors().text or color_white
        lbl:SetTextColor(textColor)
        lbl:SetWrap(true)
        lbl:Dock(TOP)
        lbl:DockMargin(10, 5, 10, 0)
        lbl.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(0, 0, 0, 30)):Shape(lia.derma.SHAPE_IOS):Draw() end
    end

    add(L("name") .. ": " .. (cl.name and L(cl.name) or L("unnamed")))
    add(L("description") .. ": " .. (cl.desc and L(cl.desc) or L("noDesc")))
    local facName = team.GetName(cl.faction)
    add(L("faction") .. ": " .. (facName and L(facName) or L("none")))
    add(L("isDefault") .. ": " .. (cl.isDefault and L("yes") or L("no")))
    add(L("baseHealth") .. ": " .. tostring(cl.health or maxH))
    add(L("baseArmor") .. ": " .. tostring(cl.armor or maxA))
    local weps = cl.weapons or {}
    add(L("weapons") .. ": " .. (#weps > 0 and table.concat(weps, ", ") or L("none")))
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
    if cl.requirements then
        local req
        if istable(cl.requirements) then
            local reqs = {}
            for _, v in ipairs(cl.requirements) do
                reqs[#reqs + 1] = L(v)
            end

            req = table.concat(reqs, ", ")
        else
            req = L(tostring(cl.requirements))
        end

        add(L("requirements") .. ": " .. req)
    end
end

function PANEL:addJoinButton(parent, cl, canBe)
    local isCurrent = LocalPlayer():getChar() and LocalPlayer():getChar():getClass() == cl.index
    local btn = parent:Add("liaMediumButton")
    btn:SetText(isCurrent and L("alreadyInClass") or canBe and L("joinClass") or L("classRequirementsNotMet"))
    btn:SetTall(45)
    btn:Dock(BOTTOM)
    btn:DockMargin(10, 10, 10, 10)
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

    btn:SetDisabled(isCurrent or not canBe)
    btn.DoClick = function()
        lia.websound.playButtonSound()
        if canBe and not isCurrent then
            lia.command.send("beclass", cl.index)
            timer.Simple(0.1, function()
                if IsValid(self) then
                    self:loadClasses()
                    self.mainContent:Clear()
                end
            end)
        end
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

    hook.Run("AddTextField", L("generalInfo"), "desc", L("description"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getDesc() or ""
    end)

    hook.Run("AddTextField", L("generalInfo"), "money", L("money"), function()
        local client = LocalPlayer()
        return client and lia.currency.get(client:getChar():getMoney()) or lia.currency.get(0)
    end)

    hook.Run("AddTextField", L("generalInfo"), "playTime", L("playTime"), function()
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
    tabs["you"] = function(statusPanel)
        statusPanel.info = vgui.Create("liaCharInfo", statusPanel)
        statusPanel.info:Dock(FILL)
        statusPanel.info:setup()
        statusPanel.info:SetAlpha(0)
        statusPanel.info:AlphaTo(255, 0.5)
    end

    tabs["information"] = function(infoTabPanel)
        local frame = infoTabPanel:Add("liaFrame")
        frame:Dock(FILL)
        frame:DockMargin(10, 10, 10, 10)
        frame:SetTitle(L("information"))
        frame:LiteMode()
        frame:DisableCloseBtn()
        local pages = {}
        hook.Run("CreateInformationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
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
            local textWidth = surface.GetTextSize(L(page.name))
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
            tabButton:SetText(L(page.name))
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

        if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
    end

    tabs["settings"] = function(settingsPanel)
        local frame = settingsPanel:Add("liaFrame")
        frame:Dock(FILL)
        frame:DockMargin(10, 10, 10, 10)
        frame:SetTitle(L("settings"))
        frame:LiteMode()
        frame:DisableCloseBtn()
        local pages = {}
        hook.Run("PopulateConfigurationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
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
            local textWidth = surface.GetTextSize(L(page.name))
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
            tabButton:SetText(L(page.name))
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

        if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
    end

    local adminPages = {}
    hook.Run("PopulateAdminTabs", adminPages)
    if not table.IsEmpty(adminPages) then
        tabs["admin"] = function(adminPanel)
            local frame = adminPanel:Add("liaFrame")
            frame:Dock(FILL)
            frame:DockMargin(10, 10, 10, 10)
            frame:SetTitle(L("admin"))
            frame:LiteMode()
            frame:DisableCloseBtn()
            local pages = {}
            hook.Run("PopulateAdminTabs", pages)
            if table.IsEmpty(pages) then return end
            table.sort(pages, function(a, b)
                local an = tostring(a.name):lower()
                local bn = tostring(b.name):lower()
                return an < bn
            end)

            table.insert(pages, 1, {
                name = "onlineStaff",
                icon = "icon16/user.png",
                drawFunc = function(panel)
                    panel.originalStaffData = {}
                    panel.filteredStaffData = {}
                    local function filterStaffData(searchText)
                        if not searchText or searchText == "" then
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
                        local searchEntry = panel:Add("DTextEntry")
                        searchEntry:Dock(TOP)
                        searchEntry:DockMargin(0, 0, 0, 15)
                        searchEntry:SetTall(30)
                        searchEntry:SetFont("LiliaFont.17")
                        searchEntry:SetPlaceholderText(L("searchStaff") or "Search staff...")
                        searchEntry:SetTextColor(Color(200, 200, 200))
                        searchEntry.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
                        searchEntry.OnChange = function(textEntry)
                            local filteredData = filterStaffData(textEntry:GetValue())
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
                local textWidth = surface.GetTextSize(L(page.name))
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
                tabButton:SetText(L(page.name))
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
    end

    local hasPrivilege = IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("accessEditConfigurationMenu") or false
    if hasPrivilege then
        tabs["themes"] = function(themesPanel)
            local sheet = themesPanel:Add("liaTabs")
            sheet:Dock(FILL)
            sheet:DockMargin(10, 10, 10, 10)
            sheet.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.background):Draw() end
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
                    local applyButton = header:Add("liaSmallButton")
                    applyButton:Dock(TOP)
                    applyButton:DockMargin(0, 5, 0, 0)
                    applyButton:SetWide(200)
                    applyButton:SetTall(35)
                    applyButton:CenterHorizontal()
                    applyButton:SetText(L("apply"))
                    local scroll = page:Add("DScrollPanel")
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
                                draw.RoundedBox(6, x, swatchY, swatchSize, swatchSize, col)
                                surface.SetDrawColor(255, 255, 255, 60)
                                surface.DrawOutlinedRect(x, swatchY, swatchSize, swatchSize)
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
