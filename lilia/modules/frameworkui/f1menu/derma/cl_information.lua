local PANEL = {}
function PANEL:Init()
    local char = LocalPlayer():getChar()
    local class = lia.class.list[char:getClass()]
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    local panelWidth = ScrW() * 0.25
    local panelHeight = ScrH() * 0.25
    local textFontSize = 20
    local textFont = "liaSmallFont"
    local textColor = color_white
    local panelColor = Color(0, 0, 0, 235)
    self:SetSize(panelWidth, panelHeight)
    self:SetPos((ScrW() - panelWidth) / 2, ScrH() * 0.75)
    self.info = vgui.Create("DFrame", self)
    self.info:SetTitle("")
    self.info:SetSize(panelWidth, panelHeight)
    self.info:ShowCloseButton(false)
    self.info:SetDraggable(false)
    self.info.Paint = function() end
    self.infoBox = self.info:Add("DPanel")
    self.infoBox:Dock(FILL)
    self.infoBox.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, panelColor) end
    self.name = self.infoBox:Add("DLabel")
    self.name:SetFont(textFont)
    self.name:SetTall(textFontSize)
    self.name:Dock(TOP)
    self.name:SetTextColor(textColor)
    self.name:DockMargin(8, 8, 8, 8)
    self.money = self.infoBox:Add("DLabel")
    self.money:Dock(TOP)
    self.money:SetFont(textFont)
    self.money:SetTall(textFontSize)
    self.money:SetTextColor(textColor)
    self.money:DockMargin(8, 8, 8, 8)
    self.faction = self.infoBox:Add("DLabel")
    self.faction:Dock(TOP)
    self.faction:SetFont(textFont)
    self.faction:SetTall(textFontSize)
    self.faction:SetTextColor(textColor)
    self.faction:DockMargin(8, 8, 8, 8)
    if class then
        self.class = self.infoBox:Add("DLabel")
        self.class:Dock(TOP)
        self.class:SetFont(textFont)
        self.class:SetTall(textFontSize)
        self.class:SetTextColor(textColor)
        self.class:DockMargin(8, 8, 8, 8)
    end

    self.desc = self.infoBox:Add("DTextEntry")
    self.desc:Dock(BOTTOM)
    self.desc:SetFont(textFont)
    self.desc:SetTall(textFontSize * 2)
    self.desc:SetMultiline(true)
    self.desc:SetTextColor(textColor)
    self.desc:SetDrawBorder(false)
    self.desc:SetPaintBackground(false)
    self.desc:SetText(char:getDesc())
    self.desc:DockMargin(8, -5, 8, 8)
    local btnEditDesc = self.infoBox:Add("DButton")
    btnEditDesc:SetText("Edit Description")
    btnEditDesc:Dock(BOTTOM)
    btnEditDesc:DockMargin(8, 8, 8, 8)
    btnEditDesc.DoClick = function()
        local newDesc = self.desc:GetValue()
        lia.command.send("chardesc", newDesc)
    end
end

function PANEL:setup()
    local char = LocalPlayer():getChar()
    if self.name then
        self.name:SetText("Your name is " .. LocalPlayer():Name():gsub("#", "\226\128\139#"))
        hook.Add("OnCharVarChanged", self, function(_, character, key, _, value)
            if char ~= character then return end
            if key ~= "name" then return end
            self.name:SetText(value:gsub("#", "\226\128\139#"))
        end)
    end

    if self.money then self.money:SetText(L("charMoney", lia.currency.get(char:getMoney()))) end
    if self.faction then self.faction:SetText(L("charFaction", L(team.GetName(LocalPlayer():Team())))) end
    if self.class and class then self.class:SetText("You are on the class " .. class.name) end
end

function PANEL:Paint()
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")