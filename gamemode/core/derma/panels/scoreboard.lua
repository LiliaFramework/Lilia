local PANEL = {}
local staffCount = 0
local staffOnDutyCount = 0
local paintFunctions = {
    [0] = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end,
    [1] = function() end
}

local function wrapTextNoBreak(text, maxWidth, font)
    surface.SetFont(font)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local lines = {}
    local currentLine = ""
    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        local w = select(1, surface.GetTextSize(testLine))
        if w > maxWidth then
            if currentLine == "" then
                table.insert(lines, word)
                currentLine = ""
            else
                table.insert(lines, currentLine)
                currentLine = word
            end
        else
            currentLine = testLine
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
            for _, client in ipairs(lia.faction.getPlayers(k)) do
                if hook.Run("ShouldShowPlayerOnScoreboard", client) == false then continue end
                if not IsValid(client.liaScoreSlot) or client.liaScoreSlot:GetParent() ~= this then
                    if IsValid(client.liaScoreSlot) then
                        client.liaScoreSlot:SetParent(this)
                    else
                        self:addPlayer(client, this)
                    end
                end
            end
        end

        local header = list:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(56)
        header:SetPaintBackground(false)
        local factionContainer = header:Add("DPanel")
        factionContainer:Dock(FILL)
        factionContainer:SetPaintBackground(false)
        local iconMat = fac.logo
        local iconWidth = ScrH() * 0.05
        local icon
        local factionName = factionContainer:Add("DLabel")
        factionName:Dock(FILL)
        factionName:SetFont("liaBigFont")
        factionName:SetTextColor(color_white)
        factionName:SetExpensiveShadow(1, color_black)
        factionName:SetText(L(fac.name))
        factionName:DockMargin(0, 0, iconMat and iconMat ~= "" and iconWidth or 0, 0)
        factionName:SetContentAlignment(5)
        if iconMat and iconMat ~= "" then
            icon = factionContainer:Add("DImage")
            icon:Dock(LEFT)
            icon:DockMargin(5, 5, 5, 5)
            icon:SetWide(iconWidth)
            icon:SetMaterial(Material(iconMat))
        end

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
    staffCount = 0
    staffOnDutyCount = 0
    for _, client in player.Iterator() do
        if client:isStaff() then staffCount = staffCount + 1 end
        if client:isStaffOnDuty() then staffOnDutyCount = staffOnDutyCount + 1 end
    end

    self.staff1:SetText(L("playersOnline", player.GetCount()) .. " | " .. L("staffOnDuty", staffOnDutyCount) .. " | " .. L("staffOnline", staffCount))
end

function PANEL:Think()
    local lp = LocalPlayer()
    if (self.nextUpdate or 0) < CurTime() then
        for k, teamPanel in ipairs(self.teams) do
            local amount = lia.faction.getPlayerCount(k)
            if k == FACTION_STAFF then
                teamPanel:SetVisible(not lia.config.get("ShowStaff", true) and lp:isStaffOnDuty() or amount > 0)
            else
                teamPanel:SetVisible(amount > 0)
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
    local lp = LocalPlayer()
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
    slot.model:SetPos(5, (rowHeight - modelSize) * 0.5)
    slot.model:SetSize(modelSize, modelSize)
    slot.model:SetModel(client:GetModel(), client:GetSkin())
    slot.model.DoClick = function()
        local menu = DermaMenu()
        local opts = {}
        hook.Run("ShowPlayerOptions", client, opts)
        for _, opt in ipairs(opts) do
            menu:AddOption(L(opt.name), opt.func):SetImage(opt.image)
        end

        menu:Open()
        RegisterDermaMenuForClose(menu)
    end

    local tooltipText = L("sbOptions", client:steamName())
    local displayTooltip = (lp:hasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or lp:hasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and lp:isStaffOnDuty()) and tooltipText or ""
    slot.model:SetTooltip(displayTooltip)
    slot.model.OnCursorEntered = function(btn) btn:SetTooltip(displayTooltip) end
    timer.Simple(0, function()
        if not IsValid(slot) then return end
        local ent = slot.model.Entity
        if IsValid(ent) then
            for _, bg in ipairs(client:GetBodyGroups()) do
                ent:SetBodygroup(bg.id, client:GetBodygroup(bg.id))
            end

            for i = 1, #client:GetMaterials() do
                ent:SetSubMaterial(i - 1, client:GetSubMaterial(i - 1))
            end
        end
    end)

    slot.name = vgui.Create("DLabel", slot)
    slot.name:SetFont("liaMediumFont")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, color_black)
    slot.name:SetText("")
    slot.desc = vgui.Create("DLabel", slot)
    slot.desc:SetAutoStretchVertical(true)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetTextColor(color_white)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.desc:SetFont("liaSmallFont")
    slot.ping = slot:Add("DLabel")
    slot.ping:SetSize(48, 64)
    slot.ping:SetText("0")
    slot.ping:SetFont("liaGenericFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    slot.ping.Think = function(p)
        if IsValid(client) then
            local pingStr = tostring(client:Ping())
            if p:GetText() ~= pingStr then
                p:SetText(pingStr)
                p:SizeToContentsX()
            end

            local sw = slot:GetWide()
            p:SetPos(sw - p:GetWide(), 0)
        end
    end

    slot.classLogo = vgui.Create("DImage", slot)
    local logoSize = rowHeight * 0.65
    local logoOffset = 10
    slot.classLogo:SetSize(logoSize, logoSize)
    slot.classLogo:SetMaterial(nil)
    slot.classLogo.Think = function()
        if IsValid(client) then
            local sw = slot:GetWide()
            local pw = slot.ping:GetWide()
            slot.classLogo:SetPos(sw - pw - logoSize - logoOffset, (slot:GetTall() - logoSize) * 0.5)
        end
    end

    slot.classLogo.Paint = function(self, w, h)
        local mat = self:GetMaterial()
        if mat then
            surface.SetMaterial(mat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    function slot:PerformLayout()
        local pingWidth = self.ping:GetWide()
        local availWidth = self:GetWide() - (modelSize + 10) - (logoSize + logoOffset) - pingWidth - 10
        self.name:SetPos(modelSize + 10, 2)
        self.name:SetWide(availWidth)
        self.desc:SetPos(modelSize + 10, 24)
        self.desc:SetWide(availWidth)
    end

    function slot:update()
        if not IsValid(client) or not client:getChar() or not self.character or self.character ~= client:getChar() or client:Team() ~= client:Team() then
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
        local availWidth = self.desc:GetWide()
        local wrapped = wrapTextNoBreak(descStr, availWidth, "liaSmallFont")
        surface.SetFont("liaSmallFont")
        local _, lh = surface.GetTextSize("W")
        local availHeight = self:GetTall() - 24
        local maxLines = math.floor(availHeight / lh)
        if #wrapped > maxLines then
            wrapped[maxLines] = wrapped[maxLines] .. " (...)"
            for i = maxLines + 1, #wrapped do
                wrapped[i] = nil
            end
        end

        local finalText = table.concat(wrapped, "\n")
        local mdl = client:GetModel()
        local skin = client:GetSkin()
        self.model:setHidden(hook.Run("ShouldAllowScoreboardOverride", client, "model"))
        if self.lastName ~= nameStr then
            self.name:SetText(nameStr)
            self.lastName = nameStr
        end

        if self.lastDesc ~= finalText then
            self.desc:SetText(finalText)
            self.desc:SizeToContentsY()
            self.lastDesc = finalText
        end

        if self.lastModel ~= mdl or self.lastSkin ~= skin then
            self.model:SetModel(mdl, skin)
            self.lastModel = mdl
            self.lastSkin = skin
        end

        local char = client:getChar()
        local classData = char and lia.class.list[char:getClass()]
        if classData and classData.logo and not hook.Run("ShouldAllowScoreboardOverride", client, "classlogo") then
            if self.lastClassLogo ~= classData.logo then
                self.classLogo:SetMaterial(Material(classData.logo))
                self.lastClassLogo = classData.logo
            end
        else
            self.classLogo:SetMaterial(nil)
        end

        local ent = self.model.Entity
        timer.Simple(0, function()
            if IsValid(ent) and IsValid(client) then
                for _, bg in ipairs(client:GetBodyGroups()) do
                    ent:SetBodygroup(bg.id, client:GetBodygroup(bg.id))
                end
            end
        end)

        self:PerformLayout()
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

local borderColorSolid = Color(0, 0, 0, 200)
local borderColorBlur = Color(0, 0, 0, 150)
local backgroundColorFallback = Color(50, 50, 50, 255)
local surfaceSetDrawColor, surfaceDrawRect, surfaceDrawOutlinedRect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
local function PaintPanel(x, y, w, h)
    surfaceSetDrawColor(0, 0, 0, 255)
    surfaceDrawOutlinedRect(x, y, w, h)
    surfaceSetDrawColor(0, 0, 0, 150)
    surfaceDrawRect(x + 1, y + 1, w - 2, h - 2)
end

function PANEL:Paint(w, h)
    local useSolid = lia.config.get("UseSolidBackground", false)
    if useSolid then
        local bg = lia.config.get("ScoreboardBackgroundColor", backgroundColorFallback)
        surface.SetDrawColor(bg)
        surface.DrawRect(0, 0, w, h)
    else
        lia.util.drawBlur(self, 10)
        PaintPanel(0, 0, w, h)
    end

    local bColor = useSolid and borderColorSolid or borderColorBlur
    surface.SetDrawColor(bColor.r, bColor.g, bColor.b, bColor.a)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaScoreboard", PANEL, "EditablePanel")
