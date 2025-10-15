﻿local PANEL = {}
function PANEL:Init()
    self:Dock(FILL)
    local function makeLabel(key)
        local lbl = self:Add("DPanel")
        lbl:Dock(TOP)
        lbl:DockMargin(0, 0, 0, 8)
        lbl:SetTall(32)
        lbl.Paint = function(_, _, h) draw.SimpleText(L(key):upper(), "liaMediumFont", 0, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        return lbl
    end

    self.factionLabel = makeLabel("faction")
    self.factionCombo = self:makeFactionComboBox()
    self.factionCombo:DockMargin(0, 8, 0, 12)
    self.factionCombo:SetTall(48)
    self.nameLabel = makeLabel("name")
    self.nameEntry = self:makeTextEntry("name")
    self.nameEntry:DockMargin(0, 8, 0, 12)
    self.descLabel = makeLabel("desc")
    self.descEntry = self:makeTextEntry("desc")
    self.descEntry:DockMargin(0, 8, 0, 12)
    self:addAttributes()
end

function PANEL:makeTextEntry(key)
    local entry = self:Add("liaEntry")
    entry:Dock(TOP)
    entry:DockMargin(0, 8, 0, 12)
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
    combo:SetTall(48)
    combo.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    combo.OnSelect = function(_, _, data)
        local factionID = nil
        if data and type(data) == "string" then
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

    for id, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
        if lia.faction.hasWhitelist(fac.index) then
            if fac.uniqueID == "staff" then continue end
            combo:AddChoice(L(fac.name), id)
        end
    end

    combo:FinishAddingOptions()
    return combo
end

function PANEL:addAttributes()
    local function makeLabel(key)
        local lbl = self:Add("DPanel")
        lbl:Dock(TOP)
        lbl:DockMargin(0, 0, 0, 8)
        lbl:SetTall(32)
        lbl.Paint = function(_, _, h) draw.SimpleText(L(key):upper(), "liaMediumFont", 0, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        return lbl
    end

    local hasAttributes = false
    for _, attrib in pairs(lia.attribs.list) do
        if not attrib.noStartBonus then
            hasAttributes = true
            break
        end
    end

    if not hasAttributes then return end
    local attrLabel = makeLabel("attributes")
    self.attrLabel = attrLabel
    self.attribsPanel = self:Add("liaCharacterAttribs")
    self.attribsPanel:Dock(TOP)
    self.attribsPanel:DockMargin(0, 8, 0, 12)
    self.attribsPanel.parentBio = self
end

function PANEL:shouldSkip()
    return false
end

function PANEL:updateAttributesLabel()
    if IsValid(self.attrLabel) and IsValid(self.attribsPanel) then
        local points = self.attribsPanel.left or 0
        self.attrLabel:SetText(L("attributes"):upper() .. " - " .. points .. " " .. L("pointsLeft"):lower())
    end
end

function PANEL:validate()
    for _, info in ipairs({{self.nameEntry, "name"}, {self.descEntry, "desc"}}) do
        local val = string.Trim(info[1]:GetValue() or "")
        if val == "" then return false, L("requiredFieldError", info[2]) end
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

    if isstring(defaultDesc) and descOverride and IsValid(self.descEntry) then
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
    if IsValid(self.descEntry) then self:setContext("desc", string.Trim(self.descEntry:GetValue() or "")) end
    if IsValid(self.factionCombo) then
        local factionUniqueID = self.factionCombo:GetSelectedData()
        if factionUniqueID then
            local faction = lia.faction.teams[factionUniqueID]
            if faction then self:setContext("faction", faction.index) end
        end
    end
end

function PANEL:onDisplay()
    local n, d = self.nameEntry:GetValue(), self.descEntry:GetValue()
    local f = self:getContext("faction")
    self:Clear()
    self:Init()
    self.nameEntry:SetValue(n)
    self.descEntry:SetValue(d)
    if f then
        self.factionCombo:ChooseOptionData(f)
        self:setContext("faction", f)
        self:updateModelPanel()
        self:updateNameAndDescForFaction(f)
    end

    if IsValid(self.attribsPanel) then
        self.attribsPanel:onDisplay()
        timer.Simple(0.01, function() if IsValid(self) then self:updateAttributesLabel() end end)
    end
end

vgui.Register("liaCharacterBiography", PANEL, "liaCharacterCreateStep")
