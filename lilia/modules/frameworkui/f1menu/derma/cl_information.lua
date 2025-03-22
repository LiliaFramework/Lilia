local PANEL = {}
local MODULE = MODULE
MODULE.CharacterInformations = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    local panelWidth = ScrW()
    local panelHeight = ScrH() * 0.8
    self:SetSize(panelWidth, panelHeight)
    self:SetPos(50, 50)
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
    self.leftColumn = self.infoBox:Add("DPanel")
    self.leftColumn:Dock(LEFT)
    self.leftColumn:SetWide(panelWidth * 0.5)
    self.leftColumn.Paint = function() end
    local spacerColumn = self.infoBox:Add("DPanel")
    spacerColumn:Dock(LEFT)
    spacerColumn:SetWide(10)
    spacerColumn.Paint = function() end
    self.rightColumn = self.infoBox:Add("DPanel")
    self.rightColumn:Dock(LEFT)
    self.rightColumn:SetWide(panelWidth * 0.3)
    self.rightColumn:DockMargin(100, 0, 8, 0)
    self.rightColumn.Paint = function() end
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
            priority = data.priority,
            location = data.location
        })
    end

    table.sort(orderedSections, function(a, b) return a.priority < b.priority end)
    local leftCount, rightCount = 0, 0
    for _, section in ipairs(orderedSections) do
        local column
        if section.location == 1 then
            column = self.leftColumn
            leftCount = leftCount + 1
        elseif section.location == 2 then
            column = self.rightColumn
            rightCount = rightCount + 1
        else
            if leftCount <= rightCount then
                column = self.leftColumn
                leftCount = leftCount + 1
            else
                column = self.rightColumn
                rightCount = rightCount + 1
            end
        end

        self:CreateSection(column, section.name, section.color)
        local fields = isfunction(section.fields) and section.fields() or section.fields
        for _, field in ipairs(fields) do
            if field.type == "text" then
                self:CreateTextEntryWithBackgroundAndLabel(column, field.name, field.label, 5, field.value)
            elseif field.type == "bar" then
                self:CreateFillableBarWithBackgroundAndLabel(column, field.name, field.label, field.min, field.max, 5, field.value)
            end

            self:AddSpacer(column, 5)
        end
    end
end

function PANEL:CreateTextEntryWithBackgroundAndLabel(parent, name, labelText, dockMarginBot, valueFunc)
    local isDesc = string.lower(name) == "desc"
    local textFont = "liaSmallFont"
    local textFontSize = 20
    local textColor = color_white
    local shadowColor = Color(30, 30, 30, 150)
    local entryContainer = parent:Add("DPanel")
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
    self[name]:SetEditable(isDesc)
    if valueFunc then self[name]:SetText(valueFunc()) end
    self[name].OnEnter = function(entry)
        if isDesc then
            local text = entry:GetText()
            lia.command.send("chardesc", text)
        end
    end
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minFunc, maxFunc, dockMargin, valueFunc)
    local textFont = "liaSmallFont"
    local textColor = color_white
    local shadowColor = Color(30, 30, 30, 150)
    local entryContainer = parent:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(30)
    entryContainer:DockMargin(8, dockMargin, 8, dockMargin)
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
    self[name] = entryContainer:Add("DProgressBar")
    self[name]:Dock(FILL)
    self[name]:SetText("")
    self[name]:SetBarColor(Color(45, 45, 45, 255))
    local min = isfunction(minFunc) and minFunc() or minFunc
    local max = isfunction(maxFunc) and maxFunc() or maxFunc
    local current = isfunction(valueFunc) and valueFunc() or valueFunc
    local fraction = math.Clamp((current - min) / (max - min), 0, 1)
    self[name]:SetFraction(fraction)
    hook.Add("Think", self, function()
        local newCurrent = isfunction(valueFunc) and valueFunc() or valueFunc
        local newFraction = math.Clamp((newCurrent - min) / (max - min), 0, 1)
        self[name]:SetFraction(newFraction)
    end)

    local gradMat = Material("vgui/gradient-d")
    surface.SetMaterial(gradMat)
    surface.SetDrawColor(200, 200, 200, 20)
    surface.DrawTexturedRect(4, 4, self[name]:GetWide(), self[name]:GetTall())
end

function PANEL:AddSpacer(parent, height)
    local spacer = parent:Add("DPanel")
    spacer:Dock(TOP)
    spacer:SetTall(height)
    spacer:DockMargin(8, 0, 8, 0)
    spacer.Paint = function() end
end

function PANEL:CreateSection(parent, title, color)
    local textFont = "liaSmallFont"
    local textFontSize = 20
    local textColor = color_white
    local sectionPanel = parent:Add("DPanel")
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
    self.leftColumn:Clear()
    self.rightColumn:Clear()
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
