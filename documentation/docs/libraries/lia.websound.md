# WebSound Library

Web-based audio content downloading, caching, and playback system for the Lilia framework.

---

Overview

The websound library provides comprehensive functionality for managing web-based audio content in the Lilia framework. It handles downloading, caching, validation, and playback of sound files from HTTP/HTTPS URLs, with automatic local storage and retrieval. The library operates on both server and client sides, providing seamless integration with Garry's Mod's sound system through enhanced versions of sound.PlayFile, sound.PlayURL, and surface.PlaySound functions. It includes robust URL validation, file format verification, caching mechanisms, and statistics tracking. The library ensures optimal performance by avoiding redundant downloads and providing fallback mechanisms for failed downloads while maintaining compatibility with existing sound APIs.

---

### download

**Purpose**

Downloads a sound file from a URL and caches it locally for future use

**When Called**

When a sound needs to be downloaded from a web URL, either directly or through other websound functions

**Parameters**

* `name` (*string*): The name/path for the sound file (will be normalized)
* `url` (*string, optional*): The HTTP/HTTPS URL to download from (uses stored URL if not provided)
* `cb` (*function, optional*): Callback function called with (path, fromCache, error) parameters

**Returns**

* None (uses callback for results)

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Download a sound file
lia.websound.download("notification.wav", "https://example.com/sound.wav")

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### register

**Purpose**

Registers a sound file URL for future use and immediately downloads it

**When Called**

When registering a new sound file that should be available for playback

**Parameters**

* `name` (*string*): The name/path for the sound file (will be normalized)
* `url` (*string*): The HTTP/HTTPS URL to download from
* `cb` (*function, optional*): Callback function called with (path, fromCache, error) parameters

**Returns**

* None (uses callback for results)

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register a sound file
lia.websound.register("button_click.wav", "https://example.com/click.wav")

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### get

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

**Returns**

* string or nil - The local file path if found, nil if not cached

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if a sound is cached
local soundPath = lia.websound.get("button_click.wav")
if soundPath then
    -- Sound is available
    else
        -- Sound not cached yet
    end

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.sound.PlayFile

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

**Returns**

* string or nil - The local file path if found, nil if not cached

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if a sound is cached
local soundPath = lia.websound.get("button_click.wav")
if soundPath then
    -- Sound is available
    else
        -- Sound not cached yet
    end

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.sound.PlayURL

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

**Returns**

* string or nil - The local file path if found, nil if not cached

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if a sound is cached
local soundPath = lia.websound.get("button_click.wav")
if soundPath then
    -- Sound is available
    else
        -- Sound not cached yet
    end

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### lia.surface.PlaySound

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

**Returns**

* string or nil - The local file path if found, nil if not cached

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if a sound is cached
local soundPath = lia.websound.get("button_click.wav")
if soundPath then
    -- Sound is available
    else
        -- Sound not cached yet
    end

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### getStats

**Purpose**

Retrieves statistics about downloaded and stored sound files

**When Called**

When monitoring websound library performance or displaying usage statistics

**Returns**

* table - Contains downloaded count, stored count, and last reset timestamp

**Realm**

Client and Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get basic statistics
local stats = lia.websound.getStats()
-- Downloaded sounds: stats.downloaded
-- Stored sounds: stats.stored

```

**Medium Complexity:**
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

**High Complexity:**
```lua
-- High: Monitor statistics with logging and performance tracking
local function monitorWebSoundPerformance()
    local stats = lia.websound.getStats()
    local currentTime = os.time()
    local timeSinceReset = currentTime - stats.lastReset
    -- Log statistics to file
    local logData = {
    timestamp = os.date("%Y-%m-%d %H:%M:%S", currentTime),
    downloaded = stats.downloaded,
    stored = stats.stored,
    timeSinceReset = timeSinceReset,
    downloadRate = timeSinceReset > 0 and (stats.downloaded / timeSinceReset) or 0
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

---

### playButtonSound

**Purpose**

Plays a button click sound with automatic fallback to default button_click.wav

**When Called**

When a button is clicked and needs to play a sound

**Parameters**

* `customSound` (*string, optional*): Custom sound to play instead of default
* `callback` (*function, optional*): Callback function called with (success) parameter

**Returns**

* None (uses callback for results)

**Realm**

Client only

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Play default button sound
lia.websound.playButtonSound()

```

**Medium Complexity:**
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

**High Complexity:**
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

---

