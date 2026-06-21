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

# Menu

Clientside helpers for world-anchored interaction menus.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The menu library manages temporary clientside option menus under `lia.menu`. Menus are anchored to either a world position or an entity-local position, drawn near their projected screen position, faded based on range and crosshair focus, and resolved into callbacks when the active option is selected.
</div>

---

<details class="realm-client" id="function-liamenuadd">
<summary><span class="summary-main"><a id="lia.menu.add"></a>lia.menu.add(opts, pos, onRemove)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/menu.lua#L85" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenuadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds a temporary clientside menu using the provided option table and anchor position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">opts</span> A table where each key is the label displayed in the menu and each value is the callback or payload associated with that option.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector|Entity</a></span> <span class="parameter">pos</span> <span class="optional">optional</span> The world position used to anchor the menu. If an entity is provided, the current eye trace hit position is stored relative to that entity. If nil, the local player's current eye trace hit position is used.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">onRemove</span> <span class="optional">optional</span> Optional function called with the menu data as self when the menu is automatically removed during drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The index of the inserted menu entry in `lia.menu.list`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.menu.add({
      Search = function() print("search") end,
      Unlock = function() print("unlock") end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenudrawall">
<summary><span class="summary-main"><a id="lia.menu.drawAll"></a>lia.menu.drawAll()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/menu.lua#L141" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenudrawall"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws every active menu, updates fade state, highlights the option under the screen center, and removes expired or invalid entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("HUDPaint", "liaMenuDrawAll", function()
      lia.menu.drawAll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenugetactivemenu">
<summary><span class="summary-main"><a id="lia.menu.getActiveMenu"></a>lia.menu.getActiveMenu()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/menu.lua#L209" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenugetactivemenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets the menu option currently targeted by the screen center while the local player is within interaction distance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> The active menu index, or nil if no menu option is active. any|nil The callback or payload associated with the active option, or nil if no menu option is active.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local id, callback = lia.menu.getActiveMenu()
  if id then lia.menu.onButtonPressed(id, callback) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenuonbuttonpressed">
<summary><span class="summary-main"><a id="lia.menu.onButtonPressed"></a>lia.menu.onButtonPressed(id, cb)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/menu.lua#L259" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenuonbuttonpressed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a menu entry and runs the selected option callback when one is provided.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The menu index to remove from `lia.menu.list`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Optional callback to run after the menu entry is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if a callback was provided and executed, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local id, callback = lia.menu.getActiveMenu()
  if id then
      lia.menu.onButtonPressed(id, callback)
  end
</code></pre>
</div>

</div>
</details>

---

