DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    gui = {},
    meta = {},
    notices = {}
}

local function IncludeLiliaFiles()
    local files = {"lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/shared.lua", "lilia/gamemode/core/libraries/includer.lua", "lilia/gamemode/core/libraries/data.lua"}
    for _, file in ipairs(files) do
        if file then include(file) end
    end
end

IncludeLiliaFiles()