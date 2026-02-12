local PANEL = {}
function PANEL:Init()
    self:SetSize(700, 600)
    self:SetTitle(L("door") .. " " .. L("settings"))
    self:Center()
    self:MakePopup()
    self.access = self:Add("liaTable")
    self.access:Dock(FILL)
    self.access:AddColumn(L("name"), 400)
    self.access:AddColumn(L("doorAccess"), 250, TEXT_ALIGN_RIGHT)
    self.access.OnAction = function(rowData)
        local ply = rowData._player
        if not IsValid(ply) then return end
        local menu = lia.derma.dermaMenu()
        local accessData = self.accessData
        local door = self.door
        local function sendPerm(level)
            net.Start("liaDoorPerm")
            net.WriteEntity(door)
            net.WriteEntity(ply)
            net.WriteUInt(level, 2)
            net.SendToServer()
        end

        menu:AddOption(L("tenant"), function() if accessData[ply] ~= DOOR_TENANT then sendPerm(DOOR_TENANT) end end):SetImage("icon16/user_add.png")
        menu:AddOption(L("guest"), function() if accessData[ply] ~= DOOR_GUEST then sendPerm(DOOR_GUEST) end end):SetImage("icon16/user_green.png")
        menu:AddOption(L("none"), function() if accessData[ply] ~= DOOR_NONE then sendPerm(DOOR_NONE) end end):SetImage("icon16/user_red.png")
        menu:Open()
    end
end

function PANEL:setDoor(door, accessData, fallback)
    door.liaPanel = self
    self.accessData = accessData
    self.door = door
    local client = LocalPlayer()
    self.access:Clear()
    for _, ply in player.Iterator() do
        if ply ~= client and ply:getChar() then
            local row = self.access:AddRow(ply:Name():gsub("#", "\226\128\139#"), L(lia.doors.AccessLabels[accessData[ply] or 0]))
            row._player = ply
        end
    end

    if self:CheckAccess(DOOR_OWNER) then
        local btnPanel = self:Add("DPanel")
        btnPanel:Dock(BOTTOM)
        btnPanel:SetTall(45)
        btnPanel:DockMargin(0, 10, 0, 0)
        btnPanel.Paint = nil
        local btn = btnPanel:Add("liaButton")
        btn:Dock(FILL)
        btn:SetText(L("doorSell"))
        btn.DoClick = function()
            self:Remove()
            lia.command.send("doorsell")
        end

        self.sell = btn
    end

    if self:CheckAccess(DOOR_TENANT) then
        local entry = self:Add("liaEntry")
        entry:Dock(TOP)
        entry:DockMargin(0, 0, 0, 10)
        entry:SetPlaceholder(L("doorTitleOwned"))
        entry.Think = function(s)
            if not s.textEntry:IsEditing() then
                local ent = IsValid(fallback) and fallback or door
                local doorData = lia.doors.getData(ent)
                local doorName = doorData.name or L("doorTitleOwned")
                if s:GetValue() ~= doorName then s:SetText(doorName) end
            end
        end

        entry.OnEnter = function(s) lia.command.send("doorsettitle", s:GetValue()) end
        self.name = entry
    end
end

function PANEL:CheckAccess(minimum)
    if not self.accessData then return false end
    return (self.accessData[LocalPlayer()] or 0) >= (minimum or DOOR_GUEST)
end

function PANEL:Think()
    if self.accessData and not IsValid(self.door) and self:CheckAccess() then self:Remove() end
end

vgui.Register("liaDoorMenu", PANEL, "liaFrame")
