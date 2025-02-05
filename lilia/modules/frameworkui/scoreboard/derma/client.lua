local PANEL = {}
local StaffCount = 0
local StaffOnDutyCount = 0
local paintFunctions = {}
paintFunctions[0] = function(_, w, h)
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 0, w, h)
end

paintFunctions[1] = function() end
local function wrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""
    for _, word in ipairs(words) do
        local testLine = (currentLine == "" and word) or (currentLine .. " " .. word)
        local textW = select(1, surface.GetTextSize(testLine))
        if textW <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= "" then table.insert(lines, currentLine) end
            currentLine = word
        end
    end

    if currentLine ~= "" then table.insert(lines, currentLine) end
    return lines
end

function PANEL:Init()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    lia.gui.score = self
    self:SetSize(ScrW() * lia.config.get("sbWidth", 0.35), ScrH() * lia.config.get("sbHeight", 0.65))
    self:Center()
    if lia.config.get("DisplayServerName", false) then
        self.serverName = self:Add("DLabel")
        self.serverName:SetText(GetHostName())
        self.serverName:SetFont("liaBigFont")
        self.serverName:SetContentAlignment(5)
        self.serverName:SetTextColor(color_white)
        self.serverName:SetExpensiveShadow(1, color_black)
        self.serverName:Dock(TOP)
        self.serverName:SizeToContentsY()
        self.serverName.Paint = function(_, w, h)
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(1, 0, 1, 0)
    self.scroll.VBar:SetWide(0)
    self.layout = self.scroll:Add("DListLayout")
    self.layout:Dock(TOP)
    self.teams = {}
    self.slots = {}
    for k, fac in ipairs(lia.faction.indices) do
        local factionColor = team.GetColor(k)
        local r, g, b = factionColor.r, factionColor.g, factionColor.b
        local list = self.layout:Add("DListLayout")
        list:Dock(TOP)
        list:SetTall(ScrH() * 0.08)
        list.Think = function(this)
            for _, ply in ipairs(lia.faction.getPlayers(k)) do
                if hook.Run("ShouldShowPlayerOnScoreboard", ply) == false then continue end
                if not IsValid(ply.liaScoreSlot) or ply.liaScoreSlot:GetParent() ~= this then
                    if IsValid(ply.liaScoreSlot) then
                        ply.liaScoreSlot:SetParent(this)
                    else
                        self:addPlayer(ply, this)
                    end
                end
            end
        end

        local header = list:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(ScrH() * 0.08)
        header:SetPaintBackground(false)
        local factionContainer = header:Add("DPanel")
        factionContainer:Dock(FILL)
        factionContainer:SetPaintBackground(false)
        local icon_material = fac.logo
        local iconWidth = ScrH() * 0.08
        local icon
        if icon_material and icon_material ~= "" then
            icon = factionContainer:Add("DImage")
            icon:Dock(RIGHT)
            icon:SetWide(iconWidth)
            icon:SetMaterial(Material(icon_material))
        end

        local factionName = factionContainer:Add("DLabel")
        factionName:Dock(FILL)
        factionName:SetFont("liaBigFont")
        factionName:SetTextColor(color_white)
        factionName:SetExpensiveShadow(1, color_black)
        factionName:SetText(L(fac.name))
        factionName:SetContentAlignment(5)
        factionName:DockMargin((icon_material and icon_material ~= "" and string.len(L(fac.name)) * 5) or 0, 0, 0, 0)
        header.Paint = function(_, w, h)
            surface.SetDrawColor(r, g, b, 30)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(r, g, b, 140)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        self.teams[k] = list
    end

    self.staff1 = self:Add("DLabel")
    self.staff1:SetText(L("playersOnline", 0) .. " | " .. L("staffOnDuty", 0) .. " | " .. L("staffOnline", 0))
    self.staff1:SetFont("liaMediumFont")
    self.staff1:SetContentAlignment(5)
    self.staff1:SetTextColor(color_white)
    self.staff1:SetExpensiveShadow(1, color_black)
    self.staff1:Dock(BOTTOM)
    self.staff1:SizeToContentsY()
    self.staff1.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:UpdateStaff()
    StaffCount = 0
    StaffOnDutyCount = 0
    for _, target in player.Iterator() do
        if target:isStaff() then StaffCount = StaffCount + 1 end
        if target:isStaffOnDuty() then StaffOnDutyCount = StaffOnDutyCount + 1 end
    end

    self.staff1:SetText(L("playersOnline", player.GetCount()) .. " | " .. L("staffOnDuty", StaffOnDutyCount) .. " | " .. L("staffOnline", StaffCount))
end

function PANEL:Think()
    local lp = LocalPlayer()
    if (self.nextUpdate or 0) < CurTime() then
        for k, v in ipairs(self.teams) do
            local amount = lia.faction.getPlayerCount(k)
            if k == FACTION_STAFF then
                v:SetVisible((not lia.config.get("ShowStaff", true) and lp:isStaffOnDuty()) or amount > 0)
            else
                v:SetVisible(amount > 0)
            end

            self.layout:InvalidateLayout()
        end

        for _, slot in pairs(self.slots) do
            if IsValid(slot) then slot:update() end
        end

        if system.GetCountry() == "FR" and input.IsKeyDown(KEY_W) or system.GetCountry() ~= "FR" and input.IsKeyDown(KEY_Z) then self:Init() end
        self.nextUpdate = CurTime() + 0.1
        self:UpdateStaff()
    end
end

function PANEL:addPlayer(client, parent)
    if not client:getChar() or not IsValid(parent) then return end
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    slot:SetTall(ScrH() * 0.07)
    slot:DockMargin(0, 0, 0, 0)
    slot.character = client:getChar()
    client.liaScoreSlot = slot
    local rowHeight = slot:GetTall()
    local modelSize = rowHeight * 0.9
    slot.Paint = function() end
    slot.model = vgui.Create("liaSpawnIcon", slot)
    slot.model:SetPos(4, (rowHeight - modelSize) * 0.5)
    slot.model:SetSize(modelSize, modelSize)
    slot.model:SetModel(client:GetModel(), client:GetSkin())
    slot.model.DoClick = function()
        local menu = DermaMenu()
        local options = {}
        hook.Run("ShowPlayerOptions", client, options)
        for _, option in ipairs(options) do
            menu:AddOption(L(option.name), option.func):SetImage(option.image)
        end

        menu:Open()
        RegisterDermaMenuForClose(menu)
    end

    slot.model:SetTooltip(L("sbOptions", client:Name()))
    timer.Simple(0, function()
        if not IsValid(slot) then return end
        local entity = slot.model.Entity
        if IsValid(entity) then
            for _, bg in ipairs(client:GetBodyGroups()) do
                entity:SetBodygroup(bg.id, client:GetBodygroup(bg.id))
            end

            for matIndex, _ in ipairs(client:GetMaterials()) do
                entity:SetSubMaterial(matIndex - 1, client:GetSubMaterial(matIndex - 1))
            end
        end
    end)

    slot.name = vgui.Create("DLabel", slot)
    slot.name:SetPos(modelSize + 10, 2)
    slot.name:SetSize(200, 20)
    slot.name:SetFont("liaMediumFont")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, color_black)
    slot.name:SetText("")
    slot.desc = vgui.Create("DLabel", slot)
    slot.desc:SetPos(modelSize + 10, 24)
    slot.desc:SetAutoStretchVertical(true)
    slot.desc:SetWrap(false)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetTextColor(color_white)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.desc:SetFont("liaSmallFont")
    slot.ping = vgui.Create("DLabel", slot)
    slot.ping:SetWide(60)
    slot.ping:SetTall(rowHeight)
    slot.ping:SetPos(self:GetWide() - slot.ping:GetWide() - 4, 0)
    slot.ping:SetFont("liaMediumFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    slot.ping:SetExpensiveShadow(1, color_black)
    slot.ping:SetText("0")
    slot.ping.Think = function(lbl)
        if IsValid(client) then
            local ping = client:Ping()
            if lbl:GetText() ~= ping then lbl:SetText(ping) end
        end
    end

    local class = lia.class.list[client:getChar():getClass()]
    if class and class.logo and not hook.Run("ShouldAllowScoreboardOverride", client, "classlogo") then
        local logoSize = rowHeight * 0.9
        slot.logo = vgui.Create("DPanel", slot)
        slot.logo:SetSize(logoSize, logoSize)
        local xPos = slot.ping.x - logoSize + 50
        slot.logo:SetPos(xPos, (rowHeight - logoSize) * 0.5)
        slot.logo.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material(class.logo))
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    local oldTeam = client:Team()
    function slot:PerformLayout()
        local rightEdge = self.ping.x - 4
        if IsValid(self.logo) then rightEdge = self.logo.x - 4 end
        self.desc:SetWide(rightEdge - (modelSize + 10))
    end

    function slot:update()
        if not IsValid(client) or not client:getChar() or not self.character or self.character ~= client:getChar() or oldTeam ~= client:Team() then
            self:Remove()
            local i = 0
            for _, child in ipairs(parent:GetChildren()) do
                if IsValid(child.model) and child ~= self then
                    i = i + 1
                    local basePaint = paintFunctions[i % 2]
                    child.Paint = function(s, w, h)
                        basePaint(s, w, h)
                        surface.SetDrawColor(255, 255, 255, 50)
                        surface.DrawLine(0, h - 1, w, h - 1)
                    end
                end
            end
            return
        end

        local overrideName = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:getChar():getName()
        local nameStr = (overrideName or client:Name()):gsub("#", "\226\128\139#")
        local overrideDesc = hook.Run("ShouldAllowScoreboardOverride", client, "desc") and hook.Run("GetDisplayedDescription", client, false) or client:getChar():getDesc()
        local descStr = (overrideDesc or ""):gsub("#", "\226\128\139#")
        if string.len(descStr) > 250 then
            local subStr = string.sub(descStr, 1, 250)
            local lastSpace = subStr:match(".*()%s+")
            if lastSpace then subStr = subStr:sub(1, lastSpace - 1) end
            descStr = subStr .. " (...)"
        end

        local availWidth = self.desc:GetWide()
        local wrapped = wrapText(descStr, "liaSmallFont", availWidth)
        local finalText = table.concat(wrapped, "\n")
        local model = client:GetModel()
        local skin = client:GetSkin()
        self.model:setHidden(hook.Run("ShouldAllowScoreboardOverride", client, "model"))
        if self.lastName ~= nameStr then
            self.name:SetText(nameStr)
            self.lastName = nameStr
        end

        if self.lastDesc ~= finalText then
            self.desc:SetText(finalText)
            self.lastDesc = finalText
        end

        if self.lastModel ~= model or self.lastSkin ~= skin then
            self.model:SetModel(model, skin)
            local lp = LocalPlayer()
            if lp:hasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or (lp:hasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and lp:isStaffOnDuty()) then
                self.model:SetTooltip(L("sbOptions", client:Name()))
            else
                self.model:SetTooltip()
            end

            self.lastModel = model
            self.lastSkin = skin
        end

        local entity = self.model.Entity
        timer.Simple(0, function()
            if IsValid(entity) and IsValid(client) then
                for _, bg in ipairs(client:GetBodyGroups()) do
                    entity:SetBodygroup(bg.id, client:GetBodygroup(bg.id))
                end
            end
        end)
    end

    self.slots[#self.slots + 1] = slot
    parent:SetVisible(true)
    parent:SizeToChildren(false, true)
    parent:InvalidateLayout(true)
    local i = 0
    for _, child in ipairs(parent:GetChildren()) do
        if IsValid(child.model) then
            i = i + 1
            local basePaint = paintFunctions[i % 2]
            child.Paint = function(s, w, h)
                basePaint(s, w, h)
                surface.SetDrawColor(255, 255, 255, 50)
                surface.DrawLine(0, h - 1, w, h - 1)
            end
        end
    end

    slot:update()
    return slot
end

function PANEL:OnRemove()
    CloseDermaMenus()
end

function PANEL:Paint(w, h)
    local backgroundColor = lia.config.get("UseSolidBackground", false) and (lia.config.get("ScoreboardBackgroundColor", Color(255, 100, 100, 255)) or Color(50, 50, 50, 255)) or Color(30, 30, 30, 100)
    local borderColor = Color(0, 0, 0, lia.config.get("UseSolidBackground", false) and 200 or 150)
    if lia.config.get("UseSolidBackground", false) then
        surface.SetDrawColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        surface.DrawOutlinedRect(0, 0, w, h)
    else
        lia.util.drawBlur(self, 10)
        surface.SetDrawColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

vgui.Register("liaScoreboard", PANEL, "EditablePanel")
