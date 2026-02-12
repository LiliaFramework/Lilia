local MODULE = MODULE
AdminStickIsOpen = false
AdminStickMenu = nil
AdminStickWarnings = {}
AdminStickMenuPositionCache = nil
AdminStickMenuOpenTime = 0
MODULE.adminStickCategories = MODULE.adminStickCategories or {}
MODULE.adminStickCategoryOrder = MODULE.adminStickCategoryOrder or {}
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
    adminStickSubCategoryRanking = "icon16/user_green.png",
    Ranks = "icon16/user_green.png",
    server = "icon16/cog.png",
    permissions = "icon16/key.png",
}

local function GetIdentifier(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return "" end
    if ent:IsBot() then return ent:Name() end
    return ent:SteamID64()
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
    local userGroup = client:GetUserGroup()
    local isAdmin = userGroup == "admin" or userGroup == "superadmin" or userGroup == "owner" or userGroup == "moderator"
    if not (isAdmin or client:hasPrivilege("canAccessScoreboardInfoOutOfStaff") or (client:hasPrivilege("canAccessScoreboardAdminOptions") and client:isStaffOnDuty())) then return end
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
        LocalPlayer():requestString(L("modifyCharFlags"), L("modifyFlagsDesc"), function(text)
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
                        container:DockMargin(0, 25, 0, 0)
                        container.Paint = function() end
                        local search = container:Add("liaEntry")
                        search:Dock(TOP)
                        search:DockMargin(0, 0, 0, 15)
                        search:SetTall(30)
                        search:SetFont("LiliaFont.17")
                        search:SetPlaceholderText(L("search"))
                        search:SetTextColor(Color(200, 200, 200))
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

                        list:AddMenuOption(L("wipeCharacter"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipe") then LocalPlayer():ConCommand('say "/charwipe ' .. rowData.CharID .. '"') end
                        end, "icon16/user_delete.png")

                        list:AddMenuOption(L("wipeCharacterOffline"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then LocalPlayer():ConCommand('say "/charwipeoffline ' .. rowData.CharID .. '"') end
                        end, "icon16/user_delete.png")

                        list:AddMenuOption(L("banCharacter"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if IsValid(owner) and not rowData.Banned and lia.command.hasAccess(LocalPlayer(), "charban") then LocalPlayer():ConCommand('say "/charban ' .. rowData.CharID .. '"') end
                        end, "icon16/cancel.png")

                        list:AddMenuOption(L("banCharacterOffline"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if not IsValid(owner) and not rowData.Banned and lia.command.hasAccess(LocalPlayer(), "charbanoffline") then LocalPlayer():ConCommand('say "/charbanoffline ' .. rowData.CharID .. '"') end
                        end, "icon16/cancel.png")

                        list:AddMenuOption(L("unbanCharacter"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if IsValid(owner) and rowData.Banned and lia.command.hasAccess(LocalPlayer(), "charunban") then LocalPlayer():ConCommand('say "/charunban ' .. rowData.CharID .. '"') end
                        end, "icon16/accept.png")

                        list:AddMenuOption(L("unbanCharacterOffline"), function(rowData)
                            if not rowData.CharID then return end
                            local owner = rowData.SteamID and lia.util.getBySteamID(rowData.SteamID)
                            if not IsValid(owner) and rowData.Banned and lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then LocalPlayer():ConCommand('say "/charunbanoffline ' .. rowData.CharID .. '"') end
                        end, "icon16/accept.png")

                        local function populate(filter)
                            list:Clear()
                            filter = tostring(filter or "")
                            filter = string.lower(filter)
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
                                        local valueStr = tostring(value):lower()
                                        if valueStr:find(filter, 1, true) then
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

                            list:ForceCommit()
                            list:InvalidateLayout(true)
                            if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
                        end

                        search.OnTextChanged = function(_, value) populate(value or "") end
                        populate("")
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
                    net.Start("liaSendLogsCategoriesRequest")
                    net.SendToServer()
                end
            end
        })
    end

    if client:hasPrivilege("manageCharacters") then
        table.insert(pages, {
            name = "pkManager",
            icon = "icon16/lightning.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestAllPks")
                net.SendToServer()
            end
        })
    end

    if client:hasPrivilege("alwaysSeeTickets") or client:isStaffOnDuty() then
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

    if client:hasPrivilege("viewPlayerWarnings") then
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
end

spawnmenu.AddContentType("inventoryitem", function(container, data)
    local client = LocalPlayer()
    if not client:hasPrivilege("canUseItemSpawner") then return end
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
                if formattedSubName:lower() == "moderationtools" then
                    formattedSubName = "Moderation Tools"
                elseif formattedSubName:lower() == "information" then
                    formattedSubName = "Information"
                elseif formattedSubName:lower() == "properties" then
                    formattedSubName = "Properties"
                elseif formattedSubName:lower() == "actions" then
                    formattedSubName = "Actions"
                elseif formattedSubName:lower() == "settings" then
                    formattedSubName = "Settings"
                elseif formattedSubName:lower() == "access" then
                    formattedSubName = "Access"
                elseif formattedSubName:lower() == "adminsticksubcategorybans" then
                    formattedSubName = "Bans"
                elseif formattedSubName:lower() == "adminsticksubcategorysetinfos" then
                    formattedSubName = "Set Information"
                elseif formattedSubName:lower() == "adminsticksubcategorygetinfos" then
                    formattedSubName = "Get Information"
                elseif formattedSubName:lower() == "adminsticksubcategorycharacterflags" then
                    formattedSubName = "Flags"
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

    local preferredOrder = {"moderation", "characterManagement", "doorManagement", "storageManagement"}
    local orderedCategories = {}
    for _, preferredCategory in ipairs(preferredOrder) do
        if mergedCategories[preferredCategory] then table.insert(orderedCategories, preferredCategory) end
    end

    for _, categoryName in ipairs(mergedCategoryNames) do
        if not table.HasValue(orderedCategories, categoryName) then table.insert(orderedCategories, categoryName) end
    end

    local hardcodedCategories = {
        moderation = {
            name = L("adminStickCategoryModeration") or "Moderation",
            icon = "icon16/shield.png",
            subcategories = {
                moderationTools = {
                    name = "Moderation Tools",
                    icon = "icon16/shield.png"
                },
                teleportation = {
                    name = L("adminStickCategoryTeleportation") or "Teleportation",
                    icon = "icon16/world.png"
                }
            }
        },
        characterManagement = {
            name = L("adminStickCategoryCharacterManagement") or "Character Management",
            icon = "icon16/user_gray.png",
            subcategories = {
                information = {
                    name = "Information",
                    icon = "icon16/information.png"
                },
                factions = {
                    name = L("adminStickSubCategoryFactions") or "Factions",
                    icon = "icon16/group.png"
                },
                classes = {
                    name = L("adminStickSubCategoryClasses") or "Classes",
                    icon = "icon16/user.png"
                },
                whitelists = {
                    name = L("adminStickSubCategoryWhitelists") or "Whitelists",
                    icon = "icon16/group_add.png"
                },
                properties = {
                    name = "Properties",
                    icon = "icon16/application_view_tile.png"
                },
                items = {
                    name = "Items",
                    icon = "icon16/box.png"
                }
            }
        },
        doorManagement = {
            name = L("adminStickCategoryDoorManagement"),
            icon = "icon16/door.png",
            subcategories = {
                actions = {
                    name = "Actions",
                    icon = "icon16/lightning.png"
                },
                settings = {
                    name = "Settings",
                    icon = "icon16/cog.png"
                },
                access = {
                    name = "Access",
                    icon = "icon16/group.png"
                }
            }
        },
        storageManagement = {
            name = L("storageManagement") or "Storage Management",
            icon = "icon16/package.png"
        }
    }

    for key, data in pairs(hardcodedCategories) do
        if not mergedCategories[key] then
            mergedCategories[key] = data
        else
            if not mergedCategories[key].subcategories then mergedCategories[key].subcategories = {} end
            for subKey, subData in pairs(data.subcategories or {}) do
                if not mergedCategories[key].subcategories[subKey] then mergedCategories[key].subcategories[subKey] = subData end
            end
        end

        if not table.HasValue(orderedCategories, key) then table.insert(orderedCategories, key) end
    end

    hook.Run("RegisterAdminStickSubcategories", mergedCategories)
    for key, _ in pairs(mergedCategories) do
        if not table.HasValue(orderedCategories, key) then table.insert(orderedCategories, key) end
    end
    return mergedCategories, orderedCategories
end

function MODULE:InitializedModules()
    local categories, categoryOrder = GenerateDynamicCategories()
    self.adminStickCategories = categories
    self.adminStickCategoryOrder = categoryOrder
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
    if not category then
        MODULE.adminStickCategories[categoryKey] = {
            name = L(categoryKey) ~= categoryKey and L(categoryKey) or categoryKey:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):gsub("_", " "),
            icon = GetIconForCategory(categoryKey),
            subcategories = {}
        }

        category = MODULE.adminStickCategories[categoryKey]
        if MODULE.adminStickCategoryOrder and not table.HasValue(MODULE.adminStickCategoryOrder, categoryKey) then table.insert(MODULE.adminStickCategoryOrder, categoryKey) end
    end

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
    if not category then category = GetOrCreateCategoryMenu(parent, categoryKey, store) and MODULE.adminStickCategories[categoryKey] end
    if not category then return parent end
    category.subcategories = category.subcategories or {}
    if not category.subcategories[subcategoryKey] then
        category.subcategories[subcategoryKey] = {
            name = L(subcategoryKey) ~= subcategoryKey and L(subcategoryKey) or subcategoryKey:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end):gsub("_", " "),
            icon = GetIconForCategory(subcategoryKey)
        }
    end

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

local function CreateOrganizedAdminStickMenu(tgt, stores, existingMenu)
    local menu = existingMenu or lia.derma.dermaMenu()
    if not IsValid(menu) then return menu end
    local cl = LocalPlayer()
    local categories, categoryOrder = GenerateDynamicCategories()
    MODULE.adminStickCategories = categories
    MODULE.adminStickCategoryOrder = categoryOrder
    for _, categoryKey in ipairs(categoryOrder) do
        local category = categories[categoryKey]
        if category then
            local hasContent
            if categoryKey == "moderation" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "characterManagement" and tgt:IsPlayer() then
                hasContent = true
            elseif categoryKey == "flagManagement" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "doorManagement" and tgt:isDoor() then
                hasContent = true
            elseif categoryKey == "storageManagement" and tgt.isStorageEntity then
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
    local victim = IsValid(tgt) and tgt:IsPlayer() and (tgt:IsBot() and tgt:Name() or tgt:SteamID()) or tgt
    lia.admin.execCommand(cmd, victim, dur, reason)
end

local function OpenPlayerModelUI(tgt)
    AdminStickIsOpen = true
    local fr = vgui.Create("liaFrame")
    fr:SetTitle(L("changePlayerModel"))
    fr:SetSize(1200, 800)
    fr:Center()
    function fr:OnClose()
        fr:Remove()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end

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

    local sheet = fr:Add("liaTabs")
    sheet:Dock(FILL)
    local function populateModelGrid(wr, modList)
        wr:Clear()
        for _, md in ipairs(modList) do
            local ic = wr:Add("SpawnIcon")
            ic:SetModel(md.mdl)
            ic:SetSize(128, 128)
            ic:SetTooltip(md.name)
            ic.model_path = md.mdl
            ic.DoClick = function() ed:SetValue(ic.model_path) end
        end
    end

    local allPanel = sheet:Add("Panel")
    local allSc = allPanel:Add("liaScrollPanel")
    allSc:Dock(FILL)
    local allWr = allSc:Add("DIconLayout")
    allWr:Dock(FILL)
    local allModList = {}
    for n, m in SortedPairs(player_manager.AllValidModels()) do
        table.insert(allModList, {
            name = n,
            mdl = m
        })
    end

    hook.Run("AdminStickAddModels", allModList, tgt)
    table.sort(allModList, function(a, b) return a.name < b.name end)
    populateModelGrid(allWr, allModList)
    sheet:AddSheet(L("all"), allPanel)
    local factionPanel = sheet:Add("Panel")
    local factionSheet = factionPanel:Add("liaTabs")
    factionSheet:Dock(FILL)
    local function processFactionModel(modelData, defaultName, modList)
        if isstring(modelData) then
            table.insert(modList, {
                name = defaultName,
                mdl = modelData
            })
        elseif istable(modelData) then
            if modelData[1] and isstring(modelData[1]) then
                table.insert(modList, {
                    name = modelData[2] or defaultName,
                    mdl = modelData[1]
                })
            end
        end
    end

    local function processFactionModels(faction, modList)
        if not faction.models then return end
        local models = faction.models
        if istable(models) then
            local hasStringKeys = false
            for k, _ in pairs(models) do
                if isstring(k) then
                    hasStringKeys = true
                    break
                end
            end

            if hasStringKeys then
                for _, categoryModels in pairs(models) do
                    if istable(categoryModels) then
                        for _, modelData in ipairs(categoryModels) do
                            processFactionModel(modelData, faction.name or "Unknown Faction", modList)
                        end
                    else
                        processFactionModel(categoryModels, faction.name or "Unknown Faction", modList)
                    end
                end
            else
                if models.male or models.female then
                    if models.male then
                        for _, modelData in ipairs(models.male) do
                            processFactionModel(modelData, faction.name or "Unknown Faction", modList)
                        end
                    end

                    if models.female then
                        for _, modelData in ipairs(models.female) do
                            processFactionModel(modelData, faction.name or "Unknown Faction", modList)
                        end
                    end
                else
                    for _, modelData in ipairs(models) do
                        processFactionModel(modelData, faction.name or "Unknown Faction", modList)
                    end
                end
            end
        else
            processFactionModel(models, faction.name or "Unknown Faction", modList)
        end
    end

    for _, faction in pairs(lia.faction.teams or {}) do
        if faction.models then
            local factionSubPanel = factionSheet:Add("Panel")
            local factionSc = factionSubPanel:Add("liaScrollPanel")
            factionSc:Dock(FILL)
            local factionWr = factionSc:Add("DIconLayout")
            factionWr:Dock(FILL)
            local factionModList = {}
            processFactionModels(faction, factionModList)
            table.sort(factionModList, function(a, b) return a.name < b.name end)
            populateModelGrid(factionWr, factionModList)
            factionSheet:AddSheet(faction.name or "Unknown Faction", factionSubPanel)
        end
    end

    sheet:AddSheet(L("faction"), factionPanel)
    local charObj = tgt:getChar()
    if charObj then
        local classIndex = charObj:getClass()
        if classIndex and classIndex ~= -1 and lia.class.list[classIndex] then
            local classPanel = sheet:Add("Panel")
            local classSheet = classPanel:Add("liaTabs")
            classSheet:Dock(FILL)
            local function processClassModel(modelData, className, modList)
                if istable(modelData) then
                    table.insert(modList, {
                        name = modelData[2] or className,
                        mdl = modelData[1]
                    })
                else
                    table.insert(modList, {
                        name = className,
                        mdl = modelData
                    })
                end
            end

            local function processClassModels(class, modList)
                if not class.model then return end
                local modelPath = class.model
                if istable(modelPath) then
                    if modelPath.male or modelPath.female then
                        if modelPath.male then
                            for _, modelData in ipairs(modelPath.male) do
                                processClassModel(modelData, class.name, modList)
                            end
                        end

                        if modelPath.female then
                            for _, modelData in ipairs(modelPath.female) do
                                processClassModel(modelData, class.name, modList)
                            end
                        end
                    else
                        for _, modelData in ipairs(modelPath) do
                            processClassModel(modelData, class.name, modList)
                        end
                    end
                elseif isstring(modelPath) then
                    table.insert(modList, {
                        name = class.name,
                        mdl = modelPath
                    })
                end
            end

            for _, class in pairs(lia.class.list or {}) do
                if class.model then
                    local classSubPanel = classSheet:Add("Panel")
                    local classSc = classSubPanel:Add("liaScrollPanel")
                    classSc:Dock(FILL)
                    local classWr = classSc:Add("DIconLayout")
                    classWr:Dock(FILL)
                    local classModList = {}
                    processClassModels(class, classModList)
                    table.sort(classModList, function(a, b) return a.name < b.name end)
                    populateModelGrid(classWr, classModList)
                    classSheet:AddSheet(class.name or "Unknown Class", classSubPanel)
                end
            end

            sheet:AddSheet(L("class"), classPanel)
        end
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
    local mods = {}
    local isBlinded = timer.Exists("liaBlind" .. tgt:SteamID())
    if isBlinded then
        mods[#mods + 1] = {
            name = L("unblind"),
            cmd = "unblind",
            icon = "icon16/eye.png"
        }
    else
        mods[#mods + 1] = {
            name = L("blind"),
            cmd = "blind",
            icon = "icon16/eye.png"
        }
    end

    if tgt:IsFrozen() then
        mods[#mods + 1] = {
            name = L("unfreeze"),
            cmd = "unfreeze",
            icon = "icon16/accept.png"
        }
    else
        mods[#mods + 1] = {
            name = L("freeze"),
            cmd = "freeze",
            icon = "icon16/lock.png"
        }
    end

    if tgt:getLiliaData("liaGagged", false) then
        mods[#mods + 1] = {
            name = L("ungag"),
            cmd = "ungag",
            icon = "icon16/sound_low.png"
        }
    else
        mods[#mods + 1] = {
            name = L("gag"),
            cmd = "gag",
            icon = "icon16/sound_mute.png"
        }
    end

    if tgt:getChar() and tgt:getLiliaData("liaMuted", false) then
        mods[#mods + 1] = {
            name = L("unmute"),
            cmd = "unmute",
            icon = "icon16/sound_add.png"
        }
    else
        mods[#mods + 1] = {
            name = L("mute"),
            cmd = "mute",
            icon = "icon16/sound_delete.png"
        }
    end

    if tgt:IsOnFire() then
        mods[#mods + 1] = {
            name = L("extinguish"),
            cmd = "extinguish",
            icon = "icon16/fire_delete.png"
        }
    else
        mods[#mods + 1] = {
            name = L("ignite"),
            cmd = "ignite",
            icon = "icon16/fire.png"
        }
    end

    if tgt:isLocked() then
        mods[#mods + 1] = {
            name = L("unjail"),
            cmd = "unjail",
            icon = "icon16/lock_open.png"
        }
    else
        mods[#mods + 1] = {
            name = L("jail"),
            cmd = "jail",
            icon = "icon16/lock.png"
        }
    end

    local otherMods = {
        {
            name = L("slay"),
            cmd = "slay",
            icon = "icon16/bomb.png"
        }
    }

    for _, mod in ipairs(otherMods) do
        mods[#mods + 1] = mod
    end

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
        modSubCategory:AddOption(L(cmd.name), function()
            RunAdminCommand(cmd.cmd, tgt)
            timer.Simple(0.1, function()
                LocalPlayer().AdminStickTarget = nil
                AdminStickIsOpen = false
            end)
        end):SetIcon(cmd.icon)
    end

    if modSubCategory.UpdateSize then modSubCategory:UpdateSize() end
end

local function IncludeTeleportation(tgt, menu, stores)
    local cl = LocalPlayer()
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local moderationCategory = GetOrCreateCategoryMenu(menu, "moderation", stores)
    if not moderationCategory then return end
    local tpCategory = GetOrCreateSubCategoryMenu(moderationCategory, "moderation", "teleportation", stores)
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

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
    if not charCategory then return end
    if cl:hasPrivilege("manageCharacterInformation") then
        charCategory:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/user_suit.png")
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

        if cf.UpdateSize then cf:UpdateSize() end
    end

    if cf and IsValid(cf) then
        cf:AddOption(L("modifyCharFlags"), function()
            local currentFlags = charObj and charObj:getFlags() or ""
            tgt:requestString(L("modifyCharFlags"), L("modifyFlagsDesc"), function(text)
                if text == false then return end
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
        if sub == "information" or sub == "adminStickSubCategorySetInfos" or sub == "adminStickSubCategoryGetInfos" then
            subcategoryKey = "information"
        elseif sub == "factions" then
            subcategoryKey = "factions"
        elseif sub == "classes" then
            subcategoryKey = "classes"
        elseif sub == "whitelists" then
            subcategoryKey = "whitelists"
        elseif sub == "properties" or sub == "flags" or sub == "attributes" or sub == "miscellaneous" then
            subcategoryKey = "properties"
        elseif sub == "items" then
            subcategoryKey = "items"
        end
    elseif cat == "doorManagement" then
        categoryKey = "doorManagement"
        if sub == "actions" or sub == "doorActions" or sub == "doorMaintenance" then
            subcategoryKey = "actions"
        elseif sub == "settings" or sub == "doorSettings" or sub == "doorInformation" then
            subcategoryKey = "settings"
        elseif sub == "access" or sub == "factions" or sub == "classes" then
            subcategoryKey = "access"
        end
    elseif cat == "storageManagement" then
        categoryKey = "storageManagement"
    elseif cat == "moderation" then
        categoryKey = "moderation"
        if sub == "moderationTools" or sub == "adminStickSubCategoryBans" or sub == "warnings" or sub == "misc" then
            subcategoryKey = "moderationTools"
        elseif sub == "teleportation" then
            subcategoryKey = "teleportation"
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
        local id = GetIdentifier(tgt)
        local baseCmd = "say /" .. key
        if id ~= "" then baseCmd = baseCmd .. " " .. QuoteArgs(id) end
        if key == "warn" then
            local warnMenu, warnOption = m:AddSubMenu(L(name))
            if warnOption then warnOption:SetIcon(ic) end
            local severityOptions = {
                {
                    label = "Low",
                    value = "Low"
                },
                {
                    label = "Medium",
                    value = "Medium"
                },
                {
                    label = "High",
                    value = "High"
                }
            }

            local reasonKey = L("reason") or "reason"
            local function openReason(selectedSeverity)
                lia.derma.requestArguments(L(name) .. " - " .. selectedSeverity, {{reasonKey, "string"}}, function(success, argData)
                    if not success or not argData then
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                        LocalPlayer().AdminStickTarget = nil
                        return
                    end

                    local reasonValue = argData[reasonKey] or ""
                    local warnCmd = baseCmd .. " " .. QuoteArgs(selectedSeverity)
                    if reasonValue ~= "" then warnCmd = warnCmd .. " " .. QuoteArgs(reasonValue) end
                    cl:ConCommand(warnCmd)
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end, {
                    [reasonKey] = ""
                })
            end

            for _, option in ipairs(severityOptions) do
                warnMenu:AddOption(option.label, function() openReason(option.value) end):SetIcon("icon16/error.png")
            end
            return
        end

        m:AddOption(L(name), function()
            local cmd = baseCmd
            if data.arguments and #data.arguments > 0 then
                local argTypes = {}
                local defaults = {}
                local startIndex = 1
                if data.arguments[1] and (data.arguments[1].type == "player" or data.arguments[1].type == "target") then startIndex = 2 end
                for i = startIndex, #data.arguments do
                    local arg = data.arguments[i]
                    table.insert(argTypes, {arg.name, arg.type})
                    if arg.optional then defaults[arg.name] = "" end
                end

                if #argTypes > 0 then
                    lia.derma.requestArguments(name .. " - Arguments", argTypes, function(success, argData)
                        if not success or not argData then
                            timer.Simple(0.1, function() AdminStickIsOpen = false end)
                            LocalPlayer().AdminStickTarget = nil
                            return
                        end

                        for i = startIndex, #data.arguments do
                            local arg = data.arguments[i]
                            local value = argData[arg.name]
                            if value and value ~= "" then cmd = cmd .. " " .. QuoteArgs(value) end
                        end

                        cl:ConCommand(cmd)
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                    end, defaults)
                else
                    cl:ConCommand(cmd)
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end
            else
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
    if not IsValid(tgt) or not tgt:isDoor() and not tgt:IsPlayer() and not tgt.isStorageEntity and not hasAdminStickTargetClass(tgt:GetClass()) then return end
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local tempMenu = lia.derma.dermaMenu()
    local stores = {}
    MODULE.adminStickCategories = {}
    MODULE.adminStickCategoryOrder = {}
    local hasOptions = false
    if tgt:IsPlayer() then
        local charID = tgt:getChar() and tgt:getChar():getID() or L("na")
        local info = {
            {
                name = L("charIDCopyFormat", charID),
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
    end

    local tgtClass = tgt:GetClass()
    local cmds = {}
    for k, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) and not v.realCommand then
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
    if IsValid(tgt) and tgt.isStorageEntity then hasOptions = true end
    local tempStores = {}
    hook.Run("PopulateAdminStick", tempMenu, tgt, tempStores)
    tempMenu:Remove()
    if not hasOptions then
        cl:notifyInfoLocalized("adminStickNoOptions")
        return
    end

    AdminStickIsOpen = true
    AdminStickMenuPositionCache = nil
    AdminStickMenuOpenTime = CurTime()
    local menu = lia.derma.dermaMenu()
    if not IsValid(menu) then return end
    AdminStickMenu = menu
    local baseThink = menu.Think
    menu.Think = function(panel)
        if baseThink then baseThink(panel) end
        if IsValid(panel) then
            local mx, my = panel:GetPos()
            local mw, mh = panel:GetWide(), panel:GetTall()
            if mw > 0 and mh > 0 then
                AdminStickMenuPositionCache = {
                    x = mx,
                    y = my,
                    w = mw,
                    h = mh,
                    updateTime = CurTime()
                }
            end
        end
    end

    if tgt:IsPlayer() then
        local charID = tgt:getChar() and tgt:getChar():getID() or L("na")
        local charName = tgt:getChar() and tgt:getChar():getName() or tgt:Name()
        local steamName = tgt:IsBot() and "BOT" or tgt:SteamName() or ""
        local steamID = tgt:IsBot() and "BOT" or tgt:SteamID() or ""
        local steamID64 = tgt:IsBot() and "BOT" or tgt:SteamID64() or ""
        local model = tgt:GetModel() or ""
        local steamProfileLink = steamID64 ~= "BOT" and steamID64 ~= "" and ("https://steamcommunity.com/profiles/" .. steamID64) or ""
        local info = {
            {
                name = "Steam Name: " .. steamName .. " (copy)",
                cmd = function()
                    if steamName ~= "BOT" and steamName ~= "" then
                        cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                        SetClipboardText(steamName)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = "Steam Profile: " .. (steamProfileLink ~= "" and steamProfileLink or "N/A") .. " (copy)",
                cmd = function()
                    if steamProfileLink ~= "" then
                        cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                        SetClipboardText(steamProfileLink)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", steamID),
                cmd = function()
                    if steamID ~= "BOT" and steamID ~= "" then
                        cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                        SetClipboardText(steamID)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = "SteamID64: " .. steamID64 .. " (copy)",
                cmd = function()
                    if steamID64 ~= "BOT" and steamID64 ~= "" then
                        cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                        SetClipboardText(steamID64)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", charName),
                cmd = function()
                    cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                    SetClipboardText(charName)
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("charIDCopyFormat", charID),
                cmd = function()
                    if tgt:getChar() then
                        cl:notifySuccessLocalized("adminStickCopiedCharID")
                        SetClipboardText(tgt:getChar():getID())
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = "Model: " .. model .. " (copy)",
                cmd = function()
                    cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                    SetClipboardText(model)
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = function()
                    local currentPos = tgt:GetPos()
                    local currentAng = tgt:GetAngles()
                    local posStr = string.format("Vector = (%.2f, %.2f, %.2f), Angle = (%.2f, %.2f, %.2f)", currentPos.x, currentPos.y, currentPos.z, currentAng.x, currentAng.y, currentAng.z)
                    return "Position: " .. posStr .. " (copy)"
                end,
                cmd = function()
                    local client = cl
                    if not IsValid(client) then
                        chat.AddText(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers"))
                        return
                    end

                    local currentPos = tgt:GetPos()
                    local currentAng = tgt:GetAngles()
                    local posStr = string.format("Vector = (%.2f, %.2f, %.2f), Angle = (%.2f, %.2f, %.2f)", currentPos.x, currentPos.y, currentPos.z, currentAng.x, currentAng.y, currentAng.z)
                    chat.AddText(Color(255, 255, 255), posStr)
                    SetClipboardText(posStr)
                    cl:notifySuccessLocalized("adminStickCopiedToClipboard")
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
        }

        for _, o in ipairs(info) do
            local nameText = isfunction(o.name) and o.name() or o.name
            local option = menu:AddOption(L(nameText), o.cmd)
            option:SetIcon(o.icon)
            option:SetZPos(-100)
        end

        menu:AddSpacer()
    end

    CreateOrganizedAdminStickMenu(tgt, stores, menu)
    menu:Center()
    menu:MakePopup()
    if tgt:IsPlayer() then
        IncludeAdminMenu(tgt, menu, stores)
        IncludeCharacterManagement(tgt, menu, stores)
        IncludeFlagManagement(tgt, menu, stores)
        IncludeTeleportation(tgt, menu, stores)
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

    hook.Add("RegisterAdminStickSubcategories", "liaDefaultSubcategories", function(categories)
        if categories.moderation then
            categories.moderation.subcategories = categories.moderation.subcategories or {}
            categories.moderation.subcategories.moderationTools = {
                name = "Moderation Tools",
                icon = "icon16/shield.png"
            }

            categories.moderation.subcategories.teleportation = {
                name = L("adminStickCategoryTeleportation") or "Teleportation",
                icon = "icon16/world.png"
            }
        end

        if categories.characterManagement then
            categories.characterManagement.subcategories = categories.characterManagement.subcategories or {}
            categories.characterManagement.subcategories.information = {
                name = "Information",
                icon = "icon16/information.png"
            }

            categories.characterManagement.subcategories.factions = {
                name = L("adminStickSubCategoryFactions") or "Factions",
                icon = "icon16/group.png"
            }

            categories.characterManagement.subcategories.classes = {
                name = L("adminStickSubCategoryClasses") or "Classes",
                icon = "icon16/group_edit.png"
            }

            categories.characterManagement.subcategories.whitelists = {
                name = L("adminStickSubCategoryWhitelists") or "Whitelists",
                icon = "icon16/group_key.png"
            }

            categories.characterManagement.subcategories.properties = {
                name = "Properties",
                icon = "icon16/application_view_tile.png"
            }

            categories.characterManagement.subcategories.items = {
                name = "Items",
                icon = "icon16/box.png"
            }
        end
    end)

    hook.Add("GetAdminStickLists", "liaDefaultAdminStickLists", function(target, lists)
        local client = LocalPlayer()
        local canFaction = client:hasPrivilege("manageTransfers")
        local canClass = client:hasPrivilege("manageClasses")
        local canWhitelist = client:hasPrivilege("manageWhitelists")
        if not target or not IsValid(target) then return end
        local pos = target:GetPos()
        local ang = target:GetAngles()
        local posStr = string.format("%.2f %.2f %.2f", pos.x, pos.y, pos.z)
        local angStr = string.format("%.2f %.2f %.2f", ang.p, ang.y, ang.r)
        local setPosAngStr = string.format("setpos %.2f %.2f %.2f; setang %.2f %.2f %.2f", pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)
        local displayName
        if target:IsPlayer() then
            local char = target:getChar()
            displayName = (char and char:getName()) or target:Nick() or target:Name() or "Unknown"
        elseif target.GetName and target:GetName() ~= "" then
            displayName = target:GetName()
        else
            displayName = target:GetClass() or "Unknown"
        end

        local copyItems = {
            {
                name = "Copy Name",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(displayName) end
            },
            {
                name = "Copy Position",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(posStr) end
            },
            {
                name = "Copy Angles",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(angStr) end
            },
            {
                name = "Copy Pos + Ang (printpos)",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(setPosAngStr) end
            }
        }

        table.insert(lists, {
            name = "Copy",
            category = "moderation",
            subcategory = "moderationTools",
            items = copyItems
        })

        if target.isStorageEntity then
            local storageOptions = {
                {
                    name = L("removePassword"),
                    icon = "icon16/key_delete.png",
                    callback = function() RunConsoleCommand("say", "/storagepasswordremove") end
                },
                {
                    name = L("changePassword"),
                    icon = "icon16/key.png",
                    callback = function()
                        lia.derma.requestString(L("enterNewPassword"), L("enterNewPassword"), function(password)
                            if password == false then return end
                            if password and password ~= "" then RunConsoleCommand("say", "/storagepasswordchange \"" .. password .. "\"") end
                        end, "")
                    end
                }
            }

            table.insert(lists, {
                name = L("storage") or "Storage",
                category = "storageManagement",
                subcategory = "storageActions",
                items = storageOptions
            })
        end

        if not target:IsPlayer() and not target.isStorageEntity then return end
        if target:IsPlayer() then
            local char = target:getChar()
            if not char then return end
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
                                        icon = "icon16/group.png",
                                        callback = function(callbackTarget)
                                            local cmd = 'say /plytransfer ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                                            client:ConCommand(cmd)
                                        end
                                    })
                                end

                                break
                            end
                        end

                        if #facOptions > 0 then
                            table.insert(lists, {
                                name = "Factions",
                                category = "characterManagement",
                                subcategory = "factions",
                                items = facOptions
                            })
                        end
                    end

                    local classes = lia.faction.getClasses(facID) or {}
                    if classes and #classes >= 1 and canClass then
                        local cls = {}
                        for _, c in ipairs(classes) do
                            table.insert(cls, {
                                name = c.name,
                                icon = "icon16/user.png",
                                callback = function(callbackTarget)
                                    local cmd = 'say /setclass ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                    client:ConCommand(cmd)
                                end
                            })
                        end

                        if #cls > 0 then
                            table.insert(lists, {
                                name = "Classes",
                                category = "characterManagement",
                                subcategory = "classes",
                                items = cls
                            })
                        end
                    end

                    if canWhitelist then
                        local facAdd, facRemove = {}, {}
                        for _, v in pairs(lia.faction.teams) do
                            if not v.isDefault then
                                if not target:hasWhitelist(v.index) then
                                    table.insert(facAdd, {
                                        name = v.name,
                                        icon = "icon16/group_add.png",
                                        callback = function(callbackTarget)
                                            local cmd = 'say /plywhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                                            client:ConCommand(cmd)
                                        end
                                    })
                                else
                                    table.insert(facRemove, {
                                        name = v.name,
                                        icon = "icon16/group_delete.png",
                                        callback = function(callbackTarget)
                                            local cmd = 'say /plyunwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                                            client:ConCommand(cmd)
                                        end
                                    })
                                end
                            end
                        end

                        local whitelistItems = {}
                        for _, item in ipairs(facAdd) do
                            table.insert(whitelistItems, item)
                        end

                        for _, item in ipairs(facRemove) do
                            table.insert(whitelistItems, item)
                        end

                        if #whitelistItems > 0 then
                            table.insert(lists, {
                                name = "Whitelists",
                                category = "characterManagement",
                                subcategory = "whitelists",
                                items = whitelistItems
                            })
                        end

                        if classes and #classes > 0 then
                            local cw, cu = {}, {}
                            for _, c in ipairs(classes) do
                                if not target:getChar():getClasswhitelists()[c.index] then
                                    table.insert(cw, {
                                        name = c.name,
                                        icon = "icon16/user_add.png",
                                        callback = function(callbackTarget)
                                            local cmd = 'say /classwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                            client:ConCommand(cmd)
                                        end
                                    })
                                else
                                    table.insert(cu, {
                                        name = c.name,
                                        icon = "icon16/user_delete.png",
                                        callback = function(callbackTarget)
                                            local cmd = 'say /classunwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                            client:ConCommand(cmd)
                                        end
                                    })
                                end
                            end

                            local classWhitelistItems = {}
                            for _, item in ipairs(cw) do
                                table.insert(classWhitelistItems, item)
                            end

                            for _, item in ipairs(cu) do
                                table.insert(classWhitelistItems, item)
                            end

                            if #classWhitelistItems > 0 then
                                table.insert(lists, {
                                    name = "Class Whitelists",
                                    category = "characterManagement",
                                    subcategory = "whitelists",
                                    items = classWhitelistItems
                                })
                            end
                        end
                    end
                end
            end
        end
    end)

    hook.Add("PopulateAdminStick", "liaAddAdminStickLists", function(currentMenu, currentTarget, currentStores)
        local lists = {}
        hook.Run("GetAdminStickLists", currentTarget, lists)
        for _, listData in ipairs(lists) do
            local listName = listData.name
            local categoryKey = listData.category
            local subcategoryKey = listData.subcategory
            local subSubcategoryKey = listData.subSubcategory
            local items = listData.items
            if listName and categoryKey and subcategoryKey and items and #items > 0 then
                local category = GetOrCreateCategoryMenu(currentMenu, categoryKey, currentStores)
                if category and IsValid(category) then
                    local subcategory = GetOrCreateSubCategoryMenu(category, categoryKey, subcategoryKey, currentStores)
                    if subcategory and IsValid(subcategory) then
                        local targetMenu = subcategory
                        if subSubcategoryKey then
                            targetMenu = GetOrCreateSubCategoryMenu(subcategory, categoryKey .. "_" .. subcategoryKey, subSubcategoryKey, currentStores)
                            if not targetMenu or not IsValid(targetMenu) then targetMenu = subcategory end
                        end

                        if targetMenu and IsValid(targetMenu) then
                            table.sort(items, function(a, b) return (a.name or "") < (b.name or "") end)
                            local icon = subMenuIcons[listName] or "icon16/page.png"
                            for _, item in ipairs(items) do
                                local option = targetMenu:AddOption(L(item.name), function()
                                    if item.callback then item.callback(currentTarget, item) end
                                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                                end)

                                if item.icon and IsValid(option) then
                                    option:SetIcon(item.icon)
                                elseif icon and icon ~= "icon16/page.png" and IsValid(option) then
                                    option:SetIcon(icon)
                                end
                            end

                            if targetMenu.UpdateSize then targetMenu:UpdateSize() end
                        end
                    end
                end
            end
        end
    end)

    hook.Run("PopulateAdminStick", menu, tgt, stores)
    function menu:OnRemove()
        if AdminStickMenu == self then
            cl.AdminStickTarget = nil
            AdminStickIsOpen = false
            AdminStickMenu = nil
            AdminStickMenuPositionCache = nil
            hook.Run("OnAdminStickMenuClosed")
        end
    end

    function menu:OnClose()
        if AdminStickMenu == self then
            cl.AdminStickTarget = nil
            AdminStickIsOpen = false
            AdminStickMenu = nil
            AdminStickMenuPositionCache = nil
            hook.Run("OnAdminStickMenuClosed")
        end
    end

    menu:Open()
    for _, delay in ipairs({0, 0.03, 0.06, 0.1}) do
        timer.Simple(delay, function()
            if AdminStickIsOpen and IsValid(menu) then
                local mx, my = menu:GetPos()
                local mw, mh = menu:GetWide(), menu:GetTall()
                if mw > 0 and mh > 0 then
                    AdminStickMenuPositionCache = {
                        x = mx,
                        y = my,
                        w = mw,
                        h = mh
                    }
                end
            end
        end)
    end
end

local currentCategoryData = {}
local function CreateLogsUI(panel, categories)
    panel:Clear()
    currentCategoryData = {}
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    if not categories or #categories == 0 then
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
    local function requestLogsForCategory(category)
        if not category or not currentCategoryData[category] then return end
        local pagePanel = currentCategoryData[category].panel
        if not IsValid(pagePanel) then return end
        if IsValid(pagePanel.loadingLabel) then
            pagePanel.loadingLabel:Remove()
            pagePanel.loadingLabel = nil
        end

        for _, child in ipairs(pagePanel:GetChildren()) do
            child:Remove()
        end

        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        net.Start("liaSendLogsRequest")
        net.WriteString(category)
        net.WriteUInt(currentCategoryData[category].currentPage, 16)
        net.SendToServer()
    end

    for _, category in ipairs(categories) do
        local pagePanel = vgui.Create("DPanel")
        pagePanel:Dock(FILL)
        pagePanel:DockPadding(10, 10, 10, 10)
        pagePanel.Paint = nil
        pagePanel.category = category
        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        currentCategoryData[category] = {
            panel = pagePanel,
            currentPage = 1,
            totalPages = 1,
            logs = {},
            searchFilter = ""
        }

        sheet:AddTab(category, pagePanel, nil, function() requestLogsForCategory(category) end)
    end

    local oldSetActiveTab = sheet.SetActiveTab
    sheet.SetActiveTab = function(self, tabIndex)
        oldSetActiveTab(self, tabIndex)
        local activeTab = self.tabs[tabIndex]
        if activeTab and activeTab.pan then
            local category = activeTab.pan.category
            requestLogsForCategory(category)
        end
    end

    if sheet.tabs and #sheet.tabs > 0 then sheet:SetActiveTab(1) end
    panel.logsSheet = sheet
end

local function UpdateLogsUI(panel, logsData)
    local category = logsData and logsData.category
    if not category then
        if IsValid(panel) and panel.logsSheet and panel.logsSheet.tabs then
            local activeId = panel.logsSheet.active_id or 1
            local activeTab = panel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
        return
    end

    if not currentCategoryData[category] then
        if IsValid(panel) and panel.logsSheet and panel.logsSheet.tabs then
            for _, tab in ipairs(panel.logsSheet.tabs) do
                if tab.pan and tab.pan.category == category and IsValid(tab.pan.loadingLabel) then
                    tab.pan.loadingLabel:Remove()
                    tab.pan.loadingLabel = nil
                end
            end

            local activeId = panel.logsSheet.active_id or 1
            local activeTab = panel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
        return
    end

    local categoryData = currentCategoryData[category]
    if not categoryData then return end
    local pagePanel = categoryData.panel
    if not IsValid(pagePanel) then return end
    if IsValid(pagePanel.loadingLabel) then
        pagePanel.loadingLabel:Remove()
        pagePanel.loadingLabel = nil
    end

    for _, child in ipairs(pagePanel:GetChildren()) do
        if child ~= pagePanel.loadingLabel then child:Remove() end
    end

    categoryData.currentPage = logsData.currentPage or 1
    categoryData.totalPages = logsData.totalPages or 1
    categoryData.logs = logsData.logs or {}
    local searchBox = pagePanel:Add("liaEntry")
    searchBox:Dock(TOP)
    searchBox:DockMargin(0, 0, 0, 15)
    searchBox:SetTall(30)
    searchBox:SetFont("LiliaFont.17")
    searchBox:SetPlaceholderText(L("searchLogs"))
    searchBox:SetTextColor(Color(200, 200, 200))
    searchBox:SetText(categoryData.searchFilter)
    local paginationContainer = pagePanel:Add("DPanel")
    paginationContainer:Dock(BOTTOM)
    paginationContainer:DockMargin(0, 15, 0, 0)
    paginationContainer:SetTall(30)
    paginationContainer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(0, 0, 0, 50)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local prevButton = paginationContainer:Add("liaButton")
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
    local nextButton = paginationContainer:Add("liaButton")
    nextButton:Dock(RIGHT)
    nextButton:SetWide(80)
    nextButton:SetText(L("nextPage"))
    nextButton:DockMargin(5, 5, 5, 5)
    local list = pagePanel:Add("liaTable")
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
    local function updatePagination()
        pageLabel:SetText(L("pageIndicator", categoryData.currentPage, categoryData.totalPages))
        prevButton:SetDisabled(categoryData.currentPage <= 1)
        nextButton:SetDisabled(categoryData.currentPage >= categoryData.totalPages)
        prevButton:SetTextColor(categoryData.currentPage <= 1 and Color(100, 100, 100) or Color(200, 200, 200))
        nextButton:SetTextColor(categoryData.currentPage >= categoryData.totalPages and Color(100, 100, 100) or Color(200, 200, 200))
    end

    local function showCurrentPage()
        list:Clear()
        local searchFilter = string.lower(categoryData.searchFilter or "")
        local filteredLogs = categoryData.logs
        if searchFilter ~= "" then
            filteredLogs = {}
            for _, log in ipairs(categoryData.logs) do
                local timestamp = string.lower(tostring(log.timestamp or ""))
                local message = string.lower(tostring(log.message or ""))
                local steamID = string.lower(tostring(log.steamID or ""))
                if string.find(timestamp, searchFilter, 1, true) or string.find(message, searchFilter, 1, true) or string.find(steamID, searchFilter, 1, true) then table.insert(filteredLogs, log) end
            end
        end

        for _, log in ipairs(filteredLogs) do
            local line = list:AddLine(log.timestamp, log.message, log.steamID or "")
            line.rowData = log
        end

        list:ForceCommit()
    end

    local function requestPage(pageNum)
        if pageNum >= 1 and pageNum <= categoryData.totalPages then
            categoryData.currentPage = pageNum
            net.Start("liaSendLogsRequest")
            net.WriteString(category)
            net.WriteUInt(pageNum, 16)
            net.SendToServer()
        end
    end

    searchBox.OnTextChanged = function(_, value)
        categoryData.searchFilter = value or ""
        showCurrentPage()
    end

    prevButton.DoClick = function() requestPage(categoryData.currentPage - 1) end
    nextButton.DoClick = function() requestPage(categoryData.currentPage + 1) end
    updatePagination()
    showCurrentPage()
    list:ForceCommit()
    list:InvalidateLayout(true)
    if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
end

liaLogsPanel = liaLogsPanel or nil
net.Receive("liaSendLogsCategories", function()
    local categories = net.ReadTable()
    if not categories or #categories == 0 then
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
        CreateLogsUI(logsPanel, categories)
    else
        chat.AddText(Color(255, 100, 100), L("logsPanelError"))
    end
end)

lia.net.readBigTable("liaSendLogs", function(logsData)
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

    local function removeLoadingLabel()
        if IsValid(logsPanel) and logsPanel.logsSheet and logsPanel.logsSheet.tabs then
            local activeId = logsPanel.logsSheet.active_id or 1
            local activeTab = logsPanel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
    end

    if not logsData then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        removeLoadingLabel()
        return
    end

    if IsValid(logsPanel) then
        local success, err = pcall(UpdateLogsUI, logsPanel, logsData)
        if not success then
            chat.AddText(Color(255, 0, 0), "Error updating logs UI: " .. tostring(err))
            removeLoadingLabel()
        end
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
            if IsValid(lia.gui.menu) and lia.gui.menu.currentTab == "themes" and lia.gui.menu:IsVisible() and lia.gui.menu:GetAlpha() > 0 then
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
            lia.char.getCharacter(id, nil, function(character)
                local client = LocalPlayer()
                if IsValid(client) then client:SetNoDraw(false) end
                hook.Run("CharLoaded", character)
            end)
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
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = function() end
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
            name = L("timestamp"),
            field = "timestamp"
        },
        {
            name = L("character"),
            field = "character"
        },
        {
            name = L("submitter"),
            field = "submitter"
        },
        {
            name = L("evidence"),
            field = "evidence"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

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
                lineData.steamID = c.steamID or ""
                lineData.reason = c.reason or ""
                lineData.evidence = c.evidence or ""
                lineData.submitter = c.submitterName or ""
                lineData.submitterSteamID = c.submitterSteamID or ""
                lineData.charID = c.charID
                list:AddLine(unpack(lineData))
            end
        end

        list:ForceCommit()
        list:InvalidateLayout(true)
        if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
    end

    list:AddMenuOption(L("copySubmitter"), function(rowData) if rowData.submitter and rowData.submitterSteamID then SetClipboardText(string.format("%s (%s)", rowData.submitter, rowData.submitterSteamID)) end end, "icon16/page_copy.png")
    list:AddMenuOption(L("copyReason"), function(rowData) if rowData.reason then SetClipboardText(rowData.reason) end end, "icon16/page_copy.png")
    list:AddMenuOption(L("copyEvidence"), function(rowData) if rowData.evidence then SetClipboardText(rowData.evidence) end end, "icon16/page_copy.png")
    list:AddMenuOption(L("copySteamID"), function(rowData) if rowData.steamID then SetClipboardText(rowData.steamID) end end, "icon16/page_copy.png")
    list:AddMenuOption(L("viewEvidence"), function(rowData) if rowData.evidence and rowData.evidence:match("^https?://") then gui.OpenURL(rowData.evidence) end end, "icon16/world.png")
    list:AddMenuOption(L("banCharacter"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charban") then LocalPlayer():ConCommand('say "/charban ' .. rowData.charID .. '"') end
    end, "icon16/cancel.png")

    list:AddMenuOption(L("wipeCharacter"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipe") then LocalPlayer():ConCommand('say "/charwipe ' .. rowData.charID .. '"') end
    end, "icon16/user_delete.png")

    list:AddMenuOption(L("unbanCharacter"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charunban") then LocalPlayer():ConCommand('say "/charunban ' .. rowData.charID .. '"') end
    end, "icon16/accept.png")

    list:AddMenuOption(L("banCharacterOffline"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charbanoffline") then LocalPlayer():ConCommand('say "/charbanoffline ' .. rowData.charID .. '"') end
    end, "icon16/cancel.png")

    list:AddMenuOption(L("wipeCharacterOffline"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then LocalPlayer():ConCommand('say "/charwipeoffline ' .. rowData.charID .. '"') end
    end, "icon16/user_delete.png")

    list:AddMenuOption(L("unbanCharacterOffline"), function(rowData)
        if not rowData.charID then return end
        local owner = rowData.steamID and lia.util.getBySteamID(rowData.steamID)
        if not IsValid(owner) and lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then LocalPlayer():ConCommand('say "/charunbanoffline ' .. rowData.charID .. '"') end
    end, "icon16/accept.png")

    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
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
    list:AddMenuOption(L("viewWarnings"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewwarns") then LocalPlayer():ConCommand("say /viewwarns " .. rowData.steamID) end end, "icon16/error.png")
    list:AddMenuOption(L("viewTicketRequests"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewtickets") then LocalPlayer():ConCommand("say /viewtickets " .. rowData.steamID) end end, "icon16/help.png")
    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
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
    local wep = client:GetActiveWeapon()
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
                        local label = entry.label ~= "" and entry.label or "Position"
                        if typeInfo.id == "faction_spawn_adder" then
                            label = "Spawn For Faction '" .. label .. "'"
                        elseif typeInfo.id == "class_spawn_adder" then
                            label = "Spawn For Class '" .. label .. "'"
                        elseif typeInfo.id == "sit_room" then
                            label = "Sit Room " .. label
                        end

                        lia.util.drawESPStyledText(label, screenPos.x, screenPos.y, col, "LiliaFont.24", 1)
                    end
                end
            end
        end
    end

    if not client:IsPlayer() or not client:getChar() then return end
    if client:GetMoveType() ~= MOVETYPE_NOCLIP then return end
    if not (client:hasPrivilege("noClipESPOffsetStaff") or client:isStaffOnDuty()) then return end
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
        elseif ent:IsPlayer() then
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
            if ent:GetClass() == "lia_npc" then
                local uniqueID = ent:getNetVar("uniqueID", "")
                if uniqueID ~= "" then
                    kind = "npcs"
                    label = ent:getNetVar("NPCName", "Unconfigured NPC")
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
            surface.SetFont("LiliaFont.24")
            local _, th = surface.GetTextSize(label)
            local bh = th + 16
            lia.util.drawESPStyledText(label, screenPos.x, screenPos.y, baseColor, "LiliaFont.24")
            if subLabel and subLabel ~= label then
                local font = (kind == "npcs") and "LiliaFont.16" or "LiliaFont.24"
                surface.SetFont(font)
                surface.GetTextSize(subLabel)
                local spacing = 8
                local subY = screenPos.y + bh / 2 + spacing
                lia.util.drawESPStyledText(subLabel, screenPos.x, subY, baseColor, font)
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
local function CreateTicketFrame(requester, message, claimed)
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
    msg:SetPaintBackground(false)
    msg.Paint = function(panel, w, h)
        lia.derma.rect(0, 0, w, h):Rad(4):Color((lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1]) or Color(34, 62, 62)):Shape(lia.derma.SHAPE_IOS):Draw()
        panel:DrawTextEntryText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235))
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
    createButton("goTo", 35, function() lia.admin.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", 60, function() lia.admin.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", 85, function() lia.admin.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", 110, function() lia.admin.execCommand("bring", requester) end, isLocalPlayer)
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
    frm:SetPos(xpos, ypos + 180 * #TicketFrames)
    frm:MoveTo(xpos, ypos + 180 * #TicketFrames, 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if TicketFrames then
            table.RemoveByValue(TicketFrames, frm)
            for k, v in ipairs(TicketFrames) do
                v:MoveTo(xpos, ypos + 180 * (k - 1), 0.1, 0, 1)
            end
        end

        if IsValid(requester) and timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    end

    table.insert(TicketFrames, frm)
    timer.Create("ticketsystem-" .. requester:SteamID(), 60, 1, function() if IsValid(frm) then frm:Remove() end end)
end

net.Receive("liaActiveTickets", function()
    local tickets = net.ReadTable() or {}
    if not IsValid(ticketPanel) then return end
    ticketPanel:Clear()
    ticketPanel:DockPadding(6, 6, 6, 6)
    ticketPanel.Paint = function() end
    local search = ticketPanel:Add("liaEntry")
    search:Dock(TOP)
    search:DockMargin(0, 20, 0, 15)
    search:SetTall(30)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
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

        list:ForceCommit()
        list:InvalidateLayout(true)
        if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
    end

    list:AddMenuOption(L("noOptionsAvailable"), function() end)
    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
end)

net.Receive("liaViewClaims", function()
    local tbl = net.ReadTable()
    local steamid = net.ReadString()
    if steamid and steamid ~= "" and steamid ~= " " then
        local v = tbl[steamid]
        lia.information(L("claimRecordLast", v.name, v.claims, string.NiceTime(os.time() - v.lastclaim)))
    else
        for _, v in pairs(tbl) do
            lia.information(L("claimRecord", v.name, v.claims))
        end
    end
end)

net.Receive("liaTicketSystem", function()
    local pl = net.ReadEntity()
    local msg = net.ReadString()
    local claimed = net.ReadEntity()
    if IsValid(LocalPlayer()) and (LocalPlayer():isStaffOnDuty() or LocalPlayer():hasPrivilege("alwaysSeeTickets")) then CreateTicketFrame(pl, msg, claimed) end
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

net.Receive("liaAllWarnings", function()
    local warnings = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = function() end
    local search = panelRef:Add("liaEntry")
    search:Dock(TOP)
    search:DockMargin(0, 20, 0, 15)
    search:SetTall(30)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
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
        },
        {
            name = L("warningSeverity"),
            field = "severity"
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
            local values = {warn.timestamp or "", warnedDisplay, adminDisplay, warn.message or "", warn.severity or "Medium"}
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

net.Receive("liaPlayerWarnings", function()
    local charID = net.ReadString()
    if not charID or charID == "" then return end
    local warnings = net.ReadTable() or {}
    AdminStickWarnings[charID] = warnings
end)

function MODULE:OnAdminStickMenuClosed()
    local client = LocalPlayer()
    if IsValid(client) and client.AdminStickTarget == client then client.AdminStickTarget = nil end
    AdminStickWarnings = {}
end

function MODULE:AdminStickAddModels(modList)
    local addedModels = {}
    for _, modelData in ipairs(modList) do
        addedModels[modelData.mdl] = true
    end

    local function addModel(modelPath, modelName)
        if not modelPath or modelPath == "" then return end
        if isstring(modelPath) and not addedModels[modelPath] then
            table.insert(modList, {
                name = modelName or modelPath,
                mdl = modelPath
            })

            addedModels[modelPath] = true
        end
    end

    local function processModelData(modelData, defaultName)
        if isstring(modelData) then
            addModel(modelData, defaultName)
        elseif istable(modelData) then
            if modelData[1] and isstring(modelData[1]) then addModel(modelData[1], modelData[2] or defaultName) end
        end
    end

    for _, faction in pairs(lia.faction.teams or {}) do
        if faction.models then
            if istable(faction.models) then
                local hasStringKeys = false
                for k, _ in pairs(faction.models) do
                    if isstring(k) then
                        hasStringKeys = true
                        break
                    end
                end

                if hasStringKeys then
                    for _, categoryModels in pairs(faction.models) do
                        if istable(categoryModels) then
                            for _, modelData in ipairs(categoryModels) do
                                processModelData(modelData, faction.name or "Unknown Faction")
                            end
                        else
                            processModelData(categoryModels, faction.name or "Unknown Faction")
                        end
                    end
                else
                    for _, modelData in ipairs(faction.models) do
                        processModelData(modelData, faction.name or "Unknown Faction")
                    end
                end
            else
                processModelData(faction.models, faction.name or "Unknown Faction")
            end
        end
    end

    for _, class in pairs(lia.class.list or {}) do
        if class.model and isstring(class.model) then addModel(class.model, class.name or "Unknown Class") end
    end
end

local function DisplayAdminStickHUD(client, hudInfos, weapon)
    if not IsValid(weapon) or not weapon.GetTarget then return end
    local target = weapon:GetTarget()
    if IsValid(target) then
        local infoLines = {}
        if not target:IsPlayer() and IsValid(target:GetOwner()) and target:GetOwner():IsPlayer() then target = target:GetOwner() end
        if target:IsPlayer() then
            local char = target:getChar()
            local charName = char and char:getName() or target:Nick()
            local steamName = target:IsBot() and "BOT" or target:SteamName() or ""
            table.insert(infoLines, "Name: " .. charName)
            table.insert(infoLines, "Steam Name: " .. steamName)
            table.insert(infoLines, "Health: " .. target:Health() .. "/" .. target:GetMaxHealth())
            local activeWeapon = target:GetActiveWeapon()
            local weaponName = "None"
            if IsValid(activeWeapon) then weaponName = activeWeapon:GetPrintName() or activeWeapon:GetClass() end
            table.insert(infoLines, "Weapon: " .. weaponName)
            table.insert(infoLines, "User Group: " .. target:GetUserGroup())
            local velocity = target:GetVelocity()
            local speed = math.Round(velocity:Length())
            table.insert(infoLines, "Speed: " .. speed)
        else
            table.insert(infoLines, "Class: " .. target:GetClass())
            local owner = target:GetOwner()
            if IsValid(owner) and owner:IsPlayer() then
                table.insert(infoLines, "Owner: " .. owner:Nick())
            else
                table.insert(infoLines, "Owner: World")
            end

            table.insert(infoLines, "Entity ID: " .. target:EntIndex())
        end

        hook.Run("AddToAdminStickHUD", client, target, infoLines)
        if IsValid(AdminStickMenu) and target:IsPlayer() then
            local char = target:getChar()
            if char then
                local charID = tostring(char:getID())
                if AdminStickWarnings[charID] == nil then
                    AdminStickWarnings[charID] = {}
                    net.Start("liaRequestPlayerWarnings")
                    net.WriteString(charID)
                    net.SendToServer()
                end

                local warnings = AdminStickWarnings[charID]
                if istable(warnings) and #warnings > 0 then
                    table.insert(infoLines, "")
                    table.insert(infoLines, "Warnings (" .. #warnings .. "):")
                    for i, warn in ipairs(warnings) do
                        if i <= 5 then
                            if istable(warn) then
                                local severity = warn.severity or "Medium"
                                local message = warn.message or ""
                                if #message > 30 then message = string.sub(message, 1, 27) .. "..." end
                                table.insert(infoLines, string.format("%d. [%s] %s", i, severity, message))
                            end
                        end
                    end

                    if #warnings > 5 then table.insert(infoLines, "... and " .. (#warnings - 5) .. " more") end
                end
            end
        end

        surface.SetFont("LiliaFont.20")
        local minTextWidth = 0
        for _, line in ipairs(infoLines) do
            local w = select(1, surface.GetTextSize(line))
            minTextWidth = math.max(minTextWidth, w)
        end

        minTextWidth = minTextWidth + 24
        local hudX, hudY, hudAlignX, hudAlignY, hudWidth, hudAutoSize
        local useSidePosition = AdminStickIsOpen
        local cacheValid = AdminStickMenuPositionCache and (AdminStickMenuPositionCache.updateTime or 0) >= (AdminStickMenuOpenTime or 0) - 0.05
        if useSidePosition and cacheValid then
            local menuX = AdminStickMenuPositionCache.x
            local menuY = AdminStickMenuPositionCache.y
            local menuW = AdminStickMenuPositionCache.w
            local menuH = AdminStickMenuPositionCache.h
            hudWidth = math.max(target:IsPlayer() and (menuW * 0.65) or (menuW * 1.2), minTextWidth)
            hudX = menuX - 20 - (hudWidth / 2)
            hudY = menuY + (menuH / 2)
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_CENTER
            hudAutoSize = false
        elseif useSidePosition then
            hudWidth = math.max(target:IsPlayer() and (ScrW() * 0.2) or (ScrW() * 0.28), minTextWidth)
            hudX = ScrW() * 0.25 - (hudWidth / 2)
            hudY = ScrH() * 0.5
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_CENTER
            hudAutoSize = false
        else
            AdminStickMenuPositionCache = nil
            hudX = ScrW() * 0.5
            hudY = IsValid(lia.gui and lia.gui.actionCircle) and (ScrH() - 170) or (ScrH() - 30)
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_BOTTOM
            hudWidth = nil
            hudAutoSize = true
        end

        local bgColor = Color(25, 28, 35, 250)
        local hudInfo = {
            text = infoLines,
            font = "LiliaFont.20",
            color = Color(180, 180, 180),
            position = {
                x = hudX,
                y = hudY
            },
            textAlignX = hudAlignX,
            textAlignY = hudAlignY,
            autoSize = hudAutoSize,
            backgroundColor = bgColor,
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
        }

        if hudWidth and hudWidth > 0 then hudInfo.width = hudWidth end
        table.insert(hudInfos, hudInfo)
    end

    local instructions = {"Left Click: Selects target", "Right Click: Freezes player", "Shift + R: Selects yourself", "R: Clears the selection"}
    table.insert(hudInfos, {
        text = instructions,
        font = "LiliaFont.18",
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

local function DisplayPositionToolHUD(client, hudInfos, weapon)
    local instructions = {"Left Click: Set position at aim", "Right Click: Use current position", "Reload: Cycle mode", "Shift + E: Open removal menu"}
    local typeInfo = weapon.GetPositionToolMode and weapon:GetPositionToolMode()
    if typeInfo and typeInfo.name then table.insert(instructions, 1, "Mode: " .. typeInfo.name) end
    table.insert(hudInfos, {
        text = instructions,
        font = "LiliaFont.18",
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
    local instructions = {"Left Click: Set point", "Right Click: Clear points", "Reload: Measure current"}
    table.insert(hudInfos, {
        text = instructions,
        font = "LiliaFont.18",
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
            font = "LiliaFont.20",
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
            text = "Click to set start point",
            font = "LiliaFont.16",
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
        font = "LiliaFont.20",
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
    if weapon:GetClass() == "lia_adminstick" then
        DisplayAdminStickHUD(client, hudInfos, weapon)
    elseif weapon:GetClass() == "lia_mapconfigurer" then
        DisplayPositionToolHUD(client, hudInfos, weapon)
    elseif weapon:GetClass() == "lia_distance" then
        DisplayDistanceToolHUD(client, hudInfos, weapon)
    end
end
