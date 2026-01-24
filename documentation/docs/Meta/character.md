# Character Meta

Character management system for the Lilia framework.

---

Overview

The character meta table provides comprehensive functionality for managing character data, attributes, and operations in the Lilia framework. It handles character creation, data persistence, attribute management, recognition systems, and character-specific operations. The meta table operates on both server and client sides, with the server managing character storage and validation while the client provides character data access and display. It includes integration with the database system for character persistence, inventory management for character items, and faction/class systems for character roles. The meta table ensures proper character data synchronization, attribute calculations with boosts, recognition between characters, and comprehensive character lifecycle management from creation to deletion.

---

<details class="realm-shared">
<summary><a id=getID></a>getID()</summary>
<a id="getid"></a>
<p>Returns this character's unique numeric identifier.</p>
<p>Use when persisting, comparing, or networking character state.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Character ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local id = char:getID()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getPlayer></a>getPlayer()</summary>
<a id="getplayer"></a>
<p>Retrieves the player entity associated with this character.</p>
<p>Use whenever you need the live player controlling this character.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Player that owns the character, or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ply = char:getPlayer()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getDisplayedName></a>getDisplayedName(client)</summary>
<a id="getdisplayedname"></a>
<p>Returns the name to show to a viewing client, honoring recognition rules.</p>
<p>Use when rendering a character's name to another player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The viewer whose recognition determines the name.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Display name or a localized "unknown" placeholder.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local name = targetChar:getDisplayedName(viewer)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasMoney></a>hasMoney(amount)</summary>
<a id="hasmoney"></a>
<p>Checks if the character has at least the given amount of money.</p>
<p>Use before charging a character to ensure they can afford a cost.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> The amount to verify.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the character's balance is equal or higher.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if char:hasMoney(100) then purchase() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasFlags></a>hasFlags(flagStr)</summary>
<a id="hasflags"></a>
<p>Determines whether the character possesses any flag in the string.</p>
<p>Use when gating actions behind one or more privilege flags.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flagStr</span> One or more flag characters to test.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if at least one provided flag is present.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if char:hasFlags("ab") then grantAccess() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getAttrib></a>getAttrib(key, default)</summary>
<a id="getattrib"></a>
<p>Gets the character's attribute value including any active boosts.</p>
<p>Use when calculating rolls or stats that depend on attributes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Attribute identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">default</span> Fallback value if the attribute is missing.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Attribute level plus stacked boosts.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local strength = char:getAttrib("str", 0)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=doesRecognize></a>doesRecognize(id)</summary>
<a id="doesrecognize"></a>
<p>Determines whether this character recognizes another character.</p>
<p>Use when deciding if a viewer should see a real name or remain unknown.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|table</a></span> <span class="parameter">id</span> Character ID or object implementing getID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if recognition is allowed by hooks.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if viewerChar:doesRecognize(targetChar) then showName() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=doesFakeRecognize></a>doesFakeRecognize(id)</summary>
<a id="doesfakerecognize"></a>
<p>Checks if the character recognizes another under a fake name.</p>
<p>Use when evaluating disguise or alias recognition logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|table</a></span> <span class="parameter">id</span> Character ID or object implementing getID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if fake recognition passes custom hooks.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local canFake = char:doesFakeRecognize(otherChar)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=setData></a>setData(k, v, noReplication, receiver)</summary>
<a id="setdata"></a>
<p>Stores custom data on the character and optionally replicates it.</p>
<p>Use when adding persistent or networked character metadata.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">k</span> Key to set or table of key/value pairs.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">v</span> Value to store when k is a string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noReplication</span> Skip networking when true.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Specific client to receive the update instead of owner.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:setData("lastLogin", os.time())
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getData></a>getData(key, default)</summary>
<a id="getdata"></a>
<p>Retrieves previously stored custom character data.</p>
<p>Use when you need saved custom fields or default fallbacks.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> <span class="optional">optional</span> Specific key to fetch or nil for the whole table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Value to return if the key is unset.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value, default, or entire data table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local note = char:getData("note", "")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isBanned></a>isBanned()</summary>
<a id="isbanned"></a>
<p>Reports whether the character is currently banned.</p>
<p>Use when validating character selection or spawning.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if banned permanently or until a future time.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if char:isBanned() then denyJoin() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=recognize></a>recognize(character, name)</summary>
<a id="recognize"></a>
<p>Marks another character as recognized, optionally storing a fake name.</p>
<p>Invoke when a player learns or is assigned recognition of someone.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|table</a></span> <span class="parameter">character</span> Target character ID or object implementing getID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> <span class="optional">optional</span> Optional alias to remember instead of real recognition.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True after recognition is recorded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:recognize(otherChar)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=joinClass></a>joinClass(class, isForced)</summary>
<a id="joinclass"></a>
<p>Attempts to place the character into the specified class.</p>
<p>Use during class selection or forced reassignment.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">class</span> Class ID to join.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">isForced</span> Skip eligibility checks when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the class change succeeded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ok = char:joinClass(newClassID)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=kickClass></a>kickClass()</summary>
<a id="kickclass"></a>
<p>Removes the character from its current class, falling back to default.</p>
<p>Use when a class is invalid, revoked, or explicitly left.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:kickClass()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=updateAttrib></a>updateAttrib(key, value)</summary>
<a id="updateattrib"></a>
<p>Increases an attribute by the given amount, respecting maximums.</p>
<p>Use when awarding experience toward an attribute.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Attribute identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">value</span> Amount to add.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:updateAttrib("stm", 5)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setAttrib></a>setAttrib(key, value)</summary>
<a id="setattrib"></a>
<p>Directly sets an attribute to a specific value and syncs it.</p>
<p>Use when loading characters or forcing an attribute level.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Attribute identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">value</span> New attribute level.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:setAttrib("str", 15)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addBoost></a>addBoost(boostID, attribID, boostAmount)</summary>
<a id="addboost"></a>
<p>Adds a temporary boost to an attribute and propagates it.</p>
<p>Use when buffs or debuffs modify an attribute value.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">boostID</span> Unique identifier for the boost source.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">attribID</span> Attribute being boosted.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">boostAmount</span> Amount to add (can be negative).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Result from setVar update.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:addBoost("stimpack", "end", 2)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removeBoost></a>removeBoost(boostID, attribID)</summary>
<a id="removeboost"></a>
<p>Removes a previously applied attribute boost.</p>
<p>Use when a buff expires or is cancelled.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">boostID</span> Identifier of the boost source.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">attribID</span> Attribute to adjust.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Result from setVar update.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:removeBoost("stimpack", "end")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=clearAllBoosts></a>clearAllBoosts()</summary>
<a id="clearallboosts"></a>
<p>Clears all attribute boosts and notifies listeners.</p>
<p>Use when resetting a character's temporary modifiers.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Result from resetting the boost table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:clearAllBoosts()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setFlags></a>setFlags(flags)</summary>
<a id="setflags"></a>
<p>Replaces the character's flag string and synchronizes it.</p>
<p>Use when setting privileges wholesale (e.g., admin changes).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Complete set of flags to apply.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:setFlags("abc")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=giveFlags></a>giveFlags(flags)</summary>
<a id="giveflags"></a>
<p>Adds one or more flags to the character if they are missing.</p>
<p>Use when granting new permissions or perks.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Concatenated flag characters to grant.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:giveFlags("z")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=takeFlags></a>takeFlags(flags)</summary>
<a id="takeflags"></a>
<p>Removes specific flags from the character and triggers callbacks.</p>
<p>Use when revoking privileges or perks.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Concatenated flag characters to remove.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:takeFlags("z")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=save></a>save(callback)</summary>
<a id="save"></a>
<p>Persists the character's current variables to the database.</p>
<p>Use during saves, character switches, or shutdown to keep data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked after the save completes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:save(function() print("saved") end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=sync></a>sync(receiver)</summary>
<a id="sync"></a>
<p>Sends character data to a specific player or all players.</p>
<p>Use after character creation, load, or when vars change.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Target player to sync to; nil broadcasts to everyone.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:sync(client)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setup></a>setup(noNetworking)</summary>
<a id="setup"></a>
<p>Applies the character state to the owning player and optionally syncs.</p>
<p>Use right after a character is loaded or swapped in.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noNetworking</span> Skip inventory and char networking when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:setup()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=kick></a>kick()</summary>
<a id="kick"></a>
<p>Forces the owning player off this character and cleans up state.</p>
<p>Use when removing access, kicking, or swapping characters.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:kick()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=ban></a>ban(time)</summary>
<a id="ban"></a>
<p>Bans the character for a duration or permanently and kicks them.</p>
<p>Use for disciplinary actions like permakill or timed bans.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> <span class="optional">optional</span> Ban duration in seconds; nil makes it permanent.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:ban(3600)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=delete></a>delete()</summary>
<a id="delete"></a>
<p>Deletes the character from persistent storage.</p>
<p>Use when a character is intentionally removed by the player or admin.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:delete()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=destroy></a>destroy()</summary>
<a id="destroy"></a>
<p>Removes the character from the active cache without DB interaction.</p>
<p>Use when unloading a character instance entirely.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:destroy()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=giveMoney></a>giveMoney(amount)</summary>
<a id="givemoney"></a>
<p>Adds money to the character through the owning player object.</p>
<p>Use when rewarding or refunding currency.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Amount to add (can be negative to deduct).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> False if no valid player exists; otherwise result of addMoney.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:giveMoney(250)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=takeMoney></a>takeMoney(amount)</summary>
<a id="takemoney"></a>
<p>Deducts money from the character and logs the transaction.</p>
<p>Use when charging a player for purchases or penalties.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Amount to remove; the absolute value is used.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True after the deduction process runs.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    char:takeMoney(50)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=isMainCharacter></a>isMainCharacter()</summary>
<a id="ismaincharacter"></a>
<p>Checks whether this character matches the player's main character ID.</p>
<p>Use when showing main character indicators or restrictions.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if this character is the player's main selection.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if char:isMainCharacter() then highlight() end
</code></pre>
</details>

---

