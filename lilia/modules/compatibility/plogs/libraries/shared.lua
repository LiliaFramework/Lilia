function MODULE:InitializedModules()
    lia.includeDir(self.path .. "/loggers", false, true, "shared")
    hook.Remove("Initialize", "plogs.Loghooks.Initialize")
end

function plogs.HasPerms(client)
    return IsValid(client) and client:HasPrivilege("Staff Permissions - Open Plogs")
end
