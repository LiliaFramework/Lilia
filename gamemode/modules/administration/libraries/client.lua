function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if not IsValid(client) or not IsValid(target) then return end
    if not (client:hasPrivilege("canAccessScoreboardInfoOutOfStaff") or client:hasPrivilege("canAccessScoreboardAdminOptions") and client:isStaffOnDuty()) then return end
    local orderedOptions = {
        {
            name = L("nameCopyFormat", target:Name()),
            image = "icon16/page_copy.png",
            func = function()
                client:notifySuccessLocalized("copiedToClipboard", target:Name(), L("name"))
                SetClipboardText(target:Name())
            end
        },
        {
            name = L("charIDCopyFormat", target:getChar() and target:getChar():getID() or L("na")),
            image = "icon16/page_copy.png",
            func = function()
                if target:getChar() then
                    client:notifySuccessLocalized("copiedCharID", target:getChar():getID())
                    SetClipboardText(target:getChar():getID())
                end
            end
        },
        {
            name = L("steamIDCopyFormat", target:SteamID()),
            image = "icon16/page_copy.png",
            func = function()
                client:notifySuccessLocalized("copiedToClipboard", target:Name(), L("steamID"))
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
                -- Force recreation of UI elements when tab is revisited
                panel:Clear()
                panel:DockPadding(6, 6, 6, 6)
                panel.Paint = function() end
                -- Remove existing sheet if it exists to force recreation
                if IsValid(panel.sheet) then panel.sheet:Remove() end
                panel.sheet = panel:Add("liaTabs")
                panel.sheet:Dock(FILL)
                function panel:buildSheets(data)
                    -- Force complete recreation of all UI elements
                    if IsValid(self.sheet) then self.sheet:Remove() end
                    self.sheet = self:Add("liaTabs")
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
                        local container = parent:Add("Panel")
                        container:Dock(FILL)
                        container:DockMargin(0, 20, 0, 0)
                        container.Paint = function() end
                        local search = container:Add("DTextEntry")
                        search:Dock(TOP)
                        search:DockMargin(0, 0, 0, 15)
                        search:SetTall(30)
                        search:SetPlaceholderText(L("search"))
                        search:SetTextColor(Color(200, 200, 200))
                        search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
                        local list = container:Add("liaTable")
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
                            local menu = lia.derma.dermaMenu()
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

                                    if lia.command.hasAccess(LocalPlayer(), "charwipe") then menu:AddOption(L("wipeCharacter"), function() LocalPlayer():ConCommand('say "/charwipe ' .. line.CharID .. '"') end):SetIcon("icon16/user_delete.png") end
                                else
                                    if not line.Banned and lia.command.hasAccess(LocalPlayer(), "charbanoffline") then menu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. line.CharID .. '"') end):SetIcon("icon16/cancel.png") end
                                    if lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then menu:AddOption(L("wipeCharacterOffline"), function() LocalPlayer():ConCommand('say "/charwipeoffline ' .. line.CharID .. '"') end):SetIcon("icon16/user_delete.png") end
                                    if line.Banned and lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then menu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. line.CharID .. '"') end):SetIcon("icon16/accept.png") end
                                end
                            end

                            menu:Open()
                        end
                    end

                    local allPanel = self.sheet:Add("Panel")
                    allPanel:Dock(FILL)
                    allPanel.Paint = function() end
                    createList(allPanel, data.all or {})
                    self.sheet:AddSheet(L("allCharacters"), allPanel)
                    for steamID, chars in pairs(data.players or {}) do
                        local ply = lia.util.getBySteamID(tostring(steamID))
                        local pnl = self.sheet:Add("Panel")
                        pnl:Dock(FILL)
                        pnl.Paint = function() end
                        createList(pnl, chars)
                        local tabName = IsValid(ply) and ply:Nick() or steamID
                        self.sheet:AddSheet(tabName, pnl)
                    end
                end

                -- Request fresh data every time the tab is accessed
                net.Start("liaRequestFullCharList")
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

    if client:hasPrivilege("manageCharacters") then
        net.Start("liaRequestPksCount")
        net.SendToServer()
    end
end

local pksTabAdded = false
net.Receive("liaPksCount", function()
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
                    net.Start("liaRequestAllPks")
                    net.SendToServer()
                end
            })
        end)
    end
end)
