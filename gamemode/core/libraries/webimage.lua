--[[
    Folder: Libraries
    File: webimage.md
]]
--[[
    Web Image Library

    Web-based image downloading, caching, and management system for the Lilia framework.
]]
--[[
    Overview:
        The web image library provides comprehensive functionality for downloading, caching, and managing web-based images in the Lilia framework. It handles automatic downloading of images from URLs, local caching to improve performance, and seamless integration with Garry's Mod's material system. The library operates on both server and client sides, with intelligent caching mechanisms that prevent redundant downloads and ensure images are available offline after initial download. It includes URL validation, file format detection, and automatic directory management for organized storage. The library also provides hooks for download events and statistics tracking. Images are stored in the data/lilia/webimages/ directory and can be accessed through various path formats for maximum compatibility with existing code.
]]
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
    if not url or not isstring(url) then return false, L("urlNotValidString") end
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

--[[
    Purpose:
        Ensure a remote image is downloaded, validated, and made available as a `Material`.

    When Called:
        During UI setup when an image asset must be cached before drawing panels.

    Parameters:
        n (string)
            Logical storage name for the downloaded image.
        u (string|nil)
            Optional override URL; uses registered `stored` entry otherwise.
        cb (function|nil)
            Callback receiving `(material, fromCache, errStr)`.
        flags (string|nil)
            Optional material flags for creation (e.g., `"noclamp smooth"`).

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        ```lua
            -- Preload multiple HUD icons, then draw them when ready.
            local function preloadIcons(list)
                if #list == 0 then return end
                local entry = table.remove(list, 1)
                lia.webimage.download(entry.name, entry.url, function(mat)
                    if mat then
                        hook.Run("WebImageReady", entry.name, mat)
                    end
                    preloadIcons(list)
                end, entry.flags)
            end

            hook.Add("InitPostEntity", "PreloadHUDImages", function()
                preloadIcons({
                    {name = "hud/armor_icon.png", url = "https://assets.example.com/images/armor_icon.png", flags = "noclamp smooth"},
                    {name = "hud/health_icon.png", url = "https://assets.example.com/images/health_icon.png", flags = "noclamp smooth"}
                })
            end)
        ```
]]
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

--[[
    Purpose:
        Cache metadata for a URL and optionally download it immediately.

    When Called:
        At startup when the gamemode wants to pre-register UI imagery.

    Parameters:
        n (string)
            Internal key used to store and retrieve the image.
        u (string)
            The HTTP/HTTPS source URL.
        cb (function|nil)
            Optional callback forwarded to `download`.
        flags (string|nil)
            Material creation flags stored for future lookups.

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("GamemodeLoaded", "RegisterIconLibrary", function()
                lia.webimage.register("icons/police.png", "https://assets.example.com/ui/icons/police.png", function(mat)
                    if mat then lia.log.add(nil, "webimageCached", "icons/police.png") end
                end, "noclamp smooth")

                lia.webimage.register("icons/medic.png", "https://assets.example.com/ui/icons/medic.png", function(mat)
                    if not mat then return end
                    hook.Add("HUDPaint", "DrawMedicBadge", function()
                        surface.SetMaterial(mat)
                        surface.DrawTexturedRect(24, ScrH() - 96, 64, 64)
                    end)
                end)
            end)
        ```
]]
function lia.webimage.register(n, u, cb, flags)
    lia.webimage.stored[n] = {
        url = u,
        flags = flags
    }

    lia.webimage.download(n, u, cb, flags)
end

--[[
    Purpose:
        Retrieve a previously cached `Material` for immediate drawing.

    When Called:
        Within paint hooks or derma code that needs a cached texture without triggering a download.

    Parameters:
        n (string)
            The registered name or derived key.
        flags (string|nil)
            Optional material flags used to rebuild the material when missing.

    Returns:
        Material|nil
            The cached material or `nil` if it isn't downloaded yet.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Render cached image if available, otherwise queue download and retry.
            local function drawIcon(name, x, y)
                local mat = lia.webimage.get(name, "noclamp smooth")
                if mat then
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(x, y, 64, 64)
                else
                    lia.webimage.download(name)
                    timer.Simple(0.2, function() drawIcon(name, x, y) end)
                end
            end

            hook.Add("HUDPaint", "DrawPoliceIcon", function() drawIcon("icons/police.png", 32, 32) end)
        ```
]]
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

--[[
    Purpose:
        Expose download statistics to aid diagnostics or admin tooling.

    When Called:
        When reporting the number of cached images or implementing cache health checks.

    Parameters:
        None

    Returns:
        table
            `{ downloaded = number, stored = number, lastReset = timestamp }`.

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("PlayerSay", "PrintWebImageStats", function(ply, text)
                if text ~= "!imagecache" then return end
                local stats = lia.webimage.getStats()
                ply:notifyLocalized("webImageStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
            end)
        ```
]]
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

--[[
    Purpose:
        Evict all downloaded web images, resetting the material cache.

    When Called:
        During configuration reloads or when manual cache management is required.

    Parameters:
        skipReRegister (boolean)
            When true, previously registered URLs are not re-downloaded.

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        ```lua
            -- Drop and re-download web images after admins push new branding.
            hook.Add("OnConfigReload", "RebuildWebImageCache", function()
                lia.webimage.clearCache(false)
                for name, data in pairs(lia.webimage.stored) do
                    lia.webimage.download(name, data.url, nil, data.flags)
                end
            end)
        ```
]]
function lia.webimage.clearCache(skipReRegister)
    cache = {}
    urlMap = {}
    local function deleteRecursive(path)
        local files, folders = file.Find(path .. "*", "DATA")
        if files then
            for _, fileName in ipairs(files) do
                local filePath = path .. fileName
                if file.Exists(filePath, "DATA") then file.Delete(filePath) end
            end
        end

        if folders then
            for _, folderName in ipairs(folders) do
                deleteRecursive(path .. folderName .. "/")
            end
        end
    end

    deleteRecursive(baseDir)
    if not skipReRegister and lia.webimage.stored then
        for name, data in pairs(lia.webimage.stored) do
            if data and data.url then lia.webimage.register(name, data.url, nil, data.flags) end
        end
    end
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
lia.webimage.register("drug.png", "https://bleonheart.github.io/Samael-Assets/misc/drug.png")
lia.webimage.register("armor.png", "https://bleonheart.github.io/Samael-Assets/misc/armor.png")
lia.webimage.register("emptyframe.png", "https://bleonheart.github.io/Samael-Assets/misc/emptyframe.png")
lia.webimage.register("cuffed.png", "https://bleonheart.github.io/Samael-Assets/misc/cuffed.png")
lia.webimage.register("backgroundsquare.png", "https://bleonheart.github.io/Samael-Assets/misc/backgroundsquare.png")
ensureDir(baseDir)
