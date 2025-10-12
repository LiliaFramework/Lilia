local PANEL = {}
function PANEL:Init()
    self.title = self:addLabel(L("selectFaction"))
    self.faction = self:Add("liaComboBox")
    self.faction:Dock(TOP)
    self.faction:PostInit()
    self.faction:DockMargin(0, 4, 0, 0)
    self.faction:SetTall(48)
    self.faction.Paint = function(p, w, h)
        lia.util.drawBlur(p)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end
    self.faction:SetTextColor(color_white)
    self.faction.OnSelect = function(_, _, data)
        if data then
            local fac = lia.faction.teams[data]
            if fac then
                self:onFactionSelected(fac)
            else
                self.desc:SetVisible(false)
            end
        else
            self.desc:SetVisible(false)
        end
    end
    self.desc = self:addLabel(L("description"))
    self.desc:DockMargin(0, 8, 0, 0)
    self.desc:SetFont("LiliaFont.18")
    self.desc:SetWrap(true)
    self.desc:SetAutoStretchVertical(true)
    self.desc:SetVisible(false)
    self.skipFirstSelect = true
    for id, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
        if lia.faction.hasWhitelist(fac.index) then
            if fac.uniqueID == "staff" then continue end
            self.faction:AddChoice(L(fac.name), id, self.skipFirstSelect)
            self.skipFirstSelect = false
        end
    end
    self.faction:FinishAddingOptions()
end
function PANEL:onDisplay()
    self.skipFirstSelect = true
    if self.faction.choices and #self.faction.choices > 0 then
        local currentChoices = #self.faction.choices
        local availableFactions = 0
        for _, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
            if lia.faction.hasWhitelist(fac.index) then
                if fac.uniqueID == "staff" then continue end
                availableFactions = availableFactions + 1
            end
        end
        if availableFactions ~= currentChoices then
            self.faction:Clear()
            for id, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
                if lia.faction.hasWhitelist(fac.index) then
                    if fac.uniqueID == "staff" then continue end
                    self.faction:AddChoice(L(fac.name), id)
                end
            end
            self.faction:FinishAddingOptions()
        end
    end
    local id = self.faction:GetSelectedData()
    if not id and self.faction.choices and #self.faction.choices > 0 then
        local firstChoice = self.faction.choices[1]
        if firstChoice and firstChoice.data then
            self.faction.selected = firstChoice.text
            self.faction.OnSelect(1, firstChoice.text, firstChoice.data)
            id = firstChoice.data
        end
    end
    if id then
        local fac = lia.faction.teams[id]
        if fac then
            self.desc:SetText(L(fac.desc or "noDesc"))
            self.desc:SetVisible(true)
            self:setContext("faction", fac.index)
            self:setContext("model", 1)
            self:updateModelPanel()
        else
            self.desc:SetVisible(false)
        end
    else
        self.desc:SetVisible(false)
    end
end
function PANEL:onFactionSelected(fac)
    self.desc:SetText(L(fac.desc or "noDesc"))
    self.desc:SizeToContentsY()
    self.desc:SetVisible(true)
    if self:getContext("faction") == fac.index and not self.skipFirstSelect then return end
    self:clearContext()
    self:setContext("faction", fac.index)
    self:setContext("model", 1)
    self:updateModelPanel()
    if self.skipFirstSelect then
        self.skipFirstSelect = false
        return
    end
    lia.gui.character:clickSound()
end
function PANEL:shouldSkip()
    return true
end
function PANEL:onSkip()
    local id = self.faction:GetSelectedData()
    if id then
        local fac = lia.faction.teams[id]
        if fac then self:setContext("faction", fac.index) end
    end
    self:setContext("model", self:getContext("model", 1))
end
vgui.Register("liaCharacterFaction", PANEL, "liaCharacterCreateStep")