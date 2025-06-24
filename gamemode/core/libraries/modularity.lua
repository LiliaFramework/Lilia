lia.module = lia.module or {}
lia.module.list = lia.module.list or {}
local ModuleFolders = {"config", "dependencies", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma", "pim"}
local ModuleFiles = {"pim.lua", "client.lua", "server.lua", "config.lua", "commands.lua"}
local function loadPermissions(Privileges)
    if not Privileges or not istable(Privileges) then return end
    for _, privilegeData in ipairs(Privileges) do
        local privilegeName = privilegeData.Name
        if not CAMI.GetPrivilege(privilegeName) then
            CAMI.RegisterPrivilege({
                Name = privilegeName,
                MinAccess = privilegeData.MinAccess or "admin",
                Description = privilegeData.Description or "Allows access to " .. privilegeName:gsub("^%l", string.upper)
            })
        end
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

local function loadExtras(path)
    lia.lang.loadFromDir(path .. "/languages")
    lia.faction.loadFromDir(path .. "/factions")
    lia.class.loadFromDir(path .. "/classes")
    lia.attribs.loadFromDir(path .. "/attributes")
    for _, fileName in ipairs(ModuleFiles) do
        local filePath = path .. "/" .. fileName
        if file.Exists(filePath, "LUA") then lia.include(filePath) end
    end

    for _, folder in ipairs(ModuleFolders) do
        local subPath = path .. "/" .. folder
        if file.Exists(subPath, "LUA") then lia.includeDir(subPath, true, true) end
    end

    lia.includeEntities(path .. "/entities")
    lia.item.loadFromDir(path .. "/items")
    hook.Run("DoModuleIncludes", path, MODULE)
end

local function loadSubmodules(path)
    local files, folders = file.Find(path .. "/submodules/*", "LUA")
    if #files > 0 or #folders > 0 then lia.module.loadFromDir(path .. "/submodules", "module") end
end

--[[
   lia.module.load

   Description:
      Loads a module from a specified path. If the module is a single file, it includes it directly;
      if it is a directory, it loads the core file (or its extended version), applies permissions, workshop content, dependencies, extras, and submodules.
      It also registers the module in the module list if applicable.

   Parameters:
      uniqueID - The unique identifier of the module.
      path - The file system path where the module is located.
      isSingleFile - Boolean indicating if the module is a single file.
      variable - A global variable name used to temporarily store the module.

   Returns:
      nil
]]
function lia.module.load(uniqueID, path, isSingleFile, variable, skipSubmodules)
    variable = variable or "MODULE"
    local lowerVar = variable:lower()
    local coreFile = path .. "/" .. lowerVar .. ".lua"
    local prev = _G[variable]
    MODULE = {
        folder = path,
        module = prev,
        uniqueID = uniqueID,
        name = L("unknown"),
        desc = L("noDesc"),
        author = L("anonymous"),
        identifier = "",
        enabled = true,
        IsValid = function() return true end
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
        lia.include(path, "shared")
    else
        if not file.Exists(coreFile, "LUA") then
            lia.bootstrap("Module", "Skipping module '" .. uniqueID .. "' - missing " .. lowerVar .. ".lua")
            _G[variable] = prev
            return
        end

        lia.include(coreFile, "shared")
    end

    local enabled
    if isfunction(MODULE.enabled) then
        enabled = MODULE.enabled()
    else
        enabled = MODULE.enabled
    end

    if uniqueID ~= "schema" and not enabled then
        lia.bootstrap("Module", "Disabled module '" .. MODULE.name .. "'")
        lia.module.list[uniqueID] = nil
        if MODULE.identifier ~= "" then _G[MODULE.identifier] = nil end
        _G[variable] = prev
        return
    end

    if uniqueID ~= "schema" and MODULE.identifier ~= "" then _G[MODULE.identifier] = {} end
    loadPermissions(MODULE.CAMIPrivileges)
    if not isSingleFile then
        loadDependencies(MODULE.Dependencies)
        loadExtras(path)
    end

    MODULE.loading = false
    local idKey = uniqueID == "schema" and MODULE.name or uniqueID
    function MODULE:setData(v, g, m)
        lia.data.set(idKey, v, g, m)
    end

    function MODULE:getData(d, g, m, r)
        return lia.data.get(idKey, d, g, m, r) or {}
    end

    for k, f in pairs(MODULE) do
        if isfunction(f) then hook.Add(k, MODULE, f) end
    end

    if uniqueID == "schema" then
        function MODULE:IsValid()
            return true
        end
    else
        lia.module.list[uniqueID] = MODULE
        if not skipSubmodules then loadSubmodules(path) end
        if MODULE.ModuleLoaded then MODULE:ModuleLoaded() end
        if MODULE.Public then
            lia.module.versionChecks = lia.module.versionChecks or {}
            table.insert(lia.module.versionChecks, {
                uniqueID = MODULE.uniqueID,
                name = MODULE.name,
                localVersion = MODULE.version,
                source = MODULE.source
            })
        end

        if MODULE.Private then
            lia.module.privateVersionChecks = lia.module.privateVersionChecks or {}
            table.insert(lia.module.privateVersionChecks, {
                uniqueID = MODULE.uniqueID,
                name = MODULE.name,
                localVersion = MODULE.version,
                source = MODULE.source
            })
        end

        if string.StartsWith(path, engine.ActiveGamemode() .. "/modules") then lia.bootstrap("Module", "Finished Loading Module '" .. MODULE.name .. "'") end
        _G[variable] = prev
    end
end

--[[
   lia.module.initialize

   Description:
      Initializes the module system by loading the schema and various module directories,
      then running the appropriate hooks after modules have been loaded.

   Parameters:
      None

   Returns:
      nil
]]
function lia.module.initialize()
    local schemaPath = engine.ActiveGamemode()
    lia.module.load("schema", schemaPath .. "/schema", false, "schema")
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module")
    lia.module.loadFromDir("lilia/modules/frameworkui", "module")
    lia.module.loadFromDir("lilia/modules/characters", "module")
    lia.module.loadFromDir("lilia/modules/utilities", "module")
    lia.module.loadFromDir(schemaPath .. "/preload", "module")
    lia.module.loadFromDir(schemaPath .. "/modules", "module")
    lia.module.loadFromDir(schemaPath .. "/overrides", "module")
    hook.Run("InitializedModules")
    for id, mod in pairs(lia.module.list) do
        if id ~= "schema" then
            local ok = isfunction(mod.enabled) and mod.enabled() or mod.enabled
            if not ok then
                lia.module.list[id] = nil
                if mod.identifier ~= "" then _G[mod.identifier] = nil end
            end
        end
    end
end

--[[
   lia.module.loadFromDir

   Description:
      Loads modules from a specified directory. It iterates over all subfolders and .lua files in the directory.
      Each subfolder is treated as a multi-file module, and each .lua file as a single-file module.
      Non-Lua files are ignored.

   Parameters:
      directory - The directory path from which to load modules.
      group - A string representing the module group (e.g., "schema" or "module").

   Returns:
      nil
]]
function lia.module.loadFromDir(directory, group)
    local locationVar = group == "schema" and "SCHEMA" or "MODULE"
    local files, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        lia.module.load(folderName, directory .. "/" .. folderName, false, locationVar)
    end

    for _, fileName in ipairs(files) do
        if fileName:sub(-4) == ".lua" then
            local uniqueID = string.StripExtension(fileName)
            lia.module.load(uniqueID, directory .. "/" .. fileName, true, locationVar)
        end
    end
end

--[[
   lia.module.get

   Description:
      Retrieves a module table by its identifier.

   Parameters:
      identifier - The unique identifier of the module to retrieve.

   Returns:
      The module table if found, or nil if the module is not registered.
]]
function lia.module.get(identifier)
    return lia.module.list[identifier]
end