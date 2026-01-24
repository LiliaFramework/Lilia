# Panel Meta

Panel management system for the Lilia framework.

---

Overview

The panel meta table provides comprehensive functionality for managing VGUI panels, UI interactions, and panel operations in the Lilia framework. It handles panel event listening, inventory synchronization, UI updates, and panel-specific operations. The meta table operates primarily on the client side, with the server providing data that panels can listen to and display. It includes integration with the inventory system for inventory change notifications, character system for character data display, network system for data synchronization, and UI system for panel management. The meta table ensures proper panel event handling, inventory synchronization, UI updates, and comprehensive panel lifecycle management from creation to destruction.

---

<details class="realm-client">
<summary><a id=liaListenForInventoryChanges></a>liaListenForInventoryChanges(inventory)</summary>
<a id="lialistenforinventorychanges"></a>
<p>Registers the panel to mirror inventory events to its methods.</p>
<p>Use when a panel needs to react to changes in a specific inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory instance whose events should be listened to.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:liaListenForInventoryChanges(inv)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=liaDeleteInventoryHooks></a>liaDeleteInventoryHooks(id)</summary>
<a id="liadeleteinventoryhooks"></a>
<p>Removes inventory event hooks previously registered on the panel.</p>
<p>Call when tearing down a panel or when an inventory is no longer tracked.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> <span class="optional">optional</span> Optional inventory ID to target; nil clears all known hooks.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:liaDeleteInventoryHooks(invID)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=setScaledPos></a>setScaledPos(x, y)</summary>
<a id="setscaledpos"></a>
<p>Sets the panel position using screen-scaled coordinates.</p>
<p>Use when positioning should respect different resolutions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">x</span> Horizontal position before scaling.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">y</span> Vertical position before scaling.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:setScaledPos(32, 48)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=setScaledSize></a>setScaledSize(w, h)</summary>
<a id="setscaledsize"></a>
<p>Sets the panel size using screen-scaled dimensions.</p>
<p>Use when sizing should scale with screen resolution.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> Width before scaling.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> Height before scaling.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:setScaledSize(120, 36)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=On></a>On(name, fn)</summary>
<a id="on"></a>
<p>Appends an additional handler to a panel function without removing the existing one.</p>
<p>Use to extend an existing panel callback (e.g., Paint, Think) while preserving prior logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Panel function name to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">fn</span> Function to run after the original callback.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:On("Paint", function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, col) end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetupTransition></a>SetupTransition(name, speed, fn)</summary>
<a id="setuptransition"></a>
<p>Creates a smoothly lerped state property driven by a predicate function.</p>
<p>Use when a panel needs an animated transition flag (e.g., hover fades).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Property name to animate on the panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Lerp speed multiplier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">fn</span> Predicate returning true when the property should approach 1.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SetupTransition("HoverAlpha", 6, function(s) return s:IsHovered() end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=FadeHover></a>FadeHover(col, speed, rad)</summary>
<a id="fadehover"></a>
<p>Draws a faded overlay that brightens when the panel is hovered.</p>
<p>Apply to panels that need a simple hover highlight.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Overlay color and base alpha.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed toward hover state.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">rad</span> <span class="optional">optional</span> Optional corner radius for rounded boxes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:FadeHover(Color(255,255,255,40), 8, 4)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=BarHover></a>BarHover(col, height, speed)</summary>
<a id="barhover"></a>
<p>Animates a horizontal bar under the panel while hovered.</p>
<p>Use for button underlines or similar hover indicators.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Bar color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">height</span> Bar thickness in pixels.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed toward hover state.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:BarHover(Color(0,150,255), 2, 10)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=FillHover></a>FillHover(col, dir, speed, mat)</summary>
<a id="fillhover"></a>
<p>Fills the panel from one side while hovered, optionally using a material.</p>
<p>Use when a directional hover fill effect is desired.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Fill color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dir</span> Direction constant (LEFT, RIGHT, TOP, BOTTOM).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed toward hover state.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> <span class="optional">optional</span> Optional material to draw instead of a solid color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:FillHover(Color(255,255,255,20), LEFT, 6)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Background></a>Background(col, rad)</summary>
<a id="background"></a>
<p>Paints a solid background for the panel with optional rounded corners.</p>
<p>Use when a panel needs a consistent background fill.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Fill color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">rad</span> <span class="optional">optional</span> Corner radius; nil or 0 draws a square rect.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Background(Color(20,20,20,230), 6)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Material></a>Material(mat, col)</summary>
<a id="material"></a>
<p>Draws a textured material across the panel.</p>
<p>Use when a static material should cover the panel area.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> Material to render.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Color tint applied to the material.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Material(Material("vgui/gradient-l"), Color(255,255,255))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=TiledMaterial></a>TiledMaterial(mat, tw, th, col)</summary>
<a id="tiledmaterial"></a>
<p>Tiles a material over the panel at a fixed texture size.</p>
<p>Use when repeating patterns should fill the panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> <span class="parameter">mat</span> Material to tile.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">tw</span> Tile width in texture units.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">th</span> Tile height in texture units.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Color tint for the material.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:TiledMaterial(myMat, 64, 64, Color(255,255,255))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Outline></a>Outline(col, width)</summary>
<a id="outline"></a>
<p>Draws an outlined rectangle around the panel.</p>
<p>Use to give a panel a simple border.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Outline color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">width</span> Border thickness in pixels.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Outline(Color(255,255,255), 2)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=LinedCorners></a>LinedCorners(col, cornerLen)</summary>
<a id="linedcorners"></a>
<p>Draws minimal corner lines on opposite corners of the panel.</p>
<p>Use for a lightweight corner accent instead of a full border.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Corner line color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">cornerLen</span> Length of each corner arm in pixels.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:LinedCorners(Color(255,255,255), 12)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SideBlock></a>SideBlock(col, size, side)</summary>
<a id="sideblock"></a>
<p>Adds a solid strip to one side of the panel.</p>
<p>Use for side indicators or separators on panels.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Strip color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">size</span> Strip thickness in pixels.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">side</span> Side constant (LEFT, RIGHT, TOP, BOTTOM).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SideBlock(Color(0,140,255), 4, LEFT)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Text></a>Text(text, font, col, alignment, paint)</summary>
<a id="text"></a>
<p>Renders a single line of text within the panel or sets label properties directly.</p>
<p>Use to quickly add centered or aligned text to a panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">font</span> Font name to use.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Text color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alignment</span> TEXT_ALIGN_* constant controlling horizontal alignment.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">paint</span> Force paint-based rendering even if label setters exist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Text("Hello", "Trebuchet24", color_white, TEXT_ALIGN_CENTER)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DualText></a>DualText(alignment, centerSpacing)</summary>
<a id="dualtext"></a>
<p>Draws two stacked text lines with independent styling.</p>
<p>Use when a panel needs a title and subtitle aligned together.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alignment</span> TEXT_ALIGN_* horizontal alignment.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">centerSpacing</span> Offset to spread the two lines from the center point.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:DualText("Title", "Trebuchet24", lia.colors.primary, "Detail", "Trebuchet18", color_white)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Blur></a>Blur(amount)</summary>
<a id="blur"></a>
<p>Draws a post-process blur behind the panel bounds.</p>
<p>Use to blur the world/UI behind a panel while it is painted.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Blur intensity multiplier.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Blur(8)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleClick></a>CircleClick(col, speed, trad)</summary>
<a id="circleclick"></a>
<p>Creates a ripple effect centered on the click position.</p>
<p>Use for buttons that need animated click feedback.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Ripple color and opacity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Lerp speed for expansion and fade.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">trad</span> <span class="optional">optional</span> Target radius override; defaults to panel width.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:CircleClick(Color(255,255,255,40), 5)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleHover></a>CircleHover(col, speed, trad)</summary>
<a id="circlehover"></a>
<p>Draws a circular highlight that follows the cursor while hovering.</p>
<p>Use for hover feedback centered on the cursor position.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Highlight color and base opacity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed for appearing/disappearing.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">trad</span> <span class="optional">optional</span> Target radius; defaults to panel width.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:CircleHover(Color(255,255,255,30), 6)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SquareCheckbox></a>SquareCheckbox(inner, outer, speed)</summary>
<a id="squarecheckbox"></a>
<p>Renders an animated square checkbox fill tied to the panel's checked state.</p>
<p>Use on checkbox panels to visualize toggled state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">inner</span> Color of the filled square.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">outer</span> Color of the outline/background.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed for filling.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    checkbox:SquareCheckbox()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleCheckbox></a>CircleCheckbox(inner, outer, speed)</summary>
<a id="circlecheckbox"></a>
<p>Renders an animated circular checkbox tied to the panel's checked state.</p>
<p>Use on checkbox panels that should appear circular.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">inner</span> Color of the inner filled circle.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">outer</span> Outline color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed for filling.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    checkbox:CircleCheckbox()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AvatarMask></a>AvatarMask(mask)</summary>
<a id="avatarmask"></a>
<p>Applies a stencil mask to an AvatarImage child using a custom shape.</p>
<p>Use when an avatar needs to be clipped to a non-rectangular mask.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">mask</span> Draw callback that defines the stencil shape.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:AvatarMask(function(_, w, h) drawCircle(w/2, h/2, w/2) end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleAvatar></a>CircleAvatar()</summary>
<a id="circleavatar"></a>
<p>Masks the panel's avatar as a circle.</p>
<p>Use when a circular avatar presentation is desired.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:CircleAvatar()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Circle></a>Circle(col)</summary>
<a id="circle"></a>
<p>Paints a filled circle that fits the panel bounds.</p>
<p>Use for circular panels or backgrounds.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Circle color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Circle(Color(255,255,255))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleFadeHover></a>CircleFadeHover(col, speed)</summary>
<a id="circlefadehover"></a>
<p>Shows a fading circular overlay at the center while hovered.</p>
<p>Use for subtle hover feedback on circular elements.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Overlay color and base alpha.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed toward hover state.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:CircleFadeHover(Color(255,255,255,30), 6)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CircleExpandHover></a>CircleExpandHover(col, speed)</summary>
<a id="circleexpandhover"></a>
<p>Draws an expanding circle from the panel center while hovered.</p>
<p>Use when a growing highlight is needed on hover.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Circle color and alpha.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">speed</span> Transition speed toward hover state.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:CircleExpandHover(Color(255,255,255,30), 6)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Gradient></a>Gradient(col, dir, frac, op)</summary>
<a id="gradient"></a>
<p>Draws a directional gradient over the panel.</p>
<p>Use to overlay a gradient tint from a chosen side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">col</span> Gradient color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dir</span> Direction constant (LEFT, RIGHT, TOP, BOTTOM).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">frac</span> Fraction of the panel to cover with the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">op</span> When true, flips the gradient material for the given direction.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Gradient(Color(0,0,0,180), BOTTOM, 0.4)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetOpenURL></a>SetOpenURL(url)</summary>
<a id="setopenurl"></a>
<p>Opens a URL when the panel is clicked.</p>
<p>Attach to clickable panels that should launch an external link.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">url</span> URL to open.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SetOpenURL("https://example.com")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=NetMessage></a>NetMessage(name, data)</summary>
<a id="netmessage"></a>
<p>Sends a network message when the panel is clicked.</p>
<p>Use for UI buttons that trigger server-side actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Net message name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">data</span> Optional writer that populates the net message payload.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:NetMessage("liaAction", function(p) net.WriteEntity(p.Entity) end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=Stick></a>Stick(dock, margin, dontInvalidate)</summary>
<a id="stick"></a>
<p>Docks the panel with optional margin and parent invalidation.</p>
<p>Use to pin a panel to a dock position with minimal boilerplate.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dock</span> DOCK constant to apply; defaults to FILL.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">margin</span> Optional uniform margin after docking.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">dontInvalidate</span> Skip invalidating the parent when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:Stick(LEFT, 8)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DivTall></a>DivTall(frac, target)</summary>
<a id="divtall"></a>
<p>Sets the panel height to a fraction of another panel's height.</p>
<p>Use for proportional layout against a parent or target panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">frac</span> Divisor applied to the target height.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">target</span> Panel to reference; defaults to the parent.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:DivTall(3, parentPanel)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DivWide></a>DivWide(frac, target)</summary>
<a id="divwide"></a>
<p>Sets the panel width to a fraction of another panel's width.</p>
<p>Use for proportional layout against a parent or target panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">frac</span> Divisor applied to the target width.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">target</span> Panel to reference; defaults to the parent.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:DivWide(2, parentPanel)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SquareFromHeight></a>SquareFromHeight()</summary>
<a id="squarefromheight"></a>
<p>Makes the panel width equal its current height.</p>
<p>Use when the panel should become a square based on height.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SquareFromHeight()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SquareFromWidth></a>SquareFromWidth()</summary>
<a id="squarefromwidth"></a>
<p>Makes the panel height equal its current width.</p>
<p>Use when the panel should become a square based on width.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SquareFromWidth()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetRemove></a>SetRemove(target)</summary>
<a id="setremove"></a>
<p>Removes a target panel when this panel is clicked.</p>
<p>Use for close buttons or dismiss actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">target</span> <span class="optional">optional</span> Panel to remove; defaults to the panel itself.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    closeButton:SetRemove(parentPanel)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=FadeIn></a>FadeIn(time, alpha)</summary>
<a id="fadein"></a>
<p>Fades the panel in from transparent to a target alpha.</p>
<p>Use when showing a panel with a quick fade animation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Duration of the fade in seconds.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alpha</span> Target opacity after fading.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:FadeIn(0.2, 255)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=HideVBar></a>HideVBar()</summary>
<a id="hidevbar"></a>
<p>Hides and collapses the vertical scrollbar of a DScrollPanel.</p>
<p>Use when the scrollbar should be invisible but scrolling remains enabled.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    scrollPanel:HideVBar()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetTransitionFunc></a>SetTransitionFunc(fn)</summary>
<a id="settransitionfunc"></a>
<p>Sets a shared predicate used by transition helpers to determine state.</p>
<p>Use before invoking helpers like SetupTransition to change their condition.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">fn</span> Predicate returning true when the transition should be active.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SetTransitionFunc(function(s) return s:IsVisible() end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ClearTransitionFunc></a>ClearTransitionFunc()</summary>
<a id="cleartransitionfunc"></a>
<p>Clears any predicate set for transition helpers.</p>
<p>Use to revert transition helpers back to their default behavior.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:ClearTransitionFunc()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetAppendOverwrite></a>SetAppendOverwrite(fn)</summary>
<a id="setappendoverwrite"></a>
<p>Overrides the target function name used by the On helper.</p>
<p>Use when On should wrap a different function name than the provided one.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fn</span> Function name to force On to wrap.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:SetAppendOverwrite("PaintOver")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ClearAppendOverwrite></a>ClearAppendOverwrite()</summary>
<a id="clearappendoverwrite"></a>
<p>Removes any function name override set for the On helper.</p>
<p>Use to return On to its default behavior.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:ClearAppendOverwrite()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ClearPaint></a>ClearPaint()</summary>
<a id="clearpaint"></a>
<p>Removes any custom Paint function on the panel.</p>
<p>Use to revert a panel to its default painting behavior.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    panel:ClearPaint()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ReadyTextbox></a>ReadyTextbox()</summary>
<a id="readytextbox"></a>
<p>Prepares a text entry for Lilia styling by hiding its background and adding focus feedback.</p>
<p>Use after creating a TextEntry to match framework visuals.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    textEntry:ReadyTextbox()
</code></pre>
</details>

---

