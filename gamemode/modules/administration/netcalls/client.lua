net.Receive("cfgList", function()
    local changed = net.ReadTable()
    for key, value in pairs(changed) do
        if lia.config.stored[key] then lia.config.stored[key].value = value end
    end

    hook.Run("InitializedConfig")
end)

local function deserializeFallback(raw)
    if lia.data and lia.data.deserialize then return lia.data.deserialize(raw) end
    if istable(raw) then return raw end
    local decoded = util.JSONToTable(raw)
    if decoded == nil then
        local ok, result = pcall(pon.decode, raw)
        if ok then decoded = result end
    end
    return decoded or raw
end

local function tableToString(tbl)
    local out = {}
    for _, value in pairs(tbl) do
        out[#out + 1] = tostring(value)
    end
    return table.concat(out, ", ")
end

function openRowInfo(row)
    local columns = {
        {
            name = "field",
            field = "field"
        },
        {
            name = "type",
            field = "type"
        },
        {
            name = "coded",
            field = "coded"
        },
        {
            name = "decoded",
            field = "decoded"
        }
    }

    local rows = {}
    for k, v in pairs(row or {}) do
        local decoded = v
        if isstring(v) then decoded = deserializeFallback(v) end
        local codedStr = istable(v) and tableToString(v) or tostring(v)
        local decodedStr = istable(decoded) and tableToString(decoded) or tostring(decoded)
        rows[#rows + 1] = {
            field = k,
            type = type(v),
            coded = codedStr,
            decoded = decodedStr
        }
    end

    lia.util.CreateTableUI("rowDetailsTitle", columns, rows)
end

function openDecodedTable(tableName, columns, data)
    local columnInfo = {}
    for _, col in ipairs(columns or {}) do
        columnInfo[#columnInfo + 1] = {
            name = col,
            field = col
        }
    end

    local decodedRows = {}
    for _, row in ipairs(data or {}) do
        local decodedRow = {}
        for _, col in ipairs(columns or {}) do
            local value = row[col]
            if isstring(value) then value = deserializeFallback(value) end
            if istable(value) then
                decodedRow[col] = tableToString(value)
            else
                decodedRow[col] = tostring(value)
            end
        end

        decodedRows[#decodedRows + 1] = decodedRow
    end

    lia.util.CreateTableUI(L("decodedTableTitle", tableName), columnInfo, decodedRows)
end

net.Receive("liaDBTables", function()
    local tables = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("dbTablesTitle"))
    frame:SetSize(300, 400)
    frame:Center()
    frame:MakePopup()
    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    local col = list:AddColumn(L("dbTableColumn"))
    surface.SetFont(col.Header:GetFont())
    local w = surface.GetTextSize(col.Header:GetText())
    col:SetMinWidth(w + 16)
    col:SetWidth(w + 16)
    for _, tbl in ipairs(tables or {}) do
        list:AddLine(tbl)
    end

    function list:OnRowSelected(_, line)
        net.Start("liaRequestTableData")
        net.WriteString(line:GetColumnText(1))
        net.SendToServer()
    end
end)

net.Receive("liaDBTableData", function()
    local tbl = net.ReadString()
    local data = net.ReadTable()
    if not data or #data == 0 then return end
    local columnKeys, columns = {}, {}
    for k in pairs(data[1]) do
        columnKeys[#columnKeys + 1] = k
        columns[#columns + 1] = {
            name = k,
            field = k
        }
    end

    local _, list = lia.util.CreateTableUI(tbl, columns, data)
    if IsValid(list) then
        function list:OnRowRightClick(_, line)
            if not IsValid(line) or not line.rowData then return end
            local rowData = line.rowData
            local menu = DermaMenu()
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for key, value in pairs(rowData) do
                    value = tostring(value or L("na"))
                    rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
                end

                SetClipboardText(string.sub(rowString, 1, -4))
            end)

            menu:AddOption(L("viewEntry"), function() openRowInfo(rowData) end)
            menu:AddOption(L("viewDecodedTable"), function() openDecodedTable(tbl, columnKeys, data) end)
            menu:Open()
        end

        function list:OnRowSelected(_, line)
            openRowInfo(line.rowData)
        end
    end
end)

net.Receive("cfgSet", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local config = lia.config.stored[key]
    if config then
        if config.callback then config.callback(config.value, value) end
        config.value = value
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

net.Receive("blindTarget", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "blindTarget", function() draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "blindTarget")
    end
end)

net.Receive("blindFade", function()
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

net.Receive("AdminModeSwapCharacter", function()
    local id = net.ReadInt(32)
    assert(isnumber(id), L("idMustBeNumber"))
    local d = deferred.new()
    net.Receive("liaCharChoose", function()
        local message = net.ReadString()
        if message == "" then
            d:resolve()
            lia.char.getCharacter(id, nil, function(character)
                hook.Run("CharLoaded", character)
            end)
        else
            d:reject(message)
        end
    end)

    d:catch(function(err) if err and err ~= "" then LocalPlayer():notifyLocalized(err) end end)
    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()
end)

net.Receive("managesitrooms", function()
    local rooms = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("manageSitrooms"))
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()
    local scroll = vgui.Create("DScrollPanel", frame)
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
                net.Start("lia_managesitrooms_action")
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

net.Receive("liaAllPKs", function()
    local cases = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(255, 255, 255))
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
        local menu = DermaMenu()
        menu:AddOption(L("copySubmitter"), function() SetClipboardText(string.format("%s (%s)", line.submitter, line.submitterSteamID)) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copyReason"), function() SetClipboardText(line.reason) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copyEvidence"), function() SetClipboardText(line.evidence) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("copySteamID"), function() SetClipboardText(line.steamID) end):SetIcon("icon16/page_copy.png")
        if line.evidence and line.evidence:match("^https?://") then menu:AddOption(L("viewEvidence"), function() gui.OpenURL(line.evidence) end):SetIcon("icon16/world.png") end
        if line.charID then
            local owner = line.steamID and lia.util.getBySteamID(line.steamID)
            if IsValid(owner) then
                if lia.command.hasAccess(LocalPlayer(), "charban") then menu:AddOption(L("banCharacter"), function() LocalPlayer():ConCommand('say "/charban ' .. line.charID .. '"') end):SetIcon("icon16/cancel.png") end
                if lia.command.hasAccess(LocalPlayer(), "charunban") then menu:AddOption(L("unbanCharacter"), function() LocalPlayer():ConCommand('say "/charunban ' .. line.charID .. '"') end):SetIcon("icon16/accept.png") end
            else
                if lia.command.hasAccess(LocalPlayer(), "charbanoffline") then menu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. line.charID .. '"') end):SetIcon("icon16/cancel.png") end
                if lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then menu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. line.charID .. '"') end):SetIcon("icon16/accept.png") end
            end
        end

        menu:Open()
    end
end)

local charMenuContext
local function requestPlayerCharacters(steamID, line, buildMenu)
    charMenuContext = {
        pos = {gui.MousePos()},
        line = line,
        steamID = steamID,
        buildMenu = buildMenu
    }

    net.Start("liaRequestPlayerCharacters")
    net.WriteString(steamID)
    net.SendToServer()
end

local function OpenRoster(panel, data)
    panel:Clear()
    local sheet = panel:Add("DPropertySheet")
    sheet:Dock(FILL)
    sheet:DockMargin(10, 10, 10, 10)
    for factionName, members in pairs(data) do
        local membersData = members
        local factionTable = lia.util.findFaction(LocalPlayer(), factionName)
        local isDefaultFaction = factionTable and factionTable.isDefault or false
        local page = sheet:Add("DPanel")
        page:Dock(FILL)
        page:DockPadding(10, 10, 10, 10)
        local rosterSheet = page:Add("liaSheet")
        rosterSheet:Dock(FILL)
        rosterSheet:SetPlaceholderText(L("search"))
        local function populate()
            rosterSheet:Clear()
            for _, member in ipairs(membersData) do
                local title = member.name or L("unnamed")
                local desc = string.format("%s | %s | %s", member.steamID or L("na"), member.class or L("none"), member.playTime or L("na"))
                local right = member.lastOnline or L("na")
                local classData = member.classID and lia.class.list[member.classID]
                local hasLogo = classData and classData.logo and classData.logo ~= ""
                local row
                if hasLogo then
                    row = rosterSheet:AddRow(function(p, rowPanel)
                        local logoSize = 64
                        local margin = 8
                        local rowHeight = logoSize + rosterSheet.padding * 2
                        local logo = vgui.Create("DImage", p)
                        logo:SetSize(logoSize, logoSize)
                        logo:SetMaterial(Material(classData.logo))
                        logo:SetPos(margin, margin)
                        local t = vgui.Create("DLabel", p)
                        t:SetFont("liaMediumFont")
                        t:SetText(title)
                        t:SizeToContents()
                        t:SetPos(margin + logoSize + margin, margin)
                        local d = vgui.Create("DLabel", p)
                        d:SetFont("liaSmallFont")
                        d:SetWrap(true)
                        d:SetAutoStretchVertical(true)
                        d:SetText(desc)
                        d:SetPos(margin + logoSize + margin, margin + t:GetTall() + 5)
                        local r = vgui.Create("DLabel", p)
                        r:SetFont("liaSmallFont")
                        r:SetText(right)
                        r:SizeToContents()
                        p.PerformLayout = function()
                            local pad = rosterSheet.padding
                            local spacing = 5
                            logo:SetPos(pad, pad)
                            t:SetPos(pad + logoSize + pad, pad)
                            d:SetPos(pad + logoSize + pad, pad + t:GetTall() + spacing)
                            d:SetWide(p:GetWide() - (pad + logoSize + pad) - pad - (r:GetWide() + 10))
                            d:SizeToContentsY()
                            if r then
                                local y = d and pad + t:GetTall() + spacing + d:GetTall() - r:GetTall() or p:GetTall() * 0.5 - r:GetTall() * 0.5
                                r:SetPos(p:GetWide() - r:GetWide() - pad, math.max(pad, y))
                            end

                            local textH = pad + t:GetTall() + spacing + d:GetTall() + pad
                            p:SetTall(math.max(rowHeight, textH))
                        end

                        rowPanel.filterText = (title .. " " .. desc .. " " .. right):lower()
                    end)
                else
                    row = rosterSheet:AddTextRow({
                        title = title,
                        desc = desc,
                        right = right,
                        minHeight = rosterSheet.padding * 2 + 64
                    })
                end

                row.rowData = member
                row.filterText = (title .. " " .. desc .. " " .. right):lower()
                row.OnRightClick = function()
                    if not IsValid(row) or not row.rowData then return end
                    local rowData = row.rowData
                    local steamID = rowData.steamID
                    local menu = DermaMenu()
                    if steamID and steamID ~= "" and LocalPlayer():hasPrivilege("canManageFactions") and not isDefaultFaction then
                        menu:AddOption(L("kick"), function()
                            Derma_Query(L("kickConfirm"), L("confirm"), L("yes"), function()
                                net.Start("KickCharacter")
                                net.WriteInt(rowData.id, 32)
                                net.SendToServer()
                            end, L("no"))
                        end):SetIcon("icon16/user_delete.png")

                        if lia.command.hasAccess(LocalPlayer(), "charlist") then menu:AddOption(L("viewCharacterList"), function() LocalPlayer():ConCommand("say /charlist " .. steamID) end):SetIcon("icon16/page_copy.png") end
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
                        local name = rowData.name or ""
                        SetClipboardText(name)
                    end):SetIcon("icon16/page_copy.png")

                    if steamID and steamID ~= "" then
                        menu:AddOption(L("copySteamID"), function() SetClipboardText(steamID) end):SetIcon("icon16/page_copy.png")
                        menu:AddOption(L("openSteamProfile"), function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steamID)) end):SetIcon("icon16/world.png")
                    end

                    menu:Open()
                end
            end

            rosterSheet:Refresh()
        end

        populate()
        sheet:AddSheet(factionName, page)
    end
end

function OpenFlagsPanel(panel, data)
    panel:Clear()
    local search = panel:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(255, 255, 255))
    local list = panel:Add("DListView")
    list:Dock(FILL)
    local function addSizedColumn(text)
        local col = list:AddColumn(text)
        surface.SetFont(col.Header:GetFont())
        local w = surface.GetTextSize(col.Header:GetText())
        col:SetMinWidth(w + 16)
        col:SetWidth(w + 16)
        return col
    end

    addSizedColumn(L("name"))
    addSizedColumn(L("steamID"))
    addSizedColumn(L("charFlagsTitle"))
    addSizedColumn(L("playerFlagsTitle"))
    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, entry in ipairs(data or {}) do
            local name = entry.name or ""
            local steamID = entry.steamID or ""
            local cFlags = entry.flags or ""
            local pFlags = entry.playerFlags or ""
            if filter == "" or name:lower():find(filter, 1, true) or steamID:lower():find(filter, 1, true) or cFlags:lower():find(filter, 1, true) or pFlags:lower():find(filter, 1, true) then list:AddLine(name, steamID, cFlags, pFlags) end
        end
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = DermaMenu()
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
    if IsValid(flagsPanel) then
        OpenFlagsPanel(flagsPanel, flagsData)
        flagsData = nil
    end
end)

lia.net.readBigTable("liaFactionRosterData", function(data) if IsValid(rosterPanel) then OpenRoster(rosterPanel, data or {}) end end)
lia.net.readBigTable("liaDatabaseViewData", function(data)
    if not IsValid(panelRef) or not isfunction(panelRef.buildSheets) then return end
    panelRef:buildSheets(data)
end)

lia.net.readBigTable("liaStaffSummary", function(data)
    if not IsValid(panelRef) or not data then return end
    panelRef:Clear()
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(255, 255, 255))
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

    addSizedColumn(L("player"))
    addSizedColumn(L("playerSteamID"))
    addSizedColumn(L("usergroup"))
    addSizedColumn(L("warningCount"))
    addSizedColumn(L("ticketCount"))
    addSizedColumn(L("kickCount"))
    addSizedColumn(L("killCount"))
    addSizedColumn(L("respawnCount"))
    addSizedColumn(L("blindCount"))
    addSizedColumn(L("muteCount"))
    addSizedColumn(L("jailCount"))
    addSizedColumn(L("stripCount"))
    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, info in ipairs(data) do
            local entries = {info.player or "", info.steamID or "", info.usergroup or "", info.warnings or 0, info.tickets or 0, info.kicks or 0, info.kills or 0, info.respawns or 0, info.blinds or 0, info.mutes or 0, info.jails or 0, info.strips or 0}
            local match = false
            if filter == "" then
                match = true
            else
                for _, value in ipairs(entries) do
                    if tostring(value):lower():find(filter, 1, true) then
                        match = true
                        break
                    end
                end
            end

            if match then list:AddLine(unpack(entries)) end
        end
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = DermaMenu()
        local steamID = line:GetColumnText(2)
        local warningCount = tonumber(line:GetColumnText(4)) or 0
        if warningCount > 0 and lia.command.hasAccess(LocalPlayer(), "viewwarns") then menu:AddOption(L("viewWarningsIssued"), function() LocalPlayer():ConCommand("say /viewwarns " .. steamID) end):SetIcon("icon16/error.png") end
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

lia.net.readBigTable("liaPlayerCharacters", function(data)
    if not data or not charMenuContext then return end
    local menu = DermaMenu()
    if charMenuContext.buildMenu then charMenuContext.buildMenu(menu, charMenuContext.line, data.steamID, data.characters or {}) end
    if charMenuContext.pos then
        menu:Open(charMenuContext.pos[1], charMenuContext.pos[2])
    else
        menu:Open()
    end

    charMenuContext = nil
end)

lia.net.readBigTable("liaAllPlayers", function(players)
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(255, 255, 255))
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

    addSizedColumn(L("steamName"))
    addSizedColumn(L("steamID"))
    addSizedColumn(L("usergroup"))
    addSizedColumn(L("firstJoin"))
    addSizedColumn(L("lastOnline"))
    addSizedColumn(L("playtime"))
    addSizedColumn(L("characters"))
    addSizedColumn(L("warnings"))
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
        local parentList = self
        requestPlayerCharacters(line.steamID, line, function(menu, ln, steamID)
            if lia.command.hasAccess(LocalPlayer(), "charlist") then menu:AddOption(L("viewCharacterList"), function() LocalPlayer():ConCommand("say /charlist " .. steamID) end):SetIcon("icon16/page_copy.png") end
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for i, column in ipairs(parentList.Columns or {}) do
                    local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                    local value = ln:GetColumnText(i) or ""
                    rowString = rowString .. header .. " " .. value .. " | "
                end

                SetClipboardText(string.sub(rowString, 1, -4))
            end):SetIcon("icon16/page_copy.png")

            menu:AddOption(L("copySteamID"), function() SetClipboardText(steamID) end):SetIcon("icon16/page_copy.png")
            menu:AddOption(L("openSteamProfile"), function() gui.OpenURL("https://steamcommunity.com/profiles/" .. util.SteamIDTo64(steamID)) end):SetIcon("icon16/world.png")
            if lia.command.hasAccess(LocalPlayer(), "viewwarns") then menu:AddOption(L("viewWarnings"), function() LocalPlayer():ConCommand("say /viewwarns " .. steamID) end):SetIcon("icon16/error.png") end
            if lia.command.hasAccess(LocalPlayer(), "viewtickets") then menu:AddOption(L("viewTicketRequests"), function() LocalPlayer():ConCommand("say /viewtickets " .. steamID) end):SetIcon("icon16/help.png") end
        end)
    end
end)

lia.net.readBigTable("liaFullCharList", function(data)
    if not IsValid(panelRef) or not data or not isfunction(panelRef.buildSheets) then return end
    panelRef:buildSheets(data)
end)