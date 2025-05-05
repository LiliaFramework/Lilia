local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:SetSize(ScrW(), ScrH() * 0.8)
    self:SetPos(50, 50)
    self.Paint = function() end
    local frame = vgui.Create("DFrame", self)
    frame:SetTitle("")
    frame:SetSize(ScrW() * 0.85, ScrH())
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function() end
    self.info = frame
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll.Paint = function() end
    local content = scroll:GetCanvas()
    content:DockPadding(8, 10, 8, 10)
    content.Paint = function() end
    self.content = content
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

function PANEL:GenerateSections()
    local info = lia.module.list["f1menu"].CharacterInformation
    local sections = {}
    for name, data in pairs(info) do
        sections[#sections + 1] = {
            name = name,
            data = data
        }
    end

    table.sort(sections, function(a, b) return a.data.priority < b.data.priority end)
    for _, sec in ipairs(sections) do
        local data = sec.data
        self:CreateSection(self.content, sec.name, data.color)
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, f in ipairs(fields) do
            if f.type == "text" then
                self:CreateTextEntryWithBackgroundAndLabel(self.content, f.name, f.label, 5, f.value)
            elseif f.type == "bar" then
                self:CreateFillableBarWithBackgroundAndLabel(self.content, f.name, f.label, f.min, f.max, 5, f.value)
            end

            self:AddSpacer(self.content, 5)
        end
    end
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
    local lw, lh = lbl:GetSize()
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
        bar:SetText(string.format("%d / %d", math.Round(val), math.Round(mx)))
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

function PANEL:CreateSection(parent, title, color)
    local sec = parent:Add("DPanel")
    sec:Dock(TOP)
    sec:DockMargin(0, 10, 0, 10)
    sec:SetTall(30)
    sec.Paint = function(_, w, h)
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(title, "liaSmallFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
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