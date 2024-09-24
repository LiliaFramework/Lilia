local PANEL = {}
local MODULE = MODULE
MODULE.CharacterInformations = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    local panelWidth = ScrW() * 0.35
    local panelHeight = ScrH() * 0.8
    self:SetSize(panelWidth, panelHeight)
    self:SetPos(50, 90)
    self.Paint = function() end
    self.info = vgui.Create("DFrame", self)
    self.info:SetTitle("")
    self.info:SetSize(panelWidth, panelHeight)
    self.info:ShowCloseButton(false)
    self.info:SetDraggable(false)
    self.info.Paint = function() end
    self.infoBox = self.info:Add("DPanel")
    self.infoBox:Dock(FILL)
    self.infoBox.Paint = function() end
    hook.Run("LoadCharInformation")
    self:GenerateSections()
end

function PANEL:GenerateSections()
    local orderedSections = {}
    for sectionName, data in pairs(MODULE.CharacterInformations) do
        table.insert(orderedSections, {
            name = sectionName,
            color = data.color,
            fields = data.fields,
            priority = data.priority
        })
    end

    table.sort(orderedSections, function(a, b) return a.priority < b.priority end)
    for _, section in ipairs(orderedSections) do
        self:CreateSection(section.name, section.color)
        local fields = isfunction(section.fields) and section.fields() or section.fields
        for _, field in ipairs(fields) do
            if field.type == "text" then
                self:CreateTextEntryWithBackgroundAndLabel(field.name, field.label, 5, field.value)
            elseif field.type == "bar" then
                self:CreateFillableBarWithBackgroundAndLabel(field.name, field.label, field.min, field.max, 5, field.value)
            end

            self:AddSpacer(5)
        end
    end
end

function PANEL:CreateTextEntryWithBackgroundAndLabel(name, labelText, dockMarginBot, valueFunc)
    local textFont = "liaSmallFont"
    local textFontSize = 20
    local textColor = color_white
    local shadowColor = Color(30, 30, 30, 150)
    local entryContainer = self.infoBox:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(textFontSize + 5)
    entryContainer:DockMargin(8, 0, 8, dockMarginBot)
    entryContainer.Paint = function(_, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = entryContainer:Add("DLabel")
    label:SetFont(textFont)
    label:SetWide(85)
    label:SetTall(25)
    label:SetTextColor(textColor)
    label:SetText(labelText)
    label:Dock(LEFT)
    label:DockMargin(0, 0, 15, 0)
    label:SetContentAlignment(6)
    self[name] = entryContainer:Add("DTextEntry")
    self[name]:SetFont(textFont)
    self[name]:SetTall(textFontSize)
    self[name]:Dock(FILL)
    self[name]:SetTextColor(textColor)
    self[name]:SetEditable(true)
    if valueFunc then self[name]:SetText(valueFunc()) end
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(name, labelText, minFunc, maxFunc, dockMarginTop, valueFunc)
    local textFont = "liaSmallFont"
    local textColor = color_white
    local shadowColor = Color(30, 30, 30, 150)
    local entryContainer = self.infoBox:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(30)
    entryContainer:DockMargin(8, dockMarginTop, 8, 1)
    entryContainer.Paint = function(_, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = entryContainer:Add("DLabel")
    label:SetFont(textFont)
    label:SetWide(100)
    label:SetTall(10)
    label:Dock(LEFT)
    label:SetTextColor(textColor)
    label:SetText(labelText)
    label:SetContentAlignment(5)
    local bar = entryContainer:Add("DPanel")
    bar:Dock(FILL)
    bar.Paint = function(_, w, h)
        local currentMin = isfunction(minFunc) and minFunc() or minFunc
        local currentMax = isfunction(maxFunc) and maxFunc() or maxFunc
        local currentValue = isfunction(valueFunc) and valueFunc() or valueFunc
        local percentage = math.Clamp((tonumber(currentValue) - tonumber(currentMin)) / (tonumber(currentMax) - tonumber(currentMin)), 0, 1)
        local filledWidth = percentage * w
        local filledColor = Color(45, 45, 45, 255)
        surface.SetDrawColor(filledColor)
        surface.DrawRect(0, 0, filledWidth, h)
        draw.SimpleText(currentValue .. "/" .. currentMax, textFont, w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self[name] = bar
end

function PANEL:AddSpacer(height)
    local spacer = self.infoBox:Add("DPanel")
    spacer:Dock(TOP)
    spacer:SetTall(height)
    spacer:DockMargin(8, 0, 8, 0)
    spacer.Paint = function() end
end

function PANEL:CreateSection(title, color)
    local textFont = "liaSmallFont"
    local textFontSize = 20
    local textColor = color_white
    local sectionPanel = self.infoBox:Add("DPanel")
    sectionPanel:Dock(TOP)
    sectionPanel:SetTall(textFontSize + 10)
    sectionPanel:DockMargin(8, 10, 8, 10)
    sectionPanel.Paint = function(_, w, h)
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(title, textFont, w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Refresh()
    self.infoBox:Clear()
    self:GenerateSections()
end

function PANEL:setup()
    for _, fields in pairs(MODULE.CharacterInformations) do
        if isfunction(fields.fields) then fields.fields = fields.fields() end
        for _, field in ipairs(fields.fields) do
            if field.type == "text" and self[field.name] then
                self[field.name]:SetText(field.value())
            elseif field.type == "bar" and self[field.name] then
                self[field.name]:SetText(field.value())
            end
        end
    end
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")