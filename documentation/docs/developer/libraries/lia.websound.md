<style>
details > summary {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 70px;
    padding-right: 180px;
}

details > summary .summary-main {
    min-width: 0;
}

details > summary .source-link-button--summary {
    position: absolute;
    right: 56px;
    top: 50%;
    transform: translateY(-50%);
    white-space: nowrap;
    z-index: 2;
}
</style>

# WebSound

Web sound helpers for registering, downloading, caching, and playing remote audio through Lilia.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The web sound library centralizes clientside handling for remote sound assets under `lia.websound`. It validates HTTP and HTTPS URLs, downloads supported audio files into `data/lilia/websounds/`, reuses valid cached files, maps URLs to local cache names, and wraps Garry's Mod sound playback helpers so registered or remote web sounds can be played through local cached files when possible.
</div>

---

<details class="realm-client" id="function-liawebsounddownload">
<summary><span class="summary-main"><a id="lia.websound.download"></a>lia.websound.download(name, url, cb)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L151" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsounddownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Downloads and caches a remote web sound, using either the provided URL or the URL registered under the sound name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The sound name or cache path relative to `lilia/websounds/`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">url</span> <span class="optional">optional</span> The HTTP or HTTPS URL to download. When nil, the URL registered in `lia.websound.stored[name]` is used.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback called with the local path and cache state on success, or nil, false, and an error message on failure.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.websound.download("effects/click.mp3", "https://example.com/click.mp3", function(path, fromCache, err)
      if path then sound.PlayFile(path, "", function() end) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundregister">
<summary><span class="summary-main"><a id="lia.websound.register"></a>lia.websound.register(name, url, cb)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L256" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a web sound URL under a normalized name and immediately starts downloading it into the local cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The sound name or cache path used to reference the web sound later.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">url</span> The HTTP or HTTPS URL for the sound file.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback passed through to `lia.websound.download`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.websound.register("effects/click.mp3", "https://example.com/click.mp3")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundget">
<summary><span class="summary-main"><a id="lia.websound.get"></a>lia.websound.get(name)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L283" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets the local cached data path for a registered or downloaded web sound when the file is available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The sound name, URL, or cache key to resolve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> The local `data/` path for the cached sound file, or nil when no cached file exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local path = lia.websound.get("effects/click.mp3")
  if path then sound.PlayFile(path, "", function() end) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundgetstats">
<summary><span class="summary-main"><a id="lia.websound.getStats"></a>lia.websound.getStats()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L523" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundgetstats"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns current web sound cache statistics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table containing the number of freshly downloaded sounds, the number of registered stored sounds, and the last reset timestamp.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local stats = lia.websound.getStats()
  print(stats.downloaded, stats.stored, stats.lastReset)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundclearcache">
<summary><span class="summary-main"><a id="lia.websound.clearCache"></a>lia.websound.clearCache(skipReRegister)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L555" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundclearcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Clears the in-memory web sound cache, removes cached web sound files from data storage, and optionally re-registers stored sounds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">skipReRegister</span> <span class="optional">optional</span> When true, stored sounds are not registered again after the cache is cleared.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.websound.clearCache()
  lia.websound.clearCache(true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebsoundplaybuttonsound">
<summary><span class="summary-main"><a id="lia.websound.playButtonSound"></a>lia.websound.playButtonSound(customSound, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L607" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebsoundplaybuttonsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Plays a button sound using a custom sound when provided, otherwise using the cached default web button sound.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">customSound</span> <span class="optional">optional</span> Optional sound path or HTTP/HTTPS URL to play instead of the default button click sound.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional callback called with true when playback was started successfully, or false when the default fallback path was used after a download failure.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.websound.playButtonSound()
  lia.websound.playButtonSound("https://example.com/ui/button.wav", function(success)
      print(success)
  end)
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-client" id="function-websounddownloaded">
<summary><span class="summary-main"><a id="WebSoundDownloaded"></a>WebSoundDownloaded(name, path)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/websound.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="websounddownloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a web sound is freshly downloaded, validated, written to the local data cache, and counted in the web sound statistics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Web Sound</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The normalized web sound name or cache key used for the downloaded sound.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> The local `data/` path for the cached sound file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WebSoundDownloaded", "liaExampleWebSoundDownloaded", function(name, path)
      print("[MyModule] handled WebSoundDownloaded")
  end)
</code></pre>
</div>

</div>
</details>

---

