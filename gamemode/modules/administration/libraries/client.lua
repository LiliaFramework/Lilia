local MODULE = MODULE
AdminStickIsOpen = false
local playerInfoLabel = L("player") .. " " .. L("information")
local subMenuIcons = {
    moderationTools = "icon16/wrench.png",
    warnings = "icon16/error.png",
    misc = "icon16/application_view_tile.png",
    [playerInfoLabel] = "icon16/information.png",
    characterManagement = "icon16/user_gray.png",
    flagManagement = "icon16/flag_blue.png",
    attributes = "icon16/chart_line.png",
    charFlagsTitle = "icon16/flag_green.png",
    giveFlagsLabel = "icon16/flag_blue.png",
    takeFlagsLabel = "icon16/flag_red.png",
    doorManagement = "icon16/door.png",
    doorActions = "icon16/arrow_switch.png",
    doorSettings = "icon16/cog.png",
    doorMaintenance = "icon16/wrench.png",
    doorInformation = "icon16/information.png",
    administration = "icon16/lock.png",
    items = "icon16/box.png",
    ooc = "icon16/comment.png",
    adminStickSubCategoryBans = "icon16/lock.png",
    adminStickSubCategoryGetInfos = "icon16/magnifier.png",
    adminStickSubCategorySetInfos = "icon16/pencil.png",
    setFactionTitle = "icon16/group.png",
    adminStickSetClassName = "icon16/user.png",
    adminStickFactionWhitelistName = "icon16/group_add.png",
    adminStickUnwhitelistName = "icon16/group_delete.png",
    adminStickClassWhitelistName = "icon16/user_add.png",
    adminStickClassUnwhitelistName = "icon16/user_delete.png",
    server = "icon16/cog.png",
    permissions = "icon16/key.png",
}

local function GetIdentifier(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return "" end
    if ent:IsBot() then return ent:Name() end
    return ent:SteamID()
end

local function QuoteArgs(...)
    local args = {}
    for _, v in ipairs({...}) do
        args[#args + 1] = string.format("'%s'", tostring(v))
    end
    return table.concat(args, " ")
end

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
            func = function() RunConsoleCommand("say", "!blind " .. GetIdentifier(target)) end
        },
        {
            name = L("freeze"),
            image = "icon16/lock.png",
            func = function() RunConsoleCommand("say", "!freeze " .. GetIdentifier(target)) end
        },
        {
            name = L("gag"),
            image = "icon16/sound_mute.png",
            func = function() RunConsoleCommand("say", "!gag " .. GetIdentifier(target)) end
        },
        {
            name = L("ignite"),
            image = "icon16/fire.png",
            func = function() RunConsoleCommand("say", "!ignite " .. GetIdentifier(target)) end
        },
        {
            name = L("jail"),
            image = "icon16/lock.png",
            func = function() RunConsoleCommand("say", "!jail " .. GetIdentifier(target)) end
        },
        {
            name = L("mute"),
            image = "icon16/sound_delete.png",
            func = function() RunConsoleCommand("say", "!mute " .. GetIdentifier(target)) end
        },
        {
            name = L("slay"),
            image = "icon16/bomb.png",
            func = function() RunConsoleCommand("say", "!slay " .. GetIdentifier(target)) end
        },
        {
            name = L("unblind"),
            image = "icon16/eye.png",
            func = function() RunConsoleCommand("say", "!unblind " .. GetIdentifier(target)) end
        },
        {
            name = L("ungag"),
            image = "icon16/sound_low.png",
            func = function() RunConsoleCommand("say", "!ungag " .. GetIdentifier(target)) end
        },
        {
            name = L("unfreeze"),
            image = "icon16/accept.png",
            func = function() RunConsoleCommand("say", "!unfreeze " .. GetIdentifier(target)) end
        },
        {
            name = L("unmute"),
            image = "icon16/sound_add.png",
            func = function() RunConsoleCommand("say", "!unmute " .. GetIdentifier(target)) end
        },
        {
            name = L("bring"),
            image = "icon16/arrow_down.png",
            func = function() RunConsoleCommand("say", "!bring " .. GetIdentifier(target)) end
        },
        {
            name = L("goTo"),
            image = "icon16/arrow_right.png",
            func = function() RunConsoleCommand("say", "!goto " .. GetIdentifier(target)) end
        },
        {
            name = L("respawn"),
            image = "icon16/arrow_refresh.png",
            func = function() RunConsoleCommand("say", "!respawn " .. GetIdentifier(target)) end
        },
        {
            name = L("returnText"),
            image = "icon16/arrow_redo.png",
            func = function() RunConsoleCommand("say", "!return " .. GetIdentifier(target)) end
        }
    }

    for _, v in ipairs(orderedOptions) do
        options[#options + 1] = v
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
        noDataLabel:SetFont("liaSmallFont")
        noDataLabel:SetTextColor(Color(150, 150, 150))
        noDataLabel:SetContentAlignment(5)
        noDataLabel:SetWrap(true)
        return
    end

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
        LocalPlayer():requestString(L("modifyCharFlags"), L("modifyFlagsDesc"), function(text)
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
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("noOptionsAvailable"), function() end)
        menu:Open()
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
                panel:Clear()
                panel:DockPadding(6, 6, 6, 6)
                panel.Paint = nil
                if IsValid(panel.sheet) then panel.sheet:Remove() end
                panel.sheet = panel:Add("liaTabs")
                panel.sheet:Dock(FILL)
                function panel:buildSheets(data)
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

                        list:AddMenuOption(L("copySteamID"), function(rowData) if steamIDColumnIndex then SetClipboardText(tostring(rowData[steamIDColumnIndex]) or "") end end, "icon16/page_copy.png")
                        list:AddMenuOption(L("copyRow"), function(rowData)
                            local rowString = ""
                            for i, column in ipairs(columns) do
                                local header = column.name or L("columnWithNumber", i)
                                local value = tostring(rowData[i] or "")
                                rowString = rowString .. header .. " " .. value .. " | "
                            end

                            SetClipboardText(string.sub(rowString, 1, -4))
                        end, "icon16/page_copy.png")

                        list:AddMenuOption(L("wipeCharacter"), function(rowData) if rowData.CharID then LocalPlayer():ConCommand('say "/charwipe ' .. rowData.CharID .. '"') end end, "icon16/user_delete.png")
                        list:AddMenuOption(L("wipeCharacterOffline"), function(rowData) if rowData.CharID then LocalPlayer():ConCommand('say "/charwipeoffline ' .. rowData.CharID .. '"') end end, "icon16/user_delete.png")
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

                net.Start("liaRequestFullCharList")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("manageFlags") then
        table.insert(pages, {
            name = L("flagsManagement"),
            icon = "icon16/flag_red.png",
            drawFunc = function(panel)
                panelRef = panel
                if not panel.flagsInitialized then
                    panel.flagsInitialized = true
                    if flagsData then
                        OpenFlagsPanel(panel, flagsData)
                        flagsData = nil
                    else
                        net.Start("liaRequestAllFlags")
                        net.SendToServer()
                    end
                end
            end
        })
    end

    if client:hasPrivilege("canSeeLogs") then
        table.insert(pages, {
            name = "logs",
            icon = "icon16/book_open.png",
            drawFunc = function(panel)
                if not panel.liaLogsPanel then
                    panel.liaLogsPanel = panel
                    liaLogsPanel = panel
                    panel:Clear()
                    panel:DockPadding(6, 6, 6, 6)
                    panel.Paint = nil
                    net.Start("liaSendLogsRequest")
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

spawnmenu.AddContentType("inventoryitem", function(container, data)
    local client = LocalPlayer()
    if not client:hasPrivilege("canUseItemSpawner") then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("inventoryitem")
    icon:SetSpawnName(data.id)
    icon:SetName(data.name)
    local itemData = lia.item.list[data.id]
    if itemData.icon then
        icon.Image:SetMaterial(itemData.icon)
    else
        local model = itemData.model or "default.mdl"
        local matName = string.Replace(model, ".mdl", "")
        icon.Image:SetMaterial(Material("spawnicons/" .. matName .. ".png"))
    end

    icon:SetColor(Color(205, 92, 92, 255))
    icon:SetTooltip(lia.darkrp.textWrap(itemData.desc or "", "DermaDefault", 560))
    icon.DoClick = function()
        net.Start("liaSpawnMenuSpawnItem")
        net.WriteString(data.id)
        net.SendToServer()
        lia.websound.playButtonSound("outlands-rp/ui/ui_return.wav")
    end

    icon.OpenMenu = function()
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copy"), function() SetClipboardText(icon:GetSpawnName()) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("giveToCharacter"), function()
            local popup = vgui.Create("liaFrame")
            popup:SetTitle(L("spawnItemTitle", data.id))
            popup:SetSize(600, 150)
            popup:Center()
            popup:MakePopup()
            popup:ShowCloseButton(true)
            local label = vgui.Create("DLabel", popup)
            label:Dock(TOP)
            label:SetText(L("giveTo") .. ":")
            local combo = vgui.Create("liaComboBox", popup)
            combo:Dock(TOP)
            combo:PostInit()
            for _, character in pairs(lia.char.getAll()) do
                local ply = character:getPlayer()
                if IsValid(ply) then
                    local steamID = ply:SteamID() or ""
                    combo:AddChoice(L("characterSteamIDFormat", character:getName() or L("unknown"), steamID), steamID)
                end
            end

            local button = vgui.Create("liaSmallButton", popup)
            button:Dock(BOTTOM)
            button:SetText(L("spawnItem"))
            button.DoClick = function()
                local target = combo:GetSelectedData()
                net.Start("liaSpawnMenuGiveItem")
                net.WriteString(data.id)
                net.WriteString(target or "")
                net.SendToServer()
                popup:Remove()
            end
        end)

        menu:Open()
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
            name = itemData.name
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
        local name = tostring(itemData.name or "")
        local desc = tostring(itemData.desc or "")
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
    if not IsValid(client) or not client.hasPrivilege or not client:hasPrivilege("canUseItemSpawner") then
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

local function GetIconForCategory(name)
    if subMenuIcons[name] then return subMenuIcons[name] end
    if subMenuIcons[L(name)] then return subMenuIcons[L(name)] end
    local baseKey = name:match("^([^%(]+)") or name
    baseKey = baseKey:gsub("^%s*(.-)%s*$", "%1")
    if subMenuIcons[baseKey] then return subMenuIcons[baseKey] end
    local nameLower = name:lower()
    local localizedName = L(name):lower()
    local iconMappings = {
        ["moderation"] = "icon16/shield.png",
        ["admin"] = "icon16/shield.png",
        ["security"] = "icon16/shield.png",
        ["character"] = "icon16/user_gray.png",
        ["player"] = "icon16/user_gray.png",
        ["user"] = "icon16/user_gray.png",
        ["person"] = "icon16/user_gray.png",
        ["door"] = "icon16/door.png",
        ["building"] = "icon16/door.png",
        ["property"] = "icon16/door.png",
        ["house"] = "icon16/door.png",
        ["information"] = "icon16/information.png",
        ["info"] = "icon16/information.png",
        ["data"] = "icon16/information.png",
        ["knowledge"] = "icon16/information.png",
        ["details"] = "icon16/information.png",
        ["teleport"] = "icon16/arrow_right.png",
        ["move"] = "icon16/arrow_right.png",
        ["travel"] = "icon16/arrow_right.png",
        ["transport"] = "icon16/arrow_right.png",
        ["utility"] = "icon16/application_view_tile.png",
        ["tool"] = "icon16/application_view_tile.png",
        ["misc"] = "icon16/application_view_tile.png",
        ["miscellaneous"] = "icon16/application_view_tile.png",
        ["other"] = "icon16/application_view_tile.png",
        ["flag"] = "icon16/flag_green.png",
        ["permission"] = "icon16/flag_green.png",
        ["access"] = "icon16/flag_green.png",
        ["privilege"] = "icon16/flag_green.png",
        ["item"] = "icon16/box.png",
        ["inventory"] = "icon16/box.png",
        ["container"] = "icon16/box.png",
        ["storage"] = "icon16/box.png",
        ["ooc"] = "icon16/comment.png",
        ["chat"] = "icon16/comment.png",
        ["message"] = "icon16/comment.png",
        ["talk"] = "icon16/comment.png",
        ["communication"] = "icon16/comment.png",
        ["warning"] = "icon16/error.png",
        ["alert"] = "icon16/error.png",
        ["error"] = "icon16/error.png",
        ["caution"] = "icon16/error.png",
        ["command"] = "icon16/page.png",
        ["control"] = "icon16/page.png",
        ["manage"] = "icon16/page.png",
        ["setting"] = "icon16/page.png",
        ["attribute"] = "icon16/chart_line.png",
        ["stat"] = "icon16/chart_line.png",
        ["skill"] = "icon16/chart_line.png",
        ["level"] = "icon16/chart_line.png",
        ["faction"] = "icon16/group.png",
        ["guild"] = "icon16/group.png",
        ["team"] = "icon16/group.png",
        ["organization"] = "icon16/group.png",
        ["class"] = "icon16/user.png",
        ["role"] = "icon16/user.png",
        ["job"] = "icon16/user.png",
        ["profession"] = "icon16/user.png",
        ["whitelist"] = "icon16/group_add.png",
        ["approve"] = "icon16/group_add.png",
        ["accept"] = "icon16/group_add.png",
        ["allow"] = "icon16/group_add.png",
        ["ban"] = "icon16/lock.png",
        ["block"] = "icon16/lock.png",
        ["restrict"] = "icon16/lock.png",
        ["deny"] = "icon16/lock.png",
    }

    for keyword, icon in pairs(iconMappings) do
        if nameLower:find(keyword) or localizedName:find(keyword) then return icon end
    end

    local localizedExactMatches = {
        [L("adminStickCategoryModeration"):lower()] = "icon16/shield.png",
        [L("adminStickCategoryCharacterManagement"):lower()] = "icon16/user_gray.png",
        [L("adminStickCategoryDoorManagement"):lower()] = "icon16/door.png",
        [L("adminStickCategoryPlayerInformation"):lower()] = "icon16/information.png",
        [L("adminStickCategoryTeleportation"):lower()] = "icon16/arrow_right.png",
        [L("adminStickCategoryUtility"):lower()] = "icon16/application_view_tile.png",
        [L("adminStickCategoryMiscellaneous"):lower()] = "icon16/application_view_tile.png",
        [L("adminStickCategoryItems"):lower()] = "icon16/box.png",
        [L("adminStickCategoryOutOfCharacter"):lower()] = "icon16/comment.png",
        [L("adminStickCategoryWarnings"):lower()] = "icon16/error.png",
    }

    if localizedExactMatches[localizedName] then return localizedExactMatches[localizedName] end
    if nameLower:find("management") or nameLower:find("admin") then return "icon16/cog.png" end
    if nameLower:find("stat") or nameLower:find("number") or nameLower:find("count") then return "icon16/chart_bar.png" end
    if nameLower:find("set") or nameLower:find("config") then return "icon16/cog.png" end
    if nameLower:find("get") or nameLower:find("view") or nameLower:find("show") then return "icon16/information.png" end
    if nameLower:find("list") or nameLower:find("all") then
        return "icon16/table.png"
    elseif nameLower:find("create") or nameLower:find("new") or nameLower:find("add") then
        return "icon16/add.png"
    elseif nameLower:find("delete") or nameLower:find("remove") then
        return "icon16/delete.png"
    elseif nameLower:find("edit") or nameLower:find("modify") then
        return "icon16/pencil.png"
    else
        return "icon16/page.png"
    end
end

local function GenerateDynamicCategories()
    local categories = {}
    local categoryNames = {}
    local adminStickCount = 0
    for _, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) then
            adminStickCount = adminStickCount + 1
            local category = v.AdminStick.Category
            local subcategory = v.AdminStick.SubCategory
            if category == "adminsticksubcategorycharacterflags" then
                category = "characterManagement"
                if not subcategory then subcategory = "adminsticksubcategorycharacterflags" end
            end

            if category then
                if not categories[category] then
                    categories[category] = {
                        name = category,
                        icon = GetIconForCategory(category),
                        subcategories = {}
                    }

                    table.insert(categoryNames, category)
                end

                if subcategory then
                    if not categories[category].subcategories[subcategory] then
                        categories[category].subcategories[subcategory] = {
                            name = subcategory,
                            icon = GetIconForCategory(subcategory)
                        }
                    end
                end
            end
        end
    end

    local mergedCategories = {}
    local mergedCategoryNames = {}
    for _, categoryKey in ipairs(categoryNames) do
        local category = categories[categoryKey]
        local displayName = L(category.name)
        local existingKey = nil
        for existingKeyCheck, existingCategory in pairs(mergedCategories) do
            if L(existingCategory.name) == displayName then
                existingKey = existingKeyCheck
                break
            end
        end

        if existingKey then
            for subKey, subCategory in pairs(category.subcategories) do
                if not mergedCategories[existingKey].subcategories[subKey] then mergedCategories[existingKey].subcategories[subKey] = subCategory end
            end
        else
            mergedCategories[categoryKey] = category
            table.insert(mergedCategoryNames, categoryKey)
        end
    end

    for _, category in pairs(mergedCategories) do
        local localizedName = L(category.name)
        if localizedName ~= category.name then
            category.name = localizedName
        else
            local formattedName = category.name
            if formattedName:lower() == "flagmanagement" then
                formattedName = "Flag Management"
            elseif formattedName:lower() == "doormanagement" then
                formattedName = "Door Management"
            elseif formattedName:lower() == "charactermanagement" then
                formattedName = "Character Management"
            elseif formattedName:lower() == "playerinformation" then
                formattedName = "Player Information"
            elseif formattedName:lower() == "adminsticksubcategorybans" then
                formattedName = "Bans"
            elseif formattedName:lower() == "adminsticksubcategorysetinfos" then
                formattedName = "Set Information"
            elseif formattedName:lower() == "adminsticksubcategorygetinfos" then
                formattedName = "Get Information"
            elseif formattedName:lower() == "adminsticksubcategorycharacterflags" then
                formattedName = "Character Flags"
            else
                formattedName = formattedName:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end)
                formattedName = formattedName:gsub("_", " ")
            end

            category.name = formattedName
        end

        for _, subCategory in pairs(category.subcategories) do
            local localizedSubName = L(subCategory.name)
            if localizedSubName ~= subCategory.name then
                subCategory.name = localizedSubName
            else
                local formattedSubName = subCategory.name
                if formattedSubName:lower() == "adminsticksubcategorybans" then
                    formattedSubName = "Bans"
                elseif formattedSubName:lower() == "adminsticksubcategorysetinfos" then
                    formattedSubName = "Set Information"
                elseif formattedSubName:lower() == "adminsticksubcategorygetinfos" then
                    formattedSubName = "Get Information"
                elseif formattedSubName:lower() == "adminsticksubcategorycharacterflags" then
                    formattedSubName = "Flags"
                elseif formattedSubName:lower() == "moderationtools" then
                    formattedSubName = "Moderation Tools"
                elseif formattedSubName:lower() == "doorinformation" then
                    formattedSubName = "Door Information"
                else
                    formattedSubName = formattedSubName:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end)
                    formattedSubName = formattedSubName:gsub("_", " ")
                end

                subCategory.name = formattedSubName
            end
        end
    end

    local preferredOrder = {"playerInformation", "moderation", "characterManagement", "doorManagement", "teleportation", "utility"}
    local orderedCategories = {}
    for _, preferredCategory in ipairs(preferredOrder) do
        if mergedCategories[preferredCategory] then table.insert(orderedCategories, preferredCategory) end
    end

    for _, categoryName in ipairs(mergedCategoryNames) do
        if not table.HasValue(orderedCategories, categoryName) then table.insert(orderedCategories, categoryName) end
    end

    local hardcodedCategories = {
        doorManagement = {
            name = L("adminStickCategoryDoorManagement") or "Door Management",
            icon = "icon16/door.png",
            subcategories = {
                doorActions = {
                    name = L("adminStickSubCategoryDoorActions") or L("actions"),
                    icon = "icon16/lightning.png"
                },
                doorSettings = {
                    name = L("adminStickSubCategoryDoorSettings") or "Settings",
                    icon = "icon16/cog.png"
                },
                doorMaintenance = {
                    name = L("adminStickSubCategoryDoorMaintenance") or "Maintenance",
                    icon = "icon16/wrench.png"
                },
                doorInformation = {
                    name = L("adminStickSubCategoryDoorInformation") or "Information",
                    icon = "icon16/information.png"
                }
            }
        },
        playerInformation = {
            name = L("adminStickCategoryPlayerInformation") or "Player Information",
            icon = "icon16/user.png",
            subcategories = {}
        },
        teleportation = {
            name = L("adminStickCategoryTeleportation") or "Teleportation",
            icon = "icon16/world.png",
            subcategories = {}
        }
    }

    if mergedCategories.characterManagement then
        mergedCategories.characterManagement.subcategories = mergedCategories.characterManagement.subcategories or {}
        mergedCategories.characterManagement.subcategories.factions = {
            name = L("adminStickSubCategoryFactions") or "Factions",
            icon = "icon16/group.png"
        }

        mergedCategories.characterManagement.subcategories.classes = {
            name = L("adminStickSubCategoryClasses") or "Classes",
            icon = "icon16/group_edit.png"
        }

        mergedCategories.characterManagement.subcategories.whitelists = {
            name = L("adminStickSubCategoryWhitelists") or "Whitelists",
            icon = "icon16/group_key.png"
        }

        mergedCategories.characterManagement.subcategories.flags = {
            name = L("adminStickSubCategoryFlags") or "Flags",
            icon = "icon16/flag_red.png"
        }
    end

    if mergedCategories.utility then
        mergedCategories.utility.subcategories = mergedCategories.utility.subcategories or {}
        mergedCategories.utility.subcategories.commands = {
            name = L("adminStickSubCategoryCommands") or "Commands",
            icon = "icon16/script.png"
        }
    end

    for key, data in pairs(hardcodedCategories) do
        if not mergedCategories[key] then
            mergedCategories[key] = data
            if not table.HasValue(orderedCategories, key) then table.insert(orderedCategories, key) end
        end
    end
    return mergedCategories, orderedCategories
end

MODULE.adminStickCategories = MODULE.adminStickCategories or {}
MODULE.adminStickCategoryOrder = MODULE.adminStickCategoryOrder or {}
function MODULE:InitializedModules()
    local categories, categoryOrder = GenerateDynamicCategories()
    self.adminStickCategories = categories
    self.adminStickCategoryOrder = categoryOrder
end

function MODULE:AddAdminStickCategory(key, data, index)
    self.adminStickCategories = self.adminStickCategories or {}
    self.adminStickCategories[key] = data
    self.adminStickCategoryOrder = self.adminStickCategoryOrder or {}
    if index then
        table.insert(self.adminStickCategoryOrder, index, key)
    else
        table.insert(self.adminStickCategoryOrder, key)
    end
end

function MODULE:AddAdminStickSubCategory(catKey, subKey, data)
    self.adminStickCategories = self.adminStickCategories or {}
    local category = self.adminStickCategories[catKey]
    if not category then return end
    category.subcategories = category.subcategories or {}
    category.subcategories[subKey] = data
end

local function GetSubMenuIcon(name)
    if subMenuIcons[name] then return subMenuIcons[name] end
    local baseKey = name:match("^([^%(]+)") or name
    baseKey = baseKey:gsub("^%s*(.-)%s*$", "%1")
    if subMenuIcons[baseKey] then return subMenuIcons[baseKey] end
    if subMenuIcons[L(name)] then return subMenuIcons[L(name)] end
    local setFactionLocalized = L("setFactionTitle", ""):match("^([^%(]+)") or L("setFactionTitle", "")
    setFactionLocalized = setFactionLocalized:gsub("^%s*(.-)%s*$", "%1")
    if name:find(setFactionLocalized, 1, true) == 1 then return subMenuIcons["setFactionTitle"] end
    if name:find(L("adminStickSetFaction"), 1, true) == 1 then return subMenuIcons["setFactionTitle"] end
    if name:lower() == "misc" or name:lower() == "miscellaneous" or name:lower() == L("adminStickCategoryMiscellaneous"):lower() then return "icon16/application_view_tile.png" end
    if name:lower() == "items" or name:lower() == L("adminStickCategoryItems"):lower() then return "icon16/box.png" end
    if name:lower() == "ooc" or name:lower():find("out of character") or name:lower() == L("adminStickCategoryOutOfCharacter"):lower() then return "icon16/comment.png" end
    if name:lower() == "warnings" or name:lower() == L("adminStickCategoryWarnings"):lower() then return "icon16/error.png" end
    if name:lower() == "commands" then return "icon16/page.png" end
    return "icon16/page.png"
end

local function GetOrCreateSubMenu(parent, name, store, category, subcategory)
    if not parent or not IsValid(parent) then return end
    local fullName = name
    if category and subcategory then
        fullName = category .. "_" .. subcategory .. "_" .. name
    elseif category then
        fullName = category .. "_" .. name
    end

    if not store[fullName] then
        local menu, panel = parent:AddSubMenu(L(name))
        local icon = GetSubMenuIcon(name)
        if icon and panel then panel:SetIcon(icon) end
        if IsValid(menu) then
            store[fullName] = menu
        else
            return parent
        end
    end
    return store[fullName] or parent
end

local function GetOrCreateCategoryMenu(parent, categoryKey, store)
    if not parent or not IsValid(parent) then return end
    local category = MODULE.adminStickCategories[categoryKey]
    if not category then return parent end
    if not store[categoryKey] then
        local menu, option = parent:AddSubMenu(category.name, function() end)
        if category.icon and option then option:SetIcon(category.icon) end
        if IsValid(menu) then
            store[categoryKey] = menu
        else
            return parent
        end
    end
    return store[categoryKey] or parent
end

local function GetOrCreateSubCategoryMenu(parent, categoryKey, subcategoryKey, store)
    if not parent or not IsValid(parent) then return end
    local category = MODULE.adminStickCategories[categoryKey]
    if not category or not category.subcategories or not category.subcategories[subcategoryKey] then return parent end
    local subcategory = category.subcategories[subcategoryKey]
    local fullKey = categoryKey .. "_" .. subcategoryKey
    if not store[fullKey] then
        local menu, option = parent:AddSubMenu(subcategory.name, function() end)
        if subcategory.icon and option then option:SetIcon(subcategory.icon) end
        if IsValid(menu) then
            store[fullKey] = menu
        else
            return parent
        end
    end
    return store[fullKey] or parent
end

local function CreateOrganizedAdminStickMenu(tgt, stores)
    local menu = lia.derma.dermaMenu()
    if not IsValid(menu) then return end
    local cl = LocalPlayer()
    local categories, categoryOrder
    if not MODULE.adminStickCategories or table.Count(MODULE.adminStickCategories) == 0 then
        categories, categoryOrder = GenerateDynamicCategories()
        MODULE.adminStickCategories = categories
        MODULE.adminStickCategoryOrder = categoryOrder
    else
        categories = MODULE.adminStickCategories
        categoryOrder = MODULE.adminStickCategoryOrder
    end

    for _, categoryKey in ipairs(categoryOrder) do
        local category = categories[categoryKey]
        if category then
            local hasContent
            if categoryKey == "playerInformation" and tgt:IsPlayer() then
                hasContent = true
            elseif categoryKey == "moderation" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "characterManagement" and tgt:IsPlayer() and (cl:hasPrivilege("manageTransfers") or cl:hasPrivilege("manageClasses") or cl:hasPrivilege("manageWhitelists") or cl:hasPrivilege("manageCharacterInformation") or cl:hasPrivilege("manageFlags")) then
                hasContent = true
            elseif categoryKey == "flagManagement" and tgt:IsPlayer() and cl:hasPrivilege("manageFlags") then
                hasContent = true
            elseif categoryKey == "doorManagement" and tgt:isDoor() then
                hasContent = true
            elseif categoryKey == "teleportation" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "utility" and tgt:IsPlayer() then
                hasContent = true
            else
                hasContent = false
            end

            if hasContent then GetOrCreateCategoryMenu(menu, categoryKey, stores) end
        end
    end

    if menu.UpdateSize then menu:UpdateSize() end
    return menu
end

local function RunAdminCommand(cmd, tgt, dur, reason)
    local cl = LocalPlayer()
    local victim = IsValid(tgt) and tgt:IsPlayer() and (tgt:IsBot() and tgt:Name() or tgt:SteamID()) or tgt
    hook.Run("RunAdminSystemCommand", cmd, cl, victim, dur, reason)
end

local function OpenPlayerModelUI(tgt)
    AdminStickIsOpen = true
    local fr = vgui.Create("liaFrame")
    fr:SetTitle(L("changePlayerModel"))
    fr:SetSize(450, 300)
    fr:Center()
    function fr:OnClose()
        fr:Remove()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    local sc = vgui.Create("liaScrollPanel", fr)
    sc:Dock(FILL)
    local wr = vgui.Create("DIconLayout", sc)
    wr:Dock(FILL)
    local ed = vgui.Create("liaEntry", fr)
    ed:Dock(BOTTOM)
    ed:SetText(tgt:GetModel())
    local bt = vgui.Create("liaButton", fr)
    bt:SetText(L("change"))
    bt:Dock(TOP)
    function bt:DoClick()
        local txt = ed:GetValue()
        local id = GetIdentifier(tgt)
        if id ~= "" then RunConsoleCommand("say", "/charsetmodel " .. QuoteArgs(id, txt)) end
        fr:Remove()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    local modList = {}
    for n, m in SortedPairs(player_manager.AllValidModels()) do
        table.insert(modList, {
            name = n,
            mdl = m
        })
    end

    table.sort(modList, function(a, b) return a.name < b.name end)
    for _, md in ipairs(modList) do
        local ic = wr:Add("SpawnIcon")
        ic:SetModel(md.mdl)
        ic:SetSize(64, 64)
        ic:SetTooltip(md.name)
        ic.model_path = md.mdl
        ic.DoClick = function() ed:SetValue(ic.model_path) end
    end

    fr:MakePopup()
end

local function OpenReasonUI(tgt, cmd)
    AdminStickIsOpen = true
    local argTypes = {}
    local defaults = {}
    argTypes[L("reason")] = "string"
    defaults[L("reason")] = ""
    if cmd == "banid" then
        argTypes[L("lengthInDays")] = "number"
        defaults[L("lengthInDays")] = 0
    end

    lia.derma.requestArguments(L("reasonFor", cmd), argTypes, function(success, data)
        if not success or not data then
            AdminStickIsOpen = false
            LocalPlayer().AdminStickTarget = nil
            return
        end

        local txt = data[L("reason")] or ""
        local id = GetIdentifier(tgt)
        if cmd == "banid" then
            if id ~= "" then
                local duration = tonumber(data[L("lengthInDays")]) or 0
                local len = duration * 60 * 24
                RunAdminCommand("ban", tgt, len, txt)
            end
        elseif cmd == "kick" then
            if id ~= "" then RunAdminCommand("kick", tgt, nil, txt) end
        end

        AdminStickIsOpen = false
        LocalPlayer().AdminStickTarget = nil
    end, defaults)
end

local function HandleModerationOption(opt, tgt)
    if opt.name == L("ban") then
        OpenReasonUI(tgt, "banid")
    elseif opt.name == L("kick") then
        OpenReasonUI(tgt, "kick")
    else
        RunAdminCommand(opt.cmd, tgt)
    end

    timer.Simple(0.1, function()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end)
end

local function IncludeAdminMenu(tgt, menu, stores)
    local cl = LocalPlayer()
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local modCategory = GetOrCreateCategoryMenu(menu, "moderation", stores)
    if not modCategory then return end
    local modSubCategory = GetOrCreateSubCategoryMenu(modCategory, "moderation", "moderationTools", stores)
    if not modSubCategory then return end
    local mods = {
        {
            action = {
                name = L("blind"),
                cmd = "blind",
                icon = "icon16/eye.png"
            },
            inverse = {
                name = L("unblind"),
                cmd = "unblind",
                icon = "icon16/eye.png"
            }
        },
        {
            action = {
                name = L("freeze"),
                cmd = "freeze",
                icon = "icon16/lock.png"
            },
            inverse = {
                name = L("unfreeze"),
                cmd = "unfreeze",
                icon = "icon16/accept.png"
            }
        },
        {
            action = {
                name = L("gag"),
                cmd = "gag",
                icon = "icon16/sound_mute.png"
            },
            inverse = {
                name = L("ungag"),
                cmd = "ungag",
                icon = "icon16/sound_low.png"
            }
        },
        {
            action = {
                name = L("mute"),
                cmd = "mute",
                icon = "icon16/sound_delete.png"
            },
            inverse = {
                name = L("unmute"),
                cmd = "unmute",
                icon = "icon16/sound_add.png"
            }
        },
        {
            name = L("ignite"),
            cmd = "ignite",
            icon = "icon16/fire.png"
        },
        {
            name = L("jail"),
            cmd = "jail",
            icon = "icon16/lock.png"
        },
        {
            name = L("slay"),
            cmd = "slay",
            icon = "icon16/bomb.png"
        }
    }

    table.sort(mods, function(a, b)
        local na = a.action and a.action.name or a.name
        local nb = b.action and b.action.name or b.name
        return na < nb
    end)

    for _, p in ipairs(mods) do
        if p.action then
            modSubCategory:AddOption(L(p.action.name), function() HandleModerationOption(p.action, tgt) end):SetIcon(p.action.icon)
            if p.inverse then modSubCategory:AddOption(L(p.inverse.name), function() HandleModerationOption(p.inverse, tgt) end):SetIcon(p.inverse.icon) end
        else
            modSubCategory:AddOption(L(p.name), function() HandleModerationOption(p, tgt) end):SetIcon(p.icon)
        end
    end

    if modSubCategory.UpdateSize then modSubCategory:UpdateSize() end
end

local function IncludeTeleportation(tgt, menu, stores)
    local cl = LocalPlayer()
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local tpCategory = GetOrCreateCategoryMenu(menu, "teleportation", stores)
    local tp = {
        {
            name = L("bring"),
            cmd = "bring",
            icon = "icon16/arrow_down.png"
        },
        {
            name = L("goTo"),
            cmd = "goto",
            icon = "icon16/arrow_right.png"
        },
        {
            name = L("returnText"),
            cmd = "return",
            icon = "icon16/arrow_redo.png"
        },
        {
            name = L("respawn"),
            cmd = "respawn",
            icon = "icon16/arrow_refresh.png"
        }
    }

    table.sort(tp, function(a, b) return a.name < b.name end)
    for _, o in ipairs(tp) do
        tpCategory:AddOption(L(o.name), function()
            RunAdminCommand(o.cmd, tgt)
            timer.Simple(0.1, function()
                LocalPlayer().AdminStickTarget = nil
                AdminStickIsOpen = false
            end)
        end):SetIcon(o.icon)
    end

    if tpCategory.UpdateSize then tpCategory:UpdateSize() end
end

local function IncludeUtility(tgt, menu, stores)
    local utilityCategory = GetOrCreateCategoryMenu(menu, "utility", stores)
    if not utilityCategory then return end
    local commandsSubCategory = GetOrCreateSubCategoryMenu(utilityCategory, "utility", "commands", stores)
    if not commandsSubCategory then return end
    local utilityCommands = {
        {
            name = L("noclip"),
            cmd = "noclip",
            icon = "icon16/shape_square.png"
        },
        {
            name = L("godmode"),
            cmd = "godmode",
            icon = "icon16/shield.png"
        },
        {
            name = L("spectate"),
            cmd = "spectate",
            icon = "icon16/eye.png"
        }
    }

    for _, cmd in ipairs(utilityCommands) do
        commandsSubCategory:AddOption(L(cmd.name), function()
            RunAdminCommand(cmd.cmd, tgt)
            timer.Simple(0.1, function()
                LocalPlayer().AdminStickTarget = nil
                AdminStickIsOpen = false
            end)
        end):SetIcon(cmd.icon)
    end

    if commandsSubCategory.UpdateSize then commandsSubCategory:UpdateSize() end
end

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local canFaction = cl:hasPrivilege("manageTransfers")
    local canClass = cl:hasPrivilege("manageClasses")
    local canWhitelist = cl:hasPrivilege("manageWhitelists")
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
    if not charCategory then return end
    local char = tgt:getChar()
    if char then
        local facID = char:getFaction()
        if facID then
            if canFaction then
                local facOptions = {}
                for _, f in pairs(lia.faction.teams) do
                    if f.index == facID then
                        for _, v in pairs(lia.faction.teams) do
                            table.insert(facOptions, {
                                name = v.name,
                                cmd = 'say /plytransfer ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        end

                        break
                    end
                end

                table.sort(facOptions, function(a, b) return a.name < b.name end)
                if #facOptions > 0 then
                    local factionsSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "factions", stores)
                    if factionsSubCategory and IsValid(factionsSubCategory) then
                        for _, o in ipairs(facOptions) do
                            factionsSubCategory:AddOption(L(o.name), function()
                                cl:ConCommand(o.cmd)
                                timer.Simple(0.1, function() AdminStickIsOpen = false end)
                            end):SetIcon("icon16/group.png")
                        end

                        if factionsSubCategory.UpdateSize then factionsSubCategory:UpdateSize() end
                    end
                end
            end

            local classes = lia.faction.getClasses and lia.faction.getClasses(facID) or {}
            if classes and #classes > 1 and canClass then
                local cls = {}
                for _, c in ipairs(classes) do
                    table.insert(cls, {
                        name = c.name,
                        cmd = 'say /setclass ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                    })
                end

                table.sort(cls, function(a, b) return a.name < b.name end)
                local classesSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "classes", stores)
                if classesSubCategory and IsValid(classesSubCategory) then
                    for _, o in ipairs(cls) do
                        classesSubCategory:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            timer.Simple(0.1, function()
                                LocalPlayer().AdminStickTarget = nil
                                AdminStickIsOpen = false
                            end)
                        end):SetIcon("icon16/user.png")
                    end

                    if classesSubCategory.UpdateSize then classesSubCategory:UpdateSize() end
                end
            end

            if canWhitelist then
                local facAdd, facRemove = {}, {}
                for _, v in pairs(lia.faction.teams) do
                    if not v.isDefault then
                        if not tgt:hasWhitelist(v.index) then
                            table.insert(facAdd, {
                                name = v.name,
                                cmd = 'say /plywhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        else
                            table.insert(facRemove, {
                                name = v.name,
                                cmd = 'say /plyunwhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        end
                    end
                end

                table.sort(facAdd, function(a, b) return a.name < b.name end)
                table.sort(facRemove, function(a, b) return a.name < b.name end)
                local whitelistsSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "whitelists", stores)
                if whitelistsSubCategory and IsValid(whitelistsSubCategory) then
                    for _, o in ipairs(facAdd) do
                        whitelistsSubCategory:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            timer.Simple(0.1, function()
                                LocalPlayer().AdminStickTarget = nil
                                AdminStickIsOpen = false
                            end)
                        end):SetIcon("icon16/group_add.png")
                    end

                    for _, o in ipairs(facRemove) do
                        whitelistsSubCategory:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            timer.Simple(0.1, function()
                                LocalPlayer().AdminStickTarget = nil
                                AdminStickIsOpen = false
                            end)
                        end):SetIcon("icon16/group_delete.png")
                    end

                    if whitelistsSubCategory.UpdateSize then whitelistsSubCategory:UpdateSize() end
                end

                if classes and #classes > 0 then
                    local cw, cu = {}, {}
                    for _, c in ipairs(classes) do
                        if not tgt:getChar():getClasswhitelists()[c.index] then
                            table.insert(cw, {
                                name = c.name,
                                cmd = 'say /classwhitelist ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                            })
                        else
                            table.insert(cu, {
                                name = c.name,
                                cmd = 'say /classunwhitelist ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                            })
                        end
                    end

                    table.sort(cw, function(a, b) return a.name < b.name end)
                    table.sort(cu, function(a, b) return a.name < b.name end)
                    if whitelistsSubCategory and IsValid(whitelistsSubCategory) then
                        for _, o in ipairs(cw) do
                            whitelistsSubCategory:AddOption(L(o.name), function()
                                cl:ConCommand(o.cmd)
                                timer.Simple(0.1, function() AdminStickIsOpen = false end)
                            end):SetIcon("icon16/user_add.png")
                        end

                        for _, o in ipairs(cu) do
                            whitelistsSubCategory:AddOption(L(o.name), function()
                                cl:ConCommand(o.cmd)
                                timer.Simple(0.1, function() AdminStickIsOpen = false end)
                            end):SetIcon("icon16/user_delete.png")
                        end

                        if whitelistsSubCategory.UpdateSize then whitelistsSubCategory:UpdateSize() end
                    end
                end
            end
        end
    end

    if cl:hasPrivilege("manageCharacterInformation") then
        local attributesSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "attributes", stores)
        attributesSubCategory:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/user_suit.png")

        if attributesSubCategory.UpdateSize then attributesSubCategory:UpdateSize() end
    end
end

local function IncludeFlagManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    if not cl:hasPrivilege("manageFlags") then return end
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
    if not charCategory then return end
    local cf = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "flags", stores)
    if not cf then return end
    local charObj = tgt:getChar()
    local toGive, toTake = {}, {}
    for fl in pairs(lia.flag.list) do
        if not charObj or not charObj:hasFlags(fl) then
            table.insert(toGive, {
                name = L("giveFlagFormat", fl),
                cmd = 'say /giveflag ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_blue.png"
            })
        else
            table.insert(toTake, {
                name = L("takeFlagFormat", fl),
                cmd = 'say /takeflag ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_red.png"
            })
        end
    end

    table.sort(toGive, function(a, b) return a.name < b.name end)
    table.sort(toTake, function(a, b) return a.name < b.name end)
    if cf and IsValid(cf) then
        for _, f in ipairs(toGive) do
            cf:AddOption(L(f.name), function()
                cl:ConCommand(f.cmd)
                timer.Simple(0.1, function() AdminStickIsOpen = false end)
            end):SetIcon(f.icon)
        end

        for _, f in ipairs(toTake) do
            cf:AddOption(L(f.name), function()
                cl:ConCommand(f.cmd)
                timer.Simple(0.1, function() AdminStickIsOpen = false end)
            end):SetIcon(f.icon)
        end
    end

    if cf and IsValid(cf) then
        cf:AddOption(L("modifyCharFlags"), function()
            local currentFlags = charObj and charObj:getFlags() or ""
            tgt:requestString(L("modifyCharFlags"), L("modifyFlagsDesc"), function(text)
                text = string.gsub(text or "", "%s", "")
                net.Start("liaModifyFlags")
                net.WriteString(tgt:SteamID())
                net.WriteString(text)
                net.WriteBool(false)
                net.SendToServer()
            end, currentFlags)

            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_orange.png")

        cf:AddOption(L("giveAllCharFlags"), function()
            local allFlags = ""
            for fl in pairs(lia.flag.list) do
                allFlags = allFlags .. fl
            end

            if allFlags ~= "" then
                net.Start("liaModifyFlags")
                net.WriteString(tgt:SteamID())
                net.WriteString(allFlags)
                net.WriteBool(false)
                net.SendToServer()
            end

            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_blue.png")

        cf:AddOption(L("takeAllCharFlags"), function()
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString("")
            net.WriteBool(false)
            net.SendToServer()
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_red.png")

        cf:AddOption(L("listCharFlags"), function()
            local currentFlags = charObj and charObj:getFlags() or ""
            local flagList = ""
            if currentFlags ~= "" then
                for i = 1, #currentFlags do
                    local flag = currentFlags:sub(i, i)
                    flagList = flagList .. flag .. " "
                end

                flagList = string.Trim(flagList)
            end

            Derma_Message(L("currentCharFlags") .. ": " .. (flagList ~= "" and flagList or L("none")), L("charFlagsTitle"), L("ok"))
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/information.png")
    end
end

local function AddCommandToMenu(menu, data, key, tgt, name, stores)
    local cl = LocalPlayer()
    local can = lia.command.hasAccess(cl, key, data)
    if not can then return end
    local cat = data.AdminStick.Category
    local sub = data.AdminStick.SubCategory
    local m = menu
    local categoryKey = nil
    local subcategoryKey = nil
    if MODULE.adminStickCategories and MODULE.adminStickCategories[cat] then
        categoryKey = cat
        if sub and MODULE.adminStickCategories[cat].subcategories and MODULE.adminStickCategories[cat].subcategories[sub] then subcategoryKey = sub end
    elseif cat == "characterManagement" then
        categoryKey = "characterManagement"
        if sub == "attributes" then
            subcategoryKey = "attributes"
        elseif sub == "factions" then
            subcategoryKey = "factions"
        elseif sub == "classes" then
            subcategoryKey = "classes"
        elseif sub == "whitelists" then
            subcategoryKey = "whitelists"
        elseif sub == "items" then
            subcategoryKey = "items"
        elseif sub == "adminStickSubCategoryBans" then
            subcategoryKey = "adminStickSubCategoryBans"
        elseif sub == "adminStickSubCategorySetInfos" then
            subcategoryKey = "adminStickSubCategorySetInfos"
        elseif sub == "adminStickSubCategoryGetInfos" then
            subcategoryKey = "adminStickSubCategoryGetInfos"
        end
    elseif cat == "characterManagement" then
        categoryKey = "characterManagement"
        if sub == "flags" then subcategoryKey = "flags" end
    elseif cat == "doorManagement" then
        categoryKey = "doorManagement"
        if sub == "doorActions" then
            subcategoryKey = "doorActions"
        elseif sub == "doorSettings" then
            subcategoryKey = "doorSettings"
        elseif sub == "doorMaintenance" then
            subcategoryKey = "doorMaintenance"
        elseif sub == "doorInformation" then
            subcategoryKey = "doorInformation"
        end
    elseif cat == "moderation" then
        categoryKey = "moderation"
        if sub == "moderationTools" then
            subcategoryKey = "moderationTools"
        elseif sub == "warnings" then
            subcategoryKey = "warnings"
        elseif sub == "misc" then
            subcategoryKey = "misc"
        end
    elseif cat == "utility" then
        categoryKey = "utility"
        if sub == "commands" then
            subcategoryKey = "commands"
        elseif sub == "items" then
            subcategoryKey = "items"
        elseif sub == "ooc" then
            subcategoryKey = "ooc"
        end
    elseif cat == "administration" then
        categoryKey = "administration"
        if sub == "server" then
            subcategoryKey = "server"
        elseif sub == "permissions" then
            subcategoryKey = "permissions"
        end
    elseif cat == "doorManagement" then
        categoryKey = "doorManagement"
        if sub == "doorActions" then
            subcategoryKey = "doorActions"
        elseif sub == "doorSettings" then
            subcategoryKey = "doorSettings"
        elseif sub == "doorMaintenance" then
            subcategoryKey = "doorMaintenance"
        elseif sub == "doorInformation" then
            subcategoryKey = "doorInformation"
        end
    end

    if categoryKey then
        m = GetOrCreateCategoryMenu(menu, categoryKey, stores)
        if subcategoryKey then m = GetOrCreateSubCategoryMenu(m, categoryKey, subcategoryKey, stores) end
    else
        if cat then m = GetOrCreateSubMenu(menu, cat, stores) end
        if sub then m = GetOrCreateSubMenu(m, sub, stores) end
    end

    if IsValid(m) then
        local ic = data.AdminStick.Icon or "icon16/page.png"
        m:AddOption(L(name), function()
            if data.arguments and #data.arguments > 0 then
                local argTypes = {}
                local defaults = {}
                for _, arg in ipairs(data.arguments) do
                    table.insert(argTypes, {arg.name, arg.type})
                    if arg.optional then defaults[arg.name] = "" end
                end

                lia.derma.requestArguments(name .. " - Arguments", argTypes, function(success, argData)
                    if not success or not argData then
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                        LocalPlayer().AdminStickTarget = nil
                        return
                    end

                    local id = GetIdentifier(tgt)
                    local cmd = "say /" .. key
                    local hasTargetArg = data.arguments[1] and (data.arguments[1].type == "player" or data.arguments[1].type == "target")
                    if id ~= "" and not hasTargetArg then cmd = cmd .. " " .. QuoteArgs(id) end
                    for _, arg in ipairs(data.arguments) do
                        local value = argData[arg.name]
                        if value and value ~= "" then
                            if (arg.type == "player" or arg.type == "target") and id ~= "" then
                                cmd = cmd .. " " .. QuoteArgs(id)
                            else
                                cmd = cmd .. " " .. QuoteArgs(value)
                            end
                        end
                    end

                    cl:ConCommand(cmd)
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end, defaults)
            else
                local id = GetIdentifier(tgt)
                local cmd = "say /" .. key
                if id ~= "" then cmd = cmd .. " " .. QuoteArgs(id) end
                cl:ConCommand(cmd)
                timer.Simple(0.1, function() AdminStickIsOpen = false end)
            end
        end):SetIcon(ic)
    end
end

local function hasAdminStickTargetClass(class)
    for _, c in pairs(lia.command.list) do
        if istable(c.AdminStick) and c.AdminStick.TargetClass == class then return true end
    end
    return false
end

function MODULE:OpenAdminStickUI(tgt)
    local cl = LocalPlayer()
    if not IsValid(tgt) or not tgt:isDoor() and not tgt:IsPlayer() and not hasAdminStickTargetClass(tgt:GetClass()) then return end
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local tempMenu = lia.derma.dermaMenu()
    local stores = {}
    local hasOptions = false
    if tgt:IsPlayer() then
        local info = {
            {
                name = L("charIDCopyFormat", tgt:getChar() and tgt:getChar():getID() or L("na")),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
        }

        if #info > 0 then hasOptions = true end
        if cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty() then hasOptions = true end
        if cl:hasPrivilege("manageTransfers") or cl:hasPrivilege("manageClasses") or cl:hasPrivilege("manageWhitelists") or cl:hasPrivilege("manageCharacterInformation") then hasOptions = true end
    end

    local tgtClass = tgt:GetClass()
    local cmds = {}
    for k, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) then
            local tc = v.AdminStick.TargetClass
            if tc then
                if tc == "door" and tgt:isDoor() or tc == tgtClass then
                    table.insert(cmds, {
                        name = v.AdminStick.Name or k,
                        data = v,
                        key = k
                    })
                end
            else
                if tgt:IsPlayer() then
                    table.insert(cmds, {
                        name = v.AdminStick.Name or k,
                        data = v,
                        key = k
                    })
                end
            end
        end
    end

    if #cmds > 0 then hasOptions = true end
    hook.Run("PopulateAdminStick", tempMenu, tgt)
    tempMenu:Remove()
    if not hasOptions then
        cl:notifyInfoLocalized("adminStickNoOptions")
        return
    end

    AdminStickIsOpen = true
    local menu = CreateOrganizedAdminStickMenu(tgt, stores)
    menu:Center()
    menu:MakePopup()
    if tgt:IsPlayer() then
        local info = {
            {
                name = L("charIDCopyFormat", tgt:getChar() and tgt:getChar():getID() or L("na")),
                cmd = function()
                    if tgt:getChar() then
                        cl:notifySuccessLocalized("adminStickCopiedCharID")
                        SetClipboardText(tgt:getChar():getID())
                    end

                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function()
                    cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                    SetClipboardText(tgt:Name())
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function()
                    cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                    SetClipboardText(tgt:SteamID())
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
        }

        table.sort(info, function(a, b) return a.name < b.name end)
        local infoCategory = GetOrCreateCategoryMenu(menu, "playerInformation", stores)
        if not infoCategory then return end
        for _, o in ipairs(info) do
            infoCategory:AddOption(L(o.name), o.cmd):SetIcon(o.icon)
        end

        IncludeAdminMenu(tgt, menu, stores)
        IncludeCharacterManagement(tgt, menu, stores)
        IncludeFlagManagement(tgt, menu, stores)
        IncludeTeleportation(tgt, menu, stores)
        IncludeUtility(tgt, menu, stores)
    end

    table.sort(cmds, function(a, b) return a.name < b.name end)
    local categorizedCommands = {}
    local uncategorizedCommands = {}
    for _, c in ipairs(cmds) do
        if c.data.AdminStick and c.data.AdminStick.Category then
            local cat = c.data.AdminStick.Category
            if not categorizedCommands[cat] then categorizedCommands[cat] = {} end
            table.insert(categorizedCommands[cat], c)
        else
            table.insert(uncategorizedCommands, c)
        end
    end

    for _, commands in pairs(categorizedCommands) do
        for _, c in ipairs(commands) do
            AddCommandToMenu(menu, c.data, c.key, tgt, c.name, stores)
        end
    end

    if #uncategorizedCommands > 0 then
        local utilityCategory = GetOrCreateCategoryMenu(menu, "utility", stores)
        if not utilityCategory then return end
        local commandsSubCategory = GetOrCreateSubCategoryMenu(utilityCategory, "utility", "commands", stores)
        if not commandsSubCategory then return end
        for _, c in ipairs(uncategorizedCommands) do
            local ic = c.data.AdminStick and c.data.AdminStick.Icon or "icon16/page.png"
            commandsSubCategory:AddOption(L(c.name), function()
                local id = GetIdentifier(tgt)
                local cmd = "say /" .. c.key
                if id ~= "" then cmd = cmd .. " " .. QuoteArgs(id) end
                cl:ConCommand(cmd)
                timer.Simple(0.1, function()
                    LocalPlayer().AdminStickTarget = nil
                    AdminStickIsOpen = false
                end)
            end):SetIcon(ic)
        end
    end

    hook.Run("PopulateAdminStick", menu, tgt)
    function menu:OnRemove()
        cl.AdminStickTarget = nil
        AdminStickIsOpen = false
        hook.Run("OnAdminStickMenuClosed")
    end

    function menu:OnClose()
        cl.AdminStickTarget = nil
        AdminStickIsOpen = false
        hook.Run("OnAdminStickMenuClosed")
    end

    menu:Open()
end

local LOGS_PER_PAGE = lia.config.get("logsPerPage", 30)
local function OpenLogsUI(panel, categorizedLogs)
    panel:Clear()
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    if not categorizedLogs or table.Count(categorizedLogs) == 0 then
        local noLogsLabel = panel:Add("DLabel")
        noLogsLabel:Dock(FILL)
        noLogsLabel:SetText(L("noLogsAvailable"))
        noLogsLabel:SetTextColor(Color(150, 150, 150))
        noLogsLabel:SetFont("LiliaFont.20")
        noLogsLabel:SetContentAlignment(5)
        return
    end

    local sheet = panel:Add("liaTabs")
    sheet:Dock(FILL)
    for category, logs in pairs(categorizedLogs) do
        local page = vgui.Create("DPanel")
        page:Dock(FILL)
        page:DockPadding(10, 10, 10, 10)
        page.Paint = nil
        local searchBox = page:Add("DTextEntry")
        searchBox:Dock(TOP)
        searchBox:DockMargin(0, 0, 0, 15)
        searchBox:SetTall(30)
        searchBox:SetPlaceholderText(L("searchLogs"))
        searchBox:SetTextColor(Color(200, 200, 200))
        searchBox.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local paginationContainer = page:Add("DPanel")
        paginationContainer:Dock(BOTTOM)
        paginationContainer:DockMargin(0, 15, 0, 0)
        paginationContainer:SetTall(30)
        paginationContainer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(0, 0, 0, 50)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local prevButton = paginationContainer:Add("liaSmallButton")
        prevButton:Dock(LEFT)
        prevButton:SetWide(80)
        prevButton:SetText(L("previousPage"))
        prevButton:DockMargin(5, 5, 5, 5)
        local pageLabel = paginationContainer:Add("DLabel")
        pageLabel:Dock(FILL)
        pageLabel:DockMargin(10, 5, 10, 5)
        pageLabel:SetTextColor(Color(200, 200, 200))
        pageLabel:SetFont("LiliaFont.16")
        pageLabel:SetContentAlignment(5)
        local nextButton = paginationContainer:Add("liaSmallButton")
        nextButton:Dock(RIGHT)
        nextButton:SetWide(80)
        nextButton:SetText(L("nextPage"))
        nextButton:DockMargin(5, 5, 5, 5)
        local list = page:Add("liaTable")
        list:Dock(FILL)
        list:DockMargin(0, 0, 0, 10)
        local columns = {
            {
                name = L("timestamp"),
                field = "timestamp"
            },
            {
                name = L("message"),
                field = "message"
            },
            {
                name = L("steamID"),
                field = "steamID"
            }
        }

        for _, col in ipairs(columns) do
            list:AddColumn(col.name)
        end

        list:AddMenuOption(L("copySteamID"), function(rowData) if rowData[3] and rowData[3] ~= "" then SetClipboardText(tostring(rowData[3])) end end, "icon16/page_copy.png")
        list:AddMenuOption(L("copyLogMessage"), function(rowData) SetClipboardText(tostring(rowData[2] or "")) end, "icon16/page_copy.png")
        local currentPage = 1
        local filteredLogs = logs
        local function getTotalPages()
            return math.max(1, math.ceil(#filteredLogs / LOGS_PER_PAGE))
        end

        local function updatePagination()
            local totalPages = getTotalPages()
            pageLabel:SetText(L("pageIndicator", tonumber(currentPage), tonumber(totalPages)))
            prevButton:SetDisabled(currentPage <= 1)
            nextButton:SetDisabled(currentPage >= totalPages)
            prevButton:SetTextColor(currentPage <= 1 and Color(100, 100, 100) or Color(200, 200, 200))
            nextButton:SetTextColor(currentPage >= totalPages and Color(100, 100, 100) or Color(200, 200, 200))
        end

        local function showCurrentPage()
            list:Clear()
            local startIndex = (currentPage - 1) * LOGS_PER_PAGE + 1
            local endIndex = math.min(startIndex + LOGS_PER_PAGE - 1, #filteredLogs)
            for i = startIndex, endIndex do
                local log = filteredLogs[i]
                if log then
                    local line = list:AddLine(log.timestamp, log.message, log.steamID or "")
                    line.rowData = log
                end
            end
        end

        local function populate(filter)
            filter = string.lower(filter or "")
            filteredLogs = {}
            for _, log in ipairs(logs) do
                local msgMatch = string.find(string.lower(log.message), filter, 1, true)
                local idMatch = log.steamID and string.find(string.lower(log.steamID), filter, 1, true)
                if filter == "" or msgMatch or idMatch then table.insert(filteredLogs, log) end
            end

            currentPage = 1
            updatePagination()
            showCurrentPage()
        end

        local function goToPage(_)
            local totalPages = getTotalPages()
            if _ >= 1 and _ <= totalPages then
                currentPage = _
                updatePagination()
                showCurrentPage()
            end
        end

        prevButton.DoClick = function() goToPage(currentPage - 1) end
        nextButton.DoClick = function() goToPage(currentPage + 1) end
        searchBox.OnChange = function() populate(searchBox:GetValue()) end
        function list:OnRowRightClick(_, line)
            if not IsValid(line) or not line.rowData then return end
            local menu = lia.derma.dermaMenu()
            menu:AddOption(L("noOptionsAvailable"), function() end)
            menu:Open()
        end

        populate("")
        page:SetParent(sheet)
        sheet:AddSheet(category, page)
    end

    if sheet.tabs and #sheet.tabs > 0 then sheet:SetActiveTab(1) end
end

liaLogsPanel = liaLogsPanel or nil
lia.net.readBigTable("liaSendLogs", function(categorizedLogs)
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        return
    end

    local logsPanel = liaLogsPanel
    if not IsValid(logsPanel) then
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(panel) and panel.liaLogsPanel then
                logsPanel = panel.liaLogsPanel
                liaLogsPanel = logsPanel
                break
            end
        end
    end

    if IsValid(logsPanel) then
        OpenLogsUI(logsPanel, categorizedLogs)
    else
        chat.AddText(Color(255, 100, 100), L("logsPanelError"))
    end
end)

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
        if key == "Theme" then
            lia.color.applyTheme(value, true)
            if IsValid(lia.gui.menu) and lia.gui.menu.currentTab == "themes" then
                lia.gui.menu:Remove()
                vgui.Create("liaMenu")
            end
        elseif key == "Font" then
            if IsValid(lia.gui.menu) then lia.gui.menu:Update() end
        end

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
    local frame = vgui.Create("liaFrame")
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
            local btn = vgui.Create("liaButton", entry)
            btn:Dock(RIGHT)
            btn:SetWide(80)
            btn:SetText(L(key))
            btn.DoClick = function()
                net.Start("liaManagesitroomsAction")
                net.WriteUInt(action, 2)
                net.WriteString(name)
                if action == 2 then
                    local prompt = vgui.Create("liaFrame")
                    prompt:SetTitle(L("renameSitroomTitle"))
                    prompt:SetSize(300, 100)
                    prompt:Center()
                    prompt:MakePopup()
                    local txt = vgui.Create("liaEntry", prompt)
                    txt:Dock(FILL)
                    local ok = vgui.Create("liaButton", prompt)
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
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
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
    hook.Run("OnlineStaffDataReceived", staffData)
end)

function MODULE:PrePlayerDraw(client)
    if not IsValid(client) then return end
    if client:GetMoveType() == MOVETYPE_NOCLIP then return true end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not client:IsValid() or not client:IsPlayer() or not client:getChar() then return end
    if not (client:GetMoveType() == MOVETYPE_NOCLIP) then return end
    if not (client:hasPrivilege("noClipESPOffsetStaff") or client:isStaffOnDuty()) then return end
    if not lia.option.get("espEnabled", false) then return end
    for _, ent in ents.Iterator() do
        if not IsValid(ent) or ent == client or ent:IsWeapon() then continue end
        local pos = ent:GetPos()
        if not pos then continue end
        local kind, label, subLabel, baseColor
        if ent:IsPlayer() then
            kind = L("players")
            subLabel = ent:Name():gsub("#", "\226\128\139#")
            if ent:getNetVar("cheater", false) then
                label = string.upper(L("cheater"))
                baseColor = Color(255, 0, 0)
            else
                label = subLabel
                baseColor = lia.option.get("espPlayersColor")
            end
        elseif ent.isItem and ent:isItem() and lia.option.get("espItems", false) then
            kind = L("items")
            local item = ent.getItemTable and ent:getItemTable()
            label = item and item.getName and item:getName() or L("unknown")
            baseColor = lia.option.get("espItemsColor")
        elseif lia.option.get("espEntities", false) and ent:GetClass():StartWith("lia_") then
            kind = L("entities")
            label = ent.PrintName or ent:GetClass()
            baseColor = lia.option.get("espEntitiesColor")
        elseif ent:isDoor() then
            local doorData = ent:getNetVar("doorData", {})
            local factions = doorData.factions or {}
            local classes = doorData.classes or {}
            local name = doorData.name
            local title = doorData.title
            local price = doorData.price or 0
            local locked = doorData.locked
            local disabled = doorData.disabled
            local hidden = doorData.hidden
            local noSell = doorData.noSell
            local isConfigured = (factions and #factions > 0) or (classes and #classes > 0) or (name and name ~= "") or (title and title ~= "") or price > 0 or locked or disabled or hidden or noSell
            if lia.option.get("espUnconfiguredDoors", false) and not isConfigured then
                kind = L("doorUnconfigured")
                label = L("doorUnconfigured")
                baseColor = lia.option.get("espUnconfiguredDoorsColor")
            elseif lia.option.get("espConfiguredDoors", false) and isConfigured then
                kind = L("doorConfigured")
                label = L("doorConfigured")
                baseColor = lia.option.get("espConfiguredDoorsColor")
            end
        end

        if not kind then continue end
        local screenPos = pos:ToScreen()
        if not screenPos.visible then continue end
        surface.SetFont("liaMediumFont")
        local _, textHeight = surface.GetTextSize("W")
        draw.SimpleTextOutlined(label, "liaMediumFont", screenPos.x, screenPos.y, Color(baseColor.r, baseColor.g, baseColor.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        if subLabel and subLabel ~= label then draw.SimpleTextOutlined(subLabel, "liaMediumFont", screenPos.x, screenPos.y + textHeight, Color(baseColor.r, baseColor.g, baseColor.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200)) end
        if kind == L("players") then
            local barW, barH = 100, 22
            local barX = screenPos.x - barW / 2
            local barY = screenPos.y + textHeight + 5
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(barX, barY, barW, barH)
            local hpFrac = math.Clamp(ent:Health() / ent:GetMaxHealth(), 0, 1)
            surface.SetDrawColor(183, 8, 0, 255)
            surface.DrawRect(barX + 2, barY + 2, (barW - 4) * hpFrac, barH - 4)
            surface.SetFont("liaSmallFont")
            local healthX = barX + barW / 2
            local healthY = barY + barH / 2
            draw.SimpleTextOutlined(ent:Health(), "liaSmallFont", healthX, healthY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            if ent:Armor() > 0 then
                barY = barY + barH + 5
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(barX, barY, barW, barH)
                local armorFrac = math.Clamp(ent:Armor() / 100, 0, 1)
                surface.SetDrawColor(0, 0, 255, 255)
                surface.DrawRect(barX + 2, barY + 2, (barW - 4) * armorFrac, barH - 4)
                local armorX = barX + barW / 2
                local armorY = barY + barH / 2
                draw.SimpleTextOutlined(ent:Armor(), "liaSmallFont", armorX, armorY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            end

            local wep = ent:GetActiveWeapon()
            if IsValid(wep) then
                local ammo, reserve = wep:Clip1(), ent:GetAmmoCount(wep:GetPrimaryAmmoType())
                local wepName = language.GetPhrase(wep:GetPrintName())
                if ammo >= 0 and reserve >= 0 then wepName = wepName .. " [" .. ammo .. "/" .. reserve .. "]" end
                draw.SimpleTextOutlined(wepName, "liaSmallFont", screenPos.x, barY + barH + 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
            end
        end
    end
end

net.Receive("liaDisplayCharList", function()
    local sendData = net.ReadTable()
    local targetSteamIDsafe = net.ReadString()
    local extraColumns, extraOrder = {}, {}
    for _, v in pairs(sendData or {}) do
        if istable(v.extraDetails) then
            for k in pairs(v.extraDetails) do
                if not extraColumns[k] then
                    extraColumns[k] = true
                    table.insert(extraOrder, k)
                end
            end
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
            name = "banned",
            field = L("banned")
        },
        {
            name = "banningAdminName",
            field = "BanningAdminName"
        },
        {
            name = "banningAdminSteamID",
            field = "BanningAdminSteamID"
        },
        {
            name = "banningAdminRank",
            field = "BanningAdminRank"
        },
        {
            name = "charMoney",
            field = L("money")
        },
        {
            name = "lastUsed",
            field = "LastUsed"
        }
    }

    for _, name in ipairs(extraOrder) do
        table.insert(columns, {
            name = name,
            field = name
        })
    end

    local _, listView = lia.util.createTableUI(L("charlistTitle", targetSteamIDsafe), columns, sendData)
    if IsValid(listView) then
        for _, line in ipairs(listView:GetLines()) do
            local dataIndex = line:GetID()
            local rowData = sendData[dataIndex]
            if rowData and rowData.Banned == L("yes") then
                line.DoPaint = line.Paint
                line.Paint = function(pnl, w, h)
                    surface.SetDrawColor(200, 100, 100)
                    surface.DrawRect(0, 0, w, h)
                    pnl:DoPaint(w, h)
                end
            end

            line.CharID = rowData and rowData.ID
            line.SteamID = targetSteamIDsafe
            if rowData and rowData.extraDetails then
                local colIndex = 10
                for _, name in ipairs(extraOrder) do
                    line:SetColumnText(colIndex, tostring(rowData.extraDetails[name] or ""))
                    colIndex = colIndex + 1
                end
            end
        end

        listView.OnRowRightClick = function(_, _, ln)
            if not (ln and ln.CharID) then return end
            if not (lia.command.hasAccess(LocalPlayer(), "charban") or lia.command.hasAccess(LocalPlayer(), "charwipe") or lia.command.hasAccess(LocalPlayer(), "charunban") or lia.command.hasAccess(LocalPlayer(), "charbanoffline") or lia.command.hasAccess(LocalPlayer(), "charwipeoffline") or lia.command.hasAccess(LocalPlayer(), "charunbanoffline")) then return end
            local owner = ln.SteamID and lia.util.getBySteamID(ln.SteamID)
            local dMenu = lia.derma.dermaMenu()
            if IsValid(owner) then
                if lia.command.hasAccess(LocalPlayer(), "charban") then
                    local opt1 = dMenu:AddOption(L("banCharacter"), function() LocalPlayer():ConCommand('say "/charban ' .. ln.CharID .. '"') end)
                    opt1:SetIcon("icon16/cancel.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charwipe") then
                    local opt1_5 = dMenu:AddOption(L("wipeCharacter"), function() LocalPlayer():ConCommand('say "/charwipe ' .. ln.CharID .. '"') end)
                    opt1_5:SetIcon("icon16/user_delete.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charunban") then
                    local opt2 = dMenu:AddOption(L("unbanCharacter"), function() LocalPlayer():ConCommand('say "/charunban ' .. ln.CharID .. '"') end)
                    opt2:SetIcon("icon16/accept.png")
                end
            else
                if lia.command.hasAccess(LocalPlayer(), "charbanoffline") then
                    local opt3 = dMenu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. ln.CharID .. '"') end)
                    opt3:SetIcon("icon16/cancel.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then
                    local opt3_5 = dMenu:AddOption(L("wipeCharacterOffline"), function() LocalPlayer():ConCommand('say "/charwipeoffline ' .. ln.CharID .. '"') end)
                    opt3_5:SetIcon("icon16/user_delete.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then
                    local opt4 = dMenu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. ln.CharID .. '"') end)
                    opt4:SetIcon("icon16/accept.png")
                end
            end

            dMenu:Open()
        end
    end
end)

local TicketFrames = {}
local xpos = xpos or 20
local ypos = ypos or 20
function MODULE:TicketFrame(requester, message, claimed)
    if not IsValid(requester) or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            local txt = v:GetChildren()[5]
            txt:AppendText("\n" .. message)
            txt:GotoTextEnd()
            timer.Remove("ticketsystem-" .. requester:SteamID())
            timer.Create("ticketsystem-" .. requester:SteamID(), 60, 1, function() if IsValid(v) then v:Remove() end end)
            lia.websound.playButtonSound("ui/hint.wav")
            return
        end
    end

    local frameWidth, frameHeight = 400, 160
    local frm = vgui.Create("liaFrame")
    frm:SetSize(frameWidth, frameHeight)
    frm:SetPos(xpos, ypos)
    frm.idiot = requester
    frm:ShowCloseButton(false)
    if claimed and IsValid(claimed) and claimed:IsPlayer() then
        frm:SetTitle(L("ticketTitleClaimed", requester:Nick(), claimed:Nick()))
        if claimed ~= LocalPlayer() then frm.headerColor = Color(207, 0, 15) end
    else
        frm:SetTitle(requester:Nick())
    end

    local msg = vgui.Create("liaEntry", frm)
    msg:SetPos(10, 30)
    msg:SetSize(280, frameHeight - 35)
    msg:SetText(message)
    msg:SetMultiline(true)
    msg:SetEditable(false)
    msg:SetDrawBackground(false)
    msg:SetPaintBackground(false)
    msg.Paint = function(panel, w, h)
        lia.derma.rect(0, 0, w, h):Rad(4):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
        panel:DrawTextEntryText(lia.color.theme.text, lia.color.theme.text, lia.color.theme.text)
    end

    local function createButton(text, position, clickFunc, disabled)
        text = L(text)
        local btn = vgui.Create("liaButton", frm)
        btn:SetPos(300, position)
        btn:SetSize(83, 18)
        btn:SetText(text)
        btn.Disabled = disabled
        btn.DoClick = function() if not btn.Disabled then clickFunc() end end
        if disabled then btn:SetTooltip(L("ticketActionSelf")) end
        return btn
    end

    local isLocalPlayer = requester == LocalPlayer()
    createButton("goTo", 35, function() lia.administrator.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", 60, function() lia.administrator.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", 85, function() lia.administrator.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", 110, function() lia.administrator.execCommand("bring", requester) end, isLocalPlayer)
    local shouldClose = false
    local claimButton
    claimButton = createButton("claimCase", 135, function()
        if not IsValid(frm) then return end
        if not frm.title then return end
        if not shouldClose then
            local title = frm.title
            if title and title:lower():find(L("claimedBy"):lower()) then
                chat.AddText(Color(255, 150, 0), "[" .. L("error") .. "] " .. L("caseAlreadyClaimed"))
                surface.PlaySound("common/wpn_denyselect.wav")
            else
                net.Start("liaTicketSystemClaim")
                net.WriteEntity(requester)
                net.SendToServer()
                shouldClose = true
                claimButton:SetText(L("closeCase"))
            end
        else
            net.Start("liaTicketSystemClose")
            net.WriteEntity(requester)
            net.SendToServer()
        end
    end, isLocalPlayer)

    local closeButton = vgui.Create("liaButton", frm)
    closeButton:SetText("X")
    closeButton:SetTooltip(L("close"))
    closeButton:SetPos(frameWidth - 18, 2)
    closeButton:SetSize(16, 16)
    closeButton.DoClick = function() frm:Remove() end
    frm:SetPos(xpos, ypos + 130 * #TicketFrames)
    frm:MoveTo(xpos, ypos + 130 * #TicketFrames, 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if TicketFrames then
            table.RemoveByValue(TicketFrames, frm)
            for k, v in ipairs(TicketFrames) do
                v:MoveTo(xpos, ypos + 130 * (k - 1), 0.1, 0, 1)
            end
        end

        if IsValid(requester) and timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    end

    table.insert(TicketFrames, frm)
    timer.Create("ticketsystem-" .. requester:SteamID(), 60, 1, function() if IsValid(frm) then frm:Remove() end end)
end

local ticketPanel
local ticketsTabAdded = false
net.Receive("liaActiveTickets", function()
    local tickets = net.ReadTable() or {}
    if not IsValid(ticketPanel) then return end
    ticketPanel:Clear()
    ticketPanel:DockPadding(6, 6, 6, 6)
    ticketPanel.Paint = function() end
    local search = ticketPanel:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local list = ticketPanel:Add("liaTable")
    list:Dock(FILL)
    local columns = {
        {
            name = L("timestamp"),
            field = "timestamp"
        },
        {
            name = L("requester"),
            field = "requesterDisplay"
        },
        {
            name = L("admin"),
            field = "adminDisplay"
        },
        {
            name = L("message"),
            field = "message"
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

    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, t in pairs(tickets) do
            local requester = t.requester or ""
            local requesterDisplay = ""
            if requester ~= "" then
                local requesterPly = lia.util.getBySteamID(requester)
                local requesterName = IsValid(requesterPly) and requesterPly:Nick() or requester
                requesterDisplay = string.format("%s (%s)", requesterName, requester)
            end

            local ts = os.date("%Y-%m-%d %H:%M:%S", t.timestamp or os.time())
            local adminDisplay = L("unassigned")
            if t.admin then
                local adminPly = lia.util.getBySteamID(t.admin)
                local adminName = IsValid(adminPly) and adminPly:Nick() or t.admin
                adminDisplay = string.format("%s (%s)", adminName, t.admin)
            end

            local values = {ts, requesterDisplay, adminDisplay, t.message or ""}
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
        menu:AddOption(L("noOptionsAvailable"), function() end)
        menu:Open()
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
end)

net.Receive("liaTicketsCount", function()
    local count = net.ReadInt(32)
    ticketsCount = count
    if not ticketsTabAdded and count > 0 then ticketsTabAdded = true end
end)

hook.Add("PopulateAdminTabs", "liaTicketsTab", function(pages)
    if not IsValid(LocalPlayer()) or not (LocalPlayer():hasPrivilege("alwaysSeeTickets") or LocalPlayer():isStaffOnDuty()) then return end
    if ticketsCount and ticketsCount > 0 then
        table.insert(pages, {
            name = "tickets",
            icon = "icon16/report.png",
            drawFunc = function(panel)
                ticketPanel = panel
                net.Start("liaRequestActiveTickets")
                net.SendToServer()
            end
        })
    end
end)

net.Receive("liaViewClaims", function()
    local tbl = net.ReadTable()
    local steamid = net.ReadString()
    if steamid and steamid ~= "" and steamid ~= " " then
        local v = tbl[steamid]
        lia.admin(L("claimRecordLast", v.name, v.claims, string.NiceTime(os.time() - v.lastclaim)))
    else
        for _, v in pairs(tbl) do
            lia.admin(L("claimRecord", v.name, v.claims))
        end
    end
end)

net.Receive("liaTicketSystem", function()
    local pl = net.ReadEntity()
    local msg = net.ReadString()
    local claimed = net.ReadEntity()
    if IsValid(LocalPlayer()) and (LocalPlayer():isStaffOnDuty() or LocalPlayer():hasPrivilege("alwaysSeeTickets")) then MODULE:TicketFrame(pl, msg, claimed) end
end)

net.Receive("liaTicketSystemClaim", function()
    local pl = net.ReadEntity()
    local requester = net.ReadEntity()
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            v:SetTitle(requester:Nick() .. " - " .. L("claimedBy") .. " " .. pl:Nick())
            local bu = v:GetChildren()[11]
            if not bu or not IsValid(bu) then return end
            bu.DoClick = function()
                if LocalPlayer() == pl then
                    net.Start("liaTicketSystemClose")
                    net.WriteEntity(requester)
                    net.SendToServer()
                else
                    v:Close()
                end
            end
        end
    end
end)

net.Receive("liaTicketSystemClose", function()
    local requester = net.ReadEntity()
    if not IsValid(requester) or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then v:Remove() end
    end

    if timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
end)

net.Receive("liaClearAllTicketFrames", function()
    for _, v in pairs(TicketFrames) do
        if IsValid(v) then v:Remove() end
    end

    TicketFrames = {}
    for _, ply in player.Iterator() do
        if timer.Exists("ticketsystem-" .. ply:SteamID()) then timer.Remove("ticketsystem-" .. ply:SteamID()) end
    end
end)

local panelRef
local warningsTabAdded = false
net.Receive("liaAllWarnings", function()
    local warnings = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = function() end
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local list = panelRef:Add("liaTable")
    list:Dock(FILL)
    local columns = {
        {
            name = L("timestamp"),
            field = "timestamp"
        },
        {
            name = L("warned"),
            field = "warnedDisplay"
        },
        {
            name = L("admin"),
            field = "adminDisplay"
        },
        {
            name = L("warningMessage"),
            field = "message"
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

    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, warn in ipairs(warnings) do
            local warnedDisplay = string.format("%s (%s)", warn.warned or "", warn.warnedSteamID or "")
            local adminDisplay = string.format("%s (%s)", warn.warner or "", warn.warnerSteamID or "")
            local values = {warn.timestamp or "", warnedDisplay, adminDisplay, warn.message or ""}
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
end)

net.Receive("liaWarningsCount", function()
    local count = net.ReadInt(32)
    warningsCount = count
    if not warningsTabAdded and count > 0 then warningsTabAdded = true end
end)

hook.Add("PopulateAdminTabs", "liaWarningsTab", function(pages)
    if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("viewPlayerWarnings") then return end
    if warningsCount and warningsCount > 0 then
        table.insert(pages, {
            name = "warnings",
            icon = "icon16/error.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestAllWarnings")
                net.SendToServer()
            end
        })
    end
end)

function MODULE:OnAdminStickMenuClosed()
    local client = LocalPlayer()
    if IsValid(client) and client.AdminStickTarget == client then client.AdminStickTarget = nil end
end
