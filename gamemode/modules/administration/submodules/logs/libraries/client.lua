function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canSeeLogs = client:hasPrivilege("canSeeLogs")
    if canSeeLogs then
        table.insert(pages, {
            name = "logs",
            icon = "icon16/book_open.png",
            drawFunc = function(panel)
                if not panel.liaLogsPanel then
                    panel.liaLogsPanel = panel
                    liaLogsPanel = panel
                    panel:Clear()
                    panel:DockPadding(6, 6, 6, 6)
                    panel.Paint = nil
                    net.Start("liaSendLogsCategoriesRequest")
                    net.SendToServer()
                end
            end
        })
    end
end

local currentCategoryData = {}
function MODULE:CreateLogsUI(panel, categories)
    panel:Clear()
    currentCategoryData = {}
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    if not categories or #categories == 0 then
        local noLogsLabel = panel:Add("DLabel")
        noLogsLabel:Dock(FILL)
        noLogsLabel:SetText(L("noLogsAvailable"))
        noLogsLabel:SetTextColor(Color(150, 150, 150))
        noLogsLabel:SetFont("LiliaFont.20")
        noLogsLabel:SetContentAlignment(5)
        return
    end

    local sheet = panel:Add("liaTabs")
    sheet:Dock(FILL)
    local function requestLogsForCategory(category)
        if not category or not currentCategoryData[category] then return end
        local pagePanel = currentCategoryData[category].panel
        if not IsValid(pagePanel) then return end
        if IsValid(pagePanel.loadingLabel) then
            pagePanel.loadingLabel:Remove()
            pagePanel.loadingLabel = nil
        end

        for _, child in ipairs(pagePanel:GetChildren()) do
            child:Remove()
        end

        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        net.Start("liaSendLogsRequest")
        net.WriteString(category)
        net.WriteUInt(currentCategoryData[category].currentPage, 16)
        net.SendToServer()
    end

    for _, category in ipairs(categories) do
        local pagePanel = vgui.Create("DPanel")
        pagePanel:Dock(FILL)
        pagePanel:DockPadding(10, 10, 10, 10)
        pagePanel.Paint = nil
        pagePanel.category = category
        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        currentCategoryData[category] = {
            panel = pagePanel,
            currentPage = 1,
            totalPages = 1,
            logs = {},
            searchFilter = ""
        }

        sheet:AddTab(category, pagePanel, nil, function() requestLogsForCategory(category) end)
    end

    local oldSetActiveTab = sheet.SetActiveTab
    sheet.SetActiveTab = function(self, tabIndex)
        oldSetActiveTab(self, tabIndex)
        local activeTab = self.tabs[tabIndex]
        if activeTab and activeTab.pan then
            local category = activeTab.pan.category
            requestLogsForCategory(category)
        end
    end

    if sheet.tabs and #sheet.tabs > 0 then sheet:SetActiveTab(1) end
    panel.logsSheet = sheet
end

local function UpdateLogsUI(panel, logsData)
    local category = logsData and logsData.category
    if not category then
        if IsValid(panel) and panel.logsSheet and panel.logsSheet.tabs then
            local activeId = panel.logsSheet.active_id or 1
            local activeTab = panel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
        return
    end

    if not currentCategoryData[category] then
        if IsValid(panel) and panel.logsSheet and panel.logsSheet.tabs then
            for _, tab in ipairs(panel.logsSheet.tabs) do
                if tab.pan and tab.pan.category == category and IsValid(tab.pan.loadingLabel) then
                    tab.pan.loadingLabel:Remove()
                    tab.pan.loadingLabel = nil
                end
            end

            local activeId = panel.logsSheet.active_id or 1
            local activeTab = panel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
        return
    end

    local categoryData = currentCategoryData[category]
    if not categoryData then return end
    local pagePanel = categoryData.panel
    if not IsValid(pagePanel) then return end
    if IsValid(pagePanel.loadingLabel) then
        pagePanel.loadingLabel:Remove()
        pagePanel.loadingLabel = nil
    end

    for _, child in ipairs(pagePanel:GetChildren()) do
        if child ~= pagePanel.loadingLabel then child:Remove() end
    end

    categoryData.currentPage = logsData.currentPage or 1
    categoryData.totalPages = logsData.totalPages or 1
    categoryData.logs = logsData.logs or {}
    local searchBox = pagePanel:Add("liaEntry")
    searchBox:Dock(TOP)
    searchBox:DockMargin(0, 0, 0, 15)
    searchBox:SetTall(30)
    searchBox:SetFont("LiliaFont.17")
    searchBox:SetPlaceholderText(L("searchLogs"))
    searchBox:SetTextColor(Color(200, 200, 200))
    searchBox:SetText(categoryData.searchFilter)
    local paginationContainer = pagePanel:Add("DPanel")
    paginationContainer:Dock(BOTTOM)
    paginationContainer:DockMargin(0, 15, 0, 0)
    paginationContainer:SetTall(30)
    paginationContainer.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(0, 0, 0, 50)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local prevButton = paginationContainer:Add("liaButton")
    prevButton:Dock(LEFT)
    prevButton:SetWide(80)
    prevButton:SetText(L("previousPage"))
    prevButton:DockMargin(5, 5, 5, 5)
    local pageLabel = paginationContainer:Add("DLabel")
    pageLabel:Dock(FILL)
    pageLabel:DockMargin(10, 5, 10, 5)
    pageLabel:SetTextColor(Color(200, 200, 200))
    pageLabel:SetFont("LiliaFont.16")
    pageLabel:SetContentAlignment(5)
    local nextButton = paginationContainer:Add("liaButton")
    nextButton:Dock(RIGHT)
    nextButton:SetWide(80)
    nextButton:SetText(L("next"))
    nextButton:DockMargin(5, 5, 5, 5)
    local list = pagePanel:Add("liaTable")
    list:Dock(FILL)
    list:DockMargin(0, 0, 0, 10)
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

    list:AddMenuOption(L("copySteamID"), function(rowData) if rowData[3] and rowData[3] ~= "" then SetClipboardText(tostring(rowData[3])) end end, "icon16/page_copy.png")
    list:AddMenuOption(L("copyLogMessage"), function(rowData) SetClipboardText(tostring(rowData[2] or "")) end, "icon16/page_copy.png")
    local function updatePagination()
        pageLabel:SetText(L("pageIndicator", categoryData.currentPage, categoryData.totalPages))
        prevButton:SetDisabled(categoryData.currentPage <= 1)
        nextButton:SetDisabled(categoryData.currentPage >= categoryData.totalPages)
        prevButton:SetTextColor(categoryData.currentPage <= 1 and Color(100, 100, 100) or Color(200, 200, 200))
        nextButton:SetTextColor(categoryData.currentPage >= categoryData.totalPages and Color(100, 100, 100) or Color(200, 200, 200))
    end

    local function showCurrentPage()
        list:Clear()
        local searchFilter = string.lower(categoryData.searchFilter or "")
        local filteredLogs = categoryData.logs
        if searchFilter ~= "" then
            filteredLogs = {}
            for _, log in ipairs(categoryData.logs) do
                local timestamp = string.lower(tostring(log.timestamp or ""))
                local message = string.lower(tostring(log.message or ""))
                local steamID = string.lower(tostring(log.steamID or ""))
                if string.find(timestamp, searchFilter, 1, true) or string.find(message, searchFilter, 1, true) or string.find(steamID, searchFilter, 1, true) then table.insert(filteredLogs, log) end
            end
        end

        for _, log in ipairs(filteredLogs) do
            local line = list:AddLine(log.timestamp, log.message, log.steamID or "")
            line.rowData = log
        end

        list:ForceCommit()
    end

    local function requestPage(pageNum)
        if pageNum >= 1 and pageNum <= categoryData.totalPages then
            categoryData.currentPage = pageNum
            net.Start("liaSendLogsRequest")
            net.WriteString(category)
            net.WriteUInt(pageNum, 16)
            net.SendToServer()
        end
    end

    searchBox.OnTextChanged = function(_, value)
        categoryData.searchFilter = value or ""
        showCurrentPage()
    end

    prevButton.DoClick = function() requestPage(categoryData.currentPage - 1) end
    nextButton.DoClick = function() requestPage(categoryData.currentPage + 1) end
    updatePagination()
    showCurrentPage()
    list:ForceCommit()
    list:InvalidateLayout(true)
    if list.scrollPanel then list.scrollPanel:InvalidateLayout(true) end
end

liaLogsPanel = liaLogsPanel or nil

lia.net.readBigTable("liaSendLogs", function(logsData)
    local logsPanel = liaLogsPanel
    if not IsValid(logsPanel) then
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(panel) and panel.liaLogsPanel then
                logsPanel = panel.liaLogsPanel
                liaLogsPanel = logsPanel
                break
            end
        end
    end

    local function removeLoadingLabel()
        if IsValid(logsPanel) and logsPanel.logsSheet and logsPanel.logsSheet.tabs then
            local activeId = logsPanel.logsSheet.active_id or 1
            local activeTab = logsPanel.logsSheet.tabs[activeId]
            if activeTab and activeTab.pan and IsValid(activeTab.pan.loadingLabel) then
                activeTab.pan.loadingLabel:Remove()
                activeTab.pan.loadingLabel = nil
            end
        end
    end

    if not logsData then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        removeLoadingLabel()
        return
    end

    if IsValid(logsPanel) then
        local success, err = pcall(UpdateLogsUI, logsPanel, logsData)
        if not success then
            chat.AddText(Color(255, 0, 0), L("logsUIUpdateError", tostring(err)))
            removeLoadingLabel()
        end
    else
        chat.AddText(Color(255, 100, 100), L("logsPanelError"))
    end
end)

