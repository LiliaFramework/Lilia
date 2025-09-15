local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:SetSize(ScrW() * 0.85, ScrH() * 0.8)
    self:SetPos(50, 50)
    self.Paint = function() end
    local scroll = vgui.Create("DScrollPanel", self)
    scroll:Dock(FILL)
    local canvas = scroll:GetCanvas()
    canvas:DockPadding(8, 10, 8, 10)
    canvas.Paint = function() end
    self.content = canvas
    hook.Run("LoadCharInformation")
    self:GenerateSections()
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
    entry:SetTall(25)
    local lbl = entry:Add("DLabel")
    lbl:Dock(LEFT)
    lbl:SetFont("liaSmallFont")
    lbl:SetText(labelText or "")
    lbl:SizeToContents()
    local lw, _ = lbl:GetSize()
    lbl:SetWide(lw + 20)
    lbl:DockMargin(0, 0, 10, 0)
    lbl:SetContentAlignment(5)
    lbl:SetTextColor(color_white)
    local txt = entry:Add("DTextEntry")
    txt:Dock(FILL)
    txt:SetFont("liaSmallFont")
    txt:SetTall(20)
    txt:SetTextColor(color_white)
    local isDesc = (name or ""):lower() == "desc"
    txt:SetEditable(isDesc)
    if isfunction(valueFunc) then
        local v = valueFunc()
        if isstring(v) then txt:SetText(v) end
    end
    txt.OnLoseFocus = function(selfEntry)
        if isDesc then
            local t = selfEntry:GetValue()
            if isstring(t) then lia.command.send("chardesc", t) end
        end
    end
    self[name] = txt
end
function PANEL:CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minFunc, maxFunc, margin, valueFunc)
    local entry = parent:Add("DPanel")
    entry:Dock(TOP)
    entry:DockMargin(0, margin or 0, 0, margin or 0)
    entry:SetTall(30)
    local lbl = entry:Add("DLabel")
    lbl:Dock(LEFT)
    lbl:SetFont("liaSmallFont")
    lbl:SetText(labelText or "")
    lbl:SizeToContents()
    lbl:SetWide(lbl:GetWide() + 20)
    lbl:DockMargin(0, 0, 10, 0)
    lbl:SetContentAlignment(5)
    lbl:SetTextColor(color_white)
    local bar = entry:Add("DProgressBar")
    bar:Dock(FILL)
    bar:SetBarColor(Color(45, 45, 45, 255))
    local function updateBar()
        local mn = isfunction(minFunc) and minFunc() or tonumber(minFunc) or 0
        local mx = isfunction(maxFunc) and maxFunc() or tonumber(maxFunc) or 1
        local val = isfunction(valueFunc) and valueFunc() or tonumber(valueFunc) or 0
        local frac = mx > mn and math.Clamp((val - mn) / (mx - mn), 0, 1) or 0
        bar:SetFraction(frac)
        bar:SetText(L("barProgress", math.Round(val), math.Round(mx)))
    end
    function bar:Think()
        updateBar()
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
    local info = lia.module.list["f1menu"].CharacterInformation
    local secs = {}
    for name, data in pairs(info) do
        secs[#secs + 1] = {
            name = name,
            data = data
        }
    end
    table.sort(secs, function(a, b) return a.data.priority < b.data.priority end)
    for _, sec in ipairs(secs) do
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
    end
end
function PANEL:CreateSection(parent, title)
    local cat = parent:Add("DCollapsibleCategory")
    cat:Dock(TOP)
    cat:DockMargin(0, 10, 0, 10)
    cat:SetLabel("")
    cat:SetExpanded(true)
    cat.Header:SetTall(30)
    cat.Paint = function() end
    cat.Header.Paint = function(p, w, h)
        derma.SkinHook("Paint", "Panel", p, w, h)
        draw.SimpleText(L(title), "liaSmallFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local contents = vgui.Create("DPanel", cat)
    contents:Dock(FILL)
    contents:DockPadding(8, 10, 8, 10)
    contents.Paint = function() end
    cat:SetContents(contents)
    return contents
end
function PANEL:Refresh()
    self.content:Clear()
    self:GenerateSections()
end
function PANEL:setup()
    local info = lia.module.list["f1menu"].CharacterInformation
    for _, data in pairs(info) do
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, f in ipairs(fields) do
            local ctrl = self[f.name]
            if ctrl and f.type == "text" and f.name:lower() ~= "desc" then ctrl:SetText(f.value()) end
        end
    end
end
vgui.Register("liaCharInfo", PANEL, "EditablePanel")
