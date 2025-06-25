local receivedChunks = {}
local receivedPanel
net.Receive("send_logs", function()
    local chunkIndex = net.ReadUInt(16)
    local numChunks = net.ReadUInt(16)
    local chunkLen = net.ReadUInt(16)
    local chunkData = net.ReadData(chunkLen)
    receivedChunks[chunkIndex] = chunkData
    for i = 1, numChunks do
        if not receivedChunks[i] then return end
    end

    local fullData = table.concat(receivedChunks)
    receivedChunks = {}
    local jsonData = util.Decompress(fullData)
    local categorizedLogs = util.JSONToTable(jsonData)
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        return
    end

    if IsValid(receivedPanel) then OpenLogsUI(receivedPanel, categorizedLogs) end
end)

function OpenLogsUI(panel, categorizedLogs)
    panel:Clear()
    local sidebar = panel:Add("DScrollPanel")
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar:DockMargin(20, 20, 0, 20)
    local contentPanel = panel:Add("DPanel")
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(10, 10, 10, 10)
    local search = contentPanel:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("searchLogs"))
    search:SetTextColor(Color(255, 255, 255))
    local list = contentPanel:Add("DListView")
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn(L("timestamp")):SetFixedWidth(150)
    list:AddColumn(L("logMessage"))
    local copyButton = contentPanel:Add("liaMediumButton")
    copyButton:Dock(BOTTOM)
    copyButton:SetText(L("copySelectedRow"))
    copyButton:SetTall(40)
    local currentLogs = {}
    local selectedButton
    for category, logs in pairs(categorizedLogs) do
        local btn = sidebar:Add("liaMediumButton")
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 10)
        btn:SetTall(40)
        btn:SetText(category)
        btn.DoClick = function()
            if IsValid(selectedButton) then selectedButton:SetSelected(false) end
            btn:SetSelected(true)
            selectedButton = btn
            list:Clear()
            currentLogs = logs
            for _, log in ipairs(logs) do
                list:AddLine(log.timestamp, log.message)
            end
        end
    end

    search.OnChange = function()
        local query = string.lower(search:GetValue())
        list:Clear()
        for _, log in ipairs(currentLogs) do
            if query == "" or string.find(string.lower(log.message), query, 1, true) then list:AddLine(log.timestamp, log.message) end
        end
    end

    copyButton.DoClick = function()
        local sel = list:GetSelectedLine()
        if sel then
            local line = list:GetLine(sel)
            SetClipboardText("[" .. line:GetColumnText(1) .. "] " .. line:GetColumnText(2))
        end
    end

    local firstCategory = next(categorizedLogs)
    if firstCategory then
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:GetText() == firstCategory then
                btn:DoClick()
                break
            end
        end
    end
end

function MODULE:CreateMenuButtons(tabs)
    if IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("Staff Permissions - Can See Logs") then
        tabs[L("logs")] = function(panel)
            receivedPanel = panel
            net.Start("send_logs_request")
            net.SendToServer()
        end
    end
end
