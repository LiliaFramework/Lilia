--[[
    Hooks:
        ShowPlayerOptions(Player target, table options)

    Purpose:
        Allows modules to append clickable player actions to the scoreboard options menu for a target player.

    Category:
        Administration

    Parameters:
        target (Player)
            The player whose options menu is being built.

        options (table)
            The mutable array of option tables consumed by the scoreboard UI.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("ShowPlayerOptions", "liaExampleShowPlayerOptions", function(target, options)
            if target:getChar() then
                options[#options + 1] = {
                    name = "Print Name",
                    image = "icon16/information.png",
                    func = function()
                        print(target:getChar():getName())
                    end
                }
            end
        end)
        ```

    Realm:
        Client
]]
local MODULE = MODULE
local flagsData
local charListRequestID = 0
local CHAR_LIST_PAGE_SIZE = 100
local function requestFullCharListPage(panel, offset)
    if not IsValid(panel) then return end
    net.Start("liaRequestFullCharListPage")
    net.WriteUInt(panel.charListRequestID or 0, 16)
    net.WriteUInt(math.max(0, tonumber(offset) or 0), 32)
    net.WriteUInt(CHAR_LIST_PAGE_SIZE, 16)
    net.SendToServer()
end

function MODULE:startFullCharListRequest(panel)
    if not IsValid(panel) then return end
    charListRequestID = (charListRequestID + 1) % 65535
    panel.charListRequestID = charListRequestID
    panel.charListLoadedCount = 0
    panel.charListTotalCount = 0
    panel.charListBuilt = false
    panel:Clear()
    panel:DockPadding(16, 16, 16, 16)
    panel.Paint = nil
    local loading = panel:Add("DLabel")
    loading:Dock(FILL)
    loading:SetFont("LiliaFont.20")
    loading:SetText("Loading character records...")
    loading:SetTextColor(Color(180, 190, 190))
    loading:SetContentAlignment(5)
    requestFullCharListPage(panel, 0)
end

function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if not IsValid(client) or not IsValid(target) then return end
    local userGroup = client:GetUserGroup()
    local isAdmin = userGroup == "admin" or userGroup == "superadmin" or userGroup == "owner" or userGroup == "moderator"
    local canAccessScoreboardInfoOutOfStaff = client:hasPrivilege("canAccessScoreboardInfoOutOfStaff")
    local canAccessScoreboardAdminOptions = client:hasPrivilege("canAccessScoreboardAdminOptions")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = isAdmin or canAccessScoreboardInfoOutOfStaff or (canAccessScoreboardAdminOptions and isStaffOnDuty)
    if not permission then return end
    local orderedOptions = {}
    table.insert(orderedOptions, {
        name = L("nameCopyFormat", target:Name()),
        image = "icon16/page_copy.png",
        func = function()
            client:notifySuccessLocalized("copiedToClipboard", target:Name(), L("name"))
            SetClipboardText(target:Name())
        end
    })

    local charID = target:getChar() and target:getChar():getID() or L("na")
    table.insert(orderedOptions, {
        name = L("charIDCopyFormat", charID),
        image = "icon16/page_copy.png",
        func = function()
            if target:getChar() then
                client:notifySuccessLocalized("copiedCharID", target:getChar():getID())
                SetClipboardText(target:getChar():getID())
            end
        end
    })

    table.insert(orderedOptions, {
        name = L("steamIDCopyFormat", target:SteamID()),
        image = "icon16/page_copy.png",
        func = function()
            client:notifySuccessLocalized("copiedToClipboard", target:Name(), L("steamID"))
            SetClipboardText(target:SteamID())
        end
    })

    local isBlinded = timer.Exists("liaBlind" .. target:SteamID())
    if not isBlinded then
        table.insert(orderedOptions, {
            name = L("blind"),
            image = "icon16/eye.png",
            func = function() lia.admin.execCommand("blind", target) end
        })
    end

    if not target:IsFrozen() then
        table.insert(orderedOptions, {
            name = L("freeze"),
            image = "icon16/lock.png",
            func = function() lia.admin.execCommand("freeze", target) end
        })
    end

    if not target:getLiliaData("liaGagged", false) then
        table.insert(orderedOptions, {
            name = L("gag"),
            image = "icon16/sound_mute.png",
            func = function() lia.admin.execCommand("gag", target) end
        })
    end

    if not target:IsOnFire() then
        table.insert(orderedOptions, {
            name = L("ignite"),
            image = "icon16/fire.png",
            func = function() lia.admin.execCommand("ignite", target) end
        })
    end

    if not target:isLocked() then
        table.insert(orderedOptions, {
            name = L("jail"),
            image = "icon16/lock.png",
            func = function() lia.admin.execCommand("jail", target) end
        })
    end

    if not (target:getChar() and target:getLiliaData("liaMuted", false)) then
        table.insert(orderedOptions, {
            name = L("mute"),
            image = "icon16/sound_delete.png",
            func = function() lia.admin.execCommand("mute", target) end
        })
    end

    table.insert(orderedOptions, {
        name = L("slay"),
        image = "icon16/bomb.png",
        func = function() lia.admin.execCommand("slay", target) end
    })

    table.insert(orderedOptions, {
        name = L("bring"),
        image = "icon16/arrow_down.png",
        func = function() lia.admin.execCommand("bring", target) end
    })

    table.insert(orderedOptions, {
        name = L("goTo"),
        image = "icon16/arrow_right.png",
        func = function() lia.admin.execCommand("goto", target) end
    })

    table.insert(orderedOptions, {
        name = L("respawn"),
        image = "icon16/arrow_refresh.png",
        func = function() lia.admin.execCommand("respawn", target) end
    })

    table.insert(orderedOptions, {
        name = L("returnText"),
        image = "icon16/arrow_redo.png",
        func = function() lia.admin.execCommand("return", target) end
    })

    if isBlinded then
        table.insert(orderedOptions, {
            name = L("unblind"),
            image = "icon16/eye.png",
            func = function() lia.admin.execCommand("unblind", target) end
        })
    end

    if target:getLiliaData("liaGagged", false) then
        table.insert(orderedOptions, {
            name = L("ungag"),
            image = "icon16/sound_low.png",
            func = function() lia.admin.execCommand("ungag", target) end
        })
    end

    if target:IsFrozen() then
        table.insert(orderedOptions, {
            name = L("unfreeze"),
            image = "icon16/accept.png",
            func = function() lia.admin.execCommand("unfreeze", target) end
        })
    end

    if target:getChar() and target:getLiliaData("liaMuted", false) then
        table.insert(orderedOptions, {
            name = L("unmute"),
            image = "icon16/sound_add.png",
            func = function() lia.admin.execCommand("unmute", target) end
        })
    end

    if target:IsOnFire() then
        table.insert(orderedOptions, {
            name = L("extinguish"),
            image = "icon16/fire_delete.png",
            func = function() lia.admin.execCommand("extinguish", target) end
        })
    end

    if target:isLocked() then
        table.insert(orderedOptions, {
            name = L("unjail"),
            image = "icon16/lock_open.png",
            func = function() lia.admin.execCommand("unjail", target) end
        })
    end

    for _, v in ipairs(orderedOptions) do
        if v then options[#options + 1] = v end
    end
end

local function OpenFlagsPanel(panel, data)
    panel:Clear()
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    if not data or #data == 0 then
        local noDataLabel = panel:Add("DLabel")
        noDataLabel:Dock(FILL)
        noDataLabel:SetText(L("flagsNoPlayersOnlineHelp"))
        noDataLabel:SetFont("LiliaFont.17")
        noDataLabel:SetTextColor(Color(150, 150, 150))
        noDataLabel:SetContentAlignment(5)
        noDataLabel:SetWrap(true)
        return
    end

    local search = panel:Add("liaEntry")
    search:Dock(TOP)
    search:DockMargin(0, 20, 0, 15)
    search:SetTall(30)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    local list = panel:Add("liaTable")
    list:Dock(FILL)
    panel.searchEntry = search
    panel.list = list
    panel.populating = false
    panel:InvalidateLayout(true)
    panel:SizeToChildren(false, true)
    local columns = {
        {
            name = L("name"),
            field = "name"
        },
        {
            name = L("steamID"),
            field = "steamID"
        },
        {
            name = L("charFlagsTitle"),
            field = "flags"
        },
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

    list:AddMenuOption(L("copyRow"), function(rowData)
        local rowString = ""
        for i, column in ipairs(columns) do
            local header = column.name or L("columnWithNumber", i)
            local value = tostring(rowData[i] or "")
            rowString = rowString .. header .. " " .. value .. " | "
        end

        SetClipboardText(string.sub(rowString, 1, -4))
    end, "icon16/page_copy.png")

    list:AddMenuOption(L("modifyCharFlags"), function(rowData)
        local steamID = rowData[2] or ""
        local currentFlags = rowData[3] or ""
        LocalPlayer():requestString("@modifyCharFlags", "@modifyFlagsDesc", function(text)
            if text == false then return end
            text = string.gsub(text or "", "%s", "")
            net.Start("liaModifyFlags")
            net.WriteString(steamID)
            net.WriteString(text)
            net.SendToServer()
        end, currentFlags)
    end, "icon16/flag_green.png")

    local function populate(filter)
        if panel.populating then return end
        panel.populating = true
        list:Clear()
        filter = string.lower(filter or "")
        local addedEntries = {}
        for _, entry in ipairs(data or {}) do
            local name = entry.name or ""
            local steamID = entry.steamID or ""
            local cFlags = entry.flags or ""
            local entryKey = steamID .. "|" .. name
            if not addedEntries[entryKey] then
                local values = {name, steamID, cFlags}
                local match = false
                if filter == "" then
                    match = true
                else
                    for _, value in ipairs(values) do
                        if tostring(value):lower():find(filter, 1, true) then
                            match = true
                            break
                        end
                    end
                end

                if match then
                    local line = list:AddLine(unpack(values))
                    line.steamID = steamID
                    addedEntries[entryKey] = true
                end
            end
        end

        panel.populating = false
        list:ForceCommit()
        list:InvalidateLayout(true)
        if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
    end

    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
    list:AddMenuOption(L("noOptionsAvailable"), function() end)
end

local CASE_MODE_ALL = "all"
local CASE_MODE_TICKETS = "tickets"
local CASE_MODE_WARNINGS = "warnings"
local CASE_MODE_PKS = "pks"
local STAFF_CASES_ACCENTS = {
    ticket = Color(70, 170, 255),
    warning = Color(255, 170, 60),
    warning_high = Color(235, 100, 80),
    pk = Color(190, 75, 75),
    neutral = Color(120, 190, 255)
}

local function staffCasesFormatTime(value)
    local timestamp = tonumber(value) or 0
    if timestamp <= 0 then return L("unknown") end
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

local function staffCasesText(value, fallback)
    value = tostring(value or "")
    if value == "" then return fallback or L("na") end
    return value
end

local function staffCasesTrim(value, limit)
    value = tostring(value or "")
    limit = limit or 72
    if #value <= limit then return value end
    return string.Trim(string.sub(value, 1, math.max(limit - 3, 1))) .. "..."
end

local function staffCasesPlayerBySteamID(steamID)
    steamID = tostring(steamID or "")
    if steamID == "" then return nil end
    return lia.util.getBySteamID(steamID)
end

local function staffCasesCommand(command, arg)
    if not command or arg == nil then return end
    lia.command.send(command, tostring(arg))
end

local function sanitizeCharacterFlags(flags)
    local cleaned = tostring(flags or ""):gsub("%s", "")
    local seen = {}
    local ordered = {}
    for i = 1, #cleaned do
        local flag = cleaned:sub(i, i)
        if not seen[flag] then
            seen[flag] = true
            ordered[#ordered + 1] = flag
        end
    end
    return table.concat(ordered)
end

local function staffCasesSeverityScore(caseData)
    if caseData.caseType == "ticket" then return caseData.claimed and 2 or 3 end
    if caseData.caseType == "pk" then return 4 end
    local severity = string.lower(caseData.severityLabel or "medium")
    if severity == "critical" then return 4 end
    if severity == "high" then return 3 end
    if severity == "medium" then return 2 end
    return 1
end

function MODULE:GetStaffCasesPermissions(client)
    client = client or LocalPlayer()
    local canSeeTickets = IsValid(client) and (client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty()) or false
    local canSeeWarnings = IsValid(client) and client:hasPrivilege("viewPlayerWarnings") or false
    local canSeePks = IsValid(client) and client:hasPrivilege("manageCharacters") or false
    return {
        tickets = canSeeTickets,
        warnings = canSeeWarnings,
        pks = canSeePks,
        any = canSeeTickets or canSeeWarnings or canSeePks
    }
end

function MODULE:HandleStaffCasesPayload(kind, data)
    self.staffCasesPayload = self.staffCasesPayload or {
        tickets = {},
        warnings = {},
        pks = {}
    }

    if not self.staffCasesPayload[kind] then return false end
    self.staffCasesPayload[kind] = data or {}
    local panel = self.staffCasesPanel
    if IsValid(panel) and isfunction(panel.RefreshData) then panel:RefreshData() end
    return IsValid(panel)
end

function MODULE:OpenStaffCases(panel)
    if not IsValid(panel) then return end
    self.staffCasesPayload = self.staffCasesPayload or {
        tickets = {},
        warnings = {},
        pks = {}
    }

    local permissions = self:GetStaffCasesPermissions(LocalPlayer())
    local accent = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme or Color(184, 132, 74)
    local panelColor = Color(4, 18, 23, 242)
    local panelColorSoft = Color(7, 24, 29, 238)
    local panelColorHovered = Color(12, 31, 36, 244)
    local selectedColor = Color(22, 31, 32, 250)
    local borderColor = Color(47, 59, 57, 220)
    local textColor = Color(230, 238, 236)
    local mutedTextColor = Color(150, 168, 166)
    local goodColor = Color(75, 205, 130)
    local badColor = Color(220, 95, 95)
    local warningColor = Color(230, 164, 70)
    local infoColor = Color(90, 170, 235)
    self.staffCasesPanel = panel
    panel:Clear()
    panel:DockPadding(10, 10, 10, 10)
    panel.Paint = nil
    panel.casePermissions = permissions
    panel.caseState = {
        mode = CASE_MODE_ALL,
        status = "all",
        search = "",
        selectedID = nil,
        selectedCase = nil
    }

    panel.caseButtons = {}
    panel.statCards = {}
    panel.caseRows = {}
    local function drawPanel(x, y, w, h, radius, color, outline)
        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
    end

    local function styleScrollBar(scrollPanel)
        if not IsValid(scrollPanel) or not IsValid(scrollPanel.VBar) then return end
        local vbar = scrollPanel.VBar
        vbar:SetWide(8)
        vbar.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 4)
            surface.DrawRect(0, 0, w, h)
        end

        vbar.btnUp.Paint = function() end
        vbar.btnDown.Paint = function() end
        vbar.btnGrip.Paint = function(_, w, h) drawPanel(1, 0, w - 2, h, 4, Color(accent.r, accent.g, accent.b, 145)) end
    end

    local function relativeTime(value)
        local timestamp = tonumber(value) or 0
        if timestamp <= 0 then return L("unknown") end
        local delta = math.max(os.time() - timestamp, 0)
        if delta < 60 then return "Now" end
        if delta < 3600 then return math.floor(delta / 60) .. "m ago" end
        if delta < 86400 then return math.floor(delta / 3600) .. "h ago" end
        return math.floor(delta / 86400) .. "d ago"
    end

    local function titleCase(value)
        value = tostring(value or "")
        if value == "" then return "" end
        return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2)
    end

    local function statusColor(caseData)
        if caseData.caseType == "ticket" then return caseData.claimed and infoColor or goodColor end
        if caseData.caseType == "warning" then
            local severity = string.lower(caseData.severityLabel or "medium")
            if severity == "high" or severity == "critical" then return badColor end
            return warningColor
        end
        return caseData.online and goodColor or mutedTextColor
    end

    local function typeColor(caseData)
        if caseData.caseType == "ticket" then return STAFF_CASES_ACCENTS.ticket end
        if caseData.caseType == "warning" then return STAFF_CASES_ACCENTS.warning end
        return STAFF_CASES_ACCENTS.pk
    end

    local function makeSection(parent, title, height)
        local section = parent:Add("DPanel")
        section:Dock(TOP)
        section:SetTall(height)
        section:DockMargin(0, 0, 0, 10)
        section:DockPadding(12, 34, 12, 8)
        section.Paint = function(_, w, h)
            drawPanel(0, 0, w, h, 5, Color(5, 20, 25, 225), Color(accent.r, accent.g, accent.b, 55))
            draw.SimpleText(string.upper(title), "LiliaFont.15", 12, 10, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
            surface.DrawRect(12, 30, w - 24, 1)
        end
        return section
    end

    local function addInfoRow(parent, label, valueFunc, colorFunc)
        local row = parent:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(30)
        row.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(0, h - 1, w, 1)
            draw.SimpleText(label, "LiliaFont.15", 0, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local color = colorFunc and colorFunc() or textColor
            draw.SimpleText(tostring(valueFunc() or ""), "LiliaFont.15", w, h * 0.5, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        return row
    end

    function panel:OnRemove()
        if MODULE.staffCasesPanel == self then MODULE.staffCasesPanel = nil end
    end

    function panel:BuildShell()
        local statsRow = self:Add("DPanel")
        statsRow:Dock(TOP)
        statsRow:SetTall(66)
        statsRow:DockMargin(0, 0, 0, 10)
        statsRow.Paint = nil
        self.statsRow = statsRow
        local cards = {
            {
                key = "tickets",
                title = "Tickets",
                accent = STAFF_CASES_ACCENTS.ticket
            },
            {
                key = "unclaimed",
                title = "Unclaimed",
                accent = Color(105, 175, 215)
            },
            {
                key = "warnings",
                title = "Warnings",
                accent = STAFF_CASES_ACCENTS.warning
            },
            {
                key = "pks",
                title = "PK Cases",
                accent = STAFF_CASES_ACCENTS.pk
            }
        }

        for _, info in ipairs(cards) do
            local card = statsRow:Add("DPanel")
            card.Paint = function(_, w, h)
                drawPanel(0, 0, w, h, 6, panelColorSoft, Color(255, 255, 255, 10))
                surface.SetDrawColor(info.accent.r, info.accent.g, info.accent.b, 235)
                surface.DrawRect(0, 0, 3, h)
                draw.SimpleText(info.title, "LiliaFont.15", 14, 12, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local value = card:Add("DLabel")
            value:SetFont("LiliaFont.22")
            value:SetText("0")
            value:SetTextColor(textColor)
            value:SetPos(14, 30)
            value:SetSize(120, 28)
            self.statCards[info.key] = value
            info.panel = card
        end

        statsRow.PerformLayout = function(_, w, h)
            local gap = 10
            local width = math.floor((w - gap * 3) / 4)
            for i, info in ipairs(cards) do
                info.panel:SetPos((i - 1) * (width + gap), 0)
                info.panel:SetSize(i == #cards and w - (i - 1) * (width + gap) or width, h)
            end
        end

        local modeBar = self:Add("DPanel")
        modeBar:Dock(TOP)
        modeBar:SetTall(34)
        modeBar:DockMargin(0, 0, 0, 10)
        modeBar.Paint = nil
        local modes = {
            {
                id = CASE_MODE_ALL,
                label = "All",
                access = true,
                width = 72
            },
            {
                id = CASE_MODE_TICKETS,
                label = "Tickets",
                access = permissions.tickets,
                width = 92
            },
            {
                id = CASE_MODE_WARNINGS,
                label = "Warnings",
                access = permissions.warnings,
                width = 100
            },
            {
                id = CASE_MODE_PKS,
                label = "PK Cases",
                access = permissions.pks,
                width = 94
            }
        }

        for _, info in ipairs(modes) do
            local button = modeBar:Add("DButton")
            button:Dock(LEFT)
            button:DockMargin(0, 0, 8, 0)
            button:SetWide(info.width)
            button:SetText("")
            button.Disabled = not info.access
            button.Paint = function(this, w, h)
                local active = self.caseState.mode == info.id
                local hovered = this:IsHovered() and not this.Disabled
                local background = active and selectedColor or hovered and panelColorHovered or panelColorSoft
                local outline = active and Color(accent.r, accent.g, accent.b, 170) or Color(borderColor.r, borderColor.g, borderColor.b, 180)
                drawPanel(0, 0, w, h, 5, background, outline)
                draw.SimpleText(info.label, "LiliaFont.16", w * 0.5, h * 0.5, this.Disabled and Color(100, 108, 112) or textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function(this)
                if this.Disabled then return end
                self.caseState.mode = info.id
                self:RefreshData()
                lia.websound.playButtonSound()
            end

            self.caseButtons[info.id] = button
        end

        local searchRow = self:Add("DPanel")
        searchRow:Dock(TOP)
        searchRow:SetTall(40)
        searchRow:DockMargin(0, 0, 0, 12)
        searchRow.Paint = nil
        local refreshButton = searchRow:Add("liaButton")
        refreshButton:Dock(RIGHT)
        refreshButton:SetWide(104)
        refreshButton:SetText("Refresh")
        refreshButton.DoClick = function()
            self:RequestData()
            lia.websound.playButtonSound()
        end

        local statusButton = searchRow:Add("DButton")
        statusButton:Dock(RIGHT)
        statusButton:SetWide(150)
        statusButton:DockMargin(8, 0, 8, 0)
        statusButton:SetText("")
        statusButton.optionIndex = 1
        statusButton.options = {
            {
                value = "all",
                label = "All Status"
            },
            {
                value = "open",
                label = "Open"
            },
            {
                value = "claimed",
                label = "Claimed"
            },
            {
                value = "high",
                label = "High Severity"
            },
            {
                value = "online",
                label = "Online"
            },
            {
                value = "offline",
                label = "Offline"
            }
        }

        statusButton.Paint = function(this, w, h)
            drawPanel(0, 0, w, h, 5, this:IsHovered() and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, this:IsHovered() and 100 or 55))
            local option = this.options[this.optionIndex]
            draw.SimpleText(option.label, "LiliaFont.15", 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("▼", "LiliaFont.13", w - 12, h * 0.5, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        statusButton.DoClick = function(this)
            this.optionIndex = this.optionIndex % #this.options + 1
            self.caseState.status = this.options[this.optionIndex].value
            self:RefreshData()
            lia.websound.playButtonSound()
        end

        self.statusButton = statusButton
        local searchEntry = searchRow:Add("liaEntry")
        searchEntry:Dock(FILL)
        searchEntry:SetFont("LiliaFont.16")
        searchEntry:SetPlaceholderText("Search cases...")
        searchEntry:SetTextColor(textColor)
        searchEntry.OnTextChanged = function(_, value)
            self.caseState.search = string.Trim(string.lower(value or ""))
            self:RefreshData()
        end

        self.searchEntry = searchEntry
        local body = self:Add("DPanel")
        body:Dock(FILL)
        body.Paint = nil
        local detailWrap = body:Add("DPanel")
        detailWrap:Dock(RIGHT)
        detailWrap:SetWide(math.max(330, ScrW() * 0.285))
        detailWrap:DockMargin(12, 0, 0, 0)
        detailWrap:DockPadding(12, 12, 12, 12)
        detailWrap.Paint = function(_, w, h) drawPanel(0, 0, w, h, 6, panelColor, borderColor) end
        local detailScroll = detailWrap:Add("DScrollPanel")
        detailScroll:Dock(FILL)
        detailScroll.Paint = nil
        styleScrollBar(detailScroll)
        self.detailPanel = detailScroll
        local listWrap = body:Add("DPanel")
        listWrap:Dock(FILL)
        listWrap:DockPadding(0, 0, 0, 0)
        listWrap.Paint = function(_, w, h) drawPanel(0, 0, w, h, 6, panelColor, borderColor) end
        local listHeader = listWrap:Add("DPanel")
        listHeader:Dock(TOP)
        listHeader:SetTall(34)
        listHeader.Paint = function(_, w, h)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 50)
            surface.DrawRect(0, h - 1, w, 1)
            draw.SimpleText("TYPE", "LiliaFont.14", 12, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("SUBJECT / TARGET", "LiliaFont.14", w * 0.14, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("SUBMITTED BY", "LiliaFont.14", w * 0.48, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("TIME", "LiliaFont.14", w * 0.70, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("STATUS", "LiliaFont.14", w * 0.84, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local caseList = listWrap:Add("DScrollPanel")
        caseList:Dock(FILL)
        caseList.Paint = nil
        styleScrollBar(caseList)
        self.caseList = caseList
    end

    function panel:BuildCases()
        local records = {}
        local payload = MODULE.staffCasesPayload or {}
        local permissionsRef = self.casePermissions or {}
        if permissionsRef.tickets then
            for _, ticket in ipairs(payload.tickets or {}) do
                local steamID = staffCasesText(ticket.requesterSteamID or ticket.requester, "")
                local requester = staffCasesPlayerBySteamID(steamID)
                local adminSteamID = staffCasesText(ticket.adminSteamID or ticket.admin, "")
                local admin = staffCasesPlayerBySteamID(adminSteamID)
                local isLiveTicket = ticket.live ~= false
                local claimed = adminSteamID ~= ""
                local requesterName = IsValid(requester) and requester:Nick() or staffCasesText(ticket.requester ~= "" and ticket.requester or steamID)
                local adminName = claimed and (IsValid(admin) and admin:Nick() or staffCasesText(ticket.admin ~= "" and ticket.admin or adminSteamID)) or "Unclaimed"
                records[#records + 1] = {
                    caseID = "ticket:" .. steamID .. ":" .. tostring(ticket.timestamp or 0) .. ":" .. tostring(ticket.message or ""),
                    caseType = "ticket",
                    typeLabel = "Ticket",
                    timestamp = tonumber(ticket.timestamp) or 0,
                    timestampText = staffCasesFormatTime(ticket.timestamp),
                    targetName = requesterName,
                    targetDisplay = requesterName,
                    steamID = steamID,
                    online = IsValid(requester),
                    staffDisplay = adminName,
                    staffName = adminName,
                    message = staffCasesText(ticket.message, ""),
                    summaryText = staffCasesTrim(ticket.message, 72),
                    statusText = isLiveTicket and (claimed and "In Progress" or "Open") or "Claimed",
                    metaText = isLiveTicket and (claimed and "Claimed" or "Unclaimed") or "Historical",
                    claimed = claimed,
                    live = isLiveTicket,
                    claimTarget = IsValid(requester) and requester or nil,
                    claimSteamID = adminSteamID,
                    severityLabel = claimed and "medium" or "high",
                    accent = STAFF_CASES_ACCENTS.ticket,
                    raw = ticket
                }
            end
        end

        if permissionsRef.warnings then
            for _, warning in ipairs(payload.warnings or {}) do
                local warnedSteamID = staffCasesText(warning.warnedSteamID, "")
                local warnedPly = staffCasesPlayerBySteamID(warnedSteamID)
                local severityText = string.lower(staffCasesText(warning.severity, "Medium"))
                local warnedName = staffCasesText(warning.warned)
                records[#records + 1] = {
                    caseID = "warning:" .. tostring(warning.id or warning.ID or warning.timestamp or #records + 1),
                    caseType = "warning",
                    typeLabel = "Warning",
                    timestamp = tonumber(warning.timestamp) or 0,
                    timestampText = staffCasesFormatTime(warning.timestamp),
                    targetName = warnedName,
                    targetDisplay = warnedName,
                    steamID = warnedSteamID,
                    online = IsValid(warnedPly),
                    staffDisplay = staffCasesText(warning.warner),
                    staffName = staffCasesText(warning.warner),
                    message = staffCasesText(warning.message, ""),
                    summaryText = staffCasesTrim(warning.message, 72),
                    severityLabel = severityText,
                    statusText = titleCase(severityText),
                    metaText = titleCase(severityText),
                    claimed = false,
                    charID = tonumber(warning.charID) or nil,
                    warningID = tonumber(warning.id or warning.ID) or tonumber(warning.index) or nil,
                    accent = severityText == "high" and STAFF_CASES_ACCENTS.warning_high or STAFF_CASES_ACCENTS.warning,
                    raw = warning
                }
            end
        end

        if permissionsRef.pks then
            for _, pkCase in ipairs(payload.pks or {}) do
                local steamID = staffCasesText(pkCase.steamID, "")
                local owner = staffCasesPlayerBySteamID(steamID)
                local submitterName = staffCasesText(pkCase.submitterName)
                local targetName = staffCasesText(pkCase.player)
                records[#records + 1] = {
                    caseID = "pk:" .. tostring(pkCase.id or pkCase.charID or #records + 1),
                    caseType = "pk",
                    typeLabel = "PK Case",
                    timestamp = tonumber(pkCase.timestamp) or 0,
                    timestampText = staffCasesFormatTime(pkCase.timestamp),
                    targetName = targetName,
                    targetDisplay = targetName,
                    steamID = steamID,
                    online = IsValid(owner),
                    staffDisplay = submitterName,
                    staffName = submitterName,
                    reason = staffCasesText(pkCase.reason, ""),
                    evidence = staffCasesText(pkCase.evidence, ""),
                    summaryText = staffCasesTrim(pkCase.reason ~= "" and pkCase.reason or pkCase.evidence, 72),
                    severityLabel = "critical",
                    statusText = IsValid(owner) and "Online" or "Offline",
                    metaText = IsValid(owner) and "Online" or "Offline",
                    claimed = false,
                    charID = tonumber(pkCase.charID) or nil,
                    accent = STAFF_CASES_ACCENTS.pk,
                    raw = pkCase
                }
            end
        end

        table.sort(records, function(a, b)
            if a.timestamp == b.timestamp then return staffCasesSeverityScore(a) > staffCasesSeverityScore(b) end
            return a.timestamp > b.timestamp
        end)
        return records
    end

    function panel:PassesFilters(caseData)
        local state = self.caseState
        if state.mode == CASE_MODE_TICKETS and caseData.caseType ~= "ticket" then return false end
        if state.mode == CASE_MODE_WARNINGS and caseData.caseType ~= "warning" then return false end
        if state.mode == CASE_MODE_PKS and caseData.caseType ~= "pk" then return false end
        if state.status == "open" and not (caseData.caseType == "ticket" and not caseData.claimed) then return false end
        if state.status == "claimed" and not (caseData.caseType == "ticket" and caseData.claimed) then return false end
        if state.status == "high" then
            local severity = string.lower(caseData.severityLabel or "")
            if caseData.caseType ~= "warning" or (severity ~= "high" and severity ~= "critical") then return false end
        end

        if state.status == "online" and not caseData.online then return false end
        if state.status == "offline" and caseData.online then return false end
        local search = state.search or ""
        if search ~= "" then
            local haystack = string.lower(table.concat({caseData.typeLabel or "", caseData.targetDisplay or "", caseData.staffDisplay or "", caseData.message or "", caseData.reason or "", caseData.evidence or "", caseData.statusText or ""}, " "))
            if not haystack:find(search, 1, true) then return false end
        end
        return true
    end

    function panel:GetVisibleCases(records)
        local visible = {}
        for _, caseData in ipairs(records or self:BuildCases()) do
            if self:PassesFilters(caseData) then visible[#visible + 1] = caseData end
        end
        return visible
    end

    function panel:GetCaseActions(caseData)
        if not caseData then return {} end
        local client = LocalPlayer()
        local actions = {}
        local targetPlayer = staffCasesPlayerBySteamID(caseData.steamID)
        caseData.isSelfTarget = IsValid(targetPlayer) and targetPlayer == client
        local function addAction(label, icon, callback, disabled, tooltip, primary)
            actions[#actions + 1] = {
                label = label,
                icon = icon,
                callback = callback,
                disabled = disabled,
                tooltip = tooltip,
                primary = primary
            }
        end

        if caseData.caseType == "ticket" then
            addAction("Claim Case", "icon16/accept.png", function()
                if not IsValid(targetPlayer) then return end
                net.Start("liaTicketSystemClaim")
                net.WriteEntity(targetPlayer)
                net.SendToServer()
            end, not caseData.live or caseData.claimed or caseData.isSelfTarget or not IsValid(targetPlayer), caseData.isSelfTarget and L("ticketActionSelf") or nil, true)

            addAction("Close Case", "icon16/cancel.png", function()
                if not IsValid(targetPlayer) then return end
                net.Start("liaTicketSystemClose")
                net.WriteEntity(targetPlayer)
                net.SendToServer()
            end, not caseData.live or caseData.claimSteamID ~= client:SteamID() or not IsValid(targetPlayer), nil, caseData.claimed)

            addAction("Go To", "icon16/arrow_right.png", function() lia.admin.execCommand("goto", targetPlayer) end, caseData.isSelfTarget or not IsValid(targetPlayer))
            addAction("Bring", "icon16/arrow_down.png", function() lia.admin.execCommand("bring", targetPlayer) end, caseData.isSelfTarget or not IsValid(targetPlayer))
            addAction("Freeze", "icon16/lock.png", function() lia.admin.execCommand("freeze", targetPlayer) end, caseData.isSelfTarget or not IsValid(targetPlayer))
            addAction("Return", "icon16/arrow_redo.png", function() lia.admin.execCommand("return", targetPlayer) end, caseData.isSelfTarget or not IsValid(targetPlayer))
        elseif caseData.caseType == "warning" then
            addAction("View Full History", "icon16/report.png", function() staffCasesCommand("viewwarns", caseData.steamID) end, not lia.command.hasAccess(client, "viewwarns") or caseData.steamID == "", nil, true)
            addAction("Remove Warning", "icon16/delete.png", function()
                if not caseData.charID or not caseData.warningID then return end
                net.Start("liaRequestRemoveWarning")
                net.WriteInt(caseData.charID, 32)
                net.WriteTable({
                    ID = caseData.warningID
                })

                net.SendToServer()
            end, not caseData.online or not caseData.charID or not caseData.warningID or not client:hasPrivilege("canRemoveWarns"))

            addAction("Copy SteamID", "icon16/page_copy.png", function() SetClipboardText(caseData.steamID or "") end, caseData.steamID == "")
        elseif caseData.caseType == "pk" then
            local isSelfTarget = caseData.steamID ~= "" and caseData.steamID == client:SteamID()
            local charID = caseData.charID
            addAction("View Evidence", "icon16/world.png", function() gui.OpenURL(caseData.evidence) end, not caseData.evidence:match("^https?://"), nil, true)
            addAction("Copy Reason", "icon16/page_copy.png", function() SetClipboardText(caseData.reason or "") end, caseData.reason == "")
            addAction("Copy Evidence", "icon16/page_copy.png", function() SetClipboardText(caseData.evidence or "") end, caseData.evidence == "")
            addAction("Ban Character", "icon16/cancel.png", function() staffCasesCommand("charban", charID) end, isSelfTarget or not charID or not IsValid(targetPlayer) or not lia.command.hasAccess(client, "charban"))
            addAction("Wipe Character", "icon16/user_delete.png", function() staffCasesCommand("charwipe", charID) end, isSelfTarget or not charID or not IsValid(targetPlayer) or not lia.command.hasAccess(client, "charwipe"))
            addAction("Unban Character", "icon16/accept.png", function() staffCasesCommand("charunban", charID) end, isSelfTarget or not charID or not IsValid(targetPlayer) or not lia.command.hasAccess(client, "charunban"))
            addAction("Ban Character Offline", "icon16/cancel.png", function() staffCasesCommand("charbanoffline", charID) end, isSelfTarget or not charID or IsValid(targetPlayer) or not lia.command.hasAccess(client, "charbanoffline"))
            addAction("Wipe Character Offline", "icon16/user_delete.png", function() staffCasesCommand("charwipeoffline", charID) end, isSelfTarget or not charID or IsValid(targetPlayer) or not lia.command.hasAccess(client, "charwipeoffline"))
            addAction("Unban Character Offline", "icon16/accept.png", function() staffCasesCommand("charunbanoffline", charID) end, isSelfTarget or not charID or IsValid(targetPlayer) or not lia.command.hasAccess(client, "charunbanoffline"))
        end
        return actions
    end

    function panel:OpenCaseMenu(caseData)
        if not caseData then return end
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copySteamID"), function() if caseData.steamID and caseData.steamID ~= "" then SetClipboardText(caseData.steamID) end end, "icon16/page_copy.png")
        for _, action in ipairs(self:GetCaseActions(caseData)) do
            if not action.disabled then menu:AddOption(action.label, action.callback, action.icon) end
        end
    end

    function panel:BuildCaseRow(caseData)
        local row = self.caseList:Add("DButton")
        row:Dock(TOP)
        row:SetTall(66)
        row:SetText("")
        row:DockMargin(0, 0, 0, 1)
        row.caseData = caseData
        row.Paint = function(this, w, h)
            local selected = self.caseState.selectedID == caseData.caseID
            drawPanel(0, 0, w, h, 6, selected and selectedColor or this:IsHovered() and panelColorHovered or panelColorSoft, selected and Color(accent.r, accent.g, accent.b, 170) or Color(borderColor.r, borderColor.g, borderColor.b, 180))
            if selected then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                surface.DrawRect(0, 7, 3, h - 14)
            end

            local badgeColor = typeColor(caseData)
            local badgeText = string.upper(caseData.typeLabel)
            surface.SetFont("LiliaFont.14")
            local badgeWidth = surface.GetTextSize(badgeText) + 18
            drawPanel(10, 18, badgeWidth, 28, 4, Color(badgeColor.r, badgeColor.g, badgeColor.b, 18), Color(badgeColor.r, badgeColor.g, badgeColor.b, 180))
            draw.SimpleText(badgeText, "LiliaFont.14", 10 + badgeWidth * 0.5, 32, badgeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local subjectX = w * 0.14
            local submitterX = w * 0.48
            local timeX = w * 0.70
            local statusX = w * 0.84
            local subject = caseData.summaryText ~= "" and caseData.summaryText or caseData.targetName
            draw.SimpleText(staffCasesTrim(subject, 42), "LiliaFont.16", subjectX, 20, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(caseData.targetName, "LiliaFont.14", subjectX, 43, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(staffCasesTrim(caseData.staffDisplay, 24), "LiliaFont.15", submitterX, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(relativeTime(caseData.timestamp), "LiliaFont.15", timeX, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local statusAccent = statusColor(caseData)
            surface.SetDrawColor(statusAccent.r, statusAccent.g, statusAccent.b, 255)
            surface.DrawCircle(statusX, h * 0.5, 3, statusAccent.r, statusAccent.g, statusAccent.b, 255)
            draw.SimpleText(caseData.statusText, "LiliaFont.15", statusX + 10, h * 0.5, statusAccent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        row.DoClick = function()
            self.caseState.selectedID = caseData.caseID
            self.caseState.selectedCase = caseData
            self:RenderDetail(caseData)
            for _, otherRow in ipairs(self.caseRows) do
                if IsValid(otherRow) then otherRow:InvalidateLayout(true) end
            end
        end

        row.DoRightClick = function() self:OpenCaseMenu(caseData) end
        self.caseRows[#self.caseRows + 1] = row
    end

    function panel:RenderDetail(caseData)
        local detail = self.detailPanel
        detail:Clear()
        if not caseData then
            local empty = detail:Add("DLabel")
            empty:Dock(TOP)
            empty:DockMargin(8, 12, 8, 0)
            empty:SetFont("LiliaFont.18")
            empty:SetText("Select a case to review details and actions.")
            empty:SetWrap(true)
            empty:SetAutoStretchVertical(true)
            empty:SetTextColor(mutedTextColor)
            return
        end

        local header = detail:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(128)
        header:DockMargin(0, 0, 0, 10)
        header.Paint = function(_, w, h)
            local badgeColor = typeColor(caseData)
            local badgeText = string.upper(caseData.typeLabel)
            surface.SetFont("LiliaFont.14")
            local badgeWidth = surface.GetTextSize(badgeText) + 18
            drawPanel(0, 0, badgeWidth, 26, 4, Color(badgeColor.r, badgeColor.g, badgeColor.b, 18), Color(badgeColor.r, badgeColor.g, badgeColor.b, 180))
            draw.SimpleText(badgeText, "LiliaFont.14", badgeWidth * 0.5, 13, badgeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local statusAccent = statusColor(caseData)
            surface.SetDrawColor(statusAccent.r, statusAccent.g, statusAccent.b, 255)
            surface.DrawCircle(w - 72, 13, 3, statusAccent.r, statusAccent.g, statusAccent.b, 255)
            draw.SimpleText(caseData.statusText, "LiliaFont.15", w - 62, 13, statusAccent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local title = caseData.summaryText ~= "" and caseData.summaryText or caseData.targetName
            draw.SimpleText(staffCasesTrim(title, 48), "LiliaFont.22", 0, 52, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Target: " .. caseData.targetName, "LiliaFont.15", 0, 80, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Recorded " .. relativeTime(caseData.timestamp), "LiliaFont.14", 0, 105, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
            surface.DrawRect(0, h - 1, w, 1)
        end

        local details = makeSection(detail, "Details", caseData.caseType == "pk" and 192 or 162)
        addInfoRow(details, "Type", function() return caseData.typeLabel end)
        if caseData.caseType == "warning" then
            addInfoRow(details, "Severity", function() return caseData.statusText end, function() return statusColor(caseData) end)
        else
            addInfoRow(details, "Status", function() return caseData.statusText end, function() return statusColor(caseData) end)
        end

        addInfoRow(details, "Target", function() return caseData.targetName end)
        addInfoRow(details, "Staff / Submitter", function() return caseData.staffDisplay end)
        if caseData.caseType == "pk" then addInfoRow(details, "Character ID", function() return tostring(caseData.charID or L("na")) end) end
        local description = makeSection(detail, caseData.caseType == "pk" and "Reason / Evidence" or "Description", 126)
        local descriptionLabel = description:Add("DLabel")
        descriptionLabel:Dock(FILL)
        descriptionLabel:SetFont("LiliaFont.15")
        descriptionLabel:SetTextColor(textColor)
        descriptionLabel:SetWrap(true)
        descriptionLabel:SetContentAlignment(7)
        if caseData.caseType == "pk" then
            descriptionLabel:SetText("Reason: " .. staffCasesText(caseData.reason, "No reason provided.") .. "\n\nEvidence: " .. staffCasesText(caseData.evidence, "No evidence provided."))
        else
            descriptionLabel:SetText(caseData.message ~= "" and caseData.message or "No additional text recorded.")
        end

        local actions = self:GetCaseActions(caseData)
        local visibleActions = {}
        for _, action in ipairs(actions) do
            if not action.disabled then visibleActions[#visibleActions + 1] = action end
        end

        local actionCount = math.min(#visibleActions, 3)
        if actionCount > 0 then
            local actionSection = makeSection(detail, "Actions", 44 + actionCount * 42)
            for i = 1, actionCount do
                local action = visibleActions[i]
                local button = actionSection:Add("DButton")
                button:Dock(TOP)
                button:SetTall(34)
                button:DockMargin(0, 0, 0, 7)
                button:SetText("")
                if action.tooltip then button:SetTooltip(action.tooltip) end
                button.Paint = function(this, w, h)
                    local primary = action.primary and Color(accent.r, accent.g, accent.b, this:IsHovered() and 230 or 205) or this:IsHovered() and panelColorHovered or panelColorSoft
                    local outline = action.primary and Color(accent.r, accent.g, accent.b, 220) or borderColor
                    drawPanel(0, 0, w, h, 4, primary, outline)
                    draw.SimpleText(action.label, "LiliaFont.15", w * 0.5, h * 0.5, action.primary and Color(255, 255, 255) or textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                button.DoClick = action.callback
            end
        end

        local activity = makeSection(detail, "Activity", 74)
        activity.PaintOver = function(_, w, h)
            draw.SimpleText("Case recorded", "LiliaFont.15", 12, 51, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(relativeTime(caseData.timestamp), "LiliaFont.15", w - 12, 51, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    function panel:UpdateStats(records)
        local stats = {
            tickets = 0,
            unclaimed = 0,
            warnings = 0,
            pks = 0
        }

        for _, caseData in ipairs(records) do
            if caseData.caseType == "ticket" then
                stats.tickets = stats.tickets + 1
                if caseData.live and not caseData.claimed then stats.unclaimed = stats.unclaimed + 1 end
            elseif caseData.caseType == "warning" then
                stats.warnings = stats.warnings + 1
            elseif caseData.caseType == "pk" then
                stats.pks = stats.pks + 1
            end
        end

        for key, value in pairs(stats) do
            if IsValid(self.statCards[key]) then self.statCards[key]:SetText(tostring(value)) end
        end
    end

    function panel:RefreshData()
        local records = self:BuildCases()
        self:UpdateStats(records)
        local visible = self:GetVisibleCases(records)
        self.caseList:Clear()
        self.caseRows = {}
        if #visible == 0 then
            local emptyState = self.caseList:Add("DPanel")
            emptyState:Dock(TOP)
            emptyState:SetTall(180)
            emptyState:DockMargin(0, 32, 0, 0)
            emptyState.Paint = nil
            local emptyTitle = emptyState:Add("DLabel")
            emptyTitle:Dock(TOP)
            emptyTitle:SetTall(34)
            emptyTitle:SetFont("LiliaFont.20")
            emptyTitle:SetTextColor(textColor)
            emptyTitle:SetContentAlignment(5)
            emptyTitle:SetText(#records == 0 and "No staff cases found." or "No cases match the current filters.")
            local emptyBody = emptyState:Add("DLabel")
            emptyBody:Dock(TOP)
            emptyBody:DockMargin(36, 8, 36, 0)
            emptyBody:SetFont("LiliaFont.15")
            emptyBody:SetWrap(true)
            emptyBody:SetAutoStretchVertical(true)
            emptyBody:SetTextColor(mutedTextColor)
            emptyBody:SetContentAlignment(8)
            emptyBody:SetText(#records == 0 and "Tickets, warnings, and PK cases will appear here once they are created or loaded from the server." or "Try switching status filters, clearing the search box, or changing the case type tabs.")
        end

        for _, caseData in ipairs(visible) do
            self:BuildCaseRow(caseData)
        end

        local selected
        if self.caseState.selectedID then
            for _, caseData in ipairs(visible) do
                if caseData.caseID == self.caseState.selectedID then
                    selected = caseData
                    break
                end
            end
        end

        if not selected then selected = visible[1] end
        self.caseState.selectedID = selected and selected.caseID or nil
        self.caseState.selectedCase = selected
        self:RenderDetail(selected)
    end

    function panel:RequestData()
        net.Start("liaRequestStaffCases")
        net.SendToServer()
    end

    panel:BuildShell()
    panel:RefreshData()
    panel:RequestData()
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canListCharacters = client:hasPrivilege("listCharacters")
    if canListCharacters then
        table.insert(pages, {
            name = "@characterList",
            icon = "icon16/book.png",
            drawFunc = function(panel)
                panelRef = panel
                panel:Clear()
                panel:DockPadding(6, 6, 6, 6)
                panel.Paint = nil
                function panel:buildSheets(data)
                    self:Clear()
                    self:DockPadding(6, 6, 6, 6)
                    self.Paint = nil
                    local accent = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme or Color(184, 132, 74)
                    local panelColor = Color(4, 18, 23, 242)
                    local panelColorSoft = Color(7, 24, 29, 238)
                    local panelColorHovered = Color(12, 31, 36, 244)
                    local selectedColor = Color(22, 31, 32, 250)
                    local borderColor = Color(47, 59, 57, 220)
                    local textColor = Color(230, 238, 236)
                    local mutedTextColor = Color(150, 168, 166)
                    local goodColor = Color(75, 205, 130)
                    local badColor = Color(220, 95, 95)
                    local selectedSteamID
                    local selectedAccount
                    local selectedCharacter
                    local accountButtons = {}
                    local characterButtons = {}
                    local accounts = {}
                    local accountIndex = {}
                    local currentCharacterFilter = "all"
                    local accountSearch
                    local accountList
                    local characterSearch
                    local characterList
                    local characterFilterButton
                    local detailPanel
                    local function drawPanel(x, y, w, h, radius, color, outline)
                        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
                        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
                    end

                    local function styleScrollBar(scrollPanel)
                        if not IsValid(scrollPanel) or not IsValid(scrollPanel.VBar) then return end
                        local vbar = scrollPanel.VBar
                        vbar:SetWide(8)
                        vbar.Paint = function(_, w, h)
                            surface.SetDrawColor(255, 255, 255, 4)
                            surface.DrawRect(0, 0, w, h)
                        end

                        vbar.btnUp.Paint = function() end
                        vbar.btnDown.Paint = function() end
                        vbar.btnGrip.Paint = function(_, w, h) drawPanel(1, 0, w - 2, h, 4, Color(accent.r, accent.g, accent.b, 145)) end
                    end

                    local function getValue(row, ...)
                        for i = 1, select("#", ...) do
                            local key = select(i, ...)
                            if key and row[key] ~= nil then return row[key] end
                        end
                    end

                    local function getCharacterID(row)
                        return getValue(row, "ID", "id", "CharID", "charID")
                    end

                    local function getCharacterName(row)
                        return tostring(getValue(row, "Name", "name", L("name")) or L("unknown"))
                    end

                    local function getCharacterDescription(row)
                        return tostring(getValue(row, "Desc", "desc", "Description", "description") or "")
                    end

                    local function getCharacterFaction(row)
                        return tostring(getValue(row, "Faction", "faction", L("faction")) or L("unknown"))
                    end

                    local function getCharacterClass(row)
                        return tostring(getValue(row, "Class", "class", L("class")) or "")
                    end

                    local function getCharacterPlayTime(row)
                        local seconds = tonumber(getValue(row, "PlayTime", "playTime", "playtime")) or 0
                        if lia.time and isfunction(lia.time.formatDHM) then return lia.time.formatDHM(seconds) end
                        local hours = math.floor(seconds / 3600)
                        local minutes = math.floor(seconds % 3600 / 60)
                        return string.format("%dh %02dm", hours, minutes)
                    end

                    local function getCharacterMoney(row)
                        local amount = tonumber(getValue(row, "Money", "money", L("money"))) or 0
                        return lia.currency.get(amount)
                    end

                    local function getCharacterLastUsed(row)
                        local value = getValue(row, "LastUsed", "lastUsed", "LastJoinTime", "lastJoinTime")
                        if value == nil or tostring(value) == "" then return L("unknown") end
                        return tostring(value)
                    end

                    local function isCharacterBanned(row)
                        local value = getValue(row, "Banned", "banned")
                        if isbool(value) then return value end
                        return tonumber(value) == 1 or tostring(value):lower() == "true"
                    end

                    local function resolveSteamName(steamID, characters)
                        local ply = lia.util.getBySteamID(steamID)
                        if IsValid(ply) then return ply:Nick() end
                        for _, character in ipairs(characters or {}) do
                            local name = character.SteamName or character.steamName or character.OwnerName or character.ownerName or character.PlayerName or character.playerName
                            if name and tostring(name) ~= "" then return tostring(name) end
                        end
                        return L("unknown")
                    end

                    local function sortAccounts()
                        table.sort(accounts, function(a, b)
                            local aName = string.lower(a.steamName or "")
                            local bName = string.lower(b.steamName or "")
                            if aName == bName then return a.steamID < b.steamID end
                            return aName < bName
                        end)
                    end

                    local function sortCharacters(characters)
                        table.sort(characters, function(a, b) return tonumber(getCharacterID(a) or 0) < tonumber(getCharacterID(b) or 0) end)
                    end

                    local function addCharacterRows(steamID, characters)
                        steamID = tostring(steamID)
                        local account = accountIndex[steamID]
                        if not account then
                            account = {
                                steamID = steamID,
                                steamName = resolveSteamName(steamID, characters),
                                characters = {},
                                characterIDs = {}
                            }

                            accountIndex[steamID] = account
                            accounts[#accounts + 1] = account
                        end

                        for _, row in ipairs(characters or {}) do
                            local charID = tonumber(getCharacterID(row))
                            if charID then
                                if not account.characterIDs[charID] then
                                    account.characterIDs[charID] = true
                                    account.characters[#account.characters + 1] = row
                                end
                            else
                                account.characters[#account.characters + 1] = row
                            end
                        end

                        if account.steamName == L("unknown") then account.steamName = resolveSteamName(steamID, account.characters) end
                        sortCharacters(account.characters)
                    end

                    for steamID, characters in pairs(data.players or {}) do
                        addCharacterRows(steamID, characters)
                    end

                    sortAccounts()
                    local header = self:Add("DPanel")
                    header:Dock(TOP)
                    header:SetTall(24)
                    header:DockMargin(0, 0, 0, 10)
                    header.Paint = function() end
                    local subtitle = header:Add("DLabel")
                    subtitle:Dock(FILL)
                    subtitle:SetFont("LiliaFont.16")
                    subtitle:SetText("Browse accounts and inspect their characters.")
                    subtitle:SetTextColor(mutedTextColor)
                    subtitle:SetContentAlignment(4)
                    local content = self:Add("DPanel")
                    content:Dock(FILL)
                    content.Paint = function() end
                    local accountsPanel = content:Add("DPanel")
                    accountsPanel:Dock(LEFT)
                    accountsPanel:SetWide(math.max(280, ScrW() * 0.205))
                    accountsPanel:DockMargin(0, 0, 12, 0)
                    accountsPanel:DockPadding(12, 12, 12, 12)
                    accountsPanel.Paint = function(_, w, h) drawPanel(0, 0, w, h, 7, panelColor, borderColor) end
                    local accountsTitle = accountsPanel:Add("DLabel")
                    accountsTitle:Dock(TOP)
                    accountsTitle:SetTall(30)
                    accountsTitle:SetFont("LiliaFont.18")
                    accountsTitle:SetText("ACCOUNTS")
                    accountsTitle:SetTextColor(accent)
                    accountSearch = accountsPanel:Add("liaEntry")
                    accountSearch:Dock(TOP)
                    accountSearch:DockMargin(0, 4, 0, 12)
                    accountSearch:SetTall(40)
                    accountSearch:SetFont("LiliaFont.16")
                    accountSearch:SetPlaceholderText("Search accounts...")
                    accountSearch:SetTextColor(textColor)
                    accountList = accountsPanel:Add("DScrollPanel")
                    accountList:Dock(FILL)
                    accountList.Paint = function() end
                    styleScrollBar(accountList)
                    local browserPanel = content:Add("DPanel")
                    browserPanel:Dock(LEFT)
                    browserPanel:SetWide(math.max(360, ScrW() * 0.285))
                    browserPanel:DockMargin(0, 0, 12, 0)
                    browserPanel:DockPadding(12, 12, 12, 12)
                    browserPanel.Paint = function(_, w, h) drawPanel(0, 0, w, h, 7, panelColor, borderColor) end
                    local charactersTitle = browserPanel:Add("DLabel")
                    charactersTitle:Dock(TOP)
                    charactersTitle:SetTall(30)
                    charactersTitle:SetFont("LiliaFont.18")
                    charactersTitle:SetText("CHARACTERS")
                    charactersTitle:SetTextColor(accent)
                    local characterSearchRow = browserPanel:Add("DPanel")
                    characterSearchRow:Dock(TOP)
                    characterSearchRow:SetTall(40)
                    characterSearchRow:DockMargin(0, 4, 0, 12)
                    characterSearchRow.Paint = function() end
                    characterSearch = characterSearchRow:Add("liaEntry")
                    characterSearch:Dock(FILL)
                    characterSearch:DockMargin(0, 0, 8, 0)
                    characterSearch:SetFont("LiliaFont.16")
                    characterSearch:SetPlaceholderText("Search characters...")
                    characterSearch:SetTextColor(textColor)
                    characterFilterButton = characterSearchRow:Add("DButton")
                    characterFilterButton:Dock(RIGHT)
                    characterFilterButton:SetWide(132)
                    characterFilterButton:SetText("")
                    characterFilterButton.filterLabel = "All Characters"
                    characterFilterButton.Paint = function(button, w, h)
                        drawPanel(0, 0, w, h, 5, button:IsHovered() and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, button:IsHovered() and 105 or 60))
                        draw.SimpleText(button.filterLabel, "LiliaFont.15", 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("▼", "LiliaFont.13", w - 12, h * 0.5, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end

                    characterList = browserPanel:Add("DScrollPanel")
                    characterList:Dock(FILL)
                    characterList.Paint = function() end
                    styleScrollBar(characterList)
                    local detailFrame = content:Add("DPanel")
                    detailFrame:Dock(FILL)
                    detailFrame:DockPadding(10, 10, 10, 10)
                    detailFrame.Paint = function(_, w, h) drawPanel(0, 0, w, h, 7, panelColor, borderColor) end
                    local detailScroll = detailFrame:Add("DScrollPanel")
                    detailScroll:Dock(FILL)
                    detailScroll.Paint = function() end
                    styleScrollBar(detailScroll)
                    local detailCanvas = detailScroll:GetCanvas()
                    if IsValid(detailCanvas) then
                        detailCanvas:DockPadding(4, 4, 4, 4)
                        detailCanvas.Paint = function() end
                    else
                        detailCanvas = detailScroll
                    end

                    detailPanel = detailCanvas
                    local function createSection(parent, label, height)
                        local section = parent:Add("DPanel")
                        section:Dock(TOP)
                        section:SetTall(height)
                        section:DockMargin(0, 0, 0, 10)
                        section:DockPadding(12, 38, 12, 8)
                        section.Paint = function(_, w, h)
                            drawPanel(0, 0, w, h, 6, Color(5, 20, 25, 225), Color(accent.r, accent.g, accent.b, 55))
                            draw.SimpleText(label, "LiliaFont.16", 12, 12, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            surface.SetDrawColor(accent.r, accent.g, accent.b, 40)
                            surface.DrawRect(12, 34, w - 24, 1)
                        end
                        return section
                    end

                    local function createInfoRow(parent, label, valueFunc, valueColorFunc)
                        local row = parent:Add("DPanel")
                        row:Dock(TOP)
                        row:SetTall(34)
                        row.Paint = function(_, w, h)
                            surface.SetDrawColor(255, 255, 255, 8)
                            surface.DrawRect(0, h - 1, w, 1)
                            draw.SimpleText(label, "LiliaFont.15", 0, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            local value = valueFunc()
                            local color = valueColorFunc and valueColorFunc() or textColor
                            draw.SimpleText(tostring(value or ""), "LiliaFont.15", w, h * 0.5, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end
                        return row
                    end

                    local function createLinkRow(parent, label, valueFunc, onClick, enabledFunc)
                        local row = parent:Add("DButton")
                        row:Dock(TOP)
                        row:SetTall(34)
                        row:SetText("")
                        row.Paint = function(button, w, h)
                            local enabled = not enabledFunc or enabledFunc()
                            local valueColor = enabled and (button:IsHovered() and accent or infoColor) or mutedTextColor
                            surface.SetDrawColor(255, 255, 255, 8)
                            surface.DrawRect(0, h - 1, w, 1)
                            draw.SimpleText(label, "LiliaFont.15", 0, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(tostring(valueFunc() or ""), "LiliaFont.15", w, h * 0.5, valueColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end

                        row.DoClick = function()
                            if enabledFunc and not enabledFunc() then return end
                            lia.websound.playButtonSound()
                            onClick()
                        end
                        return row
                    end

                    local function runCharacterCommand(command, row)
                        local charID = getCharacterID(row)
                        if not charID then return end
                        LocalPlayer():ConCommand('say "/' .. command .. ' ' .. tostring(charID) .. '"')
                    end

                    local function copyCharacterSummary(row, account)
                        local values = {"Character ID " .. tostring(getCharacterID(row) or ""), "Name " .. getCharacterName(row), "SteamID " .. tostring(account and account.steamID or ""), "Faction " .. getCharacterFaction(row), "Description " .. getCharacterDescription(row)}
                        SetClipboardText(table.concat(values, " | "))
                    end

                    local function openCharacterActions(row, account)
                        if not row or not account then return end
                        local menu = lia.derma.dermaMenu()
                        menu:AddOption(L("copySteamID"), function() SetClipboardText(account.steamID) end, "icon16/page_copy.png")
                        menu:AddOption(L("copyRow"), function() copyCharacterSummary(row, account) end, "icon16/page_copy.png")
                        local owner = lia.util.getBySteamID(account.steamID)
                        local banned = isCharacterBanned(row)
                        if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipe") then
                            menu:AddOption(L("wipeCharacter"), function() runCharacterCommand("charwipe", row) end, "icon16/user_delete.png")
                        elseif not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then
                            menu:AddOption(L("wipeCharacterOffline"), function() runCharacterCommand("charwipeoffline", row) end, "icon16/user_delete.png")
                        end

                        if not banned then
                            if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charban") then
                                menu:AddOption(L("banCharacter"), function() runCharacterCommand("charban", row) end, "icon16/cancel.png")
                            elseif not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charbanoffline") then
                                menu:AddOption(L("banCharacterOffline"), function() runCharacterCommand("charbanoffline", row) end, "icon16/cancel.png")
                            end
                        elseif IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charunban") then
                            menu:AddOption(L("unbanCharacter"), function() runCharacterCommand("charunban", row) end, "icon16/accept.png")
                        elseif not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then
                            menu:AddOption(L("unbanCharacterOffline"), function() runCharacterCommand("charunbanoffline", row) end, "icon16/accept.png")
                        end

                        menu:Open()
                    end

                    local refreshCharacterSelection
                    local function buildDetail(row, account)
                        detailPanel:Clear()
                        detailPanel:DockPadding(14, 14, 6, 14)
                        if not row or not account then
                            local empty = detailPanel:Add("DLabel")
                            empty:Dock(FILL)
                            empty:SetFont("LiliaFont.20")
                            empty:SetText("Select a character to inspect.")
                            empty:SetTextColor(mutedTextColor)
                            empty:SetContentAlignment(5)
                            return
                        end

                        local detailHeader = detailPanel:Add("DPanel")
                        detailHeader:Dock(TOP)
                        detailHeader:SetTall(78)
                        detailHeader:DockMargin(0, 0, 0, 10)
                        detailHeader.Paint = function(_, w, h)
                            draw.SimpleText(getCharacterName(row), "LiliaFont.25", 0, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText("Character #" .. tostring(getCharacterID(row) or "?"), "LiliaFont.16", w, 10, mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                            local secondary = getCharacterFaction(row)
                            local className = getCharacterClass(row)
                            if className ~= "" then secondary = secondary .. "  •  " .. className end
                            draw.SimpleText(secondary, "LiliaFont.16", 0, 42, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                            surface.DrawRect(0, h - 1, w, 1)
                        end

                        local general = createSection(detailPanel, "GENERAL", 210)
                        createInfoRow(general, "Character ID", function() return getCharacterID(row) or "" end)
                        createInfoRow(general, "Account", function() return account.steamName or account.steamID end)
                        createInfoRow(general, "SteamID", function() return account.steamID end)
                        createInfoRow(general, "Faction", function() return getCharacterFaction(row) end)
                        createInfoRow(general, "Status", function() return isCharacterBanned(row) and "Banned" or "Active" end, function() return isCharacterBanned(row) and badColor or goodColor end)
                        local stats = createSection(detailPanel, "CHARACTER DATA", 312)
                        createInfoRow(stats, "Playtime", function() return getCharacterPlayTime(row) end)
                        createInfoRow(stats, "Last Used", function() return getCharacterLastUsed(row) end)
                        createInfoRow(stats, "Money", function() return getCharacterMoney(row) end)
                        createInfoRow(stats, "Banned", function() return isCharacterBanned(row) and L("yes") or L("no") end, function() return isCharacterBanned(row) and badColor or goodColor end)
                        createInfoRow(stats, "Description", function() return getCharacterDescription(row) ~= "" and getCharacterDescription(row) or L("none") end)
                        createLinkRow(stats, "Warnings", function() return lia.command.hasAccess(LocalPlayer(), "viewwarns") and "View History" or "Unavailable" end, function() staffCasesCommand("viewwarns", account.steamID) end, function() return lia.command.hasAccess(LocalPlayer(), "viewwarns") end)
                        createLinkRow(stats, "Tickets", function() return lia.command.hasAccess(LocalPlayer(), "viewtickets") and "View Requests" or "Unavailable" end, function() staffCasesCommand("viewtickets", account.steamID) end, function() return lia.command.hasAccess(LocalPlayer(), "viewtickets") end)
                        if LocalPlayer():hasPrivilege("manageFlags") then
                            local flagSection = createSection(detailPanel, string.upper(L("charFlagsTitle")), 112)
                            createInfoRow(flagSection, "Current Flags", function() return row.Flags ~= "" and row.Flags or L("none") end, function() return row.Flags ~= "" and accent or mutedTextColor end)
                            local editFlags = flagSection:Add("DButton")
                            editFlags:Dock(BOTTOM)
                            editFlags:SetTall(36)
                            editFlags:SetText("")
                            editFlags.Paint = function(button, w, h)
                                drawPanel(0, 0, w, h, 5, button:IsHovered() and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, button:IsHovered() and 115 or 70))
                                draw.SimpleText(string.upper(L("modifyCharFlags")), "LiliaFont.15", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end

                            editFlags.DoClick = function()
                                lia.websound.playButtonSound()
                                LocalPlayer():requestString("@modifyCharFlags", "@modifyFlagsDesc", function(value)
                                    if value == false then return end
                                    local flags = sanitizeCharacterFlags(value)
                                    net.Start("liaModifyCharacterFlags")
                                    net.WriteUInt(tonumber(getCharacterID(row)) or 0, 32)
                                    net.WriteString(flags)
                                    net.SendToServer()
                                    row.Flags = flags
                                    buildDetail(row, account)
                                    refreshCharacterSelection()
                                end, row.Flags or "")
                            end
                        end

                        local actions = detailPanel:Add("DPanel")
                        actions:Dock(TOP)
                        actions:SetTall(90)
                        actions:DockMargin(0, 0, 0, 0)
                        actions:DockPadding(0, 38, 0, 0)
                        actions.Paint = function(_, w, h)
                            draw.SimpleText("ACTIONS", "LiliaFont.16", 0, 10, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            surface.SetDrawColor(accent.r, accent.g, accent.b, 40)
                            surface.DrawRect(0, 32, w, 1)
                        end

                        local actionButtons = {}
                        local function addActionButton(label, callback)
                            local button = actions:Add("DButton")
                            button:SetText("")
                            button.Paint = function(s, w, h)
                                drawPanel(0, 0, w, h, 5, s:IsHovered() and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, s:IsHovered() and 110 or 65))
                                draw.SimpleText(label, "LiliaFont.15", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end

                            button.DoClick = function()
                                lia.websound.playButtonSound()
                                callback()
                            end

                            actionButtons[#actionButtons + 1] = button
                            return button
                        end

                        actions.PerformLayout = function(_, w)
                            local gap = 10
                            local buttonH = 42
                            local buttonW = math.floor((w - gap) * 0.5)
                            for i, button in ipairs(actionButtons) do
                                local index = i - 1
                                local column = index % 2
                                local rowIndex = math.floor(index / 2)
                                button:SetPos(column * (buttonW + gap), 38 + rowIndex * (buttonH + gap))
                                button:SetSize(buttonW, buttonH)
                            end
                        end

                        addActionButton("OPEN STEAM PROFILE", function()
                            local steamID64 = util.SteamIDTo64(account.steamID)
                            if steamID64 and steamID64 ~= "0" then gui.OpenURL("https://steamcommunity.com/profiles/" .. steamID64) end
                        end)

                        addActionButton("COPY STEAMID", function() SetClipboardText(account.steamID) end)
                    end

                    function refreshCharacterSelection()
                        for _, button in ipairs(characterButtons) do
                            if IsValid(button) then button:InvalidateLayout(true) end
                        end
                    end

                    local function selectCharacter(row)
                        selectedCharacter = row
                        refreshCharacterSelection()
                        buildDetail(row, selectedAccount)
                    end

                    local function characterMatchesFilter(row)
                        if currentCharacterFilter == "banned" then return isCharacterBanned(row) end
                        if currentCharacterFilter == "active" then return not isCharacterBanned(row) end
                        return true
                    end

                    local function populateCharacters(filter)
                        characterList:Clear()
                        table.Empty(characterButtons)
                        filter = string.lower(tostring(filter or ""))
                        if not selectedAccount then
                            selectedCharacter = nil
                            buildDetail(nil, nil)
                            return
                        end

                        local firstVisibleRow
                        for _, row in ipairs(selectedAccount.characters or {}) do
                            local name = getCharacterName(row)
                            local faction = getCharacterFaction(row)
                            local className = getCharacterClass(row)
                            local charID = tostring(getCharacterID(row) or "")
                            local description = getCharacterDescription(row)
                            local haystack = string.lower(table.concat({name, faction, className, charID, description}, " "))
                            if characterMatchesFilter(row) and (filter == "" or string.find(haystack, filter, 1, true)) then
                                local button = characterList:Add("DButton")
                                button:Dock(TOP)
                                button:DockMargin(0, 0, 0, 8)
                                button:SetTall(66)
                                button:SetText("")
                                button.row = row
                                button.Paint = function(s, w, h)
                                    local selected = selectedCharacter == row
                                    drawPanel(0, 0, w, h, 6, selected and selectedColor or s:IsHovered() and panelColorHovered or panelColorSoft, selected and Color(accent.r, accent.g, accent.b, 170) or Color(borderColor.r, borderColor.g, borderColor.b, 180))
                                    if selected then
                                        surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                                        surface.DrawRect(0, 7, 3, h - 14)
                                    end

                                    draw.SimpleText(name, "LiliaFont.17", 14, 12, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    local secondary = faction
                                    if className ~= "" then secondary = secondary .. "  •  " .. className end
                                    if isCharacterBanned(row) then secondary = secondary .. "  •  Banned" end
                                    draw.SimpleText(secondary, "LiliaFont.14", 14, 38, isCharacterBanned(row) and badColor or mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    draw.SimpleText("#" .. charID, "LiliaFont.17", w - 14, h * 0.5, selected and accent or mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                                end

                                button.DoClick = function()
                                    lia.websound.playButtonSound()
                                    selectCharacter(row)
                                end

                                button.DoRightClick = function() openCharacterActions(row, selectedAccount) end
                                characterButtons[#characterButtons + 1] = button
                                if not firstVisibleRow then firstVisibleRow = row end
                            end
                        end

                        if selectedCharacter then
                            local stillVisible
                            for _, button in ipairs(characterButtons) do
                                if button.row == selectedCharacter then
                                    stillVisible = true
                                    break
                                end
                            end

                            if not stillVisible then selectedCharacter = nil end
                        end

                        if not selectedCharacter and firstVisibleRow then
                            selectCharacter(firstVisibleRow)
                        elseif selectedCharacter then
                            refreshCharacterSelection()
                            buildDetail(selectedCharacter, selectedAccount)
                        else
                            buildDetail(nil, selectedAccount)
                        end
                    end

                    local function refreshAccountSelection()
                        for _, button in pairs(accountButtons) do
                            if IsValid(button) then button:InvalidateLayout(true) end
                        end
                    end

                    local function selectAccount(account)
                        selectedAccount = account
                        selectedSteamID = account and account.steamID or nil
                        selectedCharacter = nil
                        characterSearch:SetText("")
                        populateCharacters("")
                        refreshAccountSelection()
                    end

                    local populateAccounts
                    local function requestSteamName(account)
                        if account.nameRequested or account.steamName ~= L("unknown") then return end
                        account.nameRequested = true
                        local steamID64 = account.steamID
                        if not string.match(steamID64, "^%d+$") then steamID64 = util.SteamIDTo64(account.steamID) end
                        if not steamID64 or steamID64 == "0" then return end
                        steamworks.RequestPlayerInfo(steamID64, function(name)
                            if not IsValid(self) or not name or name == "" then return end
                            account.steamName = name
                            sortAccounts()
                            populateAccounts(accountSearch:GetValue() or "")
                            if selectedAccount == account and selectedCharacter then buildDetail(selectedCharacter, account) end
                        end)
                    end

                    populateAccounts = function(filter)
                        accountList:Clear()
                        table.Empty(accountButtons)
                        filter = string.lower(tostring(filter or ""))
                        for _, account in ipairs(accounts) do
                            local name = string.lower(account.steamName or "")
                            local steamID = string.lower(account.steamID or "")
                            if filter == "" or string.find(name, filter, 1, true) or string.find(steamID, filter, 1, true) then
                                local button = accountList:Add("DButton")
                                button:Dock(TOP)
                                button:DockMargin(0, 0, 0, 8)
                                button:SetTall(72)
                                button:SetText("")
                                button.account = account
                                button.Paint = function(s, w, h)
                                    local selected = selectedSteamID == account.steamID
                                    drawPanel(0, 0, w, h, 6, selected and selectedColor or s:IsHovered() and panelColorHovered or panelColorSoft, selected and Color(accent.r, accent.g, accent.b, 170) or Color(borderColor.r, borderColor.g, borderColor.b, 180))
                                    if selected then
                                        surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                                        surface.DrawRect(0, 7, 3, h - 14)
                                    end

                                    draw.SimpleText(account.steamName or L("unknown"), "LiliaFont.17", 14, 12, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    draw.SimpleText(account.steamID, "LiliaFont.13", 14, 39, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    draw.SimpleText(tostring(#account.characters), "LiliaFont.18", w - 14, 14, selected and accent or textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                                    draw.SimpleText(#account.characters == 1 and "Character" or "Characters", "LiliaFont.12", w - 14, 41, selected and accent or mutedTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                                end

                                button.DoClick = function()
                                    lia.websound.playButtonSound()
                                    selectAccount(account)
                                end

                                accountButtons[account.steamID] = button
                                requestSteamName(account)
                            end
                        end
                    end

                    characterFilterButton.DoClick = function()
                        lia.websound.playButtonSound()
                        local menu = lia.derma.dermaMenu()
                        menu:AddOption("All Characters", function()
                            currentCharacterFilter = "all"
                            characterFilterButton.filterLabel = "All Characters"
                            populateCharacters(characterSearch:GetValue() or "")
                        end)

                        menu:AddOption("Active", function()
                            currentCharacterFilter = "active"
                            characterFilterButton.filterLabel = "Active"
                            populateCharacters(characterSearch:GetValue() or "")
                        end)

                        menu:AddOption("Banned", function()
                            currentCharacterFilter = "banned"
                            characterFilterButton.filterLabel = "Banned"
                            populateCharacters(characterSearch:GetValue() or "")
                        end)

                        menu:Open()
                    end

                    accountSearch.OnTextChanged = function(_, value) populateAccounts(value or "") end
                    characterSearch.OnTextChanged = function(_, value) populateCharacters(value or "") end
                    function self:updateCharacterListProgress(loadedCount, totalCount, finished)
                        loadedCount = tonumber(loadedCount) or 0
                        totalCount = tonumber(totalCount) or 0
                        if totalCount <= 0 then
                            subtitle:SetText("Browse accounts and inspect their characters. No character records found.")
                        elseif finished then
                            subtitle:SetText(string.format("Browse accounts and inspect their characters. Loaded %d of %d records.", loadedCount, totalCount))
                        else
                            subtitle:SetText(string.format("Browse accounts and inspect their characters. Loading %d of %d records...", loadedCount, totalCount))
                        end
                    end

                    function self:appendCharacterListPage(pageData)
                        for steamID, characters in pairs(pageData.players or {}) do
                            addCharacterRows(steamID, characters)
                        end

                        sortAccounts()
                        if selectedSteamID then selectedAccount = accountIndex[selectedSteamID] end
                        populateAccounts(accountSearch:GetValue() or "")
                        if not selectedAccount and accounts[1] then
                            selectAccount(accounts[1])
                        elseif selectedAccount then
                            populateCharacters(characterSearch:GetValue() or "")
                        else
                            buildDetail(nil, nil)
                        end
                    end

                    populateAccounts("")
                    if accounts[1] then
                        selectAccount(accounts[1])
                    else
                        buildDetail(nil, nil)
                    end

                    self:updateCharacterListProgress(self.charListLoadedCount or 0, self.charListTotalCount or 0, false)
                end

                self:startFullCharListRequest(panel)
            end
        })
    end

    local casePermissions = self:GetStaffCasesPermissions(client)
    if casePermissions.any then
        table.insert(pages, {
            name = "Staff Cases",
            icon = "icon16/report.png",
            drawFunc = function(panel) self:OpenStaffCases(panel) end
        })
    end
end

spawnmenu.AddContentType("inventoryitem", function(container, data)
    local client = LocalPlayer()
    local canUseItemSpawner = client:hasPrivilege("canUseItemSpawner")
    if not canUseItemSpawner then return end
    local icon = vgui.Create("liaItemIcon", container)
    icon:SetSize(168, 168)
    icon:DockMargin(10, 10, 10, 10)
    icon.GetSpawnName = function() return data.id end
    icon.SetSpawnName = function(_, name) data.id = name end
    icon.SetContentType = function() end
    icon:SetName(data.name)
    local itemData = lia.item.list[data.id]
    icon:setItemType(data.id)
    if icon.Icon then
        icon.Icon:SetSize(152, 152)
        local w, h = icon:GetSize()
        local iconW, iconH = icon.Icon:GetSize()
        icon.Icon:SetPos((w - iconW) * 0.5, (h - iconH) * 0.5)
    end

    icon:SetColor(Color(205, 92, 92, 255))
    icon.PaintOver = function(_, w, h)
        local name = itemData:getName()
        surface.SetFont("LiliaFont.18")
        local textW, textH = surface.GetTextSize(name)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, h - textH - 6, w, textH + 6)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos((w - textW) * 0.5, h - textH - 3)
        surface.DrawText(name)
    end

    local lines = {}
    lines[#lines + 1] = "<font=LiliaFont.16>" .. itemData:getName() .. "</font>"
    local rarity = itemData:getData("rarity") or itemData.rarity
    if rarity and rarity ~= "" then
        local rarityText = rarity
        local rarityColors = lia.item and lia.item.rarities
        local rarityColor = rarityColors and rarityColors[rarity]
        if rarityColor then rarityText = Format("<color=%s, %s, %s>%s</color>", rarityColor.r, rarityColor.g, rarityColor.b, rarity) end
        lines[#lines + 1] = "<font=LiliaFont.16>" .. rarityText .. "</font>"
    end

    lines[#lines + 1] = "<font=LiliaFont.16>" .. itemData:getDesc() .. "</font>"
    icon:SetTooltip(table.concat(lines, "\n"))
    icon.lastSpawnTime = 0
    icon.DoClick = function(self)
        local currentTime = CurTime()
        if self.lastSpawnTime and currentTime - self.lastSpawnTime < 0.5 then return end
        self.lastSpawnTime = currentTime
        net.Start("liaSpawnMenuSpawnItem")
        net.WriteString(data.id)
        net.SendToServer()
        lia.websound.playButtonSound("outlands-rp/ui/ui_return.wav")
    end

    icon.OpenMenu = function()
        net.Start("liaSpawnMenuGiveItem")
        net.WriteString(data.id)
        net.WriteString(LocalPlayer():SteamID())
        net.SendToServer()
        LocalPlayer():notifySuccess(L("itemGivenToSelf"))
        lia.websound.playButtonSound("outlands-rp/ui/ui_return.wav")
    end

    container:Add(icon)
    return icon
end)

function MODULE:PopulateInventoryItems(pnlContent, tree)
    local allItems = lia.item.list
    local categorized = {
        Unsorted = {}
    }

    tree:Clear()
    for uniqueID, itemData in pairs(allItems) do
        local category = itemData:getCategory()
        categorized[category] = categorized[category] or {}
        table.insert(categorized[category], {
            id = uniqueID,
            name = itemData:getName()
        })
    end

    for category, itemList in SortedPairs(categorized) do
        if category ~= L("unsorted") or #itemList > 0 then
            local node = tree:AddNode(category == L("unsorted") and L("unsorted") or category, "icon16/picture.png")
            node.DoPopulate = function(btn)
                if btn.PropPanel then return end
                btn.PropPanel = vgui.Create("ContentContainer", pnlContent)
                btn.PropPanel:SetVisible(false)
                btn.PropPanel:SetTriggerSpawnlistChange(false)
                local originalLayout = btn.PropPanel.PerformLayout
                local shiftAmount = 45
                local shiftDownAmount = 20
                btn.PropPanel.PerformLayout = function(panel, w, h)
                    if originalLayout then originalLayout(panel, w, h) end
                    for _, child in pairs(panel:GetChildren()) do
                        if IsValid(child) then
                            local x, y = child:GetPos()
                            if x < shiftAmount then child:SetPos(x + shiftAmount, y + shiftDownAmount) end
                        end
                    end
                end

                for _, itemListData in SortedPairsByMemberValue(itemList, "name") do
                    spawnmenu.CreateContentIcon("inventoryitem", btn.PropPanel, {
                        name = itemListData.name,
                        id = itemListData.id
                    })
                end
            end

            node.DoClick = function(btn)
                btn:DoPopulate()
                pnlContent:SwitchPanel(btn.PropPanel)
            end
        end
    end
end

search.AddProvider(function(str)
    local results = {}
    if not str or str == "" then return results end
    local query = string.lower(str)
    for uniqueID, itemData in pairs(lia.item.list or {}) do
        local name = tostring(itemData:getName() or "")
        local desc = tostring(itemData:getDesc() or "")
        local category = tostring((itemData.getCategory and itemData:getCategory()) or "")
        if string.find(string.lower(name), query, 1, true) or string.find(string.lower(desc), query, 1, true) or string.find(string.lower(category), query, 1, true) or string.find(string.lower(uniqueID), query, 1, true) then
            local icon = spawnmenu.CreateContentIcon("inventoryitem", g_SpawnMenu and g_SpawnMenu.SearchPropPanel or nil, {
                name = name ~= "" and name or uniqueID,
                id = uniqueID
            })

            table.insert(results, {
                text = name ~= "" and name or uniqueID,
                icon = icon
            })
        end
    end

    table.SortByMember(results, "text", true)
    return results
end, "inventoryitems")

spawnmenu.AddCreationTab(L("inventoryItems"), function()
    local client = LocalPlayer()
    local canUseItemSpawner = IsValid(client) and client.hasPrivilege and client:hasPrivilege("canUseItemSpawner") or false
    if not IsValid(client) or not client.hasPrivilege or not canUseItemSpawner then
        local pnl = vgui.Create("DPanel")
        pnl:Dock(FILL)
        pnl.Paint = function(_, w, h) draw.SimpleText(L("noItemSpawnerPermission"), "DermaDefault", w / 2, h / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        return pnl
    else
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        if isfunction(ctrl.EnableSearch) then ctrl:EnableSearch("inventoryitems", "PopulateInventoryItems") end
        timer.Simple(0, function() if IsValid(ctrl) then ctrl:CallPopulateHook("PopulateInventoryItems") end end)
        return ctrl
    end
end, "icon16/briefcase.png")

lia.net.readBigTable("liaAllFlags", function(data)
    flagsData = data or {}
    if IsValid(panelRef) and panelRef.flagsInitialized then
        OpenFlagsPanel(panelRef, flagsData)
        flagsData = nil
    end
end)

lia.net.readBigTable("liaStaffSummary", function(data)
    if not IsValid(panelRef) or not data then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = nil
    local search = panelRef:Add("liaEntry")
    search:Dock(TOP)
    search:DockMargin(0, 20, 0, 15)
    search:SetTall(30)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    local list = panelRef:Add("liaTable")
    list:Dock(FILL)
    panelRef.searchEntry = search
    panelRef.list = list
    panelRef:InvalidateLayout(true)
    panelRef:SizeToChildren(false, true)
    local columns = {
        {
            name = L("player"),
            field = "player"
        },
        {
            name = L("playerSteamID"),
            field = "steamID"
        },
        {
            name = L("usergroup"),
            field = "usergroup"
        },
        {
            name = L("warningCount"),
            field = "warnings"
        },
        {
            name = L("ticketCount"),
            field = "tickets"
        },
        {
            name = L("kickCount"),
            field = "kicks"
        },
        {
            name = L("killCount"),
            field = "kills"
        },
        {
            name = L("respawnCount"),
            field = "respawns"
        },
        {
            name = L("blindCount"),
            field = "blinds"
        },
        {
            name = L("muteCount"),
            field = "mutes"
        },
        {
            name = L("jailCount"),
            field = "jails"
        },
        {
            name = L("stripCount"),
            field = "strips"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

    list:AddMenuOption(L("copyRow"), function(rowData)
        local rowString = ""
        for i, column in ipairs(columns) do
            local header = column.name or L("columnWithNumber", i)
            local value = tostring(rowData[i] or "")
            rowString = rowString .. header .. " " .. value .. " | "
        end

        SetClipboardText(string.sub(rowString, 1, -4))
    end, "icon16/page_copy.png")

    list:AddMenuOption(L("viewWarningsIssued"), function(rowData)
        local steamID = rowData[2] or ""
        local warningCount = tonumber(rowData[4]) or 0
        if steamID ~= "" and warningCount > 0 then LocalPlayer():ConCommand("say /viewwarnsissued " .. steamID) end
    end, "icon16/error.png")

    list:AddMenuOption(L("viewTicketClaims"), function(rowData)
        local steamID = rowData[2] or ""
        local ticketCount = tonumber(rowData[5]) or 0
        if steamID ~= "" and ticketCount > 0 then LocalPlayer():ConCommand("say /plyviewclaims " .. steamID) end
    end, "icon16/page_white_text.png")

    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, info in ipairs(data) do
            local values = {info.player or "", info.steamID or "", info.usergroup or "", info.warnings or 0, info.tickets or 0, info.kicks or 0, info.kills or 0, info.respawns or 0, info.blinds or 0, info.mutes or 0, info.jails or 0, info.strips or 0}
            local match = false
            if filter == "" then
                match = true
            else
                for _, value in ipairs(values) do
                    if tostring(value):lower():find(filter, 1, true) then
                        match = true
                        break
                    end
                end
            end

            if match then list:AddLine(unpack(values)) end
        end

        list:ForceCommit()
        list:InvalidateLayout(true)
        if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
    end

    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
end)

lia.net.readBigTable("liaAllPlayers", function(players)
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = nil
    local search = panelRef:Add("liaEntry")
    search:Dock(TOP)
    search:DockMargin(0, 20, 0, 15)
    search:SetTall(30)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    local list = panelRef:Add("liaTable")
    list:Dock(FILL)
    panelRef.searchEntry = search
    panelRef.list = list
    panelRef:InvalidateLayout(true)
    panelRef:SizeToChildren(false, true)
    local columns = {
        {
            name = L("steamName"),
            field = "steamName"
        },
        {
            name = L("steamID"),
            field = "steamID"
        },
        {
            name = L("usergroup"),
            field = "userGroup"
        },
        {
            name = L("firstJoin"),
            field = "firstJoin"
        },
        {
            name = L("lastOnline"),
            field = "lastOnline"
        },
        {
            name = L("playtime"),
            field = "playtime"
        },
        {
            name = L("characters"),
            field = "characters"
        },
        {
            name = L("warnsModuleName"),
            field = "warnings"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

    list:AddMenuOption(L("copyRow"), function(rowData)
        local rowString = ""
        for i, column in ipairs(columns) do
            local header = column.name or L("columnWithNumber", i)
            local value = tostring(rowData[i] or "")
            rowString = rowString .. header .. " " .. value .. " | "
        end

        SetClipboardText(string.sub(rowString, 1, -4))
    end, "icon16/page_copy.png")

    list:AddMenuOption(L("copySteamID"), function(rowData) SetClipboardText(tostring(rowData[2] or "")) end, "icon16/page_copy.png")
    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, v in ipairs(players or {}) do
            local steamName = v.steamName or ""
            local steamID = v.steamID or ""
            local userGroup = v.userGroup or ""
            local ply = player.GetBySteamID(steamID)
            local lastOnlineText
            if IsValid(ply) then
                lastOnlineText = L("onlineNow")
            else
                local last = tonumber(v.lastOnline)
                if last and last > 0 then
                    local lastDiff = os.time() - last
                    local timeSince = lia.time.timeSince(last)
                    local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                    lastOnlineText = L("agoFormat", timeStripped, lia.time.formatDHM(lastDiff))
                else
                    lastOnlineText = L("unknown")
                end
            end

            local playtime
            if IsValid(ply) then
                playtime = lia.time.formatDHM(ply:getPlayTime())
            else
                playtime = lia.time.formatDHM(tonumber(v.totalOnlineTime) or 0)
            end

            local charCount = tonumber(v.characterCount) or 0
            local warnings = tonumber(v.warnings) or 0
            local ticketRequests = tonumber(v.ticketsRequested) or 0
            local ticketClaims = tonumber(v.ticketsClaimed) or 0
            if filter == "" or steamName:lower():find(filter, 1, true) or steamID:lower():find(filter, 1, true) or userGroup:lower():find(filter, 1, true) then
                local lineData = {steamName, steamID, userGroup, v.firstJoin or L("unknown"), lastOnlineText, playtime, charCount, warnings}
                lineData.steamID = v.steamID
                lineData.ticketRequests = ticketRequests
                lineData.ticketClaims = ticketClaims
                list:AddLine(unpack(lineData))
            end
        end

        list:ForceCommit()
        list:InvalidateLayout(true)
        if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
    end

    list:AddMenuOption(L("openSteamProfile"), function(rowData) if rowData.steamID then gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(rowData.steamID)) end end, "icon16/world.png")
    list:AddMenuOption(L("viewWarnings"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewwarns") then staffCasesCommand("viewwarns", rowData.steamID) end end, "icon16/error.png")
    list:AddMenuOption(L("viewTicketRequests"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewtickets") then LocalPlayer():ConCommand("say /viewtickets " .. rowData.steamID) end end, "icon16/help.png")
    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
end)

lia.net.readBigTable("liaFullCharList", function(data)
    if not IsValid(panelRef) or not data or not isfunction(panelRef.buildSheets) then return end
    panelRef.charListBuilt = true
    panelRef.charListLoadedCount = 0
    for _, characters in pairs(data.players or {}) do
        panelRef.charListLoadedCount = panelRef.charListLoadedCount + #characters
    end

    panelRef.charListTotalCount = panelRef.charListLoadedCount
    panelRef:buildSheets(data)
    if isfunction(panelRef.updateCharacterListProgress) then panelRef:updateCharacterListProgress(panelRef.charListLoadedCount, panelRef.charListTotalCount, true) end
end)

lia.net.readBigTable("liaFullCharListPage", function(data)
    if not IsValid(panelRef) or not data or not isfunction(panelRef.buildSheets) then return end
    if panelRef.charListRequestID ~= data.requestID then return end
    panelRef.charListLoadedCount = math.min((panelRef.charListLoadedCount or 0) + (tonumber(data.count) or 0), tonumber(data.total) or 0)
    panelRef.charListTotalCount = tonumber(data.total) or panelRef.charListLoadedCount
    if not panelRef.charListBuilt then
        panelRef.charListBuilt = true
        panelRef:buildSheets({
            players = data.players or {}
        })
    elseif isfunction(panelRef.appendCharacterListPage) then
        panelRef:appendCharacterListPage(data)
    end

    if isfunction(panelRef.updateCharacterListProgress) then panelRef:updateCharacterListProgress(panelRef.charListLoadedCount, panelRef.charListTotalCount, data.done) end
    if not data.done then requestFullCharListPage(panelRef, (tonumber(data.offset) or 0) + (tonumber(data.count) or 0)) end
end)

function MODULE:PostDrawTranslucentRenderables()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local wep = client:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "lia_mapconfigurer" then return end
    if not wep.CanUseTool or not wep:CanUseTool() then return end
    local typeInfo = wep.GetPositionToolMode and wep:GetPositionToolMode()
    local cacheType = wep.GetCacheType and wep:GetCacheType()
    local cachedPositions = wep.GetCachedPositions and wep:GetCachedPositions() or {}
    if not typeInfo or cacheType ~= typeInfo.id or #cachedPositions == 0 then return end
    local col = typeInfo.color or Color(255, 255, 255)
    local eyePos = client:EyePos()
    cam.Start3D()
    for i = 1, #cachedPositions do
        local entry = cachedPositions[i]
        local pos = entry.pos
        if not isvector(pos) then continue end
        local trace = util.TraceLine({
            start = eyePos,
            endpos = pos,
            mask = MASK_SOLID_BRUSHONLY
        })

        if trace.Fraction < 1 then
            render.DrawLine(eyePos, trace.HitPos, Color(col.r, col.g, col.b, 80))
            render.DrawLine(trace.HitPos, pos, Color(col.r, col.g, col.b, 160))
        else
            render.DrawLine(eyePos, pos, Color(col.r, col.g, col.b, 120))
        end
    end

    cam.End3D()
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local hudFontLarge = "HUDFont.24"
    local hudFontSmall = "HUDFont.16"
    local wep = client:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "gmod_tool" then return end
    if IsValid(wep) and wep:GetClass() == "lia_mapconfigurer" and wep.CanUseTool and wep:CanUseTool() then
        local typeInfo = wep.GetPositionToolMode and wep:GetPositionToolMode()
        local cacheType = wep.GetCacheType and wep:GetCacheType()
        local cachedPositions = wep.GetCachedPositions and wep:GetCachedPositions() or {}
        if typeInfo and cacheType == typeInfo.id and #cachedPositions > 0 then
            local col = typeInfo.color or Color(255, 255, 255)
            for i = 1, #cachedPositions do
                local entry = cachedPositions[i]
                local pos = entry.pos
                if isvector(pos) then
                    local screenPos = (pos + Vector(0, 0, 16)):ToScreen()
                    if screenPos.visible then
                        local label = entry.label ~= "" and entry.label or L("position")
                        if typeInfo.id == "faction_spawn_adder" then
                            label = L("spawnForFactionFormat", label)
                        elseif typeInfo.id == "class_spawn_adder" then
                            label = L("spawnForClassFormat", label)
                        elseif typeInfo.id == "sit_room" then
                            label = L("sitRoomLabelFormat", label)
                        end

                        lia.util.drawESPStyledText(label, screenPos.x, screenPos.y, col, hudFontLarge, 1)
                    end
                end
            end
        end
    end

    if not client:IsPlayer() or not client:getChar() then return end
    if client:GetMoveType() ~= MOVETYPE_NOCLIP then return end
    local hasNoClipESPOffsetStaff = client:hasPrivilege("noClipESPOffsetStaff")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasNoClipESPOffsetStaff or isStaffOnDuty
    if not permission then return end
    if not lia.option.get("espEnabled", false) then return end
    for _, ent in ents.Iterator() do
        if not IsValid(ent) or ent == client or ent:IsWeapon() then continue end
        local pos = ent:GetPos()
        if not pos then continue end
        local kind, label, subLabel, baseColor, customRender
        local hookResult = hook.Run("GetAdminESPTarget", ent, client)
        if istable(hookResult) then
            kind = hookResult.kind
            label = hookResult.label
            subLabel = hookResult.subLabel
            baseColor = hookResult.baseColor
            customRender = hookResult.customRender
        elseif ent:IsPlayer() and lia.option.get("espPlayers", false) then
            kind = L("players")
            subLabel = ent:Name():gsub("#", "\226\128\139#")
            label = subLabel
            baseColor = lia.option.get("espPlayersColor")
        elseif ent.isItem and ent:isItem() and lia.option.get("espItems", false) then
            kind = L("items")
            local item = ent:getItemTable()
            label = item and item:getName() or L("unknown")
            baseColor = lia.option.get("espItemsColor")
        elseif lia.option.get("espEntities", false) and ent:GetClass():StartWith("lia_") then
            if lia.dialog.isDialogNPCEntity(ent) then
                local uniqueID = ent:getNetVar("uniqueID", "")
                if uniqueID ~= "" then
                    kind = "npcs"
                    label = ent:getNetVar("NPCName", L("unconfiguredNPC"))
                    baseColor = lia.option.get("espEntitiesColor")
                end
            else
                kind = L("entities")
                label = ent.PrintName or ent:GetClass()
                baseColor = lia.option.get("espEntitiesColor")
            end
        elseif ent:isDoor() then
            local doorData = lia.doors.getData(ent)
            local isConfigured = doorData and ((doorData.factions and #doorData.factions > 0) or (doorData.classes and #doorData.classes > 0) or (doorData.name and doorData.name ~= "") or (doorData.title and doorData.title ~= "") or (doorData.price or 0) > 0 or doorData.locked or doorData.disabled or doorData.hidden or doorData.noSell)
            if lia.option.get("espUnconfiguredDoors", false) and not isConfigured then
                kind = L("doorUnconfigured")
                label = kind
                baseColor = lia.option.get("espUnconfiguredDoorsColor")
            elseif lia.option.get("espConfiguredDoors", false) and isConfigured then
                kind = L("doorConfigured")
                label = kind
                baseColor = lia.option.get("espConfiguredDoorsColor")
            end
        end

        if not kind then continue end
        local screenPos = pos:ToScreen()
        if not screenPos.visible then continue end
        if customRender then
            customRender(ent, screenPos, kind, label, subLabel, baseColor)
        else
            surface.SetFont(hudFontLarge)
            local _, th = surface.GetTextSize(label)
            local bh = th + 16
            lia.util.drawESPStyledText(label, screenPos.x, screenPos.y, baseColor, hudFontLarge)
            if subLabel and subLabel ~= label then
                local font = (kind == "npcs") and hudFontSmall or hudFontLarge
                surface.SetFont(font)
                surface.GetTextSize(subLabel)
                local spacing = 8
                local subY = screenPos.y + bh / 2 + spacing
                lia.util.drawESPStyledText(subLabel, screenPos.x, subY, baseColor, font)
            end
        end
    end
end

local function DisplayPositionToolHUD(client, hudInfos, weapon)
    local instructions = {L("positionToolInstructionSetAim"), L("positionToolInstructionUseCurrentPosition"), L("positionToolInstructionCycleMode"), L("positionToolInstructionOpenRemovalMenu")}
    local typeInfo = weapon.GetPositionToolMode and weapon:GetPositionToolMode()
    if typeInfo and typeInfo.name then table.insert(instructions, 1, L("positionToolCurrentMode", typeInfo.name)) end
    table.insert(hudInfos, {
        text = instructions,
        font = "HUDFont.18",
        color = Color(180, 180, 180),
        position = {
            x = ScrW() - 20,
            y = 20
        },
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        backgroundColor = Color(25, 28, 35, 250),
        borderRadius = 6,
        borderThickness = 0,
        padding = 12,
        blur = {
            enabled = true,
            amount = 1,
            passes = 1,
            alpha = 1.0
        },
        shadow = {
            enabled = true,
            offsetX = 8,
            offsetY = 12,
            color = lia.color.theme.window_shadow or Color(0, 0, 0, 50)
        },
        accentBorder = {
            enabled = true,
            height = 2,
            color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
        }
    })
end

local function DisplayDistanceToolHUD(client, hudInfos, weapon)
    local instructions = {L("distanceToolSetPoint"), L("distanceToolClearPoints"), L("distanceToolMeasureCurrent")}
    table.insert(hudInfos, {
        text = instructions,
        font = "HUDFont.18",
        color = Color(180, 180, 180),
        position = {
            x = ScrW() - 20,
            y = 20
        },
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        backgroundColor = Color(25, 28, 35, 250),
        borderRadius = 6,
        borderThickness = 0,
        padding = 12,
        blur = {
            enabled = true,
            amount = 1,
            passes = 1,
            alpha = 1.0
        },
        shadow = {
            enabled = true,
            offsetX = 8,
            offsetY = 12,
            color = lia.color.theme.window_shadow or Color(0, 0, 0, 50)
        },
        accentBorder = {
            enabled = true,
            height = 2,
            color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
        }
    })

    if weapon.StartPos then
        local tr = client:GetEyeTrace()
        local distance = weapon.StartPos:Distance(tr.HitPos)
        local distanceText = string.format("Distance: %.1f units", distance)
        table.insert(hudInfos, {
            text = distanceText,
            font = "HUDFont.20",
            color = Color(255, 255, 255),
            position = {
                x = ScrW() * 0.5,
                y = 30
            },
            textAlignX = TEXT_ALIGN_CENTER,
            textAlignY = TEXT_ALIGN_TOP,
            backgroundColor = Color(25, 28, 35, 250),
            borderRadius = 12,
            borderThickness = 0,
            padding = 20,
            blur = {
                enabled = true,
                amount = 1,
                passes = 1,
                alpha = 1.0
            },
            shadow = {
                enabled = true,
                offsetX = 15,
                offsetY = 20,
                color = Color(0, 0, 0, 180)
            },
            accentBorder = {
                enabled = true,
                height = 2,
                color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
            }
        })
    else
        table.insert(hudInfos, {
            text = L("distanceMeasureClickToSetStart"),
            font = "HUDFont.16",
            color = Color(180, 180, 180),
            position = {
                x = ScrW() * 0.5,
                y = 30
            },
            textAlignX = TEXT_ALIGN_CENTER,
            textAlignY = TEXT_ALIGN_TOP,
            backgroundColor = Color(25, 28, 35, 240),
            borderRadius = 12,
            borderThickness = 0,
            padding = 20,
            blur = {
                enabled = true,
                amount = 1,
                passes = 1,
                alpha = 1.0
            },
            shadow = {
                enabled = true,
                offsetX = 15,
                offsetY = 20,
                color = Color(0, 0, 0, 180)
            },
            accentBorder = {
                enabled = true,
                height = 2,
                color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
            }
        })
    end

    table.insert(hudInfos, {
        text = distanceLines,
        font = "HUDFont.20",
        position = {
            x = 20,
            y = IsValid(lia.gui and lia.gui.actionCircle) and (ScrH() - 140) or (ScrH() - 30)
        },
        textAlignX = TEXT_ALIGN_LEFT,
        textAlignY = TEXT_ALIGN_BOTTOM
    })
end

function MODULE:DisplayPlayerHUDInformation(client, hudInfos)
    if not client:getChar() then return end
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end
    if weapon:GetClass() == "lia_mapconfigurer" then
        DisplayPositionToolHUD(client, hudInfos, weapon)
    elseif weapon:GetClass() == "lia_distance" then
        DisplayDistanceToolHUD(client, hudInfos, weapon)
    end
end