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
