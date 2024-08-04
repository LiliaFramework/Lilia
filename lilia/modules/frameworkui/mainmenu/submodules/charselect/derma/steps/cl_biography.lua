local PANEL = {}
local HIGHLIGHT = Color(255, 255, 255, 50)
function PANEL:Init()
    self.nameLabel = self:addLabel("name")
    self.nameLabel:SetZPos(0)
    self.nameLabel:SetTextColor(color_white)
    self.name = self:addTextEntry("name")
    self.name:SetTall(48)
    self.name.onTabPressed = function() self.desc:RequestFocus() end
    self.name:SetZPos(1)
    self.name:SetTextColor(color_white)
    if RandomNameGenerator then
        self.rando = self:Add("DButton")
        self.rando:Dock(TOP)
        self.rando:SetTall(36)
        self.rando:SetText("Randomize Name")
        self.rando:SetFont("liaMenuButtonFont")
        self.rando:DockMargin(0, 4, 0, 16)
        self.rando.DoClick = function()
            local randName = RandomNameGenerator:generateName()
            self.name:SetText(randName)
            self:setContext("name", randName)
        end
    end

    self.descLabel = self:addLabel("description")
    self.descLabel:SetZPos(2)
    self.descLabel:SetTextColor(color_white)
    self.desc = self:addTextEntry("desc")
    self.desc:SetTall(self.name:GetTall() * 3)
    self.desc.onTabPressed = function() self.name:RequestFocus() end
    self.desc:SetMultiline(true)
    self.desc:SetZPos(3)
    self.desc:SetTextColor(color_white)
end

function PANEL:addTextEntry(contextName)
    local entry = self:Add("DTextEntry")
    entry:Dock(TOP)
    entry:SetFont("liaMenuButtonFont")
    entry.Paint = self.paintTextEntry
    entry:DockMargin(0, 4, 0, 16)
    entry.OnValueChange = function(_, value) self:setContext(contextName, string.Trim(value)) end
    entry.contextName = contextName
    entry.OnKeyCodeTyped = function(name, keyCode)
        if keyCode == KEY_TAB then
            entry:onTabPressed()
            return true
        end
    end

    entry:SetUpdateOnType(true)
    return entry
end

function PANEL:onDisplay()
    local client = LocalPlayer()
    local faction = self:getContext("faction")
    assert(faction, "Faction not set before showing name input")
    local defaultName, overrideName = hook.Run("GetDefaultCharName", client, faction)
    if overrideName then
        self.nameLabel:SetVisible(false)
        self.name:SetVisible(false)
    else
        if defaultName and not self:getContext("name") then self:setContext("name", defaultName) end
        self.nameLabel:SetVisible(true)
        self.name:SetVisible(true)
        self.name:SetText(self:getContext("name", ""))
    end

    local defaultDesc, overrideDesc = hook.Run("GetDefaultCharDesc", client, faction)
    if overrideDesc then
        self.descLabel:SetVisible(false)
        self.desc:SetVisible(false)
    else
        if defaultDesc and not self:getContext("desc") then self:setContext("desc", defaultDesc) end
        self.descLabel:SetVisible(true)
        self.desc:SetVisible(true)
        self.desc:SetText(self:getContext("desc", ""))
    end

    self.name:SetTextColor(color_white)
    self.desc:RequestFocus()
end

function PANEL:validate()
    if self.name:IsVisible() then
        local res = {self:validateCharVar("name")}
        if res[1] == false then return unpack(res) end
    end
    return self:validateCharVar("desc")
end

function PANEL:paintTextEntry(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
    self:DrawTextEntryText(color_white, HIGHLIGHT, HIGHLIGHT)
end

vgui.Register("liaCharacterBiography", PANEL, "liaCharacterCreateStep")