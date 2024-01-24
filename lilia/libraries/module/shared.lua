lia.module = lia.module or {}
lia.module.enabilitystatus = {}
lia.module.list = lia.module.list or {}
lia.module.unloaded = lia.module.unloaded or {}
lia.module.ModuleFolders = {"dependencies", "config", "permissions", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma", "pim", "concommands"}
lia.module.ModuleFiles = {
    ["client.lua"] = "client",
    ["cl_module.lua"] = "client",
    ["sv_module.lua"] = "server",
    ["server.lua"] = "server",
    ["config.lua"] = "shared",
    ["sconfig.lua"] = "server",
}

lia.module.ModuleConditions = {
    ["stormfox2"] = {
        name = "StormFox 2",
        global = "StormFox2"
    },
    ["prone"] = {
        name = "Prone Mod",
        global = "prone"
    },
    ["playx"] = {
        name = "PlayX",
        global = "PlayX"
    },
    ["streamradios"] = {
        name = "3D Stream Radios",
        global = "StreamRadioLib"
    },
    ["permaprops"] = {
        name = "PermaProps",
        global = "PermaProps"
    },
    ["vjbase"] = {
        name = "VJ Base",
        global = "VJ"
    },
    ["pcasino"] = {
        name = "PCasino",
        global = "PerfectCasino"
    },
    ["mlogs"] = {
        name = "mLogs",
        global = "mLogs"
    },
    ["sam"] = {
        name = "SAM Admin Mod",
        global = "sam"
    },
    ["ulx"] = {
        name = "ULX Admin Mod",
        global = "ulx"
    },
    ["serverguard"] = {
        name = "ServerGuard Admin Mod",
        global = "serverguard"
    },
    ["advdupe2"] = {
        name = "Advanced Dupe 2",
        global = "AdvDupe2"
    },
    ["advdupe"] = {
        name = "Advanced Dupe 1",
        global = "AdvDupe"
    },
    ["zmc"] = {
        name = "Zero's MasterChef",
        global = "zmc"
    },
    ["zpf"] = {
        name = "Zero's Factory",
        global = "zpf"
    },
    ["sitanywhere"] = {
        name = "The Sit Anywhere Script",
        global = "SitAnywhere"
    },
    ["simfphys"] = {
        name = "Simfphys LUA Vehicles Base",
        global = "simfphys"
    },
    ["pac"] = {
        name = "Player Appearance Customizer 3 (PAC3)",
        global = "pac"
    }
}

function lia.module.load(uniqueID, path, isSingleFile, variable)
    local lowerVariable = variable:lower()
    local normalpath = path .. "/" .. lowerVariable .. ".lua"
    local extendedpath = path .. "/sh_" .. lowerVariable .. ".lua"
    local ModuleCore = file.Exists(normalpath, "LUA")
    local ExtendedCore = file.Exists(extendedpath, "LUA")
    if not isSingleFile and not ModuleCore and not ExtendedCore then return end
    local oldModule = MODULE
    MODULE = {
        folder = path,
        module = oldModule,
        uniqueID = uniqueID,
        name = "Unknown",
        desc = "Description not available",
        author = "Anonymous",
        identifier = "",
        enabled = true,
        IsValid = function(_) return true end
    }

    if uniqueID == "schema" then
        if SCHEMA then MODULE = SCHEMA end
        variable = "SCHEMA"
        MODULE.folder = engine.ActiveGamemode()
    elseif lia.module.list[uniqueID] then
        MODULE = lia.module.list[uniqueID]
    end

    _G[variable] = MODULE
    MODULE.loading = true
    MODULE.path = path
    if isSingleFile then
        lia.util.include(path, "shared")
    else
        lia.util.include(ModuleCore and normalpath or ExtendedCore and extendedpath, "shared")
    end

    hook.Run("ModuleDependenciesPreLoad", uniqueID, MODULE.identifier, MODULE)
    if hook.Run("VerifyModuleValidity", uniqueID, MODULE, MODULE.identifier) then
        lia.module.enabilitystatus[tostring(MODULE.name)] = true
    else
        if lia.module.ModuleConditions[uniqueID] == nil then print(MODULE.name .. " is disabled. Disabling!") end
        lia.module.enabilitystatus[MODULE.name] = false
        return
    end

    if not isSingleFile then lia.module.loadExtras(path) end
    MODULE.loading = false
    local uniqueID2 = uniqueID
    if uniqueID2 == "schema" then uniqueID2 = MODULE.name end
    function MODULE:setData(value, global, ignoreMap)
        lia.data.set(uniqueID2, value, global, ignoreMap)
    end

    function MODULE:getData(default, global, ignoreMap, refresh)
        return lia.data.get(uniqueID2, default, global, ignoreMap, refresh) or {}
    end

    for k, v in pairs(MODULE) do
        if isfunction(v) then hook.Add(k, MODULE, v) end
    end

    if uniqueID == "schema" then
        function MODULE:IsValid()
            return true
        end
    else
        lia.module.list[uniqueID] = MODULE
        _G[variable] = oldModule
    end

    hook.Run("ModuleLoaded", uniqueID, MODULE.identifier, MODULE)
    if MODULE.OnLoaded then MODULE:OnLoaded() end
end

function lia.module.loadExtras(path)
    lia.lang.loadFromDir(path .. "/languages")
    lia.faction.loadFromDir(path .. "/factions")
    lia.class.loadFromDir(path .. "/classes")
    lia.attribs.loadFromDir(path .. "/attributes")
    for fileName, state in pairs(lia.module.ModuleFiles) do
        local filePath = path .. "/" .. fileName
        if file.Exists(filePath, "LUA") then lia.util.include(filePath, state) end
    end

    for _, folder in ipairs(lia.module.ModuleFolders) do
        local subFolders = path .. "/" .. folder
        if file.Exists(subFolders, "LUA") then lia.util.includeDir(subFolders, true, true) end
    end

    lia.util.loadEntities(path .. "/entities")
    lia.item.loadFromDir(path .. "/items", false)
    lia.module.loadFromDir(path .. "/submodules", "module")
    lia.module.loadFromDir(path .. "/modules", "module")
    hook.Run("DoModuleIncludes", path, MODULE)
end

function lia.module.initialize()
    local schema = engine.ActiveGamemode()
    lia.module.loadFromDir(schema .. "/preload", "schema")
    lia.module.load("schema", schema .. "/schema", false, "schema")
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module")
    lia.module.loadFromDir("lilia/modules/frameworkui", "module")
    lia.module.loadFromDir("lilia/modules/characters", "module")
    lia.module.loadFromDir("lilia/modules/utilities", "module")
    lia.module.loadFromDir("lilia/modules/compatibility", "module")
    lia.module.loadFromDir(schema .. "/modules", "module")
    hook.Run("InitializedModules")
end

function lia.module.loadFromDir(directory, group)
    local location = group == "schema" and "SCHEMA" or "MODULE"
    local files, folders = file.Find(directory .. "/*", "LUA")
    for _, v in ipairs(folders) do
        lia.module.load(v, directory .. "/" .. v, false, location)
    end

    for _, v in ipairs(files) do
        lia.module.load(string.StripExtension(v), directory .. "/" .. v, true, location)
    end
end

function lia.module.get(identifier)
    return lia.module.list[identifier]
end
