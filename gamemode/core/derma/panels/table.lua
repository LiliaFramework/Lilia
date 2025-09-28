﻿local PANEL = {}
local FrameTime = FrameTime
local Lerp = Lerp
local math_max = math.max
local math_floor = math.floor
function PANEL:Init()
    self.columns = {}
    self.rows = {}
    self.headerHeight = 36
    self.rowHeight = 32
    self.font = 'Fated.18'
    self.rowFont = 'Fated.16'
    self.selectedRow = nil
    self.sortColumn = nil
    self.sortDesc = true
    self.sortState = 0
    self._originalRows = nil
    self.hoverAnim = 0
    self.padding = 8
    self.sidePadding = 12
    self.vbarRightPadding = 6
    self.vbarLeftExtra = 0
    self.header = vgui.Create("liaBasePanel", self)
    self.header:Dock(TOP)
    self.header:SetTall(self.headerHeight)
    self.scrollPanel = vgui.Create("liaScrollPanel", self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DisableVBarPadding()
    self.content = vgui.Create("liaBasePanel", self.scrollPanel)
    self.content:Dock(TOP)
    self.content.Paint = nil
    self._rowPanels = {}
    self._headerButtons = {}
    self._colWidthsTarget = {}
    self._colWidthsCurrent = {}
    self._lastVBarVis = nil
    self._headerPrevActive = {}
    self.OnAction = function() end
    self.OnRightClick = function() end
    self.Think = function()
        local dt = FrameTime()
        self:UpdateColumnWidthTargets()
        for i = 1, #self.columns do
            local tgt = self._colWidthsTarget[i] or (self.columns[i] and self.columns[i].width or 100)
            self._colWidthsCurrent[i] = lia.util.approachExp(self._colWidthsCurrent[i] or tgt, tgt, 20, dt)
        end

        local leftPad = self.sidePadding + ((self._lastVBarVis and self.vbarLeftExtra) or 0)
        local x = leftPad
        for i, btn in ipairs(self._headerButtons) do
            local w = math_floor(self._colWidthsCurrent[i] or (self.columns[i] and self.columns[i].width or 100))
            if IsValid(btn) then
                btn:SetSize(w, self.headerHeight)
                btn:SetPos(x, 0)
            end

            x = x + w
        end

        local total = 0
        for i = 1, #self.columns do
            total = total + (self._colWidthsCurrent[i] or self.columns[i].width)
        end

        local panelW = self:GetWide() or 0
        if panelW <= 0 then
            local par = self:GetParent()
            if IsValid(par) and par.GetWide then panelW = par:GetWide() end
        end

        if panelW <= 0 then panelW = ScrW() end
        local rightPad = self.sidePadding + ((self._lastVBarVis and self.vbarRightPadding) or 0)
        local contentW = math_max(total + leftPad + rightPad, panelW)
        for _, row in ipairs(self._rowPanels) do
            if IsValid(row) and row._labels then
                local x2 = leftPad
                local hv = row._hoverAlpha or 0
                local eased = lia.util.easeOutCubic(math.Clamp(hv, 0, 1))
                local shift = math_floor(6 * eased)
                for i, label in ipairs(row._labels) do
                    local w = math_floor(self._colWidthsCurrent[i] or (self.columns[i] and self.columns[i].width or 100))
                    if IsValid(label) then
                        local dx = 0
                        if i == 1 then
                            dx = shift
                        elseif i == #self.columns then
                            dx = -shift
                        end

                        label:SetSize(w, self.rowHeight)
                        label:SetPos(x2 + dx, 0)
                    end

                    x2 = x2 + w
                end

                row:SetWide(contentW)
            end
        end

        self.content:SetWide(contentW)
    end
end

function PANEL:AddColumn(name, width, align, sortable)
    table.insert(self.columns, {
        name = name,
        width = width or 100,
        align = align or TEXT_ALIGN_LEFT,
        sortable = sortable or false
    })
end

function PANEL:AddItem(...)
    local args = {...}
    if #args ~= #self.columns then
        print(L("table_wrong_args"))
        return
    end

    table.insert(self.rows, args)
    self:RebuildRows()
    return #self.rows
end

function PANEL:SortByColumn(columnIndex)
    local column = self.columns[columnIndex]
    if not column or not column.sortable then return end
    if self.sortColumn ~= columnIndex then
        self.sortColumn = columnIndex
        local numCount, total = 0, 0
        for _, row in ipairs(self.rows) do
            local v = row[columnIndex]
            if v ~= nil then
                total = total + 1
                if tonumber(tostring(v)) then numCount = numCount + 1 end
            end
        end

        local isNumeric = total > 0 and numCount >= math.ceil(total / 2)
        self.sortDesc = isNumeric
    else
        self.sortDesc = not self.sortDesc
    end

    local desc = self.sortDesc
    table.sort(self.rows, function(a, b)
        local va = a[columnIndex]
        local vb = b[columnIndex]
        if va == nil and vb == nil then return false end
        if va == nil then return not desc end
        if vb == nil then return desc end
        local sa = tostring(va)
        local sb = tostring(vb)
        local na = tonumber(sa)
        local nb = tonumber(sb)
        if na and nb then
            if desc then
                return na > nb
            else
                return na < nb
            end
        end

        if na and not nb then
            return desc
        elseif nb and not na then
            return not desc
        end

        local la = string.lower(sa)
        local lb = string.lower(sb)
        if desc then
            return la > lb
        else
            return la < lb
        end
    end)

    self:RebuildRows()
end

function PANEL:UpdateColumnWidthTargets()
    local cols = self.columns
    local n = #cols
    if n == 0 then return end
    local panelW = self:GetWide() or 0
    if (not panelW) or panelW <= 0 then
        local parent = self:GetParent()
        if IsValid(parent) and parent.GetWide then panelW = parent:GetWide() end
    end

    if (not panelW) or panelW <= 0 then panelW = ScrW() end
    local vbar = (IsValid(self.scrollPanel) and self.scrollPanel.GetVBar) and self.scrollPanel:GetVBar() or nil
    local vbarVisible = IsValid(vbar) and vbar:IsVisible()
    local vbarW = vbarVisible and vbar:GetWide() or 0
    local leftPad = self.sidePadding + (vbarVisible and self.vbarLeftExtra or 0)
    local rightPad = self.sidePadding + (vbarVisible and self.vbarRightPadding or 0)
    local usable = math_max(0, panelW - leftPad - rightPad - vbarW)
    local used = 0
    for i = 1, math.max(0, n - 1) do
        self._colWidthsTarget[i] = cols[i].width or 100
        used = used + self._colWidthsTarget[i]
    end

    local lastMin = cols[n].width or 100
    local remaining = usable - used
    if remaining < lastMin then remaining = lastMin end
    self._colWidthsTarget[n] = remaining
    for i = 1, n do
        if self._colWidthsCurrent[i] == nil then self._colWidthsCurrent[i] = self._colWidthsTarget[i] end
    end

    self._lastVBarVis = vbarVisible
end

function PANEL:CreateHeader()
    local prev = {}
    for i, btn in ipairs(self._headerButtons) do
        if IsValid(btn) then prev[i] = btn._activeAlpha or 0 end
    end

    self.header:Clear()
    self._headerButtons = {}
    self.header.Paint = function(_, w, h) lia.rndx.Rect(0, 0, w, h):Radii(16, 16, 0, 0):Color(lia.color.theme.focus_panel):Shape(lia.rndx.SHAPE_IOS):Draw() end
    self:UpdateColumnWidthTargets()
    local xPos = self.sidePadding + ((self._lastVBarVis and self.vbarLeftExtra) or 0)
    for i, column in ipairs(self.columns) do
        local w = math_floor(self._colWidthsCurrent[i] or self._colWidthsTarget[i] or column.width)
        local label = vgui.Create("liaButton", self.header)
        label:SetText('')
        label:SetSize(w, self.headerHeight)
        label:SetPos(xPos, 0)
        label._hover = 0
        label._activeAlpha = prev[i] or ((self.sortColumn == i) and 1 or 0)
        label.Paint = function(s, bw, bh)
            local dt = FrameTime()
            local target = s:IsHovered() and 1 or 0
            s._hover = lia.util.approachExp(s._hover or 0, target, 14, dt)
            local activeTarget = (self.sortColumn == i) and 1 or 0
            s._activeAlpha = lia.util.approachExp(s._activeAlpha or 0, activeTarget, 12, dt)
            local themeColors = lia.color.theme
            local tr = Lerp(s._activeAlpha, themeColors.text.r, themeColors.accent.r)
            local tg = Lerp(s._activeAlpha, themeColors.text.g, themeColors.accent.g)
            local tb = Lerp(s._activeAlpha, themeColors.text.b, themeColors.accent.b)
            local ta = Lerp(s._activeAlpha, themeColors.text.a, themeColors.accent.a)
            local textColor = Color(math_floor(tr), math_floor(tg), math_floor(tb), math_floor(ta))
            draw.SimpleText(column.name, self.font, bw / 2, bh / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if column.sortable then
            label.DoClick = function()
                self:SortByColumn(i)
                surface.PlaySound('garrysmod/ui_click.wav')
            end
        end

        table.insert(self._headerButtons, label)
        xPos = xPos + w
    end
end

function PANEL:CreateRow(rowIndex, rowData)
    local row = vgui.Create("liaButton", self.content)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 1)
    row:SetTall(self.rowHeight)
    row:SetText('')
    row._index = rowIndex
    row._hoverAlpha = 0
    row._selectedAlpha = 0
    row._labels = {}
    row.Paint = function(s, w, h)
        local dt = FrameTime()
        local hoverTarget = s:IsHovered() and 1 or 0
        s._hoverAlpha = lia.util.approachExp(s._hoverAlpha, hoverTarget, 18, dt)
        local selTarget = (self.selectedRow == s._index) and 1 or 0
        s._selectedAlpha = lia.util.approachExp(s._selectedAlpha, selTarget, 22, dt)
        local base = lia.color.theme.panel_alpha[1]
        local hoverCol = lia.color.theme.hover
        local selCol = lia.color.theme.accent
        local mixHover = s._hoverAlpha * (1 - s._selectedAlpha)
        local blendA = s._selectedAlpha * 0.9 + mixHover * 0.35
        local r = Lerp(blendA, base.r, selCol.r)
        local g = Lerp(blendA, base.g, selCol.g)
        local b = Lerp(blendA, base.b, selCol.b)
        local a = Lerp(blendA, base.a, selCol.a)
        if s._hoverAlpha > 0.01 and s._selectedAlpha < 0.9 then
            local hoverR = Lerp(s._hoverAlpha * 0.6, r, hoverCol.r)
            local hoverG = Lerp(s._hoverAlpha * 0.6, g, hoverCol.g)
            local hoverB = Lerp(s._hoverAlpha * 0.6, b, hoverCol.b)
            r, g, b = hoverR, hoverG, hoverB
        end

        lia.rndx.Rect(0, 0, w, math.max(0, h - 1)):Color(Color(math.floor(r), math.floor(g), math.floor(b), math.floor(a))):Shape(lia.rndx.SHAPE_IOS):Draw()
    end

    row.DoClick = function()
        self.selectedRow = rowIndex
        self._keyboardIndex = rowIndex
        self.OnAction(rowData)
        surface.PlaySound('garrysmod/ui_click.wav')
    end

    row.DoRightClick = function()
        self.selectedRow = rowIndex
        self.OnRightClick(rowData)
        local menu = vgui.Create("liaDermaMenu")
        for i, column in ipairs(self.columns) do
            menu:AddOption(L("table_copy") .. ' ' .. column.name, function() SetClipboardText(tostring(rowData[i])) end)
        end

        menu:AddSpacer()
        menu:AddOption(L("table_delete_row"), function() self:RemoveRow(rowIndex) end, 'icon16/delete.png')
    end

    local leftPad = self.sidePadding + ((self._lastVBarVis and self.vbarLeftExtra) or 0)
    local xPos = leftPad
    for i, column in ipairs(self.columns) do
        local w = math_floor(self._colWidthsCurrent[i] or self._colWidthsTarget[i] or column.width)
        local label = vgui.Create("liaText", row)
        label:SetText(tostring(rowData[i]))
        label:SetFont(self.rowFont)
        label:SetTextColor(lia.color.theme.text)
        label:SetSize(w, self.rowHeight)
        label:SetPos(xPos, 0)
        if column.align == TEXT_ALIGN_LEFT then
            label:SetTextInset(self.padding, 0)
            label:SetContentAlignment(4)
        elseif column.align == TEXT_ALIGN_RIGHT then
            label:SetTextInset(0, 0)
            label:SetContentAlignment(6)
        else
            label:SetTextInset(0, 0)
            label:SetContentAlignment(5)
        end

        table.insert(row._labels, label)
        xPos = xPos + w
    end

    table.insert(self._rowPanels, row)
end

function PANEL:RebuildRows()
    local savedRowHover = {}
    for idx, oldRow in ipairs(self._rowPanels) do
        if IsValid(oldRow) then savedRowHover[idx] = oldRow._hoverAlpha or 0 end
    end

    local prevHeader = {}
    for i, btn in ipairs(self._headerButtons) do
        if IsValid(btn) then prevHeader[i] = btn._activeAlpha or 0 end
    end

    self.content:Clear()
    self._rowPanels = {}
    self._headerButtons = {}
    self:UpdateColumnWidthTargets()
    self:CreateHeader()
    for rowIndex, rowData in ipairs(self.rows) do
        self:CreateRow(rowIndex, rowData)
        if savedRowHover[rowIndex] and IsValid(self._rowPanels[#self._rowPanels]) then self._rowPanels[#self._rowPanels]._hoverAlpha = savedRowHover[rowIndex] end
    end

    local total = 0
    for i = 1, #self.columns do
        total = total + (self._colWidthsTarget[i] or self.columns[i].width)
    end

    local panelW = self:GetWide() or 0
    if panelW <= 0 then
        local parent = self:GetParent()
        if IsValid(parent) and parent.GetWide then panelW = parent:GetWide() end
    end

    if panelW <= 0 then panelW = ScrW() end
    local leftPad = self.sidePadding + ((self._lastVBarVis and self.vbarLeftExtra) or 0)
    local rightPad = self.sidePadding + ((self._lastVBarVis and self.vbarRightPadding) or 0)
    local contentW = math_max(total + leftPad + rightPad, panelW)
    self.content:SetSize(contentW, #self.rows * (self.rowHeight + 1))
    self.scrollPanel:InvalidateLayout(true)
end

function PANEL:SetAction(func)
    self.OnAction = func
end

function PANEL:SetRightClickAction(func)
    self.OnRightClick = func
end

function PANEL:Clear()
    self.rows = {}
    self.selectedRow = nil
    self.content:Clear()
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

function PANEL:Paint(w, h)
    lia.rndx.Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.panel_alpha[2]):Shape(lia.rndx.SHAPE_IOS):Draw()
end

function PANEL:RebuildHeader()
    self:CreateHeader()
end

function PANEL:AddColumn(name, width)
    local col = {
        name = name,
        width = width or 100
    }

    table.insert(self.columns, col)
    self:RebuildHeader()
end

function PANEL:AddLine(...)
    local row = {}
    local args = {...}
    for i = 1, #args do
        row[i] = tostring(args[i])
    end

    table.insert(self.rows, row)
    self:RebuildRows()
    return #self.rows
end

function PANEL:GetSelectedLine()
    return self:GetSelectedRow()
end

function PANEL:GetSelected()
    if self.selectedRow then return {self.rows[self.selectedRow]}, self.selectedRow end
    return {}, 0
end

function PANEL:RemoveLine(index)
    self:RemoveRow(index)
end

function PANEL:ClearSelection()
    self.selectedRow = nil
    self:RebuildRows()
end

function PANEL:SelectItem(line)
    if type(line) == "number" then
        self.selectedRow = line
    else
        for i, row in ipairs(self.rows) do
            if row == line then
                self.selectedRow = i
                break
            end
        end
    end

    self:RebuildRows()
end

function PANEL:SelectFirstItem()
    if #self.rows > 0 then
        self.selectedRow = 1
        self:RebuildRows()
    end
end

function PANEL:SortByColumn(index, descending)
    self.sortColumn = index
    self.sortDesc = descending
    if self.sortColumn then
        table.sort(self.rows, function(a, b)
            local aVal = a[index] or ""
            local bVal = b[index] or ""
            if self.sortDesc then
                return aVal > bVal
            else
                return aVal < bVal
            end
        end)
    end

    self:RebuildRows()
end

function PANEL:GetMultiSelect()
    return false
end

function PANEL:SetMultiSelect(multi)
    self.multiSelect = multi
end

vgui.Register("liaTable", PANEL, "Panel")
