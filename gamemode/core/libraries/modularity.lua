--[[
    Modularity Library

    Module loading, initialization, and lifecycle management system for the Lilia framework.
]]
--[[
    Overview:
    The modularity library provides comprehensive functionality for managing modules in the Lilia framework.
    It handles loading, initialization, and management of modules including schemas, preload modules,
    and regular modules. The library operates on both server and client sides, managing module dependencies,
    permissions, and lifecycle events. It includes functionality for loading modules from directories,
    handling module-specific data storage, and ensuring proper initialization order. The library also
    manages submodules, handles module validation, and provides hooks for module lifecycle events.
    It ensures that all modules are properly loaded and initialized before gameplay begins.
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
    Purpose: Loads a module from the specified path with the given unique identifier
    When Called: Called during module initialization, when loading modules from directories, or when manually loading specific modules
    Parameters:
        - uniqueID (string): Unique identifier for the module
        - path (string): File system path to the module directory
        - isSingleFile (boolean): Whether the module is a single file or directory-based
        - variable (string, optional): Global variable name to use (defaults to "MODULE")
        - skipSubmodules (boolean, optional): Whether to skip loading submodules
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load a basic module
    lia.module.load("mymodule", "gamemodes/lilia/modules/mymodule", false)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load module with custom variable name
    lia.module.load("custommodule", "gamemodes/lilia/modules/custom", false, "CUSTOM_MODULE")
    ```

    High Complexity:
    ```lua
    -- High: Load single file module with submodule skipping
    lia.module.load("singlemode", "gamemodes/lilia/modules/single.lua", true, "SINGLE_MODULE", true)
    ```
]]
--
function lia.module.load(uniqueID, path, isSingleFile, variable, skipSubmodules)
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
        MODULE.folder = engine.ActiveGamemode()
    end

    _G[variable] = MODULE
    MODULE.loading = true
    MODULE.path = path
    MODULE.isSingleFile = isSingleFile
    MODULE.variable = variable
    MODULE.name = L(MODULE.name)
    MODULE.desc = L(MODULE.desc)
    if isSingleFile then
        lia.loader.include(path, "shared")
    else
        if not file.Exists(coreFile, "LUA") then
            lia.bootstrap(L("moduleSkipped"), L("moduleSkipMissing", uniqueID, lowerVar))
            _G[variable] = prev
            return
        end

        lia.loader.include(coreFile, "shared")
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

--[[
    Purpose: Initializes the entire module system, loading schemas, preload modules, and regular modules in proper order
    When Called: Called during gamemode initialization to set up the complete module ecosystem
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Initialize modules (typically called automatically)
    lia.module.initialize()
    ```

    Medium Complexity:
    ```lua
    -- Medium: Initialize with custom schema path
    local schemaPath = "gamemodes/mygamemode"
    lia.module.load("schema", schemaPath .. "/schema", false, "schema")
    lia.module.initialize()
    ```

    High Complexity:
    ```lua
    -- High: Initialize with custom module loading order
    lia.module.initialize()
    -- Custom post-initialization logic
    for id, mod in pairs(lia.module.list) do
        if mod.PostInitialize then
            mod:PostInitialize()
        end
    end
    ```
]]
--
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
    if SERVER then timer.Simple(0.1, function() lia.db.addDatabaseFields() end) end
    lia.item.loadFromDir(schemaPath .. "/schema/items")
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
    Purpose: Loads all modules from a specified directory
    When Called: Called during module initialization to load multiple modules from a directory, or when manually loading modules from a specific folder
    Parameters:
        - directory (string): Path to the directory containing modules
        - group (string): Type of module group ("module", "schema", etc.)
        - skip (table, optional): Table of module IDs to skip loading
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load all modules from a directory
    lia.module.loadFromDir("gamemodes/lilia/modules", "module")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load modules with specific group type
    lia.module.loadFromDir("gamemodes/mygamemode/modules", "module")
    ```

    High Complexity:
    ```lua
    -- High: Load modules with skip list
    local skipModules = {["disabledmodule"] = true, ["testmodule"] = true}
    lia.module.loadFromDir("gamemodes/lilia/modules", "module", skipModules)
    ```
]]
--
function lia.module.loadFromDir(directory, group, skip)
    local locationVar = group == "schema" and "SCHEMA" or "MODULE"
    local _, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        if not skip or not skip[folderName] then lia.module.load(folderName, directory .. "/" .. folderName, false, locationVar) end
    end
end

--[[
    Purpose: Retrieves a loaded module by its unique identifier
    When Called: Called when you need to access a specific module's data or functions, or to check if a module is loaded
    Parameters:
        - identifier (string): Unique identifier of the module to retrieve
    Returns: Module table or nil if not found
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get a module
    local myModule = lia.module.get("mymodule")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Check if module exists and use it
    local module = lia.module.get("inventory")
    if module and module.GetItem then
        local item = module:GetItem("weapon_pistol")
    end
    ```

    High Complexity:
    ```lua
    -- High: Iterate through all modules and perform operations
    for id, module in pairs(lia.module.list) do
        local mod = lia.module.get(id)
        if mod and mod.OnPlayerSpawn then
            mod:OnPlayerSpawn(player)
        end
    end
    ```
]]
--
function lia.module.get(identifier)
    return lia.module.list[identifier]
end
