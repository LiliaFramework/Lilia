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

# Loader

Core loading and bootstrap helpers for Lilia files, directories, entities, updates, compatibility, and hot reload flow.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The loader library centralizes framework startup behavior under `lia.loader`. It includes Lua files in the correct realm, loads directories of Lua files, registers scripted entities, performs framework and module version checks, initializes modules during startup or reload, and loads compatibility libraries when supported addons are detected.
</div>

---

<details class="realm-shared" id="function-lialoaderinclude">
<summary><span class="summary-main"><a id="lia.loader.include"></a>lia.loader.include(path, realm)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L404" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderinclude"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Includes a Lua file in the requested realm and sends clientside files to clients when needed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> The Lua file path to include. Backslashes are normalized to forward slashes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> Optional realm override. Valid values are `server`, `client`, and `shared`. When omitted, the realm is inferred from filename prefixes such as `sv_`, `cl_`, or `sh_`, or from `server`, `client`, and `shared` filenames.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
  lia.loader.include("lilia/gamemode/core/hooks/server.lua")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludedir">
<summary><span class="summary-main"><a id="lia.loader.includeDir"></a>lia.loader.includeDir(dir, raw, deep, realm)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L461" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludedir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Includes every Lua file in a directory, optionally recursing into subdirectories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dir</span> The directory to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> When true, uses `dir` as a raw Lua path. When false or nil, resolves it relative to the active schema path while schema loading, or `lilia/gamemode` otherwise.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">deep</span> <span class="optional">optional</span> When true, recursively loads Lua files in child folders.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> Optional realm override passed to `lia.loader.include` for every file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
  lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludegroupeddir">
<summary><span class="summary-main"><a id="lia.loader.includeGroupedDir"></a>lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L501" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludegroupeddir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Includes Lua files from a directory in sorted order while resolving each file realm from filename prefixes unless a realm override is provided.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dir</span> The directory to load.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> When true, uses `dir` as a raw Lua path. When false or nil, resolves it relative to the active schema path while schema loading, or `lilia/gamemode` otherwise.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">recursive</span> <span class="optional">optional</span> When true, walks child folders and loads matching Lua files from them as well.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">forceRealm</span> <span class="optional">optional</span> Optional realm override for every included file. When omitted, files are resolved from `sh_`, `sv_`, `cl_`, `shared.lua`, `server.lua`, and `client.lua` names.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.includeGroupedDir("modules/example/libs", false, true)
  lia.loader.includeGroupedDir("lilia/gamemode/core/derma", true, true, "client")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoadercheckforupdates">
<summary><span class="summary-main"><a id="lia.loader.checkForUpdates"></a>lia.loader.checkForUpdates()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L587" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoadercheckforupdates"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaerror">
<summary><span class="summary-main"><a id="lia.error"></a>lia.error()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L709" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaerror"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liawarning">
<summary><span class="summary-main"><a id="lia.warning"></a>lia.warning()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L714" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawarning"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liainformation">
<summary><span class="summary-main"><a id="lia.information"></a>lia.information()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L719" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liabootstrap">
<summary><span class="summary-main"><a id="lia.bootstrap"></a>lia.bootstrap()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L724" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liabootstrap"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadebug">
<summary><span class="summary-main"><a id="lia.debug"></a>lia.debug()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L731" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadebug"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liarelaydiscordmessage">
<summary><span class="summary-main"><a id="lia.relaydiscordMessage"></a>lia.relaydiscordMessage()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L782" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liarelaydiscordmessage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.checkForUpdates()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludeentities">
<summary><span class="summary-main"><a id="lia.loader.includeEntities"></a>lia.loader.includeEntities(path)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L839" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludeentities"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loads and registers scripted entities, weapons, and effects from a base path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> The base path containing `entities`, `weapons`, and `effects` folders.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.includeEntities("lilia/gamemode")
  lia.loader.includeEntities(SCHEMA.folder .. "/schema")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderinitializegamemode">
<summary><span class="summary-main"><a id="lia.loader.initializeGamemode"></a>lia.loader.initializeGamemode(isReload)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L976" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderinitializegamemode"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initializes or hot-reloads the gamemode by loading modules, formatting faction model data, refreshing reload-sensitive state, and synchronizing changed server data after reloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isReload</span> <span class="optional">optional</span> True when initialization is being performed during a hot reload. False or nil during normal startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.loader.initializeGamemode(false)
  lia.loader.initializeGamemode(true)
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

<details class="realm-server" id="function-databaseconnected">
<summary><span class="summary-main"><a id="DatabaseConnected"></a>DatabaseConnected()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L62" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="databaseconnected"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the database connection succeeds and database tables are loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-discordrelayed">
<summary><span class="summary-main"><a id="DiscordRelayed"></a>DiscordRelayed(embed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L38" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelayed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the Discord relay request has been dispatched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">embed</span> The embed payload that was dispatched.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-discordrelaysend">
<summary><span class="summary-main"><a id="DiscordRelaySend"></a>DiscordRelaySend(embed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelaysend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs before a Discord relay embed is dispatched through the configured webhook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">embed</span> The embed payload being prepared for relay.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-discordrelayunavailable">
<summary><span class="summary-main"><a id="DiscordRelayUnavailable"></a>DiscordRelayUnavailable()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L28" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelayunavailable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs when the Discord relay cannot use the CHTTP send path and falls back to the HTTP send path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-persistenceload">
<summary><span class="summary-main"><a id="PersistenceLoad"></a>PersistenceLoad(new)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L86" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="persistenceload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after map cleanup when the `sbox_persist` console variable changes to a non-empty value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">new</span> The new persistence value being loaded.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-persistencesave">
<summary><span class="summary-main"><a id="PersistenceSave"></a>PersistenceSave(old)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L72" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="persistencesave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs before map cleanup when the `sbox_persist` console variable changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">old</span> The previous persistence value being saved.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupdatabase">
<summary><span class="summary-main"><a id="SetupDatabase"></a>SetupDatabase()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/loader.lua#L52" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupdatabase"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs immediately before the server begins connecting to the configured database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

</div>
</details>

---

