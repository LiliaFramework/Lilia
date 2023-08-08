--------------------------------------------------------------------------------------------------------
lia.config.DevPrinting = lia.config.DevPrinting or true
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
--------------------------------------------------------------------------------------------------------
lia.util.include("external/thirdparty/cl_ikon.lua", "client")
lia.util.include("external/thirdparty/cl_markup.lua", "client")
lia.util.include("external/thirdparty/cl_surfaceGetURL.lua", "client")
lia.util.include("external/thirdparty/sh_deferred.lua", "shared")
lia.util.include("external/thirdparty/sh_ease.lua", "shared")
lia.util.include("external/thirdparty/sh_netstream2.lua", "shared")
lia.util.include("external/thirdparty/sh_pon.lua", "shared")
lia.util.include("external/thirdparty/sh_utf8.lua", "shared")
--------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------------------------
lia.util.include("hud/cl_vignette.lua", "client")
lia.util.include("inventory/cl_inventory.lua", "client")
lia.util.include("inventory/cl_invpanel_extensions.lua", "client")
lia.util.include("panels/cl_horizontal_scroll_bar.lua", "client")
lia.util.include("panels/cl_modelpanel.lua", "client")
lia.util.include("panels/cl_horizontal_scroll.lua", "client")
lia.util.include("panels/cl_quick.lua", "client")
lia.util.include("panels/cl_spawnicon.lua", "client")
lia.util.include("panels/cl_tooltip.lua", "client")
lia.util.include("cl_bars.lua", "client")
lia.util.include("cl_hooks.lua", "client")
--------------------------------------------------------------------------------------------------------