local currentCategoryData = {}
local categoryIcons = {
    combat = "icon16/brick.png",
    connections = "icon16/connect.png",
    factions = "icon16/group.png",
    admin = "icon16/shield.png",
    character = "icon16/user.png",
    world = "icon16/world.png",
    chat = "icon16/comments.png",
    cheating = "icon16/eye.png",
    permissions = "icon16/lock.png",
    money = "icon16/money.png",
    vjbase = "icon16/script_code.png",
    items = "icon16/package.png",
    tools = "icon16/wrench.png",
    inventory = "icon16/briefcase.png"
}

local categoryDescriptions = {
    combat = "Review combat events and damage activity.",
    connections = "Review player connection and disconnection activity.",
    factions = "Review faction-related activity.",
    admin = "Review administrative commands and staff actions.",
    character = "Review character-related activity.",
    world = "Review world and map activity.",
    chat = "Review recorded chat activity.",
    cheating = "Review anti-cheat and suspicious activity.",
    permissions = "Review privilege and permission activity.",
    money = "Review currency and economy activity.",
    vjbase = "Review VJ Base activity.",
    items = "Review item-related activity.",
    tools = "Review tool-related activity.",
    inventory = "Review inventory activity."
}

local function normalizeCategory(category)
    return tostring(category or ""):lower():gsub("[^%w]", "")
end

local function getThemeColors()
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    local text = theme.text or Color(225, 238, 238)
    return accent, text
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

local function drawIcon(material, x, y, size, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color or color_white)
    surface.DrawTexturedRect(x, y, size, size)
end

local function getCategoryLabel(category)
    local label = tostring(category or "")
    if label == "" then return "Logs" end
    local localized = L(label)
    if isstring(localized) and localized ~= "" and localized ~= label then return localized end
    return label
end

local function getCategoryTitle(category)
    local label = getCategoryLabel(category)
    if label:lower():sub(-4) == "logs" then return label end
    return label .. " Logs"
end

local function getCategoryDescription(category)
    return categoryDescriptions[normalizeCategory(category)] or "Review recorded activity for this category."
end

local function getCategoryIcon(category)
    return Material(categoryIcons[normalizeCategory(category)] or "icon16/page_white_text.png", "smooth")
end

local function styleScrollBar(scrollPanel)
    if not IsValid(scrollPanel) or not IsValid(scrollPanel.VBar) then return end
    local vbar = scrollPanel.VBar
    vbar:SetWide(8)
    vbar.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 4)
        surface.DrawRect(0, 0, w, h)
    end

    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
    vbar.btnGrip.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(1, 0, w - 2, h, 4, Color(accent.r, accent.g, accent.b, 145))
    end
end

local function createCell(parent, font, color)
    local label = parent:Add("DLabel")
    label:SetFont(font)
    label:SetTextColor(color)
    label:SetContentAlignment(4)
    label:SetTextInset(12, 0)
    label:SetMouseInputEnabled(false)
    return label
end

local function layoutColumns(container, w, h)
    local timestampW = math.Clamp(math.floor(w * 0.18), 180, 250)
    local steamIDW = math.Clamp(math.floor(w * 0.22), 220, 320)
    local messageW = math.max(w - timestampW - steamIDW, 100)
    local widths = {timestampW, messageW, steamIDW}
    local x = 0
    for i, width in ipairs(widths) do
        local cell = container.cells[i]
        if IsValid(cell) then
            cell:SetPos(x, 0)
            cell:SetSize(width, h)
        end

        x = x + width
    end
end

local function openRowMenu(log)
    local menu = DermaMenu()
    if log.steamID and log.steamID ~= "" then menu:AddOption(L("copySteamID"), function() SetClipboardText(tostring(log.steamID)) end):SetIcon("icon16/page_copy.png") end
    menu:AddOption(L("copyLogMessage"), function() SetClipboardText(tostring(log.message or "")) end):SetIcon("icon16/page_copy.png")
    menu:Open()
end

local function filterLogs(logs, searchFilter)
    local search = string.lower(searchFilter or "")
    if search == "" then return logs end
    local filtered = {}
    for _, log in ipairs(logs or {}) do
        local timestamp = string.lower(tostring(log.timestamp or ""))
        local message = string.lower(tostring(log.message or ""))
        local steamID = string.lower(tostring(log.steamID or ""))
        if string.find(timestamp, search, 1, true) or string.find(message, search, 1, true) or string.find(steamID, search, 1, true) then filtered[#filtered + 1] = log end
    end
    return filtered
end

local function createLogTable(parent, categoryData)
    local tablePanel = parent:Add("DPanel")
    tablePanel:Dock(FILL)
    tablePanel:DockMargin(0, 0, 0, 12)
    tablePanel.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 7, Color(4, 17, 21, 242), Color(accent.r, accent.g, accent.b, 78))
    end

    local header = tablePanel:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(42)
    header.cells = {}
    header.Paint = function(_, w, h)
        local accent = getThemeColors()
        surface.SetDrawColor(7, 26, 31, 255)
        surface.DrawRect(1, 1, w - 2, h - 1)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 75)
        surface.DrawRect(0, h - 1, w, 1)
    end

    local columnNames = {L("timestamp"), L("message"), L("steamID")}
    for _, name in ipairs(columnNames) do
        local cell = createCell(header, "LiliaFont.17", Color(225, 236, 236))
        cell:SetText(name)
        header.cells[#header.cells + 1] = cell
    end

    header.PerformLayout = function(s, w, h) layoutColumns(s, w, h) end
    local scroll = tablePanel:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll.Paint = function() end
    styleScrollBar(scroll)
    local canvas = scroll:GetCanvas()
    canvas:DockPadding(0, 0, 8, 0)
    canvas.Paint = function() end
    local filteredLogs = filterLogs(categoryData.logs or {}, categoryData.searchFilter or "")
    for index, log in ipairs(filteredLogs) do
        local row = canvas:Add("DButton")
        row:Dock(TOP)
        row:SetTall(38)
        row:SetText("")
        row.cells = {}
        row.Paint = function(s, w, h)
            local accent = getThemeColors()
            if s:IsHovered() then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 18)
            elseif index % 2 == 0 then
                surface.SetDrawColor(255, 255, 255, 4)
            else
                surface.SetDrawColor(0, 0, 0, 0)
            end

            surface.DrawRect(1, 0, w - 2, h)
            surface.SetDrawColor(255, 255, 255, 8)
            surface.DrawRect(0, h - 1, w, 1)
        end

        local values = {tostring(log.timestamp or ""), tostring(log.message or ""), tostring(log.steamID or "")}
        for _, value in ipairs(values) do
            local cell = createCell(row, "LiliaFont.16", Color(202, 218, 218))
            cell:SetText(value)
            row.cells[#row.cells + 1] = cell
        end

        row.PerformLayout = function(s, w, h) layoutColumns(s, w, h) end
        row.DoClick = function() end
        row.DoRightClick = function() openRowMenu(log) end
    end

    if #filteredLogs == 0 then
        local empty = canvas:Add("DLabel")
        empty:Dock(TOP)
        empty:SetTall(120)
        empty:SetFont("LiliaFont.18")
        empty:SetTextColor(Color(145, 165, 165))
        empty:SetContentAlignment(5)
        empty:SetText(L("noLogsAvailable"))
    end
    return tablePanel
end

local function renderLoading(panel, category)
    if not IsValid(panel.logsContent) then return end
    panel.logsContent:Clear()
    local title = panel.logsContent:Add("DLabel")
    title:Dock(TOP)
    title:SetTall(34)
    title:SetFont("LiliaFont.25")
    title:SetTextColor(select(2, getThemeColors()))
    title:SetText(getCategoryTitle(category))
    local subtitle = panel.logsContent:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:SetTall(34)
    subtitle:SetFont("LiliaFont.17")
    subtitle:SetTextColor(Color(155, 178, 179))
    subtitle:SetText(getCategoryDescription(category))
    local loading = panel.logsContent:Add("DLabel")
    loading:Dock(FILL)
    loading:SetFont("LiliaFont.20")
    loading:SetTextColor(Color(150, 170, 170))
    loading:SetContentAlignment(5)
    loading:SetText(L("loading"))
    panel.loadingLabel = loading
end

local function requestPage(category, pageNum)
    local categoryData = currentCategoryData[category]
    if not categoryData then return end
    if pageNum < 1 or pageNum > categoryData.totalPages then return end
    categoryData.currentPage = pageNum
    net.Start("liaSendLogsRequest")
    net.WriteString(category)
    net.WriteUInt(pageNum, 16)
    net.SendToServer()
end

local function renderCategory(panel, category)
    local categoryData = currentCategoryData[category]
    if not categoryData or not IsValid(panel.logsContent) then return end
    panel.logsContent:Clear()
    local title = panel.logsContent:Add("DLabel")
    title:Dock(TOP)
    title:SetTall(34)
    title:SetFont("LiliaFont.25")
    title:SetTextColor(select(2, getThemeColors()))
    title:SetText(getCategoryTitle(category))
    local subtitle = panel.logsContent:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:SetTall(34)
    subtitle:SetFont("LiliaFont.17")
    subtitle:SetTextColor(Color(155, 178, 179))
    subtitle:SetText(getCategoryDescription(category))
    local searchWrap = panel.logsContent:Add("DPanel")
    searchWrap:Dock(TOP)
    searchWrap:SetTall(44)
    searchWrap:DockMargin(0, 0, 0, 12)
    searchWrap:DockPadding(42, 0, 10, 0)
    searchWrap.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 5, Color(4, 17, 21, 245), Color(accent.r, accent.g, accent.b, 82))
        drawIcon(Material("icon16/magnifier.png", "smooth"), 14, math.floor(h * 0.5) - 8, 16, Color(150, 180, 181))
    end

    local searchBox = searchWrap:Add("DTextEntry")
    searchBox:Dock(FILL)
    searchBox:SetFont("LiliaFont.17")
    searchBox:SetTextColor(Color(225, 236, 236))
    searchBox:SetCursorColor(getThemeColors())
    searchBox:SetPlaceholderText(L("searchLogs"))
    searchBox:SetDrawBackground(false)
    searchBox:SetPaintBackground(false)
    searchBox:SetPaintBorderEnabled(false)
    searchBox:SetText(categoryData.searchFilter or "")
    local pagination = panel.logsContent:Add("DPanel")
    pagination:Dock(BOTTOM)
    pagination:SetTall(46)
    pagination.Paint = function() end
    local previousButton = pagination:Add("DButton")
    previousButton:Dock(LEFT)
    previousButton:SetWide(108)
    previousButton:SetText("")
    previousButton.Paint = function(s, w, h)
        local accent = getThemeColors()
        local disabled = categoryData.currentPage <= 1
        local background = s:IsHovered() and not disabled and Color(accent.r, accent.g, accent.b, 16) or Color(4, 17, 21, 225)
        drawPanel(0, 6, w, h - 12, 5, background, Color(accent.r, accent.g, accent.b, disabled and 28 or 70))
        draw.SimpleText(L("previousPage"), "LiliaFont.16", w * 0.5, h * 0.5, disabled and Color(80, 100, 100) or Color(205, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local pageLabel = pagination:Add("DLabel")
    pageLabel:Dock(FILL)
    pageLabel:SetFont("LiliaFont.16")
    pageLabel:SetTextColor(Color(210, 224, 224))
    pageLabel:SetContentAlignment(5)
    pageLabel:SetText(L("pageIndicator", categoryData.currentPage, categoryData.totalPages))
    local nextButton = pagination:Add("DButton")
    nextButton:Dock(RIGHT)
    nextButton:SetWide(108)
    nextButton:SetText("")
    nextButton.Paint = function(s, w, h)
        local accent = getThemeColors()
        local disabled = categoryData.currentPage >= categoryData.totalPages
        local background = s:IsHovered() and not disabled and Color(accent.r, accent.g, accent.b, 16) or Color(4, 17, 21, 225)
        drawPanel(0, 6, w, h - 12, 5, background, Color(accent.r, accent.g, accent.b, disabled and 28 or 70))
        draw.SimpleText(L("next"), "LiliaFont.16", w * 0.5, h * 0.5, disabled and Color(80, 100, 100) or Color(205, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function rebuildTable()
        if IsValid(panel.logsTable) then panel.logsTable:Remove() end
        panel.logsTable = createLogTable(panel.logsContent, categoryData)
        panel.logsContent:InvalidateLayout(true)
    end

    searchBox.OnChange = function(s)
        categoryData.searchFilter = s:GetValue() or ""
        rebuildTable()
    end

    previousButton.DoClick = function() requestPage(category, categoryData.currentPage - 1) end
    nextButton.DoClick = function() requestPage(category, categoryData.currentPage + 1) end
    panel.logsTable = createLogTable(panel.logsContent, categoryData)
end

local function openLogsPanel(panel)
    if not IsValid(panel) then return end
    if not panel.liaLogsPanel then
        panel.liaLogsPanel = panel
        liaLogsPanel = panel
        panel:Clear()
        panel:DockPadding(0, 0, 0, 0)
        panel.Paint = nil
        net.Start("liaSendLogsCategoriesRequest")
        net.SendToServer()
    end
end

function MODULE:CreateMenuButtons(tabs)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canSeeLogs = client:hasPrivilege("canSeeLogs")
    if canSeeLogs then
        tabs["@logs"] = {
            name = "@logs",
            icon = "icon16/book_open.png",
            func = openLogsPanel
        }
    end
end

function MODULE:CreateLogsUI(panel, categories)
    if not IsValid(panel) then return end
    panel:Clear()
    currentCategoryData = {}
    panel:DockPadding(0, 0, 0, 0)
    panel.Paint = nil
    panel.liaLogsPanel = panel
    liaLogsPanel = panel
    if not categories or #categories == 0 then
        local noLogsLabel = panel:Add("DLabel")
        noLogsLabel:Dock(FILL)
        noLogsLabel:SetText(L("noLogsAvailable"))
        noLogsLabel:SetTextColor(Color(150, 170, 170))
        noLogsLabel:SetFont("LiliaFont.20")
        noLogsLabel:SetContentAlignment(5)
        return
    end

    local pageHeader = panel:Add("DPanel")
    pageHeader:Dock(TOP)
    pageHeader:SetTall(74)
    pageHeader.Paint = function()
        local _, textColor = getThemeColors()
        draw.SimpleText("Server Logs", "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Browse and inspect recorded server activity.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local body = panel:Add("DPanel")
    body:Dock(FILL)
    body.Paint = function() end
    local categoryPanel = body:Add("DPanel")
    categoryPanel:Dock(LEFT)
    categoryPanel:SetWide(math.Clamp(ScrW() * 0.14, 225, 275))
    categoryPanel:DockMargin(0, 0, 14, 0)
    categoryPanel:DockPadding(10, 10, 10, 10)
    categoryPanel.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(4, 17, 21, 235), Color(accent.r, accent.g, accent.b, 70))
    end

    local categoryHeader = categoryPanel:Add("DLabel")
    categoryHeader:Dock(TOP)
    categoryHeader:SetTall(38)
    categoryHeader:SetFont("LiliaFont.18")
    categoryHeader:SetTextColor(Color(190, 208, 208))
    categoryHeader:SetText("Log Categories")
    categoryHeader:SetTextInset(2, 0)
    local categoryScroll = categoryPanel:Add("DScrollPanel")
    categoryScroll:Dock(FILL)
    categoryScroll.Paint = function() end
    styleScrollBar(categoryScroll)
    local categoryCanvas = categoryScroll:GetCanvas()
    categoryCanvas:DockPadding(0, 0, 6, 0)
    categoryCanvas.Paint = function() end
    local contentPanel = body:Add("DPanel")
    contentPanel:Dock(FILL)
    contentPanel:DockPadding(14, 14, 14, 14)
    contentPanel.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(4, 17, 21, 235), Color(accent.r, accent.g, accent.b, 70))
    end

    panel.logsContent = contentPanel
    panel.categoryButtons = {}
    panel.activeLogsCategory = nil
    local function requestLogsForCategory(category)
        local categoryData = currentCategoryData[category]
        if not categoryData then return end
        renderLoading(panel, category)
        net.Start("liaSendLogsRequest")
        net.WriteString(category)
        net.WriteUInt(categoryData.currentPage, 16)
        net.SendToServer()
    end

    function panel:SelectLogsCategory(category)
        if not currentCategoryData[category] then return end
        self.activeLogsCategory = category
        for _, button in ipairs(self.categoryButtons or {}) do
            if IsValid(button) then button:InvalidateLayout(true) end
        end

        requestLogsForCategory(category)
    end

    for _, category in ipairs(categories) do
        currentCategoryData[category] = {
            currentPage = 1,
            totalPages = 1,
            logs = {},
            searchFilter = ""
        }

        local button = categoryCanvas:Add("DButton")
        button:Dock(TOP)
        button:SetTall(48)
        button:DockMargin(0, 0, 0, 5)
        button:SetText("")
        button.category = category
        button.icon = getCategoryIcon(category)
        button.Paint = function(s, w, h)
            local accent = getThemeColors()
            local active = panel.activeLogsCategory == s.category
            local hovered = s:IsHovered()
            local background = active and Color(accent.r, accent.g, accent.b, 24) or hovered and Color(255, 255, 255, 6) or Color(0, 0, 0, 0)
            drawPanel(0, 0, w, h, 5, background, active and Color(accent.r, accent.g, accent.b, 100) or Color(accent.r, accent.g, accent.b, 25))
            if active then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                surface.DrawRect(0, 5, 3, h - 10)
            end

            drawIcon(s.icon, 14, math.floor((h - 20) * 0.5), 20, active and Color(242, 248, 248) or Color(170, 192, 192))
            draw.SimpleText(getCategoryLabel(s.category), "LiliaFont.17", 48, h * 0.5, active and Color(242, 248, 248) or Color(195, 211, 211), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function() panel:SelectLogsCategory(category) end
        panel.categoryButtons[#panel.categoryButtons + 1] = button
    end

    panel:SelectLogsCategory(categories[1])
end

local function UpdateLogsUI(panel, logsData)
    local category = logsData and logsData.category
    if not category or not currentCategoryData[category] then return end
    local categoryData = currentCategoryData[category]
    categoryData.currentPage = logsData.currentPage or 1
    categoryData.totalPages = logsData.totalPages or 1
    categoryData.logs = logsData.logs or {}
    if panel.activeLogsCategory == category then renderCategory(panel, category) end
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
        if IsValid(logsPanel) and IsValid(logsPanel.loadingLabel) then
            logsPanel.loadingLabel:Remove()
            logsPanel.loadingLabel = nil
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
