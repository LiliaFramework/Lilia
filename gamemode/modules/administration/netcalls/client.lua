net.Receive("liaCfgList", function()
    local changed = net.ReadTable()
    for key, value in pairs(changed) do
        if lia.config.stored[key] then lia.config.stored[key].value = value end
    end

    hook.Run("InitializedConfig")
end)

net.Receive("liaCfgSet", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local config = lia.config.stored[key]
    if config then
        local oldValue = config.value
        config.value = value
        if config.callback then config.callback(oldValue, value) end
        hook.Run("OnConfigUpdated", key, oldValue, value)
        local properties = lia.gui.properties
        if IsValid(properties) then
            local row = properties:GetCategory(L(config.data and config.data.category or "misc")):GetRow(key)
            if IsValid(row) then
                if istable(value) and value.r and value.g and value.b then value = Vector(value.r / 255, value.g / 255, value.b / 255) end
                row:SetValue(value)
            end
        end
    end
end)

net.Receive("liaBlindTarget", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "blindTarget", function() draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "blindTarget")
    end
end)

net.Receive("liaBlindFade", function()
    local isWhite = net.ReadBool()
    local duration = net.ReadFloat()
    local fadeIn = net.ReadFloat()
    local fadeOut = net.ReadFloat()
    local startTime = CurTime()
    local endTime = startTime + duration
    local color = isWhite and Color(255, 255, 255) or Color(0, 0, 0)
    local hookName = "blindFade" .. startTime
    hook.Add("HUDPaint", hookName, function()
        local ct = CurTime()
        if ct >= endTime then
            hook.Remove("HUDPaint", hookName)
            return
        end

        local alpha
        if ct < startTime + fadeIn then
            alpha = (ct - startTime) / fadeIn
        elseif ct > endTime - fadeOut then
            alpha = (endTime - ct) / fadeOut
        else
            alpha = 1
        end

        surface.SetDrawColor(color.r, color.g, color.b, math.Clamp(alpha * 255, 0, 255))
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
end)

net.Receive("liaAdminModeSwapCharacter", function()
    local id = net.ReadInt(32)
    assert(isnumber(id), L("idMustBeNumber"))
    local d = deferred.new()
    net.Receive("liaCharChoose", function()
        local message = net.ReadString()
        if message == "" then
            d:resolve()
            lia.char.getCharacter(id, nil, function(character) hook.Run("CharLoaded", character) end)
        else
            d:reject(message)
        end
    end)

    d:catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()
end)

net.Receive("liaManageSitRooms", function()
    local rooms = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("manageSitrooms"))
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 30, 10, 10)
    for name in pairs(rooms) do
        local entry = vgui.Create("DPanel", scroll)
        entry:SetTall(40)
        entry:Dock(TOP)
        entry:DockMargin(0, 0, 0, 5)
        local lbl = vgui.Create("DLabel", entry)
        lbl:Dock(LEFT)
        lbl:DockMargin(5, 0, 0, 0)
        lbl:SetText(name)
        lbl:SetTall(40)
        lbl:SetContentAlignment(4)
        local function makeButton(key, action)
            local btn = vgui.Create("DButton", entry)
            btn:Dock(RIGHT)
            btn:SetWide(80)
            btn:SetText(L(key))
            btn.DoClick = function()
                net.Start("liaManagesitroomsAction")
                net.WriteUInt(action, 2)
                net.WriteString(name)
                if action == 2 then
                    local prompt = vgui.Create("DFrame")
                    prompt:SetTitle(L("renameSitroomTitle"))
                    prompt:SetSize(300, 100)
                    prompt:Center()
                    prompt:MakePopup()
                    local txt = vgui.Create("DTextEntry", prompt)
                    txt:Dock(FILL)
                    local ok = vgui.Create("DButton", prompt)
                    ok:Dock(BOTTOM)
                    ok:SetText(string.upper(L("ok")))
                    ok.DoClick = function()
                        net.WriteString(txt:GetValue())
                        net.SendToServer()
                        prompt:Close()
                        frame:Close()
                    end
                    return
                end

                net.SendToServer()
                frame:Close()
            end
        end

        makeButton("teleport", 1)
        makeButton("reposition", 3)
        makeButton("rename", 2)
    end
end)

net.Receive("liaAllPks", function()
    local cases = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local list = panelRef:Add("DListView")
    list:Dock(FILL)
    local function addSizedColumn(text)
        local col = list:AddColumn(text)
        surface.SetFont(col.Header:GetFont())
        local w = surface.GetTextSize(col.Header:GetText())
        col:SetMinWidth(w + 16)
        col:SetWidth(w + 16)
        return col
    end

    addSizedColumn(L("timestamp"))
    addSizedColumn(L("character"))
    addSizedColumn(L("submitter"))
    addSizedColumn(L("evidence"))
    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, c in ipairs(cases) do
            local charInfo = string.format("%s (%s, %s)", c.player or L("na"), c.steamID or L("na"), c.charID or L("na"))
            local submitInfo = string.format("%s (%s)", c.submitterName or L("na"), c.submitterSteamID or L("na"))
            local timestamp = os.date("%Y-%m-%d %H:%M:%S", tonumber(c.timestamp) or 0)
            local lineData = {timestamp, charInfo, submitInfo, c.evidence or ""}
            local searchStr = table.concat(lineData, " ") .. " " .. (c.reason or "")
            if filter == "" or searchStr:lower():find(filter, 1, true) then
                local line = list:AddLine(unpack(lineData))
                line.steamID = c.steamID or ""
                line.reason = c.reason or ""
                line.evidence = c.evidence or ""
                line.submitter = c.submitterName or ""
                line.submitterSteamID = c.submitterSteamID or ""
                line.charID = c.charID
            end
        end
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copySubmitter"), function() SetClipboardText(string.format("%s (%s)", line.submitter, line.submitterSteamID)) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copyReason"), function() SetClipboardText(line.reason) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copyEvidence"), function() SetClipboardText(line.evidence) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copySteamID"), function() SetClipboardText(line.steamID) end):SetIcon("icon16/page_copy.png")
        if line.evidence and line.evidence:match("^https?://") then menu:AddOption(L("viewEvidence"), function() gui.OpenURL(line.evidence) end):SetIcon("icon16/world.png") end
        if line.charID then
            local owner = line.steamID and lia.util.getBySteamID(line.steamID)
            if IsValid(owner) then
                if lia.command.hasAccess(LocalPlayer(), "charban") then menu:AddOption(L("banCharacter"), function() LocalPlayer():ConCommand('say "/charban ' .. line.charID .. '"') end):SetIcon("icon16/cancel.png") end
                if lia.command.hasAccess(LocalPlayer(), "charwipe") then menu:AddOption(L("wipeCharacter"), function() LocalPlayer():ConCommand('say "/charwipe ' .. line.charID .. '"') end):SetIcon("icon16/user_delete.png") end
                if lia.command.hasAccess(LocalPlayer(), "charunban") then menu:AddOption(L("unbanCharacter"), function() LocalPlayer():ConCommand('say "/charunban ' .. line.charID .. '"') end):SetIcon("icon16/accept.png") end
            else
                if lia.command.hasAccess(LocalPlayer(), "charbanoffline") then menu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. line.charID .. '"') end):SetIcon("icon16/cancel.png") end
                if lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then menu:AddOption(L("wipeCharacterOffline"), function() LocalPlayer():ConCommand('say "/charwipeoffline ' .. line.charID .. '"') end):SetIcon("icon16/user_delete.png") end
                if lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then menu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. line.charID .. '"') end):SetIcon("icon16/accept.png") end
            end
        end

        menu:Open()
    end
end)

local function OpenRoster(panel, data)
    panel:Clear()
    local sheet = panel:Add("liaTabs")
    sheet:Dock(FILL)
    sheet:DockMargin(10, 10, 10, 10)
    panel.sheet = sheet
    for factionName, members in pairs(data) do
        local membersData = members
        local factionTable = lia.util.findFaction(LocalPlayer(), factionName)
        local isDefaultFaction = factionTable and factionTable.isDefault or false
        local page = vgui.Create("DPanel")
        page:Dock(FILL)
        page:DockPadding(10, 10, 10, 10)
        local rosterTable = page:Add("liaTable")
        rosterTable:Dock(FILL)
        rosterTable:AddColumn(L("name"), nil, TEXT_ALIGN_LEFT, true)
        rosterTable:AddColumn(L("steamID"), nil, TEXT_ALIGN_LEFT, true)
        rosterTable:AddColumn(L("class"), nil, TEXT_ALIGN_LEFT, true)
        rosterTable:AddColumn(L("playTime"), 100, TEXT_ALIGN_CENTER, true)
        rosterTable:AddColumn(L("lastOnline"), 120, TEXT_ALIGN_CENTER, true)
        local function populate()
            rosterTable:Clear()
            for _, member in ipairs(membersData) do
                local name = member.name or L("unnamed")
                local steamID = member.steamID or L("na")
                local className = member.class or L("none")
                local playTime = member.playTime or L("na")
                local lastOnline = member.lastOnline or L("na")
                local row = rosterTable:AddLine(name, steamID, className, playTime, lastOnline)
                row.rowData = member
                row.OnRightClick = function()
                    if not IsValid(row) or not row.rowData then return end
                    local rowData = row.rowData
                    local menu = lia.derma.dermaMenu()
                    if rowData.steamID and rowData.steamID ~= "" and IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("canManageFactions") and not isDefaultFaction then
                        menu:AddOption(L("kick"), function()
                            Derma_Query(L("kickConfirm"), L("confirm"), L("yes"), function()
                                net.Start("liaKickCharacter")
                                net.WriteInt(rowData.id, 32)
                                net.SendToServer()
                            end, L("no"))
                        end):SetIcon("icon16/user_delete.png")

                        if lia.command.hasAccess(LocalPlayer(), "charlist") then menu:AddOption(L("viewCharacterList"), function() LocalPlayer():ConCommand("say /charlist " .. rowData.steamID) end):SetIcon("icon16/page_copy.png") end
                    end

                    menu:AddOption(L("copyRow"), function()
                        local rowString = ""
                        for key, value in pairs(rowData) do
                            value = tostring(value or L("na"))
                            rowString = rowString .. key:gsub("^%l", string.upper) .. ": " .. value .. " | "
                        end

                        rowString = rowString:sub(1, -4)
                        SetClipboardText(rowString)
                    end):SetIcon("icon16/page_copy.png")

                    menu:AddOption(L("copyName"), function()
                        local charName = rowData.name or ""
                        SetClipboardText(charName)
                    end):SetIcon("icon16/page_copy.png")

                    if steamID and steamID ~= "" then
                        menu:AddOption(L("copySteamID"), function() SetClipboardText(steamID) end):SetIcon("icon16/page_copy.png")
                        menu:AddOption(L("openSteamProfile"), function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steamID)) end):SetIcon("icon16/world.png")
                    end

                    menu:Open()
                end
            end
        end

        populate()
        sheet:AddSheet(factionName, page)
    end
end

function OpenFlagsPanel(panel, data)
    panel:Clear()
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    local search = panel:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
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
        {
            name = L("playerFlagsTitle"),
            field = "playerFlags"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

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
            local pFlags = entry.playerFlags or ""
            local entryKey = steamID .. "|" .. name
            if not addedEntries[entryKey] then
                local values = {name, steamID, cFlags, pFlags}
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
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for i, column in ipairs(self.Columns or {}) do
                local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                local value = line:GetColumnText(i) or ""
                rowString = rowString .. header .. " " .. value .. " | "
            end

            SetClipboardText(string.sub(rowString, 1, -4))
        end):SetIcon("icon16/page_copy.png")

        menu:AddOption(L("modifyCharFlags"), function()
            local steamID = line:GetColumnText(2) or ""
            local currentFlags = line:GetColumnText(3) or ""
            Derma_StringRequest(L("modifyCharFlags"), L("modifyFlagsDesc"), currentFlags, function(text)
                text = string.gsub(text or "", "%s", "")
                net.Start("liaModifyFlags")
                net.WriteString(steamID)
                net.WriteString(text)
                net.WriteBool(false)
                net.SendToServer()
                line:SetColumnText(3, text)
            end)
        end):SetIcon("icon16/flag_orange.png")

        menu:AddOption(L("modifyPlayerFlags"), function()
            local steamID = line:GetColumnText(2) or ""
            local currentFlags = line:GetColumnText(4) or ""
            Derma_StringRequest(L("modifyPlayerFlags"), L("modifyFlagsDesc"), currentFlags, function(text)
                text = string.gsub(text or "", "%s", "")
                net.Start("liaModifyFlags")
                net.WriteString(steamID)
                net.WriteString(text)
                net.WriteBool(true)
                net.SendToServer()
                line:SetColumnText(4, text)
            end)
        end):SetIcon("icon16/flag_green.png")

        menu:Open()
    end
end

lia.net.readBigTable("liaAllFlags", function(data)
    flagsData = data or {}
    if IsValid(flagsPanel) and not flagsPanel.flagsInitialized then OpenFlagsPanel(flagsPanel, flagsData) end
    flagsData = nil
end)

lia.net.readBigTable("liaFactionRosterData", function(data)
    if IsValid(panelRef) and isfunction(panelRef.buildSheets) then
        panelRef:buildSheets(data or {})
    elseif IsValid(rosterPanel) then
        OpenRoster(rosterPanel, data or {})
    end
end)

lia.net.readBigTable("liaStaffSummary", function(data)
    if not IsValid(panelRef) or not data then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = nil
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
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
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = lia.derma.dermaMenu()
        local steamID = line:GetColumnText(2)
        local warningCount = tonumber(line:GetColumnText(4)) or 0
        if warningCount > 0 and lia.command.hasAccess(LocalPlayer(), "viewwarnsissued") then menu:AddOption(L("viewWarningsIssued"), function() LocalPlayer():ConCommand("say /viewwarnsissued " .. steamID) end):SetIcon("icon16/error.png") end
        local ticketCount = tonumber(line:GetColumnText(5)) or 0
        if ticketCount > 0 and lia.command.hasAccess(LocalPlayer(), "plyviewclaims") then menu:AddOption(L("viewTicketClaims"), function() LocalPlayer():ConCommand("say /plyviewclaims " .. steamID) end):SetIcon("icon16/page_white_text.png") end
        menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for i, column in ipairs(self.Columns or {}) do
                local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                local value = line:GetColumnText(i) or ""
                rowString = rowString .. header .. " " .. value .. " | "
            end

            SetClipboardText(string.sub(rowString, 1, -4))
        end):SetIcon("icon16/page_copy.png")

        menu:Open()
    end
end)

lia.net.readBigTable("liaAllPlayers", function(players)
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = nil
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
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
            name = L("warnings"),
            field = "warnings"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

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
                    local timeSince = lia.time.TimeSince(last)
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
                local line = list:AddLine(steamName, steamID, userGroup, v.firstJoin or L("unknown"), lastOnlineText, playtime, charCount, warnings)
                line.steamID = v.steamID
                line.ticketRequests = ticketRequests
                line.ticketClaims = ticketClaims
            end
        end
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) or not line.steamID then return end
        local menu = lia.derma.dermaMenu()
        if lia.command.hasAccess(LocalPlayer(), "charlist") then menu:AddOption(L("viewCharacterList"), function() LocalPlayer():ConCommand("say /charlist " .. line.steamID) end):SetIcon("icon16/page_copy.png") end
        menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for i, column in ipairs(self.Columns or {}) do
                local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                local value = line:GetColumnText(i) or ""
                rowString = rowString .. header .. " " .. value .. " | "
            end

            SetClipboardText(string.sub(rowString, 1, -4))
        end):SetIcon("icon16/page_copy.png")

        menu:AddOption(L("copySteamID"), function() SetClipboardText(line.steamID) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("openSteamProfile"), function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(line.steamID)) end):SetIcon("icon16/world.png")
        if lia.command.hasAccess(LocalPlayer(), "viewwarns") then menu:AddOption(L("viewWarnings"), function() LocalPlayer():ConCommand("say /viewwarns " .. line.steamID) end):SetIcon("icon16/error.png") end
        if lia.command.hasAccess(LocalPlayer(), "viewtickets") then menu:AddOption(L("viewTicketRequests"), function() LocalPlayer():ConCommand("say /viewtickets " .. line.steamID) end):SetIcon("icon16/help.png") end
        menu:Open()
    end
end)

lia.net.readBigTable("liaFullCharList", function(data)
    if not IsValid(panelRef) or not data or not isfunction(panelRef.buildSheets) then return end
    panelRef:buildSheets(data)
end)

net.Receive("liaCharDeleted", function()
    if IsValid(panelRef) and isfunction(panelRef.buildSheets) then
        net.Start("liaRequestFullCharList")
        net.SendToServer()
    end
end)

net.Receive("liaOnlineStaffData", function()
    local staffData = net.ReadTable() or {}
    hook.Run("liaOnlineStaffDataReceived", staffData)
end)
