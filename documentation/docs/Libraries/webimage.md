# Web Image Library

Web-based image downloading, caching, and management system for the Lilia framework.

---

Overview

The web image library provides comprehensive functionality for downloading, caching, and managing web-based images in the Lilia framework. It handles automatic downloading of images from URLs, local caching to improve performance, and seamless integration with Garry's Mod's material system. The library operates on both server and client sides, with intelligent caching mechanisms that prevent redundant downloads and ensure images are available offline after initial download. It includes URL validation, file format detection, and automatic directory management for organized storage. The library also provides hooks for download events and statistics tracking. Images are stored in the data/lilia/webimages/ directory and can be accessed through various path formats for maximum compatibility with existing code.

---

<details class="realm-client">
<summary><a id=lia.webimage.download></a>lia.webimage.download(n, u, cb, flags)</summary>
<a id="liawebimagedownload"></a>
<p>Ensure a remote image is downloaded, validated, and made available as a `Material`.</p>
<p>During UI setup when an image asset must be cached before drawing panels.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">n</span> Logical storage name for the downloaded image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">u</span> <span class="optional">optional</span> Optional override URL; uses registered `stored` entry otherwise.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Callback receiving `(material, fromCache, errStr)`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags for creation (e.g., `"noclamp smooth"`).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Preload multiple HUD icons, then draw them when ready.
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
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.webimage.register></a>lia.webimage.register(n, u, cb, flags)</summary>
<a id="liawebimageregister"></a>
<p>Cache metadata for a URL and optionally download it immediately.</p>
<p>At startup when the gamemode wants to pre-register UI imagery.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">n</span> Internal key used to store and retrieve the image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">u</span> The HTTP/HTTPS source URL.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback forwarded to `download`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Material creation flags stored for future lookups.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GamemodeLoaded", "RegisterIconLibrary", function()
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
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.webimage.get></a>lia.webimage.get(n, flags)</summary>
<a id="liawebimageget"></a>
<p>Retrieve a previously cached `Material` for immediate drawing.</p>
<p>Within paint hooks or derma code that needs a cached texture without triggering a download.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">n</span> The registered name or derived key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags used to rebuild the material when missing.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Material">Material|nil</a></span> The cached material or `nil` if it isn't downloaded yet.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Render cached image if available, otherwise queue download and retry.
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
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.webimage.getStats></a>lia.webimage.getStats()</summary>
<a id="liawebimagegetstats"></a>
<p>Expose download statistics to aid diagnostics or admin tooling.</p>
<p>When reporting the number of cached images or implementing cache health checks.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> `{ downloaded = number, stored = number, lastReset = timestamp }`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerSay", "PrintWebImageStats", function(ply, text)
        if text ~= "!imagecache" then return end
        local stats = lia.webimage.getStats()
        ply:notifyLocalized("webImageStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.webimage.clearCache></a>lia.webimage.clearCache(skipReRegister)</summary>
<a id="liawebimageclearcache"></a>
<p>Evict all downloaded web images, resetting the material cache.</p>
<p>During configuration reloads or when manual cache management is required.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">skipReRegister</span> When true, previously registered URLs are not re-downloaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Drop and re-download web images after admins push new branding.
    hook.Add("OnConfigReload", "RebuildWebImageCache", function()
        lia.webimage.clearCache(false)
        for name, data in pairs(lia.webimage.stored) do
            lia.webimage.download(name, data.url, nil, data.flags)
        end
    end)
</code></pre>
</details>

---

