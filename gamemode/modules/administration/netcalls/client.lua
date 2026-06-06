lia.mapConfigurerState = lia.mapConfigurerState or {
    modeIndex = 1,
    cachedPositions = {},
    cacheType = nil,
    lastRequest = 0,
    removalMenuOpen = false
}

net.Receive("liaFeaturePositions", function()
    local typeId = net.ReadString()
    local count = net.ReadUInt(16)
    local list = {}
    for i = 1, count do
        local pos = net.ReadVector()
        local label = net.ReadString()
        list[#list + 1] = {
            pos = pos,
            label = label
        }
    end

    lia.mapConfigurerState.cacheType = typeId
    lia.mapConfigurerState.cachedPositions = list
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

    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()
    d:catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
end)

net.Receive("liaManagesitrooms", function()
    local rooms = net.ReadTable() or {}
    local frame = vgui.Create("liaFrame")
    frame:SetTitle(L("manageSitRooms"))
    frame:SetSize(640, 420)
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
