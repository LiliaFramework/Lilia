--------------------------------------------------------------------------------------------------------
lia.config.DevPrinting = lia.config.DevPrinting or false

--------------------------------------------------------------------------------------------------------
function lia.util.include(fileName, state)
    if not fileName then
        error("[Lilia] No file name specified for including.")
    end

    if (state == "server" or fileName:find("sv_")) and SERVER then
        return include(fileName)
    elseif state == "shared" or fileName:find("sh_") then
        if SERVER then
            AddCSLuaFile(fileName)
        end

        return include(fileName)
    elseif state == "client" or fileName:find("cl_") then
        if SERVER then
            AddCSLuaFile(fileName)
        else
            return include(fileName)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function lia.util.includeDir(directory, fromLua, recursive)
    local baseDir = "lilia"

    if SCHEMA and SCHEMA.folder and SCHEMA.loading then
        baseDir = SCHEMA.folder .. "/schema/"
    else
        baseDir = baseDir .. "/gamemode/"
    end

    local function printIncludeInfo(filePath)
        if lia.config.DevPrinting then
            print("Included file:", filePath)
        end
    end

    if recursive then
        local function AddRecursive(folder, baseFolder)
            local files, folders = file.Find(folder .. "/*", "LUA")

            if not files then
                MsgN("Warning! This folder is empty!")

                return
            end

            for k, v in pairs(files) do
                local fullPath = folder .. "/" .. v
                lia.util.include(fullPath)
                printIncludeInfo(fullPath)
            end

            for k, v in pairs(folders) do
                local subFolder = baseFolder .. "/" .. v
                AddRecursive(folder .. "/" .. v, subFolder)
            end
        end

        local initialFolder = (fromLua and "" or baseDir) .. directory
        AddRecursive(initialFolder, initialFolder)
    else
        for k, v in ipairs(file.Find((fromLua and "" or baseDir) .. directory .. "/*.lua", "LUA")) do
            local fullPath = directory .. "/" .. v
            lia.util.include(fullPath)
            printIncludeInfo(fullPath)
        end
    end
end

--=== Frontend Files ===\\
lia.util.include("frontend/cl_hooks.lua", "client")
lia.util.include("frontend/chatbox/cl_chatbox.lua", "client")
lia.util.include("frontend/chatbox/cl_markup.lua", "client")
lia.util.include("frontend/f1menu/cl_classes.lua", "client")
lia.util.include("frontend/f1menu/cl_helps.lua", "client")
lia.util.include("frontend/f1menu/cl_hooks.lua", "client")
lia.util.include("frontend/f1menu/cl_information.lua", "client")
lia.util.include("frontend/f1menu/cl_menu.lua", "client")
lia.util.include("frontend/f1menu/cl_menubutton.lua", "client")
lia.util.include("frontend/f1menu/cl_menuoptions.lua", "client")
lia.util.include("frontend/hud/cl_bars.lua", "client")
lia.util.include("frontend/hud/cl_hooks.lua", "client")
lia.util.include("frontend/hud/cl_vignette.lua", "client")
lia.util.include("frontend/inventory/cl_grid_inventory.lua", "client")
lia.util.include("frontend/inventory/cl_grid_inventory_item.lua", "client")
lia.util.include("frontend/inventory/cl_grid_inventory_panel.lua", "client")
lia.util.include("frontend/inventory/cl_hooks.lua", "client")
lia.util.include("frontend/inventory/cl_inventory.lua", "client")
lia.util.include("frontend/inventory/cl_invpanel_extensions.lua", "client")
lia.util.include("frontend/inventory/sh_grid_inv.lua", "shared")
lia.util.include("frontend/inventory/sv_hooks.lua", "server")
lia.util.include("frontend/misc/cl_horizontal_scroll.lua", "client")
lia.util.include("frontend/misc/cl_horizontal_scroll_bar.lua", "client")
lia.util.include("frontend/misc/cl_modelpanel.lua", "client")
lia.util.include("frontend/misc/cl_notice.lua", "client")
lia.util.include("frontend/misc/cl_quick.lua", "client")
lia.util.include("frontend/misc/cl_spawnicon.lua", "client")
lia.util.include("frontend/misc/cl_tooltip.lua", "client")
lia.util.include("frontend/multichar/cl_bg_music.lua", "client")
lia.util.include("frontend/multichar/cl_biography.lua", "client")
lia.util.include("frontend/multichar/cl_button.lua", "client")
lia.util.include("frontend/multichar/cl_character.lua", "client")
lia.util.include("frontend/multichar/cl_character_slot.lua", "client")
lia.util.include("frontend/multichar/cl_confirmation.lua", "client")
lia.util.include("frontend/multichar/cl_creation.lua", "client")
lia.util.include("frontend/multichar/cl_faction.lua", "client")
lia.util.include("frontend/multichar/cl_hooks.lua", "client")
lia.util.include("frontend/multichar/cl_model.lua", "client")
lia.util.include("frontend/multichar/cl_selection.lua", "client")
lia.util.include("frontend/multichar/cl_step.lua", "client")
lia.util.include("frontend/multichar/cl_tab_button.lua", "client")
lia.util.include("frontend/multichar/sv_hooks.lua", "server")
lia.util.include("frontend/theme/cl_skin.lua", "client")
lia.util.include("frontend/theme/cl_skindark.lua", "client")
lia.util.include("frontend/theme/cl_theme.lua", "client")
lia.util.include("frontend/thirdperson/cl_conconsole.lua", "client")
lia.util.include("frontend/thirdperson/cl_hooks.lua", "client")
lia.util.include("frontend/thirdperson/cl_panel.lua", "client")
lia.util.include("frontend/voicepanel/cl_hooks.lua", "client")
lia.util.include("frontend/voicepanel/cl_panel.lua", "client")
lia.util.include("frontend/voicepanel/cl_voiceclean.lua", "client")
lia.util.include("frontend/weaponselector/cl_enable.lua", "client")
lia.util.include("frontend/weaponselector/cl_hooks.lua", "client")
--=== Backend Files ===\\
lia.util.include("backend/core/cl_contextmenu.lua", "client")
lia.util.include("backend/core/cl_hooks.lua", "client")
lia.util.include("backend/core/cl_loadingscreen.lua", "client")
lia.util.include("backend/core/sh_hooks.lua", "shared")
lia.util.include("backend/core/sv_hooks.lua", "server")
lia.util.include("backend/external/thirdparty/cl_ikon.lua", "client")
lia.util.include("backend/external/thirdparty/cl_markup.lua", "client")
lia.util.include("backend/external/thirdparty/cl_surfaceGetURL.lua", "client")
lia.util.include("backend/external/thirdparty/sh_deferred.lua", "shared")
lia.util.include("backend/external/thirdparty/sh_ease.lua", "shared")
lia.util.include("backend/external/thirdparty/sh_netstream2.lua", "shared")
lia.util.include("backend/external/thirdparty/sh_pon.lua", "shared")
lia.util.include("backend/external/thirdparty/sh_utf8.lua", "shared")
lia.util.include("backend/libs/cl_bar.lua", "client")
lia.util.include("backend/libs/cl_fonts.lua", "client")
lia.util.include("backend/libs/cl_menu.lua", "client")
lia.util.include("backend/libs/cl_notice.lua", "client")
lia.util.include("backend/libs/cl_playerinteract.lua", "client")
lia.util.include("backend/libs/sh_anims.lua", "shared")
lia.util.include("backend/libs/sh_class.lua", "shared")
lia.util.include("backend/libs/sh_currency.lua", "shared")
lia.util.include("backend/libs/sh_date.lua", "shared")
lia.util.include("backend/libs/sh_module.lua", "shared")
lia.util.include("backend/libs/sv_salary.lua", "server")
lia.util.include("backend/libs/character/sh_character.lua", "shared")
lia.util.include("backend/libs/character/sv_character.lua", "server")
lia.util.include("backend/libs/chatbox/sh_chatbox.lua", "shared")
lia.util.include("backend/libs/chatbox/sv_chatbox.lua", "server")
lia.util.include("backend/libs/commands/sh_commands.lua", "shared")
lia.util.include("backend/libs/commands/sv_commands.lua", "server")
lia.util.include("backend/libs/faction/cl_faction.lua", "client")
lia.util.include("backend/libs/faction/sh_faction.lua", "shared")
lia.util.include("backend/libs/flag/sh_flag.lua", "shared")
lia.util.include("backend/libs/flag/sv_flag.lua", "server")
lia.util.include("backend/libs/inventory/cl_inventory.lua", "client")
lia.util.include("backend/libs/inventory/sh_inventory.lua", "shared")
lia.util.include("backend/libs/inventory/sv_inventory.lua", "server")
lia.util.include("backend/libs/item/sh_item.lua", "shared")
lia.util.include("backend/libs/item/sv_item.lua", "server")
lia.util.include("backend/libs/language/cl_language.lua", "client")
lia.util.include("backend/libs/language/sh_language.lua", "shared")
lia.util.include("backend/libs/language/sv_language.lua", "server")
lia.util.include("backend/libs/networking/cl_networking.lua", "client")
lia.util.include("backend/libs/networking/sh_networking.lua", "shared")
lia.util.include("backend/libs/networking/sv_networking.lua", "server")
lia.util.include("backend/libs/util/cl_util.lua", "client")
lia.util.include("backend/libs/util/sh_util.lua", "shared")
lia.util.include("backend/libs/util/sv_util.lua", "server")
lia.util.include("backend/meta/character/sh_charactermeta.lua", "shared")
lia.util.include("backend/meta/character/sv_charactermeta.lua", "server")
lia.util.include("backend/meta/entity/cl_entitymeta.lua", "client")
lia.util.include("backend/meta/entity/sh_entitymeta.lua", "shared")
lia.util.include("backend/meta/entity/sv_entitymeta.lua", "server")
lia.util.include("backend/meta/inventory/cl_inventory.lua", "client")
lia.util.include("backend/meta/inventory/sh_inventory.lua", "shared")
lia.util.include("backend/meta/inventory/sv_inventory.lua", "server")
lia.util.include("backend/meta/item/cl_itemmeta.lua", "client")
lia.util.include("backend/meta/item/sh_itemmeta.lua", "shared")
lia.util.include("backend/meta/item/sv_itemmeta.lua", "server")
lia.util.include("backend/meta/player/cl_playermeta.lua", "client")
lia.util.include("backend/meta/player/sh_playermeta.lua", "shared")
lia.util.include("backend/meta/player/sv_playermeta.lua", "server")
lia.util.include("backend/netcalls/cl_netcalls.lua", "client")
lia.util.include("backend/netcalls/sv_netcalls.lua", "server")