local PANEL = {}
local leftBinding = input.LookupBinding("+moveleft") or "A"
local rightBinding = input.LookupBinding("+moveright") or "D"
local leftKey = input.GetKeyCode(leftBinding)
local rightKey = input.GetKeyCode(rightBinding)
if not leftKey or leftKey <= 0 then leftKey = KEY_A end
if not rightKey or rightKey <= 0 then rightKey = KEY_D end

function PANEL:GetPreviewEntity()
    return lia.view.getEntity(self)
end

function PANEL:GetCurrentBodygroups()
    local model = self:GetPreviewEntity()
    if not IsValid(model) then return {} end
    local bodygroups = {}
    for i = 0, model:GetNumBodyGroups() - 1 do
        bodygroups[i] = model:GetBodygroup(i)
    end
    return bodygroups
end

function PANEL:BuildBodygroupExport()
    local lines = {"{"}
    local bodygroups = self:GetCurrentBodygroups()
    local ids = {}
    for id in pairs(bodygroups) do
        ids[#ids + 1] = id
    end

    table.sort(ids, function(a, b) return tonumber(a) < tonumber(b) end)
    for _, id in ipairs(ids) do
        lines[#lines + 1] = "    [" .. tostring(id) .. "] = " .. tostring(bodygroups[id]) .. ","
    end

    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

function PANEL:Init()
    self.models = {}
    self.allowModelChange = false
    self:SetSize(math.min(560, ScrW() * 0.36), math.min(820, ScrH() * 0.86))
    self:SetPos(ScrW() - self:GetWide() - 48, math.max(48, (ScrH() - self:GetTall()) * 0.5))
    self:SetTitle("Appearance Wardrobe")
    self:SetBackgroundBlur(false)
    self:MakePopup()
    self:DockPadding(10, 34, 10, 10)

    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:DockMargin(0, 0, 0, 8)
    self.header:SetTall(52)
    self.header.Paint = function(_, w)
        lia.util.drawText("Appearance Editor", w / 2, 16, color_white, 1, 1, "LiliaFont.18")
        lia.util.drawText(string.format("Use %s and %s to rotate the model.", leftBinding:upper(), rightBinding:upper()), w / 2, 36, Color(220, 220, 220), 1, 1, "LiliaFont.16")
    end

    self.modelSection = self:Add("DPanel")
    self.modelSection:Dock(TOP)
    self.modelSection:DockMargin(0, 0, 0, 8)
    self.modelSection:SetTall(250)
    self.modelSection:SetVisible(false)

    self.modelLabel = self.modelSection:Add("DLabel")
    self.modelLabel:Dock(TOP)
    self.modelLabel:DockMargin(4, 0, 4, 6)
    self.modelLabel:SetTall(24)
    self.modelLabel:SetFont("LiliaFont.18")
    self.modelLabel:SetText("Model")
    self.modelLabel:SetTextColor(color_white)

    self.modelScroll = self.modelSection:Add("liaScrollPanel")
    self.modelScroll:Dock(FILL)
    local canvas = self.modelScroll.GetCanvas and self.modelScroll:GetCanvas() or self.modelScroll
    self.modelLayout = canvas:Add("DIconLayout")
    self.modelLayout:Dock(TOP)
    self.modelLayout:SetSpaceX(8)
    self.modelLayout:SetSpaceY(8)
    self.modelLayout:SetPaintBackground(false)

    self.skinSelector = self:Add("liaSlideBox")
    self.skinSelector:Dock(TOP)
    self.skinSelector:DockMargin(0, 0, 0, 6)
    self.skinSelector:SetText("Skin")
    self.skinSelector:SetRange(0, 0, 0)
    self.skinSelector:SetVisible(false)
    self.skinSelector.OnValueChanged = function(_, value)
        local model = self:GetPreviewEntity()
        if IsValid(model) then model:SetSkin(math.Round(value)) end
    end

    self.bodygroupLabel = self:Add("DLabel")
    self.bodygroupLabel:Dock(TOP)
    self.bodygroupLabel:DockMargin(4, 2, 4, 4)
    self.bodygroupLabel:SetTall(24)
    self.bodygroupLabel:SetFont("LiliaFont.18")
    self.bodygroupLabel:SetText("Bodygroups")
    self.bodygroupLabel:SetTextColor(color_white)

    self.bodygroupScroll = self:Add("liaScrollPanel")
    self.bodygroupScroll:Dock(FILL)
    self.bodygroupScroll:SetZPos(100)

    self.actions = self:Add("DPanel")
    self.actions:Dock(BOTTOM)
    self.actions:SetZPos(90)
    self.actions:DockMargin(0, 8, 0, 0)
    self.actions:SetTall(34)

    self.copyBodygroups = self.actions:Add("liaButton")
    self.copyBodygroups:Dock(LEFT)
    self.copyBodygroups:SetWide(165)
    self.copyBodygroups:SetText("Copy Bodygroups")
    self.copyBodygroups.DoClick = function()
        local export = self:BuildBodygroupExport()
        SetClipboardText(export)
        MsgC(Color(0, 255, 0), "[Lilia] ", color_white, export .. "\n")
        LocalPlayer():notifySuccess("Copied to clipboard.")
    end

    self.submit = self.actions:Add("liaButton")
    self.submit:Dock(FILL)
    self.submit:DockMargin(6, 0, 0, 0)
    self.submit:SetText("Save Appearance")
    self.submit.DoClick = function()
        local target = self.target
        local preview = self:GetPreviewEntity()
        if not IsValid(target) or not IsValid(preview) then return end
        local selectedModel = self.selectedModel or target:GetModel()
        local modelChanged = self.allowModelChange and string.lower(selectedModel or "") ~= string.lower(target:GetModel() or "")
        net.Start("AppearanceMenuSubmit")
        net.WriteEntity(target)
        net.WriteBool(modelChanged)
        net.WriteString(selectedModel or "")
        net.WriteUInt(math.max(0, preview:GetSkin()), 10)
        net.WriteTable(self:GetCurrentBodygroups())
        net.SendToServer()
    end
end

function PANEL:BuildModelIcons()
    if not IsValid(self.modelLayout) then return end
    self.modelLayout:Clear()
    local iconSize = 78
    for _, modelPath in ipairs(self.models) do
        local currentModel = modelPath
        local icon = self.modelLayout:Add("SpawnIcon")
        icon:SetSize(iconSize, iconSize * 2)
        icon:SetModel(currentModel)
        icon.modelPath = currentModel
        icon.DoClick = function()
            local useTargetAppearance = IsValid(self.target) and string.lower(currentModel) == string.lower(self.target:GetModel() or "")
            self:SelectModel(currentModel, useTargetAppearance)
        end
        icon.PaintOver = function(panel, w, h)
            if string.lower(panel.modelPath or "") ~= string.lower(self.selectedModel or "") then return end
            local color = lia.config.get("Color", color_white)
            surface.SetDrawColor(color.r, color.g, color.b, 220)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
        end
    end
    self.modelLayout:SizeToChildren(false, true)
end

function PANEL:PopulateBodygroups()
    if not IsValid(self.bodygroupScroll) then return end
    self.bodygroupScroll:Clear()
    local model = self:GetPreviewEntity()
    if not IsValid(model) then return end

    local skinCount = model:SkinCount() or 0
    if skinCount > 1 then
        self.skinSelector:SetRange(0, skinCount - 1, 0)
        self.skinSelector:SetValue(model:GetSkin())
        self.skinSelector:SetVisible(true)
    else
        self.skinSelector:SetVisible(false)
    end

    local added = false
    for i = 0, model:GetNumBodyGroups() - 1 do
        local index = i
        local count = model:GetBodygroupCount(index)
        if count > 1 then
            added = true
            local slider = self.bodygroupScroll:Add("liaSlideBox")
            slider:Dock(TOP)
            slider:DockMargin(0, 0, 0, 5)
            local name = model:GetBodygroupName(index) or tostring(index)
            slider:SetText(name:sub(1, 1):upper() .. name:sub(2))
            slider:SetRange(0, count - 1, 0)
            slider:SetValue(model:GetBodygroup(index))
            slider.OnValueChanged = function(_, value)
                local preview = self:GetPreviewEntity()
                if IsValid(preview) then preview:SetBodygroup(index, math.Round(value)) end
            end
        end
    end

    if not added and not self.skinSelector:IsVisible() then
        local info = self.bodygroupScroll:Add("DLabel")
        info:Dock(TOP)
        info:DockMargin(0, 10, 0, 0)
        info:SetText("No bodygroups or skins are available for this model.")
        info:SetFont("liaMediumFont")
        info:SetTextColor(color_white)
        info:SetContentAlignment(5)
        info:SetWrap(true)
        info:SetAutoStretchVertical(true)
        info:SetTall(40)
    end
end

function PANEL:SelectModel(modelPath, useTargetAppearance)
    if not isstring(modelPath) or modelPath == "" then return end
    self.selectedModel = modelPath
    lia.view.setModel(self, modelPath, {
        context = self.target
    })

    local preview = self:GetPreviewEntity()
    if IsValid(preview) then
        if useTargetAppearance and IsValid(self.target) then
            preview:SetSkin(self.target:GetSkin())
            for i = 0, math.min(preview:GetNumBodyGroups(), self.target:GetNumBodyGroups()) - 1 do
                local value = self.target:GetBodygroup(i)
                if value >= 0 and value < preview:GetBodygroupCount(i) then preview:SetBodygroup(i, value) end
            end
        else
            preview:SetSkin(0)
            for i = 0, preview:GetNumBodyGroups() - 1 do
                preview:SetBodygroup(i, 0)
            end
        end
    end

    self:PopulateBodygroups()
end

function PANEL:SetData(target, models, allowModelChange)
    if not IsValid(target) then return end
    self.target = target
    self.models = istable(models) and models or {}
    self.allowModelChange = allowModelChange == true
    self.modelSection:SetVisible(self.allowModelChange and #self.models > 0)
    lia.view.begin(self, {
        context = target,
        hideEntities = {target, LocalPlayer()}
    })
    self:SelectModel(target:GetModel(), true)
    self:BuildModelIcons()
    self:InvalidateLayout(true)
end

function PANEL:SetTarget(target)
    self:SetData(target, {}, false)
end

function PANEL:Think()
    if input.IsKeyDown(leftKey) then
        lia.view.rotate(self, FrameTime() * 180)
    elseif input.IsKeyDown(rightKey) then
        lia.view.rotate(self, FrameTime() * -180)
    end
end

function PANEL:OnRemove()
    lia.view.close(self)
    if lia.gui.appearanceMenu == self then lia.gui.appearanceMenu = nil end
    if self.suppressCloseSignal then return end
    net.Start("AppearanceMenuClosed")
    net.SendToServer()
end

vgui.Register("AppearanceMenu", PANEL, "liaFrame")
