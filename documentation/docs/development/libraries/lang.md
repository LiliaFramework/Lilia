# Languages

Internationalization (i18n) and localization system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework. It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages with fallback mechanisms. The library automatically loads language files from directories, processes them into a unified storage system, and provides string formatting with parameter substitution. It includes functions for adding custom language tables, retrieving available languages, and getting localized strings with proper error handling. The library operates on both server and client sides, ensuring consistent localization across the entire gamemode. It supports dynamic language switching and provides the global L() function for easy access to localized strings throughout the codebase.
</div>

---

<details class="realm-shared" id="function-lialangloadfromdir">
<summary><a id="lia.lang.loadFromDir"></a>lia.lang.loadFromDir(directory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialangloadfromdir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Load language files from a directory and merge them into storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During startup to load built-in and schema-specific localization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">directory</span> Path containing language Lua files.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Load base languages and a custom pack.
  lia.lang.loadFromDir("lilia/gamemode/languages")
  lia.lang.loadFromDir("schema/languages")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialangaddtable">
<summary><a id="lia.lang.addTable"></a>lia.lang.addTable(name, tbl)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialangaddtable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Merge a table of localized strings into a named language.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When adding runtime localization or extending a language.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Language id (e.g., "english").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tbl</span> Key/value pairs to merge.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.lang.addTable("english", {
      customGreeting = "Hello, %s!",
      adminOnly = "You must be an admin."
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialanggetlanguages">
<summary><a id="lia.lang.getLanguages"></a>lia.lang.getLanguages()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialanggetlanguages"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>List available languages by display name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When populating language selection menus or config options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sorted array of language display names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, langName in ipairs(lia.lang.getLanguages()) do
      print("Language option:", langName)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialanggeneratecachekey">
<summary><a id="lia.lang.generateCacheKey"></a>lia.lang.generateCacheKey(lang, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialanggeneratecachekey"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build a cache key for a localized string with parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before caching formatted localization results.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">lang</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> ... (vararg)</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local cacheKey = lia.lang.generateCacheKey("english", "hello", "John")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialangcleanupcache">
<summary><a id="lia.lang.cleanupCache"></a>lia.lang.cleanupCache()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialangcleanupcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Evict half of the cached localization entries when over capacity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically from getLocalizedString when cache exceeds maxSize.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.lang.cache.currentSize &gt; lia.lang.cache.maxSize then
      lia.lang.cleanupCache()
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialangclearcache">
<summary><a id="lia.lang.clearCache"></a>lia.lang.clearCache()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialangclearcache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reset the localization cache to its initial state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When changing languages or when flushing cached strings.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnConfigUpdated", "ClearLangCache", function(key, old, new)
      if key == "Language" and old ~= new then
          lia.lang.clearCache()
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialanggetlocalizedstring">
<summary><a id="lia.lang.getLocalizedString"></a>lia.lang.getLocalizedString(key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialanggetlocalizedstring"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolve and format a localized string with caching and fallbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Every time L() is used to display text with parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Localization key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Formatted localized string or key when missing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local msg = lia.lang.getLocalizedString("welcomeUser", ply:Name(), os.date())
  chat.AddText(msg)
</code></pre>
</div>

</div>
</details>

---

