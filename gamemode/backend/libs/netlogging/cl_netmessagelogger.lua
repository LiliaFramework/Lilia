local isOpen = false
local logList

local function fillLogs(listview, logs)
    listview:Clear()

    for _, curLog in pairs(logs) do
        listview:AddLine(curLog.time, curLog.name, curLog.ply, curLog.steamID, curLog.len, curLog.source, curLog.ip)
    end
end

local function requestLogs(page)
    net.Start("net_RequestLogs")
    net.WriteInt(page, 32)
    net.SendToServer()
end

local function displayLogs(logs, amtOfPages)
    local results
    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("Net Message Logs")

    frame.OnClose = function()
        isOpen = false
        logList = nil
    end

    logList = vgui.Create("DListView", frame)
    logList:DockMargin(0, 0, 0, 30)
    logList:Dock(FILL)
    logList:AddColumn("Date")
    logList:AddColumn("Net Message Name")
    logList:AddColumn("Sending Player")
    logList:AddColumn("Player's SteamID")
    logList:AddColumn("Length in Bytes")
    logList:AddColumn("Source Path")
    logList:AddColumn("Player's IP Address")

    logList.OnRowRightClick = function(self, lineID, line)
        local menu = DermaMenu(frame)
        menu:MakePopup()
        menu:SetPos(input.GetCursorPos())

        menu:AddOption("Copy player name", function()
            SetClipboardText(line:GetColumnText(3))
        end)

        menu:AddOption("Copy player steamID", function()
            SetClipboardText(line:GetColumnText(4))
        end)

        menu:AddOption("Copy player IP address", function()
            SetClipboardText(line:GetColumnText(7))
        end)

        menu:AddOption("Copy source path", function()
            SetClipboardText(line:GetColumnText(6))
        end)

        menu:AddOption("Copy net message name", function()
            SetClipboardText(line:GetColumnText(2))
        end)
    end

    isOpen = true
    local curPage = 1
    fillLogs(logList, results or logs)
    local nextButton = vgui.Create("DButton", frame)
    nextButton:SetText(">")
    nextButton:SetPos(790 - nextButton:GetWide(), 590 - nextButton:GetTall())
    local prevButton = vgui.Create("DButton", frame)
    prevButton:SetText("<")
    prevButton:SetPos(10, 590 - prevButton:GetTall())
    local pages = vgui.Create("DLabel", frame)
    pages:SetText(curPage .. "/" .. amtOfPages)
    pages:SetColor(Color(200, 200, 200, 255))
    pages:SizeToContents()
    pages:MoveBelow(prevButton, -prevButton:GetTall())
    pages:MoveRightOf(prevButton)

    nextButton.DoClick = function(self)
        if curPage == amtOfPages then return end
        curPage = curPage + 1
        requestLogs(curPage)
        pages:SetText(curPage .. "/" .. amtOfPages)
        pages:SizeToContents()
    end

    prevButton.DoClick = function(self)
        if curPage == 1 then return end
        curPage = curPage - 1
        requestLogs(curPage)
        pages:SetText(curPage .. "/" .. amtOfPages)
        pages:SizeToContents()
    end

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:SetWide(500)
    searchBox:SetPos(0, 590 - searchBox:GetTall())
    searchBox:CenterHorizontal()
    searchBox:SetPlaceholderText("Search...")

    searchBox.OnEnter = function(self)
        local searchTerm = searchBox:GetText()
        results = nil

        if searchTerm == "" then
            fillLogs(logList, logs)

            return
        end

        results = {}

        for k, v in pairs(logs) do
            for _, j in pairs(v) do
                if string.match(string.lower(j), searchTerm) then
                    table.insert(results, v)
                    break
                end
            end
        end

        fillLogs(logList, results)
        results = nil
    end
end

net.Receive("net_ReceiveLogs", function()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local amtOfPages = net.ReadInt(32)
    data = util.Decompress(data)
    local tab = util.JSONToTable(data)

    if isOpen then
        fillLogs(logList, tab)
    else
        displayLogs(tab, amtOfPages)
    end
end)