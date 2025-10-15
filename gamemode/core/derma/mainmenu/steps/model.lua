local PANEL = {}
function PANEL:filterCharacterModels(faction)
    if not faction or not faction.models then return {} end
    local filteredModels = {}
    for idx, data in pairs(faction.models) do
        if isstring(idx) and istable(data) then
            filteredModels[idx] = data
        else
            local shouldInclude = hook.Run("FilterCharModels", LocalPlayer(), faction, data, idx)
            if shouldInclude ~= false then filteredModels[idx] = data end
        end
    end
    return filteredModels
end

function PANEL:Init()
    self.title = self:addLabel(L("selectModel"))
    self.models = self:Add("DIconLayout")
    self.models:Dock(FILL)
    self.models:DockMargin(0, 8, 0, 12)
    self.models:SetSpaceX(4)
    self.models:SetSpaceY(4)
    self.models:SetPaintBackground(false)
end

function PANEL:addLabel(text)
    local lbl = self:Add("DLabel")
    lbl:SetFont("liaMediumFont")
    lbl:SetText(L(text):upper())
    lbl:SizeToContents()
    lbl:Dock(TOP)
    lbl:DockMargin(0, 0, 0, 8)
    return lbl
end

function PANEL:onDisplay()
    self.models:Clear()
    local factionIndex = self:getContext("faction")
    if not factionIndex then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    local modelsToDisplay = self:filterCharacterModels(faction)
    local modelCount = 0
    local firstIdx
    for idx, _ in pairs(modelsToDisplay) do
        modelCount = modelCount + 1
        if not firstIdx then firstIdx = idx end
    end

    local shouldCenter = modelCount <= 1
    if IsValid(self.title) then self.title:SetVisible(not shouldCenter) end
    if IsValid(self.models) then self.models:SetVisible(not shouldCenter) end
    local modelPanel = self:getModelPanel()
    if IsValid(modelPanel) then
        if shouldCenter then
            modelPanel:Dock(FILL)
            modelPanel:MoveToFront()
            if modelCount == 1 and self:getContext("model") == nil then self:setContext("model", firstIdx or 1) end
            self:updateModelPanel()
        else
            modelPanel:Dock(LEFT)
            modelPanel:SetWide(ScrW() * 0.25)
        end
    end

    local paintOver = function(icon, w, h) self:paintIcon(icon, w, h) end
    if modelCount > 1 then
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

function PANEL:updateContext()
    if not self:getContext("model") then self:setContext("model", 1) end
end

function PANEL:onModelSelected(icon, noSound)
    self:setContext("model", icon.index or 1)
    if not noSound then lia.gui.character:clickSound() end
    self:updateModelPanel()
end

function PANEL:shouldSkip()
    return false
end

function PANEL:onSkip()
    self:setContext("model", 1)
end

function PANEL:onHide()
    local modelPanel = self:getModelPanel()
    if IsValid(modelPanel) then
        modelPanel:Dock(LEFT)
        modelPanel:SetWide(ScrW() * 0.25)
    end

    if IsValid(self.title) then self.title:SetVisible(true) end
    if IsValid(self.models) then self.models:SetVisible(true) end
end

vgui.Register("liaCharacterModel", PANEL, "liaCharacterCreateStep")
