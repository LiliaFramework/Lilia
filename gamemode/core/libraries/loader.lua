lia = lia or {
    util = {},
    gui = {},
    meta = {},
    loader = {}
}

local FilesToLoad = {
    {
        path = "lilia/gamemode/core/libraries/net.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/keybind.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/playerinteract.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/admin.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/workshop.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/fonts.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/option.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/util.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/notice.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/performance.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/hooks/shared.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/hooks/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/hooks/server.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/color.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/logger.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/discord.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/modularity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/chatbox.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/commands.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/flags.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/tool.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/webimage.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/websound.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/attributes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/factions.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/classes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/thirdperson.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/currency.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/vendor.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/time.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/vector.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/entity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/player.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/panel.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/darkrp.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/menu.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/bars.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/netcalls/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/netcalls/server.lua",
        realm = "server"
    }
}

local ConditionalFiles = {
    {
        path = "lilia/gamemode/core/libraries/compatibility/vcmod.lua",
        global = "VCMod",
        name = "VCMod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/vjbase.lua",
        global = "VJ",
        name = "VJ",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe.lua",
        global = "AdvDupe",
        name = "AdvDupe",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe2.lua",
        global = "AdvDupe2",
        name = "AdvDupe2",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/pac.lua",
        global = "pac",
        name = "PAC3",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/prone.lua",
        global = "prone",
        name = "Prone",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/cami.lua",
        global = "CAMI",
        name = "CAMI",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/ulx.lua",
        global = "ulx",
        name = "ULX",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/serverguard.lua",
        global = "serverguard",
        name = "ServerGuard",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sam.lua",
        global = "sam",
        name = "SAM | Admin Mod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/simfphys.lua",
        global = "simfphys",
        name = "Simfphys Vehicles",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sitanywhere.lua",
        global = "SitAnywhere",
        name = "Sit Anywhere",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/permaprops.lua",
        global = "PermaProps",
        name = "PermaProps",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/lvs.lua",
        global = "LVS",
        name = "LVS",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/arccw.lua",
        global = "ArcCW",
        name = "ArcCW",
        realm = "server"
    }
}

function lia.loader.include(path, realm)
    if not path then lia.error(L("missingFilePath")) end
    local resolved = realm
    if not resolved then
        local filename = path:match("([^/\\]+)%.lua$")
        if filename then
            local prefix = filename:sub(1, 3)
            if prefix == "sv_" or filename == "server" then
                resolved = "server"
            elseif prefix == "cl_" or filename == "client" then
                resolved = "client"
            elseif prefix == "sh_" or filename == "shared" then
                resolved = "shared"
            end
        end

        resolved = resolved or "shared"
    end

    if resolved == "server" then
        if SERVER then include(path) end
    elseif resolved == "client" then
        if SERVER then
            AddCSLuaFile(path)
        else
            include(path)
        end
    else
        if SERVER then AddCSLuaFile(path) end
        include(path)
    end
end

function lia.loader.includeDir(dir, raw, deep, realm)
    local root = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local function loadDir(folder)
        for _, fileName in ipairs(file.Find(folder .. "/*.lua", "LUA")) do
            lia.loader.include(folder .. "/" .. fileName, realm)
        end

        if deep then
            for _, subFolder in ipairs(select(2, file.Find(folder .. "/*", "LUA"))) do
                loadDir(folder .. "/" .. subFolder)
            end
        end
    end

    loadDir(root)
end

function lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)
    local baseDir = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local stack = {baseDir}
    while #stack > 0 do
        local path = table.remove(stack)
        local files, folders = file.Find(path .. "/*.lua", "LUA")
        table.sort(files)
        for _, fileName in ipairs(files) do
            local realm = forceRealm
            if not realm then
                local prefix = fileName:sub(1, 3)
                realm = (prefix == "sh_" or fileName == "shared.lua") and "shared" or (prefix == "sv_" or fileName == "server.lua") and "server" or (prefix == "cl_" or fileName == "client.lua") and "client" or "shared"
            end

            local filePath = path .. "/" .. fileName
            if file.Exists(filePath, "LUA") then lia.loader.include(filePath, realm) end
        end

        if recursive then
            for _, subfolder in ipairs(folders) do
                table.insert(stack, path .. "/" .. subfolder)
            end
        end
    end
end

lia.loader.include("lilia/gamemode/core/libraries/languages.lua", "shared")
lia.loader.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.loader.include("lilia/gamemode/core/libraries/database.lua", "server")
lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/data.lua", "server")
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logError") .. "] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

function lia.warning(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logWarning") .. "] ")
    MsgC(Color(255, 255, 0), tostring(msg), "\n")
end

function lia.deprecated(methodName, callback)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logDeprecated") .. "] ")
    MsgC(Color(255, 255, 0), L("deprecatedMessage", methodName), "\n")
    if callback and isfunction(callback) then callback() end
end

function lia.updater(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
    MsgC(Color(0, 255, 255), tostring(msg), "\n")
end

function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logInformation") .. "] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

function lia.admin(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
    MsgC(Color(255, 153, 0), tostring(msg), "\n")
end

function lia.bootstrap(section, msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logBootstrap") .. "] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), tostring(msg), "\n")
end

function lia.printLog(category, logString)
    MsgC(Color(83, 143, 239), "[LOG] ")
    MsgC(Color(0, 255, 0), "[" .. L("logCategory") .. ": " .. tostring(category) .. "] ")
    MsgC(Color(255, 255, 255), tostring(logString) .. "\n")
end

for _, files in ipairs(FilesToLoad) do
    lia.loader.include(files.path, files.realm)
end

function lia.loader.includeEntities(path)
    local function IncludeFiles(path2)
        if file.Exists(path2 .. "init.lua", "LUA") then lia.loader.include(path2 .. "init.lua", "server") end
        if file.Exists(path2 .. "shared.lua", "LUA") then lia.loader.include(path2 .. "shared.lua", "shared") end
        if file.Exists(path2 .. "cl_init.lua", "LUA") then lia.loader.include(path2 .. "cl_init.lua", "client") end
    end

    local function stripRealmPrefix(name)
        local prefix = name:sub(1, 3)
        return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly, create, complete)
        local files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
        default = default or {}
        for _, v in ipairs(folders) do
            local path2 = path .. "/" .. folder .. "/" .. v .. "/"
            v = stripRealmPrefix(v)
            _G[variable] = table.Copy(default)
            if not isfunction(create) then
                _G[variable].ClassName = v
            else
                create(v)
            end

            IncludeFiles(path2)
            if clientOnly then
                if CLIENT then register(_G[variable], v) end
            else
                register(_G[variable], v)
            end

            if isfunction(complete) then complete(_G[variable]) end
            _G[variable] = nil
        end

        for _, v in ipairs(files) do
            local niceName = stripRealmPrefix(string.StripExtension(v))
            _G[variable] = table.Copy(default)
            if not isfunction(create) then
                _G[variable].ClassName = niceName
            else
                create(niceName)
            end

            lia.loader.include(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")
            if clientOnly then
                if CLIENT then register(_G[variable], niceName) end
            else
                register(_G[variable], niceName)
            end

            if isfunction(complete) then complete(_G[variable]) end
            _G[variable] = nil
        end
    end

    local function RegisterTool(tool, className)
        local gmodTool = weapons.GetStored("gmod_tool")
        if gmodTool then gmodTool.Tool[className] = tool end
    end

    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    }, false)

    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    HandleEntityInclusion("tools", "TOOL", RegisterTool, {}, false, function(className)
        TOOL = lia.meta.tool:Create()
        TOOL.Mode = className
        TOOL:CreateConVars()
    end)

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

lia.loader.includeEntities("lilia/gamemode/entities")
lia.loader.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")
if SERVER then
    local function SetupDatabase()
        hook.Run("SetupDatabase")
        lia.db.connect(function()
            lia.db.loadTables()
            hook.Run("DatabaseConnected")
        end)
    end

    local function SetupPersistence()
        cvars.AddChangeCallback("sbox_persist", function(_, old, new)
            timer.Create("sbox_persist_change_timer", 1, 1, function()
                hook.Run("PersistenceSave", old)
                game.CleanUpMap(false, nil, function() end)
                if new ~= "" then hook.Run("PersistenceLoad", new) end
            end)
        end, "sbox_persist_load")
    end

    local function BootstrapLilia()
        timer.Simple(0, SetupDatabase)
        SetupPersistence()
    end

    BootstrapLilia()
else
    local oldLocalPlayer = LocalPlayer
    function LocalPlayer()
        lia.localClient = IsValid(lia.localClient) and lia.localClient or oldLocalPlayer()
        return lia.localClient
    end

    timer.Remove("HintSystem_OpeningMenu")
    timer.Remove("HintSystem_Annoy1")
    timer.Remove("HintSystem_Annoy2")
end

local hasInitializedModules = false
function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then lia.error(L("noSchemaLoaded")) end
    if not hasInitializedModules then
        lia.module.initialize()
        hasInitializedModules = true
    end
end

function GM:OnReloaded()
    lia.module.initialize()
    lia.config.load()
    lia.faction.formatModelData()
    if SERVER then
        timer.Simple(0.1, function() lia.config.send() end)
        timer.Simple(0.2, function() lia.administrator.sync() end)
        timer.Simple(0.3, function() lia.playerinteract.syncToClients() end)
        timer.Simple(0.5, function() lia.bootstrap("HotReload", "Gamemode hotreloaded successfully!") end)
    else
        chat.AddText(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Gamemode hotreloaded successfully!")
    end
end

local loadedCompatibility = {}
for _, compatFile in ipairs(ConditionalFiles) do
    local shouldLoad = false
    if isfunction(compatFile.condition) then
        local ok, result = pcall(compatFile.condition)
        if ok then
            shouldLoad = result
        else
            lia.error(L("compatibilityConditionError", tostring(result)))
        end
    elseif compatFile.global then
        shouldLoad = _G[compatFile.global] ~= nil
    end

    if shouldLoad then
        lia.loader.include(compatFile.path, compatFile.realm or "shared")
        loadedCompatibility[#loadedCompatibility + 1] = compatFile.name
    end
end

if #loadedCompatibility > 0 then lia.bootstrap(L("compatibility"), #loadedCompatibility == 1 and L("compatibilityLoadedSingle", loadedCompatibility[1]) or L("compatibilityLoadedMultiple", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end
