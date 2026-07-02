<style>
details > summary {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 70px;
    padding-right: 180px;
}

details > summary .summary-main {
    min-width: 0;
}

details > summary .source-link-button--summary {
    position: absolute;
    right: 56px;
    top: 50%;
    transform: translateY(-50%);
    white-space: nowrap;
    z-index: 2;
}
</style>

# Net

Networking helpers for Lilia networked variables, chunked table transfer, lightweight send caching, and network traffic profiling.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The net library centralizes shared networking helpers under `lia.net`. It provides cache markers for repeated message work, sends and receives large compressed tables in chunks, manages global networked variables, synchronizes networked data on player join or entity cleanup, and wraps Garry's Mod net functions with optional profiling output.
</div>

---

<details class="realm-shared" id="function-lianetiscachehit">
<summary><span class="summary-main"><a id="lia.net.isCacheHit"></a>lia.net.isCacheHit(name, args)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L124" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetiscachehit"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a named network cache entry exists and is still within the cache time-to-live window.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The cache namespace or message name used when the entry was created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">args</span> Ordered arguments used to build the cache key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> True when the cache entry exists and has not expired. False or nil otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if not lia.net.isCacheHit("SyncInventory", {client, itemID}) then
      lia.net.addToCache("SyncInventory", {client, itemID})
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianetaddtocache">
<summary><span class="summary-main"><a id="lia.net.addToCache"></a>lia.net.addToCache(name, args)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L149" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetaddtocache"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds or refreshes a named network cache entry and removes expired or excess cache entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The cache namespace or message name to store.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">args</span> Ordered arguments used to build the cache key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.net.addToCache("SyncInventory", {client, itemID})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianetreadbigtable">
<summary><span class="summary-main"><a id="lia.net.readBigTable"></a>lia.net.readBigTable(netStr, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L179" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetreadbigtable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a receiver for a chunked, compressed JSON table stream and rebuilds the table once every chunk has arrived.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">netStr</span> The network message name used for the chunk stream.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Function called after the table is reconstructed. On the server it receives `(Player client, table data)`. On the client it receives `(table data)`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.net.readBigTable("liaLargePayload", function(client, data)
      print(client, data)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-lianetwritebigtable">
<summary><span class="summary-main"><a id="lia.net.writeBigTable"></a>lia.net.writeBigTable(targets, netStr, tbl, chunkSize)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L296" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetwritebigtable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a table to one or more clients by JSON-encoding, compressing, chunking, and streaming it over a network message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|table</a></span> <span class="parameter">targets</span> <span class="optional">optional</span> The player, player table, or nil target set. If no valid target is provided, all human players receive the stream.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">netStr</span> The network message name used for the chunk stream.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tbl</span> The table to serialize and send.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">chunkSize</span> <span class="optional">optional</span> Optional maximum chunk size. The value is clamped and adjusted during reloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.net.writeBigTable(client, "liaLargePayload", data)
  lia.net.writeBigTable(player.GetHumans(), "liaLargePayload", data, 1024)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-lianetcheckbadtype">
<summary><span class="summary-main"><a id="lia.net.checkBadType"></a>lia.net.checkBadType(name, object)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L366" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetcheckbadtype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validates that a networked value does not contain functions, including functions nested inside tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The networked variable name being validated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">object</span> The value or nested table key/value currently being inspected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> True when an unsupported function value is found. Nil otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if lia.net.checkBadType("score", value) then return end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-lianetsetnetvar">
<summary><span class="summary-main"><a id="lia.net.setNetVar"></a>lia.net.setNetVar(key, value, receiver)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L400" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetsetnetvar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets a global networked variable, broadcasts or sends the change to clients, and runs the `NetVarChanged` hook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The global networked variable key to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to store and send. Functions are rejected, including functions nested in tables.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|table</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> Optional recipient or recipient table. When omitted, the change is broadcast to all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.net.setNetVar("roundState", "active")
  lia.net.setNetVar("eventName", "cleanup", client)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianetgetnetvar">
<summary><span class="summary-main"><a id="lia.net.getNetVar"></a>lia.net.getNetVar(key, default)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L446" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetgetnetvar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gets a global networked variable value from the local global networked variable store.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The global networked variable key to read.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">default</span> Value returned when the key has not been set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> The stored value when present, otherwise the provided default value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local state = lia.net.getNetVar("roundState", "waiting")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianetprofilerlog">
<summary><span class="summary-main"><a id="lia.net.profiler.log"></a>lia.net.profiler.log(direction, messageName, size, sender, receiver)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L537" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianetprofilerlog"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Records and prints a network profiler entry for a message when the profiler is active.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">direction</span> Message direction label, such as `S->C` or `C->S`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">messageName</span> The network message name being logged.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">size</span> The message size value supplied by the wrapper. Send wrappers pass `net.BytesWritten()`, while receive wrappers pass the `len` argument from `net.Receive`.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|string</a></span> <span class="parameter">sender</span> <span class="optional">optional</span> The sending player or sender label.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|string</a></span> <span class="parameter">receiver</span> <span class="optional">optional</span> The receiving player or receiver label.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.net.profiler.log("S-&gt;C", "liaGlobalVar", net.BytesWritten() or 0, "SERVER", client)
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-server" id="function-netvarchanged">
<summary><span class="summary-main"><a id="NetVarChanged"></a>NetVarChanged(entity, key, oldValue, newValue)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/net.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="netvarchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a networked variable changes. This file triggers it for global networked variables with `entity` set to nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Networking</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> <span class="optional">optional</span> The entity whose networked variable changed, or nil when a global networked variable changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The networked variable key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> The previous value stored for the key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">newValue</span> The new value stored for the key.</p>
</div>

</div>
</details>

---

