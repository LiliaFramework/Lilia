net.Receive("liaGroupsRequest", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
    net.Start("liaGroupsData")
    net.WriteTable(lia.admin.groups)
    net.WriteTable(CAMI.GetPrivileges() or {})
    net.Send(client)
end)

net.Receive("liaGroupCreate", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
    local name = string.Trim(net.ReadString())
    if name == "" or lia.admin.groups[name] then return end
    lia.admin.createGroup(name)
end)

net.Receive("liaGroupDelete", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
    local name = net.ReadString()
    if name == "user" or name == "admin" or name == "superadmin" then return end
    lia.admin.removeGroup(name)
end)

net.Receive("liaGroupSetPermission", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Manage UserGroups") then return end
    local group = net.ReadString()
    local perm = net.ReadString()
    local enable = net.ReadBool()
    if not lia.admin.groups[group] then return end
    if enable then
        lia.admin.addPermission(group, perm)
    else
        lia.admin.removePermission(group, perm)
    end
end)