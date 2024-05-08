local MODULE = MODULE
local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    local character = client:getChar()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    local panelWidth = ScrW() * 0.25
    local panelHeight = ScrH() * 0.8
    local textFontSize = 20
    local textFont = "liaSmallFont"
    local textColor = color_white
    local shadowColor = Color(30, 30, 30, 150)
    self:SetSize(panelWidth, panelHeight)
    if F1MenuCore.InfoMenuLocation == "TopLeft" then
        self:SetPos(10, 10)
    elseif F1MenuCore.InfoMenuLocation == "TopRight" then
        self:SetPos(ScrW() - panelWidth - 10, 10)
    elseif F1MenuCore.InfoMenuLocation == "BottomRight" then
        self:SetPos(ScrW() - panelWidth - 10, 800)
    elseif F1MenuCore.InfoMenuLocation == "BottomCenter" then
        self:SetPos((ScrW() - panelWidth) / 2, 800)
    else
        self:SetPos(ScrW() - panelWidth - 10, 10)
    end

    self.info = vgui.Create("DFrame", self)
    self.info:SetTitle("")
    self.info:SetSize(panelWidth, panelHeight)
    self.info:ShowCloseButton(false)
    self.info:SetDraggable(false)
    self.info.Paint = function() end
    self.infoBox = self.info:Add("DPanel")
    self.infoBox:Dock(FILL)
    self.infoBox.Paint = function() end
    self:CreateTextEntryWithBackgroundAndLabel("name", textFont, textFontSize, textColor, shadowColor, "Name")
    self:CreateTextEntryWithBackgroundAndLabel("desc", textFont, textFontSize * 2, textColor, shadowColor, "Description")
    self:CreateTextEntryWithBackgroundAndLabel("faction", textFont, textFontSize, textColor, shadowColor, "Faction")
    self:CreateTextEntryWithBackgroundAndLabel("money", textFont, textFontSize, textColor, shadowColor, "Money")
    self:CreateTextEntryWithBackgroundAndLabel("class", textFont, textFontSize, textColor, shadowColor, "Class")
    if MODULE.F1DisplayAttributes then
        for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
            local attribValue = character:getAttrib(k, 0)
            local maximum = v.maxValue or lia.config.MaxAttributes
            if v.NoF1Show then continue end
            self:CreateFillableBarWithBackgroundAndLabel(v.name, textFont, textFontSize, Color(255, 255, 255), shadowColor, attribValue .. "/" .. maximum, 0, maximum, 1, attribValue)
        end
    end

    local changeDescButton = vgui.Create("DButton", self.infoBox)
    changeDescButton:SetText("Change Description")
    changeDescButton:SetFont("Default")
    changeDescButton:Dock(BOTTOM)
    changeDescButton:DockMargin(8, 8, 8, 8)
    changeDescButton.DoClick = function()
        local newDesc = self.desc:GetText()
        lia.command.send("chardesc", newDesc)
    end

    self:setup()
end

function PANEL:CreateTextEntryWithBackgroundAndLabel(name, font, size, textColor, shadowColor, labelText, dockMarginBot, dockMarginTop)
    if hook.Run("CanDisplayCharacterInfo", name) == false then return end
    local isDesc = name == "desc"
    local entryContainer = self.infoBox:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(size + 5)
    entryContainer:DockMargin(8, dockMarginTop or 1, 8, dockMarginBot or 1)
    entryContainer.Paint = function(_, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = entryContainer:Add("DLabel")
    label:SetFont(font)
    label:SetWide(85)
    label:SetTall(25)
    label:SetTextColor(textColor)
    label:SetText(labelText)
    label:Dock(LEFT)
    label:DockMargin(0, 0, 0, 0)
    label:SetContentAlignment(5)
    self[name] = entryContainer:Add("DTextEntry")
    self[name]:SetFont(font)
    self[name]:SetTall(size)
    self[name]:Dock(FILL)
    self[name]:SetTextColor(textColor)
    self[name]:SetEditable(isDesc and true or false)
    self[name]:SetMultiline(isDesc and true or false)
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(name, font, _, textColor, shadowColor, labelText, minVal, maxVal, dockMarginTop, value)
    local entryContainer = self.infoBox:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(25)
    entryContainer:DockMargin(8, dockMarginTop or 1, 8, 1)
    entryContainer.Paint = function(_, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = entryContainer:Add("DLabel")
    label:SetFont(font)
    label:SetWide(85)
    label:SetTall(10)
    label:Dock(LEFT)
    label:SetTextColor(textColor)
    label:SetText(name)
    label:SetContentAlignment(5)
    local bar = entryContainer:Add("DPanel")
    bar:Dock(FILL)
    bar.Paint = function(_, w, h)
        local percentage = math.Clamp((tonumber(value) - tonumber(minVal)) / (tonumber(maxVal) - tonumber(minVal)), 0, 1)
        local filledWidth = percentage * w
        local filledColor = Color(45, 45, 45, 255)
        surface.SetDrawColor(filledColor)
        surface.DrawRect(0, 0, filledWidth, h)
        draw.SimpleText(labelText, font, w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self[name] = bar
end

function PANEL:setup()
    local client = LocalPlayer()
    local character = client:getChar()
    if self.name then self.name:SetText(character:getName()) end
    if self.desc then self.desc:SetText(character:getDesc()) end
    if self.money then self.money:SetText(character:getMoney() .. " " .. lia.currency.plural) end
    if self.faction then self.faction:SetText(L(team.GetName(client:Team()))) end
    if self.class then self.class:SetText((class and class.name) or "None") end
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")
