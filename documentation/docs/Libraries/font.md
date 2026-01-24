# Font Library

Comprehensive font management system for the Lilia framework.

---

Overview

The font library provides comprehensive functionality for managing custom fonts in the Lilia framework. It handles font registration, loading, and automatic font creation for UI elements throughout the gamemode. The library operates on both server and client sides, with the server storing font metadata and the client handling actual font creation and rendering. It includes automatic font generation for various sizes and styles, dynamic font loading based on configuration, and intelligent font name parsing for automatic font creation. The library ensures consistent typography across all UI elements and provides easy access to predefined font variants for different use cases.

---

<details class="realm-client">
<summary><a id=lia.font.loadFonts></a>lia.font.loadFonts()</summary>
<a id="liafontloadfonts"></a>
<p>Create all registered fonts on the client and count successes/failures.</p>
<p>After registration or config load to ensure fonts exist before drawing.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("RefreshFonts", "ReloadAllFonts", function()
        lia.font.loadFonts()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.font.register></a>lia.font.register(fontName, fontData)</summary>
<a id="liafontregister"></a>
<p>Register a single font definition and create it clientside if possible.</p>
<p>During font setup or dynamically when encountering unknown font names.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fontName</span> Unique font identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">fontData</span> surface.CreateFont data table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.font.register("liaDialogHeader", {
        font = "Montserrat Bold",
        size = 28,
        weight = 800,
        antialias = true
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.font.getAvailableFonts></a>lia.font.getAvailableFonts()</summary>
<a id="liafontgetavailablefonts"></a>
<p>List all registered font identifiers.</p>
<p>Populate dropdowns or config options for font selection.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Sorted array of font names.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, name in ipairs(lia.font.getAvailableFonts()) do
        print("Font:", name)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.font.getBoldFontName></a>lia.font.getBoldFontName(fontName)</summary>
<a id="liafontgetboldfontname"></a>
<p>Convert a base font name to its bold variant.</p>
<p>When auto-registering bold/shadow variants of LiliaFont entries.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fontName</span> Base font name.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Best-effort bold font name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local boldName = lia.font.getBoldFontName("Montserrat Medium")
    lia.font.register("DialogTitle", {font = boldName, size = 26, weight = 800})
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.font.registerFonts></a>lia.font.registerFonts(fontName)</summary>
<a id="liafontregisterfonts"></a>
<p>Register the full suite of Lilia fonts (regular, bold, italic, sizes).</p>
<p>On config load or when switching the base font setting.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fontName</span> <span class="optional">optional</span> Base font name; defaults to config Font.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    concommand.Add("lia_reload_fonts", function()
        local base = lia.config.get("Font", "Montserrat Medium")
        lia.font.registerFonts(base)
        timer.Simple(0.1, lia.font.loadFonts)
    end)
</code></pre>
</details>

---

