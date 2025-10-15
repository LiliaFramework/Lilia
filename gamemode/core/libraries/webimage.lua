lia.webimage = lia.webimage or {}
lia.webimage.stored = lia.webimage.stored or {}
local baseDir = "lilia/webimages/"
local cache = {}
local urlMap = {}
local stats = {
    downloaded = 0,
    lastReset = os.time(),
    downloadedImages = {}
}

local function ensureDir(p)
    local parts = string.Explode("/", p)
    local cur = ""
    for _, v in ipairs(parts) do
        if v ~= "" then
            cur = cur == "" and v or cur .. "/" .. v
            if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
        end
    end
end

local function deriveUrlSaveName(url)
    local filename = url:match("([^/]+)$") or util.CRC(url) .. ".png"
    if file.Exists(baseDir .. filename, "DATA") then return filename end
    local path = url:match("^https?://[^/]+/(.+)$") or filename
    if path:find("/") then path = path:gsub("^[^/]+/", "", 1) end
    return "urlimages/" .. path
end

local function buildMaterial(p, flags)
    return Material("data/" .. p, flags or "noclamp smooth")
end

local function validateURL(url)
    if not url or type(url) ~= "string" then return false, L("urlNotValidString") end
    if not url:find("^https?://") then return false, L("urlMustStartWithHttp") end
    local domain = url:match("^https?://([^/]+)")
    if not domain then return false, L("urlNoValidDomain") end
    if domain:find("^localhost") or domain:find("^127%.0%.0%.1") then return false, L("localhostUrlsNotAllowed") end
    local ipPattern = "^%d+%.%d+%.%d+%.%d+$"
    if domain:match(ipPattern) then
        local parts = string.Explode(".", domain)
        if #parts ~= 4 then return false, L("invalidIPAddressFormat") end
        for _, part in ipairs(parts) do
            local num = tonumber(part)
            if not num or num < 0 or num > 255 then return false, L("invalidIPAddressOctet") end
        end
    else
        if not domain:find("%.") then return false, L("domainMustContainDot") end
        if domain:find("%.%.") then return false, L("domainContainsConsecutiveDots") end
    end

    if url:find("[<>\"\\|]") then return false, L("urlContainsInvalidChars") end
    if #url > 2048 then return false, L("urlTooLong") end
    return true
end

function lia.webimage.download(n, u, cb, flags)
    if not isstring(n) then return end
    local url = u or lia.webimage.stored[n] and lia.webimage.stored[n].url
    local flg = flags or lia.webimage.stored[n] and lia.webimage.stored[n].flags
    if not url or url == "" then
        if cb then cb(nil, false, "no url") end
        return
    end

    local isValidURL, validationError = validateURL(url)
    if not isValidURL then
        if cb then cb(nil, false, "invalid url: " .. validationError) end
        return
    end

    if isstring(url) then urlMap[url] = n end
    cache[n] = nil
    local savePath = baseDir .. n
    local function finalize(fromCache)
        local m = buildMaterial(savePath, flg)
        cache[n] = m
        if cb then cb(m, fromCache) end
        if not fromCache and not stats.downloadedImages[n] then
            stats.downloadedImages[n] = true
            stats.downloaded = stats.downloaded + 1
            hook.Run("WebImageDownloaded", n, "data/" .. savePath)
        end
    end

    local cleanName = n:gsub("%.%w+$", "")
    local extension = nil
    for _, ext in ipairs({"png", "jpg", "jpeg"}) do
        local testPath = baseDir .. cleanName .. "." .. ext
        if file.Exists(testPath, "DATA") then
            savePath = testPath
            finalize(true)
            return
        end
    end

    http.Fetch(url, function(b)
        if string.lower(string.sub(b, 2, 4)) == "png" then
            extension = "png"
        elseif string.lower(string.sub(b, 7, 10)) == "jfif" or string.lower(string.sub(b, 7, 10)) == "exif" then
            extension = "jpg"
        end

        if not extension then
            if cb then cb(nil, false, L("invalidFileFormatNotPngJpeg")) end
            return
        end

        savePath = baseDir .. cleanName .. "." .. extension
        if file.Exists(savePath, "DATA") then
            local existingSize = file.Size(savePath, "DATA")
            if existingSize == #b then
                finalize(true)
                return
            end
        end

        local dirPath = savePath:match("(.+)/[^/]+$")
        if dirPath then
            ensureDir(dirPath)
        else
            ensureDir(baseDir)
        end

        file.Write(savePath, b)
        finalize(false)
    end, function(e)
        for _, ext in ipairs({"png", "jpg", "jpeg"}) do
            local testPath = baseDir .. cleanName .. "." .. ext
            if file.Exists(testPath, "DATA") then
                savePath = testPath
                finalize(true)
                return
            end
        end

        if cb then cb(nil, false, e) end
    end)
end

function lia.webimage.register(n, u, cb, flags)
    lia.webimage.stored[n] = {
        url = u,
        flags = flags
    }

    lia.webimage.download(n, u, cb, flags)
end

function lia.webimage.get(n, flags)
    local key = urlMap[n] or n
    if cache[key] then return cache[key] end
    local savePath = baseDir .. key
    if file.Exists(savePath, "DATA") then
        local m = buildMaterial(savePath, flags)
        cache[key] = m
        return m
    end
end

local origMaterial = Material
function Material(p, ...)
    local flags = select(1, ...)
    if isstring(p) then
        if p:find("^https?://") then
            local n = urlMap[p]
            if not n then
                n = deriveUrlSaveName(p)
                urlMap[p] = n
            end

            lia.webimage.register(n, p)
            return origMaterial("data/" .. baseDir .. n, flags)
        elseif p:find("^lilia/webimages/") then
            local webPath = p:gsub("^lilia/webimages/", "")
            local mat = lia.webimage.get(webPath, flags)
            if mat then return mat end
            return origMaterial("data/" .. baseDir .. webPath, flags)
        elseif p:find("^webimages/") then
            local webPath = p:gsub("^webimages/", "")
            local mat = lia.webimage.get(webPath, flags)
            if mat then return mat end
            return origMaterial("data/" .. baseDir .. webPath, flags)
        else
            local mat = lia.webimage.get(p, flags)
            if mat then return mat end
        end
    end
    return origMaterial(p, flags)
end

local dimage = vgui.GetControlTable("DImage")
local origSetImage = dimage.SetImage
function dimage:SetImage(src, backup)
    if isstring(src) then
        if src:find("^https?://") then
            local n = urlMap[src]
            if not n then
                n = deriveUrlSaveName(src)
                urlMap[src] = n
            end

            local savePath = baseDir .. n
            lia.webimage.register(n, src, function(m)
                if m and not m:IsError() then
                    origSetImage(self, "data/" .. savePath, backup)
                elseif backup then
                    origSetImage(self, backup)
                end
            end)
            return
        elseif src:find("^lilia/webimages/") then
            local webPath = src:gsub("^lilia/webimages/", "")
            local m = lia.webimage.get(webPath)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. webPath, backup)
                return
            end
        elseif src:find("^webimages/") then
            local webPath = src:gsub("^webimages/", "")
            local m = lia.webimage.get(webPath)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. webPath, backup)
                return
            end
        else
            local m = lia.webimage.get(src)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. src, backup)
                return
            end
        end
    end

    origSetImage(self, src, backup)
end

local function findImagesRecursive(dir, result)
    result = result or {}
    local files, dirs = file.Find(dir .. "*", "DATA")
    if files then
        for _, fn in ipairs(files) do
            table.insert(result, dir .. fn)
        end
    end

    if dirs then
        for _, subdir in ipairs(dirs) do
            findImagesRecursive(dir .. subdir .. "/", result)
        end
    end
    return result
end

concommand.Add("lia_saved_images", function()
    local files = findImagesRecursive(baseDir)
    if not files or #files == 0 then return end
    local f = vgui.Create("DFrame")
    f:SetTitle(L("webImagesTitle"))
    f:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    f:Center()
    f:MakePopup()
    local scroll = vgui.Create("liaScrollPanel", f)
    scroll:Dock(FILL)
    local layout = vgui.Create("DIconLayout", scroll)
    layout:Dock(FILL)
    layout:SetSpaceX(4)
    layout:SetSpaceY(4)
    for _, filePath in ipairs(files) do
        local img = layout:Add("DImage")
        img:SetMaterial(buildMaterial(filePath))
        img:SetSize(128, 128)
        img:SetTooltip(filePath:sub(#baseDir + 1))
    end
end)

local function deleteDirectoryRecursive(dir)
    local files, dirs = file.Find(dir .. "*", "DATA")
    if files then
        for _, fn in ipairs(files) do
            file.Delete(dir .. fn)
        end
    end

    if dirs then
        for _, subdir in ipairs(dirs) do
            deleteDirectoryRecursive(dir .. subdir .. "/")
            file.Delete(dir .. subdir)
        end
    end
end

concommand.Add("lia_cleanup_images", function()
    local files = findImagesRecursive(baseDir)
    local removedCount = 0
    for _, filePath in ipairs(files) do
        local fileData = file.Read(filePath, "DATA")
        if fileData then
            local isValid = false
            if string.lower(string.sub(fileData, 2, 4)) == "png" then
                isValid = true
            elseif string.lower(string.sub(fileData, 7, 10)) == "jfif" or string.lower(string.sub(fileData, 7, 10)) == "exif" then
                isValid = true
            end

            if not isValid then
                file.Delete(filePath)
                removedCount = removedCount + 1
            end
        else
            file.Delete(filePath)
            removedCount = removedCount + 1
        end
    end

    for fileName, _ in pairs(cache) do
        local savePath = baseDir .. fileName
        if not file.Exists(savePath, "DATA") then cache[fileName] = nil end
    end
end)

concommand.Add("lia_wipewebimages", function()
    deleteDirectoryRecursive(baseDir)
    cache = {}
    urlMap = {}
    lia.information(L("webImagesCleared"))
    ensureDir(baseDir)
    timer.Simple(0.1, function()
        for name, data in pairs(lia.webimage.stored) do
            lia.webimage.download(name, data.url, nil, data.flags)
        end

        lia.information(L("startedRedownloadingStoredWebImages"))
    end)
end)

function lia.webimage.getStats()
    local totalStored = 0
    for _ in pairs(lia.webimage.stored) do
        totalStored = totalStored + 1
    end
    return {
        downloaded = stats.downloaded,
        stored = totalStored,
        lastReset = stats.lastReset
    }
end

lia.webimage.register("lilia.png", "https://bleonheart.github.io/Samael-Assets/lilia.png")
lia.webimage.register("locked.png", "https://bleonheart.github.io/Samael-Assets/misc/locked.png")
lia.webimage.register("unlocked.png", "https://bleonheart.github.io/Samael-Assets/misc/unlocked.png")
lia.webimage.register("checkbox.png", "https://bleonheart.github.io/Samael-Assets/misc/checkbox.png")
lia.webimage.register("unchecked.png", "https://bleonheart.github.io/Samael-Assets/misc/unchecked.png")
lia.webimage.register("normaltalk.png", "https://bleonheart.github.io/Samael-Assets/misc/normaltalk.png")
lia.webimage.register("yelltalk.png", "https://bleonheart.github.io/Samael-Assets/misc/yelltalk.png")
lia.webimage.register("whispertalk.png", "https://bleonheart.github.io/Samael-Assets/misc/whispertalk.png")
lia.webimage.register("notalk.png", "https://bleonheart.github.io/Samael-Assets/misc/notalk.png")
lia.webimage.register("invslotfree.png", "https://bleonheart.github.io/Samael-Assets/misc/invslotfree.png")
lia.webimage.register("vignette.png", "https://bleonheart.github.io/Samael-Assets/misc/vignette.png")
lia.webimage.register("dark_vignette.png", "https://bleonheart.github.io/Samael-Assets/misc/dark_vignette.png")
lia.webimage.register("invslotblocked.png", "https://bleonheart.github.io/Samael-Assets/misc/invslotblocked.png")
lia.webimage.register("settings.png", "https://bleonheart.github.io/Samael-Assets/misc/settings.png")
lia.webimage.register("close_button.png", "https://bleonheart.github.io/Samael-Assets/misc/close_button.png")
ensureDir(baseDir)