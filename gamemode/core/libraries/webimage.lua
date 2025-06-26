lia.webimage = lia.webimage or {}
local ip = string.Replace(string.Replace(game.GetIPAddress() or "unknown", ":", "_"), "%.", "_")
local gamemode = engine.ActiveGamemode() or "unknown"
local baseDir = "lilia/" .. ip .. "/" .. gamemode .. "/"
local cache = {}
local function ensureDir(path)
    local parts = string.Explode("/", path)
    local cur = ""
    for _, part in ipairs(parts) do
        cur = cur == "" and part or cur .. "/" .. part
        if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
    end
end

function lia.webimage.register(name, url, callback)
    if cache[name] then
        if callback then callback(cache[name], true) end
        return
    end

    local savePath = baseDir .. name
    if file.Exists(savePath, "DATA") then
        cache[name] = savePath
        if callback then callback(savePath, true) end
        return
    end

    http.Fetch(url, function(body)
        ensureDir(baseDir)
        file.Write(savePath, body)
        cache[name] = savePath
        if callback then callback(savePath, false) end
    end, function(err) if callback then callback(nil, false, err) end end)
end

function lia.webimage.get(name)
    local savePath = cache[name] or baseDir .. name
    if file.Exists(savePath, "DATA") then
        cache[name] = savePath
        return savePath
    end
    return nil
end

ensureDir(baseDir)