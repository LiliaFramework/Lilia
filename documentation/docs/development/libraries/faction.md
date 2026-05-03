# Faction

Comprehensive faction (team) management and registration system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The faction library provides comprehensive functionality for managing factions (teams) in the Lilia framework. It handles registration, loading, and management of faction data including models, colors, descriptions, and team setup. The library operates on both server and client sides, with server handling faction registration and client handling whitelist checks. It includes functionality for loading factions from directories, managing faction models with bodygroup support, and providing utilities for faction categorization and player management. The library ensures proper team setup and model precaching for all registered factions, supporting both simple string models and complex model data with bodygroup configurations.
</div>

---

<details class="realm-shared" id="function-liafactionregister">
<summary><a id="lia.faction.register"></a>lia.faction.register(uniqueID, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a new faction with the specified unique ID and data table, setting up team configuration and model caching.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to register factions programmatically, typically in shared files or during faction loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique identifier for the faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> A table containing faction configuration data including name, description, color, models, etc.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>number, table Returns the faction index and the faction data table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local index, faction = lia.faction.register("citizen", {
      name = "Citizen",
      desc = "A regular citizen",
      color = Color(100, 150, 200),
      models = {"models/player/group01/male_01.mdl"}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactioncachemodels">
<summary><a id="lia.faction.cacheModels"></a>lia.faction.cacheModels(models)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactioncachemodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Precaches model files to ensure they load quickly when needed, handling both string model paths and table-based model data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called automatically during faction registration to precache all models associated with a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">models</span> A table of model data, where each entry can be a string path or a table with model information.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local models = {"models/player/group01/male_01.mdl", "models/player/group01/female_01.mdl"}
  lia.faction.cacheModels(models)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionloadfromdir">
<summary><a id="lia.faction.loadFromDir"></a>lia.faction.loadFromDir(directory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionloadfromdir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads faction definitions from Lua files in a specified directory, registering each faction found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to load faction definitions from organized directory structures.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">directory</span> The path to the directory containing faction definition files.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.faction.loadFromDir("gamemode/factions")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetall">
<summary><a id="lia.faction.getAll"></a>lia.faction.getAll()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetall"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all registered factions as a table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called whenever all faction information needs to be accessed by other systems or scripts.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table containing all faction data tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local allFactions = lia.faction.getAll()
  for _, faction in ipairs(allFactions) do
      lia.debug("Faction: " .. faction.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionget">
<summary><a id="lia.faction.get"></a>lia.faction.get(identifier)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves faction data by either its unique ID or index number.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called whenever faction information needs to be accessed by other systems or scripts.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">identifier</span> The faction's unique ID string or numeric index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The faction data table, or nil if not found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local faction = lia.faction.get("citizen")
  -- or
  local faction = lia.faction.get(1)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetmodelcustomizationallowed">
<summary><a id="lia.faction.getModelCustomizationAllowed"></a>lia.faction.getModelCustomizationAllowed(client, faction, context)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetmodelcustomizationallowed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a faction allows skin and bodygroup customization for a given client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when checking if a player can customize their character model with skins and bodygroups,
typically during character creation or model selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose customization permissions are being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">number/string/table</a></span> <span class="parameter">faction</span> The faction identifier - can be a faction ID, unique ID, or faction table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">context</span> Additional context data that might be used by hooks to determine permissions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, boolean First value: Whether skin customization is allowed. Second value: Whether bodygroup customization is allowed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local skinAllowed, bodygroupsAllowed = lia.faction.getModelCustomizationAllowed(client, faction, "character_creation")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetbodygroupnametoindex">
<summary><a id="lia.faction.getBodygroupNameToIndex"></a>lia.faction.getBodygroupNameToIndex(modelPath)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetbodygroupnametoindex"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds a lookup table of bodygroup name -> bodygroup index for a specific model path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when bodygroup whitelist rules are defined by bodygroup name, and we need to resolve
those names to numeric indices for a given model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> The model path to inspect.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A map where keys are lowercase bodygroup names and values are numeric bodygroup indices. Returns an empty table if the model is invalid or cannot be inspected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local map = lia.faction.getBodygroupNameToIndex("models/player/group01/male_01.mdl")
  local headgearIndex = map.headgear
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisskinallowedforfaction">
<summary><a id="lia.faction.isSkinAllowedForFaction"></a>lia.faction.isSkinAllowedForFaction(faction, skin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisskinallowedforfaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a skin ID is allowed for a faction when a skin whitelist is defined.
If the whitelist is missing or empty, this function treats it as unrestricted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during character creation/adjustment when `skinAllowed` is enabled and the player
attempts to pick a specific skin.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string|number</a></span> <span class="parameter">faction</span> The faction table, uniqueID, or numeric index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">skin</span> The desired skin ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if allowed, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isSkinAllowedForFaction("citizen", 0) then
      lia.debug("Allowed")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetdefaultallowedskinforfaction">
<summary><a id="lia.faction.getDefaultAllowedSkinForFaction"></a>lia.faction.getDefaultAllowedSkinForFaction(faction, fallback)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetdefaultallowedskinforfaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the first allowed skin from a faction whitelist to use as a fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player-selected skin is not allowed and we need to clamp it back to a valid
value. If no whitelist exists (or it has no numeric entries), the provided fallback is used.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string|number</a></span> <span class="parameter">faction</span> The faction table, uniqueID, or numeric index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">fallback</span> The fallback skin to use if there is no usable whitelist value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> A valid skin ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local skin = lia.faction.getDefaultAllowedSkinForFaction("citizen", 0)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetbodygroupwhitelistrule">
<summary><a id="lia.faction.getBodygroupWhitelistRule"></a>lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetbodygroupwhitelistrule"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves the whitelist rule for a specific bodygroup for a faction.
Supports looking up rules by numeric bodygroup index or by bodygroup name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when validating a requested bodygroup change during character creation/adjustment.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string|number</a></span> <span class="parameter">faction</span> The faction table, uniqueID, or numeric index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> The model used to resolve bodygroup name to index when needed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">bodygroupIndex</span> The numeric bodygroup index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bodygroupName</span> <span class="optional">optional</span> Optional bodygroup name override.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> The rule value stored in `FACTION.allowedBodygroups` for this bodygroup. - nil means no restriction. - table means a whitelist of allowed numeric values. - true/false explicitly allows/denies.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local rule = lia.faction.getBodygroupWhitelistRule("citizen", mdl, 1)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisbodygroupvalueallowed">
<summary><a id="lia.faction.isBodygroupValueAllowed"></a>lia.faction.isBodygroupValueAllowed(faction, modelPath, bodygroupIndex, value, bodygroupName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisbodygroupvalueallowed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a specific bodygroup value is allowed for a faction.
If there is no rule (or the allowedBodygroups table is missing/empty), this is unrestricted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during character creation/adjustment when `bodygroupsAllowed` is enabled and the
player attempts to pick bodygroup values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string|number</a></span> <span class="parameter">faction</span> The faction table, uniqueID, or numeric index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> The model path used to resolve bodygroup names when needed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">bodygroupIndex</span> The numeric bodygroup index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The requested bodygroup value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">bodygroupName</span> <span class="optional">optional</span> Optional bodygroup name override.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if allowed, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.isBodygroupValueAllowed("citizen", mdl, 0, 1) then
      lia.debug("Allowed")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetindex">
<summary><a id="lia.faction.getIndex"></a>lia.faction.getIndex(uniqueID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetindex"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the numeric team index for a faction given its unique ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the numeric team index is needed for GMod team functions or comparisons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique identifier of the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The faction's team index, or nil if the faction doesn't exist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local index = lia.faction.getIndex("citizen")
  if index then
      lia.debug("Citizen faction index: " .. index)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetclasses">
<summary><a id="lia.faction.getClasses"></a>lia.faction.getClasses(faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetclasses"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all character classes that belong to a specific faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to display or work with all classes available to a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> An array of class data tables that belong to the specified faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local classes = lia.faction.getClasses("citizen")
  for _, class in ipairs(classes) do
      lia.debug("Class: " .. class.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetplayers">
<summary><a id="lia.faction.getPlayers"></a>lia.faction.getPlayers(faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetplayers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all players who are currently playing characters in the specified faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to iterate over or work with all players belonging to a specific faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> An array of player entities who belong to the specified faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local players = lia.faction.getPlayers("citizen")
  for _, player in ipairs(players) do
      player:ChatPrint("Hello citizens!")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetplayercount">
<summary><a id="lia.faction.getPlayerCount"></a>lia.faction.getPlayerCount(faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetplayercount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Counts the number of players currently playing characters in the specified faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to know how many players are in a faction for UI display, limits, or statistics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The number of players in the specified faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local count = lia.faction.getPlayerCount("citizen")
  lia.debug("There are " .. count .. " citizens online")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionisfactioncategory">
<summary><a id="lia.faction.isFactionCategory"></a>lia.faction.isFactionCategory(faction, categoryFactions)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionisfactioncategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a faction belongs to a specific category of factions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when determining if a faction is part of a group or category for organizational purposes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier to check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">categoryFactions</span> An array of faction identifiers that define the category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the faction is in the category, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local lawFactions = {"police", "sheriff"}
  if lia.faction.isFactionCategory("police", lawFactions) then
      lia.debug("This is a law enforcement faction")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionjobgenerate">
<summary><a id="lia.faction.jobGenerate"></a>lia.faction.jobGenerate(index, name, color, default, models)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionjobgenerate"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Generates a basic faction configuration programmatically with minimal required parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called for quick faction creation during development or for compatibility with other systems.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">index</span> The numeric team index for the faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The display name of the faction.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> The color associated with the faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">default</span> Whether this is a default faction that doesn't require whitelisting.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">models</span> Array of model paths for the faction (optional, uses defaults if not provided).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The created faction data table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local faction = lia.faction.jobGenerate(5, "Visitor", Color(200, 200, 200), true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactionformatmodeldata">
<summary><a id="lia.faction.formatModelData"></a>lia.faction.formatModelData()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionformatmodeldata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Formats and standardizes model data across all factions, converting bodygroup configurations to proper format.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after faction loading to ensure all model data is properly formatted for use.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Called automatically during faction initialization
  lia.faction.formatModelData()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetcategories">
<summary><a id="lia.faction.getCategories"></a>lia.faction.getCategories(teamName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetcategories"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all model categories defined for a faction (string keys in the models table).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to display or work with faction model categories in UI or selection systems.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">teamName</span> The unique ID of the faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> An array of category names (strings) defined for the faction's models.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local categories = lia.faction.getCategories("citizen")
  for _, category in ipairs(categories) do
      lia.debug("Category: " .. category)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetmodelsfromcategory">
<summary><a id="lia.faction.getModelsFromCategory"></a>lia.faction.getModelsFromCategory(teamName, category)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetmodelsfromcategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all models belonging to a specific category within a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when needing to display or select models from a particular category for character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">teamName</span> The unique ID of the faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">category</span> The name of the model category to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of models in the specified category, indexed by their position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local models = lia.faction.getModelsFromCategory("citizen", "male")
  for index, model in pairs(models) do
      lia.debug("Model " .. index .. ": " .. (istable(model) and model[1] or model))
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liafactiongetdefaultclass">
<summary><a id="lia.faction.getDefaultClass"></a>lia.faction.getDefaultClass(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactiongetdefaultclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the default character class for a faction (marked with isDefault = true).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when automatically assigning a class to new characters or when needing the primary class for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">id</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The default class data table for the faction, or nil if no default class exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local defaultClass = lia.faction.getDefaultClass("citizen")
  if defaultClass then
      lia.debug("Default class: " .. defaultClass.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liafactionhaswhitelist">
<summary><a id="lia.faction.hasWhitelist"></a>lia.faction.hasWhitelist(faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionhaswhitelist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if the local player has whitelist access to the specified faction on the client side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client when determining if a faction should be available for character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if the player has access to the faction, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.faction.hasWhitelist("citizen") then
      -- Show citizen faction in character creation menu
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liafactionhaswhitelist">
<summary><a id="lia.faction.hasWhitelist"></a>lia.faction.hasWhitelist(faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liafactionhaswhitelist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whitelist access for a faction on the server side (currently simplified implementation).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the server for faction access validation, though the current implementation is restrictive.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">faction</span> The faction identifier (unique ID or index).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True only for default factions, false for all others including staff.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Server-side validation
  if lia.faction.hasWhitelist("citizen") then
      -- Allow character creation
  end
</code></pre>
</div>

</div>
</details>

---

