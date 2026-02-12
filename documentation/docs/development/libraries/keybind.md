# Keybind

Keyboard binding registration, storage, and execution system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The keybind library provides comprehensive functionality for managing keyboard bindings in the Lilia framework. It handles registration, storage, and execution of custom keybinds that can be triggered by players. The library supports both client-side and server-side keybind execution, with automatic networking for server-only keybinds. It includes persistent storage of keybind configurations, user interface for keybind management, and validation to prevent key conflicts. The library operates on both client and server sides, with the client handling input detection and UI, while the server processes server-only keybind actions. It ensures proper key mapping, callback execution, and provides a complete keybind management system for the gamemode.
</div>

---

<details class="realm-shared" id="function-liakeybindadd">
<summary><a id="lia.keybind.add"></a>lia.keybind.add(k, d, desc, cb)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liakeybindadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a keybind action with callbacks and optional metadata.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During initialization to expose actions to the keybind system/UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">k</span> Key code or key name (or actionName when using table config form).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">d</span> Action name or config table when first arg is action name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">desc</span> <span class="optional">optional</span> Description when using legacy signature.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">cb</span> <span class="optional">optional</span> Callback table {onPress, onRelease, shouldRun, serverOnly}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Table-based registration with shouldRun and serverOnly.
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
</div>

</div>
</details>

---

<details class="realm-client" id="function-liakeybindget">
<summary><a id="lia.keybind.get"></a>lia.keybind.get(a, df)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liakeybindget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Get the key code assigned to an action, with default fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When populating keybind UI or triggering actions manually.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">a</span> Action name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">df</span> <span class="optional">optional</span> Default key code if not set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span></p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local key = lia.keybind.get("openInventory", KEY_I)
  print("Inventory key is:", input.GetKeyName(key))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liakeybindsave">
<summary><a id="lia.keybind.save"></a>lia.keybind.save()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liakeybindsave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Persist current keybind overrides to disk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After users change keybinds in the config UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.keybind.save()
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liakeybindload">
<summary><a id="lia.keybind.load"></a>lia.keybind.load()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liakeybindload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Load keybind overrides from disk, falling back to defaults if missing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On client init/config load; rebuilds reverse lookup table for keys.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("Initialize", "LoadLiliaKeybinds", lia.keybind.load)
</code></pre>
</div>

</div>
</details>

---

