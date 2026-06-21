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

# DarkRP

DarkRP compatibility helpers for Lilia, including spawn position checks, DarkRP-style notifications, currency formatting, entity item generation, command registration adapters, door keyvalue handling, and RPExtraTeams synchronization.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The DarkRP compatibility library provides shim functions and tables expected by DarkRP-style addons while routing supported behavior through Lilia systems. It exposes `lia.darkrp` helpers for empty-position checks, text wrapping, notifications, currency formatting, entity item registration, and category compatibility, then maps selected helpers onto the global `DarkRP` table for addon compatibility.
</div>

---

<details class="realm-server" id="function-liadarkrpisempty">
<summary><span class="summary-main"><a id="lia.darkrp.isEmpty"></a>lia.darkrp.isEmpty(position, entitiesToIgnore)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L79" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpisempty"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a position is clear of solid contents and nearby blocking entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">position</span> The world position to check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entitiesToIgnore</span> <span class="optional">optional</span> Optional list of entities that should not cause the position to be considered occupied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the position is clear, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local position = lia.darkrp.isEmpty(client:GetPos(), {client})
  print(position)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadarkrpfindemptypos">
<summary><span class="summary-main"><a id="lia.darkrp.findEmptyPos"></a>lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L127" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpfindemptypos"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds the nearest clear position around a starting point by checking offsets along each axis.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">startPos</span> The preferred world position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entitiesToIgnore</span> <span class="optional">optional</span> Optional list of entities ignored by the occupancy checks.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxDistance</span> The maximum distance from the starting position to search.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">searchStep</span> The distance increment used while searching outward.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">checkArea</span> Additional offset checked from each candidate position to confirm clearance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> The first clear position found, or the starting position if no clear offset is found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local position = lia.darkrp.findEmptyPos(client:GetPos(), {client}, 600, 30, Vector(0, 0, 72))
  client:SetPos(position)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadarkrpnotify">
<summary><span class="summary-main"><a id="lia.darkrp.notify"></a>lia.darkrp.notify(client, notifyType, duration, message)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L168" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpnotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a DarkRP-compatible notification through Lilia's localized notification system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player receiving the notification.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">notifyType</span> <span class="optional">optional</span> DarkRP notification type value accepted for compatibility but not used by this shim.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">duration</span> <span class="optional">optional</span> DarkRP notification duration accepted for compatibility but not used by this shim.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The localization key or message passed to the notification system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.darkrp.notify(client, 0, 4, "someLocalizationKey")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadarkrptextwrap">
<summary><span class="summary-main"><a id="lia.darkrp.textWrap"></a>lia.darkrp.textWrap(text, fontName, maxLineWidth)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L213" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrptextwrap"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Wraps text to fit within a maximum pixel width using Garry's Mod surface font measurements.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fontName</span> The surface font used to measure the text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxLineWidth</span> The maximum line width in pixels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The wrapped text with newline breaks inserted where needed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local text = lia.darkrp.textWrap("Long text", "DermaDefault", 200)
  print(text)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpformatmoney">
<summary><span class="summary-main"><a id="lia.darkrp.formatMoney"></a>lia.darkrp.formatMoney(amount)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L263" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpformatmoney"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Formats a numeric amount using Lilia's configured currency formatter.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> The amount of money to format.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The formatted currency string.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  client:notifyInfo(lia.darkrp.formatMoney(250))
  print(lia.darkrp.formatMoney(1))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpcreateentity">
<summary><span class="summary-main"><a id="lia.darkrp.createEntity"></a>lia.darkrp.createEntity(name, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L311" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpcreateentity"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a DarkRP-style entity definition as a Lilia item using the `base_entities` item base.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The display name of the entity item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Entity definition data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.darkrp.createEntity("Money Printer", {
      ent = "money_printer",
      model = "models/props_c17/consolebox01a.mdl",
      price = 500
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpcreatecategory">
<summary><span class="summary-main"><a id="lia.darkrp.createCategory"></a>lia.darkrp.createCategory()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L338" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpcreatecategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides a no-op DarkRP category compatibility function.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.darkrp.createCategory()
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-server" id="function-entitykeyvalue">
<summary><span class="summary-main"><a id="EntityKeyValue"></a>EntityKeyValue(entity, key, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="entitykeyvalue"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Applies supported DarkRP door keyvalues to Lilia door data when map entities receive key-value pairs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The entity receiving the keyvalue.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The keyvalue name being applied.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">value</span> The keyvalue value being applied.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedmodules">
<summary><span class="summary-main"><a id="InitializedModules"></a>InitializedModules()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/darkrp.lua#L37" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedmodules"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Copies Lilia faction indices into `RPExtraTeams` and assigns each copied faction its DarkRP-compatible team index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

</div>
</details>

---

