local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    self:SetTitle("")
    self:SetSize(1024, 820)
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(true)
    self.windowTitle = ""
    self.columns = {}
    self.data = {}
    self.sortColumn = 1
    self.sortDesc = false
    self.visibleCount = 0
    self.headerHeight = 64
    self:DockPadding(12, self.headerHeight, 12, 8)
    self.Paint = function(_, w, h)
        surface.SetDrawColor(45, 45, 45, 250)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(self.windowTitle, "liaMediumFont", w / 2, self.headerHeight / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.topBar = vgui.Create("DPanel", self)
    self.topBar:Dock(TOP)
    self.topBar:SetTall(44)
    self.topBar.Paint = nil
    self.searchBox = vgui.Create("DTextEntry", self.topBar)
    self.searchBox:Dock(FILL)
    self.searchBox:SetTall(32)
    self.searchBox:SetPlaceholderText("")
    self.searchBox:SetText("")
    self.searchBox.OnTextChanged = function() self:Populate() end
    self.refreshButton = vgui.Create("DButton", self.topBar)
    self.refreshButton:Dock(RIGHT)
    self.refreshButton:SetWide(100)
    self.refreshButton:SetText(L("refresh") or "Refresh")
    self.refreshButton.DoClick = function()
        self:Populate()
        client:notifySuccessLocalized("privilegeListRefreshed")
    end
    self.listView = vgui.Create("DListView", self)
    self.listView:Dock(FILL)
    self.listView:SetMultiSelect(false)
    self.listView.OnRowRightClick = function(_, _, line)
        local m = lia.derma.dermaMenu()
        for i, header in ipairs(self.columns) do
            m:AddOption(L("copy") .. " " .. header, function()
                SetClipboardText(line:GetColumnText(i) or "")
                client:notifySuccessLocalized("copied")
            end)
        end
        m:AddSpacer()
        m:AddOption(L("copyAll"), function()
            local t = {}
            for i, header in ipairs(self.columns) do
                t[#t + 1] = header .. ": " .. (line:GetColumnText(i) or "")
            end
            SetClipboardText(table.concat(t, "\n"))
            client:notifySuccessLocalized("allPrivilegeInfo")
        end)
        m:Open()
    end
    self.listView.OnRowDoubleClick = function(_, _, line)
        SetClipboardText(line:GetColumnText(1) or "")
        client:notifySuccessLocalized("privilegeIdCopied")
    end
    self.statusBar = vgui.Create("DPanel", self)
    self.statusBar:Dock(BOTTOM)
    self.statusBar:SetTall(24)
    self.statusBar.Paint = function() draw.SimpleText(L("total") .. " " .. tostring(self.visibleCount or 0), "liaSmallFont", 5, 4, Color(200, 200, 200, 255), TEXT_ALIGN_LEFT) end
end
function PANEL:SetWindowTitle(t)
    self.windowTitle = t or ""
end
function PANEL:SetPlaceholderText(t)
    self.searchBox:SetPlaceholderText(t or "")
end
function PANEL:SetColumns(cols)
    self.columns = {}
    self.listView:Clear()
    if self.listView.ClearColumns then self.listView:ClearColumns() end
    for _, v in ipairs(cols or {}) do
        self.listView:AddColumn(v)
        self.columns[#self.columns + 1] = v
    end
end
function PANEL:setData(rows)
    self.data = rows or {}
    self:Populate()
end
function PANEL:SetSort(column, desc)
    self.sortColumn = column or 1
    self.sortDesc = desc and true or false
    self.listView:SortByColumn(self.sortColumn, self.sortDesc)
end
function PANEL:RowMatches(row, term)
    if not term or term == "" then return true end
    local st = string.lower(term)
    for _, v in ipairs(row) do
        local s = isstring(v) and v or tostring(v)
        if s ~= "" and string.find(string.lower(s), st, 1, true) then return true end
    end
    return false
end
function PANEL:Populate()
    self.listView:Clear()
    local term = string.Trim(self.searchBox:GetValue() or "")
    local count = 0
    for _, row in ipairs(self.data) do
        if self:RowMatches(row, term) then
            self.listView:AddLine(unpack(row))
            count = count + 1
        end
    end
    self.visibleCount = count
    if self.sortColumn then self.listView:SortByColumn(self.sortColumn, self.sortDesc) end
end
vgui.Register("liaDListView", PANEL, "DFrame")