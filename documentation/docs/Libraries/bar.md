# Bars Library

Dynamic progress bar creation and management system for the Lilia framework.

---

Overview

The bars library provides a comprehensive system for creating and managing dynamic progress bars in the Lilia framework. It handles the creation, rendering, and lifecycle management of various types of bars including health, armor, and custom progress indicators. The library operates primarily on the client side, providing smooth animated transitions between bar values and intelligent visibility management based on value changes and user preferences. It includes built-in health and armor bars, custom action progress displays, and a flexible system for adding custom bars with priority-based ordering. The library ensures consistent visual presentation across all bar types while providing hooks for customization and integration with other framework components.

---

<details class="realm-client">
<summary><a id=lia.bar.get></a>lia.bar.get(identifier)</summary>
<a id="liabarget"></a>
<p>Retrieve a registered bar definition by its identifier.</p>
<p>Before updating/removing an existing bar or inspecting its state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> <span class="optional">optional</span> Unique bar id supplied when added.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Stored bar data or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local staminaBar = lia.bar.get("stamina")
    if staminaBar then
        print("Current priority:", staminaBar.priority)
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.bar.add></a>lia.bar.add(getValue, color, priority, identifier)</summary>
<a id="liabaradd"></a>
<p>Register a new dynamic bar with optional priority and identifier.</p>
<p>Client HUD setup or when creating temporary action/status bars.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">getValue</span> Returns current fraction (0-1) when called.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> <span class="optional">optional</span> Bar color; random bright color if nil.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">priority</span> <span class="optional">optional</span> Lower draws earlier; defaults to append order.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> <span class="optional">optional</span> Unique id; replaces existing bar with same id.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Priority used for the bar.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Add a stamina bar that fades after inactivity.
    lia.bar.add(function()
        local client = LocalPlayer()
        local stamina = client:getLocalVar("stm", 100)
        return math.Clamp(stamina / 100, 0, 1)
    end, Color(120, 200, 80), 2, "stamina")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.bar.remove></a>lia.bar.remove(identifier)</summary>
<a id="liabarremove"></a>
<p>Remove a bar by its identifier.</p>
<p>After a timed action completes or when disabling a HUD element.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> Unique id passed during add.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    timer.Simple(5, function() lia.bar.remove("stamina") end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.bar.drawBar></a>lia.bar.drawBar(pos, max, color)</summary>
<a id="liabardrawbar"></a>
<p>Draw a single bar at a position with given fill and color.</p>
<p>Internally from drawAll or for custom bars in panels.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">pos</span> Current value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">max</span> Maximum value.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Fill color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Custom panel painting a download progress bar.
    function PANEL:Paint(w, h)
        lia.bar.drawBar(10, h - 24, w - 20, 16, self.progress, 1, Color(120, 180, 255))
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.bar.drawAction></a>lia.bar.drawAction(text, duration)</summary>
<a id="liabardrawaction"></a>
<p>Show a centered action bar with text and timed progress.</p>
<p>For timed actions like searching, hacking, or channeling abilities.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Label to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">duration</span> Seconds to run before auto-removal.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnStartSearch", "ShowSearchBar", function(duration)
        lia.bar.drawAction(L("searchingChar"), duration)
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.bar.drawAll></a>lia.bar.drawAll()</summary>
<a id="liabardrawall"></a>
<p>Render all registered bars with smoothing, lifetimes, and ordering.</p>
<p>Each HUDPaintBackground (hooked at bottom of file).</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Bars are drawn automatically via the HUDPaintBackground hook.
    -- For custom derma panels, you could manually call lia.bar.drawAll().
</code></pre>
</details>

---

