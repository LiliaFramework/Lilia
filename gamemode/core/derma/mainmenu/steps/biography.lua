local PANEL = {}
local HIGHLIGHT = Color(255, 255, 255, 50)
function PANEL:Init()
    self:SetSize(400, 600)
    local function makeLabel(text)
        local lbl = self:Add("DLabel")
        lbl:SetFont("liaMediumFont")
        lbl:SetText(L(text):upper())
        lbl:SizeToContents()
        lbl:Dock(TOP)
        lbl:DockMargin(0, 0, 0, 4)
        return lbl
    end

    self.nameLabel = makeLabel("Name")
    self.nameEntry = self:makeTextEntry("name")
    self.nameEntry:SetTall(32)
    self.descLabel = makeLabel("Description")
    self.descEntry = self:makeTextEntry("desc")
    self.descEntry:SetTall(32)
    makeLabel("Model")
    local faction = lia.faction.indices[self:getContext("faction")]
    if not faction then return end
    local paintOver = function(icon, w, h)
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
    local iconSizeX, iconSizeY = 64, 128
    local spacing = 5
    local count = #faction.models
    self.models:SetWide(count * (iconSizeX + spacing) - spacing)
    self.models:SetTall(iconSizeY)
    for idx, data in SortedPairs(faction.models) do
        local icon = self.models:Add("SpawnIcon")
        icon:SetSize(iconSizeX, iconSizeY)
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
            local skin = data[2] or 0
            local groups = {}
            for i = 0, 8 do
                groups[i + 1] = tostring((data[3] or {})[i] or 0)
            end

            local groupStr = table.concat(groups)
            icon:SetModel(data[1], skin, groupStr)
            icon.model, icon.skin, icon.bodyGroups = data[1], skin, groupStr
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
    for _, info in ipairs({{self.nameEntry, "Name"}, {self.descEntry, "Description"}}) do
        local val = string.Trim(info[1]:GetValue() or "")
        if val == "" then return false, ("The field '%s' is required and cannot be empty."):format(info[2]) end
    end
    return true
end

function PANEL:onDisplay()
    local nameText = self.nameEntry:GetValue()
    local descText = self.descEntry:GetValue()
    local selectedModel = self:getContext("model")
    self:Clear()
    self:Init()
    self.nameEntry:SetValue(nameText)
    self.descEntry:SetValue(descText)
    self:setContext("model", selectedModel)
    local children = self.models:GetChildren()
    if children[selectedModel] then children[selectedModel].DoClick(children[selectedModel]) end
end

vgui.Register("liaCharacterBiography", PANEL, "liaCharacterCreateStep")