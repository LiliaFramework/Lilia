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
