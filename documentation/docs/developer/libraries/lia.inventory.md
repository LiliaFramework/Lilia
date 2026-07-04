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

# Inventory

Inventory helpers for registering inventory types, creating and loading inventory instances, managing persistent storage definitions, and opening inventory panels.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The inventory library centralizes shared inventory behavior under `lia.inventory`. It registers inventory type structures, creates inventory objects, loads and deletes server-side inventory records, manages storage and vehicle trunk definitions, handles overflow after size changes, and opens single or dual inventory interfaces on the client.
</div>

---

<details class="realm-shared" id="function-liainventorynewtype">
<summary><span class="summary-main"><a id="lia.inventory.newType"></a>lia.inventory.newType(typeID, invTypeStruct)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L194" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorynewtype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a new inventory type structure under `lia.inventory.types`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> Unique identifier used to reference the inventory type.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">invTypeStruct</span> Inventory type structure containing the required metatable fields and server methods.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.newType("grid", inventoryType)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liainventorynew">
<summary><span class="summary-main"><a id="lia.inventory.new"></a>lia.inventory.new(typeID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L222" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorynew"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a new inventory object from a registered inventory type without loading or assigning persistent storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> Identifier of the registered inventory type to instantiate.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A new inventory object with copied configuration and an empty item table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local inventory = lia.inventory.new("grid")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadbyid">
<summary><span class="summary-main"><a id="lia.inventory.loadByID"></a>lia.inventory.loadByID(id, noCache)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L272" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadbyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an inventory by its persistent ID, using the cached instance unless `noCache` is enabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Persistent inventory ID to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noCache</span> <span class="optional">optional</span> Whether to bypass an existing cached inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred that resolves with the loaded inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadByID(invID):next(function(inventory)
      if inventory then inventory:sync(client) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadfromdefaultstorage">
<summary><span class="summary-main"><a id="lia.inventory.loadFromDefaultStorage"></a>lia.inventory.loadFromDefaultStorage(id, noCache)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L317" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadfromdefaultstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an inventory from the default database tables and restores its saved data and items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Persistent inventory ID to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noCache</span> <span class="optional">optional</span> Whether to bypass an existing cached inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred that resolves with the loaded inventory instance, or nil if no record exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadFromDefaultStorage(invID, true):next(function(inventory)
      if inventory then inventory:onLoaded() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryinstance">
<summary><span class="summary-main"><a id="lia.inventory.instance"></a>lia.inventory.instance(typeID, initialData)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L376" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryinstance"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates and persists a new inventory instance of the given type.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> Identifier of the registered inventory type to create.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">initialData</span> <span class="optional">optional</span> Optional data table assigned to the new inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred that resolves with the newly created inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.instance("grid", {char = character:getID()}):next(function(inventory)
      character:setInv(inventory)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadallfromcharid">
<summary><span class="summary-main"><a id="lia.inventory.loadAllFromCharID"></a>lia.inventory.loadAllFromCharID(charID)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L426" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadallfromcharid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads every inventory associated with a character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">charID</span> Character ID whose inventories should be loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred that resolves with the loaded inventory instances.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadAllFromCharID(character:getID()):next(function(inventories)
      for _, inventory in pairs(inventories) do
          inventory:sync(client)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorydeletebyid">
<summary><span class="summary-main"><a id="lia.inventory.deleteByID"></a>lia.inventory.deleteByID(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L463" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorydeletebyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Deletes an inventory and its related data from persistent storage, then destroys the cached instance if present.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Persistent inventory ID to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.deleteByID(invID)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorycleanupforcharacter">
<summary><span class="summary-main"><a id="lia.inventory.cleanUpForCharacter"></a>lia.inventory.cleanUpForCharacter(character)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L490" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorycleanupforcharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Destroys all inventory instances currently associated with a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/libraries/char/">Character</a></span> <span class="parameter">character</span> Character whose inventories should be cleaned up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.cleanUpForCharacter(character)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorycheckoverflow">
<summary><span class="summary-main"><a id="lia.inventory.checkOverflow"></a>lia.inventory.checkOverflow(inv, character, oldW, oldH)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L527" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorycheckoverflow"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes items that no longer fit in an inventory and stores them as character overflow data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inv</span> Inventory instance being checked for overflow.</p>
<p><span class="types"><a class="type" href="/developer/libraries/char/">Character</a></span> <span class="parameter">character</span> Character that owns the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oldW</span> Previous inventory width used for overflow metadata.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oldH</span> Previous inventory height used for overflow metadata.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if one or more items overflowed and were stored, otherwise false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.inventory.checkOverflow(inventory, character, oldW, oldH) then
      client:notifyWarning("Some items no longer fit in your inventory.")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryregisterstorage">
<summary><span class="summary-main"><a id="lia.inventory.registerStorage"></a>lia.inventory.registerStorage(model, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L585" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryregisterstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a world storage definition for a model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">model</span> Model path used as the storage lookup key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Storage definition containing `name`, `invType`, and `invData`, with optional description data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The registered storage definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.registerStorage("models/props_junk/wood_crate001a.mdl", {
      name = "Crate",
      invType = "grid",
      invData = {w = 4, h = 4}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetstorage">
<summary><span class="summary-main"><a id="lia.inventory.getStorage"></a>lia.inventory.getStorage(model)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L617" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves a registered storage definition by model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">model</span> Model path used to look up storage data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The matching storage definition, or nil if none exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local storage = lia.inventory.getStorage(entity:GetModel())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryregistertrunk">
<summary><span class="summary-main"><a id="lia.inventory.registerTrunk"></a>lia.inventory.registerTrunk(vehicleClass, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L649" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryregistertrunk"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a vehicle trunk storage definition for a vehicle class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">vehicleClass</span> Vehicle class used as the trunk lookup key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Trunk definition containing `name`, `invType`, and `invData`, with optional description data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The registered trunk definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.registerTrunk("prop_vehicle_jeep", {
      name = "Vehicle Trunk",
      invType = "grid",
      invData = {w = 6, h = 3}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygettrunk">
<summary><span class="summary-main"><a id="lia.inventory.getTrunk"></a>lia.inventory.getTrunk(vehicleClass)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L685" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygettrunk"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves a registered vehicle trunk definition by vehicle class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">vehicleClass</span> Vehicle class used to look up trunk data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The matching trunk definition, or nil if the class is not registered as a trunk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local trunk = lia.inventory.getTrunk(vehicle:GetClass())
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetalltrunks">
<summary><span class="summary-main"><a id="lia.inventory.getAllTrunks"></a>lia.inventory.getAllTrunks()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L710" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetalltrunks"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns every registered vehicle trunk definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Table of registered trunk definitions keyed by their lowercase trunk keys.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local trunks = lia.inventory.getAllTrunks()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetallstorage">
<summary><span class="summary-main"><a id="lia.inventory.getAllStorage"></a>lia.inventory.getAllStorage(includeTrunks)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L738" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetallstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns registered storage definitions, optionally excluding vehicle trunks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">includeTrunks</span> <span class="optional">optional</span> Set to false to return only non-trunk storage definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Registered storage definitions keyed by lowercase model or vehicle class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local storageOnly = lia.inventory.getAllStorage(false)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liainventoryshow">
<summary><span class="summary-main"><a id="lia.inventory.show"></a>lia.inventory.show(inventory, parent)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L773" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryshow"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates and opens a clientside panel for an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> Inventory instance to display.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">parent</span> <span class="optional">optional</span> Optional parent panel for the created inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The created inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = lia.inventory.show(inventory)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liainventoryshowdual">
<summary><span class="summary-main"><a id="lia.inventory.showDual"></a>lia.inventory.showDual(inventory1, inventory2, parent)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L814" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryshowdual"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens two inventory panels side by side and links their close behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory1</span> First inventory instance to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory2</span> Second inventory instance to display.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">parent</span> <span class="optional">optional</span> Optional parent panel for the created inventory panels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> A table containing both created panels, or nil if panel creation fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panels = lia.inventory.showDual(characterInv, storageInv)
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

<details class="realm-client" id="function-createinventorypanel">
<summary><span class="summary-main"><a id="CreateInventoryPanel"></a>CreateInventoryPanel(inventory, parent)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createinventorypanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows the clientside inventory interface to be created for a specific inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory instance that needs a panel.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">parent</span> <span class="optional">optional</span> Optional parent panel for the created inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> The created inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateInventoryPanel", "liaExampleCreateInventoryPanel", function(inventory, parent)
      print("[MyModule] handled CreateInventoryPanel")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryclosed">
<summary><span class="summary-main"><a id="InventoryClosed"></a>InventoryClosed(panel, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L76" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when an inventory panel is removed or closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The inventory panel that was closed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory instance that was displayed by the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryClosed", "liaExampleInventoryClosed", function(panel, inventory)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryClosed handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryopened">
<summary><span class="summary-main"><a id="InventoryOpened"></a>InventoryOpened(panel, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L45" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after an inventory panel has been created and opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The inventory panel that was opened.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory instance displayed by the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryOpened", "liaExampleInventoryOpened", function(panel, inventory)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryOpened handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatedualinventorypanels">
<summary><span class="summary-main"><a id="OnCreateDualInventoryPanels"></a>OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/inventory.lua#L107" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreatedualinventorypanels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after two inventory panels have been created and positioned for a dual-inventory view.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel1</span> The panel displaying the first inventory.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel2</span> The panel displaying the second inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory1</span> The first inventory instance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory2</span> The second inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateDualInventoryPanels", "liaExampleOnCreateDualInventoryPanels", function(panel1, panel2, inventory1, inventory2)
      print("[MyModule] handled OnCreateDualInventoryPanels")
  end)
</code></pre>
</div>

</div>
</details>

---

