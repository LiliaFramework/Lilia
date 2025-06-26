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

local function buildMaterial(path, flags)
    return Material("data/" .. path, flags or "noclamp smooth")
end

function lia.webimage.register(name, url, callback, flags)
    if cache[name] then
        if callback then callback(cache[name], true) end
        return
    end

    local savePath = baseDir .. name
    local function finalize(fromCache)
        local mat = buildMaterial(savePath, flags)
        cache[name] = mat
        if callback then callback(mat, fromCache) end
    end

    if file.Exists(savePath, "DATA") then
        finalize(true)
        return
    end

    http.Fetch(url, function(body)
        ensureDir(baseDir)
        file.Write(savePath, body)
        finalize(false)
    end, function(err) if callback then callback(nil, false, err) end end)
end

function lia.webimage.get(name, flags)
    if cache[name] then return cache[name] end
    local savePath = baseDir .. name
    if file.Exists(savePath, "DATA") then
        local mat = buildMaterial(savePath, flags)
        cache[name] = mat
        return mat
    end
    return nil
end

local origMaterial = Material
function Material(path, ...)
    if type(path) == "string" and path:find("^https?://") then
        local ext = path:match("%.([%w]+)$") or "png"
        local name = util.CRC(path) .. "." .. ext
        lia.webimage.register(name, path)
        return origMaterial("data/" .. baseDir .. name, ...)
    end
    return origMaterial(path, ...)
end

local dimage = vgui.GetControlTable("DImage")
if dimage and dimage.SetImage then
    local origSetImage = dimage.SetImage
    function dimage:SetImage(src, backup)
        if type(src) == "string" and src:find("^https?://") then
            local ext = src:match("%.([%w]+)$") or "png"
            local name = util.CRC(src) .. "." .. ext
            local savePath = baseDir .. name
            lia.webimage.register(name, src, function(mat)
                if mat and not mat:IsError() then
                    origSetImage(self, "data/" .. savePath, backup)
                elseif backup then
                    origSetImage(self, backup)
                end
            end)
            return
        end

        origSetImage(self, src, backup)
    end
end

ensureDir(baseDir)