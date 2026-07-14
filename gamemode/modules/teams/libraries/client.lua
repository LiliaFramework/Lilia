function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    hook.Run("AddTextField", L("generalInfo"), "faction", L("faction"), function()
        local factionName = team.GetName(client:Team())
        return L("factionMember", factionName)
    end)

    local classID = character:getClass()
    if not lia.class or not lia.class.list then return end
    local classData = lia.class.list[classID]
    if classID and classData and classData.name then hook.Run("AddTextField", L("generalInfo"), "class", L("class"), function() return L("classMember", classData.name) end) end
end

function MODULE:DrawCharInfo(client, character, info)
    if not lia.config.get("ClassDisplay", true) then return end
    local charClass = client:getClassData()
    if charClass then
        info[#info + 1] = {
            section = "Role"
        }
        info[#info + 1] = {
            label = "Class",
            value = charClass.name or L("undefinedClass")
        }
    end
end

local factionRosterPanel = nil
local factionMembersRequestTargets = {}
local factionRosterDetailCache = {}
local factionRosterPendingDetails = {}
local rosterSearchIcon = Material("icon16/magnifier.png", "smooth")
local rosterMemberIcon = Material("icon16/user.png", "smooth")
local rosterCopyIcon = Material("icon16/page_copy.png", "smooth")
local rosterProfileIcon = Material("icon16/world.png", "smooth")
local rosterNoteIcon = Material("icon16/note_edit.png", "smooth")
local rosterKickIcon = Material("icon16/user_delete.png", "smooth")
local function getRosterThemeColors()
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    local text = theme.text or Color(225, 238, 238)
    return accent, text
end

local function drawRosterPanel(x, y, w, h, radius, color, outline)
    if lia.derma and lia.derma.rect then
        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
        return
    end

    draw.RoundedBox(radius, x, y, w, h, color)
    if outline then
        surface.SetDrawColor(outline)
        surface.DrawOutlinedRect(x, y, w, h, 1)
    end
end

local function drawRosterIcon(material, x, y, size, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color or color_white)
    surface.DrawTexturedRect(x, y, size, size)
end

local function getRosterTextLength(text)
    if utf8 and utf8.len then
        local length = utf8.len(text)
        if length then return length end
    end
    return #text
end

local function getRosterTextPrefix(text, length)
    if length <= 0 then return "" end
    if utf8 and utf8.offset then
        local nextByte = utf8.offset(text, length + 1)
        if nextByte then return text:sub(1, nextByte - 1) end
    end
    return text:sub(1, length)
end

local function fitRosterText(text, font, maxWidth)
    text = tostring(text or "")
    maxWidth = math.max(0, tonumber(maxWidth) or 0)
    surface.SetFont(font)
    local textWidth = surface.GetTextSize(text)
    if textWidth <= maxWidth then return text end
    local ellipsis = "..."
    local ellipsisWidth = surface.GetTextSize(ellipsis)
    if ellipsisWidth > maxWidth then return "" end
    local low = 0
    local high = getRosterTextLength(text)
    while low < high do
        local mid = math.ceil((low + high) * 0.5)
        local candidate = getRosterTextPrefix(text, mid) .. ellipsis
        local candidateWidth = surface.GetTextSize(candidate)
        if candidateWidth <= maxWidth then
            low = mid
        else
            high = mid - 1
        end
    end
    return getRosterTextPrefix(text, low) .. ellipsis
end

local function getRosterFactionData(uniqueID)
    for id, faction in pairs(lia.faction.teams or {}) do
        if id == uniqueID or faction.uniqueID == uniqueID or faction.index == uniqueID then return faction end
    end

    local client = LocalPlayer()
    local character = IsValid(client) and client:getChar() or nil
    return character and lia.faction.get(character:getFaction()) or nil
end

local function getRosterMemberPresence(member)
    local lastOnlineText = member.lastOnline or L("unknown")
    local isOnline = lastOnlineText == L("onlineNow")
    local charID = tonumber(member and member.charID)
    if not isOnline and charID then
        local owner = lia.char.getOwnerByID(charID)
        local character = IsValid(owner) and owner:getChar() or nil
        if character and character:getID() == charID then
            isOnline = true
            lastOnlineText = L("onlineNow")
        end
    end

    if not isOnline and isstring(lastOnlineText) and lastOnlineText ~= L("unknown") then
        local timeParts = lia.time.toNumber(lastOnlineText)
        if timeParts and timeParts.year then
            local timestamp = os.time({
                year = timeParts.year,
                month = timeParts.month or 1,
                day = timeParts.day or 1,
                hour = timeParts.hour or 0,
                min = timeParts.min or 0,
                sec = timeParts.sec or 0
            })

            local lastDiff = os.time() - timestamp
            if lastDiff > 0 then
                local timeSince = lia.time.timeSince(timestamp)
                if timeSince and timeSince ~= L("invalidDate") and timeSince ~= L("invalidInput") then
                    local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                    lastOnlineText = L("agoFormat", timeStripped, lia.time.formatDHM(lastDiff))
                end
            end
        end
    end
    return isOnline, lastOnlineText
end

local function getRosterMemberClassName(member)
    if not member then return nil end
    if isstring(member.className) and member.className ~= "" then return member.className end
    local classIndex = tonumber(member.class)
    if not classIndex or classIndex <= 0 or not lia.class or not lia.class.list then return nil end
    local classData = lia.class.list[classIndex]
    return classData and classData.name or nil
end

local function getRosterFactionDisplayName(factionUniqueID)
    local faction = getRosterFactionData(factionUniqueID)
    if faction and faction.name then return tostring(L(faction.name)) end
    return tostring(factionUniqueID or L("unknown"))
end

local function formatRosterUnixTime(timestamp)
    timestamp = tonumber(timestamp)
    if not timestamp or timestamp <= 0 then return L("unknown") end
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

local function formatRosterDuration(seconds)
    seconds = tonumber(seconds)
    if not seconds or seconds < 0 then return L("unknown") end
    return lia.time.formatDHM(seconds)
end

local function formatRosterTransferSummary(entry)
    if not istable(entry) then return L("unknown"), L("unknown") end
    local fromFaction = entry.from and getRosterFactionDisplayName(entry.from) or "None"
    local toFaction = entry.to and getRosterFactionDisplayName(entry.to) or "None"
    local summary = string.format("%s -> %s", fromFaction, toFaction)
    if isstring(entry.reason) and entry.reason ~= "" then summary = string.format("%s (%s)", summary, entry.reason) end
    local actor = isstring(entry.byName) and entry.byName ~= "" and entry.byName or "System"
    return summary, string.format("%s | %s", actor, formatRosterUnixTime(entry.at))
end

local function getRosterCacheBucket(factionUniqueID)
    if not factionUniqueID then return {} end
    factionRosterDetailCache[factionUniqueID] = factionRosterDetailCache[factionUniqueID] or {}
    return factionRosterDetailCache[factionUniqueID]
end

local function getCachedRosterMemberDetails(factionUniqueID, charID)
    charID = tonumber(charID)
    if not factionUniqueID or not charID then return nil end
    return getRosterCacheBucket(factionUniqueID)[charID]
end

local function mergeRosterMemberDetails(member, factionUniqueID)
    if not member then return nil end
    local details = getCachedRosterMemberDetails(factionUniqueID, member.charID)
    if not details then return member end
    local merged = table.Copy(member)
    for key, value in pairs(details) do
        merged[key] = value
    end
    return merged
end

local function requestRosterMemberDetails(factionUniqueID, charID)
    charID = tonumber(charID)
    if not factionUniqueID or factionUniqueID == "" or not charID then return end
    local cacheBucket = getRosterCacheBucket(factionUniqueID)
    if cacheBucket[charID] or factionRosterPendingDetails[factionUniqueID .. ":" .. charID] then return end
    factionRosterPendingDetails[factionUniqueID .. ":" .. charID] = true
    net.Start("liaRequestFactionMemberDetails")
    net.WriteString(tostring(factionUniqueID))
    net.WriteUInt(charID, 32)
    net.SendToServer()
end

local function openFactionNoteEditor(member, factionUniqueID, onSaved)
    if not member or not member.charID or not factionUniqueID then return end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(560, 420)
    frame:Center()
    frame:SetTitle("Faction Note")
    frame:MakePopup()
    frame:DockPadding(12, 40, 12, 12)
    local info = frame:Add("DLabel")
    info:Dock(TOP)
    info:SetTall(48)
    info:SetWrap(true)
    info:SetFont("LiliaFont.17")
    info:SetTextColor(Color(215, 230, 230))
    info:SetText(string.format("Editing the faction note for %s in %s.", tostring(member.name or L("unknown")), getRosterFactionDisplayName(factionUniqueID)))
    local editor = frame:Add("DTextEntry")
    editor:Dock(FILL)
    editor:SetMultiline(true)
    editor:SetFont("LiliaFont.17")
    editor:SetText(tostring(member.factionNote or ""))
    editor:SetVerticalScrollbarEnabled(true)
    local footer = frame:Add("DPanel")
    footer:Dock(BOTTOM)
    footer:SetTall(78)
    footer:DockMargin(0, 10, 0, 0)
    footer.Paint = function() end
    local meta = footer:Add("DLabel")
    meta:Dock(TOP)
    meta:SetTall(26)
    meta:SetFont("LiliaFont.15")
    meta:SetTextColor(Color(175, 194, 194))
    local noteMeta = member.factionNoteMeta or {}
    if noteMeta.updatedAt or noteMeta.updatedBy then
        meta:SetText(string.format("Last updated: %s by %s", formatRosterUnixTime(noteMeta.updatedAt), noteMeta.updatedBy or "Unknown"))
    else
        meta:SetText("No faction note saved yet.")
    end

    local saveButton = footer:Add("DButton")
    saveButton:Dock(LEFT)
    saveButton:SetWide(170)
    saveButton:DockMargin(0, 10, 10, 0)
    saveButton:SetText("SAVE NOTE")
    saveButton:SetFont("LiliaFont.17")
    saveButton.DoClick = function()
        net.Start("liaSaveFactionNote")
        net.WriteUInt(tonumber(member.charID) or 0, 32)
        net.WriteString(tostring(factionUniqueID))
        net.WriteString(editor:GetValue() or "")
        net.SendToServer()
        if onSaved then onSaved(editor:GetValue() or "") end
        frame:Close()
        lia.websound.playButtonSound()
    end

    local clearButton = footer:Add("DButton")
    clearButton:Dock(LEFT)
    clearButton:SetWide(170)
    clearButton:DockMargin(0, 10, 0, 0)
    clearButton:SetText("CLEAR NOTE")
    clearButton:SetFont("LiliaFont.17")
    clearButton.DoClick = function()
        editor:SetText("")
        lia.websound.playButtonSound()
    end
end

local function addRosterDetailSection(parent, title, rows)
    local section = parent:Add("DPanel")
    section:Dock(TOP)
    section:SetTall(44 + #rows * 38)
    section:DockMargin(0, 0, 0, 12)
    section:DockPadding(14, 42, 14, 8)
    section.Paint = function(_, panelW, panelH)
        local accent = getRosterThemeColors()
        drawRosterPanel(0, 0, panelW, panelH, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
        draw.SimpleText(title, "LiliaFont.17", 14, 12, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
        surface.DrawRect(12, 36, panelW - 24, 1)
    end

    for _, rowData in ipairs(rows) do
        local row = section:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(38)
        row.Paint = function(_, panelW, panelH)
            draw.SimpleText(rowData[1], "LiliaFont.17", 0, panelH * 0.5, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(rowData[2], "LiliaFont.17", panelW, panelH * 0.5, Color(225, 236, 236), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(255, 255, 255, 16)
            surface.DrawRect(0, panelH - 1, panelW, 1)
        end
    end
end

function MODULE:CreateMenuButtons(tabs)
    if not lia.class or not lia.class.list then return end
    local joinable = lia.class.retrieveJoinable(LocalPlayer())
    if #joinable >= 1 then
        tabs["classes"] = {
            name = "classes",
            icon = "icon16/group.png",
            func = function(panel) panel:Add("liaClasses") end
        }
    end

    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    if character:hasFlags("F") then
        tabs["factionRoster"] = {
            name = "factionRoster",
            icon = "icon16/group_go.png",
            func = function(panel)
                panel:Clear()
                panel:DockPadding(6, 6, 6, 6)
                panel.Paint = nil
                local loadingLabel = panel:Add("DLabel")
                loadingLabel:Dock(FILL)
                loadingLabel:SetText(L("loading"))
                loadingLabel:SetTextColor(Color(150, 150, 150))
                loadingLabel:SetFont("LiliaFont.20")
                loadingLabel:SetContentAlignment(5)
                panel.loadingLabel = loadingLabel
                panel.factionRosterPanel = true
                factionRosterPanel = panel
                factionRosterDetailCache = {}
                factionRosterPendingDetails = {}
                local factionIndex = character:getFaction()
                local faction = lia.faction.get(factionIndex)
                if faction and faction.uniqueID then
                    factionMembersRequestTargets[faction.uniqueID] = panel
                    net.Start("liaRequestFactionMembers")
                    net.WriteString(faction.uniqueID)
                    net.SendToServer()
                else
                    loadingLabel:SetText(L("noFactionsFound"))
                end
            end
        }
    end
end

local factionManagementPanel = nil
local function getFactionManagementFactions()
    local factions = {}
    for uniqueID, faction in pairs(lia.faction.teams or {}) do
        if faction and faction.name then
            factions[#factions + 1] = {
                uniqueID = tostring(faction.uniqueID or uniqueID),
                name = tostring(L(faction.name))
            }
        end
    end

    table.sort(factions, function(a, b) return a.name:lower() < b.name:lower() end)
    return factions
end

local function requestFactionManagementMembers(panel, factionUniqueID)
    if not IsValid(panel) or not factionUniqueID or factionUniqueID == "" then return end
    panel.managementRequestedFaction = factionUniqueID
    panel.managementSelectedFaction = factionUniqueID
    panel.selectedRosterCharID = nil
    factionMembersRequestTargets[factionUniqueID] = panel
    net.Start("liaRequestFactionMembers")
    net.WriteString(factionUniqueID)
    net.SendToServer()
end

local function CreateFactionManagementUI(panel)
    panel:Clear()
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    panel.factionManagementPanel = true
    panel.managementFactions = getFactionManagementFactions()
    factionManagementPanel = panel
    if #panel.managementFactions == 0 then
        local noFactionsLabel = panel:Add("DLabel")
        noFactionsLabel:Dock(FILL)
        noFactionsLabel:SetText(L("noOptionsAvailable"))
        noFactionsLabel:SetTextColor(Color(150, 150, 150))
        noFactionsLabel:SetFont("LiliaFont.20")
        noFactionsLabel:SetContentAlignment(5)
        return
    end

    local loadingLabel = panel:Add("DLabel")
    loadingLabel:Dock(FILL)
    loadingLabel:SetText(L("loading"))
    loadingLabel:SetTextColor(Color(150, 150, 150))
    loadingLabel:SetFont("LiliaFont.20")
    loadingLabel:SetContentAlignment(5)
    panel.loadingLabel = loadingLabel
    requestFactionManagementMembers(panel, panel.managementFactions[1].uniqueID)
end

local function UpdateFactionRosterUI(panel, data)
    if not IsValid(panel) or not panel.factionRosterPanel and not panel.factionManagementPanel then return end
    if IsValid(panel.loadingLabel) then
        panel.loadingLabel:Remove()
        panel.loadingLabel = nil
    end

    panel:Clear()
    panel:DockPadding(0, 0, 0, 0)
    panel.Paint = function() end
    local members = data.members or {}
    local isManagement = panel.factionManagementPanel == true
    panel.rosterMembers = members
    panel.rosterFilter = panel.rosterFilter or "all"
    panel.rosterFactionUniqueID = data.faction
    if isManagement then panel.managementSelectedFaction = data.faction end
    local faction = getRosterFactionData(data.faction)
    local factionName = faction and faction.name and L(faction.name) or team.GetName(LocalPlayer():Team()) or L("unknown")
    local factionIcon = rosterMemberIcon
    if faction and isstring(faction.logo) and faction.logo ~= "" then factionIcon = Material(faction.logo, "smooth") end
    local header = panel:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(isManagement and 56 or 76)
    header.Paint = function(_, panelW)
        local accent, textColor = getRosterThemeColors()
        if not isManagement then
            draw.SimpleText("Faction Roster", "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Browse and inspect faction members.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleText("Browse and inspect faction members by faction.", "LiliaFont.17", 8, 18, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        if isManagement then
            local badgeW = math.Clamp(math.floor(panelW * 0.22), 210, 300)
            local badgeH = 42
            local badgeX = panelW - badgeW - 8
            local badgeY = 8
            drawRosterPanel(badgeX, badgeY, badgeW, badgeH, 5, Color(5, 18, 23, 210), Color(accent.r, accent.g, accent.b, 92))
            draw.SimpleText(factionName, "LiliaFont.17", badgeX + badgeW * 0.5, badgeY + badgeH * 0.5, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local content = panel:Add("DPanel")
    content:Dock(FILL)
    content.Paint = function() end
    local browser = content:Add("DPanel")
    browser:Dock(LEFT)
    browser:DockMargin(0, 0, 14, 0)
    browser:DockPadding(12, 12, 12, 12)
    browser.Paint = function(_, panelW, panelH)
        local accent = getRosterThemeColors()
        drawRosterPanel(0, 0, panelW, panelH, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    local searchRow = browser:Add("DPanel")
    searchRow:Dock(TOP)
    searchRow:SetTall(48)
    searchRow:DockMargin(0, 0, 0, 12)
    searchRow.Paint = function() end
    local filterCombo = searchRow:Add("DComboBox")
    filterCombo:Dock(RIGHT)
    filterCombo:SetWide(132)
    filterCombo:DockMargin(10, 0, 0, 0)
    filterCombo:SetFont("LiliaFont.17")
    filterCombo:SetTextColor(Color(205, 220, 220))
    filterCombo:SetContentAlignment(4)
    if isManagement then
        filterCombo:SetWide(160)
        for _, factionData in ipairs(panel.managementFactions or {}) do
            filterCombo:AddChoice(factionData.name, factionData.uniqueID, factionData.uniqueID == data.faction)
        end
    else
        filterCombo:AddChoice("All Members", "all", panel.rosterFilter == "all")
        filterCombo:AddChoice("Online", "online", panel.rosterFilter == "online")
        filterCombo:AddChoice("Offline", "offline", panel.rosterFilter == "offline")
    end

    filterCombo.Paint = function(_, panelW, panelH)
        local accent = getRosterThemeColors()
        drawRosterPanel(0, 0, panelW, panelH, 5, Color(5, 18, 23, 235), Color(accent.r, accent.g, accent.b, 92))
    end

    if IsValid(filterCombo.DropButton) then
        filterCombo.DropButton:SetWide(30)
        filterCombo.DropButton.Paint = function(_, panelW, panelH) draw.SimpleText("▼", "LiliaFont.17", panelW * 0.5, panelH * 0.5, Color(190, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    end

    local searchWrap = searchRow:Add("DPanel")
    searchWrap:Dock(FILL)
    searchWrap:DockPadding(40, 0, 8, 0)
    searchWrap.Paint = function(_, panelW, panelH)
        local accent = getRosterThemeColors()
        drawRosterPanel(0, 0, panelW, panelH, 5, Color(5, 18, 23, 235), Color(accent.r, accent.g, accent.b, 92))
        drawRosterIcon(rosterSearchIcon, 14, math.floor(panelH * 0.5) - 8, 16, Color(155, 181, 182))
    end

    local searchEntry = searchWrap:Add("DTextEntry")
    searchEntry:Dock(FILL)
    searchEntry:SetFont("LiliaFont.17")
    searchEntry:SetTextColor(Color(225, 236, 236))
    searchEntry:SetCursorColor(getRosterThemeColors())
    searchEntry:SetPlaceholderText("Search members...")
    searchEntry:SetDrawBackground(false)
    searchEntry:SetPaintBackground(false)
    searchEntry:SetPaintBorderEnabled(false)
    local rosterList = browser:Add("liaScrollPanel")
    rosterList:Dock(FILL)
    rosterList.Paint = function() end
    local rosterCanvas = rosterList:GetCanvas()
    if IsValid(rosterCanvas) then
        rosterCanvas:DockPadding(0, 0, 4, 0)
        rosterCanvas.Paint = function() end
    end

    local details = content:Add("DPanel")
    details:Dock(FILL)
    details:DockPadding(14, 14, 14, 14)
    details.Paint = function(_, panelW, panelH)
        local accent = getRosterThemeColors()
        drawRosterPanel(0, 0, panelW, panelH, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    content.PerformLayout = function(_, panelW) browser:SetWide(math.Clamp(math.floor(panelW * 0.31), 300, 390)) end
    local function buildMemberDetails(member)
        details:Clear()
        if not member then
            local empty = details:Add("DLabel")
            empty:Dock(FILL)
            empty:SetText(L("noOptionsAvailable"))
            empty:SetTextColor(Color(150, 170, 170))
            empty:SetFont("LiliaFont.20")
            empty:SetContentAlignment(5)
            return
        end

        member = mergeRosterMemberDetails(member, data.faction)
        panel.selectedRosterCharID = member.charID
        local isOnline, lastOnlineText = getRosterMemberPresence(member)
        local statusText = isOnline and "ONLINE" or "OFFLINE"
        local accent, textColor = getRosterThemeColors()
        local className = getRosterMemberClassName(member)
        local memberHeader = details:Add("DPanel")
        memberHeader:Dock(TOP)
        memberHeader:SetTall(116)
        memberHeader:DockMargin(0, 0, 0, 12)
        memberHeader.Paint = function(_, panelW, panelH)
            drawRosterPanel(0, 0, panelW, panelH, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
            surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
            surface.DrawRect(0, 0, 3, panelH)
            local iconSize = 66
            local iconX = 26
            local iconY = math.floor((panelH - iconSize) * 0.5)
            drawRosterIcon(factionIcon, iconX, iconY, iconSize, Color(240, 247, 247))
            local badgeW = 112
            local badgeH = 34
            local badgeX = panelW - badgeW - 22
            local badgeY = math.floor((panelH - badgeH) * 0.5)
            local badgeFill = isOnline and Color(accent.r, accent.g, accent.b, 20) or Color(255, 255, 255, 7)
            local badgeOutline = isOnline and Color(accent.r, accent.g, accent.b, 95) or Color(255, 255, 255, 28)
            local badgeTextColor = isOnline and accent or Color(145, 163, 164)
            drawRosterPanel(badgeX, badgeY, badgeW, badgeH, 5, badgeFill, badgeOutline)
            draw.RoundedBox(4, badgeX + 14, badgeY + 13, 8, 8, badgeTextColor)
            draw.SimpleText(statusText, "LiliaFont.15", badgeX + 31, badgeY + badgeH * 0.5, badgeTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local textX = iconX + iconSize + 24
            local nameMaxWidth = math.max(80, badgeX - textX - 24)
            local displayName = fitRosterText(member.name or L("unknown"), "LiliaFont.25", nameMaxWidth)
            draw.SimpleText(displayName, "LiliaFont.25", textX, 24, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local subtitleY = 73
            local subtitleX = textX
            if className and className ~= "" then
                local classText = tostring(className)
                local classWidth = draw.SimpleText(classText, "LiliaFont.17", subtitleX, subtitleY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                subtitleX = subtitleX + classWidth + 10
                local separatorWidth = draw.SimpleText("•", "LiliaFont.17", subtitleX, subtitleY, Color(100, 145, 145), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                subtitleX = subtitleX + separatorWidth + 10
            end

            local factionText = tostring(factionName)
            local factionWidth = draw.SimpleText(factionText, "LiliaFont.17", subtitleX, subtitleY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            subtitleX = subtitleX + factionWidth + 10
            local separatorWidth = draw.SimpleText("•", "LiliaFont.17", subtitleX, subtitleY, Color(100, 145, 145), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            subtitleX = subtitleX + separatorWidth + 10
            draw.SimpleText("Character #" .. tostring(member.charID or L("unknown")), "LiliaFont.17", subtitleX, subtitleY, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local detailScroll = details:Add("liaScrollPanel")
        detailScroll:Dock(FILL)
        detailScroll.Paint = function() end
        local canvas = detailScroll:GetCanvas()
        if IsValid(canvas) then
            canvas:DockPadding(0, 0, 4, 0)
            canvas.Paint = function() end
        else
            canvas = detailScroll
        end

        local generalRows = {{L("characterID"), tostring(member.charID or L("unknown"))}, {L("steamID"), tostring(member.steamID or L("unknown"))}, {L("faction"), tostring(factionName)}}
        if className then generalRows[#generalRows + 1] = {L("class"), tostring(className)} end
        if member.joinDate then generalRows[#generalRows + 1] = {"Join Date", formatRosterUnixTime(member.joinDate)} end
        local optionalRank = member.rank or member.role
        if optionalRank ~= nil and tostring(optionalRank) ~= "" then generalRows[#generalRows + 1] = {"Rank / Role", tostring(optionalRank)} end
        addRosterDetailSection(canvas, "GENERAL", generalRows)
        local statusRows = {{"Presence", isOnline and "Online" or "Offline"}, {L("lastOnline"), tostring(lastOnlineText)}, {"Last Active", isOnline and L("onlineNow") or tostring(member.lastActive or member.lastOnline or L("unknown"))}}
        if member.timeInFaction ~= nil then statusRows[#statusRows + 1] = {"Time in Faction", formatRosterDuration(member.timeInFaction)} end
        if member.playtimeInFaction ~= nil then statusRows[#statusRows + 1] = {"Playtime in Faction", formatRosterDuration(member.playtimeInFaction)} end
        local playtime = member.playtime or member.playTime
        if playtime ~= nil and tostring(playtime) ~= "" then statusRows[#statusRows + 1] = {L("playtime"), formatRosterDuration(playtime)} end
        addRosterDetailSection(canvas, "STATUS", statusRows)
        local transferRows = {}
        if member.transferHistory == nil then
            transferRows[#transferRows + 1] = {"Status", "Loading..."}
        else
            for index, entry in ipairs(member.transferHistory or {}) do
                if index > 6 then break end
                local summary, extra = formatRosterTransferSummary(entry)
                transferRows[#transferRows + 1] = {summary, extra}
            end
        end

        if #transferRows > 0 then addRosterDetailSection(canvas, "TRANSFER HISTORY", transferRows) end
        local noteRows = {}
        if member.factionNote == nil and member.factionNoteMeta == nil then
            noteRows[#noteRows + 1] = {"Status", "Loading..."}
        else
            local noteText = string.Trim(tostring(member.factionNote or ""))
            if noteText ~= "" then noteRows[#noteRows + 1] = {"Note", #noteText > 72 and noteText:sub(1, 69) .. "..." or noteText} end
            local noteMeta = member.factionNoteMeta or {}
            if noteMeta.updatedAt or noteMeta.updatedBy then noteRows[#noteRows + 1] = {"Updated", string.format("%s by %s", formatRosterUnixTime(noteMeta.updatedAt), noteMeta.updatedBy or "Unknown")} end
        end

        if #noteRows > 0 then addRosterDetailSection(canvas, "FACTION NOTE", noteRows) end
        local actions = canvas:Add("DPanel")
        actions:Dock(TOP)
        actions:SetTall(116)
        actions:DockMargin(0, 0, 0, 12)
        actions.Paint = function(_, panelW, panelH)
            local currentAccent = getRosterThemeColors()
            drawRosterPanel(0, 0, panelW, panelH, 6, Color(3, 16, 21, 185), Color(currentAccent.r, currentAccent.g, currentAccent.b, 68))
            draw.SimpleText("MEMBER ACTIONS", "LiliaFont.17", 14, 12, currentAccent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetDrawColor(currentAccent.r, currentAccent.g, currentAccent.b, 35)
            surface.DrawRect(12, 36, panelW - 24, 1)
        end

        local actionRow = actions:Add("DPanel")
        actionRow:Dock(FILL)
        actionRow:DockMargin(12, 44, 12, 12)
        actionRow.Paint = function() end
        local actionButtonCount = 0
        local function createActionButton(label, icon, isEnabled, onClick)
            local button = actionRow:Add("DButton")
            button:Dock(TOP)
            button:SetTall(38)
            button:DockMargin(0, 0, 0, 8)
            button:SetText("")
            button:SetEnabled(isEnabled)
            actionButtonCount = actionButtonCount + 1
            button.Paint = function(s, panelW, panelH)
                local currentAccent = getRosterThemeColors()
                local hovered = s:IsHovered() and s:IsEnabled()
                drawRosterPanel(0, 0, panelW, panelH, 5, hovered and Color(currentAccent.r, currentAccent.g, currentAccent.b, 28) or Color(5, 18, 23, 235), Color(currentAccent.r, currentAccent.g, currentAccent.b, hovered and 120 or 72))
                drawRosterIcon(icon, 14, math.floor(panelH * 0.5) - 8, 16, s:IsEnabled() and Color(185, 205, 205) or Color(100, 115, 115))
                draw.SimpleText(label, "LiliaFont.17", 40, panelH * 0.5, s:IsEnabled() and Color(220, 234, 234) or Color(110, 125, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function(self)
                if not self:IsEnabled() then return end
                onClick()
                lia.websound.playButtonSound()
            end
            return button
        end

        local function createCopyButton(label, value)
            return createActionButton(label, rosterCopyIcon, value ~= nil and tostring(value) ~= "", function() SetClipboardText(tostring(value)) end)
        end

        local steamID = tostring(member.steamID or "")
        local steamID64 = steamID ~= "" and util.SteamIDTo64(steamID) or nil
        createCopyButton("COPY CHARACTER ID", member.charID)
        createCopyButton("COPY STEAM ID", member.steamID)
        createCopyButton("COPY STEAM ID 64", steamID64)
        createActionButton("VIEW STEAM PROFILE", rosterProfileIcon, steamID64 ~= nil and steamID64 ~= "", function() gui.OpenURL("https://steamcommunity.com/profiles/" .. steamID64) end)
        createActionButton("EDIT FACTION NOTE", rosterNoteIcon, true, function()
            local detailedMember = mergeRosterMemberDetails(member, data.faction)
            if detailedMember.factionNote == nil and detailedMember.factionNoteMeta == nil then
                requestRosterMemberDetails(data.faction, detailedMember.charID)
                return
            end

            openFactionNoteEditor(detailedMember, data.faction, function(newNote)
                local cacheBucket = getRosterCacheBucket(data.faction)
                cacheBucket[detailedMember.charID] = cacheBucket[detailedMember.charID] or {}
                cacheBucket[detailedMember.charID].factionNote = newNote
            end)
        end)

        if isManagement then
            createActionButton(string.upper(tostring(L("kickToBaseFaction"))), rosterKickIcon, true, function()
                net.Start("liaKickCharacterToBase")
                net.WriteUInt(tonumber(member.charID) or 0, 32)
                net.SendToServer()
            end)
        end

        actions:SetTall(56 + actionButtonCount * 46)
        if getCachedRosterMemberDetails(data.faction, member.charID) == nil then requestRosterMemberDetails(data.faction, member.charID) end
    end

    local function rebuildRosterList()
        rosterList:Clear()
        local search = string.Trim(searchEntry:GetValue() or ""):lower()
        local firstMember
        local selectedMember
        local visibleCount = 0
        for _, member in ipairs(members) do
            local memberName = tostring(member.name or L("unknown"))
            local charID = tostring(member.charID or "")
            local steamID = tostring(member.steamID or "")
            local className = tostring(getRosterMemberClassName(member) or "")
            local isOnline = getRosterMemberPresence(member)
            local matchesSearch = search == "" or memberName:lower():find(search, 1, true) or charID:lower():find(search, 1, true) or steamID:lower():find(search, 1, true) or className:lower():find(search, 1, true)
            local matchesFilter = isManagement or panel.rosterFilter == "all" or panel.rosterFilter == "online" and isOnline or panel.rosterFilter == "offline" and not isOnline
            if not matchesSearch or not matchesFilter then continue end
            visibleCount = visibleCount + 1
            local currentMember = member
            local button = rosterList:Add("DButton")
            button:Dock(TOP)
            button:SetTall(64)
            button:DockMargin(0, 0, 0, 8)
            button:SetText("")
            button.Paint = function(s, panelW, panelH)
                local currentAccent = getRosterThemeColors()
                local active = panel.selectedRosterCharID == currentMember.charID
                local hovered = s:IsHovered()
                local online = getRosterMemberPresence(currentMember)
                local bg = active and Color(currentAccent.r, currentAccent.g, currentAccent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(2, 14, 18, 130)
                drawRosterPanel(0, 0, panelW, panelH, 5, bg, active and Color(currentAccent.r, currentAccent.g, currentAccent.b, 145) or Color(currentAccent.r, currentAccent.g, currentAccent.b, 42))
                if active then
                    surface.SetDrawColor(currentAccent.r, currentAccent.g, currentAccent.b, 245)
                    surface.DrawRect(0, 7, 3, panelH - 14)
                end

                drawRosterIcon(factionIcon, 14, 18, 28, active and Color(240, 247, 247) or Color(175, 196, 196))
                draw.SimpleText(memberName, "LiliaFont.18", 54, 12, active and Color(244, 248, 248) or Color(220, 232, 232), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                local presenceText = online and "Online" or "Offline"
                local subtitle = className ~= "" and string.format("%s | %s", className, presenceText) or presenceText
                draw.SimpleText(subtitle, "LiliaFont.15", 54, 38, className ~= "" and Color(185, 204, 204) or online and currentAccent or Color(135, 156, 157), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("#" .. charID, "LiliaFont.15", panelW - 12, panelH * 0.5, Color(135, 156, 157), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function()
                lia.websound.playButtonSound()
                panel.selectedRosterCharID = currentMember.charID
                buildMemberDetails(currentMember)
            end

            if not firstMember then firstMember = currentMember end
            if panel.selectedRosterCharID == currentMember.charID then selectedMember = currentMember end
        end

        if visibleCount == 0 then
            local empty = rosterList:Add("DLabel")
            empty:Dock(TOP)
            empty:SetTall(64)
            empty:SetText(L("noOptionsAvailable"))
            empty:SetTextColor(Color(145, 165, 166))
            empty:SetFont("LiliaFont.17")
            empty:SetContentAlignment(5)
            buildMemberDetails(nil)
            return
        end

        buildMemberDetails(selectedMember or firstMember)
    end

    filterCombo.OnSelect = function(_, _, _, value)
        if isManagement then
            if not value or value == "" or value == panel.managementSelectedFaction then return end
            requestFactionManagementMembers(panel, value)
            return
        end

        panel.rosterFilter = value or "all"
        rebuildRosterList()
    end

    searchEntry.OnChange = rebuildRosterList
    local compatibilityList = panel:Add("liaTable")
    compatibilityList:SetVisible(false)
    compatibilityList:SetSize(1, 1)
    compatibilityList:AddColumn(L("name"))
    compatibilityList:AddColumn(L("characterID"))
    for _, member in ipairs(members) do
        local line = compatibilityList:AddLine(member.name or L("unknown"), member.charID or L("unknown"))
        if line then
            line.charID = member.charID
            line.steamID = member.steamID
            line.name = member.name
        end
    end

    hook.Run("PopulateFactionRosterOptions", compatibilityList, members)
    compatibilityList:ForceCommit()
    panel.rosterCompatibilityList = compatibilityList
    rebuildRosterList()
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canListCharacters = client:hasPrivilege("listCharacters")
    if canListCharacters then
        table.insert(pages, {
            name = "@factionManagement",
            icon = "icon16/group.png",
            drawFunc = function(panel)
                if not panel.factionManagementInitialized then
                    panel.factionManagementInitialized = true
                    factionManagementPanel = panel
                    CreateFactionManagementUI(panel)
                end
            end
        })
    end
end

lia.net.readBigTable("liaFactionMembers", function(data)
    if not data or not data.faction then return end
    local requestTarget = factionMembersRequestTargets[data.faction]
    if requestTarget ~= nil then
        factionMembersRequestTargets[data.faction] = nil
        if IsValid(requestTarget) then
            if requestTarget.factionManagementPanel then
                local expectedFaction = requestTarget.managementRequestedFaction or requestTarget.managementSelectedFaction
                if expectedFaction == data.faction then
                    requestTarget.managementRequestedFaction = nil
                    UpdateFactionRosterUI(requestTarget, data)
                end
                return
            end

            if requestTarget.factionRosterPanel then
                UpdateFactionRosterUI(requestTarget, data)
                return
            end
        end
    end

    local managementPanel = factionManagementPanel
    if IsValid(managementPanel) and managementPanel.factionManagementPanel and managementPanel.managementSelectedFaction == data.faction then
        UpdateFactionRosterUI(managementPanel, data)
        return
    end

    local rosterPanel = factionRosterPanel
    if not IsValid(rosterPanel) and IsValid(lia.gui.menu) and IsValid(lia.gui.menu.panel) then
        for _, child in ipairs(lia.gui.menu.panel:GetChildren()) do
            if IsValid(child) and child.factionRosterPanel then
                rosterPanel = child
                factionRosterPanel = child
                break
            end
        end
    end

    if IsValid(rosterPanel) and rosterPanel.factionRosterPanel then UpdateFactionRosterUI(rosterPanel, data) end
end)

lia.net.readBigTable("liaFactionMemberDetails", function(data)
    if not data or not data.faction or not data.charID then return end
    local charID = tonumber(data.charID)
    if not charID then return end
    factionRosterPendingDetails[data.faction .. ":" .. charID] = nil
    if not istable(data.member) then return end
    getRosterCacheBucket(data.faction)[charID] = data.member
    local managementPanel = factionManagementPanel
    if IsValid(managementPanel) and managementPanel.factionManagementPanel and managementPanel.rosterFactionUniqueID == data.faction and managementPanel.selectedRosterCharID == charID then
        UpdateFactionRosterUI(managementPanel, {
            faction = data.faction,
            members = managementPanel.rosterMembers or {}
        })
    end

    local rosterPanel = factionRosterPanel
    if IsValid(rosterPanel) and rosterPanel.factionRosterPanel and rosterPanel.rosterFactionUniqueID == data.faction and rosterPanel.selectedRosterCharID == charID then
        UpdateFactionRosterUI(rosterPanel, {
            faction = data.faction,
            members = rosterPanel.rosterMembers or {}
        })
    end
end)
