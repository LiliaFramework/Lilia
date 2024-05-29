--[[--
Core library that manages module loading behaviors.

If you are looking for the module structure, you can find it [here](https://liliaframework.github.io/manual/structure_module).
]]
-- @module lia.module
lia.module = lia.module or {}
lia.module.EnabledList = {}
lia.module.list = lia.module.list or {}
lia.module.unloaded = lia.module.unloaded or {}
lia.module.ModuleFolders = {"dependencies", "config", "libs", "hooks", "libraries", "commands", "netcalls", "meta", "derma", "pim", "concommands"}
lia.module.ModuleFiles = {"client.lua", "cl_module.lua", "sv_module.lua", "server.lua", "config.lua", "sconfig.lua"}
lia.module.ModuleConditions = {
    ["stormfox2"] = {
        name = "StormFox 2",
        global = "StormFox2"
    },
    ["prone"] = {
        name = "Prone Mod",
        global = "prone"
    },
    ["streamradios"] = {
        name = "3D Stream Radios",
        global = "StreamRadioLib"
    },
    ["vjbase"] = {
        name = "VJ Base",
        global = "VJ"
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

--- Loads a module into the system.
-- This function loads a module into the system, making its functionality available. It sets up the module environment, including defining globals and loading necessary files.
-- @string uniqueID string The unique identifier of the module.
-- @string path string The path to the module.
-- @bool isSingleFile boolean Specifies if the module is contained in a single file.
-- @string variable string The variable name to assign the module to.
-- @realm shared
-- @internal
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
        lia.include(path, "shared")
    else
        lia.include(ModuleCore and normalpath or ExtendedCore and extendedpath, "shared")
    end

    local ModuleWorkshopContent = MODULE.WorkshopContent
    local ModuleDependencies = MODULE.Dependencies
    local ModuleCAMIPermissions = MODULE.CAMIPrivileges
    local ModuleGlobal = MODULE.identifier
    local IsValidForGlobal = ModuleGlobal ~= "" and ModuleGlobal ~= nil
    if IsValidForGlobal and uniqueID ~= "schema" then _G[ModuleGlobal] = MODULE end
    if ModuleCAMIPermissions and istable(ModuleCAMIPermissions) then
        for _, privilegeData in ipairs(ModuleCAMIPermissions) do
            local privilegeInfo = {
                Name = privilegeData.Name,
                MinAccess = privilegeData.MinAccess or "admin",
                Description = privilegeData.Description or ("Allows access to " .. privilegeData.Name:gsub("^%l", string.upper))
            }

            if not CAMI.GetPrivilege(privilegeData.Name) then
                CAMI.RegisterPrivilege(privilegeInfo)
                print("[" .. MODULE.name .. "] " .. "Registering Privilege " .. privilegeData.Name)
            end
        end
    end

    if IsValidForGlobal and uniqueID ~= "schema" then _G[ModuleGlobal] = MODULE end
    if ModuleWorkshopContent and SERVER then
        if istable(ModuleWorkshopContent) then
            for i = 1, #ModuleWorkshopContent do
                local workshopID = ModuleWorkshopContent[i]
                if isstring(workshopID) and workshopID:match("^%d+$") then
                    resource.AddWorkshop(workshopID)
                else
                    print("Invalid Workshop ID:", workshopID)
                end
            end
        else
            resource.AddWorkshop(ModuleWorkshopContent)
        end
    end

    if ModuleDependencies then
        if istable(ModuleDependencies) then
            for _, dependency in ipairs(ModuleDependencies) do
                local filepath = dependency.File
                local realm = dependency.Realm
                lia.include(filepath, realm)
            end
        else
            lia.include(filepath)
        end
    end

    if lia.module.verifyModuleValidity(uniqueID, MODULE.enabled) then
        lia.module.EnabledList[tostring(MODULE.name)] = true
    else
        if lia.module.ModuleConditions[uniqueID] == nil then print(MODULE.name .. " is disabled. Disabling!") end
        lia.module.EnabledList[MODULE.name] = false
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
    lia.module.loadFromDir(path .. "/submodules", "module")
    lia.module.loadFromDir(path .. "/modules", "module")
    hook.Run("DoModuleIncludes", path, MODULE)
end

--- Loads and initializes the modules.
-- This function loads and initializes modules located under their respective folders.
-- @realm shared
-- @internal
function lia.module.initialize()
    local schema = engine.ActiveGamemode()
    lia.module.loadFromDir(schema .. "/overrides", "module")
    lia.module.load("schema", schema .. "/schema", false, "schema")
    hook.Run("InitializedSchema")
    lia.module.loadFromDir("lilia/modules/core", "module")
    lia.module.loadFromDir("lilia/modules/frameworkui", "module")
    lia.module.loadFromDir("lilia/modules/characters", "module")
    lia.module.loadFromDir("lilia/modules/utilities", "module")
    lia.module.loadFromDir("lilia/modules/compatibility", "module")
    lia.module.loadFromDir(schema .. "/preload", "module")
    lia.module.loadFromDir(schema .. "/modules", "module")
    hook.Run("InitializedModules")
end

--- Checks if a module should load.
-- This function verifies whether a module should be loaded based on its unique ID and conditions.
-- @bool uniqueID The unique identifier of the module.
-- @string isEnabled Is the module enabled?
-- @return boolean Should the module be loaded?
-- @realm shared
-- @internal
function lia.module.verifyModuleValidity(uniqueID, isEnabled)
    if uniqueID == "schema" then return true end
    for ModuleName, conditions in pairs(lia.module.ModuleConditions) do
        if uniqueID ~= ModuleName then continue end
        if _G[conditions.global] ~= nil then
            print(conditions.name .. " found. Activating Compatibility!")
            return true
        else
            return false
        end
    end
    return isEnabled ~= false
end

--- Loads modules from a directory.
-- This function loads modules from a specified directory into the system.
-- @string directory The path to the directory containing modules.
-- @string group The group of the modules (e.g., "schema" or "module").
-- @realm shared
-- @internal
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

--- Retrieves a module.
-- This function retrieves a module table based on its identifier.
-- @string identifier The identifier of the module.
-- @return table The module object.
-- @realm shared
function lia.module.get(identifier)
    return lia.module.list[identifier]
end
--- A list of available MODULE fields.
-- @realm shared
-- @table CommandList
-- @field `MODULE.name` Specifies the name of the module, which is "Core - Permissions" in this case. This variable identifies the module.
-- @field `MODULE.author` Indicates the author of the module. It can be a STEAMID64 or Name. Replace "76561198312513285" with the actual author information.
-- @field `MODULE.discord` Indicates the discord of the module creator, in this case, as shown, is liliaplayer.
-- @field `MODULE.desc` Provides a brief description of the module's purpose. In this case, it states that the module adds skills functionality to the framework.
-- @field `MODULE.CAMIPrivileges` An example CAMI permission that is loaded alongside the module.
-- @field `MODULE.WorkshopContent` Workshop Content to be added.
-- @field `MODULE.enabled` Indicates if the module is active or not. If False, then it won't be.
-- @field `MODULE.Dependencies` Files and corresponding realms to be included.
-- @field `MODULE.identifier` This global variable uniquely identifies the module and allows it to be accessed from outside its scope.
