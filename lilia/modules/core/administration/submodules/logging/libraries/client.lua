net.Receive("send_logs", function()
    local categorizedLogs, err = net.ReadBigTable()
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), "Failed to retrieve logs: " .. err)
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
    logTree.Paint = function() end
    local logList = vgui.Create("DListView", logFrame)
    logList:SetPos(420, 70)
    logList:SetSize(1170, 520)
    logList:AddColumn("Timestamp"):SetFixedWidth(150)
    logList:AddColumn("Message")
    local searchBox = vgui.Create("DTextEntry", logFrame)
    searchBox:SetPos(420, 30)
    searchBox:SetSize(1170, 30)
    searchBox:SetPlaceholderText("Search logs in the selected category...")
    searchBox:SetTextColor(Color(255, 255, 255))
    local copyButton = vgui.Create("DButton", logFrame)
    copyButton:SetText("Copy Selected Row")
    copyButton:SetPos(10, 600)
    copyButton:SetSize(400, 40)
    local treeNodes = {}
    local currentCategoryLogs = {}
    for category, _ in pairs(categorizedLogs) do
        local node = logTree:AddNode(category)
        if node.Label then node.Label:SetTextColor(Color(255, 255, 255)) end
        treeNodes[category] = node
    end

    logTree.OnNodeSelected = function(_, node)
        logList:Clear()
        local selectedCategory = node:GetText()
        local logs = categorizedLogs[selectedCategory]
        currentCategoryLogs = logs or {}
        if logs then
            for _, log in ipairs(logs) do
                local line = logList:AddLine(log.timestamp, log.message)
                if line.Columns then
                    for i = 1, #line.Columns do
                        line.Columns[i]:SetTextColor(Color(255, 255, 255))
                    end
                end
            end
        end
    end

    searchBox.OnChange = function()
        local searchQuery = string.lower(searchBox:GetValue())
        logList:Clear()
        if searchQuery ~= "" and #currentCategoryLogs > 0 then
            for _, log in ipairs(currentCategoryLogs) do
                if string.find(string.lower(log.message), searchQuery, 1, true) then
                    local line = logList:AddLine(log.timestamp, log.message)
                    if line.Columns then
                        for i = 1, #line.Columns do
                            line.Columns[i]:SetTextColor(Color(255, 255, 255))
                        end
                    end
                end
            end
        elseif #currentCategoryLogs > 0 then
            for _, log in ipairs(currentCategoryLogs) do
                local line = logList:AddLine(log.timestamp, log.message)
                if line.Columns then
                    for i = 1, #line.Columns do
                        line.Columns[i]:SetTextColor(Color(255, 255, 255))
                    end
                end
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