# Loader Library

Core initialization and module loading system for the Lilia framework.

---

Overview

The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.

---

<details class="realm-shared">
<summary><a id=lia.loader.include></a>lia.loader.include(path, realm)</summary>
<a id="lialoaderinclude"></a>
<p>Include a Lua file with realm auto-detection and AddCSLuaFile handling.</p>
<p>Throughout bootstrap to load framework, module, and compatibility files.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> File path.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> "server" | "client" | "shared". Auto-detected from filename if nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Force client-only include for a UI helper.
    lia.loader.include("lilia/gamemode/core/ui/cl_helper.lua", "client")
    -- Auto-detect realm from prefix (sv_/cl_/sh_).
    lia.loader.include("schema/plugins/sv_custom.lua")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.loader.includeDir></a>lia.loader.includeDir(dir, raw, deep, realm)</summary>
<a id="lialoaderincludedir"></a>
<p>Include every Lua file in a directory; optionally recurse subfolders.</p>
<p>To load plugin folders or schema-specific directories.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dir</span> Directory relative to gamemode root unless raw=true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> If true, treat dir as absolute (no schema/gamemode prefix).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">deep</span> <span class="optional">optional</span> If true, recurse into subfolders.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">realm</span> <span class="optional">optional</span> Force realm for all files; auto-detect when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load all schema hooks recursively.
    lia.loader.includeDir("schema/hooks", false, true)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.loader.includeGroupedDir></a>lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)</summary>
<a id="lialoaderincludegroupeddir"></a>
<p>Include a directory grouping files by realm (sv_/cl_/sh_) with optional recursion.</p>
<p>Loading modular folders (e.g., plugins, languages, meta) with mixed realms.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">dir</span> Directory relative to gamemode root unless raw=true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">raw</span> <span class="optional">optional</span> If true, treat dir as absolute.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">recursive</span> <span class="optional">optional</span> Recurse into subfolders when true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">forceRealm</span> <span class="optional">optional</span> Override realm detection for all files.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load all plugin folders, respecting sv_/cl_/sh_ prefixes.
    lia.loader.includeGroupedDir("schema/plugins", false, true)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.loader.checkForUpdates></a>lia.loader.checkForUpdates()</summary>
<a id="lialoadercheckforupdates"></a>
<p>Check framework and module versions against remote manifests.</p>
<p>During startup or by admin command to report outdated modules.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    concommand.Add("lia_check_updates", function(ply)
        if not IsValid(ply) or ply:IsAdmin() then
            lia.loader.checkForUpdates()
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.error></a>lia.error(msg)</summary>
<a id="liaerror"></a>
<p>Logs an error message to the console with proper formatting and color coding.</p>
<p>Called throughout the framework when errors occur that need to be logged to the console for debugging purposes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">msg</span> The error message to display in the console.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Log an error when a required file fails to load
    lia.error("Failed to load configuration file: config.json not found")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.warning></a>lia.warning(msg)</summary>
<a id="liawarning"></a>
<p>Logs a warning message to the console with proper formatting and color coding.</p>
<p>Called throughout the framework when non-critical issues occur that should be brought to attention but don't stop execution.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">msg</span> The warning message to display in the console.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Log a warning when an optional dependency is missing
    lia.warning("Optional addon 'advanced_logging' not found, using basic logging instead")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.information></a>lia.information(msg)</summary>
<a id="liainformation"></a>
<p>Logs an informational message to the console with proper formatting and color coding.</p>
<p>Called throughout the framework to provide general information about system status, initialization progress, or important events.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">msg</span> The informational message to display in the console.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Log information during system initialization
    lia.information("Database connection established successfully")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.bootstrap></a>lia.bootstrap(section, msg)</summary>
<a id="liabootstrap"></a>
<p>Logs bootstrap/initialization messages to the console with section categorization and color coding.</p>
<p>Called during the framework initialization process to log progress and status of different loading sections.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">section</span> The name of the bootstrap section being initialized (e.g., "Core", "Modules", "Database").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">msg</span> The message describing what is being initialized or loaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Log bootstrap progress during initialization
    lia.bootstrap("Database", "Connecting to MySQL server...")
    lia.bootstrap("Modules", "Loading character system...")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.relaydiscordMessage></a>lia.relaydiscordMessage(embed)</summary>
<a id="liarelaydiscordmessage"></a>
<p>Sends formatted messages to a Discord webhook for logging and notifications.</p>
<p>Called when important events need to be relayed to Discord, such as server status updates, errors, or administrative actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">embed</span> A Discord embed object containing message details. Supports fields like title, description, color, timestamp, footer, etc.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Send a notification when a player achieves something special
    lia.relaydiscordMessage({
        title = "Achievement Unlocked!",
        description = player:Name() .. " unlocked the 'Master Trader' achievement",
        color = 16776960, -- Yellow
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.loader.includeEntities></a>lia.loader.includeEntities(path)</summary>
<a id="lialoaderincludeentities"></a>
<p>Include and register scripted entities, weapons, and effects under a path.</p>
<p>During initialization to load custom entities from addons/schema.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> Base path containing entities/weapons/effects subfolders.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load schema-specific entities.
    lia.loader.includeEntities("schema/entities")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.loader.initializeGamemode></a>lia.loader.initializeGamemode(isReload)</summary>
<a id="lialoaderinitializegamemode"></a>
<p>Initialize modules, apply reload syncs, and announce hot reloads.</p>
<p>On gamemode initialize and OnReloaded; supports hot-reload flow.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">isReload</span> true when called from OnReloaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Called automatically from GM:Initialize / GM:OnReloaded.
    lia.loader.initializeGamemode(false)
</code></pre>
</details>

---

