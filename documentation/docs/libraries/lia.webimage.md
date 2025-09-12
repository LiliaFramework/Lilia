# Web Image Library

This page documents the functions for working with web images and image downloading.

---

## Overview

The web image library (`lia.webimage`) provides a comprehensive system for downloading, caching, and managing web images in the Lilia framework, enabling rich visual content integration from external sources while maintaining optimal performance and reliability. This library handles sophisticated image management with support for multiple image formats, automatic format conversion, and intelligent caching systems that minimize bandwidth usage and loading times. The system features advanced URL validation with security filtering, content verification, and automatic fallback mechanisms to ensure safe and reliable image loading from external sources. It includes comprehensive caching functionality with support for local storage, memory management, and automatic cache cleanup to maintain optimal performance even with large image collections. The library provides robust material creation with support for various texture formats, automatic scaling, and integration with Garry's Mod's rendering system for seamless image display. Additional features include VGUI integration for UI elements, performance monitoring for image loading operations, and error handling with graceful degradation for failed image loads, making it essential for creating visually rich interfaces and content that enhances the overall player experience while maintaining system stability and performance.

---

### lia.webimage.download

**Purpose**

Downloads an image from a URL and caches it locally.

**Parameters**

* `name` (*string*): The name to store the image under.
* `url` (*string*): The URL to download from (optional if already registered).
* `callback` (*function*): Callback function when download completes.
* `flags` (*string*): Material flags for the image.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Download an image
local function downloadImage(name, url, callback, flags)
    lia.webimage.download(name, url, callback, flags)
end

-- Use in a function
local function loadPlayerAvatar(playerID, callback)
    local url = "https://example.com/avatars/" .. playerID .. ".png"
    lia.webimage.download("avatar_" .. playerID, url, callback)
end
```

---

### lia.webimage.register

**Purpose**

Registers an image URL and downloads it.

**Parameters**

* `name` (*string*): The name to store the image under.
* `url` (*string*): The URL to download from.
* `callback` (*function*): Callback function when download completes.
* `flags` (*string*): Material flags for the image.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Register an image
local function registerImage(name, url, callback, flags)
    lia.webimage.register(name, url, callback, flags)
end

-- Use in a function
local function setupDefaultImages()
    lia.webimage.register("logo", "https://example.com/logo.png")
    lia.webimage.register("background", "https://example.com/bg.jpg", nil, "noclamp smooth")
end
```

---

### lia.webimage.get

**Purpose**

Gets a cached image material by name.

**Parameters**

* `name` (*string*): The name of the image.
* `flags` (*string*): Material flags for the image.

**Returns**

* `material` (*Material*): The material or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get cached image
local function getImage(name, flags)
    return lia.webimage.get(name, flags)
end

-- Use in a function
local function drawImage(name, x, y, width, height)
    local material = lia.webimage.get(name)
    if material then
        surface.SetMaterial(material)
        surface.DrawTexturedRect(x, y, width, height)
    end
end
```

---

### lia.webimage.getStats

**Purpose**

Gets statistics about downloaded images.

**Parameters**

*None*

**Returns**

* `stats` (*table*): Table containing download statistics.

**Realm**

Client.

**Example Usage**

```lua
-- Get image statistics
local function getImageStats()
    return lia.webimage.getStats()
end

-- Use in a function
local function showImageStats()
    local stats = lia.webimage.getStats()
    print("Downloaded images: " .. stats.downloaded)
    print("Stored images: " .. stats.stored)
    print("Last reset: " .. os.date("%c", stats.lastReset))
end
```
