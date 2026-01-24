# Languages Library

Internationalization (i18n) and localization system for the Lilia framework.

---

Overview

The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework. It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages with fallback mechanisms. The library automatically loads language files from directories, processes them into a unified storage system, and provides string formatting with parameter substitution. It includes functions for adding custom language tables, retrieving available languages, and getting localized strings with proper error handling. The library operates on both server and client sides, ensuring consistent localization across the entire gamemode. It supports dynamic language switching and provides the global L() function for easy access to localized strings throughout the codebase.

---

<details class="realm-shared">
<summary><a id=lia.lang.loadFromDir></a>lia.lang.loadFromDir(directory)</summary>
<a id="lialangloadfromdir"></a>
<p>Load language files from a directory and merge them into storage.</p>
<p>During startup to load built-in and schema-specific localization.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">directory</span> Path containing language Lua files.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load base languages and a custom pack.
    lia.lang.loadFromDir("lilia/gamemode/languages")
    lia.lang.loadFromDir("schema/languages")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.addTable></a>lia.lang.addTable(name, tbl)</summary>
<a id="lialangaddtable"></a>
<p>Merge a table of localized strings into a named language.</p>
<p>When adding runtime localization or extending a language.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Language id (e.g., "english").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tbl</span> Key/value pairs to merge.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.lang.addTable("english", {
        customGreeting = "Hello, %s!",
        adminOnly = "You must be an admin."
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.getLanguages></a>lia.lang.getLanguages()</summary>
<a id="lialanggetlanguages"></a>
<p>List available languages by display name.</p>
<p>When populating language selection menus or config options.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Sorted array of language display names.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, langName in ipairs(lia.lang.getLanguages()) do
        print("Language option:", langName)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.generateCacheKey></a>lia.lang.generateCacheKey(lang, key)</summary>
<a id="lialanggeneratecachekey"></a>
<p>Build a cache key for a localized string with parameters.</p>
<p>Before caching formatted localization results.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">lang</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> ... (vararg)</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cacheKey = lia.lang.generateCacheKey("english", "hello", "John")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.cleanupCache></a>lia.lang.cleanupCache()</summary>
<a id="lialangcleanupcache"></a>
<p>Evict half of the cached localization entries when over capacity.</p>
<p>Automatically from getLocalizedString when cache exceeds maxSize.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.lang.cache.currentSize &gt; lia.lang.cache.maxSize then
        lia.lang.cleanupCache()
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.clearCache></a>lia.lang.clearCache()</summary>
<a id="lialangclearcache"></a>
<p>Reset the localization cache to its initial state.</p>
<p>When changing languages or when flushing cached strings.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnConfigUpdated", "ClearLangCache", function(key, old, new)
        if key == "Language" and old ~= new then
            lia.lang.clearCache()
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.lang.getLocalizedString></a>lia.lang.getLocalizedString(key)</summary>
<a id="lialanggetlocalizedstring"></a>
<p>Resolve and format a localized string with caching and fallbacks.</p>
<p>Every time L() is used to display text with parameters.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Formatted localized string or key when missing.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local msg = lia.lang.getLocalizedString("welcomeUser", ply:Name(), os.date())
    chat.AddText(msg)
</code></pre>
</details>

---

