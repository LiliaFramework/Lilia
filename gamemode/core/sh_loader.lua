--------------------------------------------------------------------------------------------------------
lia.util.includeDir("libs/thirdparty")
lia.util.include("libs/core/cl_fonts.lua")
lia.util.include("libs/core/cl_menu.lua")
lia.util.include("libs/core/cl_playerinteract.lua")
lia.util.include("libs/core/sh_anims.lua")
lia.util.include("libs/core/sh_class.lua")
lia.util.include("libs/core/sh_currency.lua")
lia.util.include("libs/core/sh_date.lua")
lia.util.include("libs/core/sv_database.lua")
lia.util.include("libs/core/sh_module.lua")
lia.util.include("libs/core/character/sh_character.lua")
lia.util.include("libs/core/chatbox/sh_chatbox.lua")
lia.util.include("libs/core/commands/sh_commands.lua")
lia.util.include("libs/core/faction/sh_faction.lua")
lia.util.include("libs/core/flag/sh_flag.lua")
lia.util.include("libs/core/inventory/sh_inventory.lua")
lia.util.include("libs/core/item/sh_item.lua")
lia.util.include("libs/core/language/sh_language.lua")
lia.util.include("libs/core/networking/sh_charactermeta.lua")


lia.util.include("libs/meta/inventory/sh_inventory.lua")
lia.util.include("libs/meta/item/sh_itemmeta.lua")
lia.util.include("libs/meta/entity/sh_entitymeta.lua")
lia.util.include("libs/meta/item/sh_itemmeta.lua")
lia.util.include("libs/meta/character/sh_charactermeta.lua")


lia.util.includeDir("libs/secondary/util", false, true)
lia.util.includeDir("libs/secondary/netcalls", false, true)
lia.util.includeDir("libs/hooks")
--------------------------------------------------------------------------------------------------------
lia.module.loaded = false

function GM:OnReloaded()
    if SERVER then
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end

        if not lia.module.loaded then
            lia.module.initialize()
            lia.module.loaded = true
        end

        lia.faction.formatModelData()
    else
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)

        if not lia.module.loaded then
            lia.module.initialize()
            lia.module.loaded = true
        end

        lia.faction.formatModelData()
    end
end

--------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
    lia.module.load()
end

--------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end