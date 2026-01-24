# Character Library

Comprehensive character creation, management, and persistence system for the Lilia framework.

---

Overview

The character library provides comprehensive functionality for managing player characters in the Lilia framework. It handles character creation, loading, saving, and management across both server and client sides. The library operates character data persistence, networking synchronization, and provides hooks for character variable changes. It includes functions for character validation, database operations, inventory management, and character lifecycle management. The library ensures proper character data integrity and provides a robust system for character-based gameplay mechanics including factions, attributes, money, and custom character variables.

---

<details class="realm-shared">
<summary><a id=lia.char.getCharacter></a>lia.char.getCharacter(charID, client, callback)</summary>
<a id="liachargetcharacter"></a>
<p>Retrieve a character by ID from cache or request a load if missing.</p>
<p>Anytime code needs a character object by ID (selection, networking, admin tools).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to fetch.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Owning player; only used server-side when loading.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with the character once available (server cached immediately, otherwise after load/network).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> The character object if already cached; otherwise nil while loading.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.getCharacter(targetID, ply, function(char)
        if char then
            char:sync(ply)
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getAll></a>lia.char.getAll()</summary>
<a id="liachargetall"></a>
<p>Return a table of all players currently holding loaded characters.</p>
<p>For admin panels, diagnostics, or mass operations over active characters.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Keyed by Player with values of their active character objects.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for ply, char in pairs(lia.char.getAll()) do
        print(ply:Name(), char:getName())
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.isLoaded></a>lia.char.isLoaded(charID)</summary>
<a id="liacharisloaded"></a>
<p>Check if a character ID currently exists in the local cache.</p>
<p>Before loading or accessing a character to avoid duplicate work.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to test.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the character is cached, otherwise false.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if not lia.char.isLoaded(id) then
        lia.char.getCharacter(id)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.addCharacter></a>lia.char.addCharacter(id, character)</summary>
<a id="liacharaddcharacter"></a>
<p>Insert a character into the cache and resolve any pending requests.</p>
<p>After successfully loading or creating a character object.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> Character database ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">character</span> Character object to store.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.addCharacter(char:getID(), char)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.removeCharacter></a>lia.char.removeCharacter(id)</summary>
<a id="liacharremovecharacter"></a>
<p>Remove a character from the local cache.</p>
<p>After a character is deleted, unloaded, or no longer needed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> Character database ID to remove.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.removeCharacter(charID)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.new></a>lia.char.new(data, id, client, steamID)</summary>
<a id="liacharnew"></a>
<p>Construct a character object and populate its variables with provided data or defaults.</p>
<p>During character creation or when rebuilding a character from stored data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Raw character data keyed by variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> <span class="optional">optional</span> Database ID; defaults to 0 when nil.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Owning player entity, if available.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">steamID</span> <span class="optional">optional</span> SteamID string used when no player entity is provided.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> New character object.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local char = lia.char.new(row, row.id, ply)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.hookVar></a>lia.char.hookVar(varName, hookName, func)</summary>
<a id="liacharhookvar"></a>
<p>Register a hook function that runs when a specific character variable changes.</p>
<p>When modules need to react to updates of a given character variable.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">varName</span> Character variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">hookName</span> Unique identifier for the hook.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">func</span> Callback invoked with (character, oldValue, newValue).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.hookVar("money", "OnMoneyChanged", function(char, old, new)
        hook.Run("OnCharMoneyChanged", char, old, new)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.registerVar></a>lia.char.registerVar(key, data)</summary>
<a id="liacharregistervar"></a>
<p>Register a character variable and generate accessor/mutator helpers with optional networking.</p>
<p>During schema load to declare character fields such as name, money, or custom data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Configuration table defining defaults, validation, networking, and callbacks.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.registerVar("title", {
        field = "title",
        fieldType = "string",
        default = "",
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getCharData></a>lia.char.getCharData(charID, key)</summary>
<a id="liachargetchardata"></a>
<p>Read character data key/value pairs stored in the chardata table.</p>
<p>When modules need arbitrary persisted data for a character, optionally scoped to a single key.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to query.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> <span class="optional">optional</span> Optional specific data key to return.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|any|nil</a></span> Table of all key/value pairs, a single value when key is provided, or nil if not found/invalid.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local prestige = lia.char.getCharData(charID, "prestige")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getCharDataRaw></a>lia.char.getCharDataRaw(charID, key)</summary>
<a id="liachargetchardataraw"></a>
<p>Retrieve raw character data from chardata without touching the cache.</p>
<p>When a direct database read is needed, bypassing any loaded character state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to query.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> <span class="optional">optional</span> Optional key for a single value; omit to fetch all.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any|table|false|nil</a></span> Decoded value for the key, a table of all key/value pairs, false if a keyed lookup is missing, or nil on invalid input.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local allData = lia.char.getCharDataRaw(charID)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getOwnerByID></a>lia.char.getOwnerByID(ID)</summary>
<a id="liachargetownerbyid"></a>
<p>Find the player entity that owns a given character ID.</p>
<p>When needing to target or notify the current owner of a loaded character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">ID</span> Character database ID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Player who currently has the character loaded, or nil if none.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local owner = lia.char.getOwnerByID(charID)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getBySteamID></a>lia.char.getBySteamID(steamID)</summary>
<a id="liachargetbysteamid"></a>
<p>Get the active character of an online player by SteamID/SteamID64.</p>
<p>For lookups across connected players when only a Steam identifier is known.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">steamID</span> SteamID or SteamID64 string.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Character object if the player is online and has one loaded, else nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local char = lia.char.getBySteamID(targetSteamID)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.char.getTeamColor></a>lia.char.getTeamColor(client)</summary>
<a id="liachargetteamcolor"></a>
<p>Return the team/class color for a player, falling back to team color.</p>
<p>Whenever UI or drawing code needs a consistent color for the player's current class.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose color is requested.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Color table sourced from class definition or team color.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local color = lia.char.getTeamColor(ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.create></a>lia.char.create(data, callback)</summary>
<a id="liacharcreate"></a>
<p>Create a new character row, build its object, and initialize inventories.</p>
<p>During character creation after validation to persist and ready the new character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Prepared character data including steamID, faction, and name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with the new character ID once creation finishes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.create(payload, function(charID) print("created", charID) end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.restore></a>lia.char.restore(client, callback, id)</summary>
<a id="liacharrestore"></a>
<p>Load all characters for a player (or a specific ID) into memory and inventory.</p>
<p>On player connect or when an admin requests to restore a specific character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose characters should be loaded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with a list of loaded character IDs once complete.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> <span class="optional">optional</span> Optional single character ID to restrict the load.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.restore(ply, function(chars) print("loaded", #chars) end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.cleanUpForPlayer></a>lia.char.cleanUpForPlayer(client)</summary>
<a id="liacharcleanupforplayer"></a>
<p>Unload and save all characters cached for a player.</p>
<p>When a player disconnects or is cleaned up to free memory and inventories.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose cached characters should be unloaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.cleanUpForPlayer(ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.delete></a>lia.char.delete(id, client)</summary>
<a id="liachardelete"></a>
<p>Delete a character, its data, and inventories, and notify affected players.</p>
<p>By admin or player actions that permanently remove a character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> Character database ID to delete.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player requesting deletion, if any.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.delete(charID, ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.getCharBanned></a>lia.char.getCharBanned(charID)</summary>
<a id="liachargetcharbanned"></a>
<p>Check the ban state of a character in the database.</p>
<p>Before allowing a character to load or when displaying ban info.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Ban flag/value (0 if not banned), or nil on invalid input.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.char.getCharBanned(id) ~= 0 then return end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.setCharDatabase></a>lia.char.setCharDatabase(charID, field, value)</summary>
<a id="liacharsetchardatabase"></a>
<p>Write a character variable to the database and update any loaded instance.</p>
<p>Whenever persistent character fields or custom data need to be changed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">field</span> Character var or custom data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store; nil removes custom data entries.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True on success, false on immediate failure.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.setCharDatabase(charID, "money", newAmount)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.unloadCharacter></a>lia.char.unloadCharacter(charID)</summary>
<a id="liacharunloadcharacter"></a>
<p>Save and unload a character from memory, clearing associated data vars.</p>
<p>When a character is no longer active or needs to be freed from cache.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to unload.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if a character was unloaded, false if none was loaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.unloadCharacter(charID)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.unloadUnusedCharacters></a>lia.char.unloadUnusedCharacters(client, activeCharID)</summary>
<a id="liacharunloadunusedcharacters"></a>
<p>Unload all cached characters for a player except the currently active one.</p>
<p>After character switches to reduce memory and inventory usage.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose cached characters should be reduced.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">activeCharID</span> Character ID to keep loaded.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Count of characters that were unloaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.unloadUnusedCharacters(ply, newCharID)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.char.loadSingleCharacter></a>lia.char.loadSingleCharacter(charID, client, callback)</summary>
<a id="liacharloadsinglecharacter"></a>
<p>Load a single character from the database, building inventories and caching it.</p>
<p>When a specific character is selected, restored, or fetched server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Character database ID to load.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Owning player, used for permission checks and inventory linking.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with the loaded character or nil on failure.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.char.loadSingleCharacter(id, ply, function(char) if char then char:sync(ply) end end)
</code></pre>
</details>

---

