# Item Meta

Item management system for the Lilia framework.

---

Overview

The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.

---

<details class="realm-shared">
<summary><a id=isRotated></a>isRotated()</summary>
<a id="isrotated"></a>
<p>Reports whether the item is stored in a rotated state.</p>
<p>Use when calculating grid dimensions or rendering the item icon.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the item is rotated.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if item:isRotated() then swapDims() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getWidth></a>getWidth()</summary>
<a id="getwidth"></a>
<p>Returns the item's width considering rotation and defaults.</p>
<p>Use when placing the item into a grid inventory.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Width in grid cells.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local w = item:getWidth()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getHeight></a>getHeight()</summary>
<a id="getheight"></a>
<p>Returns the item's height considering rotation and defaults.</p>
<p>Use when calculating how much vertical space an item needs.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Height in grid cells.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local h = item:getHeight()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getQuantity></a>getQuantity()</summary>
<a id="getquantity"></a>
<p>Returns the current stack quantity for this item.</p>
<p>Use when showing stack counts or validating transfers.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Quantity within the stack.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local count = item:getQuantity()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=tostring></a>tostring()</summary>
<a id="tostring"></a>
<p>Builds a readable string identifier for the item.</p>
<p>Use for logging, debugging, or console output.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Formatted identifier including uniqueID and item id.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    print(item:tostring())
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getID></a>getID()</summary>
<a id="getid"></a>
<p>Retrieves the numeric identifier for this item instance.</p>
<p>Use when persisting, networking, or comparing items.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Unique item ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local id = item:getID()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getModel></a>getModel()</summary>
<a id="getmodel"></a>
<p>Returns the model path assigned to this item.</p>
<p>Use when spawning an entity or rendering the item icon.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Model file path.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local mdl = item:getModel()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getSkin></a>getSkin()</summary>
<a id="getskin"></a>
<p>Returns the skin index assigned to this item.</p>
<p>Use when spawning the entity or applying cosmetics.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Skin index or nil when not set.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local skin = item:getSkin()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getBodygroups></a>getBodygroups()</summary>
<a id="getbodygroups"></a>
<p>Provides the bodygroup configuration for the item model.</p>
<p>Use when spawning or rendering to ensure correct bodygroups.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Key-value pairs of bodygroup indexes to values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local groups = item:getBodygroups()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getPrice></a>getPrice()</summary>
<a id="getprice"></a>
<p>Calculates the current sale price for the item.</p>
<p>Use when selling, buying, or displaying item cost.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Price value, possibly adjusted by calcPrice.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cost = item:getPrice()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=call></a>call(method, client, entity)</summary>
<a id="call"></a>
<p>Invokes an item method while temporarily setting context.</p>
<p>Use when you need to call an item function with player/entity context.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">method</span> Name of the item method to invoke.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player to treat as the caller.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> <span class="optional">optional</span> Entity representing the item.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Return values from the invoked method.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:call("onUse", ply, ent)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getOwner></a>getOwner()</summary>
<a id="getowner"></a>
<p>Attempts to find the player that currently owns this item.</p>
<p>Use when routing notifications or networking to the item owner.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Owning player if found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local owner = item:getOwner()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getData></a>getData(key, default)</summary>
<a id="getdata"></a>
<p>Reads a stored data value from the item or its entity.</p>
<p>Use for custom item metadata such as durability or rotation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to read.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Value to return when the key is missing.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local durability = item:getData("durability", 100)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getAllData></a>getAllData()</summary>
<a id="getalldata"></a>
<p>Returns a merged table of all item data, including entity netvars.</p>
<p>Use when syncing the entire data payload to clients.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Combined data table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = item:getAllData()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hook></a>hook(name, func)</summary>
<a id="hook"></a>
<p>Registers a pre-run hook for an item interaction.</p>
<p>Use when adding custom behavior before an action executes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Hook name to bind.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">func</span> Callback to execute.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:hook("use", function(itm) end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=postHook></a>postHook(name, func)</summary>
<a id="posthook"></a>
<p>Registers a post-run hook for an item interaction.</p>
<p>Use when you need to react after an action completes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Hook name to bind.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">func</span> Callback to execute with results.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:postHook("use", function(itm, result) end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=onRegistered></a>onRegistered()</summary>
<a id="onregistered"></a>
<p>Performs setup tasks after an item definition is registered.</p>
<p>Automatically invoked once the item type is loaded.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:onRegistered()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=print></a>print(detail)</summary>
<a id="print"></a>
<p>Prints a concise or detailed identifier for the item.</p>
<p>Use during debugging or admin commands.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">detail</span> Include owner and grid info when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:print(true)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=printData></a>printData()</summary>
<a id="printdata"></a>
<p>Outputs item metadata and all stored data fields.</p>
<p>Use for diagnostics to inspect an item's state.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:printData()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getName></a>getName()</summary>
<a id="getname"></a>
<p>Returns the display name of the item.</p>
<p>Use for UI labels, tooltips, and logs.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Item name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local name = item:getName()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getDesc></a>getDesc()</summary>
<a id="getdesc"></a>
<p>Returns the description text for the item.</p>
<p>Use in tooltips or inventory details.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Item description.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local desc = item:getDesc()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removeFromInventory></a>removeFromInventory(preserveItem)</summary>
<a id="removefrominventory"></a>
<p>Removes the item from its current inventory instance.</p>
<p>Use when dropping, deleting, or transferring the item out.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">preserveItem</span> When true, keeps the instance for later use.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Deferred resolution for removal completion.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:removeFromInventory():next(function() end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=delete></a>delete()</summary>
<a id="delete"></a>
<p>Deletes the item record from storage after destroying it in-game.</p>
<p>Use when an item should be permanently removed.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves after the database delete and callbacks run.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:delete()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=remove></a>remove()</summary>
<a id="remove"></a>
<p>Removes the world entity, inventory reference, and database entry.</p>
<p>Use when the item is consumed or otherwise removed entirely.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Promise</a></span> Resolves once removal and deletion complete.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:remove()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=destroy></a>destroy()</summary>
<a id="destroy"></a>
<p>Broadcasts item deletion to clients and frees the instance.</p>
<p>Use internally before removing an item from memory.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:destroy()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onDisposed></a>onDisposed()</summary>
<a id="ondisposed"></a>
<p>Hook called after an item is destroyed; intended for overrides.</p>
<p>Automatically triggered when the item instance is disposed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onDisposed() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onDisposed></a>onDisposed()</summary>
<a id="ondisposed"></a>
<p>Hook called after an item is destroyed; intended for overrides.</p>
<p>Automatically triggered when the item instance is disposed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onDisposed() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=getEntity></a>getEntity()</summary>
<a id="getentity"></a>
<p>Finds the world entity representing this item instance.</p>
<p>Use when needing the spawned entity from the item data.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|nil</a></span> Spawned item entity if present.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ent = item:getEntity()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=spawn></a>spawn(position, angles)</summary>
<a id="spawn"></a>
<p>Spawns a world entity for this item at the given position and angle.</p>
<p>Use when dropping an item into the world.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector|table|Entity</a></span> <span class="parameter">position</span> Where to spawn, or the player dropping the item.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle|Vector|table</a></span> <span class="parameter">angles</span> <span class="optional">optional</span> Orientation for the spawned entity.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|nil</a></span> Spawned entity on success.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ent = item:spawn(ply, Angle(0, 0, 0))
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=transfer></a>transfer(newInventory, bBypass)</summary>
<a id="transfer"></a>
<p>Moves the item into another inventory if access rules allow.</p>
<p>Use when transferring items between containers or players.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">newInventory</span> Destination inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">bBypass</span> Skip access checks when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the transfer was initiated.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:transfer(otherInv)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onInstanced></a>onInstanced()</summary>
<a id="oninstanced"></a>
<p>Hook called when a new item instance is created.</p>
<p>Automatically invoked after instancing; override to customize.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onInstanced() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onInstanced></a>onInstanced()</summary>
<a id="oninstanced"></a>
<p>Hook called when a new item instance is created.</p>
<p>Automatically invoked after instancing; override to customize.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onInstanced() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onSync></a>onSync(recipient)</summary>
<a id="onsync"></a>
<p>Hook called after the item data is synchronized to clients.</p>
<p>Triggered by sync calls; override for custom behavior.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">recipient</span> <span class="optional">optional</span> The player who received the sync, or nil for broadcast.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onSync(ply) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onSync></a>onSync(recipient)</summary>
<a id="onsync"></a>
<p>Hook called after the item data is synchronized to clients.</p>
<p>Triggered by sync calls; override for custom behavior.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">recipient</span> <span class="optional">optional</span> The player who received the sync, or nil for broadcast.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onSync(ply) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onRemoved></a>onRemoved()</summary>
<a id="onremoved"></a>
<p>Hook called after the item has been removed from the world/inventory.</p>
<p>Automatically invoked once deletion finishes.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onRemoved() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onRemoved></a>onRemoved()</summary>
<a id="onremoved"></a>
<p>Hook called after the item has been removed from the world/inventory.</p>
<p>Automatically invoked once deletion finishes.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onRemoved() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onRestored></a>onRestored()</summary>
<a id="onrestored"></a>
<p>Hook called after an item is restored from persistence.</p>
<p>Automatically invoked after loading an item from the database.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onRestored() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=onRestored></a>onRestored()</summary>
<a id="onrestored"></a>
<p>Hook called after an item is restored from persistence.</p>
<p>Automatically invoked after loading an item from the database.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    function ITEM:onRestored() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=sync></a>sync(recipient)</summary>
<a id="sync"></a>
<p>Sends this item instance to a recipient or all clients for syncing.</p>
<p>Use after creating or updating an item instance.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">recipient</span> <span class="optional">optional</span> Specific player to sync; broadcasts when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:sync(ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setData></a>setData(key, value, receivers, noSave, noCheckEntity)</summary>
<a id="setdata"></a>
<p>Sets a custom data value on the item, networking and saving as needed.</p>
<p>Use when updating item metadata that clients or persistence require.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">receivers</span> <span class="optional">optional</span> Targets to send the update to; defaults to owner.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noSave</span> Skip database write when true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noCheckEntity</span> Skip updating the world entity netvar when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:setData("durability", 80, item:getOwner())
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addQuantity></a>addQuantity(quantity, receivers, noCheckEntity)</summary>
<a id="addquantity"></a>
<p>Increases the item quantity by the given amount.</p>
<p>Use for stacking items or consuming partial quantities.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">quantity</span> Amount to add (can be negative).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">receivers</span> <span class="optional">optional</span> Targets to notify; defaults to owner.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noCheckEntity</span> Skip updating the entity netvar when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:addQuantity(-1, ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setQuantity></a>setQuantity(quantity, receivers, noCheckEntity)</summary>
<a id="setquantity"></a>
<p>Sets the item quantity, updating entities, clients, and storage.</p>
<p>Use after splitting stacks or consuming items.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">quantity</span> New stack amount.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">receivers</span> <span class="optional">optional</span> Targets to notify; defaults to owner.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noCheckEntity</span> Skip updating the world entity netvar when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:setQuantity(5, ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=interact></a>interact(action, client, entity, data)</summary>
<a id="interact"></a>
<p>Handles an item interaction action, running hooks and callbacks.</p>
<p>Use when a player selects an action from an item's context menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">action</span> Action identifier from the item's functions table.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player performing the action.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> <span class="optional">optional</span> World entity representing the item, if any.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">data</span> Additional data for multi-option actions.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the action was processed; false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    item:interact("use", ply, ent)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getCategory></a>getCategory()</summary>
<a id="getcategory"></a>
<p>Returns the item's localized category label.</p>
<p>Use when grouping or displaying items by category.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Localized category name, or "misc" if undefined.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local category = item:getCategory()
</code></pre>
</details>

---

