# Classes Library

Character class management and validation system for the Lilia framework.

---

Overview

The classes library provides comprehensive functionality for managing character classes in the Lilia framework. It handles registration, validation, and management of player classes within factions. The library operates on both server and client sides, allowing for dynamic class creation, whitelist management, and player class assignment validation. It includes functionality for loading classes from directories, checking class availability, retrieving class information, and managing class limits. The library ensures proper faction validation and provides hooks for custom class behavior and restrictions.

---

<details class="realm-shared">
<summary><a id=lia.class.register></a>lia.class.register(uniqueID, data)</summary>
<a id="liaclassregister"></a>
<p>Registers or updates a class definition within the global class list.</p>
<p>Invoked during schema initialization or dynamic class creation to
ensure a class entry exists before use.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Unique identifier for the class; must be consistent across loads.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Class metadata such as name, desc, faction, limit, OnCanBe, etc.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The registered class table with applied defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.class.register("soldier", {
        name = "Soldier",
        faction = FACTION_MILITARY,
        limit = 4
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.loadFromDir></a>lia.class.loadFromDir(directory)</summary>
<a id="liaclassloadfromdir"></a>
<p>Loads and registers all class definitions from a directory.</p>
<p>Used during schema loading to automatically include class files in a
folder following the naming convention.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">directory</span> Path to the directory containing class Lua files.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.class.loadFromDir("lilia/gamemode/classes")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.canBe></a>lia.class.canBe(client, class)</summary>
<a id="liaclasscanbe"></a>
<p>Determines whether a client can join a specific class.</p>
<p>Checked before class selection to enforce faction, limits, whitelist,
and custom restrictions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player attempting to join the class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">class</span> Class index or unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean|string</a></span> False and a reason string on failure; otherwise returns the class's isDefault value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ok, reason = lia.class.canBe(ply, CLASS_CITIZEN)
    if ok then
        -- proceed with class change
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.get></a>lia.class.get(identifier)</summary>
<a id="liaclassget"></a>
<p>Retrieves a class table by index or unique identifier.</p>
<p>Used whenever class metadata is needed given a known identifier.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">identifier</span> Class list index or unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> The class table if found; otherwise nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local classData = lia.class.get("soldier")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.getPlayers></a>lia.class.getPlayers(class)</summary>
<a id="liaclassgetplayers"></a>
<p>Collects all players currently assigned to the given class.</p>
<p>Used when enforcing limits or displaying membership lists.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">class</span> Class list index or unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of player entities in the class.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, ply in ipairs(lia.class.getPlayers("soldier")) do
        -- notify class members
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.getPlayerCount></a>lia.class.getPlayerCount(class)</summary>
<a id="liaclassgetplayercount"></a>
<p>Counts how many players are in the specified class.</p>
<p>Used to check class limits or display class population.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">class</span> Class list index or unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Current number of players in the class.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local count = lia.class.getPlayerCount(CLASS_ENGINEER)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.retrieveClass></a>lia.class.retrieveClass(class)</summary>
<a id="liaclassretrieveclass"></a>
<p>Finds the class index by matching uniqueID or display name.</p>
<p>Used to resolve user input to a class entry before further lookups.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">class</span> Text to match against class uniqueID or name.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> The class index if a match is found; otherwise nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local idx = lia.class.retrieveClass("Engineer")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.hasWhitelist></a>lia.class.hasWhitelist(class)</summary>
<a id="liaclasshaswhitelist"></a>
<p>Checks whether a class uses whitelist access.</p>
<p>Queried before allowing class selection or displaying class info.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">class</span> Class list index or unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the class is whitelisted and not default; otherwise false.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.class.hasWhitelist(CLASS_PILOT) then
        -- restrict to whitelisted players
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.class.retrieveJoinable></a>lia.class.retrieveJoinable(client)</summary>
<a id="liaclassretrievejoinable"></a>
<p>Returns a list of classes the provided client is allowed to join.</p>
<p>Used to build class selection menus and enforce availability.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Target player; defaults to LocalPlayer on the client.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of class tables the client can currently join.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local options = lia.class.retrieveJoinable(ply)
</code></pre>
</details>

---

