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
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)
    self.canvas = self.scroll:GetCanvas()
    self.search.OnTextChanged = function() self:Refresh() end
end

function PANEL:SetPlaceholderText(t)
    self.search:SetPlaceholderText(t or "")
end

function PANEL:PerformLayout()
    self:SizeToChildren(false, true)
    if self.scroll then self.scroll:InvalidateLayout(true) end
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
    return self:AddRow(function(p, row)
        widget:SetParent(p)
        if opts.dock ~= false then widget:Dock(FILL) end
        local h = opts.height or 200
        p:SetTall(h)
        p.PerformLayout = function() if not opts.height then p:SizeToChildren(false, true) end end
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
    local row = self:AddRow(function(p, row)
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

        p.PerformLayout = function()
            local pad = self.padding
            if compact then pad = math.ceil(pad * 0.5) end
            local spacing = compact and 2 or 5
            t:SetPos(pad, pad)
            if d then
                d:SetPos(pad, pad + t:GetTall() + spacing)
                d:SetWide(p:GetWide() - pad * 2 - (r and r:GetWide() + 10 or 0))
                d:SizeToContentsY()
            end

            if r then
                local y = d and pad + t:GetTall() + spacing + d:GetTall() - r:GetTall() or p:GetTall() * 0.5 - r:GetTall() * 0.5
                r:SetPos(p:GetWide() - r:GetWide() - pad, math.max(pad, y))
            end

            local textH = pad + t:GetTall() + (d and spacing + d:GetTall() or 0) + pad
            p:SetTall(math.max(minHeight, textH))
        end

        row.filterText = (title .. " " .. desc .. " " .. right):lower()
    end)

    row.panel:InvalidateLayout(true)
    return row
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
        cat.Header:SetTall(28)
        cat.Header.Paint = function(pnl, w, h)
            derma.SkinHook("Paint", "Panel", pnl, w, h)
            draw.SimpleText(title, "liaSmallFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    local row = self:AddRow(function(p, row)
        local html = vgui.Create("DHTML", p)
        html:SetSize(size, size)
        if url ~= "" then html:OpenURL(url) end
        html:SetMouseInputEnabled(false)
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
            html:SetPos(pad, pad)
            t:SetPos(pad + size + pad, pad)
            if d then
                d:SetPos(pad + size + pad, pad + t:GetTall() + 5)
                d:SetWide(p:GetWide() - (pad + size + pad) - pad - (r and r:GetWide() + 10 or 0))
                d:SizeToContentsY()
            end

            if r then
                local y = d and pad + t:GetTall() + 5 + d:GetTall() - r:GetTall() or p:GetTall() * 0.5 - r:GetTall() * 0.5
                r:SetPos(p:GetWide() - r:GetWide() - pad, math.max(pad, y))
            end

            local textH = d and t:GetTall() + 5 + d:GetTall() or t:GetTall()
            local h = math.max(size, textH) + pad * 2
            p:SetTall(h)
        end

        row.filterText = (title .. " " .. desc .. " " .. right):lower()
    end)

    row.panel:InvalidateLayout(true)
    return row
end

function PANEL:AddListViewRow(cfg)
    cfg = cfg or {}
    local cols = cfg.columns or {}
    local data = cfg.data or {}
    local height = cfg.height or 260
    local getLineText = cfg.getLineText
    local row = self:AddRow(function(p, row)
        local lv = vgui.Create("DListView", p)
        lv:Dock(FILL)
        for _, v in ipairs(cols) do
            lv:AddColumn(v)
        end

        for _, v in ipairs(data) do
            lv:AddLine(unpack(v))
        end

        p:SetTall(height)
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

    row.panel:InvalidateLayout(true)
    return row
end

function PANEL:AddIconLayoutRow(cfg)
    cfg = cfg or {}
    local height = cfg.height or 240
    local build = cfg.build
    local space = cfg.space or 6
    local row = self:AddRow(function(p, row)
        local layout = vgui.Create("DIconLayout", p)
        layout:Dock(FILL)
        layout:SetSpaceX(space)
        layout:SetSpaceY(space)
        if build then build(layout) end
        p:SetTall(height)
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

    row.panel:InvalidateLayout(true)
    return row
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
end

vgui.Register("liaSheet", PANEL, "DPanel")