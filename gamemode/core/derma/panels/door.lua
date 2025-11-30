local PANEL = {}
function PANEL:Init()
    self:SetSize(700, 600)
    self:SetTitle(L("door") .. " " .. L("settings"))
    self:Center()
    self:MakePopup()
    self.access = self:Add("DListView")
    self.access:Dock(FILL)
    local headerColor = lia.color.theme.header_text or Color(255, 255, 255)
    local headerBgColor = lia.color.theme.header or Color(45, 45, 45)
    self.access:AddColumn(L("name")).Header:SetTextColor(headerColor)
    self.access:AddColumn(L("doorAccess")).Header:SetTextColor(headerColor)
    for _, column in pairs(self.access.Columns) do
        if column.Header then
            column.Header.Paint = function(_, w, h)
                surface.SetDrawColor(headerBgColor)
                surface.DrawRect(0, 0, w, h)
            end
        end
    end

    self.access.Paint = function(_, w, h)
        surface.SetDrawColor(lia.color.theme.panel[1] or Color(35, 35, 35))
        surface.DrawRect(0, 0, w, h)
    end

    local rowIndex = 0
    self.access.PaintOver = function()
        for _, line in pairs(self.access:GetLines()) do
            if line:IsVisible() then
                local color = rowIndex % 2 == 0 and Color(0, 0, 0, 50) or Color(0, 0, 0, 25)
                surface.SetDrawColor(color)
                surface.DrawRect(0, line:GetY(), self.access:GetWide(), line:GetTall())
                rowIndex = rowIndex + 1
            end
        end

        rowIndex = 0
    end

    self.access.OnClickLine = function(_, line)
        if not IsValid(line.player) then return end
        local menu = lia.derma.dermaMenu()
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
                local doorData = lia.doors.getData(ent)
                entry:SetText(doorData.name or L("doorTitleOwned"))
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

vgui.Register("liaDoorMenu", PANEL, "liaFrame")
