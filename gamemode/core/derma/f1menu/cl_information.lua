local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:SetSize(ScrW() * 0.85, ScrH() * 0.8)
    self:SetPos(50, 50)
    self.Paint = function() end
    local scroll = vgui.Create("liaScrollPanel", self)
    scroll:Dock(FILL)
    scroll:InvalidateLayout(true)
    if not IsValid(scroll.VBar) then scroll:PerformLayout() end
    local canvas = scroll:GetCanvas()
    canvas:DockPadding(8, 10, 8, 20)
    canvas.Paint = function() end
    self.content = canvas
    hook.Run("LoadCharInformation")
    if lia.module and lia.module.list then
        for _, module in pairs(lia.module.list) do
            if module.LoadCharInformation then module:LoadCharInformation() end
        end
    end
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    local function tryGenerate()
        if not IsValid(self) then return end
        local client = LocalPlayer()
        local char = client:getChar()
        local info = lia.module.list and lia.module.list["f1menu"] and lia.module.list["f1menu"].CharacterInformation or {}
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
    lbl:SetFont("liaSmallFont")
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
    txt:SetFont("liaSmallFont")
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
    lbl:SetFont("liaSmallFont")
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
        draw.SimpleText(text, "liaSmallFont", w / 2, h / 2, lia.color.theme.text or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    local info = lia.module.list and lia.module.list["f1menu"] and lia.module.list["f1menu"].CharacterInformation or {}
    local secs = {}
    if table.IsEmpty(info) then return end
    for name, data in pairs(info) do
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
    frame.Paint = function(_, w, _)
        draw.SimpleText(L(title), "liaSmallFont", w / 2, 8, lia.color.theme.text or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        surface.SetDrawColor(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, 100)
        surface.DrawLine(12, 28, w - 12, 28)
    end
    local contents = vgui.Create("DPanel", frame)
    contents:Dock(FILL)
    contents:DockPadding(8, 35, 8, 10)
    contents.Paint = function() end
    contents.PerformLayout = function(s)
        local contentHeight = 35
        for _, child in ipairs(s:GetChildren()) do
            if IsValid(child) then
                contentHeight = contentHeight + child:GetTall()
                if child.GetDockMargin then
                    local _, top = child:GetDockMargin()
                    if top then contentHeight = contentHeight + top end
                end
            end
        end
        contentHeight = contentHeight + 10
        frame:SetTall(math.max(60, contentHeight))
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
    local info = lia.module.list and lia.module.list["f1menu"] and lia.module.list["f1menu"].CharacterInformation or {}
    if table.IsEmpty(info) then return end
    for _, data in pairs(info) do
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, f in ipairs(fields) do
            local ctrl = self[f.name]
            if ctrl and f.type == "text" and f.name:lower() ~= "desc" then ctrl:SetValue(f.value()) end
        end
    end
end
vgui.Register("liaCharInfo", PANEL, "EditablePanel")