--------------------------------------------------------------------------------------------------------
MODULE.overwrite = MODULE.overwrite or {}
--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
function MODULE:setModuleDisabled(name, disabled)
    lia.module.setDisabled(name, disabled)
    self.overwrite[name] = disabled
    net.Start("liaModuleDisable")
    net.WriteString(name)
    net.WriteBit(disabled)
    net.Send(lia.util.getAdmins(true))
end
--------------------------------------------------------------------------------------------------------