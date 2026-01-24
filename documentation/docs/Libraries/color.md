# Color Library

Comprehensive color and theme management system for the Lilia framework.

---

Overview

The color library provides comprehensive functionality for managing colors and themes in the Lilia framework. It handles color registration, theme management, color manipulation, and smooth theme transitions. The library operates primarily on the client side, with theme registration available on both server and client. It includes predefined color names, theme switching capabilities, color adjustment functions, and smooth animated transitions between themes. The library ensures consistent color usage across the entire gamemode interface and provides tools for creating custom themes and color schemes.

---

<details class="realm-client">
<summary><a id=lia.color.register></a>lia.color.register(name, color)</summary>
<a id="liacolorregister"></a>
<p>Register a named color so string-based Color() calls can resolve it.</p>
<p>During client initialization or when adding palette entries at runtime.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Identifier stored in lowercase.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|Color</a></span> <span class="parameter">color</span> Table or Color with r, g, b, a fields.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.color.register("warning", Color(255, 140, 0))
    local c = Color("warning")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.adjust></a>lia.color.adjust(color, aOffset)</summary>
<a id="liacoloradjust"></a>
<p>Apply additive offsets to a color to quickly tint or shade it.</p>
<p>While building UI states (hover/pressed) or computing theme variants.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Base color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">aOffset</span> <span class="optional">optional</span> Optional alpha offset; defaults to 0.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Adjusted color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local base = lia.color.getMainColor()
    button:SetTextColor(lia.color.adjust(base, -40, -20, -60))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.darken></a>lia.color.darken(color, factor)</summary>
<a id="liacolordarken"></a>
<p>Darken a color by a fractional factor.</p>
<p>Deriving hover/pressed backgrounds from a base accent color.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Base color to darken.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">factor</span> <span class="optional">optional</span> Amount between 0-1; defaults to 0.1 and is clamped.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Darkened color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local accent = lia.color.getMainColor()
    local pressed = lia.color.darken(accent, 0.2)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.getCurrentTheme></a>lia.color.getCurrentTheme()</summary>
<a id="liacolorgetcurrenttheme"></a>
<p>Get the active theme id from config in lowercase.</p>
<p>Before looking up theme tables or theme-specific assets.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Lowercased theme id (default "teal").</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.color.getCurrentTheme() == "dark" then
        panel:SetDarkMode(true)
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.getCurrentThemeName></a>lia.color.getCurrentThemeName()</summary>
<a id="liacolorgetcurrentthemename"></a>
<p>Get the display name of the currently selected theme.</p>
<p>Showing UI labels or logs about the active theme.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Theme name from config with original casing.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    chat.AddText(Color(180, 220, 255), "Theme: ", lia.color.getCurrentThemeName())
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.getMainColor></a>lia.color.getMainColor()</summary>
<a id="liacolorgetmaincolor"></a>
<p>Fetch the main color from the current theme with sensible fallbacks.</p>
<p>Setting accent colors for buttons, bars, and highlights.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Main theme color, falling back to the default theme or teal.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local accent = lia.color.getMainColor()
    button:SetTextColor(accent)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.applyTheme></a>lia.color.applyTheme(themeName, useTransition)</summary>
<a id="liacolorapplytheme"></a>
<p>Apply a theme immediately or begin a smooth transition toward it, falling back to Teal/default palettes and firing OnThemeChanged after updates.</p>
<p>On config changes, theme selection menus, or client startup.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">themeName</span> <span class="optional">optional</span> Target theme id; defaults to the current config value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">useTransition</span> <span class="optional">optional</span> If true, blends colors over time instead of swapping instantly.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    concommand.Add("lia_theme_preview", function(_, _, args)
        lia.color.applyTheme(args[1] or "Teal", true)
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.isTransitionActive></a>lia.color.isTransitionActive()</summary>
<a id="liacoloristransitionactive"></a>
<p>Check whether a theme transition is currently blending.</p>
<p>To avoid overlapping transitions or to gate UI animations.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if a transition is active, otherwise false.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.color.isTransitionActive() then return end
    lia.color.applyTheme("Dark", true)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.testThemeTransition></a>lia.color.testThemeTransition(themeName)</summary>
<a id="liacolortestthemetransition"></a>
<p>Convenience wrapper to start a theme transition immediately.</p>
<p>From theme preview buttons to animate a swap.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">themeName</span> Target theme id.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    vgui.Create("DButton").DoClick = function()
        lia.color.testThemeTransition("Red")
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.startThemeTransition></a>lia.color.startThemeTransition(name)</summary>
<a id="liacolorstartthemetransition"></a>
<p>Begin blending from the current palette toward a target theme, falling back to Teal when missing and finishing by firing OnThemeChanged once applied.</p>
<p>Inside applyTheme when transitions are enabled or via previews.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Theme id to blend toward.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.color.transition.speed = 1.5
    lia.color.startThemeTransition("Ice")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.isColor></a>lia.color.isColor(v)</summary>
<a id="liacoloriscolor"></a>
<p>Determine whether a value resembles a Color table.</p>
<p>While blending themes to decide how to lerp entries.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">v</span> Value to test.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True when v has numeric r, g, b, a fields.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.color.isColor(entry) then
        panel:SetTextColor(entry)
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.calculateNegativeColor></a>lia.color.calculateNegativeColor(mainColor)</summary>
<a id="liacolorcalculatenegativecolor"></a>
<p>Build a readable contrasting color (alpha 255) based on a main color.</p>
<p>Choosing text or negative colors for overlays and highlights.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">mainColor</span> <span class="optional">optional</span> Defaults to the current theme main color when nil.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Contrasting color tuned for readability.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local negative = lia.color.calculateNegativeColor()
    frame:SetTextColor(negative)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.returnMainAdjustedColors></a>lia.color.returnMainAdjustedColors()</summary>
<a id="liacolorreturnmainadjustedcolors"></a>
<p>Derive a suite of adjusted colors from the main theme color, including brightness-aware text and a calculated negative color.</p>
<p>Building consistent palettes for backgrounds, accents, and text.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Contains background, sidebar, accent, text, hover, border, highlight, negative.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local palette = lia.color.returnMainAdjustedColors()
    panel:SetBGColor(palette.background)
    panel:SetTextColor(palette.text)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.color.lerp></a>lia.color.lerp(frac, col1, col2)</summary>
<a id="liacolorlerp"></a>
<p>FrameTime-scaled color lerp helper.</p>
<p>Theme transitions or animated highlights needing smooth color changes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">frac</span> Multiplier applied to FrameTime for lerp speed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col1</span> Source color; defaults to white when nil.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col2</span> Target color; defaults to white when nil.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> Interpolated color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local blink = lia.color.lerp(6, Color(255, 0, 0), Color(255, 255, 255))
    panel:SetBorderColor(blink)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.color.registerTheme></a>lia.color.registerTheme(name, themeData)</summary>
<a id="liacolorregistertheme"></a>
<p>Register a theme table by name for later selection.</p>
<p>During initialization to expose custom palettes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Theme name/id; stored in lowercase.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">themeData</span> Map of color keys to Color values or arrays.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.color.registerTheme("MyStudio", {
        maincolor = Color(120, 200, 255),
        background = Color(20, 24, 32),
        text = Color(230, 240, 255)
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.color.getAllThemes></a>lia.color.getAllThemes()</summary>
<a id="liacolorgetallthemes"></a>
<p>Return a sorted list of available theme ids.</p>
<p>To populate config dropdowns or theme selection menus.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Sorted array of theme ids.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local options = {}
    for _, id in ipairs(lia.color.getAllThemes()) do
        options[#options + 1] = id
    end
</code></pre>
</details>

---

