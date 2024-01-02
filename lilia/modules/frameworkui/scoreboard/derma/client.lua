------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local StaffCount = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local StaffOnDutyCount = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function teamGetPlayers(teamID)
    local players = {}
    for _, client in next, player.GetAll() do
        local isDisguised = hook.Run("GetDisguised", client)
        if isDisguised and isDisguised == teamID then
            table.insert(players, client)
        elseif not isDisguised and client:Team() == teamID then
            table.insert(players, client)
        end
    end
    return players
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function teamNumPlayers(teamID)
    return #teamGetPlayers(teamID)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local paintFunctions = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
paintFunctions[0] = function(_, w, h)
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 0, w, h)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
paintFunctions[1] = function(_, _, _) end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    lia.gui.score = self
    self:SetSize(ScrW() * ScoreboardCore.sbWidth, ScrH() * ScoreboardCore.sbHeight)
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
    self.title.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end

    self.staff1 = self:Add("DLabel")
    self.staff1:SetText("Staff Online: 0")
    self.staff1:SetFont("liaBigFont")
    self.staff1:SetContentAlignment(5)
    self.staff1:SetTextColor(color_white)
    self.staff1:SetExpensiveShadow(1, color_black)
    self.staff1:Dock(BOTTOM)
    self.staff1:SizeToContentsY()
    self.staff1:SetTall(self.title:GetTall() - 16)
    self.staff1.Paint = function(_, w, h)
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
    for k, v in ipairs(lia.faction.indices) do
        if table.HasValue(ScoreboardCore.HiddenFactions, k) then continue end
        local color = team.GetColor(k)
        local r, g, b = color.r, color.g, color.b
        local list = self.layout:Add("DListLayout")
        list:Dock(TOP)
        list:SetTall(28)
        list.Think = function(this)
            for _, v2 in ipairs(teamGetPlayers(k)) do
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
        header.Paint = function(_, w, h)
            surface.SetDrawColor(r, g, b, 20)
            surface.DrawRect(0, 0, w, h)
        end

        self.teams[k] = list
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:UpdateStaff()
    StaffCount = 0
    StaffOnDutyCount = 0
    for _, target in pairs(player.GetAll()) do
        if target:isStaff() then StaffCount = StaffCount + 1 end
        if target:isStaffOnDuty() then StaffOnDutyCount = StaffOnDutyCount + 1 end
    end

    self.staff1:SetText("Staff On Duty: " .. StaffOnDutyCount .. " | Staff Online: " .. StaffCount)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:Think()
    if (self.nextUpdate or 0) < CurTime() then
        self.title:SetText(ScoreboardCore.sbTitle)
        local visible, amount
        for k, v in ipairs(self.teams) do
            visible, amount = v:IsVisible(), teamNumPlayers(k)
            if visible and k == FACTION_STAFF and LocalPlayer():isStaffOnDuty() then
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

        for _, v in pairs(self.slots) do
            if IsValid(v) then v:update() end
        end

        if input.IsKeyDown(KEY_Z) then self:Init() end
        self.nextUpdate = CurTime() + 0.1
        self:UpdateStaff()
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:addPlayer(client, parent)
    if not hook.Run("ShouldShowPlayerOnScoreboard", client) or not client:getChar() or not IsValid(parent) then return end
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

    slot.model:SetTooltip(L("sbOptions", client:Name()))
    timer.Simple(
        0,
        function()
            if not IsValid(slot) then return end
            local entity = slot.model.Entity
            if IsValid(entity) then
                for _, v in ipairs(client:GetBodyGroups()) do
                    entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
                end

                for k, _ in ipairs(client:GetMaterials()) do
                    entity:SetSubMaterial(k - 1, client:GetSubMaterial(k - 1))
                end
            end
        end
    )

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
    slot.ping.Think = function(this) if IsValid(client) then this:SetText(client:Ping()) end end
    slot.ping:SetFont("liaGenericFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    slot.ping:SetExpensiveShadow(1, color_black)
    slot.desc = slot:Add("DLabel")
    slot.desc:Dock(FILL)
    slot.desc:DockMargin(65, 0, 48, 0)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetTextColor(color_white)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.desc:SetFont("liaSmallFont")
    local oldTeam = client:Team()
    function slot:update()
        if not IsValid(client) or not client:getChar() or not self.character or self.character ~= client:getChar() or oldTeam ~= client:Team() then
            self:Remove()
            local i = 0
            for _, v in ipairs(parent:GetChildren()) do
                if IsValid(v.model) and v ~= self then
                    i = i + 1
                    v.Paint = paintFunctions[i % 2]
                end
            end
            return
        end

        local overrideName = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:getChar():getName()
        local name = overrideName or client:Name()
        name = name:gsub("#", "\226\128\139#")
        local model = client:GetModel()
        local skin = client:GetSkin()
        local desc = hook.Run("ShouldAllowScoreboardOverride", client, "desc") and hook.Run("GetDisplayedDescription", client, false) or client:getChar():getDesc()
        desc = desc:gsub("#", "\226\128\139#")
        self.model:setHidden(hook.Run("ShouldAllowScoreboardOverride", client, "model"))
        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local entity = self.model.Entity
        if not IsValid(entity) then return end
        if self.lastDesc ~= desc then
            self.desc:SetText(desc)
            self.lastDesc = desc
        end

        if self.lastModel ~= model or self.lastSkin ~= skin then
            self.model:SetModel(client:GetModel(), client:GetSkin())
            if (CAMI.PlayerHasAccess(client, "Staff Permissions - Can Access Scoreboard Info Out Of Staff") and CAMI.PlayerHasAccess(client, "Staff Permissions - Can Access Scoreboard Admin Options")) or (LocalPlayer() == client) or (CAMI.PlayerHasAccess(client, "Staff Permissions - Can Access Scoreboard Admin Options") and LocalPlayer():isStaffOnDuty()) then
                self.model:SetTooltip(L("sbOptions", client:Name()))
            else
                self.model:SetTooltip("You do not have access to see this information")
            end

            self.lastModel = model
            self.lastSkin = skin
        end

        timer.Simple(
            0,
            function()
                if not IsValid(entity) or not IsValid(client) then return end
                for _, v in ipairs(client:GetBodyGroups()) do
                    entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
                end
            end
        )
    end

    self.slots[#self.slots + 1] = slot
    parent:SetVisible(true)
    parent:SizeToChildren(false, true)
    parent:InvalidateLayout(true)
    local i = 0
    for _, v in ipairs(parent:GetChildren()) do
        if IsValid(v.model) then
            i = i + 1
            v.Paint = paintFunctions[i % 2]
        end
    end

    slot:update()
    return slot
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:OnRemove()
    CloseDermaMenus()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(30, 30, 30, 100)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vgui.Register("liaScoreboard", PANEL, "EditablePanel")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
