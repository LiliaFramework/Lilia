# Doors Library

Door management system for the Lilia framework providing preset configuration,

---

Overview

The doors library provides comprehensive door management functionality including
preset configuration, database schema verification, and data cleanup operations.
It handles door data persistence, loading door configurations from presets,
and maintaining database integrity. The library manages door ownership, access
permissions, faction and class restrictions, and provides utilities for door
data validation and corruption cleanup. It operates primarily on the server side
and integrates with the database system to persist door configurations across
server restarts. The library also handles door locking/unlocking mechanics and
provides hooks for custom door behavior integration.

---

<details class="realm-shared">
<summary><a id=lia.doors.getDoorDefaultValues></a>lia.doors.getDoorDefaultValues()</summary>
<a id="liadoorsgetdoordefaultvalues"></a>
<p>Retrieve door default values merged with any extra fields provided by modules.</p>
<p>Anywhere door defaults are needed (initialization, schema checks, load/save).</p>
<p><h3>Returns:</h3>
table defaults Map of field -> default value including extra fields. table extras Map of extra field definitions collected via the CollectDoorDataFields hook.</p>

</details>

---

<details class="realm-server">
<summary><a id=lia.doors.setCachedData></a>lia.doors.setCachedData(door, data)</summary>
<a id="liadoorssetcacheddata"></a>
<p>Store door data overrides in memory and sync to clients, omitting defaults.</p>
<p>After editing door settings (price, access, flags) server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Door data overrides.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.doors.setCachedData(door, {
        name = "Police HQ",
        price = 0,
        factions = {FACTION_POLICE}
    })
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.getCachedData></a>lia.doors.getCachedData(door)</summary>
<a id="liadoorsgetcacheddata"></a>
<p>Retrieve cached door data merged with defaults.</p>
<p>Before saving/loading or when building UI state for a door.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Complete door data with defaults filled.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = lia.doors.getCachedData(door)
    print("Door price:", data.price)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.syncDoorData></a>lia.doors.syncDoorData(door)</summary>
<a id="liadoorssyncdoordata"></a>
<p>Net-sync a single door's cached data to all clients.</p>
<p>After updating a door's data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.doors.syncDoorData(door)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.syncAllDoorsToClient></a>lia.doors.syncAllDoorsToClient(client)</summary>
<a id="liadoorssyncalldoorstoclient"></a>
<p>Bulk-sync all cached doors to a single client.</p>
<p>On player spawn/join or after admin refresh.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerInitialSpawn", "SyncDoorsOnJoin", function(ply)
        lia.doors.syncAllDoorsToClient(ply)
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.setData></a>lia.doors.setData(door, data)</summary>
<a id="liadoorssetdata"></a>
<p>Set data for a door (alias to setCachedData).</p>
<p>Convenience wrapper used by other systems.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.doors.setData(door, {locked = true})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.addPreset></a>lia.doors.addPreset(mapName, presetData)</summary>
<a id="liadoorsaddpreset"></a>
<p>Register a preset of door data for a specific map.</p>
<p>During map setup to predefine door ownership/prices.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">mapName</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">presetData</span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.doors.addPreset("rp_downtown", {
        [1234] = {name = "Bank", price = 0, factions = {FACTION_POLICE}},
        [5678] = {locked = true, hidden = true}
    })
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.getPreset></a>lia.doors.getPreset(mapName)</summary>
<a id="liadoorsgetpreset"></a>
<p>Retrieve a door preset table for a map.</p>
<p>During map load or admin inspection of presets.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">mapName</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local preset = lia.doors.getPreset(game.GetMap())
    if preset then PrintTable(preset) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.verifyDatabaseSchema></a>lia.doors.verifyDatabaseSchema()</summary>
<a id="liadoorsverifydatabaseschema"></a>
<p>Validate the doors database schema against expected columns.</p>
<p>On startup or after migrations to detect missing/mismatched columns.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DatabaseConnected", "VerifyDoorSchema", lia.doors.verifyDatabaseSchema)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.doors.cleanupCorruptedData></a>lia.doors.cleanupCorruptedData()</summary>
<a id="liadoorscleanupcorrupteddata"></a>
<p>Detect and repair corrupted faction/class door data in the database.</p>
<p>Maintenance task to clean malformed data entries.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    concommand.Add("lia_fix_doors", function(admin)
        if not IsValid(admin) or not admin:IsAdmin() then return end
        lia.doors.cleanupCorruptedData()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.doors.getData></a>lia.doors.getData(door)</summary>
<a id="liadoorsgetdata"></a>
<p>Access cached door data (server/client wrapper).</p>
<p>Anywhere door data is needed without hitting DB.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = lia.doors.getData(ent)
    if data.locked then
        -- show locked icon
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.doors.getCachedData></a>lia.doors.getCachedData(door)</summary>
<a id="liadoorsgetcacheddata"></a>
<p>Client helper to build full door data from cached entries.</p>
<p>For HUD/tooltips when interacting with doors.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local info = lia.doors.getCachedData(door)
    draw.SimpleText(info.name or "Door", "LiliaFont.18", x, y, color_white)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.doors.updateCachedData></a>lia.doors.updateCachedData(doorID, data)</summary>
<a id="liadoorsupdatecacheddata"></a>
<p>Update the client-side cache for a door ID (or clear it).</p>
<p>After receiving sync updates from the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">doorID</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> <span class="optional">optional</span> nil clears the cache entry.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.doors.updateCachedData(doorID, net.ReadTable())
</code></pre>
</details>

---

