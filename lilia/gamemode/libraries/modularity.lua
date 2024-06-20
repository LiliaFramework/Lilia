--[[--
Core library that manages module loading behaviors.

If you are looking for the module structure, you can find it [here](https://liliaframework.github.io/manual/structure_module).
]]
-- @library lia.module
lia.module = lia.module or {}
lia.module.EnabledList = {}
lia.module.list = lia.module.list or {}
lia.module.unloaded = lia.module.unloaded or {}
lia.module.ModuleFolders = {"dependencies", "config", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma", "pim", "concommands"}
lia.module.ModuleFiles = {"client.lua", "cl_module.lua", "sv_module.lua", "server.lua", "config.lua", "sconfig.lua"}
--- Loads a module into the system.
-- This function loads a module into the system, making its functionality available. It sets up the module environment, including defining globals and loading necessary files.
-- @string uniqueID The unique identifier of the module.
-- @string path The path to the module.
-- @bool isSingleFile Specifies if the module is contained in a single file.
-- @string variable The variable name to assign the module to.
-- @bool firstLoad Indicates if this is the first load of the module.
-- @realm shared
-- @internal
function lia.module.load(uniqueID, path, isSingleFile, variable, category, firstLoad)
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
        lia.include(ModuleCore and normalpath or ExtendedCore and extendedpath, "shared")
    end

    if uniqueID ~= "schema" and MODULE.enabled == false then
        MODULE = oldModule
        return
    end

    if MODULE.identifier and MODULE.identifier ~= "" and uniqueID ~= "schema" then _G[MODULE.identifier] = {} end
    lia.module.loadPermissions(MODULE.CAMIPrivileges)
    lia.module.loadWorkshop(MODULE.WorkshopContent)
    if not isSingleFile then
        lia.module.loadDependencies(MODULE.Dependencies)
        lia.module.loadExtras(path)
    end

    MODULE.loading = false
    local uniqueID2 = (uniqueID == "schema") and MODULE.name or uniqueID
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
        lia.module.OnFinishLoad(uniqueID, path, category, firstLoad)
        _G[variable] = oldModule
    end

    if MODULE.ModuleLoaded then MODULE:ModuleLoaded() end
end

--- Loads the additional files associated with the module.
-- This function loads extra files tied to the module, such as language files, factions, classes, and attributes.
-- @string path The path to the module directory.
-- @realm shared
-- @internal
function lia.module.loadExtras(path)
    lia.lang.loadFromDir(path .. "/languages")
    lia.faction.loadFromDir(path .. "/factions")
    lia.class.loadFromDir(path .. "/classes")
    lia.attribs.loadFromDir(path .. "/attributes")
    for _, fileName in ipairs(lia.module.ModuleFiles) do
        local filePath = path .. "/" .. fileName
        if file.Exists(filePath, "LUA") then lia.include(filePath) end
    end

    for _, folder in ipairs(lia.module.ModuleFolders) do
        local subFolders = path .. "/" .. folder
        if file.Exists(subFolders, "LUA") then lia.includeDir(subFolders, true, true) end
    end

    lia.includeEntities(path .. "/entities")
    lia.item.loadFromDir(path .. "/items")
    hook.Run("DoModuleIncludes", path, MODULE)
end

--- Loads and initializes the modules.
-- This function loads and initializes modules located under their respective folders.
-- @bool firstLoad Indicates if this is the first load of the modules.
-- @realm shared
-- @internal
function lia.module.initialize(firstLoad)
    local schema = engine.ActiveGamemode()
    lia.module.load("schema", schema .. "/schema", false, "schema", "Schema", firstLoad)
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module", "Core", firstLoad)
    lia.module.loadFromDir("lilia/modules/frameworkui", "module", "Visuals", firstLoad)
    lia.module.loadFromDir("lilia/modules/characters", "module", "Characters", firstLoad)
    lia.module.loadFromDir("lilia/modules/utilities", "module", "Utilities", firstLoad)
    lia.module.loadFromDir("lilia/modules/compatibility", "module", "Compatibility", firstLoad)
    lia.module.loadFromDir(schema .. "/preload", "module", "Schema", firstLoad)
    lia.module.loadFromDir(schema .. "/modules", "module", "Schema", firstLoad)
    lia.module.loadFromDir(schema .. "/overrides", "module", "Schema", firstLoad)
    hook.Run("InitializedModules")
end

--- Loads modules from a directory.
-- This function loads modules from a specified directory into the system.
-- @string directory The path to the directory containing modules.
-- @string group The group of the modules (e.g., "schema" or "module").
-- @bool firstLoad Indicates if this is the first load of the modules.
-- @realm shared
-- @internal
function lia.module.loadFromDir(directory, group, category, firstLoad)
    local location = group == "schema" and "SCHEMA" or "MODULE"
    local files, folders = file.Find(directory .. "/*", "LUA")
    for _, v in ipairs(folders) do
        lia.module.load(v, directory .. "/" .. v, false, location, category, firstLoad)
    end

    for _, v in ipairs(files) do
        lia.module.load(string.StripExtension(v), directory .. "/" .. v, true, location, category, firstLoad)
    end
end

--- Loads workshop content.
-- @param Workshop The workshop content to load. This is the MODULE.WorkshopContent.
-- @realm server
-- @internal
function lia.module.loadWorkshop(Workshop)
    if not Workshop then return end
    if not SERVER then return end
    if istable(Workshop) then
        for _, workshopID in ipairs(Workshop) do
            if isstring(workshopID) and workshopID:match("^%d+$") then
                resource.AddWorkshop(workshopID)
            else
                LiliaInformation("Invalid Workshop ID: " .. workshopID)
            end
        end
    else
        resource.AddWorkshop(Workshop)
    end
end

--- Loads permissions.
-- @param Privileges The privileges to load. This is the MODULE.CAMIPrivileges.
-- @realm shared
-- @internal
function lia.module.loadPermissions(Privileges)
    if not Privileges then return end
    if not istable(Privileges) then return end
    for _, privilegeData in ipairs(Privileges) do
        local privilegeInfo = {
            Name = privilegeData.Name,
            MinAccess = privilegeData.MinAccess or "admin",
            Description = privilegeData.Description or ("Allows access to " .. privilegeData.Name:gsub("^%l", string.upper))
        }

        if not CAMI.GetPrivilege(privilegeData.Name) then CAMI.RegisterPrivilege(privilegeInfo) end
    end
end

--- Loads module dependencies.
-- @param Dependencies The dependencies to load.
-- @realm shared
-- @internal
function lia.module.loadDependencies(Dependencies)
    if not Dependencies then return end
    if istable(Dependencies) then
        for _, dependency in ipairs(Dependencies) do
            lia.include(dependency.File, dependency.Realm)
        end
    else
        lia.include(Dependencies)
    end
end

--- Retrieves a module.
-- This function retrieves a module table based on its identifier.
-- @string identifier The identifier of the module.
-- @return table The module object.
-- @realm shared
function lia.module.get(identifier)
    return lia.module.list[identifier]
end

--- Loads a module's submodules if present.
-- This function handles the loading of a module's submodules, if they exist.
-- @string uniqueID The unique identifier for the module.
-- @string path The path to the module.
-- @bool firstLoad Indicates if this is the first load of the module.
-- @realm shared
-- @internal
function lia.module.OnFinishLoad(uniqueID, path, category, firstLoad)
    local moduleTable = lia.module.list[uniqueID]
    local identifier = moduleTable.identifier
    local name = moduleTable.name
    local files, folders = file.Find(path .. "/submodules/*", "LUA")
    if identifier ~= "" then _G[identifier] = moduleTable end
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(135, 206, 250), "[" .. string.FirstToUpper(category) .. " Modules] ", color_white, (firstLoad and "Finished Loading '" .. name .. "'\n") or "Finished Reloading '" .. name .. "'\n")
    if #files > 0 or #folders > 0 then
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. string.FirstToUpper(category) .. " SubModules] ", color_white, (firstLoad and "Finished Loading Submodules For '" .. name .. "'\n") or "Finished Reloading '" .. name .. "'\n")
        lia.module.loadFromDir(path .. "/submodules", "module", category, firstLoad)
    end
end
