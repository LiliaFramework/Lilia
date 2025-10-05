local MODULE = MODULE
MODULE.CharacterInformation = {}
function MODULE:LoadCharInformation()
    hook.Run("AddSection", L("generalInfo"), Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", L("generalInfo"), "name", L("name"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getName() or L("unknown")
    end)

    hook.Run("AddTextField", L("generalInfo"), "desc", L("description"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getDesc() or ""
    end)

    hook.Run("AddTextField", L("generalInfo"), "money", L("money"), function()
        local client = LocalPlayer()
        return client and lia.currency.get(client:getChar():getMoney()) or lia.currency.get(0)
    end)
end

function MODULE:AddSection(sectionName, color, priority, location)
    hook.Run("F1OnAddSection", sectionName, color, priority, location)
    local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
    if not self.CharacterInformation[localizedSectionName] then
        self.CharacterInformation[localizedSectionName] = {
            fields = {},
            color = color or Color(255, 255, 255),
            priority = priority or 999,
            location = location or 1
        }
    else
        local info = self.CharacterInformation[localizedSectionName]
        info.color = color or info.color
        info.priority = priority or info.priority
        info.location = location or info.location
    end
end

function MODULE:AddTextField(sectionName, fieldName, labelText, valueFunc)
    hook.Run("F1OnAddTextField", sectionName, fieldName, labelText, valueFunc)
    local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
    local localizedLabel = isstring(labelText) and L(labelText) or labelText
    local section = self.CharacterInformation[localizedSectionName]
    if section then
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then return end
        end

        table.insert(section.fields, {
            type = "text",
            name = fieldName,
            label = localizedLabel,
            value = valueFunc or function() return "" end
        })
    end
end

function MODULE:AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    hook.Run("F1OnAddBarField", sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
    local localizedLabel = isstring(labelText) and L(labelText) or labelText
    local section = self.CharacterInformation[localizedSectionName]
    if section then
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then return end
        end

        table.insert(section.fields, {
            type = "bar",
            name = fieldName,
            label = localizedLabel,
            min = minFunc or function() return 0 end,
            max = maxFunc or function() return 100 end,
            value = valueFunc or function() return 0 end
        })
    end
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end

function MODULE:CreateMenuButtons(tabs)
    tabs["you"] = function(statusPanel)
        statusPanel.info = vgui.Create("liaCharInfo", statusPanel)
        statusPanel.info:Dock(FILL)
        statusPanel.info:setup()
        statusPanel.info:SetAlpha(0)
        statusPanel.info:AlphaTo(255, 0.5)
    end

    tabs["information"] = function(infoTabPanel)
        -- Create a custom frame instead of DPropertySheet
        local frame = infoTabPanel:Add("liaFrame")
        frame:Dock(FILL)
        frame:DockMargin(10, 10, 10, 10)
        frame:SetTitle(L("information"))
        frame:LiteMode() -- Use lite mode for cleaner look
        frame:DisableCloseBtn() -- Remove close button from information tab
        local pages = {}
        hook.Run("CreateInformationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
            return an < bn
        end)

        -- Create tab container and content area
        local tabContainer = vgui.Create("DPanel", frame)
        tabContainer:Dock(TOP)
        tabContainer:SetTall(40)
        tabContainer.Paint = function() end
        local contentArea = vgui.Create("DPanel", frame)
        contentArea:Dock(FILL)
        contentArea.Paint = function() end
        local activeTab = 1
        local tabButtons = {}
        local tabPanels = {}
        local baseTabWidths = {}
        local baseMargin = 8
        -- Calculate base tab widths first
        for i, page in ipairs(pages) do
            surface.SetFont("Fated.18")
            local textWidth = surface.GetTextSize(L(page.name))
            local iconWidth = 0 -- Disable icons for information tabs
            local padding = 20
            local minWidth = 80
            local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
            baseTabWidths[i] = btnWidth
        end

        -- Create tab buttons and panels
        for i, page in ipairs(pages) do
            -- Create tab button using the new liaTabButton panel
            local tabButton = vgui.Create("liaTabButton", tabContainer)
            tabButton:Dock(LEFT)
            tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
            tabButton:SetTall(36)
            tabButton:SetText(L(page.name))
            tabButton:SetActive(i == 1) -- First tab is active by default
            -- Set base width initially (will be adjusted in PerformLayout)
            tabButton:SetWide(baseTabWidths[i] or 80)
            tabButton:SetDoClick(function()
                if activeTab == i then return end
                -- Hide current panel
                if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                -- Show new panel
                activeTab = i
                tabPanels[i]:SetVisible(true)
                -- Update button states - set active state for the new button
                for j, btn in ipairs(tabButtons) do
                    if IsValid(btn) then btn:SetActive(j == i) end
                end

                surface.PlaySound("buttons/button14.wav")
                -- Call the page's draw function if it exists
                if page.drawFunc then page.drawFunc(tabPanels[i]) end
            end)

            tabButtons[i] = tabButton
            -- Create content panel for this tab
            local contentPanel = vgui.Create("DPanel", contentArea)
            contentPanel:Dock(TOP)
            contentPanel:SetVisible(i == 1)
            contentPanel.Paint = function() end
            -- Override PerformLayout to set proper height after parent layout is complete
            contentPanel.PerformLayout = function(s)
                if IsValid(frame) and IsValid(tabContainer) then
                    s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) -- Account for margins
                end
            end

            tabPanels[i] = contentPanel
        end

        -- Function to adjust tab widths based on available space
        local function AdjustTabWidths()
            if not IsValid(tabContainer) then return end
            local totalTabsWidth = 0
            for _, width in pairs(baseTabWidths) do
                totalTabsWidth = totalTabsWidth + width
            end

            local availableWidth = tabContainer:GetWide()
            local totalMargins = baseMargin * (#pages - 1)
            local extraSpace = availableWidth - totalTabsWidth - totalMargins
            if extraSpace > 0 and #pages > 1 then
                -- Distribute extra space evenly among tabs
                local extraPerTab = math.floor(extraSpace / #pages)
                local adjustedWidths = {}
                for tabId, baseWidth in pairs(baseTabWidths) do
                    adjustedWidths[tabId] = baseWidth + extraPerTab
                end

                -- Handle remainder
                local remainder = extraSpace % #pages
                if remainder > 0 then
                    for remainderId = 1, math.min(remainder, #pages) do
                        adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                    end
                end

                -- Apply new widths to existing buttons
                for childId, child in ipairs(tabContainer:GetChildren()) do
                    if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                end
            end
        end

        -- Override tab container PerformLayout to adjust tab widths
        local originalPerformLayout = tabContainer.PerformLayout
        tabContainer.PerformLayout = function(s, w, h)
            if originalPerformLayout then originalPerformLayout(s, w, h) end
            -- Adjust tab widths after layout
            timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
        end

        -- Initialize first tab
        if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
    end

    tabs["settings"] = function(settingsPanel)
        -- Create a custom frame instead of DPropertySheet
        local frame = settingsPanel:Add("liaFrame")
        frame:Dock(FILL)
        frame:DockMargin(10, 10, 10, 10)
        frame:SetTitle(L("settings"))
        frame:LiteMode() -- Use lite mode for cleaner look
        frame:DisableCloseBtn() -- Remove close button from settings tab
        local pages = {}
        hook.Run("PopulateConfigurationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
            return an < bn
        end)

        -- Create tab container and content area
        local tabContainer = vgui.Create("DPanel", frame)
        tabContainer:Dock(TOP)
        tabContainer:SetTall(40)
        tabContainer.Paint = function() end
        local contentArea = vgui.Create("liaScrollPanel", frame)
        contentArea:Dock(FILL)
        local activeTab = 1
        local tabButtons = {}
        local tabPanels = {}
        local baseTabWidths = {}
        local baseMargin = 8
        -- Calculate base tab widths first
        for i, page in ipairs(pages) do
            surface.SetFont("Fated.18")
            local textWidth = surface.GetTextSize(L(page.name))
            local iconWidth = 0 -- Disable icons for settings tabs
            local padding = 20
            local minWidth = 80
            local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
            baseTabWidths[i] = btnWidth
        end

        -- Create tab buttons and panels
        for i, page in ipairs(pages) do
            -- Create tab button using the new liaTabButton panel
            local tabButton = vgui.Create("liaTabButton", tabContainer)
            tabButton:Dock(LEFT)
            tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
            tabButton:SetTall(36)
            tabButton:SetText(L(page.name))
            tabButton:SetActive(i == 1) -- First tab is active by default
            -- Set base width initially (will be adjusted in PerformLayout)
            tabButton:SetWide(baseTabWidths[i] or 80)
            tabButton:SetDoClick(function()
                if activeTab == i then return end
                -- Hide current panel
                if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                -- Show new panel
                activeTab = i
                tabPanels[i]:SetVisible(true)
                -- Update button states - set active state for the new button
                for j, btn in ipairs(tabButtons) do
                    if IsValid(btn) then btn:SetActive(j == i) end
                end

                surface.PlaySound("buttons/button14.wav")
                -- Call the page's draw function if it exists
                if page.drawFunc then page.drawFunc(tabPanels[i]) end
            end)

            tabButtons[i] = tabButton
            -- Create content panel for this tab
            local contentPanel = vgui.Create("DPanel", contentArea)
            contentPanel:Dock(TOP)
            contentPanel:SetVisible(i == 1)
            contentPanel.Paint = function() end
            -- Override PerformLayout to set proper height after parent layout is complete
            contentPanel.PerformLayout = function(s)
                if IsValid(frame) and IsValid(tabContainer) then
                    s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) -- Account for margins
                end
            end

            tabPanels[i] = contentPanel
        end

        -- Function to adjust tab widths based on available space
        local function AdjustTabWidths()
            if not IsValid(tabContainer) then return end
            local totalTabsWidth = 0
            for _, width in pairs(baseTabWidths) do
                totalTabsWidth = totalTabsWidth + width
            end

            local availableWidth = tabContainer:GetWide()
            local totalMargins = baseMargin * (#pages - 1)
            local extraSpace = availableWidth - totalTabsWidth - totalMargins
            if extraSpace > 0 and #pages > 1 then
                -- Distribute extra space evenly among tabs
                local extraPerTab = math.floor(extraSpace / #pages)
                local adjustedWidths = {}
                for tabId, baseWidth in pairs(baseTabWidths) do
                    adjustedWidths[tabId] = baseWidth + extraPerTab
                end

                -- Handle remainder
                local remainder = extraSpace % #pages
                if remainder > 0 then
                    for remainderId = 1, math.min(remainder, #pages) do
                        adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                    end
                end

                -- Apply new widths to existing buttons
                for childId, child in ipairs(tabContainer:GetChildren()) do
                    if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                end
            end
        end

        -- Override tab container PerformLayout to adjust tab widths
        local originalPerformLayout = tabContainer.PerformLayout
        tabContainer.PerformLayout = function(s, w, h)
            if originalPerformLayout then originalPerformLayout(s, w, h) end
            -- Adjust tab widths after layout
            timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
        end

        -- Initialize first tab
        if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
    end

    local adminPages = {}
    hook.Run("PopulateAdminTabs", adminPages)
    if not table.IsEmpty(adminPages) then
        tabs["admin"] = function(adminPanel)
            -- Create a custom frame instead of liaTabs
            local frame = adminPanel:Add("liaFrame")
            frame:Dock(FILL)
            frame:DockMargin(10, 10, 10, 10)
            frame:SetTitle(L("admin"))
            frame:LiteMode() -- Use lite mode for cleaner look
            frame:DisableCloseBtn() -- Remove close button from admin tab
            local pages = {}
            hook.Run("PopulateAdminTabs", pages)
            if table.IsEmpty(pages) then return end
            table.sort(pages, function(a, b)
                local an = tostring(a.name):lower()
                local bn = tostring(b.name):lower()
                return an < bn
            end)

            -- Add default Online Staff tab as the first tab
            table.insert(pages, 1, {
                name = "onlineStaff",
                icon = "icon16/user.png",
                drawFunc = function(panel)
                    -- Store original staff data and filtered data
                    panel.originalStaffData = {}
                    panel.filteredStaffData = {}
                    -- Create search functionality
                    local function filterStaffData(searchText)
                        if not searchText or searchText == "" then
                            panel.filteredStaffData = panel.originalStaffData
                        else
                            panel.filteredStaffData = {}
                            local searchLower = searchText:lower()
                            for _, staffInfo in ipairs(panel.originalStaffData) do
                                local nameMatch = staffInfo.name and staffInfo.name:lower():find(searchLower, 1, true)
                                local usergroupMatch = staffInfo.usergroup and staffInfo.usergroup:lower():find(searchLower, 1, true)
                                local characterMatch = staffInfo.characterName and staffInfo.characterName:lower():find(searchLower, 1, true)
                                if nameMatch or usergroupMatch or characterMatch then panel.filteredStaffData[#panel.filteredStaffData + 1] = staffInfo end
                            end
                        end
                        return panel.filteredStaffData
                    end

                    -- Create staff table display using liaTable
                    local function createStaffTable(staffData)
                        panel:Clear()
                        -- Add search
                        local searchEntry = panel:Add("DTextEntry")
                        searchEntry:Dock(TOP)
                        searchEntry:DockMargin(0, 0, 0, 15)
                        searchEntry:SetTall(30)
                        searchEntry:SetFont("liaSmallFont")
                        searchEntry:SetPlaceholderText(L("searchStaff") or "Search staff...")
                        searchEntry:SetTextColor(Color(200, 200, 200))
                        searchEntry.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
                        searchEntry.OnChange = function(textEntry)
                            local filteredData = filterStaffData(textEntry:GetValue())
                            updateStaffTable(filteredData)
                        end

                        local staffTable = panel:Add("liaTable")
                        staffTable:Dock(FILL)
                        panel.staffTable = staffTable -- Keep reference for resizing
                        -- Add 5 columns as requested
                        -- Create columns with responsive sizing (nil width = auto-size)
                        staffTable:AddColumn(L("name"), nil, TEXT_ALIGN_LEFT, true) -- Auto-size name column
                        staffTable:AddColumn(L("usergroup"), nil, TEXT_ALIGN_LEFT, true) -- Auto-size usergroup column
                        staffTable:AddColumn(L("tickets"), 80, TEXT_ALIGN_CENTER, true) -- Fixed width for tickets
                        staffTable:AddColumn(L("warnings"), 80, TEXT_ALIGN_CENTER, true) -- Fixed width for warnings
                        staffTable:AddColumn(L("staffOnDuty", ""), 100, TEXT_ALIGN_CENTER, true) -- Fixed width for duty status
                        -- Function to update table data
                        function updateStaffTable(dataToShow)
                            staffTable:Clear()
                            local staffFound = false
                            if dataToShow then
                                for _, staffInfo in ipairs(dataToShow) do
                                    staffFound = true
                                    staffTable:AddLine(staffInfo.name .. " (" .. staffInfo.characterName .. ")", staffInfo.usergroup, tostring(staffInfo.tickets), tostring(staffInfo.warnings), staffInfo.isStaffOnDuty and L("yes") or L("no"))
                                end
                            end

                            if not staffFound then staffTable:AddLine(L("noStaffCurrentlyOnline"), "", "", "", "") end
                        end

                        -- Store the update function for external use
                        panel.updateStaffTable = updateStaffTable
                        -- Update table with provided data
                        updateStaffTable(staffData)
                    end

                    -- Override PerformLayout to ensure table resizes properly when panel changes size
                    panel.PerformLayout = function(s)
                        if IsValid(s.staffTable) and s.staffTable.CalculateColumnWidths and s.staffTable.RebuildRows then
                            -- Trigger responsive column recalculation for the staff table
                            s.staffTable:CalculateColumnWidths()
                            s.staffTable:RebuildRows()
                        end
                    end

                    -- Also add a resize timer for more reliable resizing
                    panel.resizeTimer = nil
                    panel.OnSizeChanged = function(s)
                        if IsValid(s.staffTable) and s.staffTable.CalculateColumnWidths and s.staffTable.RebuildRows then
                            -- Clear existing timer
                            if s.resizeTimer then timer.Remove(s.resizeTimer) end
                            -- Set a new timer to handle resizing after a short delay
                            s.resizeTimer = "liaStaffTableResize_" .. CurTime()
                            timer.Create(s.resizeTimer, 0.1, 1, function()
                                if IsValid(s) and IsValid(s.staffTable) then
                                    s.staffTable:CalculateColumnWidths()
                                    s.staffTable:RebuildRows()
                                end
                            end)
                        end
                    end

                    -- Hook to receive staff data
                    local function onStaffDataReceived(staffData)
                        if IsValid(panel) then
                            -- Store original data
                            panel.originalStaffData = staffData or {}
                            panel.filteredStaffData = panel.originalStaffData
                            -- Update table with current data
                            if panel.updateStaffTable then
                                panel.updateStaffTable(panel.filteredStaffData)
                            else
                                createStaffTable(panel.filteredStaffData)
                            end
                        end
                    end

                    hook.Add("liaOnlineStaffDataReceived", "liaF1MenuStaffData", onStaffDataReceived)
                    -- Request staff data from server
                    net.Start("liaRequestOnlineStaffData")
                    net.SendToServer()
                    -- Refresh the table periodically
                    panel.refreshTimer = timer.Create("liaAdminStaffTableRefresh", 30, 0, function()
                        if IsValid(panel) then
                            net.Start("liaRequestOnlineStaffData")
                            net.SendToServer()
                        else
                            timer.Remove("liaAdminStaffTableRefresh")
                        end
                    end)

                    panel.OnRemove = function()
                        hook.Remove("liaOnlineStaffDataReceived", "liaF1MenuStaffData")
                        if timer.Exists("liaAdminStaffTableRefresh") then timer.Remove("liaAdminStaffTableRefresh") end
                        if panel.resizeTimer and timer.Exists(panel.resizeTimer) then timer.Remove(panel.resizeTimer) end
                        panel.staffTable = nil -- Clear reference
                    end
                end
            })

            -- Create tab container and content area
            local tabContainer = vgui.Create("DPanel", frame)
            tabContainer:Dock(TOP)
            tabContainer:SetTall(40)
            tabContainer.Paint = function() end
            local contentArea = vgui.Create("liaScrollPanel", frame)
            contentArea:Dock(FILL)
            local activeTab = 1
            local tabButtons = {}
            local tabPanels = {}
            local baseTabWidths = {}
            local baseMargin = 8
            -- Calculate base tab widths first
            for i, page in ipairs(pages) do
                surface.SetFont("Fated.18")
                local textWidth = surface.GetTextSize(L(page.name))
                local iconWidth = 0 -- Disable icons for admin tabs
                local padding = 20
                local minWidth = 80
                local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
                baseTabWidths[i] = btnWidth
            end

            -- Create tab buttons and panels
            for i, page in ipairs(pages) do
                -- Create tab button using the new liaTabButton panel
                local tabButton = vgui.Create("liaTabButton", tabContainer)
                tabButton:Dock(LEFT)
                tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
                tabButton:SetTall(36)
                tabButton:SetText(L(page.name))
                tabButton:SetActive(i == 1) -- First tab is active by default
                -- Set base width initially (will be adjusted in PerformLayout)
                tabButton:SetWide(baseTabWidths[i] or 80)
                tabButton:SetDoClick(function()
                    if activeTab == i then return end
                    -- Hide current panel
                    if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                    -- Show new panel
                    activeTab = i
                    tabPanels[i]:SetVisible(true)
                    -- Update button states - set active state for the new button
                    for j, btn in ipairs(tabButtons) do
                        if IsValid(btn) then btn:SetActive(j == i) end
                    end

                    surface.PlaySound("buttons/button14.wav")
                    -- Call the page's draw function if it exists
                    if page.drawFunc then page.drawFunc(tabPanels[i]) end
                end)

                tabButtons[i] = tabButton
                -- Create content panel for this tab
                local contentPanel = vgui.Create("DPanel", contentArea)
                contentPanel:Dock(TOP)
                contentPanel:SetVisible(i == 1)
                contentPanel.Paint = function() end
                -- Override PerformLayout to set proper height after parent layout is complete
                contentPanel.PerformLayout = function(s)
                    if IsValid(frame) and IsValid(tabContainer) then
                        s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) -- Account for margins
                    end
                end

                tabPanels[i] = contentPanel
            end

            -- Function to adjust tab widths based on available space
            local function AdjustTabWidths()
                if not IsValid(tabContainer) then return end
                local totalTabsWidth = 0
                for _, width in pairs(baseTabWidths) do
                    totalTabsWidth = totalTabsWidth + width
                end

                local availableWidth = tabContainer:GetWide()
                local totalMargins = baseMargin * (#pages - 1)
                local extraSpace = availableWidth - totalTabsWidth - totalMargins
                if extraSpace > 0 and #pages > 1 then
                    -- Distribute extra space evenly among tabs
                    local extraPerTab = math.floor(extraSpace / #pages)
                    local adjustedWidths = {}
                    for tabId, baseWidth in pairs(baseTabWidths) do
                        adjustedWidths[tabId] = baseWidth + extraPerTab
                    end

                    -- Handle remainder
                    local remainder = extraSpace % #pages
                    if remainder > 0 then
                        for remainderId = 1, math.min(remainder, #pages) do
                            adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                        end
                    end

                    -- Apply new widths to existing buttons
                    for childId, child in ipairs(tabContainer:GetChildren()) do
                        if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                    end
                end
            end

            -- Override tab container PerformLayout to adjust tab widths
            local originalPerformLayout = tabContainer.PerformLayout
            tabContainer.PerformLayout = function(s, w, h)
                if originalPerformLayout then originalPerformLayout(s, w, h) end
                -- Adjust tab widths after layout
                timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
            end

            -- Initialize first tab after a short delay to ensure proper layout
            if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then timer.Simple(0.01, function() if IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end end) end
        end
    end

    local hasPrivilege = IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("accessEditConfigurationMenu") or false
    if hasPrivilege then
        tabs["themes"] = function(themesPanel)
            local sheet = themesPanel:Add("DPropertySheet")
            sheet:Dock(FILL)
            sheet:DockMargin(10, 10, 10, 10)
            local function getLocalizedThemeName(themeID)
                -- Convert lowercase theme ID to proper case for localization key
                local properCaseName = themeID:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
                local localizationKey = "theme" .. properCaseName:gsub(" ", ""):gsub("-", "")
                return L(localizationKey) or themeID
            end

            local function prettify(name)
                name = name:gsub("_", " ")
                return name:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
            end

            local themeIDs = lia.color.getAllThemes()
            table.sort(themeIDs, function(a, b) return getLocalizedThemeName(a) < getLocalizedThemeName(b) end)
            local currentTheme = lia.color.getCurrentTheme()
            local statusUpdaters = {}
            local activeTab
            for _, themeID in ipairs(themeIDs) do
                local themeData = lia.color.themes[themeID]
                if istable(themeData) then
                    local displayName = getLocalizedThemeName(themeID)
                    local page = vgui.Create("DPanel")
                    page:SetPaintBackground(false)
                    page:DockPadding(12, 12, 12, 12)
                    local header = page:Add("DPanel")
                    header:Dock(TOP)
                    header:SetTall(60)
                    header:SetPaintBackground(false)
                    local applyButton = header:Add("liaSmallButton")
                    applyButton:Dock(TOP)
                    applyButton:DockMargin(0, 5, 0, 0)
                    applyButton:SetWide(200)
                    applyButton:SetTall(35)
                    applyButton:CenterHorizontal()
                    applyButton:SetText(L("apply"))
                    local scroll = page:Add("DScrollPanel")
                    scroll:Dock(FILL)
                    local entries = {}
                    for key, value in pairs(themeData) do
                        if lia.color.isColor(value) then
                            entries[#entries + 1] = {
                                name = key,
                                colors = {value}
                            }
                        elseif istable(value) then
                            local colors = {}
                            for _, subValue in ipairs(value) do
                                if lia.color.isColor(subValue) then colors[#colors + 1] = subValue end
                            end

                            if #colors > 0 then
                                entries[#entries + 1] = {
                                    name = key,
                                    colors = colors
                                }
                            end
                        end
                    end

                    table.sort(entries, function(a, b) return a.name < b.name end)
                    for _, entry in ipairs(entries) do
                        local row = scroll:Add("DPanel")
                        row:Dock(TOP)
                        row:DockMargin(0, 0, 0, 8)
                        row:SetTall(80)
                        row.Paint = function(_, w, h)
                            draw.RoundedBox(8, 0, 0, w, h, Color(24, 24, 24, 220))
                            draw.SimpleText(prettify(entry.name), "liaSmallFont", 12, 12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            local swatchSize = h - 34
                            local gap = 10
                            local totalWidth = (#entry.colors * (swatchSize + gap)) - gap
                            local startX = w - totalWidth - 12
                            local swatchY = (h - swatchSize) * 0.5
                            for idx, col in ipairs(entry.colors) do
                                local x = startX + (idx - 1) * (swatchSize + gap)
                                draw.RoundedBox(6, x, swatchY, swatchSize, swatchSize, col)
                                surface.SetDrawColor(255, 255, 255, 60)
                                surface.DrawOutlinedRect(x, swatchY, swatchSize, swatchSize)
                            end
                        end
                    end

                    local sheetInfo = sheet:AddSheet(displayName, page)
                    local function updateStatus()
                        local isActive = currentTheme == themeID
                        if IsValid(applyButton) then
                            applyButton:SetEnabled(not isActive)
                            applyButton:SetText(isActive and L("currentlySelected") or L("apply"))
                        end
                    end

                    table.insert(statusUpdaters, updateStatus)
                    updateStatus()
                    applyButton.DoClick = function()
                        if currentTheme == themeID then return end
                        surface.PlaySound("buttons/button14.wav")
                        net.Start("liaCfgSet")
                        net.WriteString("Theme")
                        net.WriteString(L("theme"))
                        net.WriteType(themeID)
                        net.SendToServer()
                    end

                    if themeID == currentTheme and not activeTab and sheetInfo and sheetInfo.Tab then activeTab = sheetInfo.Tab end
                end
            end

            if activeTab then sheet:SetActiveTab(activeTab) end
        end
    end
end

function MODULE:CanDisplayCharInfo(name)
    local client = LocalPlayer()
    if not client then return true end
    local character = client:getChar()
    if not character then return true end
    if not lia.class or not lia.class.list then return true end
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end

-- Refresh the F1 menu when fonts change
hook.Add("RefreshFonts", "liaF1MenuRefreshFonts", function() if IsValid(lia.gui.menu) then lia.gui.menu:Update() end end)
