# Modularity Library

Module loading, initialization, and lifecycle management system for the Lilia framework.

---

Overview

The modularity library provides comprehensive functionality for managing modules in the Lilia framework. It handles loading, initialization, and management of modules including schemas, preload modules, and regular modules. The library operates on both server and client sides, managing module dependencies, permissions, and lifecycle events. It includes functionality for loading modules from directories, handling module-specific data storage, and ensuring proper initialization order. The library also manages submodules, handles module validation, and provides hooks for module lifecycle events. It ensures that all modules are properly loaded and initialized before gameplay begins.

---

<details class="realm-shared">
<summary><a id=lia.module.load></a>lia.module.load(uniqueID, path, variable, skipSubmodules)</summary>
<a id="liamoduleload"></a>
<p>Loads and initializes a module from a specified directory path with the given unique ID.</p>
<p>Called during module initialization to load individual modules, their dependencies, and register them in the system.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique identifier for the module.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> The file system path to the module directory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">string, optional</a></span> <span class="parameter">variable</span> The global variable name to assign the module to (defaults to "MODULE").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">skipSubmodules</span> Whether to skip loading submodules for this module.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load a custom module
    lia.module.load("mymodule", "gamemodes/my_schema/modules/mymodule")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.module.initialize></a>lia.module.initialize()</summary>
<a id="liamoduleinitialize"></a>
<p>Initializes the entire module system by loading the schema, preload modules, and all available modules in the correct order.</p>
<p>Called once during gamemode initialization to set up the module loading system and load all modules.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Initialize the module system (called automatically by the framework)
    lia.module.initialize()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.module.loadFromDir></a>lia.module.loadFromDir(directory, group, skip)</summary>
<a id="liamoduleloadfromdir"></a>
<p>Loads all modules found in the specified directory, optionally skipping certain modules.</p>
<p>Called during module initialization to load groups of modules from directories like preload, modules, and overrides.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">directory</span> The directory path to search for modules.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">group</span> The type of modules being loaded ("schema" or "module").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">table, optional</a></span> <span class="parameter">skip</span> A table of module IDs to skip loading.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load all modules from the gamemode's modules directory
    lia.module.loadFromDir("gamemodes/my_schema/modules", "module")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.module.get></a>lia.module.get(identifier)</summary>
<a id="liamoduleget"></a>
<p>Retrieves a loaded module by its unique identifier.</p>
<p>Called whenever code needs to access a specific module's data or functions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> The unique identifier of the module to retrieve.</p>

<p><h3>Returns:</h3>
table or nil The module table if found, nil if the module doesn't exist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Get a reference to the inventory module
    local inventoryModule = lia.module.get("inventory")
    if inventoryModule then
        -- Use the module
    end
</code></pre>
</details>

---

