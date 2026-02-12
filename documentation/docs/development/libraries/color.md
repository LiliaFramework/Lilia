# Color

Comprehensive color and theme management system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The color library provides comprehensive functionality for managing colors and themes in the Lilia framework. It handles color registration, theme management, color manipulation, and smooth theme transitions. The library operates primarily on the client side, with theme registration available on both server and client. It includes predefined color names, theme switching capabilities, color adjustment functions, and smooth animated transitions between themes. The library ensures consistent color usage across the entire gamemode interface and provides tools for creating custom themes and color schemes.
</div>

---

<details class="realm-client" id="function-liacolorregister">
<summary><a id="lia.color.register"></a>lia.color.register(name, color)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a named color so string-based Color() calls can resolve it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During client initialization or when adding palette entries at runtime.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Identifier stored in lowercase.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|Color</a></span> <span class="parameter">color</span> Table or Color with r, g, b, a fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.color.register("warning", Color(255, 140, 0))
  local c = Color("warning")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacoloradjust">
<summary><a id="lia.color.adjust"></a>lia.color.adjust(color, aOffset)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacoloradjust"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Apply additive offsets to a color to quickly tint or shade it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While building UI states (hover/pressed) or computing theme variants.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Base color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">aOffset</span> <span class="optional">optional</span> Optional alpha offset; defaults to 0.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Adjusted color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local base = lia.color.getMainColor()
  button:SetTextColor(lia.color.adjust(base, -40, -20, -60))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolordarken">
<summary><a id="lia.color.darken"></a>lia.color.darken(color, factor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolordarken"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Darken a color by a fractional factor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Deriving hover/pressed backgrounds from a base accent color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Base color to darken.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">factor</span> <span class="optional">optional</span> Amount between 0-1; defaults to 0.1 and is clamped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Darkened color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local accent = lia.color.getMainColor()
  local pressed = lia.color.darken(accent, 0.2)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorgetcurrenttheme">
<summary><a id="lia.color.getCurrentTheme"></a>lia.color.getCurrentTheme()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorgetcurrenttheme"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Get the active theme id from config in lowercase.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before looking up theme tables or theme-specific assets.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Lowercased theme id (default "teal").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.color.getCurrentTheme() == "dark" then
      panel:SetDarkMode(true)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorgetcurrentthemename">
<summary><a id="lia.color.getCurrentThemeName"></a>lia.color.getCurrentThemeName()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorgetcurrentthemename"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Get the display name of the currently selected theme.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Showing UI labels or logs about the active theme.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Theme name from config with original casing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  chat.AddText(Color(180, 220, 255), "Theme: ", lia.color.getCurrentThemeName())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorgetmaincolor">
<summary><a id="lia.color.getMainColor"></a>lia.color.getMainColor()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorgetmaincolor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fetch the main color from the current theme with sensible fallbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Setting accent colors for buttons, bars, and highlights.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Main theme color, falling back to the default theme or teal.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local accent = lia.color.getMainColor()
  button:SetTextColor(accent)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorapplytheme">
<summary><a id="lia.color.applyTheme"></a>lia.color.applyTheme(themeName, useTransition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorapplytheme"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Apply a theme immediately or begin a smooth transition toward it, falling back to Teal/default palettes and firing OnThemeChanged after updates.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On config changes, theme selection menus, or client startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">themeName</span> <span class="optional">optional</span> Target theme id; defaults to the current config value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">useTransition</span> <span class="optional">optional</span> If true, blends colors over time instead of swapping instantly.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  concommand.Add("lia_theme_preview", function(_, _, args)
      lia.color.applyTheme(args[1] or "Teal", true)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacoloristransitionactive">
<summary><a id="lia.color.isTransitionActive"></a>lia.color.isTransitionActive()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacoloristransitionactive"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Check whether a theme transition is currently blending.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>To avoid overlapping transitions or to gate UI animations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if a transition is active, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.color.isTransitionActive() then return end
  lia.color.applyTheme("Dark", true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolortestthemetransition">
<summary><a id="lia.color.testThemeTransition"></a>lia.color.testThemeTransition(themeName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolortestthemetransition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Convenience wrapper to start a theme transition immediately.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From theme preview buttons to animate a swap.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">themeName</span> Target theme id.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  vgui.Create("DButton").DoClick = function()
      lia.color.testThemeTransition("Red")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorstartthemetransition">
<summary><a id="lia.color.startThemeTransition"></a>lia.color.startThemeTransition(name)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorstartthemetransition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Begin blending from the current palette toward a target theme, falling back to Teal when missing and finishing by firing OnThemeChanged once applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inside applyTheme when transitions are enabled or via previews.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Theme id to blend toward.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.color.transition.speed = 1.5
  lia.color.startThemeTransition("Ice")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacoloriscolor">
<summary><a id="lia.color.isColor"></a>lia.color.isColor(v)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacoloriscolor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine whether a value resembles a Color table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While blending themes to decide how to lerp entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">v</span> Value to test.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when v has numeric r, g, b, a fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.color.isColor(entry) then
      panel:SetTextColor(entry)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorcalculatenegativecolor">
<summary><a id="lia.color.calculateNegativeColor"></a>lia.color.calculateNegativeColor(mainColor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorcalculatenegativecolor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build a readable contrasting color (alpha 255) based on a main color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Choosing text or negative colors for overlays and highlights.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">mainColor</span> <span class="optional">optional</span> Defaults to the current theme main color when nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Contrasting color tuned for readability.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local negative = lia.color.calculateNegativeColor()
  frame:SetTextColor(negative)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorreturnmainadjustedcolors">
<summary><a id="lia.color.returnMainAdjustedColors"></a>lia.color.returnMainAdjustedColors()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorreturnmainadjustedcolors"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Derive a suite of adjusted colors from the main theme color, including brightness-aware text and a calculated negative color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Building consistent palettes for backgrounds, accents, and text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Contains background, sidebar, accent, text, hover, border, highlight, negative.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local palette = lia.color.returnMainAdjustedColors()
  panel:SetBGColor(palette.background)
  panel:SetTextColor(palette.text)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacolorlerp">
<summary><a id="lia.color.lerp"></a>lia.color.lerp(frac, col1, col2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorlerp"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>FrameTime-scaled color lerp helper.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Theme transitions or animated highlights needing smooth color changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">frac</span> Multiplier applied to FrameTime for lerp speed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col1</span> Source color; defaults to white when nil.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col2</span> Target color; defaults to white when nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Interpolated color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local blink = lia.color.lerp(6, Color(255, 0, 0), Color(255, 255, 255))
  panel:SetBorderColor(blink)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liacolorregistertheme">
<summary><a id="lia.color.registerTheme"></a>lia.color.registerTheme(name, themeData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorregistertheme"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a theme table by name for later selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During initialization to expose custom palettes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Theme name/id; stored in lowercase.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">themeData</span> Map of color keys to Color values or arrays.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.color.registerTheme("MyStudio", {
      maincolor = Color(120, 200, 255),
      background = Color(20, 24, 32),
      text = Color(230, 240, 255)
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liacolorgetallthemes">
<summary><a id="lia.color.getAllThemes"></a>lia.color.getAllThemes()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacolorgetallthemes"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Return a sorted list of available theme ids.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>To populate config dropdowns or theme selection menus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sorted array of theme ids.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local options = {}
  for _, id in ipairs(lia.color.getAllThemes()) do
      options[#options + 1] = id
  end
</code></pre>
</div>

</div>
</details>

---

