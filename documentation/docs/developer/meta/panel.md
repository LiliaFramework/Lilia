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

# Panel

Panel metatable helpers for inventory-aware UI behavior, layout, transitions, and drawing.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The panel meta table extends Garry's Mod VGUI panels with convenience helpers for inventory hook forwarding, scaled positioning and sizing, composable paint and hover effects, avatar masking, click behaviors, layout shortcuts, and transition-driven UI animation.
</div>

---

<details class="realm-client" id="function-lialistenforinventorychanges">
<summary><span class="summary-main"><a id="liaListenForInventoryChanges"></a>liaListenForInventoryChanges(inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L36" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialistenforinventorychanges"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Starts listening for inventory-related hooks and forwards matching events to this panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory object whose events should be observed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:liaListenForInventoryChanges(inventory)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadeleteinventoryhooks">
<summary><span class="summary-main"><a id="liaDeleteInventoryHooks"></a>liaDeleteInventoryHooks(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L94" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadeleteinventoryhooks"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes inventory hooks that were previously registered for this panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> <span class="optional">optional</span> A specific inventory ID to stop listening to, or `nil` to remove all tracked inventory hooks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:liaDeleteInventoryHooks()
  panel:liaDeleteInventoryHooks(inventory:getID())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setscaledpos">
<summary><span class="summary-main"><a id="setScaledPos"></a>setScaledPos(x, y)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L136" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setscaledpos"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets the panel position using screen-scaled X and Y values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The horizontal position before `ScreenScale` is applied.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The vertical position before `ScreenScaleH` is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:setScaledPos(32, 24)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setscaledsize">
<summary><span class="summary-main"><a id="setScaledSize"></a>setScaledSize(w, h)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L167" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setscaledsize"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets the panel size using screen-scaled width and height values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The width before `ScreenScale` is applied.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The height before `ScreenScaleH` is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:setScaledSize(300, 160)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-on">
<summary><span class="summary-main"><a id="On"></a>On(name, fn)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L216" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="on"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Appends a callback onto an existing panel method instead of replacing the method entirely.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The panel method name to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">fn</span> The callback to run after the original method.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:On("Paint", function(_, w, h)
      surface.DrawOutlinedRect(0, 0, w, h)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setuptransition">
<summary><span class="summary-main"><a id="SetupTransition"></a>SetupTransition(name, speed, fn)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L250" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setuptransition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a transition value that smoothly lerps between `0` and `1` based on a predicate callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The field name that stores the transition value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> The interpolation speed multiplier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">fn</span> A callback that returns whether the transition should move toward `1`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SetupTransition("HoverAmount", 8, function(s)
      return s:IsHovered()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-fadehover">
<summary><span class="summary-main"><a id="FadeHover"></a>FadeHover(col, speed, rad)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L279" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="fadehover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints a fading hover overlay over the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The hover overlay color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The hover fade speed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">rad</span> <span class="optional">optional</span> An optional rounded corner radius.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:FadeHover(Color(255, 255, 255, 20), 6, 8)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-barhover">
<summary><span class="summary-main"><a id="BarHover"></a>BarHover(col, height, speed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L317" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="barhover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws an animated bar along the bottom edge while the panel is hovered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The bar color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">height</span> <span class="optional">optional</span> The bar thickness.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:BarHover(Color(0, 120, 255), 3, 8)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-fillhover">
<summary><span class="summary-main"><a id="FillHover"></a>FillHover(col, dir, speed, mat)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L354" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="fillhover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fills the panel from a chosen direction while it is hovered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The fill color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">dir</span> <span class="optional">optional</span> The fill direction constant such as `LEFT` or `TOP`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> <span class="optional">optional</span> An optional material to draw instead of a solid rectangle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:FillHover(Color(255, 255, 255, 25), LEFT, 8)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-background">
<summary><span class="summary-main"><a id="Background"></a>Background(col, rad, rtl, rtr, rbl, rbr)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L412" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="background"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a flat or rounded background in the panel paint hook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> The background color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">rad</span> <span class="optional">optional</span> The rounded corner radius.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">rtl</span> <span class="optional">optional</span> Whether the top-left corner is rounded when using `draw.RoundedBoxEx`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">rtr</span> <span class="optional">optional</span> Whether the top-right corner is rounded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">rbl</span> <span class="optional">optional</span> Whether the bottom-left corner is rounded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">rbr</span> <span class="optional">optional</span> Whether the bottom-right corner is rounded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Background(Color(20, 20, 20, 220), 8)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-material">
<summary><span class="summary-main"><a id="Material"></a>Material(mat, col)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L448" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="material"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints a material stretched across the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> The material to draw.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> A tint color applied to the material.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Material(Material("vgui/white"), Color(255, 255, 255))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-tiledmaterial">
<summary><span class="summary-main"><a id="TiledMaterial"></a>TiledMaterial(mat, tw, th, col)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L482" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="tiledmaterial"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints a tiled material across the panel using UV scaling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> The material to tile.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">tw</span> The horizontal tile size.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">th</span> The vertical tile size.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> A tint color applied to the tiled material.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:TiledMaterial(Material("vgui/white"), 32, 32)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-outline">
<summary><span class="summary-main"><a id="Outline"></a>Outline(col, width)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L512" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="outline"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws an outline around the panel with configurable thickness.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The outline color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">width</span> <span class="optional">optional</span> The outline thickness in pixels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Outline(Color(255, 255, 255), 2)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-linedcorners">
<summary><span class="summary-main"><a id="LinedCorners"></a>LinedCorners(col, cornerLen)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L544" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="linedcorners"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws simple line corners around the panel frame.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The corner line color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">cornerLen</span> <span class="optional">optional</span> The length of each corner segment.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:LinedCorners(Color(255, 255, 255), 12)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-sideblock">
<summary><span class="summary-main"><a id="SideBlock"></a>SideBlock(col, size, side)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L579" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="sideblock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a solid accent block on one side of the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The block color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">size</span> <span class="optional">optional</span> The thickness of the block.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">side</span> <span class="optional">optional</span> The side constant such as `LEFT` or `BOTTOM`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SideBlock(Color(0, 127, 255), 4, LEFT)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-text">
<summary><span class="summary-main"><a id="Text"></a>Text(text, font, col, alignment, ox, oy, paint)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L628" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="text"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets built-in control text or paints centered text manually.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">font</span> <span class="optional">optional</span> The font name to use.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The text color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alignment</span> <span class="optional">optional</span> The horizontal text alignment constant.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">ox</span> <span class="optional">optional</span> Horizontal paint offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oy</span> <span class="optional">optional</span> Vertical paint offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">paint</span> <span class="optional">optional</span> Whether to force manual painting even when native text setters exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Text("Confirm", "Trebuchet24", color_white)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-dualtext">
<summary><span class="summary-main"><a id="DualText"></a>DualText(toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L685" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="dualtext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints two stacked text lines with independent fonts and colors.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">toptext</span> The upper text line.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">topfont</span> <span class="optional">optional</span> The upper line font.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">topcol</span> <span class="optional">optional</span> The upper line color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bottomtext</span> The lower text line.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bottomfont</span> <span class="optional">optional</span> The lower line font.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">bottomcol</span> <span class="optional">optional</span> The lower line color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alignment</span> <span class="optional">optional</span> The horizontal text alignment.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">centerSpacing</span> <span class="optional">optional</span> Extra spacing adjustment around the center.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:DualText("Lilia", "Trebuchet24", color_white, "Inventory", "Trebuchet18", Color(180, 180, 180))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-blur">
<summary><span class="summary-main"><a id="Blur"></a>Blur(amount)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L731" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="blur"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a blurred fullscreen backdrop behind the panel bounds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> The maximum blur strength.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Blur(8)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circleclick">
<summary><span class="summary-main"><a id="CircleClick"></a>CircleClick(col, speed, trad)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L769" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circleclick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Plays an expanding circular ripple from the click position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The ripple color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The expansion and fade speed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">trad</span> <span class="optional">optional</span> The target radius for the ripple.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  button:CircleClick(Color(255, 255, 255, 40), 5)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circlehover">
<summary><span class="summary-main"><a id="CircleHover"></a>CircleHover(col, speed, trad)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L813" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circlehover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a circular hover effect that follows the cursor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The hover effect color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">trad</span> <span class="optional">optional</span> The target hover radius.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:CircleHover(Color(255, 255, 255, 20), 6)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-squarecheckbox">
<summary><span class="summary-main"><a id="SquareCheckbox"></a>SquareCheckbox(inner, outer, speed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L849" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="squarecheckbox"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints an animated square checkbox fill based on checked state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">inner</span> <span class="optional">optional</span> The fill color used when checked.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">outer</span> <span class="optional">optional</span> The outer frame color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  checkbox:SquareCheckbox(Color(0, 200, 0), color_white, 14)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circlecheckbox">
<summary><span class="summary-main"><a id="CircleCheckbox"></a>CircleCheckbox(inner, outer, speed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L888" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circlecheckbox"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paints an animated circular checkbox fill based on checked state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">inner</span> <span class="optional">optional</span> The fill color used when checked.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">outer</span> <span class="optional">optional</span> The outer frame color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  checkbox:CircleCheckbox(Color(0, 200, 0), color_white, 14)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-avatarmask">
<summary><span class="summary-main"><a id="AvatarMask"></a>AvatarMask(mask)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L923" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="avatarmask"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Masks an embedded `AvatarImage` using a custom stencil shape callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">mask</span> A drawing callback that defines the stencil mask shape.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:AvatarMask(function(_, w, h)
      draw.RoundedBox(8, 0, 0, w, h, color_white)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circleavatar">
<summary><span class="summary-main"><a id="CircleAvatar"></a>CircleAvatar()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L971" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circleavatar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Applies a circular stencil mask to the panel avatar.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  avatarPanel:CircleAvatar()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circle">
<summary><span class="summary-main"><a id="Circle"></a>Circle(col)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L994" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circle"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a filled circle that fits inside the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The circle color.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Circle(Color(255, 255, 255))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circlefadehover">
<summary><span class="summary-main"><a id="CircleFadeHover"></a>CircleFadeHover(col, speed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1024" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circlefadehover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a circular hover overlay that fades in and out.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The overlay color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:CircleFadeHover(Color(255, 255, 255, 20), 6)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-circleexpandhover">
<summary><span class="summary-main"><a id="CircleExpandHover"></a>CircleExpandHover(col, speed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1056" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="circleexpandhover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a circular hover overlay that expands with hover progress.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> <span class="optional">optional</span> The overlay color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">speed</span> <span class="optional">optional</span> The transition speed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:CircleExpandHover(Color(255, 255, 255, 20), 6)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-gradient">
<summary><span class="summary-main"><a id="Gradient"></a>Gradient(col, dir, frac, op)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1093" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="gradient"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a directional gradient overlay with optional inversion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> The gradient tint color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">dir</span> <span class="optional">optional</span> The gradient direction constant.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">frac</span> <span class="optional">optional</span> The fraction of the panel covered by the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">op</span> <span class="optional">optional</span> Whether to invert the gradient material direction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Gradient(Color(0, 0, 0, 180), BOTTOM, 1)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setopenurl">
<summary><span class="summary-main"><a id="SetOpenURL"></a>SetOpenURL(url)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1140" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setopenurl"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens the provided URL when the panel is clicked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">url</span> The URL to open in the user's browser.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SetOpenURL("https://example.com")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-netmessage">
<summary><span class="summary-main"><a id="NetMessage"></a>NetMessage(name, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1167" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="netmessage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a client-to-server net message when the panel is clicked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The net message name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">data</span> <span class="optional">optional</span> A callback that writes additional payload data into the net message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  button:NetMessage("liaRequestAction", function()
      net.WriteUInt(1, 8)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-stick">
<summary><span class="summary-main"><a id="Stick"></a>Stick(dock, margin, dontInvalidate)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1199" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="stick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Docks the panel with optional uniform margin and parent invalidation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">dock</span> <span class="optional">optional</span> The docking mode such as `FILL` or `TOP`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">margin</span> <span class="optional">optional</span> A uniform dock margin.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">dontInvalidate</span> <span class="optional">optional</span> Whether to skip invalidating the parent layout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:Stick(TOP, 4)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-divtall">
<summary><span class="summary-main"><a id="DivTall"></a>DivTall(frac, target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1228" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="divtall"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets the panel height to a fraction of a target panel's height.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">frac</span> <span class="optional">optional</span> The divisor used for the target height.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">target</span> <span class="optional">optional</span> The panel whose height is used as the source measurement.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:DivTall(3, parent)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-divwide">
<summary><span class="summary-main"><a id="DivWide"></a>DivWide(frac, target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1255" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="divwide"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets the panel width to a fraction of a target panel's width.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">frac</span> <span class="optional">optional</span> The divisor used for the target width.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">target</span> <span class="optional">optional</span> The panel whose width is used as the source measurement.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:DivWide(2, parent)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-squarefromheight">
<summary><span class="summary-main"><a id="SquareFromHeight"></a>SquareFromHeight()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1276" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="squarefromheight"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Makes the panel square by matching its width to its current height.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SquareFromHeight()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-squarefromwidth">
<summary><span class="summary-main"><a id="SquareFromWidth"></a>SquareFromWidth()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1295" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="squarefromwidth"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Makes the panel square by matching its height to its current width.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SquareFromWidth()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setremove">
<summary><span class="summary-main"><a id="SetRemove"></a>SetRemove(target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1318" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setremove"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a target panel when this panel is clicked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">target</span> <span class="optional">optional</span> The panel to remove, or this panel when omitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  closeButton:SetRemove(frame)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-fadein">
<summary><span class="summary-main"><a id="FadeIn"></a>FadeIn(time, alpha)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1344" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="fadein"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fades the panel in from alpha `0` to a target opacity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> <span class="optional">optional</span> The fade duration in seconds.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> The target alpha value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:FadeIn(0.25, 255)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-hidevbar">
<summary><span class="summary-main"><a id="HideVBar"></a>HideVBar()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1366" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="hidevbar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Hides and collapses a scroll panel's vertical scrollbar.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  scrollPanel:HideVBar()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-settransitionfunc">
<summary><span class="summary-main"><a id="SetTransitionFunc"></a>SetTransitionFunc(fn)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1392" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="settransitionfunc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets the default predicate used by transition helpers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">fn</span> The predicate callback used by `SetupTransition`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The current panel for chaining.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SetTransitionFunc(function(s) return s:IsHovered() end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-cleartransitionfunc">
<summary><span class="summary-main"><a id="ClearTransitionFunc"></a>ClearTransitionFunc()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1413" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="cleartransitionfunc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Clears the default predicate override used by transition helpers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The current panel for chaining.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:ClearTransitionFunc()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setappendoverwrite">
<summary><span class="summary-main"><a id="SetAppendOverwrite"></a>SetAppendOverwrite(fn)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1438" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setappendoverwrite"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Overrides which panel method `On` appends to.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fn</span> The method name that `On` should use until cleared.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The current panel for chaining.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:SetAppendOverwrite("PaintOver")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-clearappendoverwrite">
<summary><span class="summary-main"><a id="ClearAppendOverwrite"></a>ClearAppendOverwrite()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1459" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="clearappendoverwrite"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Clears the temporary method override used by `On`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The current panel for chaining.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:ClearAppendOverwrite()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-clearpaint">
<summary><span class="summary-main"><a id="ClearPaint"></a>ClearPaint()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1479" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="clearpaint"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes the panel `Paint` function.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  panel:ClearPaint()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-readytextbox">
<summary><span class="summary-main"><a id="ReadyTextbox"></a>ReadyTextbox()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/meta/panel.lua#L1498" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="readytextbox"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prepares a textbox for paint-over transitions while editing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  textEntry:ReadyTextbox()
</code></pre>
</div>

</div>
</details>

---

