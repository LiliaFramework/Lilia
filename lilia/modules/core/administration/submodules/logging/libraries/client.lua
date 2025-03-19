local receivedChunks = {}
net.Receive("send_logs", function()
    local chunkIndex = net.ReadUInt(16)
    local numChunks = net.ReadUInt(16)
    local chunkLen = net.ReadUInt(16)
    local chunkData = net.ReadData(chunkLen)
    receivedChunks[chunkIndex] = chunkData
    local allReceived = true
    for i = 1, numChunks do
        if not receivedChunks[i] then
            allReceived = false
            break
        end
    end

    if allReceived then
        local fullData = table.concat(receivedChunks)
        local jsonData = util.Decompress(fullData)
        local categorizedLogs, err = util.JSONToTable(jsonData)
        if not categorizedLogs then
            chat.AddText(Color(255, 0, 0), "Failed to retrieve logs: " .. (err or "unknown error"))
            return
        end

        gui.EnableScreenClicker(true)
        local logFrame = vgui.Create("DFrame")
        logFrame:SetTitle("Server Logs")
        logFrame:SetSize(ScrW(), ScrH())
        logFrame:Center()
        logFrame:MakePopup()
        logFrame.OnClose = function() gui.EnableScreenClicker(false) end
        local logTree = vgui.Create("DTree", logFrame)
        logTree:SetPos(10, 30)
        logTree:SetSize(400, 560)
        logTree.Paint = function() end
        local logList = vgui.Create("DListView", logFrame)
        logList:SetPos(420, 70)
        logList:SetSize(ScrW() - 440, ScrH() - 100)
        logList:AddColumn("Timestamp"):SetFixedWidth(150)
        logList:AddColumn("Message")
        local searchBox = vgui.Create("DTextEntry", logFrame)
        searchBox:SetPos(420, 30)
        searchBox:SetSize(ScrW() - 440, 30)
        searchBox:SetPlaceholderText("Search logs in the selected category...")
        searchBox:SetTextColor(Color(255, 255, 255))
        local copyButton = vgui.Create("DButton", logFrame)
        copyButton:SetText("Copy Selected Row")
        copyButton:SetPos(10, ScrH() - 90)
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

        receivedChunks = {}
    end
end)

function MODULE:CreateMenuButtons(tabs)
    if LocalPlayer():hasPrivilege("Staff Permissions - Can See Logs") then
        tabs["Logs"] = function()
            net.Start("send_logs_request")
            net.SendToServer()
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
        end
    end
end
