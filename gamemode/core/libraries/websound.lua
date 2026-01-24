--[[
    Folder: Libraries
    File: websound.md
]]
--[[
    WebSound Library

    Web-based audio content downloading, caching, and playback system for the Lilia framework.
]]
--[[
    Overview:
        The websound library provides comprehensive functionality for managing web-based audio content in the Lilia framework. It handles downloading, caching, validation, and playback of sound files from HTTP/HTTPS URLs, with automatic local storage and retrieval. The library operates on both server and client sides, providing seamless integration with Garry's Mod's sound system through enhanced versions of sound.PlayFile, sound.PlayURL, and surface.PlaySound functions. It includes robust URL validation, file format verification, caching mechanisms, and statistics tracking. The library ensures optimal performance by avoiding redundant downloads and providing fallback mechanisms for failed downloads while maintaining compatibility with existing sound APIs.
]]
lia.websound = lia.websound or {}
lia.websound.stored = lia.websound.stored or {}
local baseDir = "lilia/websounds/"
local cache = {}
local urlMap = {}
local stats = {
    downloaded = 0,
    lastReset = os.time(),
    downloadedSounds = {}
}

--[[
    Purpose:
        Normalize a sound file path or name by converting backslashes to forward slashes, trimming whitespace, and removing common prefixes.

    When Called:
        Internally by websound functions when processing sound identifiers.

    Parameters:
        name (string|any)
            The sound name or path to normalize. Non-string values are returned unchanged.

    Returns:
        string|any
            The normalized string with consistent formatting, or the original value if not a string.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            local normalized = normalizeName(" sound/music_track.mp3 ")
            -- Returns: "music_track.mp3"
        ```
]]
local function normalizeName(name)
    if not isstring(name) then return name end
    name = name:gsub("\\", "/")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if string.StartWith(name, "/") then name = name:sub(2) end
    if string.StartWith(name, "sound/") then name = name:sub(7) end
    return name
end

--[[
    Purpose:
        Generate a unique local filename for caching a web sound URL, preferring the original filename when available.

    When Called:
        Internally when registering or downloading web sounds to create consistent cache file paths.

    Parameters:
        url (string)
            The HTTP/HTTPS URL of the sound file.

    Returns:
        string
            A normalized path within the websounds directory for local storage.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            local saveName = deriveUrlSaveName("https://example.com/audio/track.mp3")
            -- Returns: "urlsounds/audio/track.mp3"
        ```
]]
local function deriveUrlSaveName(url)
    local filename = url:match("([^/]+)$") or util.CRC(url) .. ".mp3"
    if file.Exists(baseDir .. filename, "DATA") then return filename end
    local path = url:match("^https?://[^/]+/(.+)$") or filename
    if path:find("/") then path = path:gsub("^[^/]+/", "", 1) end
    return "urlsounds/" .. path
end

--[[
    Purpose:
        Ensure all directories in a given path exist, creating them recursively if necessary.

    When Called:
        Internally before writing sound files to ensure the directory structure exists.

    Parameters:
        p (string)
            The file path whose parent directories should be created.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            ensureDir("lilia/websounds/audio/effects/impact.wav")
            -- Creates directories: lilia/, lilia/websounds/, lilia/websounds/audio/, lilia/websounds/audio/effects/
        ```
]]
local function ensureDir(p)
    local parts = string.Explode("/", p)
    local cur = ""
    for _, v in ipairs(parts) do
        cur = cur == "" and v or cur .. "/" .. v
        if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
    end
end

--[[
    Purpose:
        Convert a relative websound path to a full filesystem path for use with Garry's Mod file functions.

    When Called:
        Internally when constructing paths for file operations and sound playback.

    Parameters:
        p (string)
            The relative path within the websounds directory.

    Returns:
        string
            The full filesystem path prefixed with "data/".

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            local fullPath = buildPath("urlsounds/track.mp3")
            -- Returns: "data/urlsounds/track.mp3"
        ```
]]
local function buildPath(p)
    return "data/" .. p
end

--[[
    Purpose:
        Validate downloaded sound file data by checking file size, format headers, and supported extensions.

    When Called:
        Internally after downloading sound files to ensure they contain valid audio data.

    Parameters:
        filePath (string)
            The intended filename/path to check the extension.
        fileData (string)
            The raw file content as a binary string.

    Returns:
        boolean, string
            true if valid, or false and an error message if invalid.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            local isValid, errorMsg = validateSoundFile("track.mp3", downloadedData)
            if not isValid then
                print("Invalid sound file: " .. errorMsg)
            end
        ```
]]
local function validateSoundFile(filePath, fileData)
    if not fileData or #fileData == 0 then return false, "empty file" end
    local fileSize = #fileData
    if fileSize < 44 then return false, "file too small" end
    if fileSize > 50 * 1024 * 1024 then return false, "file too large" end
    local extMatch = filePath:match("%.([^%.]+)$")
    if not extMatch then return false, L("noFileExtension") end
    local ext = extMatch:lower()
    if ext == "wav" then
        if not fileData:find("^RIFF") or not fileData:find("WAVE") then return false, L("invalidWAVHeader") end
    elseif ext == "mp3" then
        if not fileData:find("^ID3") and not fileData:find("\255\251") and not fileData:find("\255\250") then return false, "invalid mp3 format" end
    elseif ext == "ogg" then
        if not fileData:find("^OggS") then return false, L("invalidOGGHeader") end
    end
    return true
end

--[[
    Purpose:
        Validate a URL for security and format compliance before attempting to download from it.

    When Called:
        Internally before initiating HTTP requests to ensure URLs are safe and properly formatted.

    Parameters:
        url (string)
            The URL to validate.

    Returns:
        boolean, string
            true if valid, or false and an error message if invalid.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Internal usage only
            local isValid, errorMsg = validateURL("https://example.com/audio.mp3")
            if not isValid then
                print("Invalid URL: " .. errorMsg)
            end
        ```
]]
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
        Download or reuse a cached web sound by name, running a callback with the local file path.

    When Called:
        Whenever a module needs to ensure a URL-based sound exists before playback, especially during initialization.

    Parameters:
        name (string)
            The logical name for this sound; normalized before saving.
        url (string|nil)
            Optional override URL; falls back to previously registered URLs.
        cb (function|nil)
            Completion callback that receives (path, fromCache, error).

    Realm:
        Client

    Example Usage:
        ```lua
            -- Preload multiple tracks in sequence, falling back to cached copies.
            local playlist = {
                {"music/combat_theme.mp3", "https://assets.example.com/music/combat_theme.mp3"},
                {"music/stealth_loop.ogg", "https://assets.example.com/music/stealth_loop.ogg"}
            }

            local function preloadNext(i)
                local entry = playlist[i]
                if not entry then return end
                lia.websound.download(entry[1], entry[2], function(path, fromCache, err)
                    if not path then
                        lia.util.logError("Failed to preload " .. entry[1] .. ": " .. tostring(err))
                        return
                    end
                    if not fromCache then
                        lia.log.add(nil, "websoundCached", entry[1])
                    end
                    preloadNext(i + 1)
                end)
            end

            hook.Add("InitPostEntity", "PreloadMusicPlaylist", function() preloadNext(1) end)
        ```
]]
function lia.websound.download(name, url, cb)
    if not isstring(name) then return end
    name = normalizeName(name)
    local u = url or lia.websound.stored[name]
    if not u or u == "" then
        if cb then cb(nil, false, L("noUrlProvided")) end
        return
    end

    local isValidURL, urlValidationError = validateURL(u)
    if not isValidURL then
        if cb then cb(nil, false, L("invalidUrl") .. ": " .. urlValidationError) end
        return
    end

    if isstring(u) then urlMap[u] = name end
    cache[name] = nil
    local savePath = baseDir .. name
    local function finalize(fromCache)
        local path = buildPath(savePath)
        cache[name] = path
        if cb then cb(path, fromCache) end
        if not fromCache and not stats.downloadedSounds[name] then
            stats.downloadedSounds[name] = true
            stats.downloaded = stats.downloaded + 1
            hook.Run("WebSoundDownloaded", name, path)
        end
    end

    if file.Exists(savePath, "DATA") then
        local existingFileData = file.Read(savePath, "DATA")
        if existingFileData then
            local isValid, _ = validateSoundFile(savePath, existingFileData)
            if isValid then
                finalize(true)
                return
            else
                file.Delete(savePath)
            end
        end
    end

    http.Fetch(u, function(body)
        local isValid, downloadValidationError = validateSoundFile(name, body)
        if not isValid then
            if cb then cb(nil, false, L("fileValidationFailed", downloadValidationError)) end
            return
        end

        if file.Exists(savePath, "DATA") then
            local existingSize = file.Size(savePath, "DATA")
            if existingSize == #body then
                finalize(true)
                return
            end
        end

        ensureDir(savePath:match("(.+)/[^/]+$") or baseDir)
        file.Write(savePath, body)
        finalize(false)
    end, function(err)
        if file.Exists(savePath, "DATA") then
            local existingFileData = file.Read(savePath, "DATA")
            if existingFileData then
                local isValid, cachedValidationError = validateSoundFile(savePath, existingFileData)
                if isValid then
                    finalize(true)
                else
                    file.Delete(savePath)
                    if cb then cb(nil, false, L("cachedFileInvalid") .. ": " .. cachedValidationError) end
                end
            else
                if cb then cb(nil, false, L("couldNotReadCachedFile")) end
            end
        elseif cb then
            cb(nil, false, err)
        end
    end)
end

--[[
    Purpose:
        Register a named URL so future calls can rely on a cached entry and optionally download it immediately.

    When Called:
        During gamemode setup when you want to associate a friendly key with a remote sound asset.

    Parameters:
        name (string)
            Logical identifier used for caching and later lookup.
        url (string)
            HTTP/HTTPS link pointing to the desired sound file.
        cb (function|nil)
            Optional callback same as `download`.

    Returns:
        string?
            Returns the cached path if already downloaded.

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("PostGamemodeLoaded", "RegisterUIAudio", function()
                lia.websound.register("ui/alert.wav", "https://assets.example.com/sounds/ui/alert.wav", function(path)
                    if path then surface.PlaySound(path) end
                end)

                lia.websound.register("ui/ambient.mp3", "https://assets.example.com/sounds/ui/ambient.mp3", function(path)
                    if not path then return end
                    timer.Create("UIAmbientLoop", 120, 0, function()
                        sound.PlayFile(path, "", function() end)
                    end)
                end)
            end)
        ```
]]
function lia.websound.register(name, url, cb)
    name = normalizeName(name)
    lia.websound.stored[name] = url
    return lia.websound.download(name, url, cb)
end

--[[
    Purpose:
        Lookup the cached filesystem path for a registered web sound when you need to play it immediately.

    When Called:
        Within any playback logic that wants to skip downloading and use an already fetched file.

    Parameters:
        name (string)
            The normalized identifier previously registered or downloaded.

    Returns:
        string|nil
            Local `data/` path to the sound file, or `nil` if not downloaded yet.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Play from cache or queue a download with a one-time completion hook.
            local function playAmbient()
                local cachedPath = lia.websound.get("ui/ambient.mp3")
                if cachedPath then
                    sound.PlayFile(cachedPath, "mono", function() end)
                    return
                end

                lia.websound.download("ui/ambient.mp3", nil, function(path)
                    if path then sound.PlayFile(path, "mono", function() end) end
                end)
            end

            hook.Add("InitPostEntity", "PlayAmbientCached", playAmbient)
        ```
]]
function lia.websound.get(name)
    name = normalizeName(name)
    local key = urlMap[name] or name
    if cache[key] then return cache[key] end
    local savePath = baseDir .. key
    if file.Exists(savePath, "DATA") then
        local path = buildPath(savePath)
        cache[key] = path
        return path
    end
    return nil
end

local origPlayFile = sound.PlayFile
--[[
    Purpose:
        Enhanced version of sound.PlayFile that supports web URLs and websound caching, falling back to the original function for local sounds.

    When Called:
        When playing sound files, automatically handling both local files and web URLs with caching.

    Parameters:
        path (string)
            The sound file path or URL to play. Supports web URLs and websound paths.
        mode (string|nil)
            Optional playback mode (e.g., "3d", "mono"). Passed to the underlying sound system.
        cb (function|nil)
            Optional callback function called when playback starts, receiving (channel, errorCode, errorString).

    Realm:
        Client

    Example Usage:
        ```lua
            -- Play a cached web sound
            sound.PlayFile("https://example.com/sound.mp3", "mono", function(channel)
                if IsValid(channel) then
                    print("Sound started playing")
                end
            end)

            -- Play a websound path
            sound.PlayFile("websounds/ui/click.wav")
        ```
]]
function sound.PlayFile(path, mode, cb)
    if isstring(path) then
        path = normalizeName(path)
        if path:find("^https?://") then
            local name = urlMap[path]
            if not name then
                name = deriveUrlSaveName(path)
                urlMap[path] = name
            end

            local cachedPath = lia.websound.get(name)
            if cachedPath then
                origPlayFile(cachedPath, mode or "", cb)
                return
            end

            lia.websound.register(name, path, function(localPath)
                if localPath then
                    origPlayFile(localPath, mode or "", cb)
                elseif cb then
                    cb(nil, nil, "failed")
                end
            end)
            return
        else
            local webPath
            if path:find("^lilia/websounds/") then
                webPath = path:gsub("^lilia/websounds/", "")
            elseif path:find("^websounds/") then
                webPath = path:gsub("^websounds/", "")
            else
                webPath = path
            end

            local localPath = lia.websound.get(webPath)
            if localPath then
                if webPath:match("%.wav$") then
                    local reqMode = mode or ""
                    local wants3d = reqMode:find("3d", 1, true) ~= nil
                    local attempts = {}
                    local seen = {}
                    local function add(m)
                        if m and m ~= "" and not seen[m] then
                            seen[m] = true
                            table.insert(attempts, m)
                        end
                    end

                    local function tryNext(i, lastErrCode, lastErrStr)
                        local m = attempts[i]
                        if not m then
                            if cb then cb(nil, lastErrCode, lastErrStr or "failed") end
                            return
                        end

                        origPlayFile(localPath, m, function(ch, errCode, errStr)
                            if IsValid(ch) then
                                if cb then cb(ch, errCode, errStr) end
                            else
                                tryNext(i + 1, errCode, errStr)
                            end
                        end)
                    end

                    if wants3d then
                        add(reqMode)
                        add("mono 3d")
                        add("3d")
                    else
                        add(reqMode)
                        table.insert(attempts, "")
                        add("mono")
                    end

                    tryNext(1)
                    return
                else
                    return origPlayFile(localPath, mode or "", cb)
                end
            else
                local url = lia.websound.stored and lia.websound.stored[webPath]
                if url then
                    lia.websound.register(webPath, url, function(downloadedPath)
                        if not downloadedPath then
                            if cb then cb(nil, nil, "failed") end
                            return
                        end

                        if webPath:match("%.wav$") then
                            origPlayFile(downloadedPath, mode or "", cb)
                        else
                            origPlayFile(downloadedPath, mode or "", cb)
                        end
                    end)
                    return
                end
            end
        end
    end
    return origPlayFile(path, mode, cb)
end

local origPlayURL = sound.PlayURL
--[[
    Purpose:
        Enhanced version of sound.PlayURL that integrates with websound caching for improved performance and reliability.

    When Called:
        When streaming sound from URLs, with automatic caching for better performance on repeated plays.

    Parameters:
        url (string)
            The HTTP/HTTPS URL of the sound to stream. If not a URL, falls back to original behavior.
        mode (string|nil)
            Optional playback mode. For 3D URLs, uses original PlayURL; others are cached first.
        cb (function|nil)
            Optional callback function called when playback starts.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Stream with caching for repeated use
            sound.PlayURL("https://example.com/stream.mp3", "mono", function(channel)
                if IsValid(channel) then
                    print("Stream started")
                end
            end)

            -- 3D positional audio (bypasses caching)
            sound.PlayURL("https://example.com/3d_sound.wav", "3d")
        ```
]]
function sound.PlayURL(url, mode, cb)
    if isstring(url) and url:find("^https?://") then
        local reqMode = mode or ""
        if reqMode:find("3d", 1, true) ~= nil then
            origPlayURL(url, reqMode, cb)
            local name = urlMap[url]
            if not name then
                name = deriveUrlSaveName(url)
                urlMap[url] = name
            end

            lia.websound.register(name, url)
            return
        end

        local name = urlMap[url]
        if not name then
            name = deriveUrlSaveName(url)
            urlMap[url] = name
        end

        local cachedPath = lia.websound.get(name)
        if cachedPath then
            origPlayFile(cachedPath, mode or "", cb)
            return
        end

        lia.websound.register(name, url, function(localPath)
            if localPath then
                origPlayFile(localPath, mode or "", cb)
            elseif cb then
                cb(nil, nil, "failed")
            end
        end)
        return
    end
    return origPlayURL(url, mode, cb)
end

local origSurfacePlaySound = surface.PlaySound
--[[
    Purpose:
        Enhanced version of surface.PlaySound that supports web URLs and websound paths with optional callback support.

    When Called:
        When playing UI sounds or simple audio effects, automatically handling web URLs and cached sounds.

    Parameters:
        soundPath (string)
            The sound file path or URL to play. Supports web URLs and websound paths.
        _ (any)
            Unused parameter (for compatibility with potential future extensions).
        cb (function|nil)
            Optional callback function receiving (success) boolean indicating if playback was successful.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Play UI sound with web URL
            surface.PlaySound("https://example.com/ui_click.wav", nil, function(success)
                if success then
                    print("UI sound played")
                end
            end)

            -- Play cached websound
            surface.PlaySound("websounds/button.wav")
        ```
]]
function surface.PlaySound(soundPath, _, cb)
    if isstring(soundPath) then
        soundPath = normalizeName(soundPath)
        if soundPath:find("^https?://") then
            local name = urlMap[soundPath]
            if not name then
                name = deriveUrlSaveName(soundPath)
                urlMap[soundPath] = name
            end

            local cachedPath = lia.websound.get(name)
            if cachedPath then
                local surfacePath = cachedPath:gsub("^data/", "")
                origSurfacePlaySound(surfacePath)
                if cb then cb(true) end
                return
            end

            lia.websound.register(name, soundPath, function(localPath)
                if localPath then
                    local surfacePath = localPath:gsub("^data/", "")
                    origSurfacePlaySound(surfacePath)
                    if cb then cb(true) end
                elseif cb then
                    cb(false, "failed")
                end
            end)
            return
        else
            local webPath
            if soundPath:find("^lilia/websounds/") then
                webPath = soundPath:gsub("^lilia/websounds/", "")
            elseif soundPath:find("^websounds/") then
                webPath = soundPath:gsub("^websounds/", "")
            else
                webPath = soundPath
            end

            local localPath = lia.websound.get(webPath)
            if localPath then
                local surfacePath = localPath:gsub("^data/", "")
                origSurfacePlaySound(surfacePath)
                if cb then cb(true) end
                return
            else
                local url = lia.websound.stored and lia.websound.stored[webPath]
                if url then
                    lia.websound.register(webPath, url, function(downloadedPath)
                        if downloadedPath then
                            local surfacePath = downloadedPath:gsub("^data/", "")
                            origSurfacePlaySound(surfacePath)
                            if cb then cb(true) end
                        elseif cb then
                            cb(false, "failed")
                        end
                    end)
                    return
                end
            end
        end
    end

    origSurfacePlaySound(soundPath)
    if cb then cb(true) end
end

--[[
    Purpose:
        Provide download statistics for diagnostic interfaces or admin reporting.

    When Called:
        When showing status panels or logging background downloads.

    Parameters:
        None

    Returns:
        table
            `{ downloaded = number, stored = number, lastReset = timestamp }`.

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("PlayerSay", "ReportWebSoundStats", function(ply, text)
                if text ~= "!soundstats" then return end
                local stats = lia.websound.getStats()
                ply:notifyLocalized("webSoundStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
            end)
        ```
]]
function lia.websound.getStats()
    local totalStored = 0
    for _ in pairs(lia.websound.stored) do
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
        Delete all cached web sounds and optionally trigger re-registration.

    When Called:
        During round resets or when you want to force a fresh download of every entry.

    Parameters:
        skipReRegister (boolean)
            If true, registered entries are not re-downloaded automatically.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Force-refresh all cached sounds when admins reload content packs.
            hook.Add("OnConfigReload", "ResetWebSounds", function()
                lia.websound.clearCache(false)
                for name, url in pairs(lia.websound.stored) do
                    lia.websound.download(name, url)
                end
            end)
        ```
]]
function lia.websound.clearCache(skipReRegister)
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
    if not skipReRegister and lia.websound.stored then
        for name, url in pairs(lia.websound.stored) do
            if url then lia.websound.register(name, url) end
        end
    end
end

--[[
    Purpose:
        Play the configured button click sound with optional overrides and fallbacks.

    When Called:
        Whenever a UI element wants to use a consistent button audio cue.

    Parameters:
        customSound (string|nil)
            Optional override path or URL.
        callback (function|nil)
            Receives `(success, errStr)` once playback is attempted.

    Realm:
        Client

    Example Usage:
        ```lua
            -- Use a per-skin override and fall back to the global default.
            local button = vgui.Create("DButton")
            button.DoClick = function()
                lia.websound.playButtonSound("https://assets.example.com/sounds/ui/blue_click.wav", function(success, err)
                    if not success then
                        lia.websound.playButtonSound(nil) -- fallback to default
                    end
                end)
            end
        ```
]]
function lia.websound.playButtonSound(customSound, callback)
    if customSound and customSound ~= "button_click.wav" then
        if customSound:find("^lilia/websounds/") or customSound:find("^websounds/") then
            surface.PlaySound(customSound)
            if callback then callback(true) end
            return
        end

        if customSound:find("^https?://") then
            lia.websound.register(customSound, customSound, function(localPath)
                if localPath then
                    local surfacePath = localPath:gsub("^data/", "")
                    surface.PlaySound(surfacePath)
                    if callback then callback(true) end
                else
                    lia.websound.playButtonSound(nil, callback)
                end
            end)
            return
        end

        surface.PlaySound(customSound)
        if callback then callback(true) end
        return
    end

    local cachedPath = lia.websound.get("button_click.wav")
    if cachedPath then
        sound.PlayFile(cachedPath, "", function() end)
        if callback then callback(true) end
        return
    end

    if not lia.websound.stored["button_click.wav"] then lia.websound.register("button_click.wav", "https://bleonheart.github.io/Samael-Assets/misc/button_click.wav") end
    lia.websound.download("button_click.wav", nil, function(localPath)
        if localPath then
            sound.PlayFile(localPath, "", function() end)
            if callback then callback(true) end
        else
            surface.PlaySound("lilia/websounds/button_click.wav")
            if callback then callback(false) end
        end
    end)
end

lia.websound.register("button_click.wav", "https://bleonheart.github.io/Samael-Assets/misc/button_click.wav")
lia.websound.register("ratio_button.wav", "https://bleonheart.github.io/Samael-Assets/misc/ratio_button.wav")
ensureDir(baseDir)
