MODULE.name = "Usergroups"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Lists CAMI usergroups."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Manage UserGroups",
        MinAccess = "superadmin",
    },
}

if SERVER then
    net.Receive("liaGroupsRequest", function(_, client)
        if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
        net.Start("liaGroupsData")
        net.WriteTable(CAMI.GetUsergroups())
        net.Send(client)
        PrintTable(CAMI.GetUsergroups())
    end)

    local function broadcastGroups()
        net.Start("liaGroupsData")
        net.WriteTable(CAMI.GetUsergroups() or {})
        net.Broadcast()
    end

    net.Receive("liaGroupsAdd", function(_, client)
        if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
        local name = net.ReadString()
        if name and name ~= "" then
            lia.admin.createGroup(name)
            broadcastGroups()
        end
    end)

    net.Receive("liaGroupsRemove", function(_, client)
        if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
        local name = net.ReadString()
        if name and name ~= "" then
            lia.admin.removeGroup(name)
            broadcastGroups()
        end
    end)

    util.AddNetworkString("liaGroupsAdd")
    util.AddNetworkString("liaGroupsRemove")
    util.AddNetworkString("liaGroupsRequest")
    util.AddNetworkString("liaGroupsData")
else
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

    net.Receive("lilia_updateAdminGroups", function()
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
end

hook.Add("CAMI.OnUsergroupRegistered", "liaSyncAdminGroupAdd", function(group)
    if lia.admin.isDisabled() then return end
    if not group or lia.admin.groups[group.Name] then return end
    lia.admin.groups[group.Name] = {}
    for privName, privilege in pairs(lia.admin.privileges) do
        if CAMI.UsergroupInherits(group.Name, privilege.MinAccess or "user") then lia.admin.groups[group.Name][privName] = true end
    end

    if SERVER then lia.admin.save(true) end
end)

hook.Add("CAMI.OnUsergroupUnregistered", "liaSyncAdminGroupRemove", function(group)
    if lia.admin.isDisabled() then return end
    if not group or not lia.admin.groups[group.Name] then return end
    lia.admin.groups[group.Name] = nil
    if SERVER then lia.admin.save(true) end
end)

hook.Add("CAMI.OnPrivilegeRegistered", "liaSyncAdminPrivilegeAdd", function(priv)
    if lia.admin.isDisabled() then return end
    if not priv or not priv.Name then return end
    lia.admin.registerPrivilege(priv)
    for groupName in pairs(lia.admin.groups) do
        if CAMI.UsergroupInherits(groupName, priv.MinAccess or "user") then lia.admin.groups[groupName][priv.Name] = true end
    end

    if SERVER then lia.admin.save(true) end
end)

hook.Add("CAMI.OnPrivilegeUnregistered", "liaSyncAdminPrivilegeRemove", function(priv)
    if lia.admin.isDisabled() then return end
    if not priv or not priv.Name then return end
    lia.admin.privileges[priv.Name] = nil
    for _, permissions in pairs(lia.admin.groups) do
        permissions[priv.Name] = nil
    end

    if SERVER then lia.admin.save(true) end
end)
