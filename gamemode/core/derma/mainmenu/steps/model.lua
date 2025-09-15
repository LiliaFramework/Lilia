local PANEL = {}
function PANEL:filterCharacterModels(faction)
    if not faction or not faction.models then return {} end
    local filteredModels = {}
    for idx, data in pairs(faction.models) do
        if isstring(idx) and istable(data) then
            filteredModels[idx] = data
        else
            local shouldInclude = hook.Run("FilterCharacterModels", LocalPlayer(), faction, data, idx)
            if shouldInclude ~= false then filteredModels[idx] = data end
        end
    end
    return filteredModels
end

function PANEL:Init()
    self.title = self:addLabel(L("selectModel"))
    self.models = self:Add("DIconLayout")
    self.models:Dock(FILL)
    self.models:SetSpaceX(4)
    self.models:SetSpaceY(4)
    self.models:SetPaintBackground(false)
end

function PANEL:onDisplay()
    self.models:Clear()
    local faction = lia.faction.indices[self:getContext("faction")]
    if not faction then return end
    local modelsToDisplay = self:filterCharacterModels(faction)
    local paintOver = function(icon, w, h) self:paintIcon(icon, w, h) end
    for idx, data in SortedPairs(modelsToDisplay) do
        local icon = self.models:Add("SpawnIcon")
        icon:SetSize(64, 128)
        icon.index = idx
        icon.PaintOver = paintOver
        icon.DoClick = function() self:onModelSelected(icon) end
        local model, skin, bodyGroups = data, 0, ""
        if istable(data) then
            skin = data[2] or 0
            for i = 0, 8 do
                bodyGroups = bodyGroups .. tostring((data[3] or {})[i] or 0)
            end

            model = data[1]
        end

        icon:SetModel(model, skin, bodyGroups)
        icon.model, icon.skin, icon.bodyGroups = model, skin, bodyGroups
        if self:getContext("model") == idx then self:onModelSelected(icon, true) end
    end

    self.models:InvalidateLayout(true)
end

function PANEL:paintIcon(icon, w, h)
    if self:getContext("model") ~= icon.index then return end
    local col = lia.config.get("Color", color_white)
    surface.SetDrawColor(col.r, col.g, col.b, 200)
    for i = 1, 3 do
        local o = i * 2
        surface.DrawOutlinedRect(i, i, w - o, h - o)
    end
end

function PANEL:onModelSelected(icon, noSound)
    self:setContext("model", icon.index or 1)
    if not noSound then lia.gui.character:clickSound() end
    self:updateModelPanel()
end

function PANEL:shouldSkip()
    local faction = lia.faction.indices[self:getContext("faction")]
    return faction and #faction.models == 1 or false
end

function PANEL:onSkip()
    self:setContext("model", 1)
end

vgui.Register("liaCharacterModel", PANEL, "liaCharacterCreateStep")
