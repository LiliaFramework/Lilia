local ugPanel
local ugPrivileges

local function openGroupsPanel(parent)
    ugPanel = parent
    parent:Clear()
    parent:DockPadding(10, 10, 10, 10)
    parent.Paint = function(pnl, w, h)
        lia.util.drawBlur(pnl)
        surface.SetDrawColor(45, 45, 45, 200)
        surface.DrawRect(0, 0, w, h)
    end

    net.Start("liaGroupsRequest")
    net.SendToServer()
end
local function buildGroupsUI(panel, groups)
    panel:Clear()
    local sidebar = panel:Add("DScrollPanel")
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar:DockMargin(0, 20, 20, 20)
    local addBtn = sidebar:Add("liaMediumButton")
    addBtn:Dock(TOP)
    addBtn:SetText(L("addGroup"))
    addBtn:SetTall(30)
    addBtn:DockMargin(0, 0, 0, 10)
    addBtn.DoClick = function()
        Derma_StringRequest(L("addGroup"), L("groupName"), "", function(text)
            net.Start("liaGroupCreate")
            net.WriteString(text)
            net.SendToServer()
        end)
    end

    local removeBtn = sidebar:Add("liaMediumButton")
    removeBtn:Dock(TOP)
    removeBtn:SetText(L("removeGroup"))
    removeBtn:SetTall(30)
    removeBtn:DockMargin(0, 0, 0, 10)
    local list = sidebar:Add("DListView")
    list:Dock(FILL)
    list:AddColumn(L("name"))
    local content = panel:Add("DScrollPanel")
    content:Dock(FILL)
    content:DockMargin(10, 10, 10, 10)
    local function populate(group)
        content:Clear()
        removeBtn:SetEnabled(group ~= "user" and group ~= "admin" and group ~= "superadmin")
        for name in pairs(ugPrivileges or {}) do
            local cb = content:Add("DCheckBoxLabel")
            cb:Dock(TOP)
            cb:SetText(name)
            cb:SetValue(groups[group] and groups[group][name] and true or false)
            cb.OnChange = function(_, val)
                net.Start("liaGroupSetPermission")
                net.WriteString(group)
                net.WriteString(name)
                net.WriteBool(val)
                net.SendToServer()
            end
        end
    end

    removeBtn.DoClick = function()
        local line = list:GetSelectedLine()
        if not line then return end
        local group = list:GetLine(line):GetColumnText(1)
        if group == "user" or group == "admin" or group == "superadmin" then return end
        net.Start("liaGroupDelete")
        net.WriteString(group)
        net.SendToServer()
    end

    list.OnRowSelected = function(_, _, row) populate(row:GetColumnText(1)) end
    for name in pairs(groups) do
        list:AddLine(name)
    end
end

net.Receive("liaGroupsData", function()
    local groups = net.ReadTable()
    ugPrivileges = net.ReadTable()
    lia.admin.groups = groups
    if IsValid(ugPanel) then buildGroupsUI(ugPanel, groups) end
end)

net.Receive("lilia_updateAdminGroups", function()
    lia.admin.groups = net.ReadTable()
    if IsValid(ugPanel) then buildGroupsUI(ugPanel, lia.admin.groups) end
end)

function MODULE:CreateMenuButtons(tabs)
    if IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("Staff Permissions - Manage UserGroups") then
        tabs[L("userGroups")] = function(panel)
            openGroupsPanel(panel)
        end
    end
end
