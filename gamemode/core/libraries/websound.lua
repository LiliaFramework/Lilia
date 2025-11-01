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

local function normalizeName(name)
    if not isstring(name) then return name end
    name = name:gsub("\\", "/")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if string.StartWith(name, "/") then name = name:sub(2) end
    if string.StartWith(name, "sound/") then name = name:sub(7) end
    return name
end

local function deriveUrlSaveName(url)
    local filename = url:match("([^/]+)$") or util.CRC(url) .. ".mp3"
    if file.Exists(baseDir .. filename, "DATA") then return filename end
    local path = url:match("^https?://[^/]+/(.+)$") or filename
    if path:find("/") then path = path:gsub("^[^/]+/", "", 1) end
    return "urlsounds/" .. path
end

local function ensureDir(p)
    local parts = string.Explode("/", p)
    local cur = ""
    for _, v in ipairs(parts) do
        cur = cur == "" and v or cur .. "/" .. v
        if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
    end
end

local function buildPath(p)
    return "data/" .. p
end

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

--[[
    Purpose:
        Downloads a sound file from a URL and caches it locally for future use

    When Called:
        When a sound needs to be downloaded from a web URL, either directly or through other websound functions

    Parameters:
        - name (string): The name/path for the sound file (will be normalized)
        - url (string, optional): The HTTP/HTTPS URL to download from (uses stored URL if not provided)
        - cb (function, optional): Callback function called with (path, fromCache, error) parameters

    Returns:
        None (uses callback for results)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Download a sound file
        lia.websound.download("notification.wav", "https://example.com/sound.wav")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Download with callback handling
        lia.websound.download("alert.mp3", "https://example.com/alert.mp3", function(path, fromCache, error)
            if path then
                -- Sound downloaded successfully
                if fromCache then
                    -- Loaded from cache
                end
            else
                -- Download failed
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Batch download with validation and error handling
        local sounds = {
            {name = "ui/click.wav", url = "https://cdn.example.com/ui/click.wav"},
            {name = "ui/hover.wav", url = "https://cdn.example.com/ui/hover.wav"},
            {name = "ui/error.wav", url = "https://cdn.example.com/ui/error.wav"}
        }

        local downloadCount = 0
        local totalSounds = #sounds

        for _, soundData in ipairs(sounds) do
            lia.websound.download(soundData.name, soundData.url, function(path, fromCache, error)
                downloadCount = downloadCount + 1
                if path then
                    -- Downloaded sound
                else
                    -- Failed to download sound
                end

                if downloadCount == totalSounds then
                    -- All sounds processed
                end
            end)
        end
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
        Registers a sound file URL for future use and immediately downloads it

    When Called:
        When registering a new sound file that should be available for playback

    Parameters:
        - name (string): The name/path for the sound file (will be normalized)
        - url (string): The HTTP/HTTPS URL to download from
        - cb (function, optional): Callback function called with (path, fromCache, error) parameters

    Returns:
        None (uses callback for results)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register a sound file
        lia.websound.register("button_click.wav", "https://example.com/click.wav")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register with callback and error handling
        lia.websound.register("notification.mp3", "https://cdn.example.com/notify.mp3", function(path, fromCache, error)
            if path then
                -- Sound registered and downloaded
                -- Sound is now available for playback
            else
                -- Failed to register sound
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Register multiple sounds with validation and progress tracking
        local soundRegistry = {
            ui = {
                {name = "ui/click.wav", url = "https://cdn.example.com/ui/click.wav"},
                {name = "ui/hover.wav", url = "https://cdn.example.com/ui/hover.wav"},
                {name = "ui/error.wav", url = "https://cdn.example.com/ui/error.wav"}
            },
            ambient = {
                {name = "ambient/rain.mp3", url = "https://cdn.example.com/ambient/rain.mp3"},
                {name = "ambient/wind.mp3", url = "https://cdn.example.com/ambient/wind.mp3"}
            }
        }

        local registeredCount = 0
        local totalSounds = 0
        for category, sounds in pairs(soundRegistry) do
            totalSounds = totalSounds + #sounds
        end

        for category, sounds in pairs(soundRegistry) do
            for _, soundData in ipairs(sounds) do
                lia.websound.register(soundData.name, soundData.url, function(path, fromCache, error)
                    registeredCount = registeredCount + 1
                    if path then
                        -- Registered sound
                    else
                        -- Failed to register sound
                    end

                    if registeredCount == totalSounds then
                        -- All sounds registered successfully
                    end
                end)
            end
        end
        ```
]]
function lia.websound.register(name, url, cb)
    name = normalizeName(name)
    lia.websound.stored[name] = url
    return lia.websound.download(name, url, cb)
end

--[[
    Purpose:
        Retrieves the local file path of a cached sound file

    When Called:
        When checking if a sound file is available locally or getting its path for playback

    Parameters:
        - name (string): The name/path of the sound file to retrieve (will be normalized)

    Returns:
        string or nil - The local file path if found, nil if not cached

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if a sound is cached
        local soundPath = lia.websound.get("button_click.wav")
        if soundPath then
            -- Sound is available
        else
            -- Sound not cached yet
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get sound path with fallback handling
        local function playSoundIfAvailable(soundName)
            local soundPath = lia.websound.get(soundName)
            if soundPath then
                sound.PlayFile(soundPath)
                return true
            else
                -- Sound not available locally
                return false
            end
        end

        -- Usage
        if not playSoundIfAvailable("notification.wav") then
            -- Fallback to default sound or download
            lia.websound.register("notification.wav", "https://example.com/notify.wav")
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch check multiple sounds with availability tracking
        local requiredSounds = {
            "ui/click.wav",
            "ui/hover.wav",
            "ui/error.wav",
            "ambient/rain.mp3",
            "ambient/wind.mp3"
        }

        local availableSounds = {}
        local missingSounds = {}

        for _, soundName in ipairs(requiredSounds) do
            local soundPath = lia.websound.get(soundName)
            if soundPath then
                availableSounds[soundName] = soundPath
                -- Sound available
            else
                table.insert(missingSounds, soundName)
                -- Sound not cached
            end
        end

        if #missingSounds > 0 then
            -- Missing sounds, downloading...
            for _, soundName in ipairs(missingSounds) do
                lia.websound.register(soundName, "https://cdn.example.com/" .. soundName)
            end
        else
            -- All required sounds are available!
        end
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
        Retrieves statistics about downloaded and stored sound files

    When Called:
        When monitoring websound library performance or displaying usage statistics

    Parameters:
        None

    Returns:
        table - Contains downloaded count, stored count, and last reset timestamp

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get basic statistics
        local stats = lia.websound.getStats()
        -- Downloaded sounds: stats.downloaded
        -- Stored sounds: stats.stored
        ```

    Medium Complexity:
        ```lua
        -- Medium: Display formatted statistics with timestamp
        local function displayWebSoundStats()
            local stats = lia.websound.getStats()
            local resetTime = os.date("%Y-%m-%d %H:%M:%S", stats.lastReset)

            -- WebSound Statistics
            -- Downloaded sounds: stats.downloaded
            -- Stored sounds: stats.stored
            -- Last reset: resetTime
        end

        displayWebSoundStats()
        ```

    High Complexity:
        ```lua
        -- High: Monitor statistics with logging and performance tracking
        local function monitorWebSoundPerformance()
            local stats = lia.websound.getStats()
            local currentTime = os.time()
            local timeSinceReset = currentTime - stats.lastReset

            -- Log statistics to file
            local logData = {
                timestamp       = os.date("%Y-%m-%d %H:%M:%S", currentTime),
                downloaded      = stats.downloaded,
                stored          = stats.stored,
                timeSinceReset  = timeSinceReset,
                downloadRate    = timeSinceReset > 0 and (stats.downloaded / timeSinceReset) or 0
            }

            -- Save to file
            file.Write("websound_stats.json", util.TableToJSON(logData, true))

            -- Display performance metrics
            -- WebSound Performance Report
            -- Downloads: stats.downloaded sounds
            -- Storage: stats.stored registered sounds
            -- Uptime: timeSinceReset seconds
            -- Download rate: logData.downloadRate sounds/second

            -- Performance warnings
            if stats.downloaded > 100 then
                -- WARNING: High download count detected!
            end

            if timeSinceReset > 3600 and stats.downloaded == 0 then
                -- INFO: No downloads in the last hour
            end
        end

        -- Run monitoring every 5 minutes
        timer.Create("WebSoundMonitor", 300, 0, monitorWebSoundPerformance)
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
        Plays a button click sound with automatic fallback to default button_click.wav

    When Called:
        When a button is clicked and needs to play a sound

    Parameters:
        - customSound (string, optional): Custom sound to play instead of default
        - callback (function, optional): Callback function called with (success) parameter

    Returns:
        None (uses callback for results)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Play default button sound
        lia.websound.playButtonSound()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Play custom sound with fallback
        lia.websound.playButtonSound("custom_click.wav", function(success)
            if success then
                -- Button sound played successfully
            else
                -- Failed to play button sound
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Conditional button sounds with error handling
        local function handleButtonClick(buttonType, customSound)
            local soundToPlay = customSound or "button_click.wav"

            lia.websound.playButtonSound(soundToPlay, function(success)
                if success then
                    -- Played sound for button
                else
                    -- Failed to play sound, using default
                    -- Fallback to default
                    lia.websound.playButtonSound()
                end
            end)
        end

        -- Usage
        handleButtonClick("primary", "primary_click.wav")
        handleButtonClick("secondary") -- Will use default
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