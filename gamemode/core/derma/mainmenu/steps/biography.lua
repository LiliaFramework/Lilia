local PANEL = {}
local HIGHLIGHT = Color(255, 255, 255, 50)
function PANEL:Init()
    self:SetSize(400, 600)
    local function makeLabel(key)
        local lbl = self:Add("DLabel")
        lbl:SetFont("liaMediumFont")
        lbl:SetText(L(key):upper())
        lbl:SizeToContents()
        lbl:Dock(TOP)
        lbl:DockMargin(0, 0, 0, 4)
        return lbl
    end
    self.nameLabel = makeLabel("name")
    self.nameEntry = self:makeTextEntry("name")
    self.nameEntry:SetTall(32)
    self.descLabel = makeLabel("desc")
    self.descEntry = self:makeTextEntry("desc")
    self.descEntry:SetTall(32)
    makeLabel("model")
    local faction = lia.faction.indices[self:getContext("faction")]
    if not faction then return end
    local function paintOver(icon, w, h)
        if self:getContext("model") == icon.index then
            local col = lia.config.get("Color", color_white)
            surface.SetDrawColor(col.r, col.g, col.b, 200)
            for i = 1, 3 do
                surface.DrawOutlinedRect(i, i, w - i * 2, h - i * 2)
            end
        end
    end
    self.models = self:Add("DIconLayout")
    self.models:Dock(TOP)
    self.models:DockMargin(0, 4, 0, 4)
    self.models:SetSpaceX(5)
    self.models:SetSpaceY(0)
    local iconW, iconH = 64, 128
    local spacing = 5
    local count = #faction.models
    self.models:SetWide(count * (iconW + spacing) - spacing)
    self.models:SetTall(iconH)
    for idx, data in SortedPairs(faction.models) do
        local icon = self.models:Add("SpawnIcon")
        icon:SetSize(iconW, iconH)
        icon:InvalidateLayout(true)
        icon.index = idx
        icon.PaintOver = paintOver
        icon.DoClick = function()
            self:setContext("model", idx)
            lia.gui.character:clickSound()
            self:updateModelPanel()
        end
        if isstring(data) then
            icon:SetModel(data)
            icon.model, icon.skin, icon.bodyGroups = data, 0, ""
        else
            local m, skin, bg = data[1], data[2] or 0, data[3] or {}
            local groups = {}
            for i = 0, 8 do
                groups[i + 1] = tostring(bg[i] or 0)
            end
            icon:SetModel(m, skin, table.concat(groups))
            icon.model, icon.skin, icon.bodyGroups = m, skin, table.concat(groups)
        end
        if self:getContext("model") == idx then icon:DoClick() end
    end
end
function PANEL:makeTextEntry(key)
    local entry = self:Add("DTextEntry")
    entry:Dock(TOP)
    entry:SetFont("liaMediumFont")
    entry:SetTall(32)
    entry:DockMargin(0, 4, 0, 8)
    entry:SetUpdateOnType(true)
    entry.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
        entry:DrawTextEntryText(color_white, HIGHLIGHT, HIGHLIGHT)
    end
    entry.OnValueChange = function(_, val) self:setContext(key, string.Trim(val)) end
    local saved = self:getContext(key)
    if saved then entry:SetValue(saved) end
    return entry
end
function PANEL:shouldSkip()
    local faction = lia.faction.indices[self:getContext("faction")]
    return faction and #faction.models == 1 or false
end
function PANEL:onSkip()
    self:setContext("model", 1)
end
function PANEL:validate()
    for _, info in ipairs({{self.nameEntry, "name"}, {self.descEntry, "desc"}}) do
        local val = string.Trim(info[1]:GetValue() or "")
        if val == "" then return false, L("requiredFieldError", info[2]) end
    end
    return true
end
function PANEL:onDisplay()
    local n, d, m = self.nameEntry:GetValue(), self.descEntry:GetValue(), self:getContext("model")
    self:Clear()
    self:Init()
    self.nameEntry:SetValue(n)
    self.descEntry:SetValue(d)
    self:setContext("model", m)
    local children = self.models:GetChildren()
    if children[m] then children[m].DoClick(children[m]) end
end
vgui.Register("liaCharacterBiography", PANEL, "liaCharacterCreateStep")