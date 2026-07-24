--[[
    Folder: Developer - Libraries
    File: lia.module.md
]]
--[[
    Module

    Module loading helpers for Lilia schemas, modules, submodules, dependencies, permissions, and module-provided assets.
]]
--[[
    Overview:
        The module library centralizes module discovery and loading under `lia.module`. It prepares the active `MODULE` or `SCHEMA` table, includes each module core file, registers privileges and dependencies, loads supported module folders and files, attaches module functions as hooks, initializes schema modules and overrides, and exposes lookup helpers for loaded modules.
]]
--[[
    Hooks:
        DoModuleIncludes(string path, table module)

    Purpose:
        Runs after a module's standard files, folders, entities, networking strings, and client web assets are included.

    Category:
        Modularity

    Parameters:
        path (string)
            The directory path of the module being loaded.

        module (table)
            The active module table for the module being loaded.

    Example Usage:
        ```lua
        hook.Add("DoModuleIncludes", "liaExampleDoModuleIncludes", function(path, module)
            print("[MyModule] handled DoModuleIncludes")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        InitializedSchema()

    Purpose:
        Runs after the active schema has been loaded and before preload, base, schema, and override modules are loaded.

    Category:
        Modularity

    Example Usage:
        ```lua
        hook.Add("InitializedSchema", "liaExampleInitializedSchema", function()
            print("[MyModule] handled InitializedSchema")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        InitializedModules()

    Purpose:
        Runs after preload, base, schema, and override modules have been loaded.

    Category:
        Modularity

    Example Usage:
        ```lua
        hook.Add("InitializedModules", "liaExampleInitializedModules", function()
            print("[MyModule] handled InitializedModules")
        end)
        ```

    Realm:
        Shared
]]
lia.module = lia.module or {}
lia.module.list = lia.module.list or {}
local function loadPermissions(Privileges)
    if not Privileges or not istable(Privileges) then return end
    for privID, privilegeData in pairs(Privileges) do
        local privilegeName = lia.lang.resolveToken(privilegeData.Name or privID)
        local privilegeCategory = privilegeData.Category or MODULE.name
        lia.admin.registerPrivilege({
            Name = privilegeName,
            ID = privID,
            MinAccess = privilegeData.MinAccess or "admin",
            Category = privilegeCategory,
            Description = privilegeData.Description or privilegeData.Desc or privilegeData.description or privilegeData.desc or privilegeData.Help or privilegeData.help or privilegeData.Tooltip or privilegeData.tooltip
        })
    end
end

local function loadDependencies(dependencies)
    if not istable(dependencies) then return end
    for _, dep in ipairs(dependencies) do
        local realm = dep.Realm
        if dep.File then
            lia.loader.include(MODULE.folder .. "/" .. dep.File, realm)
        elseif dep.Folder then
            lia.loader.includeDir(MODULE.folder .. "/" .. dep.Folder, true, true, realm)
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
        items = "shared",
    }

    local function includeDefinitionsDir(dir)
        local priority = {
            ["sh_faction.lua"] = 1,
            ["sh_factions.lua"] = 2,
            ["sh_class.lua"] = 3,
            ["sh_classes.lua"] = 4
        }

        local function loadDir(folder)
            local files, folders = file.Find(folder .. "/*", "LUA")
            table.sort(files, function(a, b)
                local aPriority = priority[a] or math.huge
                local bPriority = priority[b] or math.huge
                if aPriority == bPriority then return a:lower() < b:lower() end
                return aPriority < bPriority
            end)

            for _, fileName in ipairs(files) do
                lia.loader.include(folder .. "/" .. fileName)
            end

            table.sort(folders, function(a, b) return a:lower() < b:lower() end)
            for _, subFolder in ipairs(folders) do
                loadDir(folder .. "/" .. subFolder)
            end
        end

        loadDir(dir)
    end

    local ModuleFolders = {"config", "definitions", "dependencies", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma"}
    lia.lang.loadFromDir(path .. "/languages")
    lia.faction.loadFromDir(path .. "/factions")
    lia.class.loadFromDir(path .. "/classes")
    lia.attribs.loadFromDir(path .. "/attributes")
    for fileName, realm in pairs(ModuleFiles) do
        local filePath = path .. "/" .. fileName .. ".lua"
        if file.Exists(filePath, "LUA") then lia.loader.include(filePath, realm) end
    end

    for _, folder in ipairs(ModuleFolders) do
        local subPath = path .. "/" .. folder
        if file.Exists(subPath, "LUA") then
            if folder == "definitions" then
                includeDefinitionsDir(subPath)
            else
                lia.loader.includeDir(subPath, true, true)
            end
        end
    end

    lia.loader.includeEntities(path .. "/entities")
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

--[[
    Purpose:
        Loads a schema, module, or submodule from a directory and registers its metadata, dependencies, permissions, extras, hooks, and optional submodules.

    Parameters:
        uniqueID (string)
            The unique identifier used to register and retrieve the module.

        path (string)
            The directory path that contains the module core file and optional module folders.

        variable (string|nil)
            The global table name used while loading the module. Defaults to `MODULE`; schemas use `SCHEMA`.

        skipSubmodules (boolean|nil)
            Whether submodules should be skipped after the module finishes loading.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.module.load("inventory", "lilia/gamemode/modules/inventory", "MODULE")
        lia.module.load("schema", engine.ActiveGamemode():gsub("\\", "/") .. "/schema", "SCHEMA")
        ```

    Realm:
        Shared
]]
function lia.module.load(uniqueID, path, variable, skipSubmodules)
    variable = variable or "MODULE"
    local lowerVar = variable:lower()
    local coreFile = path .. "/" .. lowerVar .. ".lua"
    local prev = _G[variable]
    local existing = lia.module.get(uniqueID)
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
        MODULE.folder = engine.ActiveGamemode():gsub("\\", "/")
    end

    _G[variable] = MODULE
    MODULE.loading = true
    MODULE.path = path
    MODULE.variable = variable
    MODULE.name = lia.lang.resolveToken(MODULE.name)
    MODULE.desc = lia.lang.resolveToken(MODULE.desc)
    if not file.Exists(coreFile, "LUA") then
        lia.bootstrap(L("moduleSkipped"), L("moduleSkipMissing", uniqueID, lowerVar))
        _G[variable] = prev
        return
    end

    lia.loader.include(coreFile, "shared")
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
    loadDependencies(MODULE.Dependencies)
    loadExtras(path)
    MODULE.loading = false
    for k, f in pairs(MODULE) do
        if isfunction(f) then hook.Add(k, MODULE, f) end
    end

    function MODULE:IsValid()
        return true
    end

    function MODULE:setData(value, global, ignoreMap)
        lia.data.set(uniqueID, value, global, ignoreMap)
    end

    function MODULE:getData(default)
        return lia.data.get(uniqueID, default) or {}
    end

    if uniqueID ~= "schema" then
        lia.module.list[uniqueID] = MODULE
        if not skipSubmodules then loadSubmodules(path) end
        if MODULE.ModuleLoaded then MODULE:ModuleLoaded() end
        if string.StartsWith(path, engine.ActiveGamemode():gsub("\\", "/") .. "/modules") then lia.bootstrap(L("module"), L("moduleFinishedLoading", MODULE.name)) end
        _G[variable] = prev
    end
end

--[[
    Purpose:
        Initializes the schema and module loading sequence for the active gamemode.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.module.initialize()
        ```

    Realm:
        Shared
]]
function lia.module.initialize()
    local schemaPath = engine.ActiveGamemode():gsub("\\", "/")
    lia.module.load("schema", schemaPath .. "/schema", "schema")
    hook.Run("InitializedSchema")
    local preloadPath = schemaPath .. "/preload"
    local preloadIDs = collectModuleIDs(preloadPath)
    lia.module.loadFromDir(preloadPath, "module")
    local gamemodeIDs = collectModuleIDs(schemaPath .. "/modules")
    for id in pairs(collectModuleIDs(schemaPath .. "/overrides")) do
        gamemodeIDs[id] = true
    end

    for id in pairs(collectModuleIDs("lilia/gamemode/modules")) do
        if not preloadIDs[id] and gamemodeIDs[id] then lia.bootstrap(L("module"), L("modulePreloadSuggestion", id, schemaPath)) end
    end

    lia.module.loadFromDir("lilia/gamemode/modules", "module", preloadIDs)
    if lia.module.stopModulesFromLoading then return end
    lia.module.loadFromDir(schemaPath .. "/modules", "module")
    lia.module.loadFromDir(schemaPath .. "/overrides", "module")
    hook.Run("InitializedModules")
    lia.item.loadFromDir(schemaPath .. "/schema/items")
    lia.loader.includeEntities("lilia/gamemode/entities")
    lia.loader.includeEntities(engine.ActiveGamemode():gsub("\\", "/") .. "/gamemode/entities")
    for id, mod in pairs(lia.module.list) do
        if id ~= "schema" then
            local ok = isfunction(mod.enabled) and mod.enabled() or mod.enabled
            if not ok then lia.module.list[id] = nil end
        end
    end

    if lia.UpdateCheckDone then return end
    lia.loader.checkForUpdates()
    if SERVER then lia.db.addDatabaseFields() end
    lia.UpdateCheckDone = true
end

--[[
    Purpose:
        Loads every folder in a directory as a module, unless that folder is listed in the skip table.

    Parameters:
        directory (string)
            The directory whose child folders should be loaded as modules.

        group (string|nil)
            The module group used to determine the loading global. `schema` uses `SCHEMA`; all other values use `MODULE`.

        skip (table|nil)
            A table of module identifiers to skip, keyed by folder name.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.module.loadFromDir("lilia/gamemode/modules", "module")
        lia.module.loadFromDir("schema/modules", "module", {example = true})
        ```

    Realm:
        Shared
]]
function lia.module.loadFromDir(directory, group, skip)
    local locationVar = group == "schema" and "SCHEMA" or "MODULE"
    local _, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        if not skip or not skip[folderName] then lia.module.load(folderName, directory .. "/" .. folderName, locationVar) end
    end
end

--[[
    Purpose:
        Returns a loaded module table by its unique identifier.

    Parameters:
        identifier (string)
            The unique identifier of the module to retrieve.

    Returns:
        table|nil
            The loaded module table, or nil if no module is registered with that identifier.

    Example Usage:
        ```lua
        local module = lia.module.get("inventory")
        if module then print(module.name) end
        ```

    Realm:
        Shared
]]
function lia.module.get(identifier)
    return lia.module.list[identifier]
end
