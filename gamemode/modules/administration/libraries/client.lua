function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if not IsValid(client) or not IsValid(target) then return end
    if not (client:hasPrivilege("canAccessScoreboardInfoOutOfStaff") or client:hasPrivilege("canAccessScoreboardAdminOptions") and client:isStaffOnDuty()) then return end
    local orderedOptions = {
        {
            name = L("nameCopyFormat", target:Name()),
            image = "icon16/page_copy.png",
            func = function()
                client:notifyLocalized("copiedToClipboard", target:Name(), L("name"))
                SetClipboardText(target:Name())
            end
        },
        {
            name = L("charIDCopyFormat", target:getChar() and target:getChar():getID() or L("na")),
            image = "icon16/page_copy.png",
            func = function()
                if target:getChar() then
                    client:notifyLocalized("copiedCharID", target:getChar():getID())
                    SetClipboardText(target:getChar():getID())
                end
            end
        },
        {
            name = L("steamIDCopyFormat", target:SteamID()),
            image = "icon16/page_copy.png",
            func = function()
                client:notifyLocalized("copiedToClipboard", target:Name(), L("steamID"))
                SetClipboardText(target:SteamID())
            end
        },
        {
            name = L("blind"),
            image = "icon16/eye.png",
            func = function() RunConsoleCommand("say", "!blind " .. target:SteamID()) end
        },
        {
            name = L("freeze"),
            image = "icon16/lock.png",
            func = function() RunConsoleCommand("say", "!freeze " .. target:SteamID()) end
        },
        {
            name = L("gag"),
            image = "icon16/sound_mute.png",
            func = function() RunConsoleCommand("say", "!gag " .. target:SteamID()) end
        },
        {
            name = L("ignite"),
            image = "icon16/fire.png",
            func = function() RunConsoleCommand("say", "!ignite " .. target:SteamID()) end
        },
        {
            name = L("jail"),
            image = "icon16/lock.png",
            func = function() RunConsoleCommand("say", "!jail " .. target:SteamID()) end
        },
        {
            name = L("mute"),
            image = "icon16/sound_delete.png",
            func = function() RunConsoleCommand("say", "!mute " .. target:SteamID()) end
        },
        {
            name = L("slay"),
            image = "icon16/bomb.png",
            func = function() RunConsoleCommand("say", "!slay " .. target:SteamID()) end
        },
        {
            name = L("unblind"),
            image = "icon16/eye.png",
            func = function() RunConsoleCommand("say", "!unblind " .. target:SteamID()) end
        },
        {
            name = L("ungag"),
            image = "icon16/sound_low.png",
            func = function() RunConsoleCommand("say", "!ungag " .. target:SteamID()) end
        },
        {
            name = L("unfreeze"),
            image = "icon16/accept.png",
            func = function() RunConsoleCommand("say", "!unfreeze " .. target:SteamID()) end
        },
        {
            name = L("unmute"),
            image = "icon16/sound_add.png",
            func = function() RunConsoleCommand("say", "!unmute " .. target:SteamID()) end
        },
        {
            name = L("bring"),
            image = "icon16/arrow_down.png",
            func = function() RunConsoleCommand("say", "!bring " .. target:SteamID()) end
        },
        {
            name = L("goTo"),
            image = "icon16/arrow_right.png",
            func = function() RunConsoleCommand("say", "!goto " .. target:SteamID()) end
        },
        {
            name = L("respawn"),
            image = "icon16/arrow_refresh.png",
            func = function() RunConsoleCommand("say", "!respawn " .. target:SteamID()) end
        },
        {
            name = L("returnText"),
            image = "icon16/arrow_redo.png",
            func = function() RunConsoleCommand("say", "!return " .. target:SteamID()) end
        }
    }

    for _, v in ipairs(orderedOptions) do
        options[#options + 1] = v
    end
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    if client:hasPrivilege("viewStaffManagement") then
        table.insert(pages, {
            name = "moduleStaffManagementName",
            icon = "icon16/shield.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestStaffSummary")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("privilegeViewer") then
        table.insert(pages, {
            name = "privileges",
            icon = "icon16/key.png",
            drawFunc = function(panel)
                panelRef = panel
                panel:Clear()
                panel:DockPadding(10, 10, 10, 10)
                panel.Paint = function() end
                local function describe(id)
                    if string.find(id, "command_", 1, true) then return "Command access privilege" end
                    if string.find(id, "tool_", 1, true) then return "Tool access privilege" end
                    if string.find(id, "property_", 1, true) then return "Property access privilege" end
                    if string.find(id, "privilege_viewer", 1, true) then return "Access to view all privileges" end
                    return "General privilege"
                end

                function panel:buildSheets()
                    if IsValid(self.sheet) then self.sheet:Remove() end
                    self.sheet = self:Add("DPropertySheet")
                    self.sheet:Dock(FILL)
                    local privileges = lia.administrator.privileges or {}
                    local names = lia.administrator.privilegeNames or {}
                    local cats = lia.administrator.privilegeCategories or {}
                    local categories = {}
                    for id, minAccess in pairs(privileges) do
                        local name = names[id] or id
                        local category = cats[id] or "Unassigned"
                        categories[category] = categories[category] or {}
                        categories[category][#categories[category] + 1] = {id, name, minAccess, describe(id)}
                    end

                    for category, rows in SortedPairs(categories) do
                        table.sort(rows, function(a, b) return a[1] < b[1] end)
                        local pnl = self.sheet:Add("DPanel")
                        pnl:Dock(FILL)
                        pnl.Paint = function() end
                        local headers = {"ID", "Name", "Min Access", "Description"}
                        local listView = pnl:Add("DListView")
                        listView:Dock(FILL)
                        listView:SetMultiSelect(false)
                        for _, header in ipairs(headers) do
                            listView:AddColumn(header)
                        end

                        for _, row in ipairs(rows) do
                            listView:AddLine(unpack(row))
                        end

                        listView:SortByColumn(1, false)
                        listView.OnRowRightClick = function(_, _, line)
                            local m = DermaMenu()
                            for i, header in ipairs(headers) do
                                m:AddOption("Copy " .. header, function()
                                    SetClipboardText(line:GetColumnText(i) or "")
                                    notification.AddLegacy(L and L("copied") or "Copied", NOTIFY_GENERIC, 2)
                                end)
                            end

                            m:AddSpacer()
                            m:AddOption("Copy All", function()
                                local t = {}
                                for i, header in ipairs(headers) do
                                    t[#t + 1] = header .. ": " .. (line:GetColumnText(i) or "")
                                end

                                SetClipboardText(table.concat(t, "\n"))
                                notification.AddLegacy(L and L("allPrivilegeInfo") or "All info copied", NOTIFY_GENERIC, 2)
                            end)

                            m:Open()
                        end

                        listView.OnRowDoubleClick = function(_, _, line)
                            SetClipboardText(line:GetColumnText(1) or "")
                            notification.AddLegacy(L and L("privilegeIdCopied") or "ID copied", NOTIFY_GENERIC, 2)
                        end

                        self.sheet:AddSheet(L(category), pnl)
                    end
                end

                local refreshButton = vgui.Create("DButton", panel)
                refreshButton:Dock(TOP)
                refreshButton:DockMargin(0, 0, 0, 10)
                refreshButton:SetText(L("refresh"))
                refreshButton:SetTall(30)
                refreshButton.DoClick = function() panel:buildSheets() end
                panel:buildSheets()
            end
        })
    end

    if client:hasPrivilege("canAccessPlayerList") then
        table.insert(pages, {
            name = "players",
            icon = "icon16/user.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestPlayers")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("listCharacters") then
        table.insert(pages, {
            name = "characterList",
            icon = "icon16/book.png",
            drawFunc = function(panel)
                panelRef = panel
                panel:Clear()
                panel:DockPadding(10, 10, 10, 10)
                panel.Paint = function() end
                panel.sheet = panel:Add("DPropertySheet")
                panel.sheet:Dock(FILL)
                function panel:buildSheets(data)
                    if IsValid(self.sheet) then self.sheet:Remove() end
                    self.sheet = self:Add("DPropertySheet")
                    self.sheet:Dock(FILL)
                    local function formatPlayTime(secs)
                        local h = math.floor(secs / 3600)
                        local m = math.floor((secs % 3600) / 60)
                        local s = secs % 60
                        return string.format("%02i:%02i:%02i", h, m, s)
                    end

                    local hasBanInfo = false
                    for _, row in ipairs(data.all or {}) do
                        if row.Banned then
                            hasBanInfo = true
                            break
                        end
                    end

                    local columns = {
                        {
                            name = "id",
                            field = L("id")
                        },
                        {
                            name = "name",
                            field = L("name")
                        },
                        {
                            name = "description",
                            field = "Desc"
                        },
                        {
                            name = "faction",
                            field = L("faction")
                        },
                        {
                            name = "steamID",
                            field = L("steamID")
                        },
                        {
                            name = "lastUsed",
                            field = "LastUsed"
                        },
                        {
                            name = "banned",
                            field = L("banned"),
                            format = function(val) return val and L("yes") or L("no") end
                        }
                    }

                    if hasBanInfo then
                        table.insert(columns, {
                            name = "banningAdminName",
                            field = "BanningAdminName"
                        })

                        table.insert(columns, {
                            name = "banningAdminSteamID",
                            field = "BanningAdminSteamID"
                        })

                        table.insert(columns, {
                            name = "banningAdminRank",
                            field = "BanningAdminRank"
                        })
                    end

                    table.insert(columns, {
                        name = "playtime",
                        field = "PlayTime",
                        format = function(val) return formatPlayTime(val or 0) end
                    })

                    table.insert(columns, {
                        name = "money",
                        field = L("money"),
                        format = function(val) return lia.currency.get(tonumber(val) or 0) end
                    })

                    hook.Run("CharListColumns", columns)
                    local function createList(parent, rows)
                        local container = parent:Add("DPanel")
                        container:Dock(FILL)
                        container.Paint = function() end
                        local search = container:Add("DTextEntry")
                        search:Dock(TOP)
                        search:SetPlaceholderText(L("search"))
                        search:SetTextColor(Color(255, 255, 255))
                        local list = container:Add("DListView")
                        list:Dock(FILL)
                        local steamIDColumnIndex
                        for i, col in ipairs(columns) do
                            list:AddColumn(col.name)
                            if col.field == L("steamID") then steamIDColumnIndex = i end
                        end

                        local function populate(filter)
                            list:Clear()
                            filter = string.lower(filter or "")
                            for _, row in ipairs(rows) do
                                local values = {}
                                for _, col in ipairs(columns) do
                                    local value = row[col.field]
                                    if col.format then value = col.format(value, row) end
                                    values[#values + 1] = value or ""
                                end

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
                                    line.CharID = row.ID
                                    line.SteamID = row.SteamID
                                    line.Banned = row.Banned
                                end
                            end
                        end

                        search.OnChange = function() populate(search:GetValue()) end
                        populate("")
                        function list:OnRowRightClick(_, line)
                            if not IsValid(line) then return end
                            local menu = DermaMenu()
                            if steamIDColumnIndex then menu:AddOption(L("copySteamID"), function() SetClipboardText(line:GetColumnText(steamIDColumnIndex) or "") end):SetIcon("icon16/page_copy.png") end
                            menu:AddOption(L("copyRow"), function()
                                local rowString = ""
                                for i, column in ipairs(self.Columns or {}) do
                                    local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                                    local value = line:GetColumnText(i) or ""
                                    rowString = rowString .. header .. " " .. value .. " | "
                                end

                                SetClipboardText(string.sub(rowString, 1, -4))
                            end):SetIcon("icon16/page_copy.png")

                            if line.CharID then
                                local owner = line.SteamID and lia.util.getBySteamID(line.SteamID)
                                if IsValid(owner) then
                                    if line.Banned then
                                        if lia.command.hasAccess(LocalPlayer(), "charunban") then menu:AddOption(L("unbanCharacter"), function() LocalPlayer():ConCommand('say "/charunban ' .. line.CharID .. '"') end):SetIcon("icon16/accept.png") end
                                    else
                                        if lia.command.hasAccess(LocalPlayer(), "charban") then menu:AddOption(L("banCharacter"), function() LocalPlayer():ConCommand('say "/charban ' .. line.CharID .. '"') end):SetIcon("icon16/cancel.png") end
                                    end
                                else
                                    if not line.Banned and lia.command.hasAccess(LocalPlayer(), "charbanoffline") then menu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. line.CharID .. '"') end):SetIcon("icon16/cancel.png") end
                                    if line.Banned and lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then menu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. line.CharID .. '"') end):SetIcon("icon16/accept.png") end
                                end
                            end

                            menu:Open()
                        end
                    end

                    local allPanel = self.sheet:Add("DPanel")
                    allPanel:Dock(FILL)
                    allPanel.Paint = function() end
                    createList(allPanel, data.all or {})
                    self.sheet:AddSheet(L("allCharacters"), allPanel)
                    for steamID, chars in pairs(data.players or {}) do
                        local ply = lia.util.getBySteamID(tostring(steamID))
                        if IsValid(ply) then
                            local pnl = self.sheet:Add("DPanel")
                            pnl:Dock(FILL)
                            pnl.Paint = function() end
                            createList(pnl, chars)
                            self.sheet:AddSheet(ply:Nick(), pnl)
                        end
                    end
                end

                net.Start("liaRequestFullCharList")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("viewDBTables") then
        table.insert(pages, {
            name = L("databaseView"),
            icon = "icon16/database.png",
            drawFunc = function(panel)
                panelRef = panel
                panel:Clear()
                panel:DockPadding(10, 10, 10, 10)
                panel.Paint = function() end
                panel.sheet = panel:Add("DPropertySheet")
                panel.sheet:Dock(FILL)
                function panel:buildSheets(data)
                    for _, v in ipairs(self.sheet.Items or {}) do
                        if IsValid(v.Tab) then self.sheet:CloseTab(v.Tab, true) end
                    end

                    self.sheet.Items = {}
                    for tbl, rows in SortedPairs(data or {}) do
                        local pnl = self.sheet:Add("DPanel")
                        pnl:Dock(FILL)
                        pnl.Paint = function() end
                        local list = pnl:Add("DListView")
                        list:Dock(FILL)
                        local columns = {}
                        function list:OnRowRightClick(_, line)
                            if not IsValid(line) or not line.rowData then return end
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

                            menu:AddOption(L("viewEntry"), function() openRowInfo(line.rowData) end):SetIcon("icon16/table.png")
                            menu:AddOption(L("viewDecodedTable"), function() openDecodedTable(tbl, columns, rows) end):SetIcon("icon16/table_go.png")
                            menu:Open()
                        end

                        if rows and rows[1] then
                            for col in pairs(rows[1]) do
                                list:AddColumn(col)
                                columns[#columns + 1] = col
                            end

                            for _, row in ipairs(rows) do
                                local lineData = {}
                                for _, col in ipairs(columns) do
                                    lineData[#lineData + 1] = tostring(row[col])
                                end

                                local line = list:AddLine(unpack(lineData))
                                line.rowData = row
                            end
                        end

                        local sheetName = tbl:gsub("^lia_", "")
                        self.sheet:AddSheet(sheetName, pnl)
                    end
                end

                net.Start("liaRequestDatabaseView")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("canAccessFlagManagement") then
        table.insert(pages, {
            name = L("flagsManagement"),
            icon = "icon16/flag_red.png",
            drawFunc = function(panel)
                flagsPanel = panel
                if flagsData then
                    OpenFlagsPanel(panel, flagsData)
                    flagsData = nil
                else
                    net.Start("liaRequestAllFlags")
                    net.SendToServer()
                end
            end
        })
    end

    if client:hasPrivilege("canManageFactions") then
        table.insert(pages, {
            name = L("factionManagement"),
            icon = "icon16/chart_organisation.png",
            drawFunc = function(panel)
                rosterPanel = panel
                net.Start("liaRequestFactionRoster")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("manageCharacters") then
        net.Start("liaRequestPKsCount")
        net.SendToServer()
    end
end

local pksTabAdded = false
net.Receive("liaPKsCount", function()
    local count = net.ReadInt(32)
    if count > 0 and not pksTabAdded then
        pksTabAdded = true
        hook.Add("PopulateAdminTabs", "liaPKsTab", function(pages)
            local client = LocalPlayer()
            if not IsValid(client) or not client:hasPrivilege("manageCharacters") then return end
            table.insert(pages, {
                name = "pkManager",
                icon = "icon16/lightning.png",
                drawFunc = function(panel)
                    panelRef = panel
                    net.Start("liaRequestAllPKs")
                    net.SendToServer()
                end
            })
        end)
    end
end)