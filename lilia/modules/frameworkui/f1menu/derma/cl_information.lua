---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local PANEL = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:Init()
    local client = LocalPlayer()
    local char = client:getChar()
    local class = lia.class.list[char:getClass()]
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
    elseif F1MenuCore.InfoMenuLocation == "BottomLeft" then
        self:SetPos(10, ScrH() - panelHeight - 10)
    elseif F1MenuCore.InfoMenuLocation == "BottomRight" then
        self:SetPos(ScrW() - panelWidth - 10, ScrH() - panelHeight - 10)
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
    self:CreateTextEntryWithBackgroundAndLabel("name", textFont, textFontSize, textColor, shadowColor, "Character Name")
    self:CreateTextEntryWithBackgroundAndLabel("desc", textFont, textFontSize, textColor, shadowColor, "Character Description")
    self:CreateTextEntryWithBackgroundAndLabel("faction", textFont, textFontSize, textColor, shadowColor, "Character Faction")
    self:CreateTextEntryWithBackgroundAndLabel("money", textFont, textFontSize, textColor, shadowColor, "Character Money")
    if class then self:CreateTextEntryWithBackgroundAndLabel("class", textFont, textFontSize, textColor, shadowColor, "Character Class") end
    self:setup()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:CreateTextEntryWithBackgroundAndLabel(name, font, size, textColor, shadowColor, labelText, dockMarginTop)
    local isDesc = name == "desc"
    local entryContainer = self.infoBox:Add("DPanel")
    entryContainer:Dock(TOP)
    entryContainer:SetTall(size + 25)
    entryContainer:DockMargin(8, 8, 8, dockMarginTop or 8)
    entryContainer.Paint = function(_, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = entryContainer:Add("DLabel")
    label:SetFont(font)
    label:SetTall(25)
    label:Dock(TOP)
    label:SetTextColor(textColor)
    label:SetText(labelText)
    label:SetContentAlignment(5)
    self[name] = entryContainer:Add("DTextEntry")
    self[name]:SetFont(font)
    self[name]:SetTall(size)
    self[name]:SetEditable(isDesc and true or false)
    self[name]:Dock(FILL)
    self[name]:SetTextColor(textColor)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:setup()
    local client = LocalPlayer()
    local char = client:getChar()
    if self.name then self.name:SetText(char:getName()) end
    if self.desc then self.desc:SetText(char:getDesc()) end
    if self.money then self.money:SetText(char:getMoney() .. " " .. lia.currency.plural) end
    if self.faction then self.faction:SetText(L(team.GetName(client:Team()))) end
    if self.class then self.class:SetText((class and class.name) or "None") end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
vgui.Register("liaCharInfo", PANEL, "EditablePanel")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------