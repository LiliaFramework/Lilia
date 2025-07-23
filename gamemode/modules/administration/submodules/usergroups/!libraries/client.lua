local function buildGroupsUI(panel, groups)
    panel:Clear()
    local top = panel:Add("Panel")
    top:Dock(TOP)
    top:SetTall(28)
    top:DockMargin(0, 0, 0, 5)
    local add = top:Add("liaSmallButton")
    add:Dock(LEFT)
    add:SetText(L("addGroup"))
    add:SetWide(100)
    add.DoClick = function()
        Derma_StringRequest(L("addGroup"), L("groupName"), "", function(name)
            if name == "" then return end
            net.Start("liaGroupsAdd")
            net.WriteString(name)
            net.SendToServer()
        end)
    end

    local remove = top:Add("liaSmallButton")
    remove:Dock(LEFT)
    remove:DockMargin(5, 0, 0, 0)
    remove:SetText(L("removeGroup"))
    remove:SetWide(100)
    local list = panel:Add("DListView")
    list:Dock(FILL)
    list:AddColumn(L("name"))
    for name in pairs(groups) do
        list:AddLine(name)
    end

    remove.DoClick = function()
        local line = list:GetSelectedLine() and list:GetLine(list:GetSelectedLine())
        if not line then return end
        net.Start("liaGroupsRemove")
        net.WriteString(line:GetColumnText(1))
        net.SendToServer()
    end
end

net.Receive("liaGroupsData", function()
    local groups = net.ReadTable()
    lia.admin.groups = groups
    if IsValid(lia.gui.usergroups) then buildGroupsUI(lia.gui.usergroups, groups) end
end)

net.Receive("updateAdminGroups", function()
    lia.admin.groups = net.ReadTable()
    if IsValid(lia.gui.usergroups) then buildGroupsUI(lia.gui.usergroups, lia.admin.groups) end
end)

function MODULE:CreateMenuButtons(tabs)
    if IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("Staff Permissions - Manage UserGroups") then
        tabs[L("userGroups")] = function(parent)
            lia.gui.usergroups = parent
            parent:Clear()
            parent:DockPadding(10, 10, 10, 10)
            parent.Paint = function(pnl, w, h) derma.SkinHook("Paint", "Frame", pnl, w, h) end
            net.Start("liaGroupsRequest")
            net.SendToServer()
        end
    end
end
