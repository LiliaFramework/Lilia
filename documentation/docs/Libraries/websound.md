# WebSound Library

Web-based audio content downloading, caching, and playback system for the Lilia framework.

---

Overview

The websound library provides comprehensive functionality for managing web-based audio content in the Lilia framework. It handles downloading, caching, validation, and playback of sound files from HTTP/HTTPS URLs, with automatic local storage and retrieval. The library operates on both server and client sides, providing seamless integration with Garry's Mod's sound system through enhanced versions of sound.PlayFile, sound.PlayURL, and surface.PlaySound functions. It includes robust URL validation, file format verification, caching mechanisms, and statistics tracking. The library ensures optimal performance by avoiding redundant downloads and providing fallback mechanisms for failed downloads while maintaining compatibility with existing sound APIs.

---

### lia.websound.download

#### 📋 Purpose
Download or reuse a cached web sound by name, running a callback with the local file path.

#### ⏰ When Called
Whenever a module needs to ensure a URL-based sound exists before playback, especially during initialization.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The logical name for this sound; normalized before saving. |
| `url` | **string|nil** | Optional override URL; falls back to previously registered URLs. |
| `cb` | **function|nil** | Completion callback that receives (path, fromCache, error). |

#### ↩️ Returns
* nil
Nothing.

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.websound.register

#### 📋 Purpose
Register a named URL so future calls can rely on a cached entry and optionally download it immediately.

#### ⏰ When Called
During gamemode setup when you want to associate a friendly key with a remote sound asset.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Logical identifier used for caching and later lookup. |
| `url` | **string** | HTTP/HTTPS link pointing to the desired sound file. |
| `cb` | **function|nil** | Optional callback same as `download`. |

#### ↩️ Returns
* string?
Returns the cached path if already downloaded.

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.websound.get

#### 📋 Purpose
Lookup the cached filesystem path for a registered web sound when you need to play it immediately.

#### ⏰ When Called
Within any playback logic that wants to skip downloading and use an already fetched file.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The normalized identifier previously registered or downloaded. |

#### ↩️ Returns
* string|nil
Local `data/` path to the sound file, or `nil` if not downloaded yet.

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.websound.getStats

#### 📋 Purpose
Provide download statistics for diagnostic interfaces or admin reporting.

#### ⏰ When Called
When showing status panels or logging background downloads.

#### ↩️ Returns
* table
`{ downloaded = number, stored = number, lastReset = timestamp }`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PlayerSay", "ReportWebSoundStats", function(ply, text)
        if text ~= "!soundstats" then return end
        local stats = lia.websound.getStats()
        ply:notifyLocalized("webSoundStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
    end)

```

---

### lia.websound.clearCache

#### 📋 Purpose
Delete all cached web sounds and optionally trigger re-registration.

#### ⏰ When Called
During round resets or when you want to force a fresh download of every entry.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `skipReRegister` | **boolean** | If true, registered entries are not re-downloaded automatically. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Force-refresh all cached sounds when admins reload content packs.
    hook.Add("OnConfigReload", "ResetWebSounds", function()
        lia.websound.clearCache(false)
        for name, url in pairs(lia.websound.stored) do
            lia.websound.download(name, url)
        end
    end)

```

---

### lia.websound.playButtonSound

#### 📋 Purpose
Play the configured button click sound with optional overrides and fallbacks.

#### ⏰ When Called
Whenever a UI element wants to use a consistent button audio cue.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `customSound` | **string|nil** | Optional override path or URL. |
| `callback` | **function|nil** | Receives `(success, errStr)` once playback is attempted. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

