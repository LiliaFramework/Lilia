BootingTime = SysTime()
DeriveGamemode("sandbox")
resource.AddWorkshop("2959728255")
resource.AddFile("lilia/gui/vignette.png")
lia = lia or {
    util = {},
    meta = {},
    notices = {}
}

local filesAdd = {"lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/core/libraries/includer.lua", "lilia/gamemode/core/libraries/data.lua", "lilia/gamemode/shared.lua"}
local function AddLiliaFiles()
    for _, fileName in ipairs(filesAdd) do
        AddCSLuaFile(fileName)
    end
end

local filesInclude = {"lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/shared.lua", "lilia/gamemode/core/libraries/database.lua", "lilia/gamemode/core/libraries/includer.lua", "lilia/gamemode/core/libraries/data.lua"}
local function IncludeLiliaFiles()
    for _, fileName in ipairs(filesInclude) do
        include(fileName)
    end
end

local function SetupDatabase()
    hook.Run("SetupDatabase")
    lia.db.connect(function()
        lia.db.loadTables()
        lia.log.loadTables()
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
    IncludeLiliaFiles()
    AddLiliaFiles()
    timer.Simple(0, SetupDatabase)
    SetupPersistence()
end

BootstrapLilia()