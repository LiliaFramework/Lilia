net.Receive("send_logs", function()
    local length = net.ReadUInt(32)
    local compressedData = net.ReadData(length)
    local jsonData = util.Decompress(compressedData)
    if not jsonData then
        chat.AddText(Color(255, 0, 0), "Failed to decompress log data.")
        return
    end

    local categorizedLogs = util.JSONToTable(jsonData)
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), "Failed to parse log data.")
        return
    end

    gui.EnableScreenClicker(true)
    local logFrame = vgui.Create("DFrame")
    logFrame:SetTitle("Server Logs")
    logFrame:SetSize(1600, 700)
    logFrame:Center()
    logFrame:MakePopup()
    logFrame.OnClose = function() gui.EnableScreenClicker(false) end
    local logTree = vgui.Create("DTree", logFrame)
    logTree:SetPos(10, 30)
    logTree:SetSize(400, 560)
    local logList = vgui.Create("DListView", logFrame)
    logList:SetPos(420, 70)
    logList:SetSize(1170, 520)
    logList:AddColumn("Timestamp"):SetFixedWidth(150)
    logList:AddColumn("Message")
    local searchBox = vgui.Create("DTextEntry", logFrame)
    searchBox:SetPos(420, 30)
    searchBox:SetSize(1170, 30)
    searchBox:SetPlaceholderText("Search logs in the selected category...")
    local copyButton = vgui.Create("DButton", logFrame)
    copyButton:SetText("Copy Selected Row")
    copyButton:SetPos(10, 600)
    copyButton:SetSize(400, 40)
    local treeNodes = {}
    local currentCategoryLogs = {}
    for category, _ in pairs(categorizedLogs) do
        local node = logTree:AddNode(category)
        treeNodes[category] = node
    end

    logTree.OnNodeSelected = function(_, node)
        logList:Clear()
        local selectedCategory = node:GetText()
        local logs = categorizedLogs[selectedCategory]
        currentCategoryLogs = logs or {}
        if logs then
            for _, log in ipairs(logs) do
                logList:AddLine(log.timestamp, log.message)
            end
        end
    end

    searchBox.OnChange = function()
        local searchQuery = string.lower(searchBox:GetValue())
        logList:Clear()
        if searchQuery ~= "" and #currentCategoryLogs > 0 then
            for _, log in ipairs(currentCategoryLogs) do
                if string.find(string.lower(log.message), searchQuery, 1, true) then logList:AddLine(log.timestamp, log.message) end
            end
        elseif #currentCategoryLogs > 0 then
            for _, log in ipairs(currentCategoryLogs) do
                logList:AddLine(log.timestamp, log.message)
            end
        end
    end

    copyButton.DoClick = function()
        local selectedLine = logList:GetSelectedLine()
        if selectedLine then
            local line = logList:GetLine(selectedLine)
            local timestamp = line:GetColumnText(1)
            local message = line:GetColumnText(2)
            local rowText = "[" .. timestamp .. "] " .. message
            SetClipboardText(rowText)
        end
    end

    local firstCategory = next(categorizedLogs)
    if firstCategory then
        local firstNode = treeNodes[firstCategory]
        if firstNode then
            firstNode:SetExpanded(true)
            firstNode:DoClick()
        end
    end
end)