local receivedPanel
local function OpenLogsUI(panel, categorizedLogs)
    panel:Clear()
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    local sheet = panel:Add("liaTabs")
    sheet:Dock(FILL)
    for category, logs in pairs(categorizedLogs) do
        local page = vgui.Create("DPanel")
        page:Dock(FILL)
        page:DockPadding(10, 10, 10, 10)
        page.Paint = nil
        local search = page:Add("DTextEntry")
        search:Dock(TOP)
        search:DockMargin(0, 0, 0, 15)
        search:SetTall(30)
        search:SetPlaceholderText(L("searchLogs"))
        search:SetTextColor(Color(200, 200, 200))
        search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local list = page:Add("liaTable")
        list:Dock(FILL)
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
        function list:OnRowRightClick(_, line)
            if not IsValid(line) or not line.rowData then return end
            local data = line.rowData
            local menu = lia.derma.dermaMenu()
            if data.steamID and data.steamID ~= "" then menu:AddOption(L("copySteamID"), function() SetClipboardText(data.steamID) end):SetIcon("icon16/page_copy.png") end
            menu:AddOption(L("copyLogMessage"), function() SetClipboardText(data.message or "") end):SetIcon("icon16/page_copy.png")
            menu:Open()
        end

        populate("")
        sheet:AddSheet(category, page)
    end
end

lia.net.readBigTable("liaSendLogs", function(categorizedLogs)
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
                net.Start("liaSendLogsRequest")
                net.SendToServer()
            end
        })
    end
end
