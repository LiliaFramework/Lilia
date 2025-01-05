BootingTime = SysTime()
DeriveGamemode("sandbox")
resource.AddWorkshop("2959728255")
resource.AddFile("lilia/gui/vignette.png")
lia = lia or {
    util = {},
    meta = {},
    notices = {}
}

local function AddLiliaFiles()
    local files = {"lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/core/libraries/includer.lua", "lilia/gamemode/core/libraries/data.lua", "lilia/gamemode/shared.lua"}
    for _, file in ipairs(files) do
        AddCSLuaFile(file)
    end
end

local function IncludeLiliaFiles()
    local files = {"lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/shared.lua", "lilia/gamemode/core/libraries/database.lua", "lilia/gamemode/core/libraries/includer.lua", "lilia/gamemode/core/libraries/data.lua",}
    for _, file in ipairs(files) do
        include(file)
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
