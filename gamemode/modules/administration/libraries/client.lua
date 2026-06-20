local MODULE = MODULE
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

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canViewStaffManagement = client:hasPrivilege("viewStaffManagement")
    if canViewStaffManagement then
        table.insert(pages, {
            name = "@moduleStaffManagementName",
            icon = "icon16/shield.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestStaffSummary")
                net.SendToServer()
            end
        })
    end

    local canAccessPlayerList = client:hasPrivilege("canAccessPlayerList")
    if canAccessPlayerList then
        table.insert(pages, {
            name = "@players",
            icon = "icon16/user.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestPlayers")
                net.SendToServer()
            end
        })
    end

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

    local canManageFlags = client:hasPrivilege("manageFlags")
    if canManageFlags then
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

    local canManageCharacters = client:hasPrivilege("manageCharacters")
    if canManageCharacters then
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
    list:AddMenuOption(L("viewWarnings"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewwarns") then LocalPlayer():ConCommand("say /viewwarns " .. rowData.steamID) end end, "icon16/error.png")
    list:AddMenuOption(L("viewTicketRequests"), function(rowData) if rowData.steamID and lia.command.hasAccess(LocalPlayer(), "viewtickets") then LocalPlayer():ConCommand("say /viewtickets " .. rowData.steamID) end end, "icon16/help.png")
    search.OnTextChanged = function(_, value) populate(value or "") end
    populate("")
end)

lia.net.readBigTable("liaFullCharList", function(data)
    if not IsValid(panelRef) or not data or not isfunction(panelRef.buildSheets) then return end
    panelRef:buildSheets(data)
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
