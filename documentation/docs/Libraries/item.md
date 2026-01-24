# Item Library

Comprehensive item registration, instantiation, and management system for the Lilia framework.

---

Overview

The item library provides comprehensive functionality for managing items in the Lilia framework. It handles item registration, instantiation, inventory management, and item operations such as dropping, taking, rotating, and transferring items between players. The library operates on both server and client sides, with server-side functions handling database operations, item spawning, and data persistence, while client-side functions manage item interactions and UI operations. It includes automatic weapon and ammunition generation from Garry's Mod weapon lists, inventory type registration, and item entity management. The library ensures proper item lifecycle management from creation to deletion, with support for custom item functions, hooks, and data persistence.

---

<details class="realm-shared">
<summary><a id=lia.item.get></a>lia.item.get(identifier)</summary>
<a id="liaitemget"></a>
<p>Retrieves an item definition (base or regular item) by its unique identifier.</p>
<p>Called when needing to access item definitions for registration, validation, or manipulation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> The unique identifier of the item to retrieve.</p>

<p><h3>Returns:</h3>
table or nil The item definition table if found, nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local weaponItem = lia.item.get("weapon_pistol")
    if weaponItem then
        print("Found weapon:", weaponItem.name)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.getItemByID></a>lia.item.getItemByID(itemID)</summary>
<a id="liaitemgetitembyid"></a>
<p>Retrieves an instanced item by its ID and determines its current location.</p>
<p>Called when needing to access specific item instances, typically for manipulation or inspection.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> The unique ID of the instanced item to retrieve.</p>

<p><h3>Returns:</h3>
table or nil, string A table containing the item and its location ("inventory", "world", or "unknown"), or nil and an error message if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local itemData, errorMsg = lia.item.getItemByID(123)
    if itemData then
        print("Item found at:", itemData.location)
        -- Use itemData.item for item operations
    else
        print("Error:", errorMsg)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.getInstancedItemByID></a>lia.item.getInstancedItemByID(itemID)</summary>
<a id="liaitemgetinstanceditembyid"></a>
<p>Retrieves an instanced item directly by its ID without location information.</p>
<p>Called when needing to access item instances for direct manipulation without location context.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> The unique ID of the instanced item to retrieve.</p>

<p><h3>Returns:</h3>
table or nil, string The item instance if found, or nil and an error message if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local item, errorMsg = lia.item.getInstancedItemByID(123)
    if item then
        item:setData("customValue", "example")
    else
        print("Error:", errorMsg)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.getItemDataByID></a>lia.item.getItemDataByID(itemID)</summary>
<a id="liaitemgetitemdatabyid"></a>
<p>Retrieves the data table of an instanced item by its ID.</p>
<p>Called when needing to access or inspect the custom data stored on an item instance.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> The unique ID of the instanced item to retrieve data from.</p>

<p><h3>Returns:</h3>
table or nil, string The item's data table if found, or nil and an error message if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data, errorMsg = lia.item.getItemDataByID(123)
    if data then
        print("Item durability:", data.durability or "N/A")
    else
        print("Error:", errorMsg)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.load></a>lia.item.load(path, baseID, isBaseItem)</summary>
<a id="liaitemload"></a>
<p>Loads and registers an item from a file path by extracting the unique ID and registering it.</p>
<p>Called during item loading process to register items from files in the items directory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> The file path of the item to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">string, optional</a></span> <span class="parameter">baseID</span> The base item ID to inherit from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">isBaseItem</span> Whether this is a base item definition.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load a regular item
    lia.item.load("lilia/gamemode/items/food_apple.lua")
    -- Load a base item
    lia.item.load("lilia/gamemode/items/base/sh_food.lua", nil, true)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.isItem></a>lia.item.isItem(object)</summary>
<a id="liaitemisitem"></a>
<p>Checks if an object is a valid Lilia item instance.</p>
<p>Called to validate that an object is an item before performing item-specific operations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">object</span> The object to check if it's an item.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the object is a valid item, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local someObject = getSomeObject()
    if lia.item.isItem(someObject) then
        someObject:setData("used", true)
    else
        print("Object is not an item")
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.getInv></a>lia.item.getInv(invID)</summary>
<a id="liaitemgetinv"></a>
<p>Retrieves an inventory instance by its ID.</p>
<p>Called when needing to access inventory objects for item operations or inspection.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">invID</span> The unique ID of the inventory to retrieve.</p>

<p><h3>Returns:</h3>
table or nil The inventory instance if found, nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local inventory = lia.item.getInv(5)
    if inventory then
        print("Inventory size:", inventory:getWidth(), "x", inventory:getHeight())
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.addRarities></a>lia.item.addRarities(name, color)</summary>
<a id="liaitemaddrarities"></a>
<p>Adds a new item rarity tier with an associated color for visual identification.</p>
<p>Called during item system initialization to define available rarity levels for items.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> The name of the rarity tier (e.g., "Common", "Rare", "Legendary").</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> The color associated with this rarity tier.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.item.addRarities("Mythical", Color(255, 0, 255))
    lia.item.addRarities("Divine", Color(255, 215, 0))
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.register></a>lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)</summary>
<a id="liaitemregister"></a>
<p>Registers an item definition with the Lilia item system, setting up inheritance and default functions.</p>
<p>Called during item loading to register item definitions, either from files or programmatically generated.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique identifier for the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">string, optional</a></span> <span class="parameter">baseID</span> The base item ID to inherit from (defaults to lia.meta.item).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">isBaseItem</span> Whether this is a base item definition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">string, optional</a></span> <span class="parameter">path</span> The file path for loading the item (used for shared loading).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">luaGenerated</span> Whether the item is generated programmatically rather than loaded from a file.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The registered item definition table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Register a base item
    lia.item.register("base_weapon", nil, true, "path/to/base_weapon.lua")
    -- Register a regular item
    lia.item.register("weapon_pistol", "base_weapon", false, "path/to/weapon_pistol.lua")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.registerItem></a>lia.item.registerItem(id, base, properties)</summary>
<a id="liaitemregisteritem"></a>
<p>Queues an item for deferred registration and returns a placeholder that can access the item once registered.</p>
<p>Called during item system initialization to register items that will be created later, such as auto-generated weapons or ammunition items.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> The unique identifier for the item to register.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">string, optional</a></span> <span class="parameter">base</span> The base item ID to inherit from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">table, optional</a></span> <span class="parameter">properties</span> A table of properties to apply to the item when it is registered.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> A placeholder object that can access the actual item properties once registration is complete.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Queue a weapon item for registration
    local weaponPlaceholder = lia.item.registerItem("weapon_pistol", "base_weapons", {
        name = "Custom Pistol",
        width = 2,
        height = 1
    })
    -- The actual item will be registered when InitializedModules hook runs
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.overrideItem></a>lia.item.overrideItem(uniqueID, overrides)</summary>
<a id="liaitemoverrideitem"></a>
<p>Queues property overrides for an item that will be applied when the item is initialized.</p>
<p>Called during item system setup to modify item properties before they are finalized.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the item to override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">overrides</span> A table of properties to override on the item.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.item.overrideItem("weapon_pistol", {
        name = "Custom Pistol",
        width = 2,
        height = 1,
        price = 500
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.loadFromDir></a>lia.item.loadFromDir(directory)</summary>
<a id="liaitemloadfromdir"></a>
<p>Loads all items from a directory structure, organizing base items and regular items.</p>
<p>Called during gamemode initialization to load all item definitions from the items directory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">directory</span> The directory path containing the item files to load.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load all items from the gamemode's items directory
    lia.item.loadFromDir("lilia/gamemode/items")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.new></a>lia.item.new(uniqueID, id)</summary>
<a id="liaitemnew"></a>
<p>Creates a new item instance from an item definition with a specific ID.</p>
<p>Called when instantiating items from the database or creating new items programmatically.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the item definition to instantiate.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> The unique instance ID for this item.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The newly created item instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a new pistol item instance
    local pistol = lia.item.new("weapon_pistol", 123)
    pistol:setData("durability", 100)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.registerInv></a>lia.item.registerInv(invType, w, h)</summary>
<a id="liaitemregisterinv"></a>
<p>Registers a new inventory type with specified dimensions.</p>
<p>Called during inventory system initialization to define different inventory types.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">invType</span> The unique type identifier for this inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> The width of the inventory in grid units.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> The height of the inventory in grid units.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Register a backpack inventory type
    lia.item.registerInv("backpack", 4, 6)
    -- Register a safe inventory type
    lia.item.registerInv("safe", 8, 8)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.newInv></a>lia.item.newInv(owner, invType, callback)</summary>
<a id="liaitemnewinv"></a>
<p>Creates a new inventory instance for a character and syncs it with the appropriate player.</p>
<p>Called when creating new inventories for characters, such as during character creation or item operations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">owner</span> The character ID that owns this inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">invType</span> The type of inventory to create.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">function, optional</a></span> <span class="parameter">callback</span> Function called when the inventory is created and ready.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a backpack inventory for character ID 5
    lia.item.newInv(5, "backpack", function(inventory)
        print("Backpack created with ID:", inventory:getID())
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.createInv></a>lia.item.createInv(w, h, id)</summary>
<a id="liaitemcreateinv"></a>
<p>Creates a new inventory instance with specified dimensions and registers it.</p>
<p>Called when creating inventories programmatically, such as for containers or special storage.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> The width of the inventory in grid units.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> The height of the inventory in grid units.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> The unique ID for this inventory instance.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The created inventory instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a 4x6 container inventory
    local container = lia.item.createInv(4, 6, 1001)
    print("Container created with ID:", container.id)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.addWeaponOverride></a>lia.item.addWeaponOverride(className, data)</summary>
<a id="liaitemaddweaponoverride"></a>
<p>Adds custom override data for weapon items during auto-generation.</p>
<p>Called during weapon item generation to customize properties of specific weapons.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">className</span> The weapon class name to override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> The override data containing weapon properties.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.item.addWeaponOverride("weapon_pistol", {
        name = "Custom Pistol",
        width = 2,
        height = 1,
        price = 500,
        model = "models/weapons/custom_pistol.mdl"
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.item.addWeaponToBlacklist></a>lia.item.addWeaponToBlacklist(className)</summary>
<a id="liaitemaddweapontoblacklist"></a>
<p>Adds a weapon class to the blacklist to prevent it from being auto-generated as an item.</p>
<p>Called during weapon generation setup to exclude certain weapons from item creation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">className</span> The weapon class name to blacklist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Prevent admin tools from being generated as items
    lia.item.addWeaponToBlacklist("weapon_physgun")
    lia.item.addWeaponToBlacklist("gmod_tool")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.setItemDataByID></a>lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)</summary>
<a id="liaitemsetitemdatabyid"></a>
<p>Sets data on an item instance by its ID and synchronizes the changes.</p>
<p>Called when needing to modify item data server-side and sync to clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">itemID</span> The unique ID of the item instance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> The data key to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> The value to set for the key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">table, optional</a></span> <span class="parameter">receivers</span> Specific players to sync the data to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">noSave</span> Whether to skip saving to database.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">noCheckEntity</span> Whether to skip entity validation.</p>

<p><h3>Returns:</h3>
boolean, string True if successful, false and error message if failed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local success, errorMsg = lia.item.setItemDataByID(123, "durability", 75)
    if success then
        print("Item durability updated")
    else
        print("Error:", errorMsg)
    end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.instance></a>lia.item.instance(index, uniqueID, itemData, x, y, callback)</summary>
<a id="liaiteminstance"></a>
<p>Creates a new item instance in the database and returns the created item.</p>
<p>Called when creating new items that need to be persisted to the database.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">index</span> The inventory ID or unique ID if first parameter is string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">uniqueID</span> The item definition unique ID or item data if index is string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">table, optional</a></span> <span class="parameter">itemData</span> The item data to set on creation.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">number, optional</a></span> <span class="parameter">x</span> The X position in inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">number, optional</a></span> <span class="parameter">y</span> The Y position in inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">function, optional</a></span> <span class="parameter">callback</span> Function called when item is created.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> A deferred promise that resolves with the created item.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a pistol in inventory 5 at position 1,1
    lia.item.instance(5, "weapon_pistol", {}, 1, 1):next(function(item)
        print("Created item with ID:", item:getID())
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.deleteByID></a>lia.item.deleteByID(id)</summary>
<a id="liaitemdeletebyid"></a>
<p>Deletes an item instance by its ID from memory and/or database.</p>
<p>Called when permanently removing items from the game world.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> The unique ID of the item to delete.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Delete item with ID 123
    lia.item.deleteByID(123)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.loadItemByID></a>lia.item.loadItemByID(itemIndex)</summary>
<a id="liaitemloaditembyid"></a>
<p>Loads item instances from the database by their IDs and recreates them in memory.</p>
<p>Called during server startup or when needing to restore items from the database.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|table</a></span> <span class="parameter">itemIndex</span> Single item ID or array of item IDs to load.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load a single item
    lia.item.loadItemByID(123)
    -- Load multiple items
    lia.item.loadItemByID({123, 456, 789})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.spawn></a>lia.item.spawn(uniqueID, position, callback, angles, data)</summary>
<a id="liaitemspawn"></a>
<p>Creates and spawns an item entity in the world at the specified position.</p>
<p>Called when dropping items or creating item entities in the game world.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique ID of the item to spawn.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">position</span> The position to spawn the item at.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">function, optional</a></span> <span class="parameter">callback</span> Function called when item is spawned.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Angle, optional</a></span> <span class="parameter">angles</span> The angles to set on the spawned item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">table, optional</a></span> <span class="parameter">data</span> The item data to set on creation.</p>

<p><h3>Returns:</h3>
table or nil A deferred promise that resolves with the spawned item, or nil if synchronous.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Spawn a pistol at a position
    lia.item.spawn("weapon_pistol", Vector(0, 0, 0), function(item)
        print("Spawned item:", item:getName())
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.item.restoreInv></a>lia.item.restoreInv(invID, w, h, callback)</summary>
<a id="liaitemrestoreinv"></a>
<p>Restores an inventory from the database and sets its dimensions.</p>
<p>Called when loading saved inventories from the database.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">invID</span> The unique ID of the inventory to restore.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> The width of the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> The height of the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">function, optional</a></span> <span class="parameter">callback</span> Function called when inventory is restored.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Restore a 4x6 inventory
    lia.item.restoreInv(5, 4, 6, function(inventory)
        print("Restored inventory with", inventory:getItemCount(), "items")
    end)
</code></pre>
</details>

---

