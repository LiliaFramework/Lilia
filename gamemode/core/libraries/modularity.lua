lia.module = lia.module or {}
lia.module.list = lia.module.list or {}
local function loadPermissions(Privileges)
    if not Privileges or not istable(Privileges) then return end
    for _, privilegeData in ipairs(Privileges) do
        local privilegeName = L(privilegeData.Name or privilegeData.ID)
        local privilegeCategory = privilegeData.Category or MODULE.name
        lia.administrator.registerPrivilege({
            Name = privilegeName,
            ID = privilegeData.ID,
            MinAccess = privilegeData.MinAccess or "admin",
            Category = privilegeCategory
        })
    end
end

local function loadDependencies(dependencies)
    if not istable(dependencies) then return end
    for _, dep in ipairs(dependencies) do
        local realm = dep.Realm
        if dep.File then
            lia.include(MODULE.folder .. "/" .. dep.File, realm)
        elseif dep.Folder then
            lia.includeDir(MODULE.folder .. "/" .. dep.Folder, true, true, realm)
        end
    end
end

local function loadSubmodules(path)
    local files, folders = file.Find(path .. "/submodules/*", "LUA")
    if #files > 0 or #folders > 0 then lia.module.loadFromDir(path .. "/submodules", "module") end
end

local function collectModuleIDs(directory)
    local ids = {}
    if not directory then return ids end
    local _, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        ids[folderName] = true
    end
    return ids
end

local function loadExtras(path)
    local ModuleFiles = {
        pim = "server",
        config = "shared",
        commands = "shared",
        networking = "server",
    }

    local ModuleFolders = {"config", "dependencies", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma"}
    lia.lang.loadFromDir(path .. "/languages")
    lia.faction.loadFromDir(path .. "/factions")
    lia.class.loadFromDir(path .. "/classes")
    lia.attribs.loadFromDir(path .. "/attributes")
    for fileName, realm in pairs(ModuleFiles) do
        local filePath = path .. "/" .. fileName .. ".lua"
        if file.Exists(filePath, "LUA") then lia.include(filePath, realm) end
    end

    for _, folder in ipairs(ModuleFolders) do
        local subPath = path .. "/" .. folder
        if file.Exists(subPath, "LUA") then lia.includeDir(subPath, true, true) end
    end

    lia.includeEntities(path .. "/entities")
    if MODULE.uniqueID ~= "schema" then lia.item.loadFromDir(path .. "/items") end
    if SERVER then
        if MODULE.NetworkStrings and istable(MODULE.NetworkStrings) then
            for _, netString in ipairs(MODULE.NetworkStrings) do
                if isstring(netString) then util.AddNetworkString(netString) end
            end
        end
    else
        if MODULE.WebImages and istable(MODULE.WebImages) then
            for name, url in pairs(MODULE.WebImages) do
                if isstring(name) and isstring(url) then lia.webimage.register(name, url) end
            end
        end

        if MODULE.WebSounds and istable(MODULE.WebSounds) then
            for name, url in pairs(MODULE.WebSounds) do
                if isstring(name) and isstring(url) then lia.websound.register(name, url) end
            end
        end
    end

    hook.Run("DoModuleIncludes", path, MODULE)
end

function lia.module.load(uniqueID, path, isSingleFile, variable, skipSubmodules)
    variable = variable or "MODULE"
    local lowerVar = variable:lower()
    local coreFile = path .. "/" .. lowerVar .. ".lua"
    local prev = _G[variable]
    local existing = lia.module.list[uniqueID]
    if existing then
        for hookName, func in pairs(existing) do
            if isfunction(func) then hook.Remove(hookName, existing) end
        end
    end

    MODULE = {
        folder = path,
        module = existing or prev,
        uniqueID = uniqueID,
        name = L("unknown"),
        desc = L("noDesc"),
        author = L("anonymous"),
        enabled = true,
        IsValid = function() return true end
    }

    if uniqueID == "schema" then
        if SCHEMA then MODULE = SCHEMA end
        variable = "SCHEMA"
        MODULE.folder = engine.ActiveGamemode()
    end

    _G[variable] = MODULE
    MODULE.loading = true
    MODULE.path = path
    MODULE.isSingleFile = isSingleFile
    MODULE.variable = variable
    if isSingleFile then
        lia.include(path, "shared")
    else
        if not file.Exists(coreFile, "LUA") then
            lia.bootstrap(L("moduleSkipped"), L("moduleSkipMissing", uniqueID, lowerVar))
            _G[variable] = prev
            return
        end

        lia.include(coreFile, "shared")
    end

    local enabled, disableReason
    if isfunction(MODULE.enabled) then
        enabled, disableReason = MODULE.enabled()
    else
        enabled = MODULE.enabled
    end

    if uniqueID ~= "schema" and not enabled then
        if disableReason then
            lia.bootstrap(L("moduleDisabledTitle"), disableReason)
        else
            lia.bootstrap(L("moduleDisabledTitle"), MODULE.name)
        end

        _G[variable] = prev
        return
    end

    loadPermissions(MODULE.Privileges)
    if not isSingleFile then
        loadDependencies(MODULE.Dependencies)
        loadExtras(path)
    end

    MODULE.loading = false
    for k, f in pairs(MODULE) do
        if isfunction(f) then hook.Add(k, MODULE, f) end
    end

    if uniqueID == "schema" then
        function MODULE:IsValid()
            return true
        end
    else
        function MODULE:setData(value, global, ignoreMap)
            lia.data.set(uniqueID, value, global, ignoreMap)
        end

        function MODULE:getData(default)
            return lia.data.get(uniqueID, default) or {}
        end

        lia.module.list[uniqueID] = MODULE
        if not skipSubmodules then loadSubmodules(path) end
        if MODULE.ModuleLoaded then MODULE:ModuleLoaded() end
        if string.StartsWith(path, engine.ActiveGamemode() .. "/modules") then lia.bootstrap(L("module"), L("moduleFinishedLoading", MODULE.name)) end
        _G[variable] = prev
    end
end

function lia.module.initialize()
    local schemaPath = engine.ActiveGamemode()
    lia.module.load("schema", schemaPath .. "/schema", false, "schema")
    hook.Run("InitializedSchema")
    local preloadPath = schemaPath .. "/preload"
    local preloadIDs = collectModuleIDs(preloadPath)
    lia.module.loadFromDir(preloadPath, "module")
    local gamemodeIDs = collectModuleIDs(schemaPath .. "/modules")
    for id in pairs(collectModuleIDs(schemaPath .. "/overrides")) do
        gamemodeIDs[id] = true
    end

    for id in pairs(collectModuleIDs("lilia/gamemode/modules")) do
        if not preloadIDs[id] and gamemodeIDs[id] then lia.bootstrap(L("module"), L("modulePreloadSuggestion", id)) end
    end

    lia.module.loadFromDir("lilia/gamemode/modules", "module", preloadIDs)
    lia.module.loadFromDir(schemaPath .. "/modules", "module")
    lia.module.loadFromDir(schemaPath .. "/overrides", "module")
    hook.Run("InitializedModules")
    lia.item.loadFromDir(schemaPath .. "/schema/items")
    for id, mod in pairs(lia.module.list) do
        if id ~= "schema" then
            local ok = isfunction(mod.enabled) and mod.enabled() or mod.enabled
            if not ok then lia.module.list[id] = nil end
        end
    end
end

function lia.module.loadFromDir(directory, group, skip)
    local locationVar = group == "schema" and "SCHEMA" or "MODULE"
    local _, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        if not skip or not skip[folderName] then lia.module.load(folderName, directory .. "/" .. folderName, false, locationVar) end
    end
end

function lia.module.get(identifier)
    return lia.module.list[identifier]
end

hook.Add("CreateInformationButtons", "liaInformationModulesUnified", function(pages)
    table.insert(pages, {
        name = "modules",
        drawFunc = function(parent)
            local sheet = vgui.Create("liaSheet", parent)
            sheet:SetPlaceholderText(L("searchModules"))
            sheet:SetPadding(5)
            sheet:SetSpacing(4)
            for _, moduleData in SortedPairs(lia.module.list) do
                local title = moduleData.name or ""
                local desc = moduleData.desc or ""
                local right = moduleData.version and tostring(moduleData.version) or ""
                local row = sheet:AddTextRow({
                    title = title,
                    desc = desc,
                    right = right,
                })

                row.filterText = (title .. " " .. desc .. " " .. right):lower()
            end

            sheet:Refresh()
        end
    })
end)