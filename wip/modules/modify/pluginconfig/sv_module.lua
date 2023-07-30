local MODULE = MODULE
util.AddNetworkString("liaModuleDisable")
util.AddNetworkString("liaModuleList")

function MODULE:getModuleList()
    if self.computedModules then return self.computedModules end
    local modules = {}
    local found = {}

    local function findModules(path)
        local files, folders = file.Find(path .. "/*", "LUA")

        for _, folder in ipairs(folders) do
            if not file.Exists(path .. "/" .. folder .. "/sh_module.lua", "LUA") or found[folder] then continue end
            modules[#modules + 1] = folder
            found[folder] = true
            findModules(path .. "/" .. folder .. "/modules")
        end

        for _, fileName in ipairs(files) do
            local moduleID = string.StripExtension(fileName)

            if string.GetExtensionFromFilename(fileName) == "lua" and not found[moduleID] then
                modules[#modules + 1] = moduleID
                found[moduleID] = true
            end
        end
    end

    findModules("lilia/modules")
    findModules(SCHEMA.folder .. "/modules")
    self.computedModules = modules

    return modules
end

function MODULE:setModuleDisabled(name, disabled)
    lia.module.setDisabled(name, disabled)
    self.overwrite[name] = disabled
    net.Start("liaModuleDisable")
    net.WriteString(name)
    net.WriteBit(disabled)
    net.Send(lia.util.getAdmins(true))
end

concommand.Add("lia_disablemodule", function(client, _, arguments)
    if IsValid(client) and not client:IsSuperAdmin() then return end
    local name = arguments[1]
    local disabled = tobool(arguments[2])
    MODULE:setModuleDisabled(name, disabled)
    local message = name .. " is now " .. (disabled and "disabled" or "enabled")

    if IsValid(client) then
        client:ChatPrint(message)
    end

    print(message)
end)

net.Receive("liaModuleDisable", function(_, client)
    if not client:IsSuperAdmin() then return end
    local name = net.ReadString()
    local disabled = net.ReadBit() == 1
    MODULE:setModuleDisabled(name, disabled)
end)

net.Receive("liaModuleList", function(_, client)
    if not client:IsSuperAdmin() then return end
    local modules = MODULE:getModuleList()
    local disabled, module
    net.Start("liaModuleList")
    net.WriteUInt(#modules, 32)

    for k, module in ipairs(modules) do
        if MODULE.overwrite[module] ~= nil then
            disabled = MODULE.overwrite[module]
        else
            disabled = lia.module.isDisabled(module)
        end

        net.WriteString(module)
        net.WriteBit(disabled)
    end

    net.Send(client)
end)