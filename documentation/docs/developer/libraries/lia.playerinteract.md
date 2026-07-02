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

# Player Interactions

Player interaction and personal action helpers for registering, syncing, categorizing, and opening interaction menu options.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The player interaction library centralizes menu-driven player interactions under `lia.playerinteract`. It stores registered interactions and personal actions, groups options by category, synchronizes safe option metadata to clients, opens the clientside options menu, and provides built-in money transfer and voice mode actions.
</div>

---

<details class="realm-shared" id="function-liaplayerinteractiswithinrange">
<summary><span class="summary-main"><a id="lia.playerinteract.isWithinRange"></a>lia.playerinteract.isWithinRange(client, entity, customRange)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L67" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractiswithinrange"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether an entity is within interaction range of a client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player being used as the range origin.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The entity being checked against the client.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">customRange</span> <span class="optional">optional</span> Optional distance override. Defaults to 100 units.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if both entities are valid and the target is within range, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.playerinteract.isWithinRange(client, target, 150) then
      client:notifyInfo("Target is close enough.")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaplayerinteractgetinteractions">
<summary><span class="summary-main"><a id="lia.playerinteract.getInteractions"></a>lia.playerinteract.getInteractions(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L96" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractgetinteractions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets interaction options available for the entity currently traced by a client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player whose traced entity should be checked. Defaults to LocalPlayer on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of available interaction definitions keyed by interaction name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local interactions = lia.playerinteract.getInteractions(LocalPlayer())
  for name, interaction in pairs(interactions) do
      print(name, interaction.category)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaplayerinteractgetactions">
<summary><span class="summary-main"><a id="lia.playerinteract.getActions"></a>lia.playerinteract.getActions(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L135" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractgetactions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets personal action options available to a client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player whose personal actions should be checked. Defaults to LocalPlayer on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of available action definitions keyed by action name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local actions = lia.playerinteract.getActions(LocalPlayer())
  for name, action in pairs(actions) do
      print(name, action.category)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaplayerinteractgetcategorizedoptions">
<summary><span class="summary-main"><a id="lia.playerinteract.getCategorizedOptions"></a>lia.playerinteract.getCategorizedOptions(options)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L168" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractgetcategorizedoptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds a display-ready option list grouped by category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> The option entries to categorize. Each entry may include an `opt.category` value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A sequential table containing category header entries followed by the options in each category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local categorized = lia.playerinteract.getCategorizedOptions(options)
  for _, entry in ipairs(categorized) do
      if entry.isCategory then print(entry.name, entry.count) end
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaplayerinteractaddinteraction">
<summary><span class="summary-main"><a id="lia.playerinteract.addInteraction"></a>lia.playerinteract.addInteraction(name, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L230" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractaddinteraction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a target-based interaction option.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Unique interaction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Interaction definition. Supports fields such as `category`, `target`, `range`, `shouldShow`, `onRun`, `serverOnly`, `timeToComplete`, `actionText`, `targetActionText`, and `categoryColor`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.playerinteract.addInteraction("inspectTarget", {
      target = "player",
      category = "@categoryGeneral",
      shouldShow = function(client, target) return target:IsPlayer() end,
      onRun = function(client, target) client:notifyInfo(target:Name()) end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaplayerinteractaddaction">
<summary><span class="summary-main"><a id="lia.playerinteract.addAction"></a>lia.playerinteract.addAction(name, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L280" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractaddaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a personal action option.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Unique action identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Action definition. Supports fields such as `category`, `range`, `shouldShow`, `onRun`, `serverOnly`, `timeToComplete`, `actionText`, `targetActionText`, and `categoryColor`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.playerinteract.addAction("toggleHelmet", {
      category = "@categoryGeneral",
      shouldShow = function(client) return client:getChar() ~= nil end,
      onRun = function(client) client:notifyInfo("Helmet toggled.") end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaplayerinteractsync">
<summary><span class="summary-main"><a id="lia.playerinteract.sync"></a>lia.playerinteract.sync(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L323" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractsync"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Synchronizes registered player interaction metadata and categories to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Optional player to synchronize. When omitted, all connected players are synchronized in small batches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.playerinteract.sync(client)
  lia.playerinteract.sync()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaplayerinteracthaschanges">
<summary><span class="summary-main"><a id="lia.playerinteract.hasChanges"></a>lia.playerinteract.hasChanges()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L386" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteracthaschanges"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether registered interactions or categories have changed since the last full synchronization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the stored interaction count or category count differs from the last synchronized counts.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.playerinteract.hasChanges() then
      lia.playerinteract.sync()
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaplayerinteractopenmenu">
<summary><span class="summary-main"><a id="lia.playerinteract.openMenu"></a>lia.playerinteract.openMenu(options, isInteraction, titleText, closeKey, netMsg, preFiltered)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L502" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaplayerinteractopenmenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens the clientside player interaction or personal action options menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> Options to display in the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isInteraction</span> True for target interactions, false for personal actions.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">titleText</span> <span class="optional">optional</span> Optional menu title text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">closeKey</span> <span class="optional">optional</span> Optional key code used to close the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">netMsg</span> <span class="optional">optional</span> Optional network message used when an option is selected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">preFiltered</span> <span class="optional">optional</span> Whether the supplied options were already filtered before opening the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel|nil</a></span> The created options menu panel, or nil if the local player is invalid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.playerinteract.openMenu(options, true, L("interactionMenu"), KEY_TAB, "liaRunInteraction", true)
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

<details class="realm-server" id="function-onvoicetypechanged">
<summary><span class="summary-main"><a id="OnVoiceTypeChanged"></a>OnVoiceTypeChanged(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/playerinteract.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onvoicetypechanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a client changes their voice mode through a player interaction action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Player Interaction</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose voice mode changed.</p>
</div>

</div>
</details>

---

