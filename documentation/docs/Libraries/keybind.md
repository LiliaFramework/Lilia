# Keybind Library

Keyboard binding registration, storage, and execution system for the Lilia framework.

---

Overview

The keybind library provides comprehensive functionality for managing keyboard bindings in the Lilia framework. It handles registration, storage, and execution of custom keybinds that can be triggered by players. The library supports both client-side and server-side keybind execution, with automatic networking for server-only keybinds. It includes persistent storage of keybind configurations, user interface for keybind management, and validation to prevent key conflicts. The library operates on both client and server sides, with the client handling input detection and UI, while the server processes server-only keybind actions. It ensures proper key mapping, callback execution, and provides a complete keybind management system for the gamemode.

---

<details class="realm-shared">
<summary><a id=lia.keybind.add></a>lia.keybind.add(k, d, desc, cb)</summary>
<a id="liakeybindadd"></a>
<p>Register a keybind action with callbacks and optional metadata.</p>
<p>During initialization to expose actions to the keybind system/UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> <span class="parameter">k</span> Key code or key name (or actionName when using table config form).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|table</a></span> <span class="parameter">d</span> Action name or config table when first arg is action name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">desc</span> <span class="optional">optional</span> Description when using legacy signature.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Callback table {onPress, onRelease, shouldRun, serverOnly}.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Table-based registration with shouldRun and serverOnly.
    lia.keybind.add("toggleMap", {
        keyBind = KEY_M,
        desc = "Open the world map",
        serverOnly = false,
        shouldRun = function(client) return client:Alive() end,
        onPress = function(client)
            if IsValid(client.mapPanel) then
                client.mapPanel:Close()
                client.mapPanel = nil
            else
                client.mapPanel = vgui.Create("liaWorldMap")
            end
        end
    })
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.keybind.get></a>lia.keybind.get(a, df)</summary>
<a id="liakeybindget"></a>
<p>Get the key code assigned to an action, with default fallback.</p>
<p>When populating keybind UI or triggering actions manually.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">a</span> Action name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">df</span> <span class="optional">optional</span> Default key code if not set.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local key = lia.keybind.get("openInventory", KEY_I)
    print("Inventory key is:", input.GetKeyName(key))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.keybind.save></a>lia.keybind.save()</summary>
<a id="liakeybindsave"></a>
<p>Persist current keybind overrides to disk.</p>
<p>After users change keybinds in the config UI.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.keybind.save()
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.keybind.load></a>lia.keybind.load()</summary>
<a id="liakeybindload"></a>
<p>Load keybind overrides from disk, falling back to defaults if missing.</p>
<p>On client init/config load; rebuilds reverse lookup table for keys.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("Initialize", "LoadLiliaKeybinds", lia.keybind.load)
</code></pre>
</details>

---

