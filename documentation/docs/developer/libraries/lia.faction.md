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

# Faction

Faction helpers for registering factions, loading faction definitions, resolving models, validating character customization, and querying faction membership data.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The faction library centralizes shared faction behavior under `lia.faction`. It stores factions by index and unique ID, registers Garry's Mod teams, resolves localized names and descriptions, prepares faction models, validates skin and bodygroup restrictions, and exposes helpers used during character creation and faction lookups.
</div>

---

<details class="realm-shared" id="function-liafactionregister">
<summary><span class="summary-main"><a id="lia.faction.register"></a>lia.faction.register(uniqueID, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L151" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers or updates a faction and creates its team entry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Stable identifier used to store the faction and create the global FACTION_* constant.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Faction data such as name, description, color, models, weapons, index, and customization settings.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>number, table The faction index and registered faction table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local index, faction = lia.faction.register("citizen", {
      name = "@citizen",
      desc = "@citizenDesc",
      color = Color(150, 150, 150),
      models = {"models/player/group01/male_01.mdl"}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactioncachemodels">
<summary><span class="summary-main"><a id="lia.faction.cacheModels"></a>lia.faction.cacheModels(models)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L211" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactioncachemodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Precaches every usable model found in a faction model table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">models</span> <span class="optional">optional</span> Model table containing string entries or structured model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.faction.cacheModels(faction.models)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionismodelusable">
<summary><span class="summary-main"><a id="lia.faction.isModelUsable"></a>lia.faction.isModelUsable(modelPath)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L240" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionismodelusable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a model path is usable for faction model handling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> Model path to validate.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the value is a non-empty string and passes `util.IsValidModel` when available, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isModelUsable(modelPath) then
      util.PrecacheModel(modelPath)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionnormalizeskinvalue">
<summary><span class="summary-main"><a id="lia.faction.normalizeSkinValue"></a>lia.faction.normalizeSkinValue(skin, fallback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L267" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionnormalizeskinvalue"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Converts a skin value into a numeric skin index with a fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">skin</span> <span class="optional">optional</span> Skin value to normalize.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">fallback</span> <span class="optional">optional</span> Fallback skin index used when the provided value is empty, default, or invalid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The normalized skin index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local skin = lia.faction.normalizeSkinValue(data.skin, 0)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetmodeldata">
<summary><span class="summary-main"><a id="lia.faction.getModelData"></a>lia.faction.getModelData(modelKey, modelData)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L305" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetmodeldata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Parses supported faction model entry formats into a consistent model data table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Model table key, which may also be the model path for keyed model definitions.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> Raw model entry data to parse.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Parsed model data containing `model`, `skin`, `bodygroups`, `allowedSkins`, and `allowedBodygroups`, or nil when the entry is not a model definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local parsed = lia.faction.getModelData(modelKey, modelData)
  if parsed then
      print(parsed.model)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionloadfromdir">
<summary><span class="summary-main"><a id="lia.faction.loadFromDir"></a>lia.faction.loadFromDir(directory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L361" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionloadfromdir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads faction definition files from a directory and registers them into the faction caches.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">directory</span> Directory path searched for Lua faction files.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.faction.loadFromDir("schema/factions")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetall">
<summary><span class="summary-main"><a id="lia.faction.getAll"></a>lia.faction.getAll()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L428" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetall"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns every registered faction as an array.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table containing all registered faction tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, faction in ipairs(lia.faction.getAll()) do
      print(faction.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionget">
<summary><span class="summary-main"><a id="lia.faction.get"></a>lia.faction.get(identifier)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L456" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds a registered faction by numeric index or unique ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">identifier</span> Faction index or unique ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The matching faction table, or nil when no faction exists for the identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local faction = lia.faction.get(FACTION_CITIZEN)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetmodelcustomizationallowed">
<summary><span class="summary-main"><a id="lia.faction.getModelCustomizationAllowed"></a>lia.faction.getModelCustomizationAllowed(client, faction, context)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L486" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetmodelcustomizationallowed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether skin and bodygroup customization are allowed for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose customization permissions are being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">context</span> Optional caller-provided context passed to customization override hooks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, boolean Whether skin customization and bodygroup customization are allowed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local canSkin, canBodygroups = lia.faction.getModelCustomizationAllowed(client, faction, "creation")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetbodygroupnametoindex">
<summary><span class="summary-main"><a id="lia.faction.getBodygroupNameToIndex"></a>lia.faction.getBodygroupNameToIndex(modelPath)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L523" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetbodygroupnametoindex"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds and caches a lowercase bodygroup-name-to-index map for a model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> Model path whose bodygroups should be inspected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Table mapping lowercase bodygroup names to numeric bodygroup indexes. Returns an empty table when the model is unusable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local map = lia.faction.getBodygroupNameToIndex(modelPath)
  local headIndex = map.head
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetallowedskins">
<summary><span class="summary-main"><a id="lia.faction.getAllowedSkins"></a>lia.faction.getAllowedSkins(faction, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L581" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetallowedskins"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets the skin whitelist for a model entry or its owning faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedSkins`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Allowed skin values from the model entry or faction, or nil when no skin whitelist exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local allowedSkins = lia.faction.getAllowedSkins(faction, modelData, modelKey)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetallowedbodygroups">
<summary><span class="summary-main"><a id="lia.faction.getAllowedBodygroups"></a>lia.faction.getAllowedBodygroups(faction, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L614" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetallowedbodygroups"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets the bodygroup whitelist rules for a model entry or its owning faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedBodygroups`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Allowed bodygroup rules from the model entry or faction, or nil when no bodygroup whitelist exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local allowedBodygroups = lia.faction.getAllowedBodygroups(faction, modelData, modelKey)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisskinallowedforfaction">
<summary><span class="summary-main"><a id="lia.faction.isSkinAllowedForFaction"></a>lia.faction.isSkinAllowedForFaction(faction, skin, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L652" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisskinallowedforfaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a skin value is permitted by a faction or model skin whitelist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">skin</span> Skin value being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedSkins`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the skin is allowed or no whitelist exists, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isSkinAllowedForFaction(faction, skin, modelData, modelKey) then
      character:setData("skin", skin)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetdefaultallowedskinforfaction">
<summary><span class="summary-main"><a id="lia.faction.getDefaultAllowedSkinForFaction"></a>lia.faction.getDefaultAllowedSkinForFaction(faction, fallback, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L695" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetdefaultallowedskinforfaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the first allowed skin for a faction or model, falling back when no usable whitelist value exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">fallback</span> Skin value returned when no whitelist value is available.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedSkins`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> First numeric allowed skin value, or the fallback value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local skin = lia.faction.getDefaultAllowedSkinForFaction(faction, 0, modelData, modelKey)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetbodygroupwhitelistrule">
<summary><span class="summary-main"><a id="lia.faction.getBodygroupWhitelistRule"></a>lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L743" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetbodygroupwhitelistrule"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds the whitelist rule that applies to a bodygroup by index or name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> Model path used to resolve bodygroup names when needed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">bodygroupIndex</span> <span class="optional">optional</span> Bodygroup index being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bodygroupName</span> <span class="optional">optional</span> Optional bodygroup name being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedBodygroups`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|boolean|nil</a></span> Whitelist rule for the bodygroup, true or false for unconditional allow or deny, or nil when no rule applies.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local rule = lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisbodygroupvalueallowed">
<summary><span class="summary-main"><a id="lia.faction.isBodygroupValueAllowed"></a>lia.faction.isBodygroupValueAllowed(faction, modelPath, bodygroupIndex, value, bodygroupName, modelData, modelKey)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L820" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisbodygroupvalueallowed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a bodygroup value is permitted by the applicable whitelist rule.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> Model path used to resolve bodygroup names when needed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">bodygroupIndex</span> <span class="optional">optional</span> Bodygroup index being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">value</span> Bodygroup value being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bodygroupName</span> <span class="optional">optional</span> Optional bodygroup name being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">modelData</span> <span class="optional">optional</span> Optional model entry data that may define `allowedBodygroups`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">modelKey</span> Optional model entry key used when parsing model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the value is allowed or no rule applies, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isBodygroupValueAllowed(faction, modelPath, index, value, name, modelData, modelKey) then
      entity:SetBodygroup(index, value)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetindex">
<summary><span class="summary-main"><a id="lia.faction.getIndex"></a>lia.faction.getIndex(uniqueID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L856" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetindex"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets a faction index from its unique ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Faction unique ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Faction index, or nil when the unique ID is not registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local index = lia.faction.getIndex("citizen")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetclasses">
<summary><span class="summary-main"><a id="lia.faction.getClasses"></a>lia.faction.getClasses(faction)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L880" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetclasses"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns all classes assigned to a faction index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Faction index used by class definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table containing class tables that belong to the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classes = lia.faction.getClasses(FACTION_CITIZEN)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetplayers">
<summary><span class="summary-main"><a id="lia.faction.getPlayers"></a>lia.faction.getPlayers(faction)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L910" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetplayers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns all connected players whose current character belongs to a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Faction index to match against character faction data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table containing matching Player objects.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, ply in ipairs(lia.faction.getPlayers(FACTION_CITIZEN)) do
      print(ply:Name())
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetplayercount">
<summary><span class="summary-main"><a id="lia.faction.getPlayerCount"></a>lia.faction.getPlayerCount(faction)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L939" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetplayercount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Counts connected players whose current character belongs to a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Faction index to match against character faction data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Number of connected players in the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local count = lia.faction.getPlayerCount(FACTION_CITIZEN)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisfactioncategory">
<summary><span class="summary-main"><a id="lia.faction.isFactionCategory"></a>lia.faction.isFactionCategory(faction, categoryFactions)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L973" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisfactioncategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a faction value is included in a faction category list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">faction</span> Faction value being searched for.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">categoryFactions</span> Table of faction values that make up the category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the faction exists in the category table, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isFactionCategory(faction, categoryFactions) then
      return true
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcharactercreationclass">
<summary><span class="summary-main"><a id="lia.faction.getCharacterCreationClass"></a>lia.faction.getCharacterCreationClass(faction, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1001" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcharactercreationclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves the class used for character creation and verifies it belongs to the selected faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Class identifier or class table. When omitted or invalid, the faction default class is used when available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Resolved class table, or nil when no valid class exists for the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classData = lia.faction.getCharacterCreationClass(faction, selectedClass)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcharactercreationmodelsource">
<summary><span class="summary-main"><a id="lia.faction.getCharacterCreationModelSource"></a>lia.faction.getCharacterCreationModelSource(faction, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1033" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcharactercreationmodelsource"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds the model source used during character creation from class data, faction data, or defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Optional class identifier or class table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string|table, table|nil, boolean Model path or model table, the owner table that provided it, and whether the source is a forced single model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcharactercreationmodelchoices">
<summary><span class="summary-main"><a id="lia.faction.getCharacterCreationModelChoices"></a>lia.faction.getCharacterCreationModelChoices(faction, class)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1071" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcharactercreationmodelchoices"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the selectable model choices for character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Optional class identifier or class table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>table, table|nil, boolean Model choices table, the owner table that provided the models, and whether the choice is a forced single model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local choices, owner, forced = lia.faction.getCharacterCreationModelChoices(faction, class)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcharactercreationmodelinfo">
<summary><span class="summary-main"><a id="lia.faction.getCharacterCreationModelInfo"></a>lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1107" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcharactercreationmodelinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the selected character creation model entry and its source owner.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">faction</span> Faction index, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string|table</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Optional class identifier or class table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">selectedModel</span> <span class="optional">optional</span> Selected model index. Defaults to 1 when omitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string|table|nil, table|nil, boolean Selected model entry, the owner table that provided it, and whether the source is a forced single model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local modelData, owner, forced = lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionjobgenerate">
<summary><span class="summary-main"><a id="lia.faction.jobGenerate"></a>lia.faction.jobGenerate(index, name, color, default, models)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1146" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionjobgenerate"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates and registers a faction table from job-style data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">index</span> Faction index to assign.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Faction name and storage key.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Team color for the faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">default</span> Whether the faction should be treated as default.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">models</span> <span class="optional">optional</span> Optional model list. Defaults to the library default models when omitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Generated faction table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local faction = lia.faction.jobGenerate(10, "Worker", Color(125, 125, 125), true, models)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionformatmodeldata">
<summary><span class="summary-main"><a id="lia.faction.formatModelData"></a>lia.faction.formatModelData()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1251" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionformatmodeldata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Normalizes bodygroup data for every registered faction model entry where bodygroup names must be converted to indexes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.faction.formatModelData()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcategories">
<summary><span class="summary-main"><a id="lia.faction.getCategories"></a>lia.faction.getCategories(teamName)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1293" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcategories"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns model category names defined for a faction team.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">teamName</span> Faction storage key used in `lia.faction.teams`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Sequential table containing category names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local categories = lia.faction.getCategories("citizen")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetmodelsfromcategory">
<summary><span class="summary-main"><a id="lia.faction.getModelsFromCategory"></a>lia.faction.getModelsFromCategory(teamName, category)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1327" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetmodelsfromcategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns all model entries from a named faction model category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">teamName</span> Faction storage key used in `lia.faction.teams`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">category</span> Model category name to read.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Table containing model entries from the requested category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local models = lia.faction.getModelsFromCategory("citizen", "male")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetdefaultclass">
<summary><span class="summary-main"><a id="lia.faction.getDefaultClass"></a>lia.faction.getDefaultClass(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1358" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetdefaultclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds the default class assigned to a faction index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Faction index used by class definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Default class table, or nil when none is registered for the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local defaultClass = lia.faction.getDefaultClass(FACTION_CITIZEN)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liafactionhaswhitelist">
<summary><span class="summary-main"><a id="lia.faction.hasWhitelist"></a>lia.faction.hasWhitelist(faction)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1401" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionhaswhitelist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether the local player is allowed to create or use a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Faction index to check.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the faction is default, when the local player has staff character creation privilege for the staff faction, or when local whitelist data contains the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.hasWhitelist(FACTION_CITIZEN) then
      print("allowed")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liafactionhaswhitelist">
<summary><span class="summary-main"><a id="lia.faction.hasWhitelist"></a>lia.faction.hasWhitelist(faction)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L1438" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionhaswhitelist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a faction is available by default on the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Faction index to check.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True only for default factions in this implementation, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.hasWhitelist(FACTION_CITIZEN) then
      print("default faction")
  end
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

<details class="realm-shared" id="function-overridefactiondesc">
<summary><span class="summary-main"><a id="OverrideFactionDesc"></a>OverrideFactionDesc(uniqueID, desc)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L38" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactiondesc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override a faction's resolved description while it is registered or loaded from disk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Factions</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The faction unique ID being registered or loaded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">desc</span> The resolved faction description before the override is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Return a string to replace the faction description. Return nil to keep the current description.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactionmodelcustomization">
<summary><span class="summary-main"><a id="OverrideFactionModelCustomization"></a>OverrideFactionModelCustomization(client, faction, context, skinAllowed, bodygroupsAllowed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L86" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactionmodelcustomization"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override whether skins and bodygroups can be customized for a faction model selection context.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Factions</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose customization permissions are being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> The faction data being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">context</span> Optional caller-provided context for the customization check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">skinAllowed</span> Whether skin customization is currently allowed by faction data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">bodygroupsAllowed</span> Whether bodygroup customization is currently allowed by faction data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>table|boolean|nil, boolean|nil Return a table with `skinAllowed` and/or `bodygroupsAllowed` fields, or return two booleans to override each value separately. Return nil values to keep the current permissions.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactionmodels">
<summary><span class="summary-main"><a id="OverrideFactionModels"></a>OverrideFactionModels(uniqueID, models)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L62" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactionmodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override the model list assigned to a faction while it is registered or loaded from disk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Factions</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The faction unique ID being registered or loaded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">models</span> The faction model table before the override is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Return a model table to replace the faction models. Return nil to keep the current models.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactionname">
<summary><span class="summary-main"><a id="OverrideFactionName"></a>OverrideFactionName(uniqueID, name)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/factions.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactionname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override a faction's resolved display name while it is registered or loaded from disk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Factions</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The faction unique ID being registered or loaded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The resolved faction name before the override is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Return a string to replace the faction name. Return nil to keep the current name.</p>
</div>

</div>
</details>

---

