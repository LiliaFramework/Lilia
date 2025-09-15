﻿local PANEL = {}
local rowPaint = {
    [0] = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end,
    [1] = function() end
}

local function wrap(text, maxWidth, font)
    surface.SetFont(font)
    local words, lines, current = {}, {}, ""
    for w in text:gmatch("%S+") do
        words[#words + 1] = w
    end

    for _, w in ipairs(words) do
        local trial = current == "" and w or current .. " " .. w
        if select(1, surface.GetTextSize(trial)) > maxWidth then
            if current == "" then
                lines[#lines + 1] = w
            else
                lines[#lines + 1] = current
                current = w
            end
        else
            current = trial
        end
    end

    if current ~= "" then lines[#lines + 1] = current end
    return lines
end

function PANEL:ApplyConfig()
    local screenW, screenH = ScrW(), ScrH()
    local w, h = screenW * lia.config.get("sbWidth", 0.35), screenH * lia.config.get("sbHeight", 0.65)
    self:SetSize(w, h)
    local dock = string.lower(lia.config.get("sbDock", "center"))
    if dock == "left" then
        self:SetPos(0, (screenH - h) * 0.5)
    elseif dock == "right" then
        self:SetPos(screenW - w, (screenH - h) * 0.5)
    else
        self:Center()
    end
end

function PANEL:Init()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    lia.gui.score = self
    hook.Run("ScoreboardOpened", self)
    self:ApplyConfig()
    local header = self:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(80)
    header:DockMargin(0, 0, 0, 5)
    header.Paint = function() end
    local serverName = header:Add("DLabel")
    serverName:Dock(TOP)
    serverName:SetText(GetHostName())
    serverName:SetFont("liaBigFont")
    serverName:SetContentAlignment(5)
    serverName:SetTextColor(color_white)
    serverName:SetExpensiveShadow(1, color_black)
    serverName:SizeToContentsY()
    local stats = header:Add("DPanel")
    stats:Dock(BOTTOM)
    stats:DockMargin(10, 15, 10, 0)
    stats:SetTall(24)
    stats.Paint = function() end
    local staffOnline = stats:Add("DLabel")
    staffOnline:Dock(LEFT)
    staffOnline:DockMargin(0, 0, 10, 0)
    staffOnline:SetFont("liaSmallFont")
    staffOnline:SetTextColor(color_white)
    staffOnline:SetExpensiveShadow(1, color_black)
    staffOnline:SetContentAlignment(4)
    local playersOnline = stats:Add("DLabel")
    playersOnline:Dock(FILL)
    playersOnline:SetFont("liaSmallFont")
    playersOnline:SetTextColor(color_white)
    playersOnline:SetExpensiveShadow(1, color_black)
    playersOnline:SetContentAlignment(5)
    local staffOnDuty = stats:Add("DLabel")
    staffOnDuty:Dock(RIGHT)
    staffOnDuty:DockMargin(10, 0, 0, 0)
    staffOnDuty:SetFont("liaSmallFont")
    staffOnDuty:SetTextColor(color_white)
    staffOnDuty:SetExpensiveShadow(1, color_black)
    staffOnDuty:SetContentAlignment(6)
    local scroll = self:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(1, 0, 1, 0)
    scroll.VBar:SetWide(0)
    local layout = scroll:Add("DListLayout")
    layout:Dock(TOP)
    self.staffOnline, self.playersOnline, self.staffOnDuty = staffOnline, playersOnline, staffOnDuty
    self.scroll, self.layout = scroll, layout
    self.playerSlots, self.factionLists = {}, {}
    for facID, facData in ipairs(lia.faction.indices) do
        local facColor = team.GetColor(facID)
        local facCont = layout:Add("DListLayout")
        facCont:Dock(TOP)
        local facHeader = facCont:Add("DPanel")
        facHeader:Dock(TOP)
        facHeader:SetTall(40)
        facHeader.Paint = function(_, ww, hh)
            surface.SetDrawColor(facColor.r, facColor.g, facColor.b, 80)
            surface.DrawRect(0, 0, ww, hh)
            surface.SetDrawColor(facColor.r, facColor.g, facColor.b, 200)
            surface.DrawOutlinedRect(0, 0, ww, hh)
        end

        local facInner = facHeader:Add("DPanel")
        facInner:Dock(FILL)
        if facData.logo and facData.logo ~= "" then
            local img = facInner:Add("DImage")
            img:Dock(LEFT)
            img:DockMargin(5, 5, 5, 5)
            img:SetWide(30)
            img:SetMaterial(Material(facData.logo))
        end

        local lbl = facInner:Add("DLabel")
        lbl:SetFont("liaMediumFont")
        lbl:SetTextColor(color_white)
        lbl:SetExpensiveShadow(1, color_black)
        lbl:SetText(L(facData.name))
        lbl:SizeToContents()
        lbl:SetContentAlignment(5)
        facHeader.PerformLayout = function(_, ww, hh)
            lbl:SizeToContents()
            lbl:SetPos((ww - lbl:GetWide()) * 0.5, (hh - lbl:GetTall()) * 0.5)
        end

        facCont.noClass = facCont:Add("DListLayout")
        facCont.noClass:Dock(TOP)
        facCont.classLists = {}
        if lia.config.get("ClassHeaders", true) and lia.class and lia.class.list then
            for clsID, clsData in pairs(lia.class.list) do
                if clsData.faction ~= facID then continue end
                if clsData.scoreboardHidden then
                    local lst = facCont:Add("DListLayout")
                    lst:Dock(TOP)
                    facCont.classLists[clsID] = lst
                    continue
                end

                local cat = facCont:Add("DCollapsibleCategory")
                cat:SetLabel("")
                cat:SetExpanded(true)
                cat.Header:SetTall(28)
                cat.Header.Paint = function(_, ww, hh)
                    local c = clsData.color or facColor
                    surface.SetDrawColor(c.r, c.g, c.b, 80)
                    surface.DrawRect(0, 0, ww, hh)
                end

                if clsData.logo and clsData.logo ~= "" then
                    local ico = cat.Header:Add("DImage")
                    ico:Dock(LEFT)
                    ico:DockMargin(5, 4, 5, 4)
                    ico:SetWide(20)
                    ico:SetMaterial(Material(clsData.logo))
                end

                local hlbl = cat.Header:Add("DLabel")
                hlbl:Dock(LEFT)
                hlbl:SetFont("liaMediumFont")
                hlbl:SetTextColor(color_white)
                hlbl:SetExpensiveShadow(1, color_black)
                hlbl:SetText(L(clsData.name))
                hlbl:SizeToContentsX()
                if not (clsData.logo and clsData.logo ~= "") then hlbl:DockMargin(5, 0, 0, 0) end
                local lst = vgui.Create("DListLayout", cat)
                cat:SetContents(lst)
                facCont.classLists[clsID] = lst
            end
        end

        self.factionLists[facID] = facCont
    end
end

function PANEL:updateStaff()
    local total, duty = 0, 0
    for _, ply in player.Iterator() do
        if ply:isStaff() then total = total + 1 end
        if ply:isStaffOnDuty() then duty = duty + 1 end
    end

    local current, maximum = player.GetCount(), game.MaxPlayers()
    self.staffOnline:SetText(L("staffOnline", total))
    self.playersOnline:SetText(L("playersOnline", current .. "/" .. maximum))
    self.staffOnDuty:SetText(L("staffOnDuty", duty))
    self.staffOnline:SizeToContentsX()
    self.playersOnline:SizeToContentsX()
    self.staffOnDuty:SizeToContentsX()
end

function PANEL:Think()
    if (self.nextUpdate or 0) > CurTime() then return end
    for _, ply in player.Iterator() do
        if hook.Run("ShouldShowPlayerOnScoreboard", ply) == false then continue end
        local char = ply:getChar()
        if not char then continue end
        local facCont = self.factionLists[ply:Team()]
        local parent = facCont.classLists[char:getClass()] or facCont.noClass
        if not IsValid(ply.liaScoreSlot) then
            self:addPlayer(ply, parent)
        elseif ply.liaScoreSlot:GetParent() ~= parent then
            ply.liaScoreSlot:SetParent(parent)
            parent:InvalidateLayout(true)
        end
    end

    for _, facCont in pairs(self.factionLists) do
        local showFaction = facCont.noClass:ChildCount() > 0
        for _, lst in pairs(facCont.classLists) do
            local cat, hasPlayers = lst:GetParent(), lst:ChildCount() > 0
            cat:SetVisible(hasPlayers)
            if hasPlayers then showFaction = true end
        end

        facCont:SetVisible(showFaction)
    end

    for _, slot in ipairs(self.playerSlots) do
        if IsValid(slot) then slot:update() end
    end

    self:updateStaff()
    self.nextUpdate = CurTime() + 0.1
end

function PANEL:addPlayer(ply, parent)
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    local height = ScrH() * 0.07
    slot:SetTall(height)
    slot.Paint = function() end
    slot.character = ply:getChar()
    ply.liaScoreSlot = slot
    local margin, iconSize = 5, height * 0.9
    slot.model = slot:Add("liaSpawnIcon")
    slot.model:SetPos(margin, (height - iconSize) * 0.5)
    slot.model:SetSize(iconSize, iconSize)
    slot.model:SetModel(ply:GetModel(), ply:GetSkin())
    slot.model:SetCamPos(Vector(0, 0, 55))
    slot.model:SetLookAt(Vector(0, 0, 0))
    slot.model.LayoutEntity = function(_, ent)
        ent:SetAngles(Angle(0, 0, 0))
        slot.model:RunAnimation()
    end

    slot.lastHidden = hook.Run("ShouldAllowScoreboardOverride", ply, "model")
    slot.model:setHidden(slot.lastHidden)
    local initialOpts = {}
    hook.Run("ShowPlayerOptions", ply, initialOpts)
    if #initialOpts > 0 then slot.model:SetTooltip(L("sbOptions")) end
    slot.model.DoClick = function()
        local opts = {}
        hook.Run("ShowPlayerOptions", ply, opts)
        if #opts > 0 then
            local menu = DermaMenu()
            for _, o in ipairs(opts) do
                menu:AddOption(L(o.name), o.func):SetImage(o.image)
            end

            menu:Open()
            RegisterDermaMenuForClose(menu)
        end
    end

    timer.Simple(0, function()
        if not IsValid(slot.model) or not IsValid(slot.model.Entity) then return end
        for _, bg in ipairs(ply:GetBodyGroups()) do
            slot.model.Entity:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
        end

        for i in ipairs(ply:GetMaterials()) do
            slot.model.Entity:SetSubMaterial(i - 1, ply:GetSubMaterial(i - 1))
        end

        hook.Run("ModifyScoreboardModel", slot.model.Entity, ply)
    end)

    slot.name = vgui.Create("DLabel", slot)
    slot.name:SetFont("liaMediumFont")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, color_black)
    slot.desc = vgui.Create("DLabel", slot)
    slot.desc:SetAutoStretchVertical(true)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetFont("liaSmallFont")
    slot.desc:SetTextColor(color_white)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.ping = vgui.Create("DLabel", slot)
    slot.ping:SetFont("liaGenericFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    local logoSize, logoOffset = height * 0.65, 10
    slot.classLogo = vgui.Create("DImage", slot)
    slot.classLogo:SetSize(logoSize, logoSize)
    function slot:layout()
        self.ping:SizeToContents()
        local pingW, totalW = self.ping:GetWide(), self:GetWide()
        local hasLogo = lia.config.get("ClassLogo", false) and self.classLogo:GetMaterial() and not self.hideLogo
        local extra = hasLogo and logoSize + logoOffset or 0
        local availW = totalW - (iconSize + margin * 2) - extra - pingW - margin
        self.name:SetPos(iconSize + margin * 2, 2)
        self.name:SetWide(availW)
        self.desc:SetPos(iconSize + margin * 2, 24)
        self.desc:SetWide(availW)
        if hasLogo then
            self.classLogo:SetVisible(true)
            self.classLogo:SetPos(totalW - pingW - logoSize - logoOffset, (height - logoSize) * 0.5)
        else
            self.classLogo:SetVisible(false)
        end

        self.ping:SetPos(totalW - pingW, (height - self.ping:GetTall()) * 0.5)
    end

    slot.ping.Think = function(lbl)
        if not IsValid(ply) then return end
        local txt = tostring(ply:Ping())
        if lbl:GetText() ~= txt then
            lbl:SetText(txt)
            lbl:SizeToContentsX()
            slot:layout()
        end
    end

    function slot:update()
        if not IsValid(ply) then
            hook.Run("ScoreboardRowRemoved", self, ply)
            self:Remove()
            return
        end

        local char = ply:getChar()
        if not char or char ~= self.character then
            hook.Run("ScoreboardRowRemoved", self, ply)
            self:Remove()
            return
        end

        local overrideModel = hook.Run("ShouldAllowScoreboardOverride", ply, "model")
        if self.lastHidden ~= overrideModel then
            slot.model:setHidden(overrideModel)
            self.lastHidden = overrideModel
        end

        local name = hook.Run("ShouldAllowScoreboardOverride", ply, "name") and hook.Run("GetDisplayedName", ply) or char:getName()
        name = name:gsub("#", "\226\128\139#")
        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local desc = hook.Run("ShouldAllowScoreboardOverride", ply, "desc") and hook.Run("GetDisplayedDescription", ply, false) or char:getDesc()
        desc = desc:gsub("#", "\226\128\139#")
        local wrapped = wrap(desc, self.desc:GetWide(), "liaSmallFont")
        surface.SetFont("liaSmallFont")
        local _, lineH = surface.GetTextSize("W")
        local maxLines = math.floor((height - 24) / lineH)
        if #wrapped > maxLines then
            wrapped[maxLines] = wrapped[maxLines] .. " (...)"
            for i = maxLines + 1, #wrapped do
                wrapped[i] = nil
            end
        end

        local finalDesc = table.concat(wrapped, "\n")
        if self.lastDesc ~= finalDesc then
            self.desc:SetText(finalDesc)
            self.lastDesc = finalDesc
        end

        local mdl, sk = ply:GetModel(), ply:GetSkin()
        if self.lastModel ~= mdl or self.lastSkin ~= sk then
            slot.model:SetModel(mdl, sk)
            for _, bg in ipairs(ply:GetBodyGroups()) do
                slot.model.Entity:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
            end

            hook.Run("ModifyScoreboardModel", slot.model.Entity, ply)
            self.lastModel, self.lastSkin = mdl, sk
        end

        local clsData = lia.class.list[char:getClass()]
        local showLogo = lia.config.get("ClassLogo", false) and clsData and not clsData.scoreboardHidden and clsData.logo and clsData.logo ~= ""
        if showLogo then
            local logoMat = clsData.logo
            if self.lastClassLogo ~= logoMat then
                self.classLogo:SetMaterial(Material(logoMat))
                self.lastClassLogo = logoMat
            end

            self.hideLogo = false
        else
            self.classLogo:SetMaterial(nil)
            self.lastClassLogo = nil
            self.hideLogo = true
        end

        slot:layout()
    end

    parent:InvalidateLayout(true)
    self.playerSlots[#self.playerSlots + 1] = slot
    local idx = 0
    for _, child in ipairs(parent:GetChildren()) do
        if IsValid(child.model) then
            idx = idx + 1
            local fn = rowPaint[idx % 2]
            child.Paint = function(s, w, h)
                fn(s, w, h)
                surface.SetDrawColor(255, 255, 255, 50)
                surface.DrawLine(0, h - 1, w, h - 1)
            end
        end
    end

    slot:update()
    hook.Run("ScoreboardRowCreated", slot, ply)
end

function PANEL:Paint(w, h)
    if lia.config.get("UseSolidBackground", false) then
        local bg = lia.config.get("ScoreboardBackgroundColor", {
            r = 50,
            g = 50,
            b = 50,
            a = 255
        })

        surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
        surface.DrawRect(0, 0, w, h)
    else
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(1, 1, w - 2, h - 2)
    end

    local alpha = lia.config.get("UseSolidBackground", false) and 200 or 150
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:OnRemove()
    hook.Run("ScoreboardClosed", self)
    CloseDermaMenus()
end

vgui.Register("liaScoreboard", PANEL, "EditablePanel")
