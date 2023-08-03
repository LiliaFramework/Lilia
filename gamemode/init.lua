DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("core/sh_include.lua")
AddCSLuaFile("shared.lua")
include("core/sh_include.lua")
include("core/sv_data.lua")
include("shared.lua")

--------------------------------------------------------------------------------------------------------
hook.Add("OnReloaded", "OnReloadedServer", function()
    for _, client in ipairs(player.GetAll()) do
        hook.Run("CreateSalaryTimer", client)
    end

    if not lia.module.loaded then
        lia.module.initialize()
        lia.module.loaded = true
    end

    lia.faction.formatModelData()
end)

--------------------------------------------------------------------------------------------------------
resource.AddWorkshop("2959728255")
--------------------------------------------------------------------------------------------------------