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

# Class

Character class helpers for registering, loading, retrieving, counting, validating, and resolving playable classes.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The class library centralizes shared character class behavior under `lia.class`. It stores class definitions in `lia.class.list`, loads class files, validates whether a player can join a class, resolves class identifiers, manages whitelist checks, reports class membership counts, and applies default or overridden bodygroups for characters.
</div>

---

<details class="realm-shared" id="function-liaclassgetbodygroups">
<summary><span class="summary-main"><a id="lia.class.getBodygroups"></a>lia.class.getBodygroups(class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L63" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassgetbodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the normalized bodygroup table configured for a class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|number|string</a></span> <span class="parameter">class</span> Class data table or class identifier used to look up registered class data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Normalized bodygroup values from `bodyGroups` or `bodygroups`, or an empty table when no class data exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local bodygroups = lia.class.getBodygroups(CLASS_CITIZEN)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassgetmergedbodygroups">
<summary><span class="summary-main"><a id="lia.class.getMergedBodygroups"></a>lia.class.getMergedBodygroups(character)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L89" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassgetmergedbodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds the effective bodygroup table for a character by combining class defaults with character-specific overrides.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/char/">Character</a></span> <span class="parameter">character</span> Character whose class bodygroups and stored bodygroup overrides should be merged.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Merged normalized bodygroup table where character overrides take priority over class defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local bodygroups = lia.class.getMergedBodygroups(character)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassregister">
<summary><span class="summary-main"><a id="lia.class.register"></a>lia.class.register(uniqueID, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L134" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers or updates a character class with a unique identifier and class data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Unique string identifier for the class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Class definition data to store, including a valid `faction` value and optional class configuration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Registered class index, or nil if registration fails because the class has no valid faction. table|nil Registered class table, or nil if registration fails because the class has no valid faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classIndex = lia.class.register("medic", {
      name = "Medic",
      desc = "A trained field medic.",
      faction = FACTION_CITIZEN
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassloadfromdir">
<summary><span class="summary-main"><a id="lia.class.loadFromDir"></a>lia.class.loadFromDir(directory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L195" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassloadfromdir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads class definition files from a directory and adds valid class definitions to the registered class list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">directory</span> Lua directory path containing class files to load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.class.loadFromDir("schema/classes")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclasscanbe">
<summary><span class="summary-main"><a id="lia.class.canBe"></a>lia.class.canBe(client, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L260" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclasscanbe"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a player is allowed to join a specific class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> Player being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> Class index being checked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the player can join the class, otherwise false. string|nil Localized failure reason when class validation fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local canJoin, reason = lia.class.canBe(client, CLASS_MEDIC)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassget">
<summary><span class="summary-main"><a id="lia.class.get"></a>lia.class.get(identifier)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L299" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves registered class data by identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">identifier</span> Class list key used to retrieve the class data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Registered class data when found, otherwise nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classData = lia.class.get(CLASS_MEDIC)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassgetplayers">
<summary><span class="summary-main"><a id="lia.class.getPlayers"></a>lia.class.getPlayers(class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L324" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassgetplayers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns all players whose active character is assigned to a class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> Class index to match against active characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table of players currently in the class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local medics = lia.class.getPlayers(CLASS_MEDIC)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassgetplayercount">
<summary><span class="summary-main"><a id="lia.class.getPlayerCount"></a>lia.class.getPlayerCount(class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L354" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassgetplayercount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Counts players whose active character is assigned to a class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> Class index to count.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Number of players currently in the class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local medicCount = lia.class.getPlayerCount(CLASS_MEDIC)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassretrieveclass">
<summary><span class="summary-main"><a id="lia.class.retrieveClass"></a>lia.class.retrieveClass(class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L384" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassretrieveclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds a registered class index by matching a class unique ID or display name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">class</span> Class unique ID or class name to search for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Matching class index when found, otherwise nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classIndex = lia.class.retrieveClass("medic")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclasshaswhitelist">
<summary><span class="summary-main"><a id="lia.class.hasWhitelist"></a>lia.class.hasWhitelist(class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L414" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclasshaswhitelist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a class requires whitelist access.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> Class index to check.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the class requires whitelist access, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.class.hasWhitelist(CLASS_MEDIC) then
      client:notifyInfo("This class requires whitelist access.")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaclassretrievejoinable">
<summary><span class="summary-main"><a id="lia.class.retrieveJoinable"></a>lia.class.retrieveJoinable(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L443" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaclassretrievejoinable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns classes that a player is currently eligible to join.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player to check. Defaults to the local player on the client when omitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table of class data tables that the player can join.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classes = lia.class.retrieveJoinable(client)
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

<details class="realm-shared" id="function-canplayerjoinclass">
<summary><span class="summary-main"><a id="CanPlayerJoinClass"></a>CanPlayerJoinClass(client, class, classData)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/classes.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerjoinclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to block a player from joining a class during class eligibility checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Classes</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to join the class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> The class index being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">classData</span> The registered class data for the class being checked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to prevent the player from joining the class. Return nil or any non-false value to continue normal class validation.</p>
</div>

</div>
</details>

---

