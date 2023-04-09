local PANEL = {}


local function teamGetPlayers(teamID)
    local players = {}

    for _, ply in next, player.GetAll() do
        local isDisguised = hook.Run("GetDisguised", ply)

        if isDisguised and isDisguised == teamID then
            table.insert(players, ply)
        elseif not isDisguised and ply:Team() == teamID then
            table.insert(players, ply)
        end
    end

    return players
end

local function teamNumPlayers(teamID)
    return #teamGetPlayers(teamID)
end

local paintFunctions = {}
paintFunctions[0] = function(this, w, h)
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 0, w, h)
end
paintFunctions[1] = function(this, w, h)
end

function PANEL:Init()
    if IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end

    lia.gui.score = self
    self:SetSize(ScrW() * lia.config.get("sbWidth"), ScrH() * lia.config.get("sbHeight"))
    self:Center()
    self.title = self:Add("DLabel")
    self.title:SetText(GetHostName())
    self.title:SetFont("liaBigFont")
    self.title:SetContentAlignment(5)
    self.title:SetTextColor(color_white)
    self.title:SetExpensiveShadow(1, color_black)
    self.title:Dock(TOP)
    self.title:SizeToContentsY()
    self.title:SetTall(self.title:GetTall() + 16)

    self.title.Paint = function(this, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(1, 0, 1, 0)
    self.scroll.VBar:SetWide(0)
    self.layout = self.scroll:Add("DListLayout")
    self.layout:Dock(TOP)
    self.teams = {}
    self.slots = {}
    self.i = {}
    local staffCount = 0

    for _, ply in ipairs(player.GetAll()) do
        if UserGroups.StaffRanks[ply:GetUserGroup()] then
            staffCount = staffCount + 1
        end
    end

    local staffList = self.layout:Add("DListLayout")
    staffList:Dock(TOP)
    staffList:SetTall(32)
    self.staffListHeader = staffList:Add("DLabel")
    self.staffListHeader:Dock(LEFT)
    self.staffListHeader:SetText("Staff Online: " .. staffCount)
    self.staffListHeader:SetTextInset(3, 0)
    self.staffListHeader:SetFont("liaMediumFont")
    self.staffListHeader:SetTextColor(color_white)
    self.staffListHeader:SetExpensiveShadow(1, color_black)
    self.staffListHeader:SetTall(28)
    self.staffListHeader:SizeToContents()

    self.staffListHeader.Paint = function(this, w, h)
        surface.SetDrawColor(50, 50, 50, 20)
        surface.DrawRect(0, 0, w, h)
    end

    for k, v in ipairs(lia.faction.indices) do
        local color = team.GetColor(k)
        local r, g, b = color.r, color.g, color.b
        local list = self.layout:Add("DListLayout")
        list:Dock(TOP)
        list:SetTall(28)

        list.Think = function(this)
            for k2, v2 in ipairs(teamGetPlayers(k)) do
                if not IsValid(v2.liaScoreSlot) or v2.liaScoreSlot:GetParent() ~= this then
                    if IsValid(v2.liaScoreSlot) then
                        v2.liaScoreSlot:SetParent(this)
                    else
                        self:addPlayer(v2, this)
                    end
                end
            end
        end

        local header = list:Add("DLabel")
        header:Dock(TOP)
        header:SetText(L(v.name))
        header:SetTextInset(3, 0)
        header:SetFont("liaMediumFont")
        header:SetTextColor(color_white)
        header:SetExpensiveShadow(1, color_black)
        header:SetTall(28)

        header.Paint = function(this, w, h)
            surface.SetDrawColor(r, g, b, 20)
            surface.DrawRect(0, 0, w, h)
        end

        self.teams[k] = list
    end
end

function PANEL:Think()
    if (self.nextUpdate or 0) < CurTime() then
        self.title:SetText(lia.config.get("sbTitle", GetHostName()))
        local visible, amount

        for k, v in ipairs(self.teams) do
            visible, amount = v:IsVisible(), teamNumPlayers(k)
            if visible and k == FACTION_STAFF and LocalPlayer():Team() == FACTION_STAFF then
                v:SetVisible(true)
                self.layout:InvalidateLayout()
            elseif visible and k == FACTION_STAFF then
                v:SetVisible(false)
                self.layout:InvalidateLayout()
            end

            if visible and amount == 0 then
                v:SetVisible(false)
                self.layout:InvalidateLayout()
            elseif not visible and amount > 0 and k ~= FACTION_STAFF then
                v:SetVisible(true)
            end
        end

        for k, v in pairs(self.slots) do
            if IsValid(v) then
                v:update()
            end
        end

        self.nextUpdate = CurTime() + 0.1
    end
end

function PANEL:addPlayer(client, parent)
    if not client:getChar() or not IsValid(parent) then return end
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    slot:SetTall(64)
    slot:DockMargin(0, 0, 0, 1)
    slot.character = client:getChar()
    client.liaScoreSlot = slot
    slot.model = slot:Add("liaSpawnIcon")
    slot.model:SetModel(client:GetModel(), client:GetSkin())
    slot.model:SetSize(64, 64)

    slot.model.DoClick = function()
        local menu = DermaMenu()
        local options = {}
        hook.Run("ShowPlayerOptions", client, options)

        if table.Count(options) > 0 then
            for k, v in SortedPairs(options) do
                menu:AddOption(L(k), v[2]):SetImage(v[1])
            end
        end

        menu:Open()
        RegisterDermaMenuForClose(menu)
    end

    slot.model:SetTooltip(L("sbOptions", client:steamName()))

    timer.Simple(0, function()
        if not IsValid(slot) then return end
        local entity = slot.model.Entity

        if IsValid(entity) then
            for k, v in ipairs(client:GetBodyGroups()) do
                entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
            end

            for k, v in ipairs(client:GetMaterials()) do
                entity:SetSubMaterial(k - 1, client:GetSubMaterial(k - 1))
            end
        end
    end)

    slot.name = slot:Add("DLabel")
    slot.name:Dock(TOP)
    slot.name:DockMargin(65, 0, 48, 0)
    slot.name:SetTall(18)
    slot.name:SetFont("liaGenericFont")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, color_black)
    slot.ping = slot:Add("DLabel")
    slot.ping:SetPos(self:GetWide() - 48, 0)
    slot.ping:SetSize(48, 64)
    slot.ping:SetText("0")

    slot.ping.Think = function(this)
        if IsValid(client) then
            this:SetText(client:Ping())
        end
    end

    slot.ping:SetFont("liaGenericFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    slot.ping:SetExpensiveShadow(1, color_black)
    local oldTeam = client:Team()

    function slot:update()
        if not IsValid(client) or not client:getChar() or not self.character or self.character ~= client:getChar() or oldTeam ~= client:Team() then
            self:Remove()
            local i = 0

            for k, v in ipairs(parent:GetChildren()) do
                if IsValid(v.model) and v ~= self then
                    i = i + 1
                    v.Paint = paintFunctions[i % 2]
                end
            end

            return
        end

        local overrideName = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client)
        local name = overrideName or client:Name()
        name = name:gsub("#", "\226\128\139#")
        local model = client:GetModel()
        local skin = client:GetSkin()
        self.model:setHidden(overrideName == L("unknown"))

        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local entity = self.model.Entity
        if not IsValid(entity) then return end

        local offDutySB = {
            root = true,
            communitymanager = true,
            superadministrator = true,
        }

        if self.lastModel ~= model or self.lastSkin ~= skin then
            self.model:SetModel(client:GetModel(), client:GetSkin())

            if offDutySB[LocalPlayer():GetUserGroup()] or (LocalPlayer() == client) or LocalPlayer():Team() == FACTION_STAFF then
                self.model:SetToolTip(L("sbOptions", client:steamName()))
            else
                self.model:SetToolTip("You do not have access to see this information")
            end

            self.lastModel = model
            self.lastSkin = skin
        end

        timer.Simple(0, function()
            if not IsValid(entity) or not IsValid(client) then return end

            for k, v in ipairs(client:GetBodyGroups()) do
                entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
            end
        end)
    end

    self.slots[#self.slots + 1] = slot
    parent:SetVisible(true)
    parent:SizeToChildren(false, true)
    parent:InvalidateLayout(true)
    local i = 0

    for k, v in ipairs(parent:GetChildren()) do
        if IsValid(v.model) then
            i = i + 1
            v.Paint = paintFunctions[i % 2]
        end
    end

    slot:update()

    return slot
end

function PANEL:OnRemove()
    CloseDermaMenus()
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(30, 30, 30, 100)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaScoreboard", PANEL, "EditablePanel")

concommand.Add("dev_reloadsb", function()
    if IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end
end)