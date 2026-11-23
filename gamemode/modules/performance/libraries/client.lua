local MODULE = MODULE
MODULE.hideNativeMetrics = MODULE.hideNativeMetrics or false
MODULE.serverProfilingStarted = MODULE.serverProfilingStarted or false
MODULE.serverProfilingCollecting = MODULE.serverProfilingCollecting or false

local currentPanel
local nextRefresh = 0
local clientMetrics = {}
local serverMetrics = {}
local sourceCache = {}
local clientColor = Color(235, 190, 80)
local serverColor = Color(100, 155, 255)
local mutedColor = Color(144, 166, 174)
local iconChart = Material("icon16/chart_bar.png", "smooth")
local iconClock = Material("icon16/time.png", "smooth")
local iconFolder = Material("icon16/folder.png", "smooth")
local iconDocument = Material("icon16/page_white_code.png", "smooth")
local nativePaths = {
    ["lua/includes/"] = true,
    ["lua/derma/derma.lua"] = true,
    ["lua/derma/derma_menus.lua"] = true,
    ["lua/vgui/"] = true,
    ["lua/postprocess/"] = true,
    ["lua/menu/menu.lua"] = true,
    ["gamemodes/base/"] = true,
    ["gamemodes/sandbox/"] = true,
    ["gamemodes/darkrp/"] = true,
    ["lua/matproxy/"] = true,
    ["lua/skins/"] = true
}

local addonPatterns = {"^.*/addons/", "^.*workshop/content/4000/"}

local function getThemeColors()
    local theme = lia.color and lia.color.theme or {}
    return theme.accent or theme.theme or lia.config.get("Color") or Color(115, 148, 248), theme.text or Color(225, 238, 238)
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

local function fitText(value, font, maxWidth)
    local text = tostring(value or "")
    surface.SetFont(font)
    if surface.GetTextSize(text) <= maxWidth then return text end
    while #text > 6 and surface.GetTextSize(text .. "...") > maxWidth do
        text = text:sub(1, -2)
    end
    return text .. "..."
end

local function createButton(parent, title, click, height, selected, danger)
    local button = parent:Add("DButton")
    button:SetText("")
    button:SetTall(height or 36)
    button:SetCursor("hand")
    button.Paint = function(self, w, h)
        local accent, textColor = getThemeColors()
        local active = isfunction(selected) and selected() == true or selected == true
        local edge = danger and Color(198, 86, 86, 135) or Color(accent.r, accent.g, accent.b, active and 150 or self:IsHovered() and 110 or 58)
        local fill = danger and Color(70, 28, 34, self:IsHovered() and 200 or 155) or active and Color(26, 43, 59, 240) or self:IsHovered() and Color(23, 39, 48, 235) or Color(8, 25, 32, 210)
        drawPanel(0, 0, w, h, 4, fill, edge)
        if active then surface.SetDrawColor(accent) surface.DrawRect(1, 1, 3, h - 2) end
        draw.SimpleText(isfunction(title) and title() or title, "LiliaFont.15", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button.DoClick = function(self)
        if lia.webcontent and lia.webcontent.playButtonSound then lia.webcontent.playButtonSound() end
        click(self)
    end
    return button
end

local function createCard(parent, paint)
    local panel = parent:Add("DPanel")
    panel.Paint = function(self, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 5, Color(4, 19, 25, 220), Color(accent.r, accent.g, accent.b, 52))
        if paint then paint(self, w, h) end
    end
    return panel
end

function MODULE:IsAddonSource(source)
    if sourceCache[source] ~= nil then return sourceCache[source] end
    local normalized = tostring(source or ""):lower():gsub("\\", "/")
    for _, pattern in ipairs(addonPatterns) do
        if normalized:match(pattern) then
            sourceCache[source] = true
            return true
        end
    end
    for path in pairs(nativePaths) do
        if normalized:find(path, 1, true) then
            sourceCache[source] = false
            return false
        end
    end
    sourceCache[source] = true
    return true
end

function MODULE:FilterMetrics(metrics)
    if not self.hideNativeMetrics then return metrics end
    local filtered = {}
    for source, data in pairs(metrics) do
        if self:IsAddonSource(source) then filtered[source] = data end
    end
    return filtered
end

function MODULE:MergeProfileMetrics()
    local rows = {}
    for source, data in pairs(self:FilterMetrics(clientMetrics)) do
        rows[#rows + 1] = {
            key = "client:" .. source,
            source = source,
            realm = 0,
            time = data.time or 0,
            funcs = data.funcs or {},
            counts = data.counts or {},
            calls = data.calls or 0
        }
    end
    for source, data in pairs(self:FilterMetrics(serverMetrics)) do
        rows[#rows + 1] = {
            key = "server:" .. source,
            source = source,
            realm = 1,
            time = data.time or 0,
            funcs = data.funcs or {},
            counts = data.counts or {},
            calls = data.calls or 0
        }
    end
    table.sort(rows, function(a, b) return a.time > b.time end)
    return rows
end

function MODULE:GetRealmSummary(rows, realm)
    local total, count, calls = 0, 0, 0
    for _, data in ipairs(rows) do
        if data.realm == realm then
            total = total + data.time
            count = count + 1
            calls = calls + data.calls
        end
    end
    return {time = total, sources = count, calls = calls}
end

function MODULE:ToggleProfiling(realm, panel)
    if realm == 0 then
        if self.profilingCollecting then
            self:PauseProfiling()
        else
            self:StartProfiling()
        end
    elseif realm == 1 then
        net.Start("liaPerformanceProfileStart")
        net.WriteBool(not self.serverProfilingCollecting)
        net.SendToServer()
    else
        return
    end
    if IsValid(panel) then self:RefreshMetrics(panel) end
end

function MODULE:ClearDisplayedMetrics(realm, panel)
    if realm == 0 then
        self:ClearProfileMetrics()
        clientMetrics = {}
    elseif realm == 1 then
        serverMetrics = {}
    else
        return
    end

    if not IsValid(panel) then return end
    if panel.FrozenRows then
        for i = #panel.FrozenRows, 1, -1 do
            if panel.FrozenRows[i].realm == realm then table.remove(panel.FrozenRows, i) end
        end
    end

    if panel.SelectedData and panel.SelectedData.realm == realm then
        panel.SelectedKey = nil
        panel.SelectedData = nil
    end

    self:RefreshMetrics(panel)
end

function MODULE:ClearRealmMetrics(realm, panel)
    if realm == 0 then
        self:ClearDisplayedMetrics(realm, panel)
    elseif realm == 1 then
        net.Start("liaPerformanceProfileClear")
        net.SendToServer()
    end
end

function MODULE:ReceiveServerMetrics(source, time, calls, funcs, counts)
    serverMetrics[source] = {
        realm = 1,
        time = time,
        calls = calls,
        funcs = funcs,
        counts = counts,
        expires = CurTime() + math.max(self.profileRefreshRate, 0.1) + 1
    }
end

function MODULE:CreateRealmCard(parent, realm, dashboard)
    local isServer = realm == 1
    local name = isServer and "Server Performance" or "Client Performance"
    local color = isServer and serverColor or clientColor
    local card = createCard(parent)
    card.Paint = function(_, w, h)
        local accent, textColor = getThemeColors()
        drawPanel(0, 0, w, h, 5, Color(4, 19, 25, 220), Color(accent.r, accent.g, accent.b, 65))
        surface.SetDrawColor(color)
        surface.DrawRect(0, 14, 3, h - 28)
        drawPanel(15, 16, 13, 13, 3, color)
        draw.SimpleText(name, "LiliaFont.20", 38, 13, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(isServer and "Profile Lua executed on the server." or "Profile Lua executed on this client.", "LiliaFont.14", 38, 39, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local active = isServer and MODULE.serverProfilingCollecting or MODULE.profilingCollecting
        local initialized = isServer and MODULE.serverProfilingStarted or MODULE.profilingStarted
        local badgeColor = active and Color(103, 207, 137) or mutedColor
        local status = active and "RUNNING" or initialized and "PAUSED" or "STOPPED"
        drawPanel(w - 101, 15, 86, 27, 5, Color(badgeColor.r, badgeColor.g, badgeColor.b, 12), Color(badgeColor.r, badgeColor.g, badgeColor.b, 85))
        draw.SimpleText(status, "LiliaFont.14", w - 58, 29, badgeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local stats = card:Add("DPanel")
    stats.Paint = function() end
    local labels = {"SAMPLE COST", "SOURCES", "CALLS"}
    local icons = {iconClock, iconFolder, iconChart}
    local blocks = {}
    for i = 1, 3 do
        local index = i
        local block = createCard(stats, function(_, w, h)
            local _, textColor = getThemeColors()
            local value = (dashboard.RealmSummary or {})[realm] or {time = 0, sources = 0, calls = 0}
            local number = index == 1 and string.format("%.3f ms", value.time * 1000) or index == 2 and tostring(value.sources) or string.Comma(value.calls)
            drawIcon(icons[index], 10, 9, 15, Color(150, 180, 190))
            draw.SimpleText(labels[index], "LiliaFont.13", 30, 9, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(number, "LiliaFont.20", 12, 36, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            if index == 1 then draw.SimpleText(string.format("%.1fs window", MODULE.profileRefreshRate), "LiliaFont.12", w - 9, h - 9, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM) end
        end)
        blocks[i] = block
    end
    stats.PerformLayout = function(_, w, h)
        local gap = 8
        local unit = math.floor((w - gap * 2) / 3)
        for i, block in ipairs(blocks) do
            block:SetPos((i - 1) * (unit + gap), 0)
            block:SetSize(i == 3 and w - 2 * (unit + gap) or unit, h)
        end
    end
    local action = createButton(card, function()
        local running = isServer and MODULE.serverProfilingCollecting or MODULE.profilingCollecting
        return running and ("Pause " .. (isServer and "Server" or "Client") .. " Profiler") or ("Start " .. (isServer and "Server" or "Client") .. " Profiler")
    end, function() MODULE:ToggleProfiling(realm, dashboard) end, 36, false, false)
    action.Paint = function(panel, w, h)
        local running = isServer and MODULE.serverProfilingCollecting or MODULE.profilingCollecting
        local accent, textColor = getThemeColors()
        local edge = running and Color(188, 78, 87, 142) or Color(accent.r, accent.g, accent.b, panel:IsHovered() and 145 or 75)
        local fill = running and Color(58, 27, 34, panel:IsHovered() and 215 or 180) or Color(8, 30, 39, panel:IsHovered() and 245 or 215)
        drawPanel(0, 0, w, h, 4, fill, edge)
        draw.SimpleText(running and ("Pause " .. (isServer and "Server" or "Client") .. " Profiler") or ("Start " .. (isServer and "Server" or "Client") .. " Profiler"), "LiliaFont.15", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local clear = createButton(card, "Clear " .. (isServer and "Server" or "Client"), function()
        MODULE:ClearRealmMetrics(realm, dashboard)
    end, 36)
    card.PerformLayout = function(_, w, h)
        stats:SetPos(12, 66)
        stats:SetSize(w - 24, math.max(60, h - 120))
        local clearWidth = math.min(128, math.max(100, math.floor((w - 32) * 0.3)))
        action:SetPos(12, h - 46)
        action:SetSize(w - clearWidth - 32, 34)
        clear:SetPos(w - clearWidth - 12, h - 46)
        clear:SetSize(clearWidth, 34)
    end
    return card
end

function MODULE:CreateMetricRow(parent, data, maxTime, dashboard)
    local row = parent:Add("DButton")
    row:Dock(TOP)
    row:SetTall(35)
    row:SetText("")
    row.Paint = function(panel, w, h)
        local accent, textColor = getThemeColors()
        local selected = dashboard.SelectedKey == data.key
        if selected or panel:IsHovered() then
            drawPanel(0, 0, w, h, 2, Color(22, 39, 51, selected and 243 or 185), Color(accent.r, accent.g, accent.b, selected and 145 or 62))
            if selected then surface.SetDrawColor(accent) surface.DrawRect(0, 0, 3, h) end
        elseif panel.rowIndex % 2 == 0 then
            surface.SetDrawColor(16, 36, 42, 135)
            surface.DrawRect(0, 0, w, h)
        end
        local pathWidth = math.max(80, w * 0.50 - 15)
        draw.SimpleText(fitText(data.source, "LiliaFont.14", pathWidth), "LiliaFont.14", 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local realmColor = data.realm == 1 and serverColor or clientColor
        local realmText = data.realm == 1 and "SERVER" or "CLIENT"
        local badgeX = w * 0.52
        drawPanel(badgeX, 8, 55, 20, 3, Color(realmColor.r, realmColor.g, realmColor.b, 19), Color(realmColor.r, realmColor.g, realmColor.b, 93))
        draw.SimpleText(realmText, "LiliaFont.12", badgeX + 27, 18, realmColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.format("%.3f", data.time * 1000), "LiliaFont.14", w * 0.83, h * 0.5, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.Comma(data.calls), "LiliaFont.14", w - 12, h * 0.5, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        local share = maxTime > 0 and math.Clamp(data.time / maxTime, 0, 1) or 0
        surface.SetDrawColor(realmColor.r, realmColor.g, realmColor.b, 180)
        surface.DrawRect(1, h - 2, math.max(1, math.floor(w * share)), 2)
    end
    row.DoClick = function()
        dashboard.SelectedKey = data.key
        dashboard.SelectedData = data
        MODULE:RefreshMetrics(dashboard)
    end
    return row
end

function MODULE:CreateDetails(dashboard)
    local detailScroll = dashboard.DetailScroll
    local previousScroll = IsValid(detailScroll) and detailScroll:GetVBar():GetScroll() or 0
    local changedSelection = dashboard.LastDetailKey ~= dashboard.SelectedKey
    dashboard.LastDetailKey = dashboard.SelectedKey
    local canvas = dashboard.DetailsCanvas
    if not IsValid(canvas) then return end
    canvas:Clear()
    local data = dashboard.SelectedData
    if not data then
        local blank = canvas:Add("DPanel")
        blank:Dock(TOP)
        blank:SetTall(180)
        blank.Paint = function(_, w, h)
            drawIcon(iconChart, w * 0.5 - 16, 30, 32, mutedColor)
            draw.SimpleText("Select a source", "LiliaFont.20", w * 0.5, 90, Color(210, 226, 232), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Inspect execution time and callback activity", "LiliaFont.14", w * 0.5, 118, mutedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return
    end
    local accent, textColor = getThemeColors()
    local heading = canvas:Add("DPanel")
    heading:Dock(TOP)
    heading:SetTall(67)
    heading.Paint = function(_, w)
        drawIcon(iconDocument, 10, 10, 22, textColor)
        draw.SimpleText(fitText(data.source, "LiliaFont.19", w - 110), "LiliaFont.19", 39, 10, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(data.realm == 1 and "SERVER LUA" or "CLIENT LUA", "LiliaFont.14", 39, 39, data.realm == 1 and serverColor or clientColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    local summary = canvas:Add("DPanel")
    summary:Dock(TOP)
    summary:SetTall(75)
    summary:DockMargin(0, 0, 0, 12)
    summary.Paint = function(_, w, h)
        local cards = {
            {"TOTAL TIME", string.format("%.3f ms", data.time * 1000)},
            {"TOTAL CALLS", string.Comma(data.calls)},
            {"AVG / CALL", string.format("%.4f ms", data.calls > 0 and data.time * 1000 / data.calls or 0)}
        }
        local gap = 7
        local unit = (w - gap * 2) / 3
        for i, item in ipairs(cards) do
            local x = (i - 1) * (unit + gap)
            drawPanel(x, 0, unit, h, 4, Color(6, 27, 34, 225), Color(accent.r, accent.g, accent.b, 44))
            draw.SimpleText(item[1], "LiliaFont.12", x + 9, 13, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(item[2], "LiliaFont.19", x + 9, 39, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
    local section = canvas:Add("DPanel")
    section:Dock(TOP)
    section:SetTall(32)
    section.Paint = function(_, w)
        draw.SimpleText("CALLBACK BREAKDOWN", "LiliaFont.15", 0, 6, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("TOTAL MS", "LiliaFont.12", w - 8, 8, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
    local callbacks = {}
    for name, elapsed in pairs(data.funcs) do
        callbacks[#callbacks + 1] = {name = name, elapsed = elapsed, calls = data.counts[name] or 0}
    end
    table.sort(callbacks, function(a, b) return a.elapsed > b.elapsed end)
    for i, callback in ipairs(callbacks) do
        local entry = callback
        local row = canvas:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(45)
        row:DockMargin(0, 0, 0, 4)
        row.Paint = function(_, w, h)
            local share = data.time > 0 and math.Clamp(entry.elapsed / data.time, 0, 1) or 0
            drawPanel(0, 0, w, h, 3, Color(7, 27, 34, 195), Color(accent.r, accent.g, accent.b, 38))
            draw.SimpleText(fitText(entry.name, "LiliaFont.14", w - 115), "LiliaFont.14", 9, 6, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(string.format("%.3f ms", entry.elapsed * 1000), "LiliaFont.14", w - 9, 6, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(string.Comma(entry.calls) .. " calls", "LiliaFont.12", 9, 26, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local bx = math.min(116, w * 0.38)
            surface.SetDrawColor(56, 76, 89, 175)
            surface.DrawRect(bx, 30, math.max(1, w - bx - 9), 5)
            surface.SetDrawColor((data.realm == 1 and serverColor or clientColor))
            surface.DrawRect(bx, 30, math.max(1, (w - bx - 9) * share), 5)
        end
        if i >= 40 then break end
    end
    canvas:InvalidateLayout(true)
    if not changedSelection and IsValid(detailScroll) then detailScroll:GetVBar():SetScroll(previousScroll) end
end

function MODULE:RefreshMetrics(panel)
    if not IsValid(panel) or currentPanel ~= panel then return end
    local list = panel.MetricList
    if not IsValid(list) then return end
    local rows = panel.Frozen and panel.FrozenRows or self:MergeProfileMetrics()
    panel.RealmSummary = {
        [0] = self:GetRealmSummary(rows, 0),
        [1] = self:GetRealmSummary(rows, 1)
    }
    local visible = {}
    local search = string.Trim(string.lower(panel.SearchText or ""))
    for _, data in ipairs(rows) do
        if (panel.RealmFilter == "all" or (panel.RealmFilter == "client" and data.realm == 0) or (panel.RealmFilter == "server" and data.realm == 1)) and (search == "" or string.find(string.lower(data.source), search, 1, true)) then
            visible[#visible + 1] = data
        end
    end
    panel.VisibleCount = #visible
    local selected
    for _, data in ipairs(visible) do
        if data.key == panel.SelectedKey then selected = data break end
    end
    panel.SelectedData = selected
    local scroll = panel.MetricScroll
    local previousScroll = IsValid(scroll) and IsValid(scroll:GetVBar()) and scroll:GetVBar():GetScroll() or 0
    list:Clear()
    for i, data in ipairs(visible) do
        local row = self:CreateMetricRow(list, data, visible[1] and visible[1].time or 0, panel)
        row.rowIndex = i
    end
    if #visible == 0 then
        local empty = list:Add("DPanel")
        empty:Dock(TOP)
        empty:SetTall(120)
        empty.Paint = function(_, w, h)
            drawIcon(iconChart, w * 0.5 - 12, 15, 24, mutedColor)
            draw.SimpleText(search ~= "" and "No matching sources" or "No profiling samples", "LiliaFont.19", w * 0.5, 67, Color(207, 223, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Start a profiler or adjust the filters", "LiliaFont.14", w * 0.5, 94, mutedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    list:InvalidateLayout(true)
    if IsValid(scroll) and IsValid(scroll:GetVBar()) then scroll:GetVBar():SetScroll(previousScroll) end
    self:CreateDetails(panel)
end

function MODULE:BuildPanel(parent)
    parent:Clear()
    parent:DockPadding(0, 0, 0, 0)
    parent.Frozen = false
    parent.SearchText = ""
    parent.RealmFilter = "all"
    parent.RealmSummary = {[0] = {time = 0, sources = 0, calls = 0}, [1] = {time = 0, sources = 0, calls = 0}}
    parent.OnRemove = function(panel)
        if currentPanel ~= panel then return end
        currentPanel = nil
        net.Start("liaPerformanceProfileSubscription")
        net.WriteBool(false)
        net.SendToServer()
    end
    local dashboard = parent:Add("DPanel")
    dashboard:Dock(TOP)
    dashboard:SetTall(191)
    dashboard:DockMargin(0, 0, 0, 10)
    dashboard.Paint = function() end
    local clientCard = self:CreateRealmCard(dashboard, 0, parent)
    local serverCard = self:CreateRealmCard(dashboard, 1, parent)
    dashboard.PerformLayout = function(_, w, h)
        local half = math.floor((w - 10) * 0.5)
        clientCard:SetPos(0, 0)
        clientCard:SetSize(half, h)
        serverCard:SetPos(half + 10, 0)
        serverCard:SetSize(w - half - 10, h)
    end
    local toolbar = parent:Add("DPanel")
    toolbar:Dock(TOP)
    toolbar:SetTall(40)
    toolbar:DockMargin(0, 0, 0, 10)
    toolbar.Paint = function() end
    local filters = {}
    for _, option in ipairs({{"All Sources", "all"}, {"Client", "client"}, {"Server", "server"}}) do
        local filter = option[2]
        filters[#filters + 1] = createButton(toolbar, option[1], function()
            parent.RealmFilter = filter
            MODULE:RefreshMetrics(parent)
        end, 38, function() return parent.RealmFilter == filter end)
    end
    local search = toolbar:Add("DTextEntry")
    search:SetFont("LiliaFont.15")
    search:SetText("")
    search:SetUpdateOnType(true)
    search.Paint = function(entry, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 4, Color(20, 31, 40, 225), Color(accent.r, accent.g, accent.b, 45))
        if entry:GetText() == "" and not entry:HasFocus() then draw.SimpleText("Search sources...", "LiliaFont.15", 11, h * 0.5, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        entry:DrawTextEntryText(Color(223, 235, 240), accent, Color(223, 235, 240))
    end
    search.OnValueChange = function(_, value)
        parent.SearchText = value
        MODULE:RefreshMetrics(parent)
    end
    local freeze = createButton(toolbar, function() return parent.Frozen and "Unfreeze Samples" or "Freeze Samples" end, function()
        parent.Frozen = not parent.Frozen
        parent.FrozenRows = parent.Frozen and MODULE:MergeProfileMetrics() or nil
        MODULE:RefreshMetrics(parent)
    end, 38, function() return parent.Frozen end)
    local native = createButton(toolbar, "Hide Native Activity", function()
        MODULE.hideNativeMetrics = not MODULE.hideNativeMetrics
        MODULE:RefreshMetrics(parent)
    end, 38, function() return MODULE.hideNativeMetrics end)
    local refresh = createButton(toolbar, "Refresh", function()
        parent.Frozen = false
        parent.FrozenRows = nil
        MODULE:RefreshMetrics(parent)
    end, 38)
    toolbar.PerformLayout = function(_, w, h)
        local gap = 7
        local fixed = {86, 66, 66, 126, 157, 79}
        local remaining = math.max(125, w - 6 * gap - 580)
        local x = 0
        for i, filter in ipairs(filters) do
            filter:SetPos(x, 0)
            filter:SetSize(fixed[i], h)
            x = x + fixed[i] + gap
        end
        search:SetPos(x, 0)
        search:SetSize(remaining, h)
        x = x + remaining + gap
        for _, button in ipairs({freeze, native, refresh}) do
            local size = button == freeze and fixed[4] or button == native and fixed[5] or fixed[6]
            button:SetPos(x, 0)
            button:SetSize(size, h)
            x = x + size + gap
        end
    end
    local body = parent:Add("DPanel")
    body:Dock(FILL)
    body.Paint = function() end
    local sources = createCard(body)
    local details = createCard(body)
    body.PerformLayout = function(_, w, h)
        local left = math.floor((w - 10) * 0.57)
        sources:SetPos(0, 0)
        sources:SetSize(left, h)
        details:SetPos(left + 10, 0)
        details:SetSize(w - left - 10, h)
    end
    local sourceHeader = sources:Add("DPanel")
    sourceHeader:Dock(TOP)
    sourceHeader:SetTall(37)
    sourceHeader.Paint = function(_, w, h)
        draw.SimpleText("SOURCE", "LiliaFont.13", 12, 13, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("REALM", "LiliaFont.13", w * 0.52, 13, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("TIME (MS)", "LiliaFont.13", w * 0.83, 13, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("CALLS", "LiliaFont.13", w - 12, 13, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(60, 85, 102, 155)
        surface.DrawRect(0, h - 1, w, 1)
    end
    local metricScroll = sources:Add("liaScrollPanel")
    metricScroll:Dock(FILL)
    metricScroll:DockMargin(5, 0, 5, 5)
    parent.MetricScroll = metricScroll
    parent.MetricList = metricScroll:GetCanvas()
    parent.MetricList:DockPadding(0, 0, 5, 0)
    local detailScroll = details:Add("liaScrollPanel")
    detailScroll:Dock(FILL)
    detailScroll:DockMargin(12, 8, 12, 10)
    parent.DetailScroll = detailScroll
    parent.DetailsCanvas = detailScroll:GetCanvas()
    parent.DetailsCanvas:DockPadding(0, 0, 5, 0)
    currentPanel = parent
    net.Start("liaPerformanceProfileSubscription")
    net.WriteBool(true)
    net.SendToServer()
    MODULE:RefreshMetrics(parent)
end

function MODULE:PopulateAdminTabs(pages)
    pages[#pages + 1] = {
        name = "Performance Metrics",
        description = "Monitor Lua execution and identify expensive callbacks.",
        icon = "icon16/chart_bar.png",
        shouldShow = function() return self:CanViewMetrics(LocalPlayer()) end,
        drawFunc = function(panel) self:BuildPanel(panel) end
    }
end

function MODULE:F1MenuClosed()
    currentPanel = nil
    net.Start("liaPerformanceProfileSubscription")
    net.WriteBool(false)
    net.SendToServer()
end

function MODULE:Think()
    if nextRefresh > CurTime() then return end
    local now = CurTime()
    if self.profilingCollecting and not self.profilingFrozen then
        clientMetrics = self:GetReadableMetrics()
        table.Empty(self.profileMetrics)
        table.Empty(self.profileCounts)
    end
    if self.serverProfilingCollecting then
        for source, data in pairs(serverMetrics) do
            if data.expires and data.expires < now then serverMetrics[source] = nil end
        end
    end
    if IsValid(currentPanel) and not currentPanel.Frozen then self:RefreshMetrics(currentPanel) end
    nextRefresh = now + math.Clamp(self.profileRefreshRate, 0.1, 5)
end

net.Receive("liaPerformanceProfileMetric", function()
    if not MODULE:CanViewMetrics(LocalPlayer()) then return end
    local source = net.ReadString()
    local time = net.ReadFloat()
    local calls = net.ReadUInt(32)
    local count = net.ReadUInt(4)
    local funcs = {}
    local counts = {}
    for _ = 1, count do
        local name = net.ReadString()
        funcs[name] = net.ReadFloat()
        counts[name] = net.ReadUInt(32)
    end
    MODULE:ReceiveServerMetrics(source, time, calls, funcs, counts)
end)

net.Receive("liaPerformanceProfileClear", function()
    MODULE:ClearDisplayedMetrics(1, currentPanel)
end)

net.Receive("liaPerformanceProfileState", function()
    MODULE.profilingFrozen = net.ReadBool()
    MODULE.profileRefreshRate = math.Clamp(net.ReadFloat(), 0.1, 5)
    MODULE.serverProfilingStarted = net.ReadBool()
    MODULE.serverProfilingCollecting = net.ReadBool()
    if IsValid(currentPanel) then MODULE:RefreshMetrics(currentPanel) end
end)
