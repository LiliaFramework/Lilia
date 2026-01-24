# Entity Meta

Entity management system for the Lilia framework.

---

Overview

The entity meta table provides comprehensive functionality for extending Garry's Mod entities with Lilia-specific features and operations. It handles entity identification, sound management, door access control, vehicle ownership, network variable synchronization, and entity-specific operations. The meta table operates on both server and client sides, with the server managing entity data and validation while the client provides entity interaction and display. It includes integration with the door system for access control, vehicle system for ownership management, network system for data synchronization, and sound system for audio playback. The meta table ensures proper entity identification, access control validation, network data synchronization, and comprehensive entity interaction management for doors, vehicles, and other game objects.

---

<details class="realm-shared">
<summary><a id=EmitSound></a>EmitSound(soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)</summary>
<a id="emitsound"></a>
<p>Detour of Entity:EmitSound that plays a sound from this entity, handling web sound URLs and fallbacks.
This function overrides the base game's EmitSound method to add support for web-sourced audio streams.</p>
<p>Use whenever an entity needs to emit a sound that may be streamed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">soundName</span> File path or URL to play.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">soundLevel</span> Sound level for attenuation.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">pitchPercent</span> Pitch modifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">volume</span> Volume from 0-100.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">channel</span> Optional sound channel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">flags</span> Optional emit flags.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dsp</span> Optional DSP effect index.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True when handled by websound logic; otherwise base emit result.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:EmitSound("lilia/websounds/example.mp3", 75)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isProp></a>isProp()</summary>
<a id="isprop"></a>
<p>Indicates whether this entity is a physics prop.</p>
<p>Use when filtering interactions to physical props only.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity class is prop_physics.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isProp() then handleProp(ent) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isItem></a>isItem()</summary>
<a id="isitem"></a>
<p>Checks if the entity represents a Lilia item.</p>
<p>Use when distinguishing item entities from other entities.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity class is lia_item.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isItem() then pickUpItem(ent) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isMoney></a>isMoney()</summary>
<a id="ismoney"></a>
<p>Checks if the entity is a Lilia money pile.</p>
<p>Use when processing currency pickups or interactions.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity class is lia_money.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isMoney() then ent:Remove() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isSimfphysCar></a>isSimfphysCar()</summary>
<a id="issimfphyscar"></a>
<p>Determines whether the entity belongs to supported vehicle classes.</p>
<p>Use when applying logic specific to Simfphys/LVS vehicles.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity is a recognized vehicle type.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isSimfphysCar() then configureVehicle(ent) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=checkDoorAccess></a>checkDoorAccess(client, access)</summary>
<a id="checkdooraccess"></a>
<p>Verifies whether a client has a specific level of access to a door.</p>
<p>Use when opening menus or performing actions gated by door access.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting access.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">access</span> Required access level, defaults to DOOR_GUEST.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the client meets the access requirement.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if door:checkDoorAccess(ply, DOOR_OWNER) then openDoor() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=keysOwn></a>keysOwn(client)</summary>
<a id="keysown"></a>
<p>Assigns vehicle ownership metadata to a player.</p>
<p>Use when a player purchases or claims a vehicle entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player to set as owner.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    vehicle:keysOwn(ply)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=keysLock></a>keysLock()</summary>
<a id="keyslock"></a>
<p>Locks a vehicle entity via its Fire interface.</p>
<p>Use when a player locks their owned vehicle.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    vehicle:keysLock()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=keysUnLock></a>keysUnLock()</summary>
<a id="keysunlock"></a>
<p>Unlocks a vehicle entity via its Fire interface.</p>
<p>Use when giving a player access back to their vehicle.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    vehicle:keysUnLock()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getDoorOwner></a>getDoorOwner()</summary>
<a id="getdoorowner"></a>
<p>Retrieves the owning player for a door or vehicle, if any.</p>
<p>Use when displaying ownership information.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Owner entity or nil if unknown.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local owner = door:getDoorOwner()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isLocked></a>isLocked()</summary>
<a id="islocked"></a>
<p>Returns whether the entity is flagged as locked through net vars.</p>
<p>Use when deciding if interactions should be blocked.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity's locked net var is set.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if door:isLocked() then denyUse() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isDoorLocked></a>isDoorLocked()</summary>
<a id="isdoorlocked"></a>
<p>Checks the underlying lock state of a door entity.</p>
<p>Use when syncing lock visuals or handling use attempts.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the door reports itself as locked.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local locked = door:isDoorLocked()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isFemale></a>isFemale()</summary>
<a id="isfemale"></a>
<p>Infers whether the entity's model is tagged as female.</p>
<p>Use for gender-specific animations or sounds.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if GetModelGender returns "female".</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isFemale() then setFemaleVoice(ent) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getDoorPartner></a>getDoorPartner()</summary>
<a id="getdoorpartner"></a>
<p>Finds the paired door entity associated with this door.</p>
<p>Use when syncing double-door behavior or ownership.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|nil</a></span> Partner door entity when found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local partner = door:getDoorPartner()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=sendNetVar></a>sendNetVar(key, receiver)</summary>
<a id="sendnetvar"></a>
<p>Sends a networked variable for this entity to one or more clients.</p>
<p>Use immediately after changing lia.net values to sync them.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Net variable name to send.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Optional player to send to; broadcasts when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:sendNetVar("locked", ply)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=clearNetVars></a>clearNetVars(receiver)</summary>
<a id="clearnetvars"></a>
<p>Clears all stored net vars for this entity and notifies clients.</p>
<p>Use when an entity is being removed or reset.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Optional target to notify; broadcasts when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:clearNetVars()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removeDoorAccessData></a>removeDoorAccessData()</summary>
<a id="removedooraccessdata"></a>
<p>Resets stored door access data and closes any open menus.</p>
<p>Use when clearing door permissions or transferring ownership.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    door:removeDoorAccessData()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setLocked></a>setLocked(state)</summary>
<a id="setlocked"></a>
<p>Sets the locked net var state for this entity.</p>
<p>Use when toggling lock status server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">state</span> Whether the entity should be considered locked.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    door:setLocked(true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setKeysNonOwnable></a>setKeysNonOwnable(state)</summary>
<a id="setkeysnonownable"></a>
<p>Marks an entity as non-ownable for keys/door systems.</p>
<p>Use when preventing selling or owning of a door/vehicle.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">state</span> True to make the entity non-ownable.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    door:setKeysNonOwnable(true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setNetVar></a>setNetVar(key, value, receiver)</summary>
<a id="setnetvar"></a>
<p>Stores a networked variable for this entity and notifies listeners.</p>
<p>Use when updating shared entity state that clients need.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Net variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store and broadcast.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Optional player to send to; broadcasts when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:setNetVar("color", Color(255, 0, 0))
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setLocalVar></a>setLocalVar(key, value)</summary>
<a id="setlocalvar"></a>
<p>Saves a local (server-only) variable on the entity.</p>
<p>Use for transient server state that should not be networked.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Local variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:setLocalVar("cooldown", CurTime())
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=getLocalVar></a>getLocalVar(key, default)</summary>
<a id="getlocalvar"></a>
<p>Reads a server-side local variable stored on the entity.</p>
<p>Use when retrieving transient server-only state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Local variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Value to return if unset.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored local value or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cooldown = ent:getLocalVar("cooldown", 0)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=playFollowingSound></a>playFollowingSound(soundPath, volume, shouldFollow, maxDistance, startDelay, minDistance, pitch, soundLevel, dsp)</summary>
<a id="playfollowingsound"></a>
<p>Plays a web sound locally on the client, optionally following the entity.</p>
<p>Use when the client must play a streamed sound attached to an entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">soundPath</span> URL or path to the sound.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">volume</span> Volume from 0-1.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">shouldFollow</span> Whether the sound follows the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">maxDistance</span> Maximum audible distance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">startDelay</span> Delay before playback starts.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">minDistance</span> Minimum distance for attenuation.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">pitch</span> Playback rate multiplier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">soundLevel</span> Optional sound level for attenuation.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dsp</span> Optional DSP effect index.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ent:playFollowingSound(url, 1, true, 1200)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isDoor></a>isDoor()</summary>
<a id="isdoor"></a>
<p>Determines whether this entity should be treated as a door.</p>
<p>Use when applying door-specific logic on an entity.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the entity class matches common door types.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ent:isDoor() then handleDoor(ent) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getNetVar></a>getNetVar(key, default)</summary>
<a id="getnetvar"></a>
<p>Retrieves a networked variable stored on this entity.</p>
<p>Use when reading shared entity state on either server or client.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Net variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Fallback value if none is set.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored net var or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local locked = ent:getNetVar("locked", false)
</code></pre>
</details>

---

