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

# Configuration

Configuration helpers for registering, retrieving, localizing, synchronizing, saving, and editing Lilia configuration values.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The configuration library centralizes runtime settings under `lia.config`. It stores registered configuration definitions, preserves defaults, localizes names, descriptions, categories, and selectable options, coerces networked values into the expected types, synchronizes changed server values to clients, persists non-default values, and builds the client configuration menu.
</div>

---

<details class="realm-shared" id="function-liaconfigadd">
<summary><span class="summary-main"><a id="lia.config.add"></a>lia.config.add(key, name, value, callback, data)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L260" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a configuration entry and stores its metadata, default value, current value, localization data, optional callback, and UI behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The unique configuration key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The display name or localization token shown for the configuration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The default value for the configuration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called with the old value and new value when the configuration is changed through `lia.config.set` or reset on the server.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Configuration metadata, including fields such as type, desc, category, min, max, decimals, options, optionsFunc, noNetworking, isGlobal, and uniqueTab.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.add("ExampleEnabled", "@exampleEnabled", true, nil, {
      desc = "@exampleEnabledDesc",
      category = "@core",
      type = "Boolean"
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfiggetdisplayname">
<summary><span class="summary-main"><a id="lia.config.getDisplayName"></a>lia.config.getDisplayName(key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L322" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfiggetdisplayname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the localized display name for a registered configuration key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key whose display name should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|any</a></span> The localized display name when available, or the key when the configuration is not registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  print(lia.config.getDisplayName("WalkSpeed"))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfiggetdisplaydesc">
<summary><span class="summary-main"><a id="lia.config.getDisplayDesc"></a>lia.config.getDisplayDesc(key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L349" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfiggetdisplaydesc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the localized description for a registered configuration key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key whose description should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|any</a></span> The localized description when available, or an empty string when the configuration is not registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  print(lia.config.getDisplayDesc("WalkSpeed"))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfiggetdisplaycategory">
<summary><span class="summary-main"><a id="lia.config.getDisplayCategory"></a>lia.config.getDisplayCategory(key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L376" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfiggetdisplaycategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the localized category for a registered configuration key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key whose category should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|any</a></span> The localized category when available, or the localized character category when the configuration is not registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  print(lia.config.getDisplayCategory("WalkSpeed"))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfiggetoptions">
<summary><span class="summary-main"><a id="lia.config.getOptions"></a>lia.config.getOptions(key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L405" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfiggetoptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns normalized selectable options for a registered table-based configuration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key whose options should be returned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of normalized option entries containing rawLabel, localized label, and value fields. Returns an empty table when no options are available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  for _, option in pairs(lia.config.getOptions("Language")) do
      print(option.label, option.value)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfigsetdefault">
<summary><span class="summary-main"><a id="lia.config.setDefault"></a>lia.config.setDefault(key, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L453" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigsetdefault"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Updates the default value for a registered configuration key.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key whose default value should be changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The new default value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.setDefault("WalkSpeed", 200)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfigforceset">
<summary><span class="summary-main"><a id="lia.config.forceSet"></a>lia.config.forceSet(key, value, noSave)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L483" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigforceset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Directly changes a registered configuration value, runs the update hook, and optionally saves the configuration without type coercion, networking, or callbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key to change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to assign.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noSave</span> <span class="optional">optional</span> When true, prevents the configuration from being saved after the value is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.forceSet("WalkSpeed", 250, true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfigset">
<summary><span class="summary-main"><a id="lia.config.set"></a>lia.config.set(key, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L516" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Changes a registered configuration value, coerces it to the expected type, runs update hooks, broadcasts the value from the server when networking is enabled, calls the configuration callback, and saves the configuration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key to change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> The value to assign.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.set("WalkSpeed", 250)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaconfigget">
<summary><span class="summary-main"><a id="lia.config.get"></a>lia.config.get(key, default)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L563" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the current value for a registered configuration key, falling back to its default value or the provided fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key to read.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">default</span> Optional fallback value returned when the configuration key is not registered or has no stored value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> The current configuration value, its default value, the special client color fallback for `Color`, or the provided fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local walkSpeed = lia.config.get("WalkSpeed", 200)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaconfigload">
<summary><span class="summary-main"><a id="lia.config.load"></a>lia.config.load()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L623" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads saved configuration values from data storage, applies defaults for missing values, updates the last-synced value cache, and runs the initialization hook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.load()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaconfiggetchangedvalues">
<summary><span class="summary-main"><a id="lia.config.getChangedValues"></a>lia.config.getChangedValues(includeDefaults)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L674" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfiggetchangedvalues"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds a table of configuration values that differ from their defaults or from the last values synchronized to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">includeDefaults</span> <span class="optional">optional</span> When true, compares each current value against its default instead of the last synchronized value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table of changed configuration keys and normalized values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local changes = lia.config.getChangedValues()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaconfigsend">
<summary><span class="summary-main"><a id="lia.config.send"></a>lia.config.send(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L709" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigsend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends configuration data to one client or broadcasts changed configuration values to all human players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Optional player who should receive the full saved configuration table. When omitted, changed values are sent to all human players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.send(client)
  lia.config.send()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaconfigsave">
<summary><span class="summary-main"><a id="lia.config.save"></a>lia.config.save()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L754" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigsave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Persists all registered configuration values that differ from their defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.save()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaconfigreset">
<summary><span class="summary-main"><a id="lia.config.reset"></a>lia.config.reset()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L778" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaconfigreset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Resets every registered configuration value to its default, runs configuration callbacks, saves the new state, and synchronizes clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.config.reset()
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

<details class="realm-shared" id="function-canplayermodifyconfig">
<summary><span class="summary-main"><a id="CanPlayerModifyConfig"></a>CanPlayerModifyConfig(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L50" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayermodifyconfig"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to control whether a player may view or modify configuration values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to access or modify configuration values.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key being modified. This argument is only provided during a configuration change.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block access or modification. Return nil or true to allow it.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-configchanged">
<summary><span class="summary-main"><a id="ConfigChanged"></a>ConfigChanged(key, newValue, oldValue, client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L74" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="configchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs on the server after a player successfully changes a configuration value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">newValue</span> The new value assigned to the configuration key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> The previous value for the configuration key.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who changed the configuration value.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createmenubuttons">
<summary><span class="summary-main"><a id="CreateMenuButtons"></a>CreateMenuButtons(tabs)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L147" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createmenubuttons"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows menu tabs to be collected for the `DefaultMenuTab` configuration option.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tabs</span> A table that should be populated with menu tab definitions.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-createsalarytimers">
<summary><span class="summary-main"><a id="CreateSalaryTimers"></a>CreateSalaryTimers()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L117" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createsalarytimers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs shortly after the `SalaryInterval` configuration value changes so salary timers can be rebuilt.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-dermaskinchanged">
<summary><span class="summary-main"><a id="DermaSkinChanged"></a>DermaSkinChanged(skin)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L130" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="dermaskinchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs when the `DermaSkin` configuration value changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">skin</span> The selected Derma skin name.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedconfig">
<summary><span class="summary-main"><a id="InitializedConfig"></a>InitializedConfig()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedconfig"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after configuration values have been loaded on the server or received by the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onconfigupdated">
<summary><span class="summary-main"><a id="OnConfigUpdated"></a>OnConfigUpdated(key, oldValue, newValue)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L27" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onconfigupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs whenever a configuration value is updated locally through `lia.config.set`, `lia.config.forceSet`, or a networked configuration update.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The configuration key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> The previous value for the configuration key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">newValue</span> The new value for the configuration key.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-voicetoggled">
<summary><span class="summary-main"><a id="VoiceToggled"></a>VoiceToggled(enabled)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/config.lua#L100" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="voicetoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs when the `IsVoiceEnabled` configuration value changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configuration</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">enabled</span> True when voice chat is enabled, false when it is disabled.</p>
</div>

</div>
</details>

---

