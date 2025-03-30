lia.module = lia.module or {}
lia.module.list = lia.module.list or {}
local ModuleFolders = {"config", "dependencies", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma", "pim"}
local ModuleFiles = {"pim.lua", "client.lua", "server.lua", "config.lua", "commands.lua"}
local function loadWorkshopContent(Workshop)
    if SERVER and Workshop then
        if istable(Workshop) then
            for _, workshopID in ipairs(Workshop) do
                if isstring(workshopID) and workshopID:match("^%d+$") then
                    resource.AddWorkshop(workshopID)
                else
                    LiliaInformation("Invalid Workshop ID: " .. tostring(workshopID))
                end
            end
        else
            resource.AddWorkshop(Workshop)
        end
    end
end

local function checkVersion(module, isPublic)
    local moduleID = module.uniqueID
    local CheckerURL = {
        public = "https://raw.githubusercontent.com/LiliaFramework/Modules/main/modules.json",
        private = ""
    }

    local moduleURL = isPublic and CheckerURL.public or CheckerURL.private
    if moduleURL == "" then
        LiliaUpdater("Detected Public Plugin, can't evaluate update status as no version exists.")
        return
    end

    http.Fetch(moduleURL, function(body, _, _, code)
        if code ~= 200 then
            LiliaUpdater("Error fetching module list (HTTP " .. code .. ")")
            return
        end

        local modules = util.JSONToTable(body)
        if not modules then
            LiliaUpdater("Error parsing module data")
            return
        end

        local module = nil
        for _, m in ipairs(modules) do
            if m.uniqueID == moduleID then
                module = m
                break
            end
        end

        if not module then
            LiliaUpdater("Module with uniqueID '" .. moduleID .. "' not found")
            return
        end

        if not module.version then
            LiliaUpdater("Detected Public Plugin, can't evaluate update status as no version exists.")
            return
        end

        if module.version ~= module.version then
            LiliaUpdater("Module '" .. module.name .. "' has a version mismatch. " .. (isPublic and "Please update to version " .. module.version .. " at " .. module.source) or "Request an update from the developer.")
        else
            LiliaUpdater("Module " .. module.name .. " is up-to-date.")
        end
    end, function(err) LiliaUpdater("HTTP.Fetch error: " .. err) end)
end

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

local function loadSubmodules(path, firstLoad)
    local files, folders = file.Find(path .. "/submodules/*", "LUA")
    if #files > 0 or #folders > 0 then lia.module.loadFromDir(path .. "/submodules", "module", firstLoad) end
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
      firstLoad - Boolean indicating if this is the first load of the module.

   Returns:
      nil
]]
function lia.module.load(uniqueID, path, isSingleFile, variable, firstLoad)
    local lowerVariable = variable:lower()
    local normalPath = path .. "/" .. lowerVariable .. ".lua"
    local extendedPath = path .. "/sh_" .. lowerVariable .. ".lua"
    local ModuleCore = file.Exists(normalPath, "LUA")
    local ExtendedCore = file.Exists(extendedPath, "LUA")
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
        lia.include(ModuleCore and normalPath or extendedPath, "shared")
    end

    local isEnabled = isfunction(MODULE.enabled) and MODULE.enabled() or MODULE.enabled
    if uniqueID ~= "schema" and not isEnabled then
        MODULE = oldModule
        return
    end

    if uniqueID ~= "schema" and MODULE.identifier and MODULE.identifier ~= "" then _G[MODULE.identifier] = {} end
    loadPermissions(MODULE.CAMIPrivileges)
    loadWorkshopContent(MODULE.WorkshopContent)
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
        loadSubmodules(path, firstLoad)
        if MODULE.ModuleLoaded then MODULE:ModuleLoaded() end
        if MODULE.Public ~= nil then checkVersion(MODULE, MODULE.Public) end
        _G[variable] = oldModule
    end
end

--[[
   Function: lia.module.initialize

   Description:
      Initializes the module system by loading the schema and various module directories,
      then running the appropriate hooks after modules have been loaded.

   Parameters:
      firstLoad - Boolean indicating if this is the first time loading modules.

   Returns:
      nil
]]
function lia.module.initialize(firstLoad)
    local schema = engine.ActiveGamemode()
    lia.module.load("schema", schema .. "/schema", false, "schema", firstLoad)
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module", firstLoad)
    lia.module.loadFromDir("lilia/modules/frameworkui", "module", firstLoad)
    lia.module.loadFromDir("lilia/modules/characters", "module", firstLoad)
    lia.module.loadFromDir("lilia/modules/utilities", "module", firstLoad)
    lia.module.loadFromDir(schema .. "/preload", "module", firstLoad)
    lia.module.loadFromDir(schema .. "/modules", "module", firstLoad)
    lia.module.loadFromDir(schema .. "/overrides", "module", firstLoad)
    hook.Run("InitializedModules")
end

--[[
   Function: lia.module.loadFromDir

   Description:
      Loads modules from a specified directory. It iterates over all folders and files in the directory,
      loading each as a module based on whether it is a folder (multi-file module) or a single file.

   Parameters:
      directory - The directory path from which to load modules.
      group - A string representing the module group (e.g., "schema" or "module").
      firstLoad - Boolean indicating if this is the first load.

   Returns:
      nil
]]
function lia.module.loadFromDir(directory, group, firstLoad)
    local locationVar = group == "schema" and "SCHEMA" or "MODULE"
    local files, folders = file.Find(directory .. "/*", "LUA")
    for _, folderName in ipairs(folders) do
        lia.module.load(folderName, directory .. "/" .. folderName, false, locationVar, firstLoad)
    end

    for _, fileName in ipairs(files) do
        local uniqueID = string.StripExtension(fileName)
        lia.module.load(uniqueID, directory .. "/" .. fileName, true, locationVar, firstLoad)
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
