# Logger Library

Comprehensive logging and audit trail system for the Lilia framework.

---

Overview

The logger library provides comprehensive logging functionality for the Lilia framework, enabling detailed tracking and recording of player actions, administrative activities, and system events. It operates on the server side and automatically categorizes log entries into predefined categories such as character management, combat, world interactions, chat communications, item transactions, administrative actions, and security events. The library stores all log entries in a database table with timestamps, player information, and categorized messages. It supports dynamic log type registration and provides hooks for external systems to process log events. The logger ensures accountability and provides administrators with detailed audit trails for server management and moderation.

---

<details class="realm-shared">
<summary><a id=lia.log.addType></a>lia.log.addType(logType, func, category)</summary>
<a id="lialogaddtype"></a>
<p>Register a new log type with formatter and category.</p>
<p>During init to add custom audit events (e.g., quests, crafting).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">logType</span> Unique log key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">func</span> Formatter function (client, ... ) -> string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">category</span> Category label used in console output and DB.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.log.addType("questComplete", function(client, questID, reward)
        return L("logQuestComplete", client:Name(), questID, reward)
    end, L("quests"))
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.log.getString></a>lia.log.getString(client, logType)</summary>
<a id="lialoggetstring"></a>
<p>Build a formatted log string and return its category.</p>
<p>Internally by lia.log.add before printing/persisting logs.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">logType</span> ... (vararg)</p>

<p><h3>Returns:</h3>
string|nil, string|nil logString, category</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local text, category = lia.log.getString(ply, "playerDeath", attackerName)
    if text then print(category, text) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.log.add></a>lia.log.add(client, logType)</summary>
<a id="lialogadd"></a>
<p>Create and store a log entry (console + database) using a logType.</p>
<p>Anywhere you need to audit player/admin/system actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">logType</span> ... (vararg)</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.log.add(client, "itemTake", itemName)
    lia.log.add(nil, "frameworkOutdated") -- system log without player
</code></pre>
</details>

---

