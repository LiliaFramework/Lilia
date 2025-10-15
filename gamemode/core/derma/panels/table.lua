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
    self.content = vgui.Create("Panel", self.scrollPanel)
    self.content:Dock(FILL)
    self.content.Paint = nil
    self.OnAction = function() end
    self.OnRightClick = function() end
    self.customMenuOptions = {}
end

function PANEL:AddColumn(name, width, align, sortable)
    table.insert(self.columns, {
        name = name,
        width = width or 100,
        align = align or TEXT_ALIGN_LEFT,
        sortable = sortable or false,
        autoSize = width == nil
    })
end

function PANEL:AddItem(...)
    local args = {...}
    if #args ~= #self.columns then return end
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

function PANEL:AddLine(...)
    return self:AddItem(...)
end

function PANEL:AddRow(...)
    return self:AddItem(...)
end

function PANEL:SortByColumn(columnIndex)
    local column = self.columns[columnIndex]
    if not column or not column.sortable then return end
    self.sortColumn = columnIndex
    local function getValueType(value)
        if value == nil then return "nil" end
        value = tostring(value)
        return tonumber(value) and "number" or "string"
    end

    local function compareValues(a, b)
        if a == nil and b == nil then return false end
        if a == nil then return true end
        if b == nil then return false end
        local typeA = getValueType(a)
        local typeB = getValueType(b)
        if typeA ~= typeB then return typeA < typeB end
        if typeA == "number" then
            local numA = tonumber(a) or 0
            local numB = tonumber(b) or 0
            return numA > numB
        else
            local strA = tostring(a)
            local strB = tostring(b)
            return strA < strB
        end
    end

    local success, _ = pcall(function() table.sort(self.rows, function(a, b) return compareValues(a[columnIndex], b[columnIndex]) end) end)
    if not success then return end
    self:RebuildRows()
end

function PANEL:CreateHeader()
    self.header:Clear()
    self.header.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Radii(16, 16, 0, 0):Color(lia.color.theme.focus_panel):Shape(lia.derma.SHAPE_IOS):Draw() end
    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create("DButton", self.header)
        label:SetText("")
        label:SetSize(column.width, self.headerHeight)
        label:SetPos(xPos, 0)
        label.Paint = function(s, w, h)
            local isHovered = s:IsHovered() and column.sortable
            local isActive = self.sortColumn == i
            if isHovered then lia.derma.rect(0, 0, w, h):Radii(16, 16, 0, 0):Color(lia.color.theme.hover):Shape(lia.derma.SHAPE_IOS):Draw() end
            local textColor = isActive and lia.color.theme.theme or lia.color.theme.text
            draw.SimpleText(column.name, self.font, w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if column.sortable then
            label.DoClick = function()
                self:SortByColumn(i)
                surface.PlaySound("button_click.wav")
            end
        end

        xPos = xPos + column.width
    end
end

function PANEL:CreateRow(rowIndex, rowData)
    local row = vgui.Create("DButton", self.content)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 1)
    row:SetTall(self.rowHeight)
    row:SetText("")
    row.Paint = function(s, w, h)
        local bgColor = self.selectedRow == rowIndex and lia.color.theme.theme or (s:IsHovered() and lia.color.theme.hover or lia.color.theme.panel[1])
        lia.derma.rect(0, 0, w, h):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    row.DoClick = function()
        self.selectedRow = rowIndex
        self.OnAction(rowData)
        surface.PlaySound("button_click.wav")
    end

    row.DoRightClick = function()
        self.selectedRow = rowIndex
        self.OnRightClick(rowData)
        local menu = lia.derma.dermaMenu()
        for _, option in ipairs(self.customMenuOptions) do
            menu:AddOption(option.text, function() option.callback(rowData, rowIndex) end, option.icon)
        end

        if #self.customMenuOptions == 0 then menu:AddOption(L("adminStickNoOptions"), function() end) end
        menu:Open()
    end

    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create("DLabel", row)
        label:SetText(tostring(rowData[i]))
        label:SetFont(self.rowFont)
        label:SetTextColor(lia.color.theme.text)
        label:SetContentAlignment(column.align)
        label:SetSize(column.width, self.rowHeight)
        label:SetPos(xPos, 0)
        if column.align == TEXT_ALIGN_LEFT then
            label:SetTextInset(self.padding, 0)
        elseif column.align == TEXT_ALIGN_RIGHT then
            label:SetTextInset(0, 0, self.padding, 0)
        end

        label:SetContentAlignment(column.align + 4)
        xPos = xPos + column.width
    end
end

function PANEL:CalculateColumnWidths()
    if #self.rows == 0 then return end
    if not self.font or not self.rowFont then return end
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

            column.width = math.max(maxWidth, 60)
            table.insert(autoSizeColumns, colIndex)
        end
    end

    if #autoSizeColumns > 0 then
        local totalUsedWidth = 0
        for _, column in ipairs(self.columns) do
            totalUsedWidth = totalUsedWidth + column.width
        end

        local availableWidth = self:GetWide()
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

    local panelWidth = self:GetWide()
    self.content:SetSize(math.max(totalWidth, panelWidth), #self.rows * (self.rowHeight + 1))
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
    if #self.rows == 0 or self.isRebuilding then return end
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

function PANEL:AddMenuOption(text, callback, icon)
    table.insert(self.customMenuOptions, {
        text = text,
        callback = callback,
        icon = icon
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
    self.rows = {}
    self.selectedRow = nil
    self.content:Clear()
end

function PANEL:ClearSelection()
    self.selectedRow = nil
end

function PANEL:ClearLines()
    self:Clear()
end

function PANEL:GetSelectedRow()
    return self.selectedRow and self.rows[self.selectedRow] or nil
end

function PANEL:GetRowCount()
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
    return self.rows[id]
end

function PANEL:SetMultiSelect()
end

function PANEL:IsLineSelected(id)
    return self.selectedRow == id
end

function PANEL:SelectItem(id)
    if id < 1 or id > #self.rows then return end
    self.selectedRow = id
    if self.OnAction then self.OnAction(self.rows[id]) end
end

function PANEL:SelectFirstItem()
    if #self.rows > 0 then self:SelectItem(1) end
end

function PANEL:SelectItemByID(id)
    self:SelectItem(id)
end

function PANEL:SelectItemByLine(line)
    for idx, data in ipairs(self.rows) do
        if data == line then
            self:SelectItem(idx)
            break
        end
    end
end

function PANEL:GetSelectedLine()
    return self.selectedRow
end

function PANEL:GetSelectedLines()
    if self.selectedRow then return {self.selectedRow} end
    return {}
end

function PANEL:GetSelected()
    if not self.selectedRow then return nil end
    return self.rows[self.selectedRow]
end

function PANEL:GetLines()
    return self.rows
end

function PANEL:OnSizeChanged()
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
    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
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

function PANEL:SelectItem(lineID)
    if lineID < 1 or lineID > #self.rows then return end
    local oldSelected = self.selectedRow
    self.selectedRow = lineID
    if self.OnRowSelected and oldSelected ~= lineID then self:OnRowSelected(lineID, self.rows[lineID]) end
    if self.OnClickLine then self:OnClickLine(self.rows[lineID], true) end
end

function PANEL:SelectItemByID(id)
    self:SelectItem(id)
end

function PANEL:SelectItemByLine(line)
    for idx, data in ipairs(self.rows) do
        if data == line then
            self:SelectItem(idx)
            break
        end
    end
end

function PANEL:SelectFirstItem()
    if #self.rows > 0 then self:SelectItem(1) end
end

function PANEL:GetSelected()
    if not self.selectedRow then return nil end
    return self.rows[self.selectedRow]
end

function PANEL:GetSelectedLine()
    return self.selectedRow
end

function PANEL:GetSelectedLines()
    if self.selectedRow then return {self.selectedRow} end
    return {}
end

function PANEL:GetLine(id)
    if id and id > 0 and id <= #self.rows then return self.rows[id] end
    return nil
end

function PANEL:GetLines()
    return self.rows
end

function PANEL:SortByColumn(columnIndex, desc)
    local column = self.columns[columnIndex]
    if not column or not column.sortable then return end
    self.sortColumn = columnIndex
    self.sortDesc = desc or false
    local function getValueType(value)
        if value == nil then return "nil" end
        value = tostring(value)
        return tonumber(value) and "number" or "string"
    end

    local function compareValues(a, b)
        if a == nil and b == nil then return not self.sortDesc end
        if a == nil then return self.sortDesc end
        if b == nil then return not self.sortDesc end
        local typeA = getValueType(a)
        local typeB = getValueType(b)
        if typeA ~= typeB then return typeA < typeB end
        if typeA == "number" then
            local numA = tonumber(a) or 0
            local numB = tonumber(b) or 0
            return self.sortDesc and (numA < numB) or (numA > numB)
        else
            local strA = tostring(a)
            local strB = tostring(b)
            return self.sortDesc and (strA > strB) or (strA < strB)
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
    row.Paint = function(s, w, h)
        local bgColor = self.selectedRow == rowIndex and lia.color.theme.theme or (s:IsHovered() and lia.color.theme.hover or lia.color.theme.panel[1])
        lia.derma.rect(0, 0, w, h):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
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
        surface.PlaySound("button_click.wav")
    end

    row.DoDoubleClick = function() self:DoDoubleClick(rowIndex, rowData) end
    row.DoRightClick = function()
        if not self.multiSelect then self.selectedRow = rowIndex end
        self:OnRowRightClick(rowIndex, rowData)
        if self.OnRightClick then self:OnRightClick(rowData) end
        local menu = lia.derma.dermaMenu()
        for _, option in ipairs(self.customMenuOptions) do
            menu:AddOption(option.text, function() option.callback(rowData, rowIndex) end, option.icon)
        end

        if #self.customMenuOptions == 0 then menu:AddOption(L("adminStickNoOptions"), function() end) end
        menu:Open()
    end

    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create("DLabel", row)
        label:SetText(tostring(rowData[i]))
        label:SetFont(self.rowFont)
        label:SetTextColor(lia.color.theme.text)
        label:SetContentAlignment(column.align)
        label:SetSize(column.width, self.rowHeight)
        label:SetPos(xPos, 0)
        if column.align == TEXT_ALIGN_LEFT then
            label:SetTextInset(self.padding, 0)
        elseif column.align == TEXT_ALIGN_RIGHT then
            label:SetTextInset(0, 0, self.padding, 0)
        end

        label:SetContentAlignment(column.align + 4)
        xPos = xPos + column.width
    end
end

vgui.Register("liaTable", PANEL, "Panel")
