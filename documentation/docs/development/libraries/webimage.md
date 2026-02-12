# Web Image

Web-based image downloading, caching, and management system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The web image library provides comprehensive functionality for downloading, caching, and managing web-based images in the Lilia framework. It handles automatic downloading of images from URLs, local caching to improve performance, and seamless integration with Garry's Mod's material system. The library operates on both server and client sides, with intelligent caching mechanisms that prevent redundant downloads and ensure images are available offline after initial download. It includes URL validation, file format detection, and automatic directory management for organized storage. The library also provides hooks for download events and statistics tracking. Images are stored in the data/lilia/webimages/ directory and can be accessed through various path formats for maximum compatibility with existing code.
</div>

---

<details class="realm-client" id="function-liawebimagedownload">
<summary><a id="lia.webimage.download"></a>lia.webimage.download(n, u, cb, flags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimagedownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Ensure a remote image is downloaded, validated, and made available as a `Material`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During UI setup when an image asset must be cached before drawing panels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> Logical storage name for the downloaded image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">u</span> <span class="optional">optional</span> Optional override URL; uses registered `stored` entry otherwise.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Callback receiving `(material, fromCache, errStr)`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags for creation (e.g., `"noclamp smooth"`).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Preload multiple HUD icons, then draw them when ready.
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
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageregister">
<summary><a id="lia.webimage.register"></a>lia.webimage.register(n, u, cb, flags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Cache metadata for a URL and optionally download it immediately.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At startup when the gamemode wants to pre-register UI imagery.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> Internal key used to store and retrieve the image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">u</span> The HTTP/HTTPS source URL.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback forwarded to `download`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Material creation flags stored for future lookups.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GamemodeLoaded", "RegisterIconLibrary", function()
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
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageget">
<summary><a id="lia.webimage.get"></a>lia.webimage.get(n, flags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieve a previously cached `Material` for immediate drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Within paint hooks or derma code that needs a cached texture without triggering a download.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> The registered name or derived key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags used to rebuild the material when missing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Material">Material|nil</a></span> The cached material or `nil` if it isn't downloaded yet.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Render cached image if available, otherwise queue download and retry.
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
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimagegetstats">
<summary><a id="lia.webimage.getStats"></a>lia.webimage.getStats()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimagegetstats"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Expose download statistics to aid diagnostics or admin tooling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When reporting the number of cached images or implementing cache health checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> `{ downloaded = number, stored = number, lastReset = timestamp }`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerSay", "PrintWebImageStats", function(ply, text)
      if text ~= "!imagecache" then return end
      local stats = lia.webimage.getStats()
      ply:notifyLocalized("webImageStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageclearcache">
<summary><a id="lia.webimage.clearCache"></a>lia.webimage.clearCache(skipReRegister)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageclearcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Evict all downloaded web images, resetting the material cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During configuration reloads or when manual cache management is required.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">skipReRegister</span> When true, previously registered URLs are not re-downloaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Drop and re-download web images after admins push new branding.
  hook.Add("OnConfigReload", "RebuildWebImageCache", function()
      lia.webimage.clearCache(false)
      for name, data in pairs(lia.webimage.stored) do
          lia.webimage.download(name, data.url, nil, data.flags)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

