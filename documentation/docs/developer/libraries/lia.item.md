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

# Item

Item definition, registration, instancing, inventory helper, rarity, and generated weapon/ammunition item utilities for Lilia.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The item library manages registered item definitions and base items under `lia.item`, creates and restores item instances, creates inventory helpers, registers deferred item definitions and overrides, supports generated weapon and ammunition item definitions, and applies persistent weapon override data.
</div>

---

<details class="realm-shared" id="function-liaitemget">
<summary><span class="summary-main"><a id="lia.item.get"></a>lia.item.get(identifier)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L411" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a registered base item or normal item definition by identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">identifier</span> The unique ID of the item or base item to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item|nil</a></span> The matching item definition, or nil if no registered item or base item exists for the identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local itemDef = lia.item.get("water_bottle")
  if itemDef then print(itemDef.name) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemapplyweaponoverride">
<summary><span class="summary-main"><a id="lia.item.applyWeaponOverride"></a>lia.item.applyWeaponOverride(uniqueID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L436" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemapplyweaponoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Applies stored weapon override values to an already registered item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique ID or weapon class name of the generated weapon item to update.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.addWeaponOverride("weapon_pistol", {name = "Sidearm"})
  lia.item.applyWeaponOverride("weapon_pistol")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemgetitembyid">
<summary><span class="summary-main"><a id="lia.item.getItemByID"></a>lia.item.getItemByID(itemID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L469" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemgetitembyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Finds an instantiated item by database ID and reports where the item currently exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The database ID of the item instance to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> A table containing `item` and `location` when found, or nil when the item does not exist. string|nil An error message when the item cannot be found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local result, err = lia.item.getItemByID(15)
  if result then print(result.location) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemgetinstanceditembyid">
<summary><span class="summary-main"><a id="lia.item.getInstancedItemByID"></a>lia.item.getInstancedItemByID(itemID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L509" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemgetinstanceditembyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns an instantiated item directly from the item instance cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The database ID of the item instance to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item|nil</a></span> The item instance when it exists, or nil when it cannot be found. string|nil An error message when the item cannot be found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local item, err = lia.item.getInstancedItemByID(15)
  if item then print(item.uniqueID) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemgetitemdatabyid">
<summary><span class="summary-main"><a id="lia.item.getItemDataByID"></a>lia.item.getItemDataByID(itemID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L539" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemgetitemdatabyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the data table stored on an instantiated item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The database ID of the item instance whose data should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The item data table when the item exists, or nil when it cannot be found. string|nil An error message when the item cannot be found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local data = lia.item.getItemDataByID(15)
  if data then print(data.x, data.y) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemload">
<summary><span class="summary-main"><a id="lia.item.load"></a>lia.item.load(path, baseID, isBaseItem)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L571" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an item file path by deriving its unique ID and registering it as an item or base item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> The Lua file path to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">baseID</span> <span class="optional">optional</span> The base item unique ID to inherit from, if any.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isBaseItem</span> <span class="optional">optional</span> Whether the file should be registered as a base item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.load("lilia/gamemode/items/sh_example.lua")
  lia.item.load("lilia/gamemode/items/base/sh_weapons.lua", nil, true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemisitem">
<summary><span class="summary-main"><a id="lia.item.isItem"></a>lia.item.isItem(object)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L604" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemisitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a value is an item table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">object</span> The value to inspect.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the value is a table marked as an item, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.item.isItem(item) then print(item:getID()) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemgetinv">
<summary><span class="summary-main"><a id="lia.item.getInv"></a>lia.item.getInv(invID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L629" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemgetinv"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a registered inventory instance by inventory ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">invID</span> The inventory ID to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/inventory/">Inventory|nil</a></span> The inventory instance, or nil if no inventory is loaded for the ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local inventory = lia.item.getInv(item.invID)
  if inventory then print(inventory:getID()) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemaddrarities">
<summary><span class="summary-main"><a id="lia.item.addRarities"></a>lia.item.addRarities(name, color)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L655" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemaddrarities"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers an item rarity color under a rarity name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The rarity name to register.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> The color associated with the rarity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.addRarities("Legendary", Color(255, 170, 0))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemregister">
<summary><span class="summary-main"><a id="lia.item.register"></a>lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L690" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemregister"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers an item definition or base item and prepares inherited hooks, functions, localization, and overrides.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique ID to register.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">baseID</span> <span class="optional">optional</span> The base item unique ID to inherit from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isBaseItem</span> <span class="optional">optional</span> Whether the registration target is a base item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> <span class="optional">optional</span> The Lua file path to include for the item definition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">luaGenerated</span> <span class="optional">optional</span> Whether the item is being generated from Lua data instead of loaded from a file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> The registered item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local itemDef = lia.item.register("example", "base_entities", false, nil, true)
  itemDef.name = "Example Item"
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemlocalizedefinition">
<summary><span class="summary-main"><a id="lia.item.localizeDefinition"></a>lia.item.localizeDefinition(itemDef)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L770" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemlocalizedefinition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resolves localization tokens on an item definition and its item function names or tips.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item|table</a></span> <span class="parameter">itemDef</span> The item definition to localize.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local itemDef = lia.item.get("water_bottle")
  lia.item.localizeDefinition(itemDef)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemregisteritem">
<summary><span class="summary-main"><a id="lia.item.registerItem"></a>lia.item.registerItem(id, base, properties)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L814" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemregisteritem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Queues a Lua-generated item registration to be finalized after modules initialize.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> The unique ID of the item to register.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">base</span> <span class="optional">optional</span> The base item unique ID to inherit from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">properties</span> <span class="optional">optional</span> Properties to copy onto the registered item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A placeholder item table that proxies to the actual registered item once it exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.registerItem("example_entity", "base_entities", {
      name = "Example Entity",
      entityid = "example_entity"
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemoverrideitem">
<summary><span class="summary-main"><a id="lia.item.overrideItem"></a>lia.item.overrideItem(uniqueID, overrides)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L870" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemoverrideitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Queues overrides for an item definition to be applied after modules initialize.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the item to override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">overrides</span> The fields, functions, hooks, or post hooks to merge into the item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.overrideItem("water_bottle", {
      name = "Clean Water"
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemloadfromdir">
<summary><span class="summary-main"><a id="lia.item.loadFromDir"></a>lia.item.loadFromDir(directory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L899" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemloadfromdir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads base item files, category item files, and direct item files from an item directory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">directory</span> The Lua directory containing item files and optional base subdirectory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.loadFromDir("lilia/gamemode/items")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemnew">
<summary><span class="summary-main"><a id="lia.item.new"></a>lia.item.new(uniqueID, id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L944" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemnew"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates or returns an item instance for a registered item definition and database ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the registered item definition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">id</span> The item database ID, converted to a number when possible.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> The item instance for the provided unique ID and ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local item = lia.item.new("water_bottle", 15)
  print(item:getID())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemregisterinv">
<summary><span class="summary-main"><a id="lia.item.registerInv"></a>lia.item.registerInv(invType, w, h)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L991" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemregisterinv"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a grid inventory type with fixed width and height accessors.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">invType</span> The inventory type name to register.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The inventory width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The inventory height.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.registerInv("small_bag", 4, 4)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemnewinv">
<summary><span class="summary-main"><a id="lia.item.newInv"></a>lia.item.newInv(owner, invType, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1033" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemnewinv"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a new inventory instance for a character owner and optionally syncs it to the owning player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">owner</span> <span class="optional">optional</span> The character ID that owns the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">invType</span> The inventory type to instantiate.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called with the created inventory after it is available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.newInv(charID, "grid", function(inventory)
      print(inventory:getID())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemcreateinv">
<summary><span class="summary-main"><a id="lia.item.createInv"></a>lia.item.createInv(w, h, id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1075" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemcreateinv"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a grid inventory instance immediately using the provided dimensions and ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The inventory width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The inventory height.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The inventory ID to assign to the new instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/inventory/">Inventory</a></span> The created grid inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local inventory = lia.item.createInv(4, 4, 1001)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemaddweaponoverride">
<summary><span class="summary-main"><a id="lia.item.addWeaponOverride"></a>lia.item.addWeaponOverride(className, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1177" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemaddweaponoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Stores item definition override data for a generated weapon item class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">className</span> The weapon class or generated item unique ID to override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> The override fields to apply to the generated item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.addWeaponOverride("weapon_pistol", {
      width = 1,
      height = 1
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemaddweapontoblacklist">
<summary><span class="summary-main"><a id="lia.item.addWeaponToBlacklist"></a>lia.item.addWeaponToBlacklist(className)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1201" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemaddweapontoblacklist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prevents a weapon class from being converted into an automatically generated item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">className</span> The weapon class name to blacklist.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.addWeaponToBlacklist("weapon_example_base")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemapplyruntimeoverridepath">
<summary><span class="summary-main"><a id="lia.item.applyRuntimeOverridePath"></a>lia.item.applyRuntimeOverridePath(wepTable, dotPath, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1229" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemapplyruntimeoverridepath"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Applies a value to a nested field on a weapon table using a dot-separated path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">wepTable</span> The weapon table to modify.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dotPath</span> The dot-separated nested field path to write.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to assign at the destination path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the value was applied, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local ok = lia.item.applyRuntimeOverridePath(SWEP, "Primary.Damage", 35)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaitemgetruntimevalue">
<summary><span class="summary-main"><a id="lia.item.getRuntimeValue"></a>lia.item.getRuntimeValue(wepTable, dotPath)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1266" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemgetruntimevalue"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reads a nested value from a weapon table using a dot-separated path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">wepTable</span> The weapon table to read from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dotPath</span> The dot-separated nested field path to read.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any|nil</a></span> The nested value when the path exists, or nil when it cannot be resolved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local damage = lia.item.getRuntimeValue(SWEP, "Primary.Damage")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemsetitemdatabyid">
<summary><span class="summary-main"><a id="lia.item.setItemDataByID"></a>lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1310" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemsetitemdatabyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets a data key on an instantiated item by database ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The database ID of the item instance to update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The data key to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to store.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|table</a></span> <span class="parameter">receivers</span> <span class="optional">optional</span> Optional networking recipients for the data update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noSave</span> <span class="optional">optional</span> Whether to skip saving the data change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noCheckEntity</span> <span class="optional">optional</span> Whether to skip entity validity checks during the update.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the data was set, or false when the item was not found. string|nil An error message when the item cannot be found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local ok, err = lia.item.setItemDataByID(15, "uses", 2)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaiteminstance">
<summary><span class="summary-main"><a id="lia.item.instance"></a>lia.item.instance(index, uniqueID, itemData, x, y, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1351" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaiteminstance"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a persistent item database record and item instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">index</span> <span class="optional">optional</span> The inventory ID for the new item, or the unique ID when using the shorthand overload.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">uniqueID</span> <span class="optional">optional</span> The item unique ID, or item data when using the shorthand overload.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">itemData</span> <span class="optional">optional</span> Initial data to store on the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> <span class="optional">optional</span> The item inventory X position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> <span class="optional">optional</span> The item inventory Y position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called with the created item after the database insert completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred</a></span> A deferred object that resolves with the created item or rejects with an error message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.instance(invID, "water_bottle", {}, 1, 1, function(item)
      print(item:getID())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemdeletebyid">
<summary><span class="summary-main"><a id="lia.item.deleteByID"></a>lia.item.deleteByID(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1421" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemdeletebyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Deletes an item by database ID, using the loaded instance when available or a direct database delete otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The item database ID to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.deleteByID(15)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemloaditembyid">
<summary><span class="summary-main"><a id="lia.item.loadItemByID"></a>lia.item.loadItemByID(itemIndex)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1450" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemloaditembyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads one or more items from the database into the item instance cache.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|table</a></span> <span class="parameter">itemIndex</span> A single item ID or a table of item IDs to restore.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.loadItemByID(15)
  lia.item.loadItemByID({15, 16, 17})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemspawn">
<summary><span class="summary-main"><a id="lia.item.spawn"></a>lia.item.spawn(uniqueID, position, callback, angles, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1509" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemspawn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates an item instance and spawns it into the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the item definition to spawn.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">position</span> The world position where the item should be spawned.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function|Angle</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called with the spawned item, or used as angles when no callback is provided.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle|table</a></span> <span class="parameter">angles</span> <span class="optional">optional</span> The spawn angles, or item data when passed through the angle overload.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> <span class="optional">optional</span> Initial data to store on the spawned item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|nil</a></span> A deferred object when no callback function is supplied, otherwise nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.spawn("water_bottle", client:GetPos(), function(item)
      if item then print(item:getID()) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemrestoreinv">
<summary><span class="summary-main"><a id="lia.item.restoreInv"></a>lia.item.restoreInv(invID, w, h, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1566" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemrestoreinv"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an inventory by ID, restores its dimensions, and optionally passes it to a callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">invID</span> The inventory ID to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> The restored inventory width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> The restored inventory height.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called with the restored inventory when it is available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.restoreInv(invID, 6, 4, function(inventory)
      inventory:sync(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemloadweaponoverrides">
<summary><span class="summary-main"><a id="lia.item.loadWeaponOverrides"></a>lia.item.loadWeaponOverrides()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1738" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemloadweaponoverrides"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads saved generated weapon item override data and applies it to registered item definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.loadWeaponOverrides()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaitemloadweaponruntimeoverrides">
<summary><span class="summary-main"><a id="lia.item.loadWeaponRuntimeOverrides"></a>lia.item.loadWeaponRuntimeOverrides()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L1767" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaitemloadweaponruntimeoverrides"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads saved runtime weapon stat overrides and applies them to stored weapon tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">nil</a></span> This function does not return a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.item.loadWeaponRuntimeOverrides()
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

<details class="realm-client" id="function-canplayermodifyconfig">
<summary><span class="summary-main"><a id="CanPlayerModifyConfig"></a>CanPlayerModifyConfig(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L206" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayermodifyconfig"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Controls whether the local player can see the generated weapon item configuration page.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player opening the configuration interface.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to hide the configuration page. Return nil or true to allow it.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getweaponname">
<summary><span class="summary-main"><a id="GetWeaponName"></a>GetWeaponName(weaponTable)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L166" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getweaponname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to provide a display name for automatically generated weapon items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">weaponTable</span> The weapon table being converted into an item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Return a string to override the generated item name, or nil to use the default name source.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-handleitemtransferrequest">
<summary><span class="summary-main"><a id="HandleItemTransferRequest"></a>HandleItemTransferRequest(client, itemID, x, y, targetInvID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L73" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="handleitemtransferrequest"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handles the actual transfer when a player gives an item forward to another player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player initiating the transfer.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The database ID of the item being transferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> <span class="optional">optional</span> The destination inventory X position, if one is specified.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> <span class="optional">optional</span> The destination inventory Y position, if one is specified.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">targetInvID</span> The inventory ID receiving the item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|nil</a></span> Return a deferred transfer result to continue the give-forward flow, or nil to stop handling.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializeditems">
<summary><span class="summary-main"><a id="InitializedItems"></a>InitializedItems()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L136" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializeditems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after item files have been loaded from the item directory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-itemdefaultfunctions">
<summary><span class="summary-main"><a id="ItemDefaultFunctions"></a>ItemDefaultFunctions(functions)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L102" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemdefaultfunctions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to inspect or modify the default item action table during item registration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">functions</span> The mutable table of item action definitions.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemcreated">
<summary><span class="summary-main"><a id="OnItemCreated"></a>OnItemCreated(item)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L149" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after an item instance table is created from a registered item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> <span class="parameter">item</span> The newly created item instance.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemoverridden">
<summary><span class="summary-main"><a id="OnItemOverridden"></a>OnItemOverridden(itemDef, overrides)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L187" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemoverridden"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after pending overrides have been applied to an item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> <span class="parameter">itemDef</span> The item definition that received overrides.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">overrides</span> The override table that was applied.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemregistered">
<summary><span class="summary-main"><a id="OnItemRegistered"></a>OnItemRegistered(itemDef)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L119" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemregistered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after an item definition or base item has been registered and localized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> <span class="parameter">itemDef</span> The registered item definition table.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerdroppeditem">
<summary><span class="summary-main"><a id="OnPlayerDroppedItem"></a>OnPlayerDroppedItem(client, itemEntity)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerdroppeditem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a player uses the default drop action and the item has been spawned into the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who dropped the item.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">itemEntity</span> The spawned world entity for the dropped item.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerrotateitem">
<summary><span class="summary-main"><a id="OnPlayerRotateItem"></a>OnPlayerRotateItem(client, item, rotated)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L52" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerrotateitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a player rotates an inventory item using the default rotate action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who rotated the item.</p>
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> <span class="parameter">item</span> The item instance that was rotated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">rotated</span> The new rotated state stored on the item.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayertakeitem">
<summary><span class="summary-main"><a id="OnPlayerTakeItem"></a>OnPlayerTakeItem(client, item)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/item.lua#L33" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayertakeitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a player successfully takes a world item into their inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Items</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who took the item.</p>
<p><span class="types"><a class="type" href="/developer/libraries/item/">Item</a></span> <span class="parameter">item</span> The item instance that was added to the inventory.</p>
</div>

</div>
</details>

---

