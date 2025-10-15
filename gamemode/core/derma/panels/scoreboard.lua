local PANEL = {}
local rowPaint = {
    [0] = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawRect(0, 0, w, h)
    end,
    [1] = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 80)
        surface.DrawRect(0, 0, w, h)
    end
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
    self:ShowCloseButton(false)
    local header = self:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(40)
    header:DockMargin(0, 0, 0, 5)
    header.Paint = function() end
    local serverName = header:Add("DLabel")
    serverName:Dock(TOP)
    serverName:DockMargin(0, -5, 0, 0)
    serverName:SetText(GetHostName())
    serverName:SetFont("liaMediumFont")
    serverName:SetContentAlignment(5)
    serverName:SetTextColor(color_white)
    serverName:SetExpensiveShadow(1, color_black)
    serverName:SizeToContentsY()
    local serverIcon = header:Add("DImage")
    serverIcon:Dock(RIGHT)
    serverIcon:DockMargin(15, -20, 20, 7)
    serverIcon:SetWide(60)
    serverIcon:SetTall(32)
    serverIcon.PerformLayout = function(icon)
        icon:SetWide(60)
        icon:SetTall(32)
    end

    serverIcon:SetVisible(false)
    local serverIconPath = lia.config.get("ServerLogo", "")
    local scoreboardLogoEnabled = lia.config.get("ScoreboardLogoEnabled", true)
    if scoreboardLogoEnabled and serverIconPath and serverIconPath ~= "" then
        local material = Material(serverIconPath)
        if material then
            serverIcon:SetMaterial(material)
            serverIcon:SetVisible(true)
        end
    end

    local scroll = self:Add("liaScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(1, 0, 1, 0)
    scroll.VBar:SetWide(0)
    local layout = scroll:Add("DListLayout")
    layout:Dock(TOP)
    self.scroll, self.layout = scroll, layout
    self.playerSlots, self.factionLists = {}, {}
    for facID, facData in ipairs(lia.faction.indices) do
        local facColor = team.GetColor(facID)
        local facCat = layout:Add("DCollapsibleCategory")
        facCat:SetLabel("")
        facCat:SetExpanded(true)
        if IsValid(facCat.Header) then
            facCat.Header:SetTall(50)
            facCat.Header.Paint = function(_, ww, hh)
                local radius = 8
                lia.derma.rect(0, 0, ww, hh):Rad(radius):Color(Color(facColor.r, facColor.g, facColor.b, 80)):Shape(lia.derma.SHAPE_IOS):Draw()
                lia.derma.rect(0, 0, ww, hh):Rad(radius):Color(Color(facColor.r, facColor.g, facColor.b, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
            end
        end

        if facData.logo and facData.logo ~= "" and IsValid(facCat.Header) then
            local img = facCat.Header:Add("DImage")
            img:Dock(LEFT)
            img:DockMargin(5, 5, 5, 5)
            img:SetWide(45)
            img:SetMaterial(Material(facData.logo))
        end

        local lbl
        if IsValid(facCat.Header) then
            lbl = facCat.Header:Add("DLabel")
        else
            lbl = vgui.Create("DLabel")
        end

        lbl:SetFont("liaMediumFont")
        lbl:SetTextColor(color_white)
        lbl:SetExpensiveShadow(1, color_black)
        lbl:SetText(L(facData.name))
        lbl:SizeToContents()
        lbl:SetContentAlignment(5)
        if IsValid(facCat.Header) then
            facCat.Header.PerformLayout = function(_, ww, hh)
                lbl:SizeToContents()
                lbl:SetPos((ww - lbl:GetWide()) * 0.5, (hh - lbl:GetTall()) * 0.5)
            end
        end

        local facCont = vgui.Create("DListLayout", facCat)
        facCat:SetContents(facCont)
        facCont.noClass = facCont:Add("DListLayout")
        facCont.noClass:Dock(TOP)
        facCont.classLists = {}
        if lia.config.get("ClassHeaders", true) and lia.config.get("ClassDisplay", true) and lia.class and lia.class.list then
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
                if IsValid(cat.Header) then
                    cat.Header:SetTall(30)
                    cat.Header.Paint = function(_, ww, hh)
                        local c = clsData.color or facColor
                        local radius = 6
                        lia.derma.rect(0, 0, ww, hh):Rad(radius):Color(Color(c.r, c.g, c.b, 80)):Shape(lia.derma.SHAPE_IOS):Draw()
                    end
                end

                if clsData.logo and clsData.logo ~= "" and IsValid(cat.Header) then
                    local ico = cat.Header:Add("DImage")
                    ico:Dock(RIGHT)
                    ico:DockMargin(5, 4, 5, 4)
                    ico:SetWide(20)
                    ico:SetMaterial(Material(clsData.logo))
                end

                local hlbl
                if IsValid(cat.Header) then
                    hlbl = cat.Header:Add("DLabel")
                else
                    hlbl = vgui.Create("DLabel")
                end

                hlbl:SetFont("liaSmallFont")
                hlbl:SetTextColor(color_white)
                hlbl:SetExpensiveShadow(1, color_black)
                hlbl:SetText(L(clsData.name))
                hlbl:SizeToContents()
                hlbl:SetContentAlignment(4)
                if IsValid(cat.Header) then
                    cat.Header.PerformLayout = function(_, _, hh)
                        hlbl:SizeToContents()
                        hlbl:SetPos(10, (hh - hlbl:GetTall()) * 0.5)
                    end
                end

                local lst = vgui.Create("DListLayout", cat)
                cat:SetContents(lst)
                facCont.classLists[clsID] = lst
            end
        end

        self.factionLists[facID] = facCont
    end
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

        local facCat = facCont:GetParent()
        if IsValid(facCat) then facCat:SetVisible(showFaction) end
    end

    for _, slot in ipairs(self.playerSlots) do
        if IsValid(slot) then slot:update() end
    end

    self.nextUpdate = CurTime() + 0.1
end

function PANEL:addPlayer(ply, parent)
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    local height = ScrH() * 0.08
    slot:SetTall(height)
    slot.Paint = function() end
    slot.character = ply:getChar()
    ply.liaScoreSlot = slot
    local margin, iconSize = 5, height * 0.75
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
            local frame = vgui.Create("liaFrame")
            frame:SetSize(300, 450)
            frame:Center()
            frame:MakePopup()
            frame:SetTitle(L("sbOptions"))
            frame:LiteMode()
            local scrollPanel = vgui.Create("liaScrollPanel", frame)
            scrollPanel:Dock(FILL)
            scrollPanel:DockMargin(5, 5, 5, 5)
            for _, o in ipairs(opts) do
                local button = vgui.Create("liaButton", scrollPanel)
                button:Dock(TOP)
                button:DockMargin(5, 5, 5, 0)
                button:SetTall(32)
                button:SetText("")
                button.Paint = function(s, w, h)
                    if s:IsHovered() then
                        lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.button_hovered):Shape(lia.derma.SHAPE_IOS):Draw()
                    else
                        lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.button):Shape(lia.derma.SHAPE_IOS):Draw()
                    end

                    local localIconSize = 16
                    if o.image then
                        surface.SetDrawColor(lia.color.theme.text)
                        surface.SetMaterial(Material(o.image))
                        surface.DrawTexturedRect(8, (h - localIconSize) / 2, localIconSize, localIconSize)
                    end

                    draw.SimpleText(L(o.name), "liaSmallFont", 32, h / 2, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                button.DoClick = function()
                    o.func()
                    frame:Remove()
                end
            end
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
    slot.ping:SetFont("LiliaFont.16")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    local logoSize, logoOffset = height * 0.6, 8
    slot.classLogo = vgui.Create("DImage", slot)
    slot.classLogo:SetSize(logoSize, logoSize)
    function slot:layout()
        self.ping:SizeToContents()
        local pingW, totalW = self.ping:GetWide(), self:GetWide()
        local hasLogo = lia.config.get("ClassLogo", false) and self.classLogo:GetMaterial() and not self.hideLogo
        local extra = hasLogo and logoSize + logoOffset or 0
        local availW = totalW - (iconSize + margin * 2) - extra - pingW - margin
        self.name:SetPos(iconSize + margin * 2, height * 0.08)
        self.name:SetWide(availW)
        self.name:SetTall(height * 0.4)
        self.desc:SetPos(iconSize + margin * 2, height * 0.52)
        self.desc:SetWide(availW - 5)
        self.desc:SetTall(height * 0.4)
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
        local maxLines = 2
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

function PANEL:Update()
    if IsValid(self) then
        self:Remove()
        vgui.Create("liaScoreboard")
    end
end

function PANEL:OnRemove()
    hook.Run("ScoreboardClosed", self)
    CloseDermaMenus()
end

vgui.Register("liaScoreboard", PANEL, "liaSemiTransparentDFrame")
