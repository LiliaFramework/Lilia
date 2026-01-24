# Network Library

Network communication and data streaming system for the Lilia framework.

---

Overview

The network library provides comprehensive functionality for managing network communication in the Lilia framework. It handles both simple message passing and complex data streaming between server and client. The library includes support for registering network message handlers, sending messages to specific targets or broadcasting to all clients, and managing large data transfers through chunked streaming. It also provides global variable synchronization across the network, allowing server-side variables to be automatically synchronized with clients. The library operates on both server and client sides, with server handling message broadcasting and client handling message reception and acknowledgment.

---

<details class="realm-shared">
<summary><a id=lia.net.isCacheHit></a>lia.net.isCacheHit(name, args)</summary>
<a id="lianetiscachehit"></a>
<p>Determine if a net payload with given args is still fresh in cache.</p>
<p>Before sending large net payloads to avoid duplicate work.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Cache identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">args</span> Arguments that define cache identity.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if cached entry exists within TTL.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if not lia.net.isCacheHit("bigSync", {ply:SteamID64()}) then
        lia.net.writeBigTable(ply, "liaBigSync", payload)
        lia.net.addToCache("bigSync", {ply:SteamID64()})
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.net.addToCache></a>lia.net.addToCache(name, args)</summary>
<a id="lianetaddtocache"></a>
<p>Insert a cache marker for a named payload/args combination.</p>
<p>Right after sending a large or expensive net payload.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Cache identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">args</span> Arguments that define cache identity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.net.writeBigTable(targets, "liaDialogSync", data)
    lia.net.addToCache("dialogSync", {table.Count(data)})
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.net.readBigTable></a>lia.net.readBigTable(netStr, callback)</summary>
<a id="lianetreadbigtable"></a>
<p>Receive chunked JSON-compressed tables and reconstruct them.</p>
<p>To register a receiver for big table streams (both realms).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">netStr</span> Net message name carrying the chunks.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Function called when table is fully received. Client: function(tbl), Server: function(ply, tbl).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.net.readBigTable("liaDoorDataBulk", function(tbl)
        if not tbl then return end
        for doorID, data in pairs(tbl) do
            lia.doors.updateCachedData(doorID, data)
        end
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.net.writeBigTable></a>lia.net.writeBigTable(targets, netStr, tbl, chunkSize)</summary>
<a id="lianetwritebigtable"></a>
<p>Send a large table by compressing and chunking it across the net.</p>
<p>For big payloads (dialog sync, door data, keybinds) that exceed net limits.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">targets</span> <span class="optional">optional</span> Single player, list of players, or nil to broadcast to humans.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">netStr</span> Net message name to use.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tbl</span> Data to serialize.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">chunkSize</span> <span class="optional">optional</span> Optional override for chunk size.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local payload = {doors = lia.doors.stored, ts = os.time()}
    lia.net.writeBigTable(player.GetHumans(), "liaDoorDataBulk", payload, 2048)
    lia.net.addToCache("doorBulk", {payload.ts})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.net.checkBadType></a>lia.net.checkBadType(name, object)</summary>
<a id="lianetcheckbadtype"></a>
<p>Validate netvar payloads to prevent functions being networked.</p>
<p>Internally before setting globals/locals.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Identifier for error reporting.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">object</span> Value to validate for networking safety.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean|nil</a></span> true if bad type detected.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.net.checkBadType("example", someTable) then return end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.net.setNetVar></a>lia.net.setNetVar(key, value, receiver)</summary>
<a id="lianetsetnetvar"></a>
<p>Set a global netvar and broadcast it (or send to specific receiver).</p>
<p>Whenever shared state changes (config sync, feature flags, etc.).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Netvar identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to set.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|table</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Optional target(s); broadcasts when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.net.setNetVar("eventActive", true)
    lia.net.setNetVar("roundNumber", round, targetPlayers)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.net.getNetVar></a>lia.net.getNetVar(key, default)</summary>
<a id="lianetgetnetvar"></a>
<p>Retrieve a global netvar with a fallback default.</p>
<p>Client/server code reading synchronized state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Netvar identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Fallback value if netvar is not set.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.net.getNetVar("eventActive", false) then
        DrawEventHUD()
    end
</code></pre>
</details>

---

