lia.webcontent = lia.webcontent or {}
lia.webcontent.stored = lia.webcontent.stored or {}
local baseDir = "lilia/webcontent/"
local cache = {}
local urlMap = {}
local stats = {
    downloaded = 0,
    lastReset = os.time(),
    downloadedContent = {}
}

local imageExtensions = {
    png = true,
    jpg = true,
    jpeg = true
}

local soundExtensions = {
    wav = true,
    mp3 = true,
    ogg = true
}

local function ensureDir(path)
    local current = ""
    for _, part in ipairs(string.Explode("/", path)) do
        if part ~= "" then
            current = current == "" and part or current .. "/" .. part
            if not file.Exists(current, "DATA") then file.CreateDir(current) end
        end
    end
end

local function normalizeName(name)
    if not isstring(name) then return nil end
    name = name:gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("^/", ""):gsub("^sound/", "")
    name = name:gsub("^lilia/webcontent/[a-z]+/", ""):gsub("^webcontent/[a-z]+/", "")
    name = name:gsub("^lilia/webcontent/image/", ""):gsub("^webcontent/image/", "")
    name = name:gsub("^lilia/webcontent/sound/", ""):gsub("^webcontent/sound/", "")
    if name == "" or name:find("%.%.", 1, true) or name:find("[^%w%._%-%/]") then return nil end
    return name
end

local function getExtension(name)
    if not isstring(name) then return end
    local extension = name:match("%.([%w]+)$")
    return extension and extension:lower()
end

local function getType(name)
    local extension = getExtension(name)
    if not extension then return end
    if imageExtensions[extension] then return "image" end
    if soundExtensions[extension] then return "sound" end
end

local function getKey(name, contentType)
    return contentType .. ":" .. name
end

local function getPath(name, contentType)
    return baseDir .. contentType .. "/" .. name
end

local function buildMaterial(path, flags)
    return Material("data/" .. path, flags or "noclamp smooth")
end

local function validateURL(url)
    if not isstring(url) or url == "" then return false, "URL is not a valid string" end
    if #url > 2048 or url:find("[<>\"\\|]") then return false, "URL contains invalid characters" end
    local host = url:match("^https?://([^/%?#]+)")
    if not host then return false, "URL must use HTTP or HTTPS" end
    host = host:match("^([^:]+)") or host
    local lowerHost = host:lower()
    if lowerHost == "localhost" or lowerHost:find("%.localhost$") or lowerHost == "::1" then return false, "Localhost URLs are not allowed" end
    local a, b, c, d = host:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    if a then
        a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
        if not a or not b or not c or not d or a > 255 or b > 255 or c > 255 or d > 255 then return false, "Invalid IP address" end
        if a == 10 or a == 127 or a == 0 or (a == 169 and b == 254) or (a == 172 and b >= 16 and b <= 31) or (a == 192 and b == 168) then return false, "Private IP URLs are not allowed" end
    elseif not host:find("%.") or host:find("%.%.") then
        return false, "Invalid domain"
    end
    return true
end

local function validateSound(path, body)
    if not body or #body < 44 then return false, "File too small" end
    if #body > 50 * 1024 * 1024 then return false, "File too large" end
    local extension = getExtension(path)
    if extension == "wav" and (not body:find("^RIFF") or not body:find("WAVE", 1, true)) then return false, "Invalid WAV header" end
    if extension == "mp3" and not body:find("^ID3") and not body:find("\255\251", 1, true) and not body:find("\255\250", 1, true) then return false, "Invalid MP3 header" end
    if extension == "ogg" and not body:find("^OggS") then return false, "Invalid OGG header" end
    return soundExtensions[extension] == true, "Unsupported sound format"
end

local function validateImage(body)
    if not body or #body < 8 then return nil, "File too small" end
    if body:sub(1, 8) == "\137PNG\r\n\26\n" then return "png" end
    if body:sub(1, 3) == "\255\216\255" then return "jpg" end
    return nil, "Invalid image format"
end

local function decodeInlineImage(source)
    if not isstring(source) or source:find("^https?://") then return nil end
    local encoded = source:match("^data:image/[%w%+%-%.]+;base64,(.+)$") or source
    if #encoded % 4 ~= 0 or not encoded:match("^[%w%+/%=]+$") then return nil end
    return util.Base64Decode(encoded)
end

local function parseArguments(name, url, contentType, callback, flags)
    if isfunction(contentType) then
        flags = callback
        callback = contentType
    elseif isfunction(callback) == false and isfunction(flags) then
        callback, flags = flags, callback
    end

    name = normalizeName(name)
    contentType = getType(name)
    return name, url, contentType, callback, flags
end

function lia.webcontent.download(name, url, contentType, callback, flags)
    name, url, contentType, callback, flags = parseArguments(name, url, contentType, callback, flags)
    if not name or not contentType then
        if callback then callback(nil, false, "Invalid name or content type") end
        return
    end

    local key = getKey(name, contentType)
    local entry = lia.webcontent.stored[key]
    url = url or entry and entry.url
    flags = flags or entry and entry.flags
    local inlineImage = contentType == "image" and decodeInlineImage(url)
    if inlineImage then
        local extension, validationError = validateImage(inlineImage)
        if not extension then
            if callback then callback(nil, false, validationError) end
            return
        end

        local withoutExtension = name:gsub("%.[^%.]+$", "")
        name = withoutExtension .. "." .. extension
        key = getKey(name, contentType)
        local inlinePath = getPath(name, contentType)
        lia.webcontent.stored[key] = {
            name = name,
            url = url,
            type = contentType,
            flags = flags
        }

        urlMap[contentType .. ":" .. url] = name
        cache[key] = nil
        ensureDir(inlinePath:match("(.+)/[^/]+$") or baseDir)
        file.Write(inlinePath, inlineImage)
        local material = buildMaterial(inlinePath, flags)
        cache[key] = material
        if callback then callback(material, false) end
        if not stats.downloadedContent[key] then
            stats.downloadedContent[key] = true
            stats.downloaded = stats.downloaded + 1
            hook.Run("WebImageDownloaded", name, "data/" .. inlinePath)
        end
        return
    end

    local valid, err = validateURL(url)
    if not valid then
        if callback then callback(nil, false, err) end
        return
    end

    lia.webcontent.stored[key] = {
        name = name,
        url = url,
        type = contentType,
        flags = flags
    }

    urlMap[contentType .. ":" .. url] = name
    cache[key] = nil
    local path = getPath(name, contentType)
    local function finalize(fromCache)
        local result = contentType == "image" and buildMaterial(path, flags) or "data/" .. path
        cache[key] = result
        if callback then callback(result, fromCache) end
        if not fromCache and not stats.downloadedContent[key] then
            stats.downloadedContent[key] = true
            stats.downloaded = stats.downloaded + 1
            hook.Run(contentType == "image" and "WebImageDownloaded" or "WebSoundDownloaded", name, contentType == "image" and "data/" .. path or result)
        end
    end

    if file.Exists(path, "DATA") then
        local data = file.Read(path, "DATA")
        local validCache = contentType == "image" and validateImage(data) or validateSound(path, data)
        if validCache then
            finalize(true)
            return
        end

        file.Delete(path)
    end

    http.Fetch(url, function(body)
        local extension, validationError
        if contentType == "image" then
            extension, validationError = validateImage(body)
            if extension then
                local withoutExtension = name:gsub("%.[^%.]+$", "")
                path = getPath(withoutExtension .. "." .. extension, contentType)
                name = withoutExtension .. "." .. extension
                key = getKey(name, contentType)
                lia.webcontent.stored[key] = {
                    name = name,
                    url = url,
                    type = contentType,
                    flags = flags
                }

                urlMap[contentType .. ":" .. url] = name
            end
        else
            extension, validationError = validateSound(path, body)
        end

        if not extension then
            if callback then callback(nil, false, validationError) end
            return
        end

        if file.Exists(path, "DATA") and file.Size(path, "DATA") == #body then
            finalize(true)
            return
        end

        ensureDir(path:match("(.+)/[^/]+$") or baseDir)
        file.Write(path, body)
        finalize(false)
    end, function(fetchError)
        if file.Exists(path, "DATA") then
            local data = file.Read(path, "DATA")
            local validCache = contentType == "image" and validateImage(data) or validateSound(path, data)
            if validCache then
                finalize(true)
                return
            end
        end

        if callback then callback(nil, false, fetchError) end
    end)
end

function lia.webcontent.register(name, url, contentType, callback, flags)
    name, url, contentType, callback, flags = parseArguments(name, url, contentType, callback, flags)
    if not name or not contentType then
        if callback then callback(nil, false, "Invalid name or content type") end
        return
    end

    lia.webcontent.stored[getKey(name, contentType)] = {
        name = name,
        url = url,
        type = contentType,
        flags = flags
    }
    return lia.webcontent.download(name, url, contentType, callback, flags)
end

function lia.webcontent.get(name, _, flags)
    name = normalizeName(name)
    local contentType = getType(name)
    if not name or not contentType then return end
    local mapped = urlMap[contentType .. ":" .. name]
    name = mapped or name
    local key = getKey(name, contentType)
    if cache[key] then return cache[key] end
    local path = getPath(name, contentType)
    if not file.Exists(path, "DATA") then return end
    local result = contentType == "image" and buildMaterial(path, flags) or "data/" .. path
    cache[key] = result
    return result
end

function lia.webcontent.getStats(contentType)
    local stored, downloaded = 0, 0
    for key, entry in pairs(lia.webcontent.stored) do
        if not contentType or entry.type == contentType then
            stored = stored + 1
            if stats.downloadedContent[key] then downloaded = downloaded + 1 end
        end
    end
    return {
        downloaded = downloaded,
        stored = stored,
        lastReset = stats.lastReset
    }
end

function lia.webcontent.clearCache(skipReRegister, contentType)
    cache, urlMap = {}, {}
    local function deleteRecursive(path)
        local files, folders = file.Find(path .. "*", "DATA")
        for _, fileName in ipairs(files or {}) do
            file.Delete(path .. fileName)
        end

        for _, folderName in ipairs(folders or {}) do
            deleteRecursive(path .. folderName .. "/")
        end
    end

    if contentType then
        deleteRecursive(baseDir .. contentType .. "/")
    else
        deleteRecursive(baseDir)
    end

    if not skipReRegister then
        for _, entry in pairs(lia.webcontent.stored) do
            if not contentType or entry.type == contentType then lia.webcontent.download(entry.name, entry.url, entry.type, nil, entry.flags) end
        end
    end
end

local function urlName(url, contentType)
    local name = urlMap[contentType .. ":" .. url]
    if name then return name end
    local cleanURL = url:match("^[^%?#]+") or url
    local extension = getExtension(cleanURL)
    if contentType == "image" and not imageExtensions[extension] then
        extension = "png"
    elseif contentType == "sound" and not soundExtensions[extension] then
        extension = "mp3"
    end

    name = "url/" .. util.CRC(url) .. "." .. extension
    urlMap[contentType .. ":" .. url] = name
    return name
end

local originalMaterial = Material
function Material(path, ...)
    local flags = select(1, ...)
    if isstring(path) then
        if path:find("^https?://") then
            local name = urlName(path, "image")
            lia.webcontent.register(name, path, "image", nil, flags)
            return originalMaterial("data/" .. getPath(name, "image"), flags)
        end

        local material = lia.webcontent.get(path, "image", flags)
        if material then return material end
    end
    return originalMaterial(path, flags)
end

local dimage = vgui.GetControlTable("DImage")
local originalSetImage = dimage.SetImage
function dimage:SetImage(source, backup)
    if isstring(source) and source:find("^https?://") then
        local name = urlName(source, "image")
        lia.webcontent.register(name, source, "image", function(material)
            if material and not material:IsError() then
                originalSetImage(self, "data/" .. getPath(name, "image"), backup)
            elseif backup then
                originalSetImage(self, backup)
            end
        end)
        return
    end

    if isstring(source) and lia.webcontent.get(source, "image") then
        originalSetImage(self, "data/" .. getPath(normalizeName(source), "image"), backup)
        return
    end

    originalSetImage(self, source, backup)
end

local function playFile(path, mode, callback)
    return sound.PlayFile(path, mode, callback)
end

local originalPlayFile = sound.PlayFile
function sound.PlayFile(path, mode, callback)
    if isstring(path) and path:find("^https?://") then
        local name = urlName(path, "sound")
        local cached = lia.webcontent.get(name, "sound")
        if cached then return originalPlayFile(cached, mode or "", callback) end
        lia.webcontent.register(name, path, "sound", function(localPath)
            if localPath then
                originalPlayFile(localPath, mode or "", callback)
            elseif callback then
                callback(nil, nil, "failed")
            end
        end)
        return
    end

    if isstring(path) then
        local cached = lia.webcontent.get(path, "sound")
        if cached then return originalPlayFile(cached, mode or "", callback) end
        local name = normalizeName(path)
        local entry = name and lia.webcontent.stored[getKey(name, "sound")]
        if entry then
            lia.webcontent.download(name, nil, "sound", function(localPath)
                if localPath then
                    originalPlayFile(localPath, mode or "", callback)
                elseif callback then
                    callback(nil, nil, "failed")
                end
            end)
            return
        end
    end
    return originalPlayFile(path, mode, callback)
end

local originalPlayURL = sound.PlayURL
function sound.PlayURL(url, mode, callback)
    if isstring(url) and url:find("^https?://") and not (mode or ""):find("3d", 1, true) then return sound.PlayFile(url, mode, callback) end
    if isstring(url) and url:find("^https?://") then lia.webcontent.register(urlName(url, "sound"), url, "sound") end
    return originalPlayURL(url, mode, callback)
end

local originalSurfacePlaySound = surface.PlaySound
function surface.PlaySound(path, _, callback)
    if isstring(path) and path:find("^https?://") then
        local name = urlName(path, "sound")
        lia.webcontent.register(name, path, "sound", function(localPath)
            if localPath then
                originalSurfacePlaySound(localPath:gsub("^data/", ""))
                if callback then callback(true) end
            elseif callback then
                callback(false, "failed")
            end
        end)
        return
    end

    if isstring(path) then
        local cached = lia.webcontent.get(path, "sound")
        if cached then
            originalSurfacePlaySound(cached:gsub("^data/", ""))
            if callback then callback(true) end
            return
        end
    end

    originalSurfacePlaySound(path)
    if callback then callback(true) end
end

function lia.webcontent.playButtonSound(customSound, callback)
    if customSound and customSound ~= "button_click.wav" then
        surface.PlaySound(customSound, nil, callback)
        return
    end

    local cached = lia.webcontent.get("button_click.wav", "sound")
    if cached then
        playFile(cached, "", function() end)
        if callback then callback(true) end
        return
    end

    lia.webcontent.download("button_click.wav", nil, "sound", function(localPath)
        if localPath then
            playFile(localPath, "", function() end)
            if callback then callback(true) end
        elseif callback then
            callback(false)
        end
    end)
end

lia.webcontent.register("lilia.png", "https://bleonheart.github.io/Samael-Assets/lilia.png", "image")
lia.webcontent.register("locked.png", "https://bleonheart.github.io/Samael-Assets/misc/locked.png", "image")
lia.webcontent.register("unlocked.png", "https://bleonheart.github.io/Samael-Assets/misc/unlocked.png", "image")
lia.webcontent.register("button_click.wav", "https://bleonheart.github.io/Samael-Assets/misc/button_click.wav", "sound")
lia.webcontent.register("ratio_button.wav", "https://bleonheart.github.io/Samael-Assets/misc/ratio_button.wav", "sound")
lia.webcontent.register("locked.png", "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")
lia.webcontent.register("unlocked.png", "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")
ensureDir(baseDir)
