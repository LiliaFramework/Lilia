local PANEL = {}
function PANEL:Init()
    self:Dock(FILL)
    local function makeLabel(key)
        local header = self:Add("liaHeaderPanel")
        header:Dock(TOP)
        header:DockMargin(0, 0, 0, 6)
        header:SetTall(32)
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        header:SetLineColor(accentColor)
        header:SetLineWidth(2)
        local lbl = header:Add("DLabel")
        lbl:SetFont("LiliaFont.18")
        lbl:SetText(L(key):upper())
        lbl:SizeToContents()
        lbl:Dock(FILL)
        lbl:DockMargin(8, 0, 8, 0)
        local textColor = lia.color.theme.text or Color(220, 220, 220)
        lbl:SetTextColor(textColor)
        lbl:SetContentAlignment(5)
        return header
    end

    self.factionLabel = makeLabel("faction")
    self.factionCombo = self:makeFactionComboBox()
    self.factionCombo:DockMargin(0, 6, 0, 16)
    self.nameLabel = makeLabel("name")
    self.nameEntry = self:makeTextEntry("name")
    self.nameEntry:DockMargin(0, 6, 0, 16)
    if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false then
        self.descLabel = makeLabel("desc")
        self.descEntry = self:makeTextEntry("desc")
        self.descEntry:DockMargin(0, 6, 0, 16)
    end

    self:addAttributes()
end

function PANEL:makeTextEntry(key)
    local entry = self:Add("liaEntry")
    entry:Dock(TOP)
    entry:DockMargin(0, 8, 0, 12)
    entry:SetTall(40)
    entry:SetFont("LiliaFont.18")
    entry.OnEnter = function() self:setContext(key, string.Trim(entry:GetValue())) end
    entry.OnLoseFocus = function() self:setContext(key, string.Trim(entry:GetValue())) end
    local saved = self:getContext(key)
    if saved then entry:SetValue(saved) end
    return entry
end

function PANEL:makeFactionComboBox()
    local combo = self:Add("liaComboBox")
    combo:Dock(TOP)
    combo:PostInit()
    combo:DockMargin(0, 8, 0, 12)
    combo.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    combo.OnSelect = function(_, _, data)
        local factionID = nil
        if data and isstring(data) then
            for id, fac in pairs(lia.faction.teams) do
                if L(fac.name) == data then
                    factionID = id
                    break
                end
            end
        end

        if factionID then
            local fac = lia.faction.teams[factionID]
            if fac then
                self:onFactionSelected(fac)
                return
            end
        end
    end

    local firstFactionID = nil
    for id, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
        if lia.faction.hasWhitelist(fac.index) then
            if fac.uniqueID == "staff" then continue end
            local desc = L(fac.desc or "noDesc")
            combo:AddChoice(L(fac.name), id, desc ~= "" and desc or nil)
            if not firstFactionID then firstFactionID = id end
        end
    end

    combo:FinishAddingOptions()
    if firstFactionID then
        combo:ChooseOptionData(firstFactionID)
        local fac = lia.faction.teams[firstFactionID]
        if fac then self:onFactionSelected(fac) end
    end

    combo.userSetHeight = true
    local panelTable = vgui.GetControlTable("Panel")
    if panelTable and panelTable.SetTall then
        panelTable.SetTall(combo, 40)
    else
        combo:SetTall(40)
    end

    local oldAutoSize = combo.AutoSize
    combo.AutoSize = function(pnl)
        if pnl.userSetHeight then return end
        oldAutoSize(pnl)
    end
    return combo
end

function PANEL:addAttributes()
    if IsValid(self.attribsPanel) then return end
    if not self._attemptedAttribLoad and lia.attribs and isfunction(lia.attribs.loadFromDir) then
        self._attemptedAttribLoad = true
        local base = (SCHEMA and SCHEMA.folder) and SCHEMA.folder or engine.ActiveGamemode():gsub("\\", "/")
        lia.attribs.loadFromDir(base .. "/schema/attributes")
    end

    local function makeLabel(key)
        local header = self:Add("liaHeaderPanel")
        header:Dock(TOP)
        header:DockMargin(0, 0, 0, 6)
        header:SetTall(32)
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        header:SetLineColor(accentColor)
        header:SetLineWidth(2)
        local lbl = header:Add("DLabel")
        lbl:SetFont("LiliaFont.18")
        lbl:SetText(L(key):upper())
        lbl:SizeToContents()
        lbl:Dock(FILL)
        lbl:DockMargin(8, 0, 8, 0)
        local textColor = lia.color.theme.text or Color(220, 220, 220)
        lbl:SetTextColor(textColor)
        lbl:SetContentAlignment(5)
        return header
    end

    local hasAttributes = false
    if lia.attribs and lia.attribs.list then
        for _, attrib in pairs(lia.attribs.list) do
            if not attrib.noStartBonus then
                hasAttributes = true
                break
            end
        end
    end

    if not hasAttributes then
        if not self._attribRetry then
            self._attribRetry = true
            timer.Simple(0.25, function()
                if IsValid(self) then
                    self._attribRetry = nil
                    self:addAttributes()
                    if IsValid(self.attribsPanel) then
                        self.attribsPanel:onDisplay()
                        self:updateAttributesLabel()
                    end
                end
            end)
        end
        return
    end

    local attrLabel = makeLabel("attributes")
    self.attrLabel = attrLabel
    local bgPanel = attrLabel:GetChildren()[1]
    if IsValid(bgPanel) then
        local lblContainer = bgPanel:GetChildren()[1]
        if IsValid(lblContainer) then
            local lbl = lblContainer:GetChildren()[1]
            if IsValid(lbl) and lbl.SetText then
                self.attrLabelText = lbl
                self:updateAttributesLabel()
            end
        end
    end

    self.attribsPanel = self:Add("liaCharacterAttribs")
    self.attribsPanel:Dock(TOP)
    self.attribsPanel:DockMargin(0, 6, 0, 16)
    local rows = 0
    for _, attrib in pairs(lia.attribs.list or {}) do
        if not attrib.noStartBonus then rows = rows + 1 end
    end

    self.attribsPanel:SetTall(math.max(120, 80 + rows * 40))
    self.attribsPanel:SetVisible(true)
    self.attribsPanel.parentBio = self
    if isfunction(self.attribsPanel.onDisplay) then self.attribsPanel:onDisplay() end
    if IsValid(self.attribsPanel.title) then self.attribsPanel.title:SetVisible(false) end
    if IsValid(self.attribsPanel.leftLabel) then self.attribsPanel.leftLabel:SetVisible(false) end
    self:styleAttribsPanel()
end

function PANEL:styleAttribsPanel()
    if not IsValid(self.attribsPanel) then return end
    local canvas = self.attribsPanel.GetCanvas and self.attribsPanel:GetCanvas()
    if IsValid(canvas) then canvas:DockPadding(0, 0, 0, 0) end
    if self.attribsPanel.SetPaintBackground then self.attribsPanel:SetPaintBackground(false) end
    self.attribsPanel.Paint = function() end
    if not istable(self.attribsPanel.attribs) then return end
    for _, row in pairs(self.attribsPanel.attribs) do
        if not IsValid(row) then continue end
        row:SetTall(40)
        row.Paint = function(s, w, h)
            local hover = s:IsHovered() and 1 or 0
            s._hoverFrac = Lerp(FrameTime() * 10, s._hoverFrac or 0, hover)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(4, 12):Draw()
            lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.focus_panel):Shape(lia.derma.SHAPE_IOS):Draw()
            if s._hoverFrac > 0 then
                local hov = lia.color.theme.button_hovered or Color(255, 255, 255)
                lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(hov.r, hov.g, hov.b, math.floor(s._hoverFrac * 60))):Shape(lia.derma.SHAPE_IOS):Draw()
            end
        end

        if IsValid(row.name) then
            row.name:SetFont("LiliaFont.18")
            row.name:SetTextColor(lia.color.theme.text)
        end

        if IsValid(row.quantity) then
            row.quantity:SetFont("LiliaFont.18")
            row.quantity:SetTextColor(lia.color.theme.text)
        end

        if IsValid(row.add) then
            if row.add.SetRadius then row.add:SetRadius(16) end
            if row.add.SetGradient then row.add:SetGradient(false) end
            if row.add.PaintButton then row.add:PaintButton(lia.color.theme.focus_panel, lia.color.theme.hover or lia.color.theme.button_hovered) end
        end

        if IsValid(row.sub) then
            if row.sub.SetRadius then row.sub:SetRadius(16) end
            if row.sub.SetGradient then row.sub:SetGradient(false) end
            if row.sub.PaintButton then row.sub:PaintButton(lia.color.theme.focus_panel, lia.color.theme.hover or lia.color.theme.button_hovered) end
        end

        if IsValid(row.buttons) then row.buttons:SetPaintBackground(false) end
    end
end

function PANEL:shouldSkip()
    return false
end

function PANEL:updateAttributesLabel()
    if IsValid(self.attrLabelText) then
        local total = hook.Run("GetMaxStartingAttributePoints", LocalPlayer(), lia.config.get("StartingAttributePoints", 30))
        local attribs = self:getContext("attribs", {})
        local sum = 0
        for _, quantity in pairs(attribs) do
            sum = sum + quantity
        end

        local left = math.max((total or 0) - sum, 0)
        self.attrLabelText:SetText(L("attributes"):upper() .. " - " .. left .. " " .. L("pointsLeft"):lower())
        self.attrLabelText:SizeToContents()
    end

    if IsValid(self.attrLabel) then self.attrLabel:InvalidateLayout(true) end
end

function PANEL:validate()
    for _, info in ipairs({{self.nameEntry, "name"}, {self.descEntry, "desc"}}) do
        if IsValid(info[1]) then
            local val = string.Trim(info[1]:GetValue() or "")
            if val == "" then return false, L("requiredFieldError", info[2]) end
        end
    end

    if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false and IsValid(self.descEntry) then
        local desc = string.Trim(self.descEntry:GetValue() or "")
        local descWithoutSpaces = string.gsub(desc, "%s", "")
        local minLength = lia.config.get("MinDescLen", 16)
        if #descWithoutSpaces < minLength then return false, L("descMinLen", minLength) end
    end

    local factionID = self.factionCombo:GetSelectedData()
    if not factionID then return false, L("requiredFieldError", "faction") end
    return true
end

function PANEL:onFactionSelected(fac)
    self:setContext("faction", fac.index)
    self:setContext("model", 1)
    self:updateModelPanel()
    self:updateNameAndDescForFaction(fac.index)
    lia.gui.character:clickSound()
end

function PANEL:updateNameAndDescForFaction(factionIndex)
    local client = LocalPlayer()
    local context = self:getContext()
    local defaultName, nameOverride = hook.Run("GetDefaultCharName", client, factionIndex, context)
    local defaultDesc, descOverride = hook.Run("GetDefaultCharDesc", client, factionIndex, context)
    if isstring(defaultName) and nameOverride and IsValid(self.nameEntry) then
        local currentName = string.Trim(self.nameEntry:GetValue() or "")
        if currentName == "" or nameOverride then
            timer.Simple(0.01, function()
                if IsValid(self) and IsValid(self.nameEntry) then
                    self.nameEntry:SetValue(defaultName)
                    self:setContext("name", defaultName)
                end
            end)
        end
    end

    if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false and isstring(defaultDesc) and descOverride and IsValid(self.descEntry) then
        local currentDesc = string.Trim(self.descEntry:GetValue() or "")
        if currentDesc == "" or descOverride then
            timer.Simple(0.01, function()
                if IsValid(self) and IsValid(self.descEntry) then
                    self.descEntry:SetValue(defaultDesc)
                    self:setContext("desc", defaultDesc)
                end
            end)
        end
    end
end

function PANEL:updateContext()
    if IsValid(self.nameEntry) then self:setContext("name", string.Trim(self.nameEntry:GetValue() or "")) end
    if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false then
        if IsValid(self.descEntry) then self:setContext("desc", string.Trim(self.descEntry:GetValue() or "")) end
    else
        local varData = lia.char.vars["desc"]
        if varData and varData.default then self:setContext("desc", varData.default) end
    end

    if IsValid(self.factionCombo) then
        local factionUniqueID = self.factionCombo:GetSelectedData()
        if factionUniqueID then
            local faction = lia.faction.teams[factionUniqueID]
            if faction then self:setContext("faction", faction.index) end
        end
    end
end

function PANEL:onDisplay()
    local n = IsValid(self.nameEntry) and self.nameEntry:GetValue() or ""
    local d = IsValid(self.descEntry) and self.descEntry:GetValue() or ""
    local f = self:getContext("faction")
    self:Clear()
    self:Init()
    if IsValid(self.nameEntry) then self.nameEntry:SetValue(n) end
    if IsValid(self.descEntry) then self.descEntry:SetValue(d) end
    if f then
        self.factionCombo:ChooseOptionData(f)
        self:setContext("faction", f)
        self:updateModelPanel()
        self:updateNameAndDescForFaction(f)
    end

    if IsValid(self.attribsPanel) then
        self.attribsPanel:onDisplay()
        self:styleAttribsPanel()
        timer.Simple(0.01, function() if IsValid(self) then self:updateAttributesLabel() end end)
    else
        timer.Simple(0.1, function()
            if IsValid(self) and IsValid(self.attribsPanel) then
                self.attribsPanel:onDisplay()
                self:styleAttribsPanel()
                self:updateAttributesLabel()
            end
        end)
    end
end

vgui.Register("liaCharacterBiography", PANEL, "liaCharacterCreateStep")
