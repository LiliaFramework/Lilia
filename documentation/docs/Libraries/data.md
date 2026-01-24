# Data Library

Data persistence, serialization, and management system for the Lilia framework.

---

Overview

The data library provides comprehensive functionality for data persistence, serialization, and management within the Lilia framework. It handles encoding and decoding of complex data types including vectors, angles, colors, and nested tables for database storage. The library manages both general data storage with gamemode and map-specific scoping, as well as entity persistence for maintaining spawned entities across server restarts. It includes automatic serialization/deserialization, database integration, and caching mechanisms to ensure efficient data access and storage operations.

---

<details class="realm-server">
<summary><a id=lia.data.encodetable></a>lia.data.encodetable(value)</summary>
<a id="liadataencodetable"></a>
<p>Encode vectors/angles/colors/tables into JSON-safe structures.</p>
<p>Before persisting data to DB or file storage.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Encoded representation.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local payload = lia.data.encodetable({
        pos = Vector(0, 0, 64),
        ang = Angle(0, 90, 0),
        tint = Color(255, 0, 0)
    })
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.decode></a>lia.data.decode(value)</summary>
<a id="liadatadecode"></a>
<p>Decode nested structures into native types (Vector/Angle/Color).</p>
<p>After reading serialized data from DB/file.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Decoded value with deep conversion.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local decoded = lia.data.decode(storedJsonTable)
    local pos = decoded.spawnPos
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.serialize></a>lia.data.serialize(value)</summary>
<a id="liadataserialize"></a>
<p>Serialize a value into JSON, pre-encoding special types.</p>
<p>Before writing data blobs into DB columns.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> JSON string.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local json = lia.data.serialize({pos = Vector(1,2,3)})
    lia.db.updateSomewhere(json)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.deserialize></a>lia.data.deserialize(raw)</summary>
<a id="liadatadeserialize"></a>
<p>Deserialize JSON/pon or raw tables back into native types.</p>
<p>After fetching data rows from DB.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table|any</a></span> <span class="parameter">raw</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local row = lia.db.select(...):get()
    local data = lia.data.deserialize(row.data)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.decodeVector></a>lia.data.decodeVector(raw)</summary>
<a id="liadatadecodevector"></a>
<p>Decode a vector from various string/table encodings.</p>
<p>While rebuilding persistent entities or map data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">raw</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector|any</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local pos = lia.data.decodeVector(row.pos)
    if isvector(pos) then ent:SetPos(pos) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.decodeAngle></a>lia.data.decodeAngle(raw)</summary>
<a id="liadatadecodeangle"></a>
<p>Decode an angle from string/table encodings.</p>
<p>During persistence loading or data deserialization.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">raw</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle|any</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ang = lia.data.decodeAngle(row.angles)
    if isangle(ang) then ent:SetAngles(ang) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.set></a>lia.data.set(key, value, global, ignoreMap)</summary>
<a id="liadataset"></a>
<p>Persist a key/value pair scoped to gamemode/map (or global).</p>
<p>To save configuration/state data into the DB.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">global</span> <span class="optional">optional</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">ignoreMap</span> <span class="optional">optional</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Path prefix used for file save fallback.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.data.set("event.active", true, false, false)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.delete></a>lia.data.delete(key, global, ignoreMap)</summary>
<a id="liadatadelete"></a>
<p>Delete a stored key (and row if empty) from DB cache.</p>
<p>To remove saved state/config entries.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">global</span> <span class="optional">optional</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">ignoreMap</span> <span class="optional">optional</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.data.delete("event.active")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.loadTables></a>lia.data.loadTables()</summary>
<a id="liadataloadtables"></a>
<p>Load stored data rows for global, gamemode, and map scopes.</p>
<p>On database ready to hydrate lia.data.stored cache.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DatabaseConnected", "LoadLiliaData", lia.data.loadTables)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.loadPersistence></a>lia.data.loadPersistence()</summary>
<a id="liadataloadpersistence"></a>
<p>Ensure persistence table has required columns; add if missing.</p>
<p>Before saving/loading persistent entities.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">promise</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.data.loadPersistence():next(function() print("Persistence columns ready") end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.savePersistence></a>lia.data.savePersistence(entities)</summary>
<a id="liadatasavepersistence"></a>
<p>Save persistent entities to the database (with dynamic columns).</p>
<p>On PersistenceSave hook/timer with collected entities.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">entities</span> Array of entity data tables.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">promise|nil</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Run("PersistenceSave", collectedEntities)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.loadPersistenceData></a>lia.data.loadPersistenceData(callback)</summary>
<a id="liadataloadpersistencedata"></a>
<p>Load persistent entities from DB, decode fields, and cache them.</p>
<p>On server start or when manually reloading persistence.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with entities table once loaded.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">promise</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.data.loadPersistenceData(function(entities)
        for _, entData in ipairs(entities) do
            -- spawn logic here
        end
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.get></a>lia.data.get(key, default)</summary>
<a id="liadataget"></a>
<p>Fetch a stored key from cache, deserializing strings on demand.</p>
<p>Anywhere stored data is read after loadTables.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local eventData = lia.data.get("event.settings", {})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.data.getPersistence></a>lia.data.getPersistence()</summary>
<a id="liadatagetpersistence"></a>
<p>Return the cached list of persistent entities (last loaded/saved).</p>
<p>For admin tools or debug displays.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    PrintTable(lia.data.getPersistence())
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.data.addEquivalencyMap></a>lia.data.addEquivalencyMap(map1, map2)</summary>
<a id="liadataaddequivalencymap"></a>
<p>Register an equivalency between two map names (bidirectional).</p>
<p>To share data/persistence across multiple map aliases.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">map1</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">map2</span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.data.addEquivalencyMap("rp_downtown_v1", "rp_downtown_v2")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.data.getEquivalencyMap></a>lia.data.getEquivalencyMap(map)</summary>
<a id="liadatagetequivalencymap"></a>
<p>Resolve a map name to its equivalency (if registered).</p>
<p>Before saving/loading data keyed by map name.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">map</span></p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local canonical = lia.data.getEquivalencyMap(game.GetMap())
</code></pre>
</details>

---

