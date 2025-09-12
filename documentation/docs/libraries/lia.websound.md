# Web Sound Library

This page documents the functions for working with web sounds and sound downloading.

---

## Overview

The web sound library (`lia.websound`) provides a comprehensive system for downloading, caching, and managing web sounds in the Lilia framework, enabling rich audio content integration from external sources while maintaining optimal performance and audio quality. This library handles sophisticated sound management with support for multiple audio formats, automatic format conversion, and intelligent caching systems that minimize bandwidth usage and loading times while preserving audio fidelity. The system features advanced URL validation with security filtering, content verification, and automatic fallback mechanisms to ensure safe and reliable sound loading from external sources. It includes comprehensive caching functionality with support for local storage, memory management, and automatic cache cleanup to maintain optimal performance even with large audio collections. The library provides robust sound file validation with format checking, quality verification, and integration with Garry's Mod's audio system for seamless sound playback. Additional features include performance monitoring for audio loading operations, error handling with graceful degradation for failed sound loads, and integration with the framework's notification and UI systems for enhanced audio feedback, making it essential for creating immersive audio experiences that complement visual content and enhance overall player engagement.

---

### lia.websound.download

**Purpose**

Downloads a sound file from a URL and caches it locally.

**Parameters**

* `name` (*string*): The name to store the sound under.
* `url` (*string*): The URL to download from (optional if already registered).
* `callback` (*function*): Callback function when download completes.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Download a sound file
local function downloadSound(name, url, callback)
    lia.websound.download(name, url, callback)
end

-- Use in a function
local function loadNotificationSound(callback)
    local url = "https://example.com/sounds/notification.mp3"
    lia.websound.download("notification", url, callback)
end
```

---

### lia.websound.register

**Purpose**

Registers a sound URL and downloads it.

**Parameters**

* `name` (*string*): The name to store the sound under.
* `url` (*string*): The URL to download from.
* `callback` (*function*): Callback function when download completes.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Register a sound
local function registerSound(name, url, callback)
    lia.websound.register(name, url, callback)
end

-- Use in a function
local function setupDefaultSounds()
    lia.websound.register("click", "https://example.com/sounds/click.wav")
    lia.websound.register("hover", "https://example.com/sounds/hover.mp3")
end
```

---

### lia.websound.get

**Purpose**

Gets a cached sound file path by name.

**Parameters**

* `name` (*string*): The name of the sound.

**Returns**

* `path` (*string*): The sound file path or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get cached sound
local function getSound(name)
    return lia.websound.get(name)
end

-- Use in a function
local function playSound(name)
    local path = lia.websound.get(name)
    if path then
        sound.PlayFile(path, "", function(chan)
            if chan then chan:Play() end
        end)
    end
end
```

---

### lia.websound.getStats

**Purpose**

Gets statistics about downloaded sounds.

**Parameters**

*None*

**Returns**

* `stats` (*table*): Table containing download statistics.

**Realm**

Client.

**Example Usage**

```lua
-- Get sound statistics
local function getSoundStats()
    return lia.websound.getStats()
end

-- Use in a function
local function showSoundStats()
    local stats = lia.websound.getStats()
    print("Downloaded sounds: " .. stats.downloaded)
    print("Stored sounds: " .. stats.stored)
    print("Last reset: " .. os.date("%c", stats.lastReset))
end
```
