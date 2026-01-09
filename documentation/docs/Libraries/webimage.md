# Web Image Library

Web-based image downloading, caching, and management system for the Lilia framework.

---

Overview

The web image library provides comprehensive functionality for downloading, caching, and managing web-based images in the Lilia framework. It handles automatic downloading of images from URLs, local caching to improve performance, and seamless integration with Garry's Mod's material system. The library operates on both server and client sides, with intelligent caching mechanisms that prevent redundant downloads and ensure images are available offline after initial download. It includes URL validation, file format detection, and automatic directory management for organized storage. The library also provides hooks for download events and statistics tracking. Images are stored in the data/lilia/webimages/ directory and can be accessed through various path formats for maximum compatibility with existing code.

---

### lia.webimage.download

#### 📋 Purpose
Ensure a remote image is downloaded, validated, and made available as a `Material`.

#### ⏰ When Called
During UI setup when an image asset must be cached before drawing panels.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `n` | **string** | Logical storage name for the downloaded image. |
| `u` | **string|nil** | Optional override URL; uses registered `stored` entry otherwise. |
| `cb` | **function|nil** | Callback receiving `(material, fromCache, errStr)`. |
| `flags` | **string|nil** | Optional material flags for creation (e.g., `"noclamp smooth"`). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.webimage.register

#### 📋 Purpose
Cache metadata for a URL and optionally download it immediately.

#### ⏰ When Called
At startup when the gamemode wants to pre-register UI imagery.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `n` | **string** | Internal key used to store and retrieve the image. |
| `u` | **string** | The HTTP/HTTPS source URL. |
| `cb` | **function|nil** | Optional callback forwarded to `download`. |
| `flags` | **string|nil** | Material creation flags stored for future lookups. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.webimage.get

#### 📋 Purpose
Retrieve a previously cached `Material` for immediate drawing.

#### ⏰ When Called
Within paint hooks or derma code that needs a cached texture without triggering a download.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `n` | **string** | The registered name or derived key. |
| `flags` | **string|nil** | Optional material flags used to rebuild the material when missing. |

#### ↩️ Returns
* Material|nil
The cached material or `nil` if it isn't downloaded yet.

#### 🌐 Realm
Client

#### 💡 Example Usage

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

---

### lia.webimage.getStats

#### 📋 Purpose
Expose download statistics to aid diagnostics or admin tooling.

#### ⏰ When Called
When reporting the number of cached images or implementing cache health checks.

#### ↩️ Returns
* table
`{ downloaded = number, stored = number, lastReset = timestamp }`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PlayerSay", "PrintWebImageStats", function(ply, text)
        if text ~= "!imagecache" then return end
        local stats = lia.webimage.getStats()
        ply:notifyLocalized("webImageStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
    end)

```

---

### lia.webimage.clearCache

#### 📋 Purpose
Evict all downloaded web images, resetting the material cache.

#### ⏰ When Called
During configuration reloads or when manual cache management is required.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `skipReRegister` | **boolean** | When true, previously registered URLs are not re-downloaded. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Drop and re-download web images after admins push new branding.
    hook.Add("OnConfigReload", "RebuildWebImageCache", function()
        lia.webimage.clearCache(false)
        for name, data in pairs(lia.webimage.stored) do
            lia.webimage.download(name, data.url, nil, data.flags)
        end
    end)

```

---

