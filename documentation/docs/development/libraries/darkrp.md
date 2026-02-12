# DarkRP

The DarkRP compatibility library provides essential functions for maintaining compatibility

---

<details class="realm-server" id="function-liadarkrpisempty">
<summary><a id="lia.darkrp.isEmpty"></a>lia.darkrp.isEmpty(position, entitiesToIgnore)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpisempty"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine whether a position is free of solid contents, players, NPCs, or props.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before spawning DarkRP-style shipments or entities to ensure the destination is clear.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">position</span> World position to test.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entitiesToIgnore</span> <span class="optional">optional</span> Optional list of entities that should be excluded from the collision check.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true when the spot contains no blocking contents or entities; otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local spawnPos = ent:GetPos() + Vector(0, 0, 16)
  if lia.darkrp.isEmpty(spawnPos) then
      lia.darkrp.createEntity("Ammo Crate", {ent = "item_ammo_crate", model = "models/Items/ammocrate_smg1.mdl"})
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadarkrpfindemptypos">
<summary><a id="lia.darkrp.findEmptyPos"></a>lia.darkrp.findEmptyPos(startPos, entitiesToIgnore, maxDistance, searchStep, checkArea)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpfindemptypos"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Locate the nearest empty position around a starting point within a search radius.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selecting safe fallback positions for DarkRP-style shipments or NPC spawns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">startPos</span> Origin position to test first.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entitiesToIgnore</span> <span class="optional">optional</span> Optional list of entities to ignore while searching.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxDistance</span> Maximum distance to search away from the origin.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">searchStep</span> Increment used when expanding the search radius.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">checkArea</span> Additional offset tested to ensure enough clearance (for hull height, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> First empty position discovered; if none found, returns startPos.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local spawnPos = lia.darkrp.findEmptyPos(requestPos, nil, 256, 16, Vector(0, 0, 32))
  npc:SetPos(spawnPos)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadarkrpnotify">
<summary><a id="lia.darkrp.notify"></a>lia.darkrp.notify(client, notifyType, duration, message)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpnotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide a DarkRP-compatible wrapper for Lilia's localized notify system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From DarkRP addons or compatibility code that expects DarkRP.notify to exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Recipient of the notification.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">notifyType</span> Unused legacy parameter kept for API parity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">duration</span> Unused legacy parameter kept for API parity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Localization key or message to pass to Lilia's notifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.darkrp.notify(ply, NOTIFY_GENERIC, 4, "You received a paycheck.")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadarkrptextwrap">
<summary><a id="lia.darkrp.textWrap"></a>lia.darkrp.textWrap(text, fontName, maxLineWidth)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrptextwrap"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Wrap long text to a maximum line width based on the active surface font metrics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Preparing DarkRP-compatible messages for HUD or chat rendering without overflow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> Message to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fontName</span> Name of the font to measure.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxLineWidth</span> Maximum pixel width allowed per line before inserting a newline.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Wrapped text with newline characters inserted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local wrapped = lia.darkrp.textWrap("A very long notice message...", "DermaDefault", 240)
  chat.AddText(color_white, wrapped)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpformatmoney">
<summary><a id="lia.darkrp.formatMoney"></a>lia.darkrp.formatMoney(amount)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpformatmoney"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Format a currency amount using Lilia's currency system while matching DarkRP's API.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Anywhere DarkRP.formatMoney is expected by compatibility layers or addons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> Currency amount to format.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Localized and formatted currency string.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local paycheck = DarkRP.formatMoney(500)
  chat.AddText(L("paydayReceived", paycheck))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpcreateentity">
<summary><a id="lia.darkrp.createEntity"></a>lia.darkrp.createEntity(name, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpcreateentity"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a DarkRP entity definition as a Lilia item for compatibility.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While converting DarkRP shipments or entities into Lilia items at load time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Display name for the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Supported fields: cmd, ent, model, desc, price, category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.darkrp.createEntity("Ammo Crate", {
      ent = "item_ammo_crate",
      model = "models/Items/ammocrate_smg1.mdl",
      price = 750,
      category = "Supplies"
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadarkrpcreatecategory">
<summary><a id="lia.darkrp.createCategory"></a>lia.darkrp.createCategory()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadarkrpcreatecategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide an API stub for DarkRP category creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Invoked by DarkRP.createCategory during addon initialization; intentionally no-op.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- API parity only; this function performs no actions.
  lia.darkrp.createCategory()
</code></pre>
</div>

</div>
</details>

---

