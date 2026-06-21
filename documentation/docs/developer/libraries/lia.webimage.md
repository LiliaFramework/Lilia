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

# Web Image

Web image helpers for downloading remote PNG and JPEG assets, caching them under the data folder, resolving registered image names, and allowing Material and DImage to load web-backed images.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The web image library centralizes clientside image loading under `lia.webimage`. It validates HTTP and HTTPS image URLs, downloads supported image formats into `data/lilia/webimages/`, caches built materials, maps URLs to stored image names, and integrates those cached assets with `Material` and `DImage:SetImage`.
</div>

---

<details class="realm-client" id="function-liawebimagedownload">
<summary><span class="summary-main"><a id="lia.webimage.download"></a>lia.webimage.download(n, u, cb, flags)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L109" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimagedownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Downloads a named web image, validates the URL, stores supported PNG or JPEG data under the web image cache folder, builds a material for the saved file, and updates download statistics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> The image cache name or save name to use for the downloaded image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">u</span> <span class="optional">optional</span> The URL to download. When omitted, the URL stored for `n` in `lia.webimage.stored` is used.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback called with the material and cache state on success, or nil, false, and an error message on failure.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags used when building the cached material.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageregister">
<summary><span class="summary-main"><a id="lia.webimage.register"></a>lia.webimage.register(n, u, cb, flags)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L213" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a named web image URL and immediately starts downloading or loading it through the web image cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> The image name used to store and retrieve the web image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">u</span> The HTTP or HTTPS URL for the image.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback passed to `lia.webimage.download`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags saved with the registered image and used when building its material.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageget">
<summary><span class="summary-main"><a id="lia.webimage.get"></a>lia.webimage.get(n, flags)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L240" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a cached material for a registered image name, URL, or saved web image path when the file is already available locally.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> The registered image name, mapped URL, or saved cache path to resolve.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional material flags used when building the material if it is not already cached.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial|nil</a></span> The cached or newly built material when the saved image exists, otherwise nil.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimagegetstats">
<summary><span class="summary-main"><a id="lia.webimage.getStats"></a>lia.webimage.getStats()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L339" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimagegetstats"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns runtime statistics for the web image cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table containing `downloaded`, `stored`, and `lastReset` values.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liawebimageclearcache">
<summary><span class="summary-main"><a id="lia.webimage.clearCache"></a>lia.webimage.clearCache(skipReRegister)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L362" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawebimageclearcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Clears cached materials, URL mappings, and downloaded files from the web image cache folder, then optionally re-registers stored web images.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">skipReRegister</span> <span class="optional">optional</span> Whether to skip re-registering images from `lia.webimage.stored` after clearing cached files.</p>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-client" id="function-webimagedownloaded">
<summary><span class="summary-main"><a id="WebImageDownloaded"></a>WebImageDownloaded(name, path)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/webimage.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="webimagedownloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a web image is successfully downloaded, saved, and built into a material.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The registered image name or derived save name used by the web image cache.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> The data material path for the downloaded image, prefixed with `data/`.</p>
</div>

</div>
</details>

---

