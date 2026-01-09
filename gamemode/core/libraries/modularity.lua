--[[
    Folder: Libraries
    File: module.md
]]
--[[
    Modularity Library

    Module loading, initialization, and lifecycle management system for the Lilia framework.
]]
--[[
    Overview:
        The modularity library provides comprehensive functionality for managing modules in the Lilia framework. It handles loading, initialization, and management of modules including schemas, preload modules, and regular modules. The library operates on both server and client sides, managing module dependencies, permissions, and lifecycle events. It includes functionality for loading modules from directories, handling module-specific data storage, and ensuring proper initialization order. The library also manages submodules, handles module validation, and provides hooks for module lifecycle events. It ensures that all modules are properly loaded and initialized before gameplay begins.
]]
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
    }

    local ModuleFolders = {"config", "dependencies", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma"}
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
        if file.Exists(subPath, "LUA") then lia.loader.includeDir(subPath, true, true) end
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
        Loads and initializes a module from a specified directory path with the given unique ID.

    When Called:
        Called during module initialization to load individual modules, their dependencies, and register them in the system.

    Parameters:
        uniqueID (string)
            The unique identifier for the module.
        path (string)
            The file system path to the module directory.
        variable (string, optional)
            The global variable name to assign the module to (defaults to "MODULE").
        skipSubmodules (boolean, optional)
            Whether to skip loading submodules for this module.

    Returns:
        nil
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Load a custom module
            lia.module.load("mymodule", "gamemodes/my_schema/modules/mymodule")
        ```
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
    MODULE.name = L(MODULE.name)
    MODULE.desc = L(MODULE.desc)
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
        Initializes the entire module system by loading the schema, preload modules, and all available modules in the correct order.

    When Called:
        Called once during gamemode initialization to set up the module loading system and load all modules.

    Parameters:
        None

    Returns:
        nil
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Initialize the module system (called automatically by the framework)
            lia.module.initialize()
        ```
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
        if not preloadIDs[id] and gamemodeIDs[id] then lia.bootstrap(L("module"), L("modulePreloadSuggestion", id)) end
    end

    lia.module.loadFromDir("lilia/gamemode/modules", "module", preloadIDs)
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
        Loads all modules found in the specified directory, optionally skipping certain modules.

    When Called:
        Called during module initialization to load groups of modules from directories like preload, modules, and overrides.

    Parameters:
        directory (string)
            The directory path to search for modules.
        group (string)
            The type of modules being loaded ("schema" or "module").
        skip (table, optional)
            A table of module IDs to skip loading.

    Returns:
        nil
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Load all modules from the gamemode's modules directory
            lia.module.loadFromDir("gamemodes/my_schema/modules", "module")
        ```
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
        Retrieves a loaded module by its unique identifier.

    When Called:
        Called whenever code needs to access a specific module's data or functions.

    Parameters:
        identifier (string)
            The unique identifier of the module to retrieve.

    Returns:
        table or nil
            The module table if found, nil if the module doesn't exist.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Get a reference to the inventory module
            local inventoryModule = lia.module.get("inventory")
            if inventoryModule then
                -- Use the module
            end
        ```
]]
function lia.module.get(identifier)
    return lia.module.list[identifier]
end
