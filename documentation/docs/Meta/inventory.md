# Inventory Meta

Inventory management system for the Lilia framework.

---

Overview

The inventory meta table provides comprehensive functionality for managing inventory data, item storage, and inventory operations in the Lilia framework. It handles inventory creation, item management, data persistence, capacity management, and inventory-specific operations. The meta table operates on both server and client sides, with the server managing inventory storage and validation while the client provides inventory data access and display. It includes integration with the item system for item storage, database system for inventory persistence, character system for character inventories, and network system for inventory synchronization. The meta table ensures proper inventory data synchronization, item capacity management, item validation, and comprehensive inventory lifecycle management from creation to deletion.

---

<details class="realm-shared">
<summary><a id=getData></a>getData(key, default)</summary>
<a id="getdata"></a>
<p>Retrieves a stored data value on the inventory.</p>
<p>Use whenever reading custom inventory metadata.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to read.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Value returned when the key is missing.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value or the provided default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local owner = inv:getData("char")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=extend></a>extend(className)</summary>
<a id="extend"></a>
<p>Creates a subclass of Inventory with its own metatable.</p>
<p>Use when defining a new inventory type.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">className</span> Registry name for the new subclass.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Newly created subclass table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local Backpack = Inventory:extend("liaBackpack")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=configure></a>configure()</summary>
<a id="configure"></a>
<p>Sets up inventory defaults; meant to be overridden.</p>
<p>Invoked during type registration to configure behavior.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:configure() self.config.size = {4,4} end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=configure></a>configure()</summary>
<a id="configure"></a>
<p>Sets up inventory defaults; meant to be overridden.</p>
<p>Invoked during type registration to configure behavior.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:configure() self.config.size = {4,4} end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=addDataProxy></a>addDataProxy(key, onChange)</summary>
<a id="adddataproxy"></a>
<p>Registers a proxy callback for a specific data key.</p>
<p>Use when you need to react to data changes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to watch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">onChange</span> Callback receiving old and new values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:addDataProxy("locked", function(o,n) end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItemsByUniqueID></a>getItemsByUniqueID(uniqueID, onlyMain)</summary>
<a id="getitemsbyuniqueid"></a>
<p>Returns all items in the inventory matching a uniqueID.</p>
<p>Use when finding all copies of a specific item type.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Item unique identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">onlyMain</span> Restrict search to main inventory when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of matching item instances.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local meds = inv:getItemsByUniqueID("medkit")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=register></a>register(typeID)</summary>
<a id="register"></a>
<p>Registers this inventory type with the system.</p>
<p>Invoke once per subclass to set type ID and defaults.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">typeID</span> Unique identifier for this inventory type.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    Inventory:register("bag")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=new></a>new()</summary>
<a id="new"></a>
<p>Creates a new instance of this inventory type.</p>
<p>Use when a character or container needs a fresh inventory.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Deferred inventory instance creation.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local inv = Inventory:new()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=tostring></a>tostring()</summary>
<a id="tostring"></a>
<p>Formats the inventory as a readable string with its ID.</p>
<p>Use for logging or debugging output.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Localized class name and ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    print(inv:tostring())
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getType></a>getType()</summary>
<a id="gettype"></a>
<p>Returns the inventory type definition table.</p>
<p>Use when accessing type-level configuration.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Registered inventory type data.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local typeData = inv:getType()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=onDataChanged></a>onDataChanged(key, oldValue, newValue)</summary>
<a id="ondatachanged"></a>
<p>Fires proxy callbacks when a tracked data value changes.</p>
<p>Internally after setData updates.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">newValue</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:onDataChanged("locked", false, true)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItems></a>getItems()</summary>
<a id="getitems"></a>
<p>Returns the table of item instances in this inventory.</p>
<p>Use when iterating all items.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Item instances keyed by item ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for id, itm in pairs(inv:getItems()) do end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItemsOfType></a>getItemsOfType(itemType)</summary>
<a id="getitemsoftype"></a>
<p>Collects items of a given type from the inventory.</p>
<p>Use when filtering for a specific item uniqueID.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">itemType</span> Unique item identifier to match.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of matching items.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local foods = inv:getItemsOfType("food")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getFirstItemOfType></a>getFirstItemOfType(itemType)</summary>
<a id="getfirstitemoftype"></a>
<p>Returns the first item matching a uniqueID.</p>
<p>Use when only one instance of a type is needed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">itemType</span> Unique item identifier to find.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Item instance or nil if none found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local gun = inv:getFirstItemOfType("pistol")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasItem></a>hasItem(itemType)</summary>
<a id="hasitem"></a>
<p>Checks whether the inventory contains an item type.</p>
<p>Use before consuming or requiring an item.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">itemType</span> Unique item identifier to check.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if at least one matching item exists.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if inv:hasItem("keycard") then unlock() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItemCount></a>getItemCount(itemType)</summary>
<a id="getitemcount"></a>
<p>Counts items, optionally filtering by uniqueID.</p>
<p>Use for capacity checks or UI badge counts.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">itemType</span> <span class="optional">optional</span> Unique ID to filter by; nil counts all.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Total quantity of matching items.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ammoCount = inv:getItemCount("ammo")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getID></a>getID()</summary>
<a id="getid"></a>
<p>Returns the numeric identifier for this inventory.</p>
<p>Use when networking, saving, or comparing inventories.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Inventory ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local id = inv:getID()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addItem></a>addItem(item, noReplicate)</summary>
<a id="additem"></a>
<p>Inserts an item into this inventory and persists its invID.</p>
<p>Use when adding an item to the inventory on the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance to add.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noReplicate</span> Skip replication hooks when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> The inventory for chaining.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:addItem(item)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=add></a>add(item)</summary>
<a id="add"></a>
<p>Alias to addItem for convenience.</p>
<p>Use wherever you would call addItem.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance to add.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> The inventory for chaining.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:add(item)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=syncItemAdded></a>syncItemAdded(item)</summary>
<a id="syncitemadded"></a>
<p>Notifies clients about an item newly added to this inventory.</p>
<p>Invoked after addItem to replicate state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance already inserted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:syncItemAdded(item)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=initializeStorage></a>initializeStorage(initialData)</summary>
<a id="initializestorage"></a>
<p>Creates a database record for a new inventory and its data.</p>
<p>Use during initial inventory creation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">initialData</span> Key/value pairs to seed invdata rows; may include char.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves with new inventory ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:initializeStorage({char = charID})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=restoreFromStorage></a>restoreFromStorage()</summary>
<a id="restorefromstorage"></a>
<p>Hook for restoring inventory data from storage.</p>
<p>Override to load custom data during restoration.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:restoreFromStorage() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=restoreFromStorage></a>restoreFromStorage()</summary>
<a id="restorefromstorage"></a>
<p>Hook for restoring inventory data from storage.</p>
<p>Override to load custom data during restoration.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:restoreFromStorage() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removeItem></a>removeItem(itemID, preserveItem)</summary>
<a id="removeitem"></a>
<p>Removes an item from this inventory and updates clients/DB.</p>
<p>Use when deleting or moving items out of the inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> ID of the item to remove.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">preserveItem</span> Keep the instance and DB row when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves after removal finishes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:removeItem(itemID)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=remove></a>remove(itemID)</summary>
<a id="remove"></a>
<p>Alias for removeItem.</p>
<p>Use interchangeably with removeItem.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> ID of the item to remove.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves after removal.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:remove(id)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setData></a>setData(key, value)</summary>
<a id="setdata"></a>
<p>Updates inventory data, persists it, and notifies listeners.</p>
<p>Use to change stored metadata such as character assignment.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value or nil to delete.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> The inventory for chaining.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:setData("locked", true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=canAccess></a>canAccess(action, context)</summary>
<a id="canaccess"></a>
<p>Evaluates access rules for a given action context.</p>
<p>Use before allowing inventory interactions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">action</span> Action name (e.g., "repl", "transfer").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">context</span> Additional data such as client.</p>

<p><h3>Returns:</h3>
boolean|nil, string|nil Decision and optional reason if a rule handled it.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ok = inv:canAccess("repl", {client = ply})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addAccessRule></a>addAccessRule(rule, priority)</summary>
<a id="addaccessrule"></a>
<p>Inserts an access rule into the rule list.</p>
<p>Use when configuring permissions for this inventory type.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">rule</span> Function returning decision and reason.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">priority</span> <span class="optional">optional</span> Optional insert position.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> The inventory for chaining.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:addAccessRule(myRule, 1)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removeAccessRule></a>removeAccessRule(rule)</summary>
<a id="removeaccessrule"></a>
<p>Removes a previously added access rule.</p>
<p>Use when unregistering dynamic permission logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">rule</span> The rule function to remove.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> The inventory for chaining.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:removeAccessRule(myRule)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=getRecipients></a>getRecipients()</summary>
<a id="getrecipients"></a>
<p>Determines which players should receive inventory replication.</p>
<p>Use before sending inventory data to clients.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> List of player recipients allowed by access rules.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local recips = inv:getRecipients()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onInstanced></a>onInstanced()</summary>
<a id="oninstanced"></a>
<p>Hook called when an inventory instance is created.</p>
<p>Override to perform custom initialization.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onInstanced() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onInstanced></a>onInstanced()</summary>
<a id="oninstanced"></a>
<p>Hook called when an inventory instance is created.</p>
<p>Override to perform custom initialization.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onInstanced() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onLoaded></a>onLoaded()</summary>
<a id="onloaded"></a>
<p>Hook called after inventory data is loaded.</p>
<p>Override to react once storage data is retrieved.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onLoaded() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onLoaded></a>onLoaded()</summary>
<a id="onloaded"></a>
<p>Hook called after inventory data is loaded.</p>
<p>Override to react once storage data is retrieved.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onLoaded() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=loadItems></a>loadItems()</summary>
<a id="loaditems"></a>
<p>Loads item instances from the database into this inventory.</p>
<p>Use during inventory initialization to restore contents.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves with the loaded items table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:loadItems():next(function(items) end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onItemsLoaded></a>onItemsLoaded(items)</summary>
<a id="onitemsloaded"></a>
<p>Hook called after items are loaded into the inventory.</p>
<p>Override to run logic after contents are ready.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">items</span> Loaded items table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onItemsLoaded(items) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onItemsLoaded></a>onItemsLoaded(items)</summary>
<a id="onitemsloaded"></a>
<p>Hook called after items are loaded into the inventory.</p>
<p>Override to run logic after contents are ready.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">items</span> Loaded items table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function Inventory:onItemsLoaded(items) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=instance></a>instance(initialData)</summary>
<a id="instance"></a>
<p>Creates and registers an inventory instance with initial data.</p>
<p>Use to instantiate a server-side inventory of this type.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">initialData</span> Data used during creation (e.g., char assignment).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves with the new inventory instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    Inventory:instance({char = charID})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=syncData></a>syncData(key, recipients)</summary>
<a id="syncdata"></a>
<p>Sends a single inventory data key to recipients.</p>
<p>Use after setData to replicate a specific field.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to send.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">recipients</span> <span class="optional">optional</span> Targets to notify; defaults to recipients with access.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:syncData("locked")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=sync></a>sync(recipients)</summary>
<a id="sync"></a>
<p>Sends full inventory state and contained items to recipients.</p>
<p>Use when initializing or resyncing an inventory for clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">recipients</span> <span class="optional">optional</span> Targets to receive the update; defaults to access list.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:sync(ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=delete></a>delete()</summary>
<a id="delete"></a>
<p>Deletes this inventory via the inventory manager.</p>
<p>Use when permanently removing an inventory record.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:delete()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=destroy></a>destroy()</summary>
<a id="destroy"></a>
<p>Clears inventory items, removes it from cache, and notifies clients.</p>
<p>Use when unloading or destroying an inventory instance.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:destroy()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=show></a>show(parent)</summary>
<a id="show"></a>
<p>Opens the inventory UI on the client.</p>
<p>Use to display this inventory to the player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">parent</span> Optional parent panel.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> The created inventory panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    inv:show()
</code></pre>
</details>

---

