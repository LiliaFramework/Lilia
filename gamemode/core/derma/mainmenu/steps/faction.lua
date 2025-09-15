local PANEL = {}
function PANEL:Init()
    self.title = self:addLabel(L("selectFaction"))
    self.faction = self:Add("DComboBox")
    self.faction:SetFont("liaCharButtonFont")
    self.faction:Dock(TOP)
    self.faction:DockMargin(0, 4, 0, 0)
    self.faction:SetTall(40)
    self.faction.Paint = function(p, w, h)
        lia.util.drawBlur(p)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end
    self.faction:SetTextColor(color_white)
    self.faction.OnSelect = function(_, _, _, id) self:onFactionSelected(lia.faction.teams[id]) end
    self.desc = self:addLabel(L("description"))
    self.desc:DockMargin(0, 8, 0, 0)
    self.desc:SetFont("liaCharSubTitleFont")
    self.desc:SetWrap(true)
    self.desc:SetAutoStretchVertical(true)
    self.skipFirstSelect = true
    for id, fac in SortedPairsByMemberValue(lia.faction.teams, "name") do
        if lia.faction.hasWhitelist(fac.index) then
            self.faction:AddChoice(L(fac.name), id, self.skipFirstSelect)
            self.skipFirstSelect = false
        end
    end
end
function PANEL:onDisplay()
    self.skipFirstSelect = true
    local _, id = self.faction:GetSelected()
    local fac = lia.faction.teams[id]
    if fac then self:onFactionSelected(fac) end
end
function PANEL:onFactionSelected(fac)
    if self:getContext("faction") == fac.index then return end
    self.desc:SetText(L(fac.desc or "noDesc"))
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
    return #self.faction.Choices == 1
end
function PANEL:onSkip()
    local _, id = self.faction:GetSelected()
    local fac = lia.faction.teams[id]
    self:setContext("faction", fac and fac.index)
    self:setContext("model", self:getContext("model", 1))
end
vgui.Register("liaCharacterFaction", PANEL, "liaCharacterCreateStep")
