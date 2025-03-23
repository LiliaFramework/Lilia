DeriveGamemode( "sandbox" )
lia = lia or {
	util = {},
	gui = {},
	meta = {},
	notices = {}
}

local files = { "lilia/gamemode/core/libraries/config.lua", "lilia/gamemode/shared.lua", "lilia/gamemode/core/libraries/includer.lua" }
local function BootstrapLilia()
    for _, filePath in ipairs( files ) do
        if file.Exists( filePath, "LUA" ) then
            include( filePath )
        end
    end
end

function is64Bits()
	return BRANCH == "x86-64"
end

BootstrapLilia()
