--------------------------------------------------------------------------------------------------------
lia.util.includeDir("core/libs/thirdparty", false, true)
lia.util.include("core/libs/primary/cl_fonts.lua")
lia.util.include("core/libs/primary/cl_menu.lua")
lia.util.include("core/libs/primary/cl_playerinteract.lua")
lia.util.include("core/libs/primary/sh_anims.lua")
lia.util.include("core/libs/primary/sh_class.lua")
lia.util.include("core/libs/primary/sh_currency.lua")
lia.util.include("core/libs/primary/sh_date.lua")
lia.util.include("core/libs/primary/sv_database.lua")
lia.util.include("core/libs/primary/sh_module.lua")
lia.util.include("core/libs/primary/character/sh_character.lua")
lia.util.include("core/libs/primary/chatbox/sh_chatbox.lua")
lia.util.include("core/libs/primary/commands/sh_commands.lua")
lia.util.include("core/libs/primary/faction/sh_faction.lua")
lia.util.include("core/libs/primary/flag/sh_flag.lua")
lia.util.include("core/libs/primary/inventory/sh_inventory.lua")
lia.util.include("core/libs/primary/item/sh_item.lua")
lia.util.include("core/libs/primary/language/sh_language.lua")
lia.util.include("core/libs/primary/networking/sh_charactermeta.lua")

--------------------------------------------------------------------------------------------------------
lia.util.include("core/libs/meta/character/sh_charactermeta.lua")
lia.util.include("core/libs/meta/entity/sh_entity.lua")
lia.util.include("core/libs/meta/inventory/sh_inventory.lua")
lia.util.include("core/libs/meta/item/sh_itemmeta.lua")
lia.util.include("core/libs/meta/player/sh_playermeta.lua")
--------------------------------------------------------------------------------------------------------

lia.util.includeDir("core/libs/secondary/util", false, true)
lia.util.includeDir("core/libs/secondary/netcalls", false, true)
lia.util.includeDir("core/libs/hooks")
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
--------------------------------------------------------------------------------------------------------