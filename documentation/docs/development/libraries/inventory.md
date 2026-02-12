# Inventory

Comprehensive inventory system management with multiple storage types for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The inventory library provides comprehensive functionality for managing inventory systems in the Lilia framework. It handles inventory type registration, instance creation, storage management, and database persistence. The library operates on both server and client sides, with the server managing inventory data persistence, loading, and storage registration, while the client handles inventory panel display and user interaction. It supports multiple inventory types, storage containers, vehicle trunks, and character-based inventory management. The library ensures proper data validation, caching, and cleanup for optimal performance.
</div>

---

<details class="realm-shared" id="function-liainventorynewtype">
<summary><a id="lia.inventory.newType"></a>lia.inventory.newType(typeID, invTypeStruct)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorynewtype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a new inventory type with the specified ID and structure.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization or when defining custom inventory types that extend the base inventory system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> Unique identifier for the inventory type.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">invTypeStruct</span> Table containing the inventory type definition with required fields like className, config, and methods.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.newType("grid", {
      className = "GridInv",
      config = {w = 10, h = 10},
      add = function(self, item) end,
      remove = function(self, item) end,
      sync = function(self, client) end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liainventorynew">
<summary><a id="lia.inventory.new"></a>lia.inventory.new(typeID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorynew"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a new inventory instance of the specified type.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when instantiating inventories during loading, character creation, or when creating new storage containers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> The inventory type identifier that was previously registered with newType.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A new inventory instance with items table and copied config from the type definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local myInventory = lia.inventory.new("grid")
  -- Creates a new grid-based inventory instance
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadbyid">
<summary><a id="lia.inventory.loadByID"></a>lia.inventory.loadByID(id, noCache)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadbyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an inventory instance by its ID, checking cache first and falling back to storage loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when accessing inventories by ID, typically during character loading, item operations, or storage access.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The unique inventory ID to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noCache</span> Optional flag to bypass cache and force loading from storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred object that resolves to the loaded inventory instance, or rejects if loading fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadByID(123):next(function(inventory)
      print("Loaded inventory:", inventory.id)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadfromdefaultstorage">
<summary><a id="lia.inventory.loadFromDefaultStorage"></a>lia.inventory.loadFromDefaultStorage(id, noCache)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadfromdefaultstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads an inventory from the default database storage, including associated data and items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called by loadByID when no custom storage loader is found, or when directly loading from database storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The inventory ID to load from database storage.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noCache</span> Optional flag to bypass cache and force fresh loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred object that resolves to the fully loaded inventory instance with data and items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadFromDefaultStorage(456, true):next(function(inventory)
      -- Inventory loaded with fresh data, bypassing cache
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryinstance">
<summary><a id="lia.inventory.instance"></a>lia.inventory.instance(typeID, initialData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryinstance"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates a new inventory instance with persistent storage initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when creating new inventories that need database persistence, such as character inventories or storage containers.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">typeID</span> The inventory type identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">initialData</span> Optional initial data to store with the inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred object that resolves to the created inventory instance after storage initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.instance("grid", {char = 1}):next(function(inventory)
      -- New inventory created and stored in database
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryloadallfromcharid">
<summary><a id="lia.inventory.loadAllFromCharID"></a>lia.inventory.loadAllFromCharID(charID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryloadallfromcharid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads all inventories associated with a specific character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during character loading to restore all inventory data for a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">charID</span> The character ID to load inventories for (will be converted to number).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> A deferred object that resolves to an array of loaded inventory instances.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.loadAllFromCharID(42):next(function(inventories)
      for _, inv in ipairs(inventories) do
          print("Loaded inventory:", inv.id)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorydeletebyid">
<summary><a id="lia.inventory.deleteByID"></a>lia.inventory.deleteByID(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorydeletebyid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Permanently deletes an inventory and all its associated data from the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when removing inventories, such as during character deletion or storage cleanup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The inventory ID to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.deleteByID(123)
  -- Inventory 123 and all its data/items are permanently removed
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorycleanupforcharacter">
<summary><a id="lia.inventory.cleanUpForCharacter"></a>lia.inventory.cleanUpForCharacter(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorycleanupforcharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Destroys all inventories associated with a character during cleanup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during character deletion or when cleaning up character data to prevent memory leaks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">character</span> The character object whose inventories should be destroyed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.cleanUpForCharacter(player:getChar())
  -- All inventories for this character are destroyed
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorycheckoverflow">
<summary><a id="lia.inventory.checkOverflow"></a>lia.inventory.checkOverflow(inv, character, oldW, oldH)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorycheckoverflow"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks for items that no longer fit in an inventory after resizing and moves them to overflow storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when inventory dimensions change (like when upgrading inventory size) to handle items that no longer fit.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inv</span> The inventory instance to check for overflow.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">character</span> The character object to store overflow items on.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oldW</span> The previous width of the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oldH</span> The previous height of the inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if overflow items were found and moved, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.inventory.checkOverflow(inventory, player:getChar(), 5, 5) then
      -- Items were moved to overflow storage
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryregisterstorage">
<summary><a id="lia.inventory.registerStorage"></a>lia.inventory.registerStorage(model, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryregisterstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a storage container configuration for entities with the specified model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to define storage containers like lockers, crates, or other inventory-holding entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">model</span> The model path of the entity that will have storage capability.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Configuration table containing name, invType, invData, and other storage properties.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The registered storage data table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.registerStorage("models/props_c17/lockers001a.mdl", {
      name = "Locker",
      invType = "grid",
      invData = {w = 4, h = 6}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetstorage">
<summary><a id="lia.inventory.getStorage"></a>lia.inventory.getStorage(model)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the storage configuration for a specific model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when checking if an entity model has storage capabilities or retrieving storage properties.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">model</span> The model path to look up storage configuration for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The storage configuration table if found, nil otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local storage = lia.inventory.getStorage("models/props_c17/lockers001a.mdl")
  if storage then
      print("Storage name:", storage.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventoryregistertrunk">
<summary><a id="lia.inventory.registerTrunk"></a>lia.inventory.registerTrunk(vehicleClass, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryregistertrunk"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a vehicle trunk configuration for vehicles with the specified class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during gamemode initialization to define vehicle trunk storage capabilities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">vehicleClass</span> The vehicle class name that will have trunk capability.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Configuration table containing name, invType, invData, and trunk-specific properties.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The registered trunk data table with trunk flags set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.inventory.registerTrunk("vehicle_class", {
      name = "Car Trunk",
      invType = "grid",
      invData = {w = 8, h = 4}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygettrunk">
<summary><a id="lia.inventory.getTrunk"></a>lia.inventory.getTrunk(vehicleClass)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygettrunk"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves the trunk configuration for a specific vehicle class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when checking if a vehicle class has trunk capabilities or retrieving trunk properties.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">vehicleClass</span> The vehicle class name to look up trunk configuration for.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The trunk configuration table if found and it's a trunk, nil otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local trunk = lia.inventory.getTrunk("vehicle_class")
  if trunk then
      print("Trunk capacity:", trunk.invData.w, "x", trunk.invData.h)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetalltrunks">
<summary><a id="lia.inventory.getAllTrunks"></a>lia.inventory.getAllTrunks()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetalltrunks"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all registered trunk configurations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when listing all available vehicle trunk types or for administrative purposes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table containing all registered trunk configurations keyed by vehicle class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local trunks = lia.inventory.getAllTrunks()
  for class, config in pairs(trunks) do
      print("Trunk for", class, ":", config.name)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liainventorygetallstorage">
<summary><a id="lia.inventory.getAllStorage"></a>lia.inventory.getAllStorage(includeTrunks)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventorygetallstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all registered storage configurations, optionally excluding trunks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when listing all available storage types or for administrative purposes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">includeTrunks</span> Optional flag to include (true) or exclude (false) trunk configurations. Defaults to true.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table containing all registered storage configurations, optionally filtered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Get all storage including trunks
  local allStorage = lia.inventory.getAllStorage(true)
  -- Get only non-trunk storage
  local storageOnly = lia.inventory.getAllStorage(false)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liainventoryshow">
<summary><a id="lia.inventory.show"></a>lia.inventory.show(inventory, parent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryshow"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates and displays an inventory panel for the specified inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when opening inventory interfaces, such as character inventories, storage containers, or other inventory UIs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory instance to display in the panel.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">parent</span> Optional parent panel for the inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> The created inventory panel instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = lia.inventory.show(myInventory)
  -- Opens the inventory UI for myInventory
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liainventoryshowdual">
<summary><a id="lia.inventory.showDual"></a>lia.inventory.showDual(inventory1, inventory2, parent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainventoryshowdual"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates and displays two inventory panels side by side for dual inventory interactions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when opening dual inventory interfaces, such as trading, transferring items between inventories, or accessing storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory1</span> The first inventory instance to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory2</span> The second inventory instance to display.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">parent</span> Optional parent panel for the inventory panels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> An array containing both created inventory panel instances {panel1, panel2}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panels = lia.inventory.showDual(playerInv, storageInv)
  -- Opens dual inventory UI for trading between player and storage
</code></pre>
</div>

</div>
</details>

---

