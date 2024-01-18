local PANEL = {}
function PANEL:Init()
    local char = LocalPlayer():getChar()
    local class = lia.class.list[char:getClass()]
    if IsValid(lia.gui.info) then
        lia.gui.info:Remove()
    end

    lia.gui.info = self
    local panelWidth = ScrW() * 0.25
    local panelHeight = ScrH() * 0.25
    local textFontSize = 20
    local textFont = "liaSmallFont"
    local textColor = color_white
    self:SetSize(panelWidth, panelHeight)
    self:SetPos(ScrW() * 0.73, ScrH() * 0.02)
    self.info = vgui.Create("DFrame", self)
    self.info:SetTitle("Character Information")
    self.info:SetSize(panelWidth, panelHeight)
    self.info:ShowCloseButton(false)
    self.info:SetDraggable(false)
    self.info.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 200))
    end

    self.infoBox = self.info:Add("DPanel")
    self.infoBox:Dock(FILL)
    self.infoBox.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    self.name = self.infoBox:Add("DLabel")
    self.name:SetFont(textFont)
    self.name:SetTall(textFontSize)
    self.name:Dock(TOP)
    self.name:SetTextColor(textColor)
    self.name:DockMargin(8, 8, 8, 4)
    self.money = self.infoBox:Add("DLabel")
    self.money:Dock(TOP)
    self.money:SetFont(textFont)
    self.money:SetTall(textFontSize)
    self.money:SetTextColor(textColor)
    self.money:DockMargin(8, 0, 8, 0)
    self.faction = self.infoBox:Add("DLabel")
    self.faction:Dock(TOP)
    self.faction:SetFont(textFont)
    self.faction:SetTall(textFontSize)
    self.faction:SetTextColor(textColor)
    self.faction:DockMargin(8, 0, 8, 0)
    if class then
        self.class = self.infoBox:Add("DLabel")
        self.class:Dock(TOP)
        self.class:SetFont(textFont)
        self.class:SetTall(textFontSize)
        self.class:SetTextColor(textColor)
        self.class:DockMargin(8, 0, 8, 0)
    end

    self.desc = self.infoBox:Add("DTextEntry")
    self.desc:Dock(BOTTOM)
    self.desc:SetFont(textFont)
    self.desc:SetTall(textFontSize)
    self.desc:SetMultiline(true)
    self.desc:SetTextColor(textColor)
    self.desc:SetDrawBorder(false)
    self.desc:SetPaintBackground(false)
    self.desc:SetText(char:getDesc())
    local btnEditDesc = self.infoBox:Add("DButton")
    btnEditDesc:SetText("Edit Description")
    btnEditDesc:Dock(BOTTOM)
    btnEditDesc.DoClick = function()
        local newDesc = self.desc:GetValue()
        lia.command.send("chardesc", newDesc)
    end

    hook.Run("CreateCharInfoText", self, suppress)
    hook.Run("CreateCharInfo", self)
end

function PANEL:setup()
    local char = LocalPlayer():getChar()
    if self.name then
        self.name:SetText(LocalPlayer():Name():gsub("#", "\226\128\139#"))
        hook.Add(
            "OnCharVarChanged",
            self,
            function(_, character, key, _, value)
                if char ~= character then return end
                if key ~= "name" then return end
                self.name:SetText(value:gsub("#", "\226\128\139#"))
            end
        )
    end

    if self.money then
        self.money:SetText(L("charMoney", lia.currency.get(char:getMoney())))
    end

    if self.faction then
        self.faction:SetText(L("charFaction", L(team.GetName(LocalPlayer():Team()))))
    end

    if self.class then
        local class = lia.class.list[char:getClass()]
        if class then
            self.class:SetText(L("charClass", L(class.name)))
        end
    end

    hook.Run("OnCharInfoSetup", self)
end

function PANEL:Paint()
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")