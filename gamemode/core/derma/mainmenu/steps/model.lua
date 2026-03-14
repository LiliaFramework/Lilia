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
    self.rotation = self:Add("DNumSlider")
    self.rotation:Dock(TOP)
    self.rotation:DockMargin(0, 4, 0, 4)
    self.rotation:SetText("Rotation")
    self.rotation:SetMin(-180)
    self.rotation:SetMax(180)
    self.rotation:SetDecimals(0)
    self.rotation:SetValue(0)
    self.rotation:SetTall(44)
    local oldRotationPerformLayout = self.rotation.PerformLayout
    self.rotation.PerformLayout = function(slider, w, h)
        if oldRotationPerformLayout then oldRotationPerformLayout(slider, w, h) end
        if not IsValid(slider.Label) then return end
        local leftPad = 12
        local labelW = math.floor((w or slider:GetWide()) * 0.22)
        slider.Label:SetPos(leftPad, 0)
        slider.Label:SetWide(math.max(labelW - leftPad, 0))
        slider.Label:SetContentAlignment(5)
    end

    self.rotation.Paint = function(slider, w, h)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        if slider.Hovered or slider:IsEditing() then
            lia.derma.rect(0, 0, w, h):Rad(8):Color(accentColor):Outline(1):Draw()
        else
            lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(255, 255, 255, 30)):Outline(1):Draw()
        end
    end

    self.rotation.OnValueChanged = function(slider, value)
        self:setContext("previewYaw", tonumber(value) or 0)
        self:updateModelPanel()
    end

    self.models = self:Add("DIconLayout")
    self.models:Dock(FILL)
    self.models:DockMargin(0, 4, 0, 24)
    self.models:SetSpaceX(8)
    self.models:SetSpaceY(8)
    self.models:SetPaintBackground(false)
    local oldModelsPerformLayout = self.models.PerformLayout
    self.models.PerformLayout = function(layout, w, h)
        if oldModelsPerformLayout then oldModelsPerformLayout(layout, w, h) end
        local offsetX = layout._centerOffsetX or 0
        local prevOffsetX = layout._appliedCenterOffsetX or 0
        local delta = offsetX - prevOffsetX
        if delta == 0 then return end
        for _, child in ipairs(layout:GetChildren()) do
            if IsValid(child) then
                local x, y = child:GetPos()
                child:SetPos(x + delta, y)
            end
        end

        layout._appliedCenterOffsetX = offsetX
    end

    self.models.OnSizeChanged = function() if IsValid(self) then self:RequestIconResize() end end
    self._iconColumns = 5
    self._iconSpace = 8
end

function PANEL:RequestIconResize()
    if not IsValid(self.models) then return false end
    local w = self.models:GetWide() or 0
    if w <= 0 then return false end
    self._needsIconResize = true
    self:InvalidateLayout(true)
    return true
end

function PANEL:PerformLayout(w, h)
    if self.BaseClass and self.BaseClass.PerformLayout then self.BaseClass.PerformLayout(self, w, h) end
    if not IsValid(self.models) then return end
    if not self._needsIconResize then return end
    local columns = self._iconColumns or 5
    local space = self._iconSpace or 8
    self.models:SetSpaceX(space)
    self.models:SetSpaceY(space)
    local layoutW = self.models:GetWide() or 0
    if layoutW <= 0 then return end
    local iconW = math.floor((layoutW - (columns - 1) * space) / columns)
    if iconW < 64 then iconW = 64 end
    if iconW > 80 then iconW = 80 end
    local rowW = columns * iconW + (columns - 1) * space
    local leftPad = math.floor((layoutW - rowW) * 0.5)
    if leftPad < 0 then leftPad = 0 end
    self.models._centerOffsetX = leftPad
    local iconH = math.floor(iconW * 2)
    for _, child in ipairs(self.models:GetChildren()) do
        if IsValid(child) and child.SetSize then child:SetSize(iconW, iconH) end
    end

    self.models:InvalidateLayout(true)
    self._needsIconResize = nil
end

function PANEL:addLabel(text)
    local header = self:Add("liaHeaderPanel")
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 4)
    header:SetTall(32)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    header:SetLineColor(accentColor)
    header:SetLineWidth(2)
    local lbl = header:Add("DLabel")
    lbl:SetFont("LiliaFont.18")
    lbl:SetText(L(text):upper())
    lbl:SizeToContents()
    lbl:Dock(FILL)
    lbl:DockMargin(8, 0, 8, 0)
    local textColor = lia.color.theme.text or Color(220, 220, 220)
    lbl:SetTextColor(textColor)
    lbl:SetContentAlignment(5)
    header.label = lbl
    return header
end

function PANEL:onDisplay()
    self.models:Clear()
    local factionIndex = self:getContext("faction")
    if not factionIndex then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    if IsValid(self.rotation) then self.rotation:SetValue(tonumber(self:getContext("previewYaw")) or 0) end
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
    if IsValid(self.rotation) then self.rotation:SetVisible(not shouldCenter) end
    local modelPanel = self:getModelPanel()
    if IsValid(modelPanel) and not (IsValid(lia.gui.character) and lia.gui.character.inWorldPreview) then
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
        local columns = self._iconColumns or 5
        local space = self._iconSpace or 8
        local layoutW = IsValid(self.models) and self.models:GetWide() or 0
        if layoutW <= 0 then layoutW = ScrW() * 0.5 - 64 end
        local iconW = math.floor((layoutW - (columns - 1) * space) / columns)
        if iconW < 64 then iconW = 64 end
        if iconW > 80 then iconW = 80 end
        local iconH = math.floor(iconW * 2)
        for idx, data in SortedPairs(modelsToDisplay) do
            local icon = self.models:Add("SpawnIcon")
            icon:SetSize(iconW, iconH)
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
            hook.Run("OnCharacterCreationModelIconSet", icon, model, skin, bodyGroups)
            if self:getContext("model") == idx then self:onModelSelected(icon, true) end
        end
    end

    self.models:InvalidateLayout(true)
    self:RequestIconResize()
    timer.Simple(0, function()
        if not IsValid(self) then return end
        if not self:RequestIconResize() then
            timer.Simple(0.05, function()
                if not IsValid(self) then return end
                if not self:RequestIconResize() then timer.Simple(0.15, function() if IsValid(self) then self:RequestIconResize() end end) end
            end)
        end
    end)
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
    if IsValid(modelPanel) and not (IsValid(lia.gui.character) and lia.gui.character.inWorldPreview) then
        modelPanel:Dock(LEFT)
        modelPanel:SetWide(ScrW() * 0.25)
    end

    if IsValid(self.title) then self.title:SetVisible(true) end
    if IsValid(self.models) then self.models:SetVisible(true) end
end

vgui.Register("liaCharacterModel", PANEL, "liaCharacterCreateStep")
