local receivedPanel
local function OpenLogsUI(panel, categorizedLogs)
    panel:Clear()
    local sheet = panel:Add("DPropertySheet")
    sheet:Dock(FILL)
    sheet:DockMargin(10, 10, 10, 10)
    local function addSizedColumn(list, text)
        local col = list:AddColumn(text)
        surface.SetFont(col.Header:GetFont())
        local w = surface.GetTextSize(col.Header:GetText())
        col:SetMinWidth(w + 16)
        col:SetWidth(w + 16)
        return col
    end
    for category, logs in pairs(categorizedLogs) do
        local page = sheet:Add("DPanel")
        page:Dock(FILL)
        page:DockPadding(10, 10, 10, 10)
        local search = page:Add("DTextEntry")
        search:Dock(TOP)
        search:SetPlaceholderText(L("searchLogs"))
        search:SetTextColor(Color(255, 255, 255))
        local list = page:Add("DListView")
        list:Dock(FILL)
        list:SetMultiSelect(false)
        addSizedColumn(list, L("timestamp"))
        addSizedColumn(list, L("message"))
        addSizedColumn(list, L("steamID"))
        local function populate(filter)
            filter = string.lower(filter or "")
            list:Clear()
            for _, log in ipairs(logs) do
                local msgMatch = string.find(string.lower(log.message), filter, 1, true)
                local idMatch = log.steamID and string.find(string.lower(log.steamID), filter, 1, true)
                if filter == "" or msgMatch or idMatch then
                    local line = list:AddLine(log.timestamp, log.message, log.steamID or "")
                    line.rowData = log
                end
            end
        end
        search.OnChange = function() populate(search:GetValue()) end
        list.OnRowRightClick = function(_, _, line)
            if not IsValid(line) or not line.rowData then return end
            local data = line.rowData
            local menu = DermaMenu()
            if data.steamID and data.steamID ~= "" then menu:AddOption(L("copySteamID"), function() SetClipboardText(data.steamID) end) end
            menu:AddOption(L("copyLogMessage"), function() SetClipboardText(data.message or "") end)
            menu:Open()
        end
        populate("")
        sheet:AddSheet(category, page)
    end
end
lia.net.readBigTable("send_logs", function(categorizedLogs)
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        return
    end
    if IsValid(receivedPanel) then OpenLogsUI(receivedPanel, categorizedLogs) end
end)
function MODULE:PopulateAdminTabs(pages)
    if IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("canSeeLogs") then
        table.insert(pages, {
            name = "logs",
            icon = "icon16/book_open.png",
            drawFunc = function(panel)
                receivedPanel = panel
                net.Start("send_logs_request")
                net.SendToServer()
            end
        })
    end
end
