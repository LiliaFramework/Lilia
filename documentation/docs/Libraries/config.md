# Configuration Library

Comprehensive user-configurable settings management system for the Lilia framework.

---

Overview

The configuration library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.

---

<details class="realm-shared">
<summary><a id=lia.config.add></a>lia.config.add(key, name, value, callback, data)</summary>
<a id="liaconfigadd"></a>
<p>Register a config entry with defaults, UI metadata, and optional callback.</p>
<p>During schema/module initialization to expose server-stored configuration.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Unique identifier for the config entry.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Display text or localization key for UI.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Default value; type inferred when data.type is omitted.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked server-side as callback(oldValue, newValue) after set().</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Fields such as type, desc, category, options/optionsFunc, noNetworking, etc.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, function(old, new)
        lia.option.set("thirdPersonDistance", math.min(lia.option.get("thirdPersonDistance", new), new))
    end, {category = "Lilia", type = "Int", min = 10, max = 200})
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.getOptions></a>lia.config.getOptions(key)</summary>
<a id="liaconfiggetoptions"></a>
<p>Resolve a config entry's selectable options, static list or generated.</p>
<p>Before rendering dropdown-type configs or validating submitted values.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key to resolve options for.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Options array or key/value table; empty when unavailable.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local opts = lia.config.getOptions("Theme")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.setDefault></a>lia.config.setDefault(key, value)</summary>
<a id="liaconfigsetdefault"></a>
<p>Override the default value for an already registered config entry.</p>
<p>During migrations, schema overrides, or backward-compatibility fixes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key to override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New default value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.setDefault("StartingMoney", 300)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.forceSet></a>lia.config.forceSet(key, value, noSave)</summary>
<a id="liaconfigforceset"></a>
<p>Force-set a config value and fire update hooks without networking.</p>
<p>Runtime adjustments (admin tools/commands) or hot reload scenarios.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key to change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to assign.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noSave</span> <span class="optional">optional</span> When true, skip persisting to disk.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.forceSet("MaxCharacters", 10, false)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.set></a>lia.config.set(key, value)</summary>
<a id="liaconfigset"></a>
<p>Set a config value, fire update hooks, run server callbacks, network to clients, and persist.</p>
<p>Through admin tools/commands or internal code updating configuration.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key to change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to assign and broadcast.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.set("RunSpeed", 420)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.get></a>lia.config.get(key, default)</summary>
<a id="liaconfigget"></a>
<p>Retrieve a config value with fallback to its stored default or a provided default.</p>
<p>Anywhere configuration influences gameplay or UI logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key to read.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Optional fallback when no stored value or default exists.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value, default value, or supplied fallback.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local walkSpeed = lia.config.get("WalkSpeed", 200)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.config.load></a>lia.config.load()</summary>
<a id="liaconfigload"></a>
<p>Load config values from the database (server) or request them from the server (client).</p>
<p>On initialization to hydrate lia.config.stored after database connectivity.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DatabaseConnected", "LoadLiliaConfig", lia.config.load)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.config.getChangedValues></a>lia.config.getChangedValues(includeDefaults)</summary>
<a id="liaconfiggetchangedvalues"></a>
<p>Collect config entries whose values differ from last synced values or their defaults.</p>
<p>Prior to sending incremental config updates to clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">includeDefaults</span> <span class="optional">optional</span> When true, compare against defaults instead of last synced values.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> key → value for configs that changed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local changed = lia.config.getChangedValues()
    if next(changed) then lia.config.send() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.config.hasChanges></a>lia.config.hasChanges()</summary>
<a id="liaconfighaschanges"></a>
<p>Check whether any config values differ from the last synced snapshot.</p>
<p>To determine if a resync to clients is required.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True when at least one config value has changed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.config.hasChanges() then lia.config.send() end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.config.send></a>lia.config.send(client)</summary>
<a id="liaconfigsend"></a>
<p>Send config values to one player (full payload) or broadcast only changed values.</p>
<p>After config changes or when a player joins the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Target player for full sync; nil broadcasts only changed values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerInitialSpawn", "SyncConfig", function(ply) lia.config.send(ply) end)
    lia.config.send() -- broadcast diffs
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.config.save></a>lia.config.save()</summary>
<a id="liaconfigsave"></a>
<p>Persist all config values to the database.</p>
<p>After changes, on shutdown, or during scheduled saves.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.save()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.config.reset></a>lia.config.reset()</summary>
<a id="liaconfigreset"></a>
<p>Reset all config values to defaults, then save and sync to clients.</p>
<p>During admin resets or troubleshooting.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.config.reset()
</code></pre>
</details>

---

