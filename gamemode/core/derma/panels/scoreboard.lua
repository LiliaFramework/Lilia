local PANEL = {}
local frameColor = Color(4, 14, 19, 248)
local headerColor = Color(5, 18, 24, 252)
local panelColor = Color(6, 21, 28, 246)
local rowColors = {
    [0] = Color(6, 19, 27, 246),
    [1] = Color(8, 23, 31, 246)
}

local borderColor = Color(77, 105, 114, 105)
local dividerColor = Color(192, 211, 218, 24)
local mutedTextColor = Color(160, 180, 188)
local sectionAccentColor = Color(171, 113, 61)
local positiveColor = Color(92, 225, 180)
local function wrap(text, maxWidth, font)
    surface.SetFont(font)
    local words, lines, current = {}, {}, ""
    for word in text:gmatch("%S+") do
        words[#words + 1] = word
    end

    for _, word in ipairs(words) do
        local trial = current == "" and word or current .. " " .. word
        if select(1, surface.GetTextSize(trial)) > maxWidth then
            if current == "" then
                lines[#lines + 1] = word
            else
                lines[#lines + 1] = current
                current = word
            end
        else
            current = trial
        end
    end

    if current ~= "" then lines[#lines + 1] = current end
    return lines
end

local function tintColor(base, accent, amount, alpha)
    return Color(math.Clamp(base.r + (accent.r - base.r) * amount, 0, 255), math.Clamp(base.g + (accent.g - base.g) * amount, 0, 255), math.Clamp(base.b + (accent.b - base.b) * amount, 0, 255), alpha or base.a)
end

local function resolveHeaderColor(primary, fallback)
    if IsColor(primary) then return Color(primary.r, primary.g, primary.b, primary.a or 255) end
    if istable(primary) then
        if isnumber(primary.r) and isnumber(primary.g) and isnumber(primary.b) then return Color(primary.r, primary.g, primary.b, primary.a or 255) end
        if isnumber(primary[1]) and isnumber(primary[2]) and isnumber(primary[3]) then return Color(primary[1], primary[2], primary[3], primary[4] or 255) end
    end
    return Color(fallback.r, fallback.g, fallback.b, fallback.a or 255)
end

local function getColorLuminance(color)
    return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
end

local function getPingColor(ping)
    if ping <= 60 then return Color(92, 225, 180) end
    if ping <= 120 then return Color(239, 198, 98) end
    return Color(235, 104, 104)
end

local function getValidMaterial(path)
    if not isstring(path) or path == "" then return nil end
    local material = Material(path, "smooth")
    if not material or material:IsError() then return nil end
    return material
end

local function getPlayerRankText(ply, char)
    local rank = ""
    if char and char.getData then
        local storedRank = char:getData("rank")
        if storedRank ~= nil and tostring(storedRank) ~= "" then rank = tostring(storedRank) end
    end

    if rank == "" and IsValid(ply) then
        local userGroup = ply:GetUserGroup()
        if isstring(userGroup) and userGroup ~= "" then
            rank = userGroup:gsub("_", " ")
            rank = rank:sub(1, 1):upper() .. rank:sub(2)
        end
    end

    if rank == "" then rank = L("none") end
    return rank
end

local function paintScoreboardHeader(header, w, h, accentColor)
    lia.util.drawBlur(header, 3, 2, 220)
    draw.RoundedBox(2, 0, 0, w, h, headerColor)
    surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 220)
    surface.DrawRect(0, 0, 3, h)
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(sectionAccentColor.r, sectionAccentColor.g, sectionAccentColor.b, 70)
    surface.DrawLine(12, h - 1, w - 12, h - 1)
end

function PANEL:ApplyConfig()
    local screenW, screenH = ScrW(), ScrH()
    local w = screenW * lia.config.get("sbWidth", 0.66)
    local h = screenH * lia.config.get("sbHeight", 0.68)
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

local function paintServerHeader(header, w, h, accentColor)
    lia.util.drawBlur(header, 3, 2, 230)
    draw.RoundedBox(2, 0, 0, w, h, headerColor)
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(sectionAccentColor.r, sectionAccentColor.g, sectionAccentColor.b, 210)
    surface.DrawRect(0, h - 2, w, 2)
    surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 180)
    surface.DrawRect(0, 0, 3, h - 2)
end

local function paintClassHeader(header, w, h, accentColor)
    lia.util.drawBlur(header, 2, 2, 190)
    draw.RoundedBox(1, 0, 0, w, h, panelColor)
    surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 220)
    surface.DrawRect(0, 0, 3, h)
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 38)
    surface.DrawLine(10, h - 1, w - 10, h - 1)
end

function PANEL:Init()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    lia.gui.score = self
    self.isLiaScoreboard = true
    hook.Run("ScoreboardOpened", self)
    self:ApplyConfig()
    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetCenterTitle("")
    self:SetDraggable(false)
    self:LiteMode()
    self.Paint = function(panel, w, h)
        lia.util.drawBlur(panel, 4, 2, 235)
        draw.RoundedBox(2, 0, 0, w, h, frameColor)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    self.playerOptionFrames = {}
    self.serverHeader = self:Add("DPanel")
    self.serverHeader:Dock(TOP)
    self.serverHeader:DockMargin(0, 0, 0, 6)
    self.serverHeader:SetTall(math.Clamp(ScrH() * 0.07, 64, 78))
    local accentColor = lia.color.theme and (lia.color.theme.accent or lia.color.theme.theme) or Color(48, 194, 132)
    self.serverHeader.Paint = function(header, w, h) paintServerHeader(header, w, h, accentColor) end
    local schemaLogoMaterial = SCHEMA and getValidMaterial(SCHEMA.icon) or nil
    if schemaLogoMaterial then
        self.serverLogo = self.serverHeader:Add("DImage")
        self.serverLogo:SetMaterial(schemaLogoMaterial)
    end

    self.serverTitle = self.serverHeader:Add("DLabel")
    self.serverTitle:SetFont("LiliaFont.25b")
    self.serverTitle:SetTextColor(color_white)
    self.serverTitle:SetExpensiveShadow(1, Color(0, 0, 0, 190))
    self.serverTitle:SetText(GetHostName())
    self.serverTitle:SizeToContents()
    self.serverTitle:SetMouseInputEnabled(false)
    self.onlineBadge = self.serverHeader:Add("DPanel")
    self.onlineBadge:SetMouseInputEnabled(false)
    self.onlineBadge.Paint = function(_, w, h)
        draw.RoundedBox(1, 0, 0, w, h, panelColor)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.RoundedBox(h * 0.16, 14, h * 0.42, h * 0.16, h * 0.16, sectionAccentColor)
    end

    self.onlineLabel = self.onlineBadge:Add("DLabel")
    self.onlineLabel:SetFont("LiliaFont.17")
    self.onlineLabel:SetTextColor(color_white)
    self.onlineLabel:SetContentAlignment(5)
    self.onlineLabel:SetMouseInputEnabled(false)
    self.serverHeader.PerformLayout = function(_, w, h)
        local padding = 22
        local logoSize = IsValid(self.serverLogo) and math.min(h - 24, 48) or 0
        local titleX = padding
        if IsValid(self.serverLogo) then
            self.serverLogo:SetPos(padding, (h - logoSize) * 0.5)
            self.serverLogo:SetSize(logoSize, logoSize)
            titleX = padding + logoSize + 14
        end

        self.serverTitle:SizeToContents()
        self.serverTitle:SetPos(titleX, (h - self.serverTitle:GetTall()) * 0.5)
        local badgeW = math.Clamp(w * 0.12, 120, 150)
        local badgeH = math.Clamp(h * 0.54, 36, 42)
        self.onlineBadge:SetSize(badgeW, badgeH)
        self.onlineBadge:SetPos(w - padding - badgeW, (h - badgeH) * 0.5)
        self.onlineLabel:SetPos(24, 0)
        self.onlineLabel:SetSize(badgeW - 30, badgeH)
    end

    local scroll = self:Add("liaScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)
    scroll.VBar:SetWide(0)
    local layout = scroll:Add("DListLayout")
    layout:Dock(TOP)
    self.scroll, self.layout = scroll, layout
    self.playerSlots, self.factionLists = {}, {}
    local sortedFactions = {}
    for facID, facData in ipairs(lia.faction.indices) do
        sortedFactions[#sortedFactions + 1] = {
            id = facID,
            data = facData
        }
    end

    table.sort(sortedFactions, function(a, b) return (a.data.scoreboardPriority or 999) < (b.data.scoreboardPriority or 999) end)
    for _, factionInfo in ipairs(sortedFactions) do
        local facID, facData = factionInfo.id, factionInfo.data
        local facColor = team.GetColor(facID)
        local factionTitle = string.upper(L(facData.name))
        local factionSubtitle = facData.scoreboardSubtitle and L(facData.scoreboardSubtitle) or ""
        local facCat = layout:Add("DCollapsibleCategory")
        facCat:SetLabel("")
        facCat:SetExpanded(true)
        facCat:DockMargin(0, 0, 0, 6)
        local factionLogo
        local factionTitleLabel
        local factionSubtitleLabel
        local factionMemberLabel
        if IsValid(facCat.Header) then
            facCat.Header:SetTall(math.Clamp(ScrH() * 0.062, 56, 70))
            facCat.Header.Paint = function() end
            facCat.Header.PaintOver = function(_, w, h)
                paintScoreboardHeader(facCat.Header, w, h, facColor)
                local logoSize = IsValid(factionLogo) and factionLogo:GetMaterial() and math.min(h - 18, 62) or 0
                local textX = logoSize > 0 and 18 + logoSize + 16 or 20
                if logoSize > 0 then
                    surface.SetMaterial(factionLogo:GetMaterial())
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(16, (h - logoSize) * 0.5, logoSize, logoSize)
                end

                if factionSubtitle ~= "" then
                    draw.SimpleText(factionTitle, "LiliaFont.25b", textX, h * 0.25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(factionSubtitle, "LiliaFont.16", textX, h * 0.68, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(factionTitle, "LiliaFont.25b", textX, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                if IsValid(factionMemberLabel) then draw.SimpleText(factionMemberLabel:GetText(), "LiliaFont.16", w - 20, h * 0.5, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) end
            end

            local factionLogoMaterial = getValidMaterial(facData.logo)
            if factionLogoMaterial then
                factionLogo = facCat.Header:Add("DImage")
                factionLogo:SetMaterial(factionLogoMaterial)
            end

            factionTitleLabel = facCat.Header:Add("DLabel")
            factionTitleLabel:SetFont("LiliaFont.25b")
            factionTitleLabel:SetTextColor(color_white)
            factionTitleLabel:SetExpensiveShadow(1, Color(0, 0, 0, 180))
            factionTitleLabel:SetText(factionTitle)
            factionTitleLabel:SizeToContents()
            factionTitleLabel:SetMouseInputEnabled(false)
            factionSubtitleLabel = facCat.Header:Add("DLabel")
            factionSubtitleLabel:SetFont("LiliaFont.16")
            factionSubtitleLabel:SetTextColor(tintColor(Color(150, 180, 195), facColor, 0.55, 255))
            factionSubtitleLabel:SetText(factionSubtitle)
            factionSubtitleLabel:SizeToContents()
            factionSubtitleLabel:SetMouseInputEnabled(false)
            factionMemberLabel = facCat.Header:Add("DLabel")
            factionMemberLabel:SetFont("LiliaFont.16")
            factionMemberLabel:SetTextColor(tintColor(Color(180, 205, 215), facColor, 0.55, 255))
            factionMemberLabel:SetContentAlignment(6)
            factionMemberLabel:SetMouseInputEnabled(false)
            factionTitleLabel:SetVisible(false)
            factionSubtitleLabel:SetVisible(false)
            factionMemberLabel:SetVisible(false)
            if IsValid(factionLogo) then factionLogo:SetVisible(false) end
            facCat.Header.PerformLayout = function(_, w, h)
                local logoSize = factionLogo and math.min(h - 18, 62) or 0
                local textX = factionLogo and 18 + logoSize + 16 or 20
                if factionLogo then
                    factionLogo:SetPos(16, (h - logoSize) * 0.5)
                    factionLogo:SetSize(logoSize, logoSize)
                end

                factionTitleLabel:SizeToContents()
                factionSubtitleLabel:SizeToContents()
                factionMemberLabel:SetSize(150, h)
                factionMemberLabel:SetPos(w - 170, 0)
                if factionSubtitle ~= "" then
                    factionTitleLabel:SetPos(textX, h * 0.25 - factionTitleLabel:GetTall() * 0.5)
                    factionSubtitleLabel:SetPos(textX, h * 0.68 - factionSubtitleLabel:GetTall() * 0.5)
                else
                    factionTitleLabel:SetPos(textX, (h - factionTitleLabel:GetTall()) * 0.5)
                    factionSubtitleLabel:SetVisible(false)
                end
            end
        end

        local facCont = vgui.Create("DListLayout", facCat)
        facCat:SetContents(facCont)
        facCont.noClass = facCont:Add("DListLayout")
        facCont.noClass:Dock(TOP)
        facCont.classLists = {}
        facCont.memberLabel = factionMemberLabel
        facCont.factionID = facID
        if lia.config.get("ClassHeaders", true) then
            for clsID, clsData in pairs(lia.class.list) do
                if clsData.faction ~= facID then continue end
                if clsData.scoreboardHidden or hook.Run("ShouldShowClassOnScoreboard", clsData) == false then
                    local hiddenList = facCont:Add("DListLayout")
                    hiddenList:Dock(TOP)
                    facCont.classLists[clsID] = hiddenList
                    continue
                end

                local cat = facCont:Add("DCollapsibleCategory")
                cat:SetLabel("")
                cat:SetExpanded(true)
                cat:DockMargin(8, 3, 8, 0)
                local classColor = resolveHeaderColor(clsData.color, facColor)
                if getColorLuminance(classColor) < 45 then classColor = Color(accentColor.r, accentColor.g, accentColor.b, accentColor.a or 255) end
                local headerClassColor = Color(classColor.r, classColor.g, classColor.b, classColor.a or 255)
                local list
                local classLogo
                local classLabel
                if IsValid(cat.Header) then
                    cat.Header:SetTall(36)
                    cat.Header.Paint = function(header, w, h) end
                    cat.Header.PaintOver = function(_, w, h)
                        paintClassHeader(cat.Header, w, h, headerClassColor)
                        local centerY = h * 0.5
                        surface.SetDrawColor(headerClassColor.r, headerClassColor.g, headerClassColor.b, 255)
                        if cat:GetExpanded() then
                            surface.DrawLine(14, centerY - 3, 19, centerY + 2)
                            surface.DrawLine(19, centerY + 2, 24, centerY - 3)
                        else
                            surface.DrawLine(16, centerY - 5, 21, centerY)
                            surface.DrawLine(21, centerY, 16, centerY + 5)
                        end

                        local textX = 34
                        if IsValid(classLogo) and classLogo:GetMaterial() then
                            local logoSize = 22
                            surface.SetMaterial(classLogo:GetMaterial())
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.DrawTexturedRect(textX, (h - logoSize) * 0.5, logoSize, logoSize)
                            textX = textX + 30
                        end

                        draw.SimpleText(string.upper(L(clsData.name)), "LiliaFont.15b", textX, centerY, tintColor(mutedTextColor, headerClassColor, 0.45, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        local count = IsValid(list) and list:ChildCount() or 0
                        draw.SimpleText(count == 1 and "1 PLAYER" or count .. " PLAYERS", "LiliaFont.16", w - 14, centerY, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end

                    local classLogoMaterial = getValidMaterial(clsData.logo)
                    if classLogoMaterial then
                        classLogo = cat.Header:Add("DImage")
                        classLogo:SetMaterial(classLogoMaterial)
                    end

                    classLabel = cat.Header:Add("DLabel")
                    classLabel:SetFont("LiliaFont.15b")
                    classLabel:SetTextColor(color_white)
                    classLabel:SetExpensiveShadow(1, Color(0, 0, 0, 170))
                    classLabel:SetText(string.upper(L(clsData.name)))
                    classLabel:SizeToContents()
                    classLabel:SetMouseInputEnabled(false)
                    classLabel:SetVisible(false)
                    if IsValid(classLogo) then classLogo:SetVisible(false) end
                    cat.Header.PerformLayout = function(_, _, h)
                        local x = 34
                        if classLogo then
                            classLogo:SetPos(x, (h - 22) * 0.5)
                            classLogo:SetSize(22, 22)
                            x = x + 30
                        end

                        classLabel:SizeToContents()
                        classLabel:SetPos(x, (h - classLabel:GetTall()) * 0.5)
                    end
                end

                list = vgui.Create("DListLayout", cat)
                list.category = cat
                cat:SetContents(list)
                facCont.classLists[clsID] = list
            end
        end

        self.factionLists[facID] = facCont
    end
end

function PANEL:Think()
    if not self:IsVisible() then return end
    if IsValid(self.onlineLabel) then
        local online = player.GetCount()
        self.onlineLabel:SetText(online .. " Online")
    end

    if (self.nextUpdate or 0) > CurTime() then return end
    for _, ply in player.Iterator() do
        local factionData = lia.faction.indices[ply:Team()]
        if hook.Run("ShouldShowPlayerOnScoreboard", ply) == false or hook.Run("ShouldShowFactionOnScoreboard", ply) == false or factionData and factionData.scoreboardHidden then continue end
        local char = ply:getChar()
        if not char then continue end
        local facCont = self.factionLists[ply:Team()]
        if not IsValid(facCont) then continue end
        local parent = facCont.classLists[char:getClass()] or facCont.noClass
        if not IsValid(parent) then continue end
        if not IsValid(ply.liaScoreSlot) then
            self:addPlayer(ply, parent)
        elseif ply.liaScoreSlot:GetParent() ~= parent then
            ply.liaScoreSlot:SetParent(parent)
            parent:InvalidateLayout(true)
        end
    end

    for _, facCont in pairs(self.factionLists) do
        local showFaction = facCont.noClass:ChildCount() > 0
        local memberCount = facCont.noClass:ChildCount()
        for _, list in pairs(facCont.classLists) do
            local count = list:ChildCount()
            memberCount = memberCount + count
            if IsValid(list.category) then
                local hasPlayers = count > 0
                list.category:SetVisible(hasPlayers)
                if hasPlayers then showFaction = true end
            elseif count > 0 then
                showFaction = true
            end
        end

        if IsValid(facCont.memberLabel) then facCont.memberLabel:SetText(memberCount == 1 and "1 MEMBER" or memberCount .. " MEMBERS") end
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
    slot:DockMargin(10, 3, 10, 0)
    local height = math.Clamp(ScrH() * 0.068, 60, 76)
    slot:SetTall(height)
    slot.player = ply
    slot.character = ply:getChar()
    ply.liaScoreSlot = slot
    local margin = 9
    local iconSize = height - margin * 2
    slot.Paint = function(s, w, h)
        local index = s.rowIndex or 0
        local base = rowColors[index % 2]
        draw.RoundedBox(1, 0, 0, w, h, base)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        if s.statusX and s.pingX then
            surface.SetDrawColor(dividerColor)
            surface.DrawLine(s.statusX - 10, 12, s.statusX - 10, h - 12)
            surface.DrawLine(s.pingX - 10, 12, s.pingX - 10, h - 12)
        end

        if IsValid(ply) and s.pingX then
            local ping = ply:Ping()
            local color = getPingColor(ping)
            local barX = s.pingX + 8
            local baseY = h * 0.5 + 7
            surface.SetDrawColor(color)
            for i = 1, 4 do
                local barHeight = 3 + i * 3
                surface.DrawRect(barX + (i - 1) * 4, baseY - barHeight, 2, barHeight)
            end
        end
    end

    slot.model = slot:Add("liaSpawnIcon")
    slot.model:SetPos(margin, margin)
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
        if #opts == 0 then return end
        local frame = vgui.Create("liaFrame", self)
        frame:SetSize(360, 450)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle(L("sbOptions"))
        frame:LiteMode()
        self.playerOptionFrames[#self.playerOptionFrames + 1] = frame
        frame.OnRemove = function()
            if not self.playerOptionFrames then return end
            for i, optionFrame in ipairs(self.playerOptionFrames) do
                if optionFrame == frame then
                    table.remove(self.playerOptionFrames, i)
                    break
                end
            end
        end

        local scrollPanel = vgui.Create("liaScrollPanel", frame)
        scrollPanel:Dock(FILL)
        scrollPanel:DockMargin(5, 5, 5, 5)
        for _, option in ipairs(opts) do
            local button = vgui.Create("DButton", scrollPanel)
            button:Dock(TOP)
            button:DockMargin(5, 5, 5, 0)
            button:SetTall(32)
            button:SetText("")
            button:SetCursor("hand")
            button.Paint = function(s, w, h)
                local baseColor = s:IsHovered() and lia.color.theme.button_hovered or lia.color.theme.button
                draw.RoundedBox(8, 0, 0, w, h, baseColor)
                if option.image then
                    surface.SetMaterial(Material(option.image))
                    surface.SetDrawColor(lia.color.theme.text)
                    surface.DrawTexturedRect(8, (h - 16) * 0.5, 16, 16)
                end

                draw.SimpleText(L(option.name), "LiliaFont.17", 32, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function()
                option.func()
                frame:Remove()
            end
        end
    end

    timer.Simple(0, function()
        if not IsValid(slot.model) or not IsValid(slot.model.Entity) then return end
        for _, bodygroup in ipairs(ply:GetBodyGroups()) do
            slot.model.Entity:SetBodygroup(bodygroup.id, ply:GetBodygroup(bodygroup.id))
        end

        for i in ipairs(ply:GetMaterials()) do
            slot.model.Entity:SetSubMaterial(i - 1, ply:GetSubMaterial(i - 1))
        end

        hook.Run("ModifyScoreboardModel", slot.model.Entity, ply)
    end)

    slot.name = vgui.Create("DLabel", slot)
    slot.name:SetFont("LiliaFont.17")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, Color(0, 0, 0, 190))
    slot.desc = vgui.Create("DLabel", slot)
    slot.desc:SetAutoStretchVertical(true)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetFont("LiliaFont.16")
    slot.desc:SetTextColor(mutedTextColor)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.status = vgui.Create("DLabel", slot)
    slot.status:SetFont("LiliaFont.16")
    slot.status:SetText("")
    slot.status:SetTextColor(positiveColor)
    slot.status:SetContentAlignment(5)
    slot.ping = vgui.Create("DLabel", slot)
    slot.ping:SetFont("LiliaFont.16")
    slot.ping:SetContentAlignment(5)
    function slot:layout()
        local totalW = self:GetWide()
        local pingColumnW = math.Clamp(totalW * 0.1, 82, 110)
        local statusColumnW = math.Clamp(totalW * 0.1, 82, 105)
        local contentX = iconSize + margin * 2
        self.statusX = totalW - pingColumnW - statusColumnW
        self.pingX = totalW - pingColumnW
        local textWidth = math.max(80, self.statusX - contentX - 18)
        self.name:SetPos(contentX, height * 0.14)
        self.name:SetSize(textWidth, height * 0.34)
        self.desc:SetPos(contentX, height * 0.52)
        self.desc:SetSize(textWidth, height * 0.3)
        self.status:SetPos(self.statusX, 0)
        self.status:SetSize(statusColumnW - 10, height)
        self.ping:SetPos(self.pingX + 24, 0)
        self.ping:SetSize(pingColumnW - 26, height)
    end

    slot.ping.Think = function(label)
        if not IsValid(ply) or not IsValid(self) or not self:IsVisible() then return end
        local ping = ply:Ping()
        local text = ping .. " ms"
        if label:GetText() ~= text then label:SetText(text) end
        label:SetTextColor(getPingColor(ping))
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
            self.model:setHidden(overrideModel)
            self.lastHidden = overrideModel
        end

        local name = hook.Run("ShouldAllowScoreboardOverride", ply, "name") and hook.Run("GetDisplayedName", ply) or char:getName()
        name = name:gsub("#", "\226\128\139#")
        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local description = hook.Run("ShouldAllowScoreboardOverride", ply, "desc") and hook.Run("GetDisplayedDescription", ply, false) or char:getDesc()
        description = description:gsub("#", "\226\128\139#")
        local wrapped = wrap(description, math.max(self.desc:GetWide(), 80), "LiliaFont.16")
        if #wrapped > 1 then
            wrapped[1] = wrapped[1] .. " (...)"
            for i = 2, #wrapped do
                wrapped[i] = nil
            end
        end

        local finalDescription = table.concat(wrapped, "\n")
        if self.lastDesc ~= finalDescription then
            self.desc:SetText(finalDescription)
            self.lastDesc = finalDescription
        end

        local rankText = getPlayerRankText(ply, char)
        if self.lastRank ~= rankText then
            self.status:SetText(rankText)
            self.lastRank = rankText
        end

        local model = ply:GetModel()
        local skin = ply:GetSkin()
        if self.lastModel ~= model or self.lastSkin ~= skin then
            self.model:SetModel(model, skin)
            if IsValid(self.model.Entity) then
                for _, bodygroup in ipairs(ply:GetBodyGroups()) do
                    self.model.Entity:SetBodygroup(bodygroup.id, ply:GetBodygroup(bodygroup.id))
                end

                hook.Run("ModifyScoreboardModel", self.model.Entity, ply)
            end

            self.lastModel, self.lastSkin = model, skin
        end

        self:layout()
    end

    parent:InvalidateLayout(true)
    self.playerSlots[#self.playerSlots + 1] = slot
    local index = 0
    for _, child in ipairs(parent:GetChildren()) do
        if IsValid(child.model) then
            index = index + 1
            child.rowIndex = index
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

function PANEL:ClosePlayerOptionFrames()
    if not self.playerOptionFrames then return end
    for _, frame in ipairs(self.playerOptionFrames) do
        if IsValid(frame) then frame:Remove() end
    end

    self.playerOptionFrames = {}
end

function PANEL:OnRemove()
    hook.Run("ScoreboardClosed", self)
    CloseDermaMenus()
    self:ClosePlayerOptionFrames()
    for _, slot in ipairs(self.playerSlots or {}) do
        if IsValid(slot) and IsValid(slot.player) and slot.player.liaScoreSlot == slot then slot.player.liaScoreSlot = nil end
    end
end

vgui.Register("liaScoreboard", PANEL, "liaFrame")
local function liaScoreboardHide()
    if IsValid(lia.gui.score) and lia.gui.score:IsVisible() then
        lia.gui.score:SetVisible(false)
        CloseDermaMenus()
        if lia.gui.score.ClosePlayerOptionFrames then lia.gui.score:ClosePlayerOptionFrames() end
        hook.Run("ScoreboardClosed", lia.gui.score)
    end

    gui.EnableScreenClicker(false)
    return true
end

local function liaScoreboardShow()
    local client = LocalPlayer()
    if hook.Run("CanPlayerOpenScoreboard", LocalPlayer()) == false then return false end
    local tracedEntity = client:getTracedEntity(100)
    if not IsValid(tracedEntity) or not tracedEntity:IsPlayer() then
        if IsValid(lia.gui.score) then
            if not lia.gui.score:IsVisible() then
                lia.gui.score.nextUpdate = 0
                lia.gui.score:SetVisible(true)
                hook.Run("ScoreboardOpened", lia.gui.score)
            end
        else
            vgui.Create("liaScoreboard")
        end
    end

    gui.EnableScreenClicker(true)
    return true
end

hook.Add("ScoreboardHide", "liaScoreboardHide", liaScoreboardHide)
hook.Add("ScoreboardShow", "liaScoreboardShow", liaScoreboardShow)
hook.Add("InteractionMenuOpened", "liaScoreboardInteractionMenuOpened", liaScoreboardHide)
