local PANEL = {}
local fallbackBackground = Color(7, 14, 23)
local fallbackText = Color(230, 239, 239)
local fallbackAccent = Color(76, 164, 224)
local rowHeight = math.Clamp(ScrH() * 0.068, 60, 76)
local factionHeaderHeight = math.Clamp(ScrH() * 0.062, 56, 70)
local classHeaderHeight = 48
local scoreboardHeaderTitleFont = "LiliaFont.22"
local scoreboardHeaderMetaFont = "LiliaFont.16"

local function themeColor(value, fallback, alpha)
    value = IsColor(value) and value or fallback
    return Color(value.r, value.g, value.b, alpha or value.a or 255)
end

local function getTheme()
    return lia.color and lia.color.theme or {}
end

local function getAccent(alpha)
    local theme = getTheme()
    return themeColor(theme.accent or theme.theme or lia.config.get("Color"), fallbackAccent, alpha)
end

local function getText(alpha)
    local theme = getTheme()
    return themeColor(theme.text or theme.foreground, fallbackText, alpha)
end

local function getBackground(alpha)
    local theme = getTheme()
    return themeColor(theme.background or theme.panel or theme.window, fallbackBackground, alpha)
end

local function blendColor(from, to, fraction, alpha)
    fraction = math.Clamp(fraction, 0, 1)
    return Color(math.Round(Lerp(fraction, from.r, to.r)), math.Round(Lerp(fraction, from.g, to.g)), math.Round(Lerp(fraction, from.b, to.b)), alpha or 255)
end

local function getSurface(fraction, alpha)
    return blendColor(getBackground(), getText(), fraction or 0.04, alpha or 240)
end

local function getMuted(alpha)
    return blendColor(getText(), getBackground(), 0.40, alpha or 255)
end

local function paintBox(w, h, background, outline, radius)
    radius = radius or 6
    if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
        lia.derma.rect(0, 0, w, h):Rad(radius):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(0, 0, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
    else
        draw.RoundedBox(radius, 0, 0, w, h, background)
        if outline then
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
end

local function paintSection(w, h, accent, hovered)
    local background = hovered and getSurface(0.065, 242) or getSurface(0.05, 236)
    local border = Color(accent.r, accent.g, accent.b, hovered and 135 or 60)
    paintBox(w, h, background, border, 7)
end

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

    if rank == "" then rank = "None" end
    return rank
end

local function paintScoreboardHeader(header, w, h)
    local accent = getAccent()
    paintSection(w, h, accent, header:IsHovered())
    surface.SetDrawColor(getAccent(145))
    surface.DrawRect(0, 0, 3, h)
end

function PANEL:ApplyConfig()
    local screenW, screenH = ScrW(), ScrH()
    local width = math.Clamp(screenW * lia.config.get("sbWidth", 0.66), math.min(520, screenW * 0.92), screenW * 0.92)
    local height = math.Clamp(screenH * lia.config.get("sbHeight", 0.68), math.min(220, screenH * 0.88), screenH * 0.88)
    self:SetSize(math.Round(width), math.Round(height))
    self:PositionFrame()
end

function PANEL:PositionFrame()
    local screenW, screenH = ScrW(), ScrH()
    local w, h = self:GetSize()
    local dock = string.lower(lia.config.get("sbDock", "center"))
    if dock == "left" then
        self:SetPos(0, (screenH - h) * 0.5)
    elseif dock == "right" then
        self:SetPos(screenW - w, (screenH - h) * 0.5)
    else
        self:SetPos((screenW - w) * 0.5, (screenH - h) * 0.5)
    end
end

function PANEL:ShowAnimated()
    self:SetVisible(true)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.22, 0)
    self.nextUpdate = 0
end

local function paintServerHeader(_, w, h)
    paintBox(w, h, getSurface(0.028, 245), getAccent(95), 7)
    surface.SetDrawColor(getAccent(150))
    surface.DrawRect(0, h - 2, w, 2)
end

local function paintClassHeader(header, w, h)
    paintSection(w, h, getAccent(), header:IsHovered())
    surface.SetDrawColor(getAccent(100))
    surface.DrawRect(0, 0, 2, h)
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
        lia.util.drawBlur(panel, 3, 2, 215)
        paintBox(w, h, getSurface(0.022, 244), getAccent(90), 8)
    end

    self.playerOptionFrames = {}
    self.serverHeader = self:Add("DPanel")
    self.serverHeader:Dock(TOP)
    self.serverHeader:DockMargin(0, 0, 0, 6)
    self.serverHeader:SetTall(math.Clamp(ScrH() * 0.07, 64, 78))
    self.serverHeader:SetMouseInputEnabled(false)
    self.serverHeader.Paint = function(header, w, h) paintServerHeader(header, w, h) end
    local schemaLogoMaterial = SCHEMA and getValidMaterial(SCHEMA.icon) or nil
    if schemaLogoMaterial then
        self.serverLogo = self.serverHeader:Add("DImage")
        self.serverLogo:SetMaterial(schemaLogoMaterial)
    end

    self.serverTitle = self.serverHeader:Add("DLabel")
    self.serverTitle:SetFont(scoreboardHeaderTitleFont)
    self.serverTitle:SetTextColor(getText())
    self.serverTitle:SetText(GetHostName())
    self.serverTitle:SizeToContents()
    self.serverTitle:SetMouseInputEnabled(false)
    self.onlineBadge = self.serverHeader:Add("DPanel")
    self.onlineBadge:SetMouseInputEnabled(false)
    self.onlineBadge.Paint = function(_, w, h)
        paintBox(w, h, getSurface(0.05, 238), getAccent(65), 5)
        draw.RoundedBox(4, 13, h * 0.5 - 4, 8, 8, getAccent())
    end

    self.onlineLabel = self.onlineBadge:Add("DLabel")
    self.onlineLabel:SetFont("LiliaFont.17")
    self.onlineLabel:SetTextColor(getText())
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
    scroll:DockMargin(12, 0, 12, 4)
    scroll.VBar:SetWide(8)
    scroll.VBar.Paint = function() end
    scroll.VBar.btnUp.Paint = function() end
    scroll.VBar.btnDown.Paint = function() end
    scroll.VBar.btnGrip.Paint = function(grip, w, h)
        draw.RoundedBox(4, 1, 0, w - 2, h, getAccent(grip:IsHovered() and 175 or 100))
    end
    scroll.Paint = function(_, w, h)
        if (self.displayedCount or 0) == 0 then
            draw.SimpleText("NO ACTIVE CHARACTERS", "LiliaFont.17", w * 0.5, h * 0.5, getMuted(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    self:ShowAnimated()
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
        local factionTitle = string.upper(tostring(facData.name))
        local factionSubtitle = facData.scoreboardSubtitle and tostring(facData.scoreboardSubtitle) or (factionTitle == "STAFF ON DUTY" and "Staff members currently available." or "")
        local facCat = layout:Add("DCollapsibleCategory")
        facCat.Paint = function() end
        facCat.PaintOver = function() end
        facCat:SetLabel("")
        facCat:SetExpanded(true)
        facCat:DockMargin(0, 0, 0, 7)
        local factionLogo
        local factionTitleLabel
        local factionSubtitleLabel
        local factionMemberLabel
        if IsValid(facCat.Header) then
            facCat.Header:SetTall(factionHeaderHeight)
            facCat.Header.Paint = function() end
            facCat.Header.PaintOver = function(_, w, h)
                paintScoreboardHeader(facCat.Header, w, h)
                local logoSize = IsValid(factionLogo) and factionLogo:GetMaterial() and math.min(h - 18, 46) or 0
                local textX = logoSize > 0 and 18 + logoSize + 14 or 18
                if logoSize > 0 then
                    surface.SetMaterial(factionLogo:GetMaterial())
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(16, (h - logoSize) * 0.5, logoSize, logoSize)
                end

                if factionSubtitle ~= "" then
                    draw.SimpleText(string.upper(tostring(factionTitle)), scoreboardHeaderTitleFont, textX, h * 0.32, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(factionSubtitle, scoreboardHeaderMetaFont, textX, h * 0.72, getMuted(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(string.upper(tostring(factionTitle)), scoreboardHeaderTitleFont, textX, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                if IsValid(factionMemberLabel) then draw.SimpleText(factionMemberLabel:GetText(), scoreboardHeaderMetaFont, w - 16, h * 0.5, getAccent(), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) end
            end

            local factionLogoMaterial = getValidMaterial(facData.logo)
            if factionLogoMaterial then
                factionLogo = facCat.Header:Add("DImage")
                factionLogo:SetMaterial(factionLogoMaterial)
            end

            factionTitleLabel = facCat.Header:Add("DLabel")
            factionTitleLabel:SetFont(scoreboardHeaderTitleFont)
            factionTitleLabel:SetTextColor(getText())
            factionTitleLabel:SetExpensiveShadow(1, Color(0, 0, 0, 180))
            factionTitleLabel:SetText(string.upper(tostring(factionTitle)))
            factionTitleLabel:SizeToContents()
            factionTitleLabel:SetMouseInputEnabled(false)
            factionSubtitleLabel = facCat.Header:Add("DLabel")
            factionSubtitleLabel:SetFont(scoreboardHeaderMetaFont)
            factionSubtitleLabel:SetTextColor(getMuted())
            factionSubtitleLabel:SetText(factionSubtitle)
            factionSubtitleLabel:SizeToContents()
            factionSubtitleLabel:SetMouseInputEnabled(false)
            factionMemberLabel = facCat.Header:Add("DLabel")
            factionMemberLabel:SetFont(scoreboardHeaderMetaFont)
            factionMemberLabel:SetTextColor(getAccent())
            factionMemberLabel:SetContentAlignment(6)
            factionMemberLabel:SetMouseInputEnabled(false)
            factionTitleLabel:SetVisible(false)
            factionSubtitleLabel:SetVisible(false)
            factionMemberLabel:SetVisible(false)
            if IsValid(factionLogo) then factionLogo:SetVisible(false) end
            facCat.Header.PerformLayout = function(_, w, h)
                local logoSize = factionLogo and math.min(h - 18, 46) or 0
                local textX = factionLogo and 18 + logoSize + 14 or 18
                if factionLogo then
                    factionLogo:SetPos(16, (h - logoSize) * 0.5)
                    factionLogo:SetSize(logoSize, logoSize)
                end

                factionTitleLabel:SizeToContents()
                factionSubtitleLabel:SizeToContents()
                factionMemberLabel:SetSize(150, h)
                factionMemberLabel:SetPos(w - 170, 0)
                if factionSubtitle ~= "" then
                    factionTitleLabel:SetPos(textX, h * 0.32 - factionTitleLabel:GetTall() * 0.5)
                    factionSubtitleLabel:SetPos(textX, h * 0.72 - factionSubtitleLabel:GetTall() * 0.5)
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
        facCont.factionTitle = factionTitle
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
                cat.Paint = function() end
                cat.PaintOver = function() end
                cat:SetLabel("")
                cat:SetExpanded(true)
                cat:DockMargin(8, 3, 8, 0)
                local list
                local classLogo
                local classLabel
                if IsValid(cat.Header) then
                    cat.Header:SetTall(classHeaderHeight)
                    cat.Header.Paint = function(header, w, h) end
                    cat.Header.PaintOver = function(_, w, h)
                        paintClassHeader(cat.Header, w, h)
                        local centerY = h * 0.5
                        surface.SetDrawColor(getAccent())
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

                        draw.SimpleText(string.upper(tostring(clsData.name)), scoreboardHeaderTitleFont, textX, centerY, getText(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        local count = IsValid(list) and list:ChildCount() or 0
                        draw.SimpleText(count == 1 and "1 PLAYER" or count .. " PLAYERS", scoreboardHeaderMetaFont, w - 14, centerY, getAccent(), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end

                    local classLogoMaterial = getValidMaterial(clsData.logo)
                    if classLogoMaterial then
                        classLogo = cat.Header:Add("DImage")
                        classLogo:SetMaterial(classLogoMaterial)
                    end

                    classLabel = cat.Header:Add("DLabel")
                    classLabel:SetFont(scoreboardHeaderTitleFont)
                    classLabel:SetTextColor(color_white)
                    classLabel:SetExpensiveShadow(1, Color(0, 0, 0, 170))
                    classLabel:SetText(string.upper(tostring(clsData.name)))
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

    for i = #self.playerSlots, 1, -1 do
        local slot = self.playerSlots[i]
        if IsValid(slot) then
            slot:update()
        else
            table.remove(self.playerSlots, i)
        end
    end

    local displayedCount = 0
    for _, facCont in pairs(self.factionLists) do
        local facCat = facCont:GetParent()
        local directCount = facCont.noClass:ChildCount()
        local memberCount = directCount
        for _, list in pairs(facCont.classLists) do
            local count = list:ChildCount()
            memberCount = memberCount + count
            if IsValid(list.category) then
                list.category:SetVisible(count > 0)
            end
        end

        if IsValid(facCont.memberLabel) then
            facCont.memberLabel:SetText(memberCount == 1 and "1 MEMBER" or memberCount .. " MEMBERS")
        end

        if IsValid(facCat) then
            facCat:SetVisible(memberCount > 0)
        end

        displayedCount = displayedCount + memberCount
    end

    self.displayedCount = displayedCount

    self.nextUpdate = CurTime() + 0.12
end

function PANEL:addPlayer(ply, parent)
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    slot:DockMargin(6, 3, 6, 3)
    local height = rowHeight
    slot:SetTall(height)
    slot.player = ply
    slot.character = ply:getChar()
    ply.liaScoreSlot = slot
    local margin = 8
    local iconSize = height - margin * 2
    slot.Paint = function(s, w, h)
        paintSection(w, h, getAccent(), s:IsHovered())
        if s.pingX then
            surface.SetDrawColor(getAccent(55))
            surface.DrawRect(s.pingX - 6, 12, 1, h - 24)
        end

        if IsValid(ply) and s.pingX then
            local barX = s.pingX + 7
            local baseY = h * 0.5 + 7
            surface.SetDrawColor(getPingColor(ply:Ping()))
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
    if #initialOpts > 0 then slot.model:SetTooltip("Scoreboard Options.") end
    slot.model.DoClick = function()
        local opts = {}
        hook.Run("ShowPlayerOptions", ply, opts)
        if #opts == 0 then return end
        local frame = vgui.Create("liaFrame", self)
        frame:SetSize(360, 450)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("Scoreboard Options.")
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
                paintSection(w, h, getAccent(), s:IsHovered())
                if option.image then
                    surface.SetMaterial(Material(option.image))
                    surface.SetDrawColor(getText())
                    surface.DrawTexturedRect(8, (h - 16) * 0.5, 16, 16)
                end

                draw.SimpleText(tostring(option.name), "LiliaFont.17", 32, h * 0.5, getText(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
    slot.name:SetTextColor(getText())
    slot.name:SetExpensiveShadow(1, Color(0, 0, 0, 190))
    slot.desc = vgui.Create("DLabel", slot)
    slot.desc:SetAutoStretchVertical(true)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetFont("LiliaFont.16")
    slot.desc:SetTextColor(getMuted())
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.status = vgui.Create("DLabel", slot)
    slot.status:SetFont("LiliaFont.16")
    slot.status:SetText("")
    slot.status:SetTextColor(getAccent())
    slot.status:SetContentAlignment(5)
    slot.status.Paint = function(label, w, h)
        local top = math.floor((h - 30) * 0.5)
        local accent = getAccent()
        draw.RoundedBox(5, 0, top, w, 30, getSurface(0.045, 235))
        surface.SetDrawColor(Color(accent.r, accent.g, accent.b, 100))
        surface.DrawOutlinedRect(0, top, w, 30, 1)
        draw.SimpleText(label:GetText(), "LiliaFont.16", w * 0.5, h * 0.5, getAccent(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    slot.ping = vgui.Create("DLabel", slot)
    slot.ping:SetFont("LiliaFont.16")
    slot.ping:SetContentAlignment(5)
    function slot:layout()
        local totalW = self:GetWide()
        local pingColumnW = math.Clamp(totalW * 0.13, 90, 132)
        local statusColumnW = math.Clamp(totalW * 0.145, 98, 152)
        local contentX = iconSize + margin * 2 + 8
        self.statusX = totalW - pingColumnW - statusColumnW - 8
        self.pingX = totalW - pingColumnW
        local textWidth = math.max(70, self.statusX - contentX - 18)
        self.name:SetPos(contentX, height * 0.13)
        self.name:SetSize(textWidth, height * 0.37)
        self.desc:SetPos(contentX, height * 0.52)
        self.desc:SetSize(textWidth, height * 0.3)
        self.status:SetPos(self.statusX, 0)
        self.status:SetSize(statusColumnW - 18, height)
        self.ping:SetPos(self.pingX + 23, 0)
        self.ping:SetSize(pingColumnW - 24, height)
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
        name = tostring(name or "Unknown")
        name = name:gsub("#", "\226\128\139#")
        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local description = hook.Run("ShouldAllowScoreboardOverride", ply, "desc") and hook.Run("GetDisplayedDescription", ply, false) or char:getDesc()
        description = tostring(description or "")
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
            self.status:SetText(string.upper(rankText))
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
                lia.gui.score:ShowAnimated()
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
concommand.Add("lia_scoreboard_reload", function()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    vgui.Create("liaScoreboard")
end)