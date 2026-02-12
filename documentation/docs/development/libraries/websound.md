# WebSound

Web-based audio content downloading, caching, and playback system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The websound library provides comprehensive functionality for managing web-based audio content in the Lilia framework. It handles downloading, caching, validation, and playback of sound files from HTTP/HTTPS URLs, with automatic local storage and retrieval. The library operates on both server and client sides, providing seamless integration with Garry's Mod's sound system through enhanced versions of sound.PlayFile, sound.PlayURL, and surface.PlaySound functions. It includes robust URL validation, file format verification, caching mechanisms, and statistics tracking. The library ensures optimal performance by avoiding redundant downloads and providing fallback mechanisms for failed downloads while maintaining compatibility with existing sound APIs.
</div>

---

<details class="realm-client" id="function-liawebsounddownload">
<summary><a id="lia.websound.download"></a>lia.websound.download(name, url, cb)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsounddownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Download or reuse a cached web sound by name, running a callback with the local file path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever a module needs to ensure a URL-based sound exists before playback, especially during initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The logical name for this sound; normalized before saving.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">url</span> <span class="optional">optional</span> Optional override URL; falls back to previously registered URLs.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Completion callback that receives (path, fromCache, error).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Preload multiple tracks in sequence, falling back to cached copies.
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
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundregister">
<summary><a id="lia.websound.register"></a>lia.websound.register(name, url, cb)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a named URL so future calls can rely on a cached entry and optionally download it immediately.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During gamemode setup when you want to associate a friendly key with a remote sound asset.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Logical identifier used for caching and later lookup.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">url</span> HTTP/HTTPS link pointing to the desired sound file.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback same as `download`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string? Returns the cached path if already downloaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostGamemodeLoaded", "RegisterUIAudio", function()
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
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundget">
<summary><a id="lia.websound.get"></a>lia.websound.get(name)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lookup the cached filesystem path for a registered web sound when you need to play it immediately.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Within any playback logic that wants to skip downloading and use an already fetched file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The normalized identifier previously registered or downloaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Local `data/` path to the sound file, or `nil` if not downloaded yet.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Play from cache or queue a download with a one-time completion hook.
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
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundgetstats">
<summary><a id="lia.websound.getStats"></a>lia.websound.getStats()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundgetstats"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide download statistics for diagnostic interfaces or admin reporting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When showing status panels or logging background downloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> `{ downloaded = number, stored = number, lastReset = timestamp }`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerSay", "ReportWebSoundStats", function(ply, text)
      if text ~= "!soundstats" then return end
      local stats = lia.websound.getStats()
      ply:notifyLocalized("webSoundStats", stats.downloaded, stats.stored, os.date("%c", stats.lastReset))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundclearcache">
<summary><a id="lia.websound.clearCache"></a>lia.websound.clearCache(skipReRegister)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundclearcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Delete all cached web sounds and optionally trigger re-registration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During round resets or when you want to force a fresh download of every entry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">skipReRegister</span> If true, registered entries are not re-downloaded automatically.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Force-refresh all cached sounds when admins reload content packs.
  hook.Add("OnConfigReload", "ResetWebSounds", function()
      lia.websound.clearCache(false)
      for name, url in pairs(lia.websound.stored) do
          lia.websound.download(name, url)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundplaybuttonsound">
<summary><a id="lia.websound.playButtonSound"></a>lia.websound.playButtonSound(customSound, callback)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundplaybuttonsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Play the configured button click sound with optional overrides and fallbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever a UI element wants to use a consistent button audio cue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">customSound</span> <span class="optional">optional</span> Optional override path or URL.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Receives `(success, errStr)` once playback is attempted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Use a per-skin override and fall back to the global default.
  local button = vgui.Create("DButton")
  button.DoClick = function()
      lia.websound.playButtonSound("https://assets.example.com/sounds/ui/blue_click.wav", function(success, err)
          if not success then
              lia.websound.playButtonSound(nil) -- fallback to default
          end
      end)
  end
</code></pre>
</div>

</div>
</details>

---

