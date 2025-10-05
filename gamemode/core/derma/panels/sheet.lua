local PANEL = {}
function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(10, 10, 10, 10)
    self.spacingY = 8
    self.padding = 10
    self.rows = {}
    self.search = vgui.Create("DTextEntry", self)
    self.search:Dock(TOP)
    self.search:SetTall(30)
    self.search:DockMargin(0, 0, 0, 8)
    self.scroll = vgui.Create("liaScrollPanel", self)
    self.scroll:Dock(FILL)
    self.scroll:InvalidateLayout(true) -- Ensure proper layout initialization
    -- Ensure scrollbar is properly initialized
    if not IsValid(self.scroll.VBar) then self.scroll:PerformLayout() end
    self.canvas = self.scroll:GetCanvas()
    self.search.OnTextChanged = function() self:Refresh() end
end

function PANEL:SetPlaceholderText(t)
    self.search:SetPlaceholderText(t or "")
end

function PANEL:PerformLayout()
    self:SizeToChildren(false, true)
    if self.scroll then
        self.scroll:InvalidateLayout(true)
        -- Ensure all rows get properly laid out when container resizes
        for _, row in ipairs(self.rows) do
            if row.panel and row.panel.PerformLayout then
                row.panel:PerformLayout()
                row.panel:InvalidateLayout(true)
            end
        end
    end
end

function PANEL:SetSpacing(y)
    self.spacingY = y or self.spacingY
end

function PANEL:SetPadding(p)
    self.padding = p or self.padding
end

function PANEL:Clear()
    self.canvas:Clear()
    self.rows = {}
end

function PANEL:AddRow(builder)
    local p = vgui.Create("DPanel", self.canvas)
    p:Dock(TOP)
    p:DockMargin(0, 0, 0, self.spacingY)
    p:DockPadding(self.padding, self.padding, self.padding, self.padding)
    p.Paint = function(pnl, w, h) derma.SkinHook("Paint", "Panel", pnl, w, h) end
    local row = {
        panel = p,
        filterText = "",
        filterFunc = nil
    }

    builder(p, row)
    self.rows[#self.rows + 1] = row
    return row
end

function PANEL:AddPanelRow(widget, opts)
    opts = opts or {}
    local responsiveHeight = opts.responsiveHeight ~= false -- Default to true for responsive behavior
    local minHeight = opts.minHeight or 100
    local maxHeight = opts.maxHeight or 500
    return self:AddRow(function(p, row)
        widget:SetParent(p)
        if opts.dock ~= false then widget:Dock(FILL) end
        local h = opts.height or 200
        -- Make panel row responsive
        local function updatePanelDimensions()
            if responsiveHeight and not opts.height then
                local calculatedHeight = widget:GetTall() or h
                calculatedHeight = math.max(minHeight, math.min(maxHeight, calculatedHeight))
                p:SetTall(calculatedHeight)
            else
                p:SetTall(h)
            end
        end

        p.PerformLayout = function()
            updatePanelDimensions()
            if not opts.height then p:SizeToChildren(false, true) end
        end

        row.widget = widget
        row.filterText = (opts.filterText or ""):lower()
        row.filterFunc = opts.filterFunc
    end)
end

function PANEL:AddTextRow(data)
    local title = data.title or ""
    local desc = data.desc or ""
    local right = data.right or ""
    local compact = data.compact
    local minHeight = data.minHeight or compact and 30 or 40
    local rowData = self:AddRow(function(p, row)
        local titleFont = compact and "liaSmallFont" or "liaMediumFont"
        local descFont = compact and "liaMiniFont" or "liaSmallFont"
        local t = vgui.Create("DLabel", p)
        t:SetFont(titleFont)
        t:SetText(title)
        t:SizeToContents()
        local d
        if desc ~= "" then
            d = vgui.Create("DLabel", p)
            d:SetFont(descFont)
            d:SetWrap(true)
            d:SetAutoStretchVertical(true)
            d:SetText(desc)
        end

        local r
        if right ~= "" then
            r = vgui.Create("DLabel", p)
            r:SetFont(descFont)
            r:SetText(right)
            r:SizeToContents()
        end

        p.PerformLayout = function(panel)
            local pad = self.padding
            if compact then pad = math.ceil(pad * 0.5) end
            local spacing = compact and 2 or 5
            t:SetPos(pad, pad)
            if d then
                d:SetPos(pad, pad + t:GetTall() + spacing)
                d:SetWide(panel:GetWide() - pad * 2 - (r and r:GetWide() + 10 or 0))
                d:SizeToContentsY()
            end

            if r then
                local y = d and pad + t:GetTall() + spacing + d:GetTall() - r:GetTall() or panel:GetTall() * 0.5 - r:GetTall() * 0.5
                r:SetPos(panel:GetWide() - r:GetWide() - pad, math.max(pad, y))
            end

            local textH = pad + t:GetTall() + (d and spacing + d:GetTall() or 0) + pad
            panel:SetTall(math.max(minHeight, textH))
        end

        row.filterText = (title .. " " .. desc .. " " .. right):lower()
    end)

    rowData.panel:InvalidateLayout(true)
    return rowData
end

function PANEL:AddSubsheetRow(cfg)
    cfg = cfg or {}
    local title = cfg.title or ""
    local build = cfg.build
    return self:AddRow(function(p, row)
        local cat = vgui.Create("DCollapsibleCategory", p)
        cat:Dock(FILL)
        cat:SetLabel("")
        cat:SetExpanded(false)
        if IsValid(cat.Header) then
            cat.Header:SetTall(28)
            cat.Header.Paint = function(pnl, w, h)
                derma.SkinHook("Paint", "Panel", pnl, w, h)
                draw.SimpleText(title, "liaSmallFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local subsheet = vgui.Create("liaSheet", cat)
        subsheet:Dock(FILL)
        cat:SetContents(subsheet)
        if build then build(subsheet) end
        row.widget = cat
        row.subsheet = subsheet
        row.filterFunc = function(q)
            subsheet.search:SetValue(q)
            subsheet:Refresh()
            for _, sr in ipairs(subsheet.rows or {}) do
                if sr.panel:IsVisible() then return true end
            end
            return false
        end

        row.filterText = title:lower()
    end)
end

function PANEL:AddPreviewRow(data)
    local title = data.title or ""
    local desc = data.desc or ""
    local right = data.right or ""
    local url = data.url or ""
    local size = data.size or 128
    local minSize = math.min(data.minSize or size, size)
    local maxSize = data.maxSize or math.max(size, 200)
    local rowData = self:AddRow(function(p, row)
        local html = vgui.Create("DHTML", p)
        html:SetSize(size, size)
        if url ~= "" then html:OpenURL(url) end
        html:SetMouseInputEnabled(false)
        -- Make HTML responsive to available space
        local function updateHTMLSize()
            local availableWidth = p:GetWide() - self.padding * 3
            local availableHeight = p:GetTall() - self.padding * 2
            local newSize = math.min(availableWidth, availableHeight, maxSize)
            newSize = math.max(newSize, minSize)
            html:SetSize(newSize, newSize)
        end

        local t = vgui.Create("DLabel", p)
        t:SetFont("liaMediumFont")
        t:SetText(title)
        t:SizeToContents()
        local d
        if desc ~= "" then
            d = vgui.Create("DLabel", p)
            d:SetFont("liaSmallFont")
            d:SetWrap(true)
            d:SetAutoStretchVertical(true)
            d:SetText(desc)
        end

        local r
        if right ~= "" then
            r = vgui.Create("DLabel", p)
            r:SetFont("liaSmallFont")
            r:SetText(right)
            r:SizeToContents()
        end

        p.PerformLayout = function()
            local pad = self.padding
            updateHTMLSize() -- Update HTML size based on current panel width
            local htmlSize = html:GetWide()
            t:SetPos(pad + htmlSize + pad, pad)
            if d then
                d:SetPos(pad + htmlSize + pad, pad + t:GetTall() + 5)
                d:SetWide(p:GetWide() - (pad + htmlSize + pad) - pad - (r and r:GetWide() + 10 or 0))
                d:SizeToContentsY()
            end

            if r then
                local y = d and pad + t:GetTall() + 5 + d:GetTall() - r:GetTall() or p:GetTall() * 0.5 - r:GetTall() * 0.5
                r:SetPos(p:GetWide() - r:GetWide() - pad, math.max(pad, y))
            end

            local textH = d and t:GetTall() + 5 + d:GetTall() or t:GetTall()
            local h = math.max(htmlSize, textH) + pad * 2
            p:SetTall(h)
        end

        row.filterText = (title .. " " .. desc .. " " .. right):lower()
    end)

    rowData.panel:InvalidateLayout(true)
    return rowData
end

function PANEL:AddListViewRow(cfg)
    cfg = cfg or {}
    local cols = cfg.columns or {}
    local data = cfg.data or {}
    local height = cfg.height or 260
    local getLineText = cfg.getLineText
    local autoResizeColumns = cfg.autoResizeColumns ~= false -- Default to true for responsive behavior
    local minColumnWidth = cfg.minColumnWidth or 80
    local maxColumnWidth = cfg.maxColumnWidth or 200
    local rowData = self:AddRow(function(p, row)
        local lv = vgui.Create("DListView", p)
        lv:Dock(FILL)
        -- Add columns with initial sizing
        for _, colName in ipairs(cols) do
            lv:AddColumn(colName)
        end

        for _, v in ipairs(data) do
            lv:AddLine(unpack(v))
        end

        -- Make list view responsive
        local function resizeColumns()
            if not autoResizeColumns or #cols == 0 then return end
            local totalWidth = p:GetWide()
            local availableWidth = totalWidth - 20 -- Account for scrollbar and padding
            if availableWidth <= 0 then return end
            local colWidth = math.max(minColumnWidth, math.min(maxColumnWidth, availableWidth / #cols))
            for i = 1, #cols do
                lv.Columns[i]:SetWidth(colWidth)
            end
        end

        p.PerformLayout = function()
            resizeColumns()
            p:SetTall(height)
        end

        row.widget = lv
        row.filterFunc = function(q)
            local any = false
            for _, line in ipairs(lv:GetLines() or {}) do
                local s = ""
                if getLineText then
                    s = getLineText(line) or ""
                else
                    for i = 1, #cols do
                        local v = line:GetValue(i)
                        if v then s = s .. " " .. tostring(v) end
                    end
                end

                local vis = q == "" or s:lower():find(q, 1, true) ~= nil
                line:SetVisible(vis)
                if vis then any = true end
            end
            return any
        end
    end)

    rowData.panel:InvalidateLayout(true)
    return rowData
end

function PANEL:AddIconLayoutRow(cfg)
    cfg = cfg or {}
    local build = cfg.build
    local space = cfg.space or 6
    local responsiveHeight = cfg.responsiveHeight ~= false -- Default to true
    local minHeight = cfg.minHeight or 100
    local maxHeight = cfg.maxHeight or 400
    local rowData = self:AddRow(function(p, row)
        local layout = vgui.Create("DIconLayout", p)
        layout:Dock(FILL)
        layout:SetSpaceX(space)
        layout:SetSpaceY(space)
        if build then build(layout) end
        -- Make icon layout responsive to container size
        local function updateLayoutDimensions()
            if not responsiveHeight then return end
            local children = layout:GetChildren()
            if #children == 0 then return end
            -- Calculate optimal height based on content and container width
            local containerWidth = p:GetWide()
            local iconsPerRow = math.floor((containerWidth - space) / (64 + space)) -- Assume 64px icon size
            iconsPerRow = math.max(1, iconsPerRow)
            local totalIcons = #children
            local rowsNeeded = math.ceil(totalIcons / iconsPerRow)
            local iconHeight = 64 + space -- Assume standard icon size plus spacing
            local calculatedHeight = rowsNeeded * iconHeight + space
            calculatedHeight = math.max(minHeight, math.min(maxHeight, calculatedHeight))
            p:SetTall(calculatedHeight)
        end

        p.PerformLayout = function() updateLayoutDimensions() end
        row.widget = layout
        row.filterFunc = function(q)
            local any = false
            for _, child in ipairs(layout:GetChildren()) do
                local txt = (child.filterText or ""):lower()
                local vis = q == "" or txt:find(q, 1, true) ~= nil
                child:SetVisible(vis)
                if vis then any = true end
            end

            layout:InvalidateLayout(true)
            return any
        end
    end)

    rowData.panel:InvalidateLayout(true)
    return rowData
end

function PANEL:RegisterCustomFilter(row, fn)
    row.filterFunc = fn
    return row
end

function PANEL:Refresh()
    local q = self.search:GetValue():lower()
    for _, row in ipairs(self.rows) do
        local vis
        if row.filterFunc then
            vis = row.filterFunc(q, row)
            if vis == nil then vis = true end
        else
            vis = q == "" or row.filterText and row.filterText:find(q, 1, true) ~= nil
        end

        row.panel:SetVisible(vis ~= false)
    end

    self.canvas:InvalidateLayout(true)
    self.canvas:SizeToChildren(false, true)
    -- Trigger layout updates for all visible rows after filtering
    for _, row in ipairs(self.rows) do
        if row.panel:IsVisible() and row.panel.PerformLayout then
            row.panel:PerformLayout()
            row.panel:InvalidateLayout(true)
        end
    end
end

vgui.Register("liaSheet", PANEL, "DPanel")
