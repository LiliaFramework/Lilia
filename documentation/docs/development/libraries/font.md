# Font

Comprehensive font management system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The font library provides comprehensive functionality for managing custom fonts in the Lilia framework. It handles font registration, loading, and automatic font creation for UI elements throughout the gamemode. The library operates on both server and client sides, with the server storing font metadata and the client handling actual font creation and rendering. It includes automatic font generation for various sizes and styles, dynamic font loading based on configuration, and intelligent font name parsing for automatic font creation. The library ensures consistent typography across all UI elements and provides easy access to predefined font variants for different use cases.
</div>

---

<details class="realm-client" id="function-liafontloadfonts">
<summary><a id="lia.font.loadFonts"></a>lia.font.loadFonts()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafontloadfonts"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Create all registered fonts on the client and count successes/failures.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After registration or config load to ensure fonts exist before drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RefreshFonts", "ReloadAllFonts", function()
      lia.font.loadFonts()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafontregister">
<summary><a id="lia.font.register"></a>lia.font.register(fontName, fontData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafontregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a single font definition and create it clientside if possible.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During font setup or dynamically when encountering unknown font names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fontName</span> Unique font identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">fontData</span> surface.CreateFont data table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.font.register("liaDialogHeader", {
      font = "Montserrat Bold",
      size = 28,
      weight = 800,
      antialias = true
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafontgetavailablefonts">
<summary><a id="lia.font.getAvailableFonts"></a>lia.font.getAvailableFonts()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafontgetavailablefonts"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>List all registered font identifiers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate dropdowns or config options for font selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sorted array of font names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, name in ipairs(lia.font.getAvailableFonts()) do
      print("Font:", name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafontgetboldfontname">
<summary><a id="lia.font.getBoldFontName"></a>lia.font.getBoldFontName(fontName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafontgetboldfontname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Convert a base font name to its bold variant.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When auto-registering bold/shadow variants of LiliaFont entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fontName</span> Base font name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Best-effort bold font name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local boldName = lia.font.getBoldFontName("Montserrat Medium")
  lia.font.register("DialogTitle", {font = boldName, size = 26, weight = 800})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafontregisterfonts">
<summary><a id="lia.font.registerFonts"></a>lia.font.registerFonts(fontName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafontregisterfonts"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register the full suite of Lilia fonts (regular, bold, italic, sizes).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On config load or when switching the base font setting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fontName</span> <span class="optional">optional</span> Base font name; defaults to config Font.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  concommand.Add("lia_reload_fonts", function()
      local base = lia.config.get("Font", "Montserrat Medium")
      lia.font.registerFonts(base)
      timer.Simple(0.1, lia.font.loadFonts)
  end)
</code></pre>
</div>

</div>
</details>

---

