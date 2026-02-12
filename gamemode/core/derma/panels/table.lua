local PANEL = {}
function PANEL:Init()
    self.columns = {}
    self.rows = {}
    self.headerHeight = 36
    self.rowHeight = 32
    self.font = "LiliaFont.18"
    self.rowFont = "LiliaFont.16"
    self.selectedRow = nil
    self.sortColumn = nil
    self.hoverAnim = 0
    self.padding = 8
    self.isRebuilding = false
    self.autoSizeScheduled = false
    self.header = vgui.Create("Panel", self)
    self.header:Dock(TOP)
    self.header:SetTall(self.headerHeight)
    self.scrollPanel = vgui.Create("liaScrollPanel", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(0, 0, 0, 0)
    self.content = vgui.Create("Panel", self.scrollPanel.pnlCanvas)
    self.content:Dock(TOP)
    self.content:DockMargin(0, 0, 0, 0)
    self.content.Paint = nil
    self.OnAction = function() end
    self.OnRightClick = function() end
    self.customMenuOptions = {}
    self.batchMode = true
    self.batchRows = {}
end

function PANEL:AddColumn(name, width, align, sortable)
    local column = {
        name = name,
        width = width or 100,
        align = align or TEXT_ALIGN_LEFT,
        sortable = sortable ~= false,
        autoSize = true,
        minWidth = 0,
        baseWidth = width or 100
    }

    column.Header = {
        GetFont = function() return self.font end,
        GetText = function() return name end
    }

    column.SetMinWidth = function(_, minWidth)
        column.minWidth = minWidth
        if column.width < minWidth then column.width = minWidth end
    end

    column.SetMaxWidth = function(_, maxWidth) column.maxWidth = maxWidth end
    column.SetWidth = function(_, newWidth)
        column.width = newWidth
        column.autoSize = false
    end

    table.insert(self.columns, column)
    self:RebuildRows()
    return column
end

function PANEL:AddItem(...)
    local args = {...}
    if #args ~= #self.columns then return end
    if self.batchMode then
        table.insert(self.batchRows, args)
        local rowIndex = #self.batchRows
        local proxy = {}
        local rowData = self.batchRows[rowIndex]
        setmetatable(proxy, {
            __index = function(_, key) return rowData[key] end,
            __newindex = function(_, key, value) rowData[key] = value end
        })
        return proxy
    else
        table.insert(self.rows, args)
        local rowIndex = #self.rows
        self:RebuildRows()
        local proxy = {}
        local rowData = self.rows[rowIndex]
        setmetatable(proxy, {
            __index = function(_, key) return rowData[key] end,
            __newindex = function(_, key, value) rowData[key] = value end
        })
        return proxy
    end
end

function PANEL:AddLine(...)
    return self:AddItem(...)
end

function PANEL:AddRow(...)
    return self:AddItem(...)
end

function PANEL:CreateHeader()
    self.header:Clear()
    self.header.Paint = function(_, w, h)
        local accent = lia.color.theme.accent or lia.color.theme.theme or Color(116, 185, 255)
        lia.derma.rect(0, 0, w, h):Radii(16, 16, 0, 0):Color(Color(255, 255, 255, 4)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, h - 2, w, 2):Color(ColorAlpha(accent, 150)):Draw()
    end

    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create("DButton", self.header)
        label:SetText("")
        label:SetSize(column.width, self.headerHeight)
        label:SetPos(xPos, 0)
        label.Paint = function(s, w, h)
            local textColor = lia.color.theme.text
            local align = column.align or 0
            local x = w / 2
            local xAlign = 1
            if align == 0 then
                x = self.padding
                xAlign = 0
            elseif align == 2 then
                x = w - self.padding
                xAlign = 2
            end

            draw.SimpleText(column.name, self.font, x, h / 2, textColor, xAlign, 1)
            if i < #self.columns then
                local accent = lia.color.theme.accent or lia.color.theme.theme or Color(116, 185, 255)
                local dividerColor = ColorAlpha(accent, 60)
                lia.derma.rect(w - 2, 8, 2, h - 16):Color(dividerColor):Draw()
            end
        end

        if column.sortable then
            label.DoClick = function()
                local desc = (self.sortColumn == i and not self.sortDesc) or false
                self:SortByColumn(i, desc)
                lia.websound.playButtonSound()
            end
        end

        xPos = xPos + column.width
    end
end

function PANEL:CalculateColumnWidths()
    for _, column in ipairs(self.columns) do
        column.width = column.baseWidth or column.width
    end

    local autoSizeColumns = {}
    for colIndex, column in ipairs(self.columns) do
        if column.autoSize then
            local maxWidth = 0
            surface.SetFont(self.font)
            local headerWidth = surface.GetTextSize(column.name or "")
            maxWidth = math.max(maxWidth, headerWidth + self.padding * 2)
            surface.SetFont(self.rowFont)
            for _, rowData in ipairs(self.rows) do
                if rowData[colIndex] then
                    local textWidth = surface.GetTextSize(tostring(rowData[colIndex] or ""))
                    maxWidth = math.max(maxWidth, textWidth + self.padding * 2)
                end
            end

            local calculatedWidth = math.max(maxWidth, column.minWidth or 60)
            if column.maxWidth then calculatedWidth = math.min(calculatedWidth, column.maxWidth) end
            column.width = calculatedWidth
            table.insert(autoSizeColumns, colIndex)
        end
    end

    if #autoSizeColumns > 0 then
        local totalUsedWidth = 0
        for _, column in ipairs(self.columns) do
            totalUsedWidth = totalUsedWidth + column.width
        end

        local availableWidth = self:GetWide()
        if IsValid(self.scrollPanel) and IsValid(self.scrollPanel.VBar) and self.scrollPanel.VBar:IsVisible() then availableWidth = availableWidth - self.scrollPanel.VBar:GetWide() end
        local remainingWidth = availableWidth - totalUsedWidth
        if remainingWidth > 0 then
            local extraWidthPerColumn = math.floor(remainingWidth / #autoSizeColumns)
            local remainder = remainingWidth % #autoSizeColumns
            for i, colIndex in ipairs(autoSizeColumns) do
                local extraWidth = extraWidthPerColumn
                if i <= remainder then extraWidth = extraWidth + 1 end
                self.columns[colIndex].width = self.columns[colIndex].width + extraWidth
            end
        end
    end
end

function PANEL:RebuildRows()
    self:InvalidateLayout(true)
    self:CalculateColumnWidths()
    self.content:Clear()
    self:CreateHeader()
    local totalWidth = 0
    for _, column in ipairs(self.columns) do
        totalWidth = totalWidth + column.width
    end

    for rowIndex, rowData in ipairs(self.rows) do
        self:CreateRow(rowIndex, rowData)
    end

    local contentWidth = math.max(totalWidth, self.scrollPanel:GetWide())
    local contentHeight = #self.rows * (self.rowHeight + 1)
    self.content:SetSize(contentWidth, contentHeight)
    if not self.isRebuilding then
        self.isRebuilding = true
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:RecalculateColumnWidths()
                self.isRebuilding = nil
            end
        end)
    end
end

function PANEL:RecalculateColumnWidths()
    if self.isRebuilding then return end
    if not self.font or not self.rowFont then return end
    local oldWidths = {}
    for i, column in ipairs(self.columns) do
        oldWidths[i] = column.width
    end

    self:CalculateColumnWidths()
    local widthsChanged = false
    for i, column in ipairs(self.columns) do
        if oldWidths[i] ~= column.width then
            widthsChanged = true
            break
        end
    end

    if widthsChanged then
        self.isRebuilding = true
        self:RebuildRows()
        self.isRebuilding = nil
    end
end

function PANEL:SetAction(func)
    self.OnAction = func
end

function PANEL:SetRightClickAction(func)
    self.OnRightClick = func
end

function PANEL:AddMenuOption(text, callback, icon, shouldShow)
    table.insert(self.customMenuOptions, {
        text = text,
        callback = callback,
        icon = icon,
        shouldShow = shouldShow
    })
end

function PANEL:RemoveMenuOption(text)
    for i, option in ipairs(self.customMenuOptions) do
        if option.text == text then
            table.remove(self.customMenuOptions, i)
            break
        end
    end
end

function PANEL:ClearMenuOptions()
    self.customMenuOptions = {}
end

function PANEL:Clear()
    self:EnsureCommitted()
    self.rows = {}
    self.selectedRow = nil
    self.batchRows = {}
    self.content:Clear()
end

function PANEL:ClearSelection()
    self.selectedRow = nil
end

function PANEL:ClearLines()
    self:Clear()
end

function PANEL:GetSelectedRow()
    self:EnsureCommitted()
    return self.selectedRow and self.rows[self.selectedRow] or nil
end

function PANEL:GetRowCount()
    self:EnsureCommitted()
    return #self.rows
end

function PANEL:RemoveRow(index)
    if index and index > 0 and index <= #self.rows then
        table.remove(self.rows, index)
        if self.selectedRow == index then
            self.selectedRow = nil
        elseif self.selectedRow and self.selectedRow > index then
            self.selectedRow = self.selectedRow - 1
        end

        self:RebuildRows()
        self.scrollPanel:InvalidateLayout(true)
    end
end

function PANEL:GetLine(id)
    self:EnsureCommitted()
    return self.rows[id]
end

function PANEL:SetMultiSelect()
end

function PANEL:OnSizeChanged()
    self:EnsureCommitted()
    if #self.columns > 0 then
        self:CalculateColumnWidths()
        if #self.rows > 0 then
            self:RebuildRows()
        else
            self:CreateHeader()
        end
    end
end

function PANEL:SetMinHeight(height)
    self.minHeight = tonumber(height) or self.minHeight
    if self:GetTall() < self.minHeight then self:SetTall(self.minHeight) end
end

function PANEL:Paint(w, h)
    local bgColor = Color(25, 28, 35, 250)
    lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 180)):Shadow(15, 20):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(16):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

function PANEL:DoDoubleClick(lineID, line)
    if self.OnRowDoubleClick then self:OnRowDoubleClick(lineID, line) end
end

function PANEL:OnRowRightClick(_, line)
    if self.OnRightClick then self:OnRightClick(line) end
end

function PANEL:OnRowSelected()
end

function PANEL:OnClickLine(line, isSelected)
    if self.OnRowClick then self:OnRowClick(line, isSelected) end
end

function PANEL:OnRequestResize(_, iWidth, iHeight)
    return iWidth, iHeight
end

function PANEL:ColumnWidth(i)
    if self.columns[i] then return self.columns[i].width end
    return 0
end

function PANEL:DataLayout()
    return self.dataLayout or "default"
end

function PANEL:DisableScrollbar()
    if self.scrollPanel and self.scrollPanel.GetVBar then self.scrollPanel:GetVBar():SetEnabled(false) end
end

function PANEL:FixColumnsLayout()
    self:CalculateColumnWidths()
    self:RebuildRows()
end

function PANEL:GetCanvas()
    return self.content
end

function PANEL:GetDataHeight()
    return self.dataHeight or (#self.rows * (self.rowHeight + 1))
end

function PANEL:GetDirty()
    return self.dirty or false
end

function PANEL:GetHeaderHeight()
    return self.headerHeight
end

function PANEL:GetHideHeaders()
    return self.hideHeaders or false
end

function PANEL:GetInnerTall()
    return self:GetTall() - self.headerHeight
end

function PANEL:GetMultiSelect()
    return self.multiSelect or false
end

function PANEL:GetSortable()
    for _, column in ipairs(self.columns) do
        if column.sortable then return true end
    end
    return false
end

function PANEL:GetSortedID()
    return self.sortColumn or 1
end

function PANEL:RemoveLine(lineID)
    if lineID and lineID > 0 and lineID <= #self.rows then
        table.remove(self.rows, lineID)
        if self.selectedRow == lineID then
            self.selectedRow = nil
        elseif self.selectedRow and self.selectedRow > lineID then
            self.selectedRow = self.selectedRow - 1
        end

        self:RebuildRows()
        self.scrollPanel:InvalidateLayout(true)
    end
end

function PANEL:SortByColumn(columnIndex, desc)
    self:EnsureCommitted()
    local column = self.columns[columnIndex]
    if not column or not column.sortable then return end
    self.sortColumn = columnIndex
    self.sortDesc = desc or false
    local function extractNumber(str)
        if not str then return nil end
        str = tostring(str)
        local num = tonumber(str)
        if num then return num end
        local match = string.match(str, "([%-%+]?%d+%.?%d*)")
        if match then
            num = tonumber(match)
            if num then return num end
        end
        return nil
    end

    local function compareValues(a, b)
        local strA = a ~= nil and tostring(a) or ""
        local strB = b ~= nil and tostring(b) or ""
        local numA = extractNumber(strA)
        local numB = extractNumber(strB)
        if numA and numB then
            if self.sortDesc then
                return numA > numB
            else
                return numA < numB
            end
        else
            if self.sortDesc then
                return strA > strB
            else
                return strA < strB
            end
        end
    end

    table.sort(self.rows, function(a, b) return compareValues(a[columnIndex], b[columnIndex]) end)
    self:RebuildRows()
end

function PANEL:SortByColumns(...)
    local args = {...}
    if #args == 0 then return end
    self:SortByColumn(args[1])
end

function PANEL:SetDataHeight(height)
    self.dataHeight = height or (#self.rows * (self.rowHeight + 1))
    self:RebuildRows()
end

function PANEL:SetDirty(dirty)
    self.dirty = dirty or false
end

function PANEL:SetHeaderHeight(height)
    self.headerHeight = height or 36
    if self.header then self.header:SetTall(self.headerHeight) end
    self:RebuildRows()
end

function PANEL:SetHideHeaders(hide)
    self.hideHeaders = hide or false
    if self.header then self.header:SetVisible(not self.hideHeaders) end
    self:RebuildRows()
end

function PANEL:SetMultiSelect(multi)
    self.multiSelect = multi or false
end

function PANEL:SetSortable(sortable)
    for _, column in ipairs(self.columns) do
        column.sortable = sortable or false
    end
end

function PANEL:CreateRow(rowIndex, rowData)
    local row = vgui.Create("DButton", self.content)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 1)
    row:SetTall(self.rowHeight)
    row:SetText("")
    row:SetMouseInputEnabled(true)
    row:SetKeyboardInputEnabled(false)
    row:SetZPos(100)
    row.Paint = function(s, w, h)
        local colors = lia.color.theme
        local accent = colors.accent or colors.theme or Color(116, 185, 255)
        local bgColor = Color(255, 255, 255, 4)
        if self.selectedRow == rowIndex then bgColor = ColorAlpha(accent, 80) end
        lia.derma.rect(0, 0, w, h):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        if self.selectedRow == rowIndex then lia.derma.rect(0, 0, 2, h):Color(accent):Draw() end
    end

    row.DoClick = function()
        local wasSelected = self.selectedRow == rowIndex
        if self.multiSelect then
            self.selectedRow = rowIndex
        else
            self.selectedRow = rowIndex
        end

        if self.OnRowSelected then self:OnRowSelected(rowIndex, rowData) end
        if self.OnClickLine then self:OnClickLine(rowData, not wasSelected) end
        if self.OnAction then self:OnAction(rowData) end
        lia.websound.playButtonSound()
    end

    row.DoDoubleClick = function() self:DoDoubleClick(rowIndex, rowData) end
    row.DoRightClick = function()
        if not self.multiSelect then self.selectedRow = rowIndex end
        self:OnRowRightClick(rowIndex, rowData)
        if self.OnRightClick then self:OnRightClick(rowData) end
        local menu = lia.derma.dermaMenu()
        local addedAny = false
        for _, option in ipairs(self.customMenuOptions) do
            local canShow = true
            if option.shouldShow then canShow = option.shouldShow(rowData, rowIndex) ~= false end
            if canShow then
                menu:AddOption(option.text, function() option.callback(rowData, rowIndex) end, option.icon)
                addedAny = true
            end
        end

        if not addedAny then menu:AddOption(L("adminStickNoOptions"), function() end) end
        menu:Open()
    end

    local xPos = 0
    for i, column in ipairs(self.columns) do
        local cellPanel = vgui.Create("DPanel", row)
        cellPanel:SetSize(column.width, self.rowHeight)
        cellPanel:SetPos(xPos, 0)
        cellPanel:SetMouseInputEnabled(false)
        cellPanel.Paint = function(s, w, h)
            local textColor = lia.color.theme.text
            local text = tostring(rowData[i] or "")
            local align = column.align or 0
            local x = w / 2
            local xAlign = 1
            if align == 0 then
                x = self.padding
                xAlign = 0
            elseif align == 2 then
                x = w - self.padding
                xAlign = 2
            end

            draw.SimpleText(text, self.rowFont, x, h / 2, textColor, xAlign, 1)
        end

        xPos = xPos + column.width
    end
end

function PANEL:SetBatchMode(enabled)
    if not enabled and self.batchMode and #self.batchRows > 0 then self:CommitBatch() end
    self.batchMode = enabled or false
    if enabled and not self.batchRows then self.batchRows = {} end
end

function PANEL:CommitBatch()
    if #self.batchRows == 0 then return end
    for _, row in ipairs(self.batchRows) do
        table.insert(self.rows, row)
    end

    self.batchRows = {}
    self:RebuildRows()
end

function PANEL:ForceCommit()
    if #self.batchRows > 0 then self:CommitBatch() end
end

function PANEL:EnsureCommitted()
    if #self.batchRows > 0 then self:CommitBatch() end
end

function PANEL:AddItemsBatch(itemsArray, mapperFunc, filterFunc)
    if not itemsArray or not mapperFunc then return end
    self:SetBatchMode(true)
    for _, item in ipairs(itemsArray) do
        if not filterFunc or filterFunc(item) then
            local rowData = mapperFunc(item)
            if rowData then self:AddItem(unpack(rowData)) end
        end
    end

    self:CommitBatch()
end

vgui.Register("liaTable", PANEL, "Panel")
