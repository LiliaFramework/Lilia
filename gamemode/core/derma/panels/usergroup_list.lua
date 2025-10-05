local PANEL = {}
function PANEL:Init()
    self.groups = {}
    self.selectedGroup = nil
    self.groupButtons = {}
    self:SetupUI()
end

function PANEL:SetupUI()
    -- Header
    local header = self:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(40)
    header:DockMargin(0, 0, 0, 5)
    header.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel[3]):Shape(lia.derma.SHAPE_IOS):Draw()
        draw.SimpleText(L("groups"), "liaMediumFont", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Scroll panel for groups
    self.scrollPanel = self:Add("liaScrollPanel")
    self.scrollPanel:Dock(FILL)
end

function PANEL:SetGroups(groups)
    self.groups = groups or {}
    self:RefreshGroups()
end

function PANEL:RefreshGroups()
    self.scrollPanel:Clear()
    self.groupButtons = {}
    local keys = {}
    for g in pairs(self.groups) do
        keys[#keys + 1] = g
    end

    table.sort(keys, function(a, b) return a:lower() < b:lower() end)
    for _, groupName in ipairs(keys) do
        local groupData = self.groups[groupName]
        local isDefault = lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[groupName] ~= nil
        local groupBtn = self.scrollPanel:Add("liaUserGroupButton")
        groupBtn:Dock(TOP)
        groupBtn:SetTall(50)
        groupBtn:DockMargin(0, 0, 0, 5)
        groupBtn:SetGroup(groupName, groupData, isDefault)
        groupBtn.DoClick = function() self:SelectGroup(groupName) end
        self.groupButtons[groupName] = groupBtn
    end
end

function PANEL:SelectGroup(groupName)
    if self.selectedGroup and self.groupButtons[self.selectedGroup] then self.groupButtons[self.selectedGroup]:SetSelected(false) end
    self.selectedGroup = groupName
    if self.groupButtons[groupName] then self.groupButtons[groupName]:SetSelected(true) end
    if self.OnGroupSelected then self:OnGroupSelected(groupName) end
end

function PANEL:GetSelectedGroup()
    return self.selectedGroup
end

function PANEL:Paint(w, h)
    lia.derma.rect(0, 0, w, h):Rad(12):Color(lia.color.theme.panel[2]):Shape(lia.derma.SHAPE_IOS):Draw()
end

vgui.Register("liaUserGroupList", PANEL, "DPanel")
