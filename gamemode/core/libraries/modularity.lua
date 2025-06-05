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

local function loadDependencies(Dependencies)
    if not Dependencies then return end
    if istable(Dependencies) then
        for _, dep in ipairs(Dependencies) do
            lia.include(dep.File, dep.Realm)
        end
    else
        lia.include(Dependencies)
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
   Function: lia.module.load

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
function lia.module.load(uniqueID, path, isSingleFile, variable)
    variable = variable or "MODULE"
    local lowerVariable = variable:lower()
    local ModuleCore = path .. "/" .. lowerVariable .. ".lua"
    if not isSingleFile and not ModuleCore then return end
    local oldModule = MODULE
    MODULE = {
        folder = path,
        module = oldModule,
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
        lia.include(ModuleCore, "shared")
    end

    local isEnabled = isfunction(MODULE.enabled) and MODULE.enabled() or MODULE.enabled
    if uniqueID ~= "schema" and not isEnabled then
        MODULE = oldModule
        return
    end

    if uniqueID ~= "schema" and MODULE.identifier and MODULE.identifier ~= "" then _G[MODULE.identifier] = {} end
    loadPermissions(MODULE.CAMIPrivileges)
    if not isSingleFile then
        loadDependencies(MODULE.Dependencies)
        loadExtras(path)
    end

    MODULE.loading = false
    local uniqueID2 = uniqueID == "schema" and MODULE.name or uniqueID
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
        if MODULE.identifier and MODULE.identifier ~= "" and uniqueID ~= "schema" then _G[MODULE.identifier] = lia.module.list[uniqueID] end
        loadSubmodules(path)
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

        _G[variable] = oldModule
    end
end

--[[
   Function: lia.module.initialize

   Description:
      Initializes the module system by loading the schema and various module directories,
      then running the appropriate hooks after modules have been loaded.

   Parameters:
      None

   Returns:
      nil
]]
function lia.module.initialize()
    local schema = engine.ActiveGamemode()
    lia.module.load("schema", schema .. "/schema", false, "schema")
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module")
    lia.module.loadFromDir("lilia/modules/frameworkui", "module")
    lia.module.loadFromDir("lilia/modules/characters", "module")
    lia.module.loadFromDir("lilia/modules/utilities", "module")
    lia.module.loadFromDir(schema .. "/preload", "module")
    lia.module.loadFromDir(schema .. "/modules", "module")
    lia.module.loadFromDir(schema .. "/overrides", "module")
    hook.Run("InitializedModules")
end

--[[
   Function: lia.module.loadFromDir

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
   Function: lia.module.get

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