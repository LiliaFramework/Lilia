# Doors

Door management system for the Lilia framework providing preset configuration,

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The doors library provides comprehensive door management functionality including
preset configuration, database schema verification, and data cleanup operations.
It handles door data persistence, loading door configurations from presets,
and maintaining database integrity. The library manages door ownership, access
permissions, faction and class restrictions, and provides utilities for door
data validation and corruption cleanup. It operates primarily on the server side
and integrates with the database system to persist door configurations across
server restarts. The library also handles door locking/unlocking mechanics and
provides hooks for custom door behavior integration.
</div>

---

<details class="realm-shared" id="function-liadoorsgetdoordefaultvalues">
<summary><a id="lia.doors.getDoorDefaultValues"></a>lia.doors.getDoorDefaultValues()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsgetdoordefaultvalues"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieve door default values merged with any extra fields provided by modules.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Anywhere door defaults are needed (initialization, schema checks, load/save).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>table defaults Map of field -> default value including extra fields. table extras Map of extra field definitions collected via the CollectDoorDataFields hook.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorssetcacheddata">
<summary><a id="lia.doors.setCachedData"></a>lia.doors.setCachedData(door, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorssetcacheddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Store door data overrides in memory and sync to clients, omitting defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After editing door settings (price, access, flags) server-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Door data overrides.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.doors.setCachedData(door, {
      name = "Police HQ",
      price = 0,
      factions = {FACTION_POLICE}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorsgetcacheddata">
<summary><a id="lia.doors.getCachedData"></a>lia.doors.getCachedData(door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsgetcacheddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieve cached door data merged with defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before saving/loading or when building UI state for a door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Complete door data with defaults filled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local data = lia.doors.getCachedData(door)
  print("Door price:", data.price)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorssyncdoordata">
<summary><a id="lia.doors.syncDoorData"></a>lia.doors.syncDoorData(door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorssyncdoordata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Net-sync a single door's cached data to all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After updating a door's data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.doors.syncDoorData(door)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorssyncalldoorstoclient">
<summary><a id="lia.doors.syncAllDoorsToClient"></a>lia.doors.syncAllDoorsToClient(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorssyncalldoorstoclient"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Bulk-sync all cached doors to a single client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On player spawn/join or after admin refresh.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerInitialSpawn", "SyncDoorsOnJoin", function(ply)
      lia.doors.syncAllDoorsToClient(ply)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorssetdata">
<summary><a id="lia.doors.setData"></a>lia.doors.setData(door, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorssetdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set data for a door (alias to setCachedData).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Convenience wrapper used by other systems.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.doors.setData(door, {locked = true})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorsaddpreset">
<summary><a id="lia.doors.addPreset"></a>lia.doors.addPreset(mapName, presetData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsaddpreset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a preset of door data for a specific map.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During map setup to predefine door ownership/prices.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">mapName</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">presetData</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.doors.addPreset("rp_downtown", {
      [1234] = {name = "Bank", price = 0, factions = {FACTION_POLICE}},
      [5678] = {locked = true, hidden = true}
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorsgetpreset">
<summary><a id="lia.doors.getPreset"></a>lia.doors.getPreset(mapName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsgetpreset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieve a door preset table for a map.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During map load or admin inspection of presets.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">mapName</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local preset = lia.doors.getPreset(game.GetMap())
  if preset then PrintTable(preset) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorsverifydatabaseschema">
<summary><a id="lia.doors.verifyDatabaseSchema"></a>lia.doors.verifyDatabaseSchema()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsverifydatabaseschema"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validate the doors database schema against expected columns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On startup or after migrations to detect missing/mismatched columns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DatabaseConnected", "VerifyDoorSchema", lia.doors.verifyDatabaseSchema)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadoorscleanupcorrupteddata">
<summary><a id="lia.doors.cleanupCorruptedData"></a>lia.doors.cleanupCorruptedData()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorscleanupcorrupteddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Detect and repair corrupted faction/class door data in the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Maintenance task to clean malformed data entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  concommand.Add("lia_fix_doors", function(admin)
      if not IsValid(admin) or not admin:IsAdmin() then return end
      lia.doors.cleanupCorruptedData()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadoorsgetdata">
<summary><a id="lia.doors.getData"></a>lia.doors.getData(door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsgetdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Access cached door data (server/client wrapper).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Anywhere door data is needed without hitting DB.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local data = lia.doors.getData(ent)
  if data.locked then
      -- show locked icon
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadoorsgetcacheddata">
<summary><a id="lia.doors.getCachedData"></a>lia.doors.getCachedData(door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsgetcacheddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client helper to build full door data from cached entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>For HUD/tooltips when interacting with doors.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local info = lia.doors.getCachedData(door)
  draw.SimpleText(info.name or "Door", "LiliaFont.18", x, y, color_white)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadoorsupdatecacheddata">
<summary><a id="lia.doors.updateCachedData"></a>lia.doors.updateCachedData(doorID, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadoorsupdatecacheddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Update the client-side cache for a door ID (or clear it).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After receiving sync updates from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">doorID</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> <span class="optional">optional</span> nil clears the cache entry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.doors.updateCachedData(doorID, net.ReadTable())
</code></pre>
</div>

</div>
</details>

---

