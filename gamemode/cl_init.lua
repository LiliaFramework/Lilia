DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    gui = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
include("core/sh_include.lua")
include("shared.lua")

--------------------------------------------------------------------------------------------------------
hook.Add("OnReloaded", "OnReloadedClient", function()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)

    if not lia.module.loaded then
        lia.module.initialize()
        lia.module.loaded = true
    end

    lia.faction.formatModelData()
end)