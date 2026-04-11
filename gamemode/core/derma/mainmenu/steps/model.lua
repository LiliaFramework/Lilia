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
    local baseCanvas = self.GetCanvas and self:GetCanvas() or self
    self.content = baseCanvas:Add("DPanel")
    self.content:Dock(TOP)
    self.content:SetTall(0)
    self.content:SetPaintBackground(false)
    self.title = self:addLabel(L("selectModel"), self.content)
    self.customPanel = self.content:Add("DPanel")
    self.customPanel:Dock(NODOCK)
    self.customPanel:SetVisible(false)
    self.customPanel:SetTall(0)
    self.customPanel:DockMargin(0, 0, 0, 0)
    self.customPanel:SetPaintBackground(false)
    self.customPanelDefaultTall = 220
    self.customPanelDefaultMargin = {0, 16, 0, 16}
    self.customPanel.Paint = nil
    self.controls = self.customPanel:Add("liaScrollPanel")
    self.controls:Dock(FILL)
    self.controls:DockMargin(0, 0, 0, 0)
    if self.controls.SetPaintBackground then self.controls:SetPaintBackground(false) end
    self.controls.Paint = nil
    self.controlsCanvas = self.controls.GetCanvas and self.controls:GetCanvas() or nil
    if IsValid(self.controlsCanvas) then
        self.controlsCanvas:DockPadding(8, 8, 8, 8)
        if self.controlsCanvas.SetPaintBackground then self.controlsCanvas:SetPaintBackground(false) end
        self.controlsCanvas.Paint = nil
    end

    self.modelsScroll = self.content:Add("liaScrollPanel")
    self.modelsScroll:Dock(FILL)
    self.modelsScroll:DockMargin(0, 0, 0, 0)
    local modelsParent = self.modelsScroll.GetCanvas and self.modelsScroll:GetCanvas() or self.modelsScroll
    self.models = IsValid(modelsParent) and modelsParent:Add("DIconLayout") or self.content:Add("DIconLayout")
    self.models:Dock(LEFT)
    self.models:DockMargin(0, 0, 0, 24)
    self.modelsDefaultMargin = {0, 0, 0, 24}
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
    if IsValid(self.content) then
        self.content:SetWide(w)
        self.content:SetTall(h)
    end

    if not IsValid(self.models) then return end
    if not self._needsIconResize then return end
    local columns = self._iconColumns or 5
    local space = self._iconSpace or 8
    self.models:SetSpaceX(space)
    self.models:SetSpaceY(space)
    local layoutW = self.models:GetWide() or 0
    if IsValid(self.modelsScroll) then
        layoutW = self.modelsScroll:GetWide() or layoutW
        if layoutW > 0 then self.models:SetWide(layoutW) end
    end

    if layoutW <= 0 then return end
    local iconW = math.floor((layoutW - (columns - 1) * space) / columns)
    if iconW < 64 then iconW = 64 end
    if iconW > 80 then iconW = 80 end
    local iconH = math.floor(iconW * 2)
    for _, child in ipairs(self.models:GetChildren()) do
        if IsValid(child) and child.SetSize then child:SetSize(iconW, iconH) end
    end

    self.models:SizeToChildren(false, true)
    self.models:InvalidateLayout(true)
    self._needsIconResize = nil
end

function PANEL:addLabel(text, parent)
    local container = IsValid(parent) and parent or self
    local header = container:Add("liaHeaderPanel")
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 16)
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

function PANEL:addEntryHeader(text, parent)
    local container = IsValid(parent) and parent or (IsValid(self.controlsCanvas) and self.controlsCanvas or self.controls)
    local header = container:Add("liaHeaderPanel")
    header:Dock(TOP)
    header:DockMargin(0, 12, 0, 12)
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

function PANEL:addCustomizationSectionPanel()
    local parent = IsValid(self.controlsCanvas) and self.controlsCanvas or self.controls
    local section = parent:Add("DPanel")
    section:Dock(TOP)
    section:DockMargin(0, 0, 0, 12)
    section:DockPadding(12, 12, 12, 12)
    section:SetTall(0)
    section.Paint = function(_, w, h)
        local bgColor = Color(25, 28, 35, 220)
        lia.derma.rect(0, 0, w, h):Rad(10):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    section.PerformLayout = function(s, w, h)
        s:SizeToChildren(false, true)
        s:SetTall((s:GetTall() or 0) + 24)
    end
    return section
end

function PANEL:resetCustomizationControls()
    if IsValid(self.controlsCanvas) then
        self.controlsCanvas:Clear()
    elseif IsValid(self.controls) then
        self.controls:Clear()
    end
end

function PANEL:refreshCustomizationControlsTall()
    if not IsValid(self.customPanel) or not IsValid(self.controls) then return end
    if not self.customPanel:IsVisible() then return end
    local maxTall = self.customPanelDefaultTall or 220
    local canvas = self.controls.GetCanvas and self.controls:GetCanvas() or nil
    if IsValid(canvas) then
        canvas:InvalidateLayout(true)
        canvas:SizeToChildren(false, true)
        local desiredTall = (canvas:GetTall() or 0) + 8
        if desiredTall < 0 then desiredTall = 0 end
        if desiredTall > maxTall then desiredTall = maxTall end
        self.customPanel:SetTall(desiredTall)
        self.customPanel:InvalidateLayout(true)
    else
        self.customPanel:SetTall(maxTall)
    end
end

function PANEL:addSkinControl(entity, defaultSkin)
    local section = self:addCustomizationSectionPanel()
    self:addEntryHeader("skin", section)
    local slider = section:Add("liaSlider")
    slider:Dock(TOP)
    slider:DockMargin(0, 0, 0, 12)
    slider:SetText("")
    slider:SetRange(0, math.max(0, entity:SkinCount() - 1), 0)
    slider:SetValue(self:getContext("skin", defaultSkin) or defaultSkin)
    slider.OnValueChanged = function(_, value)
        value = math.Round(value)
        self:setContext("skin", value)
        self:updateModelPanel()
    end

    if IsValid(section) then section:InvalidateLayout(true) end
end

function PANEL:addBodygroupControls(entity, defaultGroups)
    local section = self:addCustomizationSectionPanel()
    self:addEntryHeader("bodygroups", section)
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) <= 1 then continue end
        local bodygroupLabel = section:Add("DLabel")
        bodygroupLabel:Dock(TOP)
        bodygroupLabel:DockMargin(0, 0, 0, 6)
        bodygroupLabel:SetText(entity:GetBodygroupName(i))
        bodygroupLabel:SetFont("LiliaFont.16")
        bodygroupLabel:SetTextColor(lia.color.theme.text or color_white)
        bodygroupLabel:SetContentAlignment(5)
        bodygroupLabel:SetTall(20)
        local slider = section:Add("liaSlider")
        slider:Dock(TOP)
        slider:DockMargin(0, 0, 0, 12)
        slider:SetText("")
        slider:SetRange(0, entity:GetBodygroupCount(i) - 1, 0)
        local ctxGroups = self:getContext("bodygroups")
        if not istable(ctxGroups) then ctxGroups = self:getContext("groups") end
        local startVal = istable(ctxGroups) and (ctxGroups[i] or ctxGroups[tostring(i)]) or nil
        if startVal == nil and istable(defaultGroups) then startVal = defaultGroups[i] or defaultGroups[tostring(i)] end
        slider:SetValue(tonumber(startVal) or entity:GetBodygroup(i) or 0)
        slider.OnValueChanged = function(_, val)
            val = math.Round(val)
            local groups = self:getContext("bodygroups")
            if not istable(groups) then groups = {} end
            groups[i] = val
            self:setContext("bodygroups", groups)
            self:setContext("groups", groups)
            self:updateModelPanel()
        end
    end

    if IsValid(section) then section:InvalidateLayout(true) end
end

function PANEL:updateCustomizationControls()
    self:resetCustomizationControls()
    if not IsValid(self.customPanel) or not IsValid(self.controls) then return end
    local context = self:getContext()
    local factionIndex = context.faction
    if not factionIndex then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    local info = faction.models[context.model or 1]
    local mdl, defaultSkin, defaultGroups = info, 0, {}
    if istable(info) then mdl, defaultSkin, defaultGroups = info[1], info[2] or 0, info[3] or {} end
    local entity
    if IsValid(lia.gui.charCreate) and IsValid(lia.gui.charCreate.model) then entity = lia.gui.charCreate.model:GetEntity() end
    local tempEntity
    if (not IsValid(entity)) or (entity:GetModel() ~= mdl) then
        tempEntity = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
        if not IsValid(tempEntity) then return end
        entity = tempEntity
    end

    local skinAllowed, bodygroupsAllowed = lia.faction.getModelCustomizationAllowed(LocalPlayer(), faction, context)
    local modelSupportsSkins = skinAllowed and entity:SkinCount() > 1
    local modelSupportsBodygroups = false
    if bodygroupsAllowed then
        for i = 0, entity:GetNumBodyGroups() - 1 do
            if entity:GetBodygroupCount(i) > 1 then
                modelSupportsBodygroups = true
                break
            end
        end
    end

    if modelSupportsBodygroups then self:addBodygroupControls(entity, defaultGroups) end
    if modelSupportsSkins then self:addSkinControl(entity, defaultSkin) end
    local shouldShow = modelSupportsSkins or modelSupportsBodygroups
    self.customPanel:SetVisible(shouldShow)
    if shouldShow then
        self.customPanel:Dock(BOTTOM)
        local m = self.customPanelDefaultMargin or {0, 8, 0, 8}
        self.customPanel:DockMargin(m[1] or 0, m[2] or 0, m[3] or 0, m[4] or 0)
        self:refreshCustomizationControlsTall()
        timer.Simple(0, function() if IsValid(self) then self:refreshCustomizationControlsTall() end end)
        if IsValid(self.models) then
            local mm = self.modelsDefaultMargin or {0, 0, 0, 24}
            self.models:DockMargin(mm[1] or 0, mm[2] or 0, mm[3] or 0, 8)
        end
    else
        self.customPanel:Dock(NODOCK)
        self.customPanel:SetTall(0)
        self.customPanel:DockMargin(0, 0, 0, 0)
        if IsValid(self.models) then
            local mm = self.modelsDefaultMargin or {0, 0, 0, 24}
            self.models:DockMargin(mm[1] or 0, mm[2] or 0, mm[3] or 0, mm[4] or 0)
        end
    end

    if IsValid(tempEntity) then tempEntity:Remove() end
    self:InvalidateLayout(true)
end

function PANEL:updateModelPanel()
    lia.gui.charCreate:updateModel()
end

function PANEL:onDisplay()
    self.models:Clear()
    local factionIndex = self:getContext("faction")
    if not factionIndex then return end
    local faction = lia.faction.indices[factionIndex]
    if not faction then return end
    if IsValid(self.customPanel) then
        self.customPanel:SetVisible(false)
        self.customPanel:Dock(NODOCK)
        self.customPanel:SetTall(0)
        self.customPanel:DockMargin(0, 0, 0, 0)
    end

    if IsValid(self.models) then
        local mm = self.modelsDefaultMargin or {0, 0, 0, 24}
        self.models:DockMargin(mm[1] or 0, 0, mm[3] or 0, mm[4] or 0)
    end

    local modelsToDisplay = self:filterCharacterModels(faction)
    local modelCount = 0
    local firstIdx
    for idx, _ in pairs(modelsToDisplay) do
        modelCount = modelCount + 1
        if not firstIdx then firstIdx = idx end
    end

    local shouldCenter = modelCount <= 1
    if IsValid(self.title) then self.title:SetVisible(not shouldCenter) end
    if IsValid(self.models) then self.models:SetVisible(true) end
    local modelPanel = self:getModelPanel()
    if IsValid(modelPanel) and not (IsValid(lia.gui.character) and lia.gui.character.inWorldPreview) then
        if shouldCenter then
            modelPanel:Dock(FILL)
            modelPanel:MoveToFront()
            if modelCount == 1 and self:getContext("model") == nil then self:setContext("model", firstIdx or 1) end
            self:updateModelPanel()
            self:updateCustomizationControls()
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
        if layoutW <= 0 then layoutW = ScrW() * 0.5 end
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
                local resolvedGroups = data[3] or {}
                if istable(data[3]) and data[1] then
                    local previewEntity = ClientsideModel(data[1], RENDERGROUP_OTHER)
                    if IsValid(previewEntity) then
                        resolvedGroups = lia.util.resolveBodygroups(previewEntity, data[3])
                        previewEntity:Remove()
                    end
                end

                for i = 0, 8 do
                    bodyGroups = bodyGroups .. tostring(resolvedGroups[i] or 0)
                end

                model = data[1]
            end

            icon:SetModel(model, skin, bodyGroups)
            icon.model, icon.skin, icon.bodyGroups = model, skin, bodyGroups
            hook.Run("OnCharacterCreationModelIconSet", icon, model, skin, bodyGroups)
            if self:getContext("model") == idx then self:onModelSelected(icon, true) end
        end
    end

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
    self:setContext("skin", nil)
    self:setContext("bodygroups", nil)
    self:setContext("groups", nil)
    if not noSound then lia.gui.character:clickSound() end
    self:updateModelPanel()
    self:updateCustomizationControls()
end

function PANEL:shouldSkip()
    return false
end

function PANEL:onSkip()
    self:setContext("model", 1)
end

function PANEL:onHide()
    local modelPanel = self:getModelPanel()
    if IsValid(modelPanel) and (not IsValid(lia.gui.character) or not lia.gui.character.inWorldPreview) then
        modelPanel:Dock(LEFT)
        modelPanel:SetWide(ScrW() * 0.25)
    end

    if IsValid(self.title) then self.title:SetVisible(true) end
    if IsValid(self.models) then self.models:SetVisible(true) end
    if IsValid(self.controls) then self.controls:SetVisible(true) end
end

vgui.Register("liaCharacterModel", PANEL, "liaCharacterCreateStep")
