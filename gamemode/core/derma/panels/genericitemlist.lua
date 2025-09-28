local PANEL = {}
function PANEL:Init()
    self:SetTitle(self.Title or "Item List")
    self:SetSize(self.Width or 600, self.Height or 500)
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(true)
    self:DockPadding(10, 50, 10, 10)
    self.listView = self:Add("DListView")
    self.listView:Dock(FILL)
    self.listView:SetMultiSelect(false)
    if self.Columns then
        for _, column in ipairs(self.Columns) do
            self.listView:AddColumn(column)
        end
    else
        self.listView:AddColumn("Item Name")
        self.listView:AddColumn("Value")
        self.listView:AddColumn("Description")
    end

    self.closeButton = self:Add("DButton")
    self.closeButton:Dock(BOTTOM)
    self.closeButton:SetTall(30)
    self.closeButton:SetText("Close")
    self.closeButton.DoClick = function() self:Remove() end
    if self.Data then self:PopulateItems() end
end

function PANEL:PopulateItems()
    if not self.Data then return end
    self.listView:Clear()
    for _, itemData in ipairs(self.Data) do
        local line = self.listView:AddLine(unpack(itemData))
        if self.LineData then
            for key, value in pairs(self.LineData) do
                line[key] = value
            end
        end
    end
end

function PANEL:SetData(data)
    self.Data = data
    self:PopulateItems()
end

function PANEL:SetTitle(title)
    self.Title = title
    if self:GetTitle() ~= title then DFrame.SetTitle(self, title) end
end

function PANEL:SetColumns(columns)
    self.Columns = columns
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(45, 45, 45, 250)
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText(self.Title or "Item List", "liaMediumFont", w / 2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("liaItemList", PANEL, "DFrame")
PANEL = {}
function PANEL:Init()
    self:SetTitle(self.Title or "Select Items")
    self:SetSize(self.Width or 600, self.Height or 500)
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(true)
    self:DockPadding(10, 50, 10, 10)
    self.listView = self:Add("DListView")
    self.listView:Dock(FILL)
    self.listView:SetMultiSelect(false)
    if self.Columns then
        for _, column in ipairs(self.Columns) do
            self.listView:AddColumn(column)
        end
    else
        self.listView:AddColumn("Item Name")
        self.listView:AddColumn("Value")
        self.listView:AddColumn("Quantity")
    end

    self.actionButton = self:Add("DButton")
    self.actionButton:Dock(BOTTOM)
    self.actionButton:SetTall(40)
    self.actionButton:SetText(self.ActionText or "Select Item")
    self.actionButton:SetDisabled(true)
    self.actionButton.DoClick = function()
        local selectedLine = self.listView:GetSelectedLine()
        if selectedLine and self.OnAction then
            local line = self.listView:GetLine(selectedLine)
            self:OnAction(line, selectedLine)
        end
    end

    self.closeButton = self:Add("DButton")
    self.closeButton:Dock(BOTTOM)
    self.closeButton:DockMargin(0, 5, 0, 0)
    self.closeButton:SetTall(30)
    self.closeButton:SetText("Close")
    self.closeButton.DoClick = function() self:Remove() end
    self.listView.OnRowSelected = function(_, _, line)
        self.actionButton:SetDisabled(false)
        self.selectedItem = line
    end

    if self.Data then self:PopulateItems() end
end

function PANEL:PopulateItems()
    if not self.Data then return end
    self.listView:Clear()
    for _, itemData in ipairs(self.Data) do
        local line = self.listView:AddLine(unpack(itemData))
        if self.LineData then
            for key, value in pairs(self.LineData) do
                line[key] = value
            end
        end
    end
end

function PANEL:SetData(data)
    self.Data = data
    self:PopulateItems()
end

function PANEL:SetTitle(title)
    self.Title = title
    if self:GetTitle() ~= title then DFrame.SetTitle(self, title) end
end

function PANEL:SetActionText(text)
    self.ActionText = text
    if self.actionButton then self.actionButton:SetText(text) end
end

function PANEL:SetColumns(columns)
    self.Columns = columns
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(45, 45, 45, 250)
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText(self.Title or "Select Items", "liaMediumFont", w / 2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("liaItemSelector", PANEL, "DFrame")
