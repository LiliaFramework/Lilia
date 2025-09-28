local PANEL = {}
function PANEL:Init()
    self:SetSize(280, 240)
    self:SetTitle(L("door") .. " " .. L("settings"))
    self:Center()
    self:MakePopup()
    self.access = self:Add("DListView")
    self.access:Dock(FILL)
    local headerColor = Color(25, 25, 25)
    self.access:AddColumn(L("name")).Header:SetTextColor(headerColor)
    self.access:AddColumn(L("doorAccess")).Header:SetTextColor(headerColor)
    self.access.OnClickLine = function(_, line)
        if not IsValid(line.player) then return end
        local menu = DermaMenu()
        local ply = line.player
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
    for _, ply in player.Iterator() do
        if ply ~= client and ply:getChar() then
            local line = self.access:AddLine(ply:Name():gsub("#", "\226\128\139#"), L(lia.doors.AccessLabels[accessData[ply] or 0]))
            line.player = ply
        end
    end

    if self:CheckAccess(DOOR_OWNER) then
        local btn = self:Add("DButton")
        btn:Dock(BOTTOM)
        btn:DockMargin(0, 5, 0, 0)
        btn:SetText(L("doorSell"))
        btn:SetTextColor(color_white)
        btn.DoClick = function()
            self:Remove()
            lia.command.send("doorsell")
        end

        self.sell = btn
    end

    if self:CheckAccess(DOOR_TENANT) then
        local entry = self:Add("DTextEntry")
        entry:Dock(TOP)
        entry:DockMargin(0, 0, 0, 5)
        entry.Think = function()
            if not entry:IsEditing() then
                local ent = IsValid(fallback) and fallback or door
                entry:SetText(ent:getNetVar("title", L("doorTitleOwned")))
            end
        end

        entry.OnEnter = function() lia.command.send("doorsettitle", entry:GetText()) end
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

vgui.Register("liaDoorMenu", PANEL, "DFrame")
