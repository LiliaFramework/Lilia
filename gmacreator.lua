local OUTPUT_FILE = assert(arg[1], "Missing argument #1 (output file)")
local ADDON_JSON = assert(arg[2], "Missing argument #2 (path to addon.json)")
local PATH_SEP = package.config:sub(1, 1)
local function read(path)
    local handle = assert(io.open(path, "rb"))
    local content = handle:read("*a")
    handle:close()
    return content
end

local function map(t, f)
    local out = {}
    for k, v in ipairs(t) do
        out[k] = f(v, k)
    end
    return out
end

local function pack(name, desc, author, files, steamid, timestamp)
    return "GMAD" .. ("< I1 I8 I8 x z z z I4"):pack(3, steamid or 0, timestamp or os.time(), name, desc, author, 1) .. table.concat(map(files, function(v, k) return ("< I4 z I8 I4"):pack(k, v.path, #v.content, 0) end)) .. "\0\0\0\0" .. table.concat(map(files, function(v) return v.content end)) .. "\0\0\0\0"
end

local function decode(json)
    local ptr = 0
    local function consume(pattern)
        ptr = json:find("%S", ptr) or ptr
        local start, finish, match = json:find(pattern, ptr)
        if start then
            ptr = finish + 1
            return match or true
        end
    end

    local object, array
    local function number()
        return tonumber(consume("^(%-?%d+%.%d+)") or consume("^(%-?%d+)"))
    end

    local function bool()
        return consume("^(true)") or consume("^(false)")
    end

    local function string()
        return consume("^\"([^\"]*)\"")
    end

    local function value()
        return object() or string() or number() or bool() or array()
    end

    function object()
        if consume("^{") then
            local fields = {}
            while true do
                if consume("^}") then return fields end
                local key = assert(string(), "Expected field for table")
                assert(consume("^:"))
                fields[key] = assert(value(), "Expected value for field " .. key)
                consume("^,")
            end
        end
    end

    function array()
        if consume("^%[") then
            local values = {}
            while true do
                if consume("^%]") then return values end
                values[#values + 1] = assert(value(), "Expected value for field #" .. #values + 1)
                consume("^,")
            end
        end
    end
    return object() or array()
end

local function wildcard2pattern(s)
    return "^%./" .. s:gsub("%.", "%%."):gsub("%*", ".*") .. "$"
end

do
    local addon = assert(decode(read(ADDON_JSON)), "Failed to parse addon.json file")
    local files = {}
    local blocklist = {}
    local allowlist = map({"lua/*.lua", "scenes/*.vcd", "particles/*.pcf", "resource/fonts/*.ttf", "scripts/vehicles/*.txt", "resource/localization/*/*.properties", "maps/*.bsp", "maps/*.lmp", "maps/*.nav", "maps/*.ain", "maps/thumb/*.png", "sound/*.wav", "sound/*.mp3", "sound/*.ogg", "materials/*.vmt", "materials/*.vtf", "materials/*.png", "materials/*.jpg", "materials/*.jpeg", "materials/colorcorrection/*.raw", "models/*.mdl", "models/*.vtx", "models/*.phy", "models/*.ani", "models/*.vvd", "gamemodes/*/*.txt", "gamemodes/*/*.fgd", "gamemodes/*/logo.png", "gamemodes/*/icon24.png", "gamemodes/*/gamemode/*.lua", "gamemodes/*/entities/effects/*.lua", "gamemodes/*/entities/weapons/*.lua", "gamemodes/*/entities/entities/*.lua", "gamemodes/*/backgrounds/*.png", "gamemodes/*/backgrounds/*.jpg", "gamemodes/*/backgrounds/*.jpeg", "gamemodes/*/content/models/*.mdl", "gamemodes/*/content/models/*.vtx", "gamemodes/*/content/models/*.phy", "gamemodes/*/content/models/*.ani", "gamemodes/*/content/models/*.vvd", "gamemodes/*/content/materials/*.vmt", "gamemodes/*/content/materials/*.vtf", "gamemodes/*/content/materials/*.png", "gamemodes/*/content/materials/*.jpg", "gamemodes/*/content/materials/*.jpeg", "gamemodes/*/content/materials/colorcorrection/*.raw", "gamemodes/*/content/scenes/*.vcd", "gamemodes/*/content/particles/*.pcf", "gamemodes/*/content/resource/fonts/*.ttf", "gamemodes/*/content/scripts/vehicles/*.txt", "gamemodes/*/content/resource/localization/*/*.properties", "gamemodes/*/content/maps/*.bsp", "gamemodes/*/content/maps/*.nav", "gamemodes/*/content/maps/*.ain", "gamemodes/*/content/maps/thumb/*.png", "gamemodes/*/content/sound/*.wav", "gamemodes/*/content/sound/*.mp3", "gamemodes/*/content/sound/*.ogg", "data_static/*.txt", "data_static/*.dat", "data_static/*.json", "data_static/*.xml", "data_static/*.csv", "data_static/*.dem", "data_static/*.vcd", "data_static/*.vtf", "data_static/*.vmt", "data_static/*.png", "data_static/*.jpg", "data_static/*.jpeg", "data_static/*.mp3", "data_static/*.wav", "data_static/*.ogg"}, wildcard2pattern)
    if addon.ignore then blocklist = map(addon.ignore, wildcard2pattern) end
    local dir = assert(io.popen(PATH_SEP == "\\" and "dir /s /b ." or "find . -type f"))
    for path in dir:lines() do
        local normalized = path:gsub(PATH_SEP, "/")
        for _, allow_pattern in ipairs(allowlist) do
            if normalized:match(allow_pattern) then
                for _, block_pattern in ipairs(blocklist) do
                    if normalized:match(block_pattern) then
                        print("Blocked ", normalized)
                        goto cont
                    end
                end

                files[#files + 1] = {
                    path = normalized:sub(3),
                    content = read(path)
                }

                goto cont
            end
        end

        print("Warning: File " .. normalized .. " not whitelisted. Skipping..")
        ::cont::
    end

    dir:close()
    local handle = assert(io.open(OUTPUT_FILE, "wb"), "Failed to create/overwrite output file")
    handle:write(pack(addon.title or "No title provided", addon.description or "No description provided", addon.author or addon.authors and table.concat(addon.authors, ", ") or "No author provided", files))
    handle:close()
end