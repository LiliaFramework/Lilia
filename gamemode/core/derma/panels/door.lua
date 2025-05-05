local PANEL = {}
function PANEL:Init()
    self:SetSize(280, 240)
    self:SetTitle(L("doorSettings"))
    self:Center()
    self:MakePopup()
    self.access = self:Add("DListView")
    self.access:Dock(FILL)
    local headerColor = Color(25, 25, 25)
    self.access:AddColumn(L("doorName")).Header:SetTextColor(headerColor)
    self.access:AddColumn(L("doorAccess")).Header:SetTextColor(headerColor)
    self.access.OnClickLine = function(_, line)
        if not IsValid(line.player) then return end
        local menu = DermaMenu()
        local playerEntity = line.player
        local accessData = self.accessData
        local doorEntity = self.door
        menu:AddOption(L("doorTenant"), function() if accessData and accessData[playerEntity] ~= DOOR_TENANT then netstream.Start("doorPerm", doorEntity, playerEntity, DOOR_TENANT) end end):SetImage("icon16/user_add.png")
        menu:AddOption(L("doorGuest"), function() if accessData and accessData[playerEntity] ~= DOOR_GUEST then netstream.Start("doorPerm", doorEntity, playerEntity, DOOR_GUEST) end end):SetImage("icon16/user_green.png")
        menu:AddOption(L("doorNone"), function() if accessData and accessData[playerEntity] ~= DOOR_NONE then netstream.Start("doorPerm", doorEntity, playerEntity, DOOR_NONE) end end):SetImage("icon16/user_red.png")
        menu:Open()
    end
end

function PANEL:setDoor(doorEntity, accessData, fallbackDoor)
    doorEntity.liaPanel = self
    self.accessData = accessData
    self.door = doorEntity
    local client = LocalPlayer()
    for _, ply in player.Iterator() do
        if ply ~= client and ply:getChar() then
            local label = L(ACCESS_LABELS[accessData[ply] or 0])
            local line = self.access:AddLine(ply:Name():gsub("#", "\226\128\139#"), label)
            line.player = ply
        end
    end

    if self:CheckAccess(DOOR_OWNER) then
        local sellBtn = self:Add("DButton")
        sellBtn:Dock(BOTTOM)
        sellBtn:DockMargin(0, 5, 0, 0)
        sellBtn:SetText(L("doorSell"))
        sellBtn:SetTextColor(color_white)
        sellBtn.DoClick = function()
            self:Remove()
            lia.command.send("doorsell")
        end

        self.sell = sellBtn
    end

    if self:CheckAccess(DOOR_TENANT) then
        local textEntry = self:Add("DTextEntry")
        textEntry:Dock(TOP)
        textEntry:DockMargin(0, 0, 0, 5)
        textEntry.Think = function()
            if not textEntry:IsEditing() then
                local entity = IsValid(fallbackDoor) and fallbackDoor or doorEntity
                textEntry:SetText(entity:getNetVar("title", L("doorTitleOwned")))
            end
        end

        textEntry.OnEnter = function() lia.command.send("doorsettitle", textEntry:GetText()) end
        self.name = textEntry
    end
end

function PANEL:CheckAccess(minAccess)
    if not self.accessData then return false end
    return (self.accessData[LocalPlayer()] or 0) >= (minAccess or DOOR_GUEST)
end

function PANEL:Think()
    if self.accessData and not IsValid(self.door) and self:CheckAccess() then self:Remove() end
end

vgui.Register("liaDoorMenu", PANEL, "DFrame")