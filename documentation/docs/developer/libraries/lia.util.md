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

# Utility

General-purpose helpers for Lilia bodygroups, player lookup, entity ownership queries, world-space placement, string formatting, cached materials, table UI handling, and clientside drawing utilities.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The utility library centralizes common helpers under `lia.util`. Shared helpers normalize and apply bodygroups, find players and player-owned entities, format strings, cache materials, resolve factions, generate names, and register feature-position callbacks. Server-only helpers send table UI data and find open world positions. Client-only helpers provide menu animation, blur effects, text wrapping, table UI creation, world text drawing, and feature-position interactions.
</div>

---

<details class="realm-shared" id="function-liautilnormalizebodygroupkey">
<summary><span class="summary-main"><a id="lia.util.normalizeBodygroupKey"></a>lia.util.normalizeBodygroupKey(key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L35" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilnormalizebodygroupkey"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Normalizes a bodygroup identifier into either a numeric bodygroup index or a trimmed bodygroup name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">key</span> The bodygroup key to normalize. Numeric values and numeric strings are converted to numbers; non-empty strings are trimmed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|nil</a></span> The normalized bodygroup index or name. Returns nil when the key cannot be normalized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local key = lia.util.normalizeBodygroupKey("  headgear  ")
  local numericKey = lia.util.normalizeBodygroupKey("2")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilresolvebodygroupindex">
<summary><span class="summary-main"><a id="lia.util.resolveBodygroupIndex"></a>lia.util.resolveBodygroupIndex(target, identifier)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L64" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilresolvebodygroupindex"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves a bodygroup identifier against an entity or player into a numeric bodygroup index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|Player</a></span> <span class="parameter">target</span> The entity whose bodygroups should be checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">identifier</span> The bodygroup index, numeric string, or bodygroup name to resolve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> The resolved bodygroup index. Returns nil when the target is invalid or the identifier cannot be matched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local index = lia.util.resolveBodygroupIndex(client, "headgear")
  if index then client:SetBodygroup(index, 1) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilnormalizebodygroups">
<summary><span class="summary-main"><a id="lia.util.normalizeBodygroups"></a>lia.util.normalizeBodygroups(bodygroups)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L98" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilnormalizebodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Converts supported bodygroup table formats into a simple identifier-to-value lookup table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">bodygroups</span> A bodygroup table containing array entries, keyed values, or both.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A normalized table where each key is a bodygroup identifier and each value is a numeric bodygroup value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local bodygroups = lia.util.normalizeBodygroups({{name = "headgear", value = 1}, [2] = 0})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilresolvebodygroups">
<summary><span class="summary-main"><a id="lia.util.resolveBodygroups"></a>lia.util.resolveBodygroups(target, bodygroups)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L138" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilresolvebodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves a bodygroup table into numeric bodygroup indices for a specific target entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|Player</a></span> <span class="parameter">target</span> The entity whose bodygroups should be resolved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">bodygroups</span> The bodygroup data to normalize and resolve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of resolved numeric bodygroup indices mapped to numeric bodygroup values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local resolved = lia.util.resolveBodygroups(client, {headgear = 1})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilapplybodygroups">
<summary><span class="summary-main"><a id="lia.util.applyBodygroups"></a>lia.util.applyBodygroups(target, bodygroups)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L169" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilapplybodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Applies bodygroup values to a valid entity after resolving bodygroup names or identifiers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|Player</a></span> <span class="parameter">target</span> The entity receiving the bodygroup changes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">bodygroups</span> The bodygroup data to apply.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The resolved bodygroups that were applied. Returns an empty table when the target is invalid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.applyBodygroups(client, {headgear = 1, [2] = 0})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayersinbox">
<summary><span class="summary-main"><a id="lia.util.findPlayersInBox"></a>lia.util.findPlayersInBox(mins, maxs)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L200" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayersinbox"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds all players inside an axis-aligned world-space box.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">mins</span> The minimum corner of the search box.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">maxs</span> The maximum corner of the search box.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing every valid player found inside the box.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local players = lia.util.findPlayersInBox(Vector(-128, -128, 0), Vector(128, 128, 128))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilrequestentityinformation">
<summary><span class="summary-main"><a id="lia.util.requestEntityInformation"></a>lia.util.requestEntityInformation(client, entity, argTypes, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L237" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilrequestentityinformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Requests argument input from a client for an entity and removes the entity if the request is cancelled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player receiving the argument request.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The entity associated with the request.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">argTypes</span> The argument definitions passed to `client:requestArguments`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional callback called with the submitted information when the request succeeds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.requestEntityInformation(client, entity, args, function(information)
      entity.information = information
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilgetbysteamid">
<summary><span class="summary-main"><a id="lia.util.getBySteamID"></a>lia.util.getBySteamID(steamID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L272" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilgetbysteamid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds an online player with an active character by SteamID or SteamID64.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">steamID</span> The SteamID or SteamID64 to search for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|nil</a></span> The matching player with a loaded character, or nil when no match is found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local client = lia.util.getBySteamID("STEAM_0:1:123456")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayersinsphere">
<summary><span class="summary-main"><a id="lia.util.findPlayersInSphere"></a>lia.util.findPlayersInSphere(origin, radius)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L303" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayersinsphere"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds all players within a radius of a world position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">origin</span> The center point of the sphere.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">radius</span> The search radius in Source units.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing players within the radius.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local nearby = lia.util.findPlayersInSphere(entity:GetPos(), 256)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayer">
<summary><span class="summary-main"><a id="lia.util.findPlayer"></a>lia.util.findPlayer(client, identifier)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L335" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves a player from a command-style identifier, SteamID, SteamID64, self marker, trace marker, or partial name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player performing the lookup. Used for `^`, `@`, and localized error notifications.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">identifier</span> The player identifier to resolve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|nil</a></span> The matching player, or nil when no valid player is found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local target = lia.util.findPlayer(client, "@")
  local byName = lia.util.findPlayer(client, "samael")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayeritems">
<summary><span class="summary-main"><a id="lia.util.findPlayerItems"></a>lia.util.findPlayerItems(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L397" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayeritems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds all spawned item entities created by a specific player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose created item entities should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing matching item entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local items = lia.util.findPlayerItems(client)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayeritemsbyclass">
<summary><span class="summary-main"><a id="lia.util.findPlayerItemsByClass"></a>lia.util.findPlayerItemsByClass(client, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L427" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayeritemsbyclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds spawned item entities created by a player that match a specific item ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose created item entities should be searched.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">class</span> The item ID stored in the entity network variable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing matching item entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local radios = lia.util.findPlayerItemsByClass(client, "handheld_radio")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayerentities">
<summary><span class="summary-main"><a id="lia.util.findPlayerEntities"></a>lia.util.findPlayerEntities(client, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L458" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayerentities"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds entities created by, or assigned to, a specific player, optionally filtered by entity class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose entities should be found.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Optional entity class filter.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing matching entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local doors = lia.util.findPlayerEntities(client, "prop_door_rotating")
  local owned = lia.util.findPlayerEntities(client)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilstringmatches">
<summary><span class="summary-main"><a id="lia.util.stringMatches"></a>lia.util.stringMatches(a, b)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L490" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilstringmatches"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Performs a case-sensitive and case-insensitive substring or exact-string comparison.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">a</span> The source string to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">b</span> The string or pattern-safe fragment to look for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the strings match exactly or when `b` is found within `a`; otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.util.stringMatches(client:Name(), "sam") then
      print(client:Name())
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilgetadmins">
<summary><span class="summary-main"><a id="lia.util.getAdmins"></a>lia.util.getAdmins()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L522" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilgetadmins"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Collects all online players that pass the framework staff check.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing online staff players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, staff in ipairs(lia.util.getAdmins()) do
      staff:notify("Staff notice")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayerbysteamid64">
<summary><span class="summary-main"><a id="lia.util.findPlayerBySteamID64"></a>lia.util.findPlayerBySteamID64(SteamID64)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L551" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayerbysteamid64"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds an online player by converting a SteamID64 into a SteamID first.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">SteamID64</span> The SteamID64 to convert and search for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|nil</a></span> The matching player, or nil when conversion fails or no player matches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local client = lia.util.findPlayerBySteamID64("76561198000000000")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindplayerbysteamid">
<summary><span class="summary-main"><a id="lia.util.findPlayerBySteamID"></a>lia.util.findPlayerBySteamID(SteamID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L577" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindplayerbysteamid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds an online player by SteamID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">SteamID</span> The SteamID to search for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|nil</a></span> The matching player, or nil when no player matches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local client = lia.util.findPlayerBySteamID("STEAM_0:1:123456")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilcanfit">
<summary><span class="summary-main"><a id="lia.util.canFit"></a>lia.util.canFit(pos, mins, maxs, filter)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L612" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilcanfit"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a hull can fit at a world position without hitting player-solid geometry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The position to test.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">mins</span> <span class="optional">optional</span> Optional hull minimums. Defaults to `Vector(16, 16, 0)` and is inverted when positive.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">maxs</span> <span class="optional">optional</span> Optional hull maximums. Defaults to `mins`.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|table</a></span> <span class="parameter">filter</span> <span class="optional">optional</span> Optional trace filter.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the hull does not hit anything; otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.util.canFit(spawnPos, nil, nil, client) then
      client:SetPos(spawnPos)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilplayerinradius">
<summary><span class="summary-main"><a id="lia.util.playerInRadius"></a>lia.util.playerInRadius(pos, dist)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L647" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilplayerinradius"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds valid players within a radius of a world position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The center of the search area.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">dist</span> The radius to search, in Source units.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing players inside the radius.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local players = lia.util.playerInRadius(entity:GetPos(), 128)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilformatstringnamed">
<summary><span class="summary-main"><a id="lia.util.formatStringNamed"></a>lia.util.formatStringNamed(format)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L679" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilformatstringnamed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Replaces `{name}` or ordered placeholder tokens in a string with table or vararg values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">format</span> The format string containing `{token}` placeholders.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The formatted string with placeholders replaced.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local text = lia.util.formatStringNamed("Hello, {name}", {name = client:Name()})
  local ordered = lia.util.formatStringNamed("{first} {second}", "Hello", "World")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilgetmaterial">
<summary><span class="summary-main"><a id="lia.util.getMaterial"></a>lia.util.getMaterial(materialPath, materialParameters)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L720" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilgetmaterial"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a cached material instance for a material path and optional material parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">materialPath</span> The material path to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">materialParameters</span> <span class="optional">optional</span> Optional material parameters passed to `Material` on first load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> The cached or newly created material.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local blur = lia.util.getMaterial("pp/blurscreen")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilfindfaction">
<summary><span class="summary-main"><a id="lia.util.findFaction"></a>lia.util.findFaction(client, name)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L748" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindfaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds a faction by numeric/team key, name, or unique ID, and notifies the client when no match is found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player to notify when the faction cannot be found.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">name</span> The faction key, display name, or unique ID to search for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The matching faction table, or nil when no faction matches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local faction = lia.util.findFaction(client, "citizen")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilgeneraterandomname">
<summary><span class="summary-main"><a id="lia.util.generateRandomName"></a>lia.util.generateRandomName(firstNames, lastNames)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L852" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilgeneraterandomname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Generates a random full name from provided first-name and last-name lists or built-in fallback lists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">firstNames</span> <span class="optional">optional</span> Optional list of first names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">lastNames</span> <span class="optional">optional</span> Optional list of last names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> A generated first-name and last-name combination.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local name = lia.util.generateRandomName()
  local custom = lia.util.generateRandomName({"Alex"}, {"Morgan"})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liautilsetpositioncallback">
<summary><span class="summary-main"><a id="lia.util.setPositionCallback"></a>lia.util.setPositionCallback(name, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L891" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilsetpositioncallback"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers or updates a named feature-position callback definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The display name for the position callback.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Callback data containing `onRun`, `onSelect`, and optional `onRemove`, `HUDPaint`, `serverOnly`, and `color` fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.setPositionCallback("Vendor Spawn", {
      onRun = function(pos, client, typeId) end,
      onSelect = function() end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liautilsendtableui">
<summary><span class="summary-main"><a id="lia.util.sendTableUI"></a>lia.util.sendTableUI(client, title, columns, data, options, characterID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L958" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilsendtableui"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends localized table UI data to a player through the large-table networking helper.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who should receive the table UI.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Optional localization key for the table title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">columns</span> Column definitions, with names localized before sending.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Row data for the table UI.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> <span class="optional">optional</span> Optional row action definitions.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">characterID</span> <span class="optional">optional</span> Optional character ID associated with row actions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.sendTableUI(client, "players", columns, rows, options, client:getChar():getID())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liautilfindemptyspace">
<summary><span class="summary-main"><a id="lia.util.findEmptySpace"></a>lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1009" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilfindemptyspace"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds nearby empty world positions around an entity using trace checks and distance sorting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The entity used as the search origin and default filter.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|table</a></span> <span class="parameter">filter</span> <span class="optional">optional</span> Optional trace filter. Defaults to the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">spacing</span> <span class="optional">optional</span> Distance between checked grid positions. Defaults to 32.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">size</span> <span class="optional">optional</span> Number of grid steps to search in each direction. Defaults to 3.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">height</span> <span class="optional">optional</span> Height used for vertical trace checks. Defaults to 36.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">tolerance</span> <span class="optional">optional</span> Vertical offset used to avoid immediate ground contact. Defaults to 5.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A distance-sorted table of valid empty positions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local positions = lia.util.findEmptySpace(entity, client, 32, 4)
  local nearest = positions[1]
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilanimateappearance">
<summary><span class="summary-main"><a id="lia.util.animateAppearance"></a>lia.util.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1079" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilanimateappearance"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Animates a panel from a scaled, transparent state to its target size, position, and full opacity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel to animate.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">targetWidth</span> The final panel width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">targetHeight</span> The final panel height.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">duration</span> <span class="optional">optional</span> Approximate size and position animation duration. Defaults to 0.18.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alphaDuration</span> <span class="optional">optional</span> Approximate alpha animation duration. Defaults to `duration`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional callback called with the panel when the animation finishes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">scaleFactor</span> <span class="optional">optional</span> Initial scale multiplier. Defaults to 0.8.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.animateAppearance(frame, 400, 300, 0.2)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilclampmenuposition">
<summary><span class="summary-main"><a id="lia.util.clampMenuPosition"></a>lia.util.clampMenuPosition(panel)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1143" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilclampmenuposition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Keeps a panel inside the screen bounds and avoids overlapping the character menu logo when present.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel whose position should be clamped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.clampMenuPosition(menu)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawgradient">
<summary><span class="summary-main"><a id="lia.util.drawGradient"></a>lia.util.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1207" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawgradient"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws one of the built-in VGUI gradient materials through the Lilia Derma material helper.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The x position to draw at.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The y position to draw at.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The gradient width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The gradient height.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">direction</span> Gradient material index: up, down, left, or right.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">colorShadow</span> The color used to draw the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">radius</span> <span class="optional">optional</span> Optional rounded radius. Defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional drawing flags passed to the Derma helper.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawGradient(0, 0, 200, 40, 2, Color(0, 0, 0, 180))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilwraptext">
<summary><span class="summary-main"><a id="lia.util.wrapText"></a>lia.util.wrapText(text, width, font)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1237" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilwraptext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Wraps text into multiple lines that fit within a target pixel width for a specific font.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">width</span> The maximum line width in pixels.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">font</span> <span class="optional">optional</span> Font name used for measuring. Defaults to `LiliaFont.16`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>table, number The wrapped lines and the widest measured line width.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local lines, maxWidth = lia.util.wrapText(description, 300, "LiliaFont.16")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawblur">
<summary><span class="summary-main"><a id="lia.util.drawBlur"></a>lia.util.drawBlur(panel, amount, passes, alpha)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1293" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawblur"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a screen-space blur behind a panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel whose screen position determines the blur offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength. Defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Present for compatibility; the function uses a fixed internal pass count.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Blur draw alpha. Defaults to 255.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  frame.Paint = function(self)
      lia.util.drawBlur(self, 4)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawblackblur">
<summary><span class="summary-main"><a id="lia.util.drawBlackBlur"></a>lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1338" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawblackblur"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a blur behind a panel and overlays a dark rectangle over the panel area.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel to draw behind and darken.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength. Defaults to 6.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Number of blur passes. Defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Blur draw alpha. Defaults to 255.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">darkAlpha</span> <span class="optional">optional</span> Alpha for the dark overlay. Defaults to 220.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawBlackBlur(frame, 6, 5, 255, 200)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawblurat">
<summary><span class="summary-main"><a id="lia.util.drawBlurAt"></a>lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1395" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawblurat"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws a localized blur over a rectangular screen area.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The x position of the blur rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The y position of the blur rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The blur rectangle width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The blur rectangle height.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength. Defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Starting blur-loop value. Defaults to 0.2.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Blur draw alpha. Defaults to 255.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawBlurAt(20, 20, 300, 120, 6)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilcreatetableui">
<summary><span class="summary-main"><a id="lia.util.createTableUI"></a>lia.util.createTableUI(title, columns, data, options, charID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1439" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilcreatetableui"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a clientside table window with localized columns, row data, copy support, and optional row actions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Optional localization key for the frame title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">columns</span> Column definitions used to build the table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Row data displayed in the table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> <span class="optional">optional</span> Optional row action definitions that may send net messages.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">charID</span> <span class="optional">optional</span> Character ID written with row action net messages.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Panel, Panel The created frame and table panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local frame, listView = lia.util.createTableUI("players", columns, rows, options, charID)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilopenoptionsmenu">
<summary><span class="summary-main"><a id="lia.util.openOptionsMenu"></a>lia.util.openOptionsMenu(title, options)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1617" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilopenoptionsmenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens a small centered options menu from either an array of option tables or a name-to-callback table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Optional localization key for the menu title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> Options to show. Array entries need `name` and `callback`; keyed entries use the key as the name and value as the callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel|nil</a></span> The created menu frame, or nil when no valid options are provided.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.openOptionsMenu("options", {
      inspect = function() print("Inspect") end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawenttext">
<summary><span class="summary-main"><a id="lia.util.drawEntText"></a>lia.util.drawEntText(ent, text, posY, alphaOverride)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1753" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawenttext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws animated styled text above an entity when the local player is close enough to see it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">ent</span> The entity to draw text above.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">posY</span> <span class="optional">optional</span> Optional screen-space vertical offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alphaOverride</span> <span class="optional">optional</span> Optional alpha multiplier or 0-255 alpha value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawEntText(entity, "Open", 0, 255)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawlooktext">
<summary><span class="summary-main"><a id="lia.util.drawLookText"></a>lia.util.drawLookText(text, posY, alphaOverride, maxDist)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1834" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawlooktext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws animated styled text at the point the local player is looking at within a maximum distance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">posY</span> <span class="optional">optional</span> Optional screen-space vertical offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alphaOverride</span> <span class="optional">optional</span> Optional alpha multiplier or 0-255 alpha value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxDist</span> <span class="optional">optional</span> Maximum trace distance. Defaults to 380.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawLookText("Interact", 0, 255, 256)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilsetfeatureposition">
<summary><span class="summary-main"><a id="lia.util.setFeaturePosition"></a>lia.util.setFeaturePosition(pos, typeId)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1903" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilsetfeatureposition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Defines an empty clientside placeholder for setting a feature position before the implemented definition later in the file replaces it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The position argument accepted by the placeholder.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeId</span> The feature-position callback ID accepted by the placeholder.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This placeholder does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.setFeaturePosition(pos, typeId)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawlooktext">
<summary><span class="summary-main"><a id="lia.util.drawLookText"></a>lia.util.drawLookText(text, posY, alphaOverride, maxDist)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L1932" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawlooktext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws animated styled text at the point the local player is looking at within a maximum distance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">posY</span> <span class="optional">optional</span> Optional screen-space vertical offset.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alphaOverride</span> <span class="optional">optional</span> Optional alpha multiplier or 0-255 alpha value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxDist</span> <span class="optional">optional</span> Maximum trace distance. Defaults to 380.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawLookText("Interact", 0, 255, 256)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilsetfeatureposition">
<summary><span class="summary-main"><a id="lia.util.setFeaturePosition"></a>lia.util.setFeaturePosition(pos, typeId)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L2001" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilsetfeatureposition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs a registered feature-position callback for a clientside position selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The selected world position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeId</span> The registered feature-position callback ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.setFeaturePosition(trace.HitPos, "vendor_spawn")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautilremovefeatureposition">
<summary><span class="summary-main"><a id="lia.util.removeFeaturePosition"></a>lia.util.removeFeaturePosition(pos, typeId)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L2036" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautilremovefeatureposition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes or requests removal of a feature position using the registered callback for a type ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The world position to remove.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeId</span> The registered feature-position callback ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.removeFeaturePosition(trace.HitPos, "vendor_spawn")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liautildrawespstyledtext">
<summary><span class="summary-main"><a id="lia.util.drawESPStyledText"></a>lia.util.drawESPStyledText(text, x, y, espColor, font, fadeAlpha)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/util.lua#L2082" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liautildrawespstyledtext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draws styled ESP text with a themed background, blur, accent bar, and fade alpha.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> The ESP text to draw.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The horizontal screen position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The vertical screen position.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">espColor</span> <span class="optional">optional</span> Optional accent color. Defaults to the active theme accent.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">font</span> Font used to measure and draw the text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">fadeAlpha</span> <span class="optional">optional</span> Alpha multiplier from 0 to 1. Defaults to 1.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The height of the styled text block.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.util.drawESPStyledText("Target", x, y, Color(255, 255, 255), "LiliaFont.24", 1)
</code></pre>
</div>

</div>
</details>

---

