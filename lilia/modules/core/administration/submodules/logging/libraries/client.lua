net.Receive("send_logs", function()
    local categorizedLogs = net.ReadTable()
    if not categorizedLogs then
        chat.AddText(Color(255, 0, 0), "No logs available.")
        return
    end

    gui.EnableScreenClicker(true)
    local logFrame = vgui.Create("DFrame")
    logFrame:SetTitle("Server Logs")
    logFrame:SetSize(1600, 600)
    logFrame:Center()
    logFrame:MakePopup()
    logFrame.OnClose = function() gui.EnableScreenClicker(false) end
    local logTree = vgui.Create("DTree", logFrame)
    logTree:SetPos(10, 30)
    logTree:SetSize(400, 560)
    local logList = vgui.Create("DListView", logFrame)
    logList:SetPos(420, 30)
    logList:SetSize(1170, 560)
    logList:AddColumn("Timestamp"):SetFixedWidth(150)
    logList:AddColumn("Message")
    local treeNodes = {}
    for category, _ in pairs(categorizedLogs) do
        local node = logTree:AddNode(category)
        treeNodes[category] = node
    end

    logTree.OnNodeSelected = function(_, node)
        logList:Clear()
        local selectedCategory = node:GetText()
        local logs = categorizedLogs[selectedCategory]
        if logs then
            for _, log in ipairs(logs) do
                logList:AddLine(log.timestamp, log.message)
            end
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