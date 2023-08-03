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

    if recursive then
        local function AddRecursive(folder)
            local files, folders = file.Find(folder .. "/*", "LUA")

            if not files then
                MsgN("Warning! This folder is empty!")

                return
            end

            for k, v in pairs(files) do
                lia.util.include(folder .. "/" .. v)
            end

            for k, v in pairs(folders) do
                AddRecursive(folder .. "/" .. v)
            end
        end

        AddRecursive((fromLua and "" or baseDir) .. directory)
    else
        for k, v in ipairs(file.Find((fromLua and "" or baseDir) .. directory .. "/*.lua", "LUA")) do
            lia.util.include(directory .. "/" .. v)
        end
    end
end
--------------------------------------------------------------------------------------------------------
lia.util.includeDir("lilia/gamemode/core/util", true, true)
--------------------------------------------------------------------------------------------------------