# Loader

Core initialization and module loading system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.
</div>

---

<details class="realm-shared" id="function-lialoaderinclude">
<summary><a id="lia.loader.include"></a>lia.loader.include(path, realm)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderinclude"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Include a Lua file with realm auto-detection and AddCSLuaFile handling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Throughout bootstrap to load framework, module, and compatibility files.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> File path.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> "server" | "client" | "shared". Auto-detected from filename if nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Force client-only include for a UI helper.
  lia.loader.include("lilia/gamemode/core/ui/cl_helper.lua", "client")
  -- Auto-detect realm from prefix (sv_/cl_/).
  lia.loader.include("modules/sv_custom.lua")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludedir">
<summary><a id="lia.loader.includeDir"></a>lia.loader.includeDir(dir, raw, deep, realm)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludedir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Include every Lua file in a directory; optionally recurse subfolders.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>To load plugin folders or schema-specific directories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dir</span> Directory relative to gamemode root unless raw=true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> If true, treat dir as absolute (no schema/gamemode prefix).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">deep</span> <span class="optional">optional</span> If true, recurse into subfolders.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> Force realm for all files; auto-detect when nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Load all schema hooks recursively.
  lia.loader.includeDir("schema/hooks", false, true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludegroupeddir">
<summary><a id="lia.loader.includeGroupedDir"></a>lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludegroupeddir"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Include a directory grouping files by realm (sv_/cl_/) with optional recursion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Loading modular folders (e.g., plugins, languages, meta) with mixed realms.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">dir</span> Directory relative to gamemode root unless raw=true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> If true, treat dir as absolute.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">recursive</span> <span class="optional">optional</span> Recurse into subfolders when true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">forceRealm</span> <span class="optional">optional</span> Override realm detection for all files.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Load all plugin folders, respecting sv_/cl_/ prefixes.
  lia.loader.includeGroupedDir("modules", false, true)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoadercheckforupdates">
<summary><a id="lia.loader.checkForUpdates"></a>lia.loader.checkForUpdates()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoadercheckforupdates"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Check framework and module versions against remote manifests.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During startup or by admin command to report outdated modules.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  concommand.Add("lia_check_updates", function(ply)
      if not IsValid(ply) or ply:IsAdmin() then
          lia.loader.checkForUpdates()
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liaerror">
<summary><a id="lia.error"></a>lia.error(msg)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaerror"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Logs an error message to the console with proper formatting and color coding.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called throughout the framework when errors occur that need to be logged to the console for debugging purposes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">msg</span> The error message to display in the console.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Log an error when a required file fails to load
  lia.error("Failed to load configuration file: config.json not found")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liawarning">
<summary><a id="lia.warning"></a>lia.warning(msg)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liawarning"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Logs a warning message to the console with proper formatting and color coding.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called throughout the framework when non-critical issues occur that should be brought to attention but don't stop execution.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">msg</span> The warning message to display in the console.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Log a warning when an optional dependency is missing
  lia.warning("Optional addon 'advanced_logging' not found, using basic logging instead")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liainformation">
<summary><a id="lia.information"></a>lia.information(msg)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liainformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Logs an informational message to the console with proper formatting and color coding.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called throughout the framework to provide general information about system status, initialization progress, or important events.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">msg</span> The informational message to display in the console.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Log information during system initialization
  lia.information("Database connection established successfully")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liabootstrap">
<summary><a id="lia.bootstrap"></a>lia.bootstrap(section, msg)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liabootstrap"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Logs bootstrap/initialization messages to the console with section categorization and color coding.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called during the framework initialization process to log progress and status of different loading sections.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">section</span> The name of the bootstrap section being initialized (e.g., "Core", "Modules", "Database").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">msg</span> The message describing what is being initialized or loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Log bootstrap progress during initialization
  lia.bootstrap("Database", "Connecting to MySQL server...")
  lia.bootstrap("Modules", "Loading character system...")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liarelaydiscordmessage">
<summary><a id="lia.relaydiscordMessage"></a>lia.relaydiscordMessage(embed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liarelaydiscordmessage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends formatted messages to a Discord webhook for logging and notifications.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when important events need to be relayed to Discord, such as server status updates, errors, or administrative actions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">embed</span> A Discord embed object containing message details. Supports fields like title, description, color, timestamp, footer, etc.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Send a notification when a player achieves something special
  lia.relaydiscordMessage({
      title = "Achievement Unlocked!",
      description = player:Name() .. " unlocked the 'Master Trader' achievement",
      color = 16776960, -- Yellow
      timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderincludeentities">
<summary><a id="lia.loader.includeEntities"></a>lia.loader.includeEntities(path)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderincludeentities"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Include and register scripted entities, weapons, and effects under a path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During initialization to load custom entities from addons/schema.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> Base path containing entities/weapons/effects subfolders.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Load schema-specific entities.
  lia.loader.includeEntities("schema/entities")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lialoaderinitializegamemode">
<summary><a id="lia.loader.initializeGamemode"></a>lia.loader.initializeGamemode(isReload)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lialoaderinitializegamemode"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initialize modules, apply reload syncs, and announce hot reloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On gamemode initialize and OnReloaded; supports hot-reload flow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isReload</span> true when called from OnReloaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Called automatically from GM:Initialize / GM:OnReloaded.
  lia.loader.initializeGamemode(false)
</code></pre>
</div>

</div>
</details>

---
