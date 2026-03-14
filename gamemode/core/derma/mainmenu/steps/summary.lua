local PANEL = {}
function PANEL:Init()
    self.title = self:Add("liaHeaderPanel")
    self.title:Dock(TOP)
    self.title:DockMargin(0, 0, 0, 4)
    self.title:SetTall(32)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    self.title:SetLineColor(accentColor)
    self.title:SetLineWidth(2)
    local lbl = self.title:Add("DLabel")
    lbl:SetFont("LiliaFont.18")
    lbl:SetText(tostring(L("summary")):upper())
    lbl:SizeToContents()
    lbl:Dock(FILL)
    lbl:DockMargin(8, 0, 8, 0)
    local textColor = lia.color.theme.text or Color(220, 220, 220)
    lbl:SetTextColor(textColor)
    lbl:SetContentAlignment(5)
    self.title.label = lbl
    self.frame = self:Add("DPanel")
    self.frame:Dock(TOP)
    self.frame:DockMargin(0, 8, 0, 16)
    self.frame:DockPadding(16, 18, 16, 18)
    self.frame.Paint = function(_, w, h)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(12):Color(Color(0, 0, 0, 180)):Shadow(15, 20):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, 5):Radii(12, 12, 0, 0):Color(lia.config.get("Color") or Color(255, 255, 255)):Draw()
    end

    self.create = self.frame:Add("liaMediumButton")
    self.create:Dock(BOTTOM)
    self.create:DockMargin(0, 12, 0, 0)
    self.create:SetTall(44)
    self.create:SetText((L("create") .. " " .. L("character")):upper())
    self.create.DoClick = function()
        local createPanel = lia.gui and lia.gui.charCreate
        if IsValid(createPanel) and isfunction(createPanel.onFinish) then createPanel:onFinish() end
    end

    self.list = self.frame:Add("liaScrollPanel")
    self.list:Dock(FILL)
    self.list:DockMargin(0, 0, 0, 0)
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.frame) then
        local titleH = IsValid(self.title) and self.title:GetTall() or 0
        local _, mt, _, mb = self.frame:GetDockMargin()
        local availableH = (h or self:GetTall()) - titleH - mt - mb
        self.frame:SetTall(math.max(availableH, 64))
    end
end

function PANEL:buildDefaultSummary(context)
    local summary = {}
    local name = context.name or context.charName
    local desc = context.desc or context.description
    summary[#summary + 1] = {
        title = L("name"),
        value = tostring(name or "")
    }

    summary[#summary + 1] = {
        title = L("description"),
        value = tostring(desc or "")
    }

    local faction = context.faction and lia.faction.indices[context.faction] or nil
    summary[#summary + 1] = {
        title = L("faction"),
        value = faction and tostring(faction.name or "") or ""
    }

    local attribLines = {}
    local attribs = istable(context.attribs) and context.attribs or {}
    local attribKeys = {}
    if lia.attribs and istable(lia.attribs.list) then
        for k, _ in pairs(lia.attribs.list) do
            attribKeys[#attribKeys + 1] = k
        end

        table.sort(attribKeys, function(a, b)
            local aa = lia.attribs.list[a]
            local bb = lia.attribs.list[b]
            local an = aa and aa.name or tostring(a)
            local bn = bb and bb.name or tostring(b)
            return tostring(an) < tostring(bn)
        end)

        for _, k in ipairs(attribKeys) do
            local attr = lia.attribs.list[k]
            local attrName = attr and attr.name or tostring(k)
            local v = tonumber(attribs[k]) or 0
            attribLines[#attribLines + 1] = tostring(attrName) .. ": " .. tostring(v)
        end
    end

    if #attribLines > 0 then
        summary[#summary + 1] = {
            title = L("attributes"),
            value = table.concat(attribLines, "\n")
        }
    end

    local idLines = {}
    local identifications = istable(context.identifications) and context.identifications or {}
    local idKeys = {}
    for k, _ in pairs(identifications) do
        idKeys[#idKeys + 1] = k
    end

    table.sort(idKeys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(idKeys) do
        local v = identifications[k]
        if v ~= nil then idLines[#idLines + 1] = tostring(k) .. ": " .. tostring(v) end
    end

    if #idLines > 0 then
        summary[#summary + 1] = {
            title = L("identifications"),
            value = table.concat(idLines, "\n")
        }
    end
    return summary
end

function PANEL:getSummary(context)
    local summary = self:buildDefaultSummary(context)
    local ret = hook.Run("GetCharacterCreationSummary", LocalPlayer(), context, summary, self)
    if istable(ret) then summary = ret end
    hook.Run("ModifyCharacterCreationSummary", LocalPlayer(), context, summary, self)
    return summary
end

function PANEL:addEntry(entry)
    local header = self.list:Add("liaHeaderPanel")
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 12)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    header:SetLineColor(accentColor)
    header:SetLineWidth(2)
    header:DockPadding(10, 10, 10, 12)
    local title = header:Add("DLabel")
    title:SetFont("LiliaFont.16")
    title:SetText(tostring(entry.title or ""):upper())
    title:Dock(TOP)
    title:DockMargin(0, 0, 0, 6)
    title:SetTextColor(lia.color.theme and lia.color.theme.text or Color(220, 220, 220))
    title:SetContentAlignment(4)
    local value = header:Add("DLabel")
    value:SetFont("LiliaFont.17")
    value:SetTextColor(Color(230, 230, 230))
    value:SetWrap(true)
    value:SetAutoStretchVertical(true)
    value:SetText(tostring(entry.value or ""))
    value:Dock(TOP)
    value:DockMargin(0, 0, 0, 0)
    header.PerformLayout = function(s, w, h)
        local l, t, r, b = s:GetDockPadding()
        local innerW = math.max((w or s:GetWide()) - l - r, 0)
        if IsValid(title) then
            title:SetWide(innerW)
            title:SizeToContentsY()
        end

        if IsValid(value) then
            value:SetWide(innerW)
            value:SizeToContentsY()
        end

        local totalH = 0
        for _, child in ipairs(s:GetChildren()) do
            if IsValid(child) and child:IsVisible() then
                totalH = totalH + child:GetTall()
                local _, mt, _, mb = child:GetDockMargin()
                totalH = totalH + mt + mb
            end
        end

        s:SetTall(totalH + t + b)
    end

    header:InvalidateLayout(true)
end

function PANEL:onDisplay()
    if IsValid(self.list) then self.list:Clear() end
    local createPanel = lia.gui and lia.gui.charCreate
    if IsValid(createPanel) and IsValid(createPanel.next) then
        self._oldNextVisible = createPanel.next:IsVisible()
        self._oldNextAlpha = createPanel.next:GetAlpha()
        createPanel.next:SetVisible(false)
        createPanel.next:SetMouseInputEnabled(false)
    end

    if IsValid(createPanel) and istable(createPanel.steps) then
        for _, step in ipairs(createPanel.steps) do
            if IsValid(step) and isfunction(step.updateContext) then step:updateContext() end
        end
    end

    local context = self:getContext() or {}
    local summary = self:getSummary(context)
    if not istable(summary) then return end
    for _, entry in ipairs(summary) do
        if istable(entry) then self:addEntry(entry) end
    end
end

function PANEL:onHide()
    local createPanel = lia.gui and lia.gui.charCreate
    if IsValid(createPanel) and IsValid(createPanel.next) then
        createPanel.next:SetVisible(self._oldNextVisible ~= false)
        createPanel.next:SetAlpha(self._oldNextAlpha or 255)
        createPanel.next:SetMouseInputEnabled(true)
    end

    self._oldNextVisible = nil
    self._oldNextAlpha = nil
end

function PANEL:validate()
    return true
end

vgui.Register("liaCharacterSummary", PANEL, "liaCharacterCreateStep")
