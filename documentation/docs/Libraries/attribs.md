# Attributes Library

Character attribute management system for the Lilia framework.

---

Overview

The attributes library provides functionality for managing character attributes in the Lilia framework. It handles loading attribute definitions from files, registering attributes in the system, and setting up attributes for characters during spawn. The library operates on both server and client sides, with the server managing attribute setup during character spawning and the client handling attribute-related UI elements. It includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior.

---

<details class="realm-shared">
<summary><a id=lia.attribs.loadFromDir></a>lia.attribs.loadFromDir(directory)</summary>
<a id="liaattribsloadfromdir"></a>
<p>Discover and include attribute definitions from a directory.</p>
<p>During schema/gamemode startup to load all attribute files.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">directory</span> Path containing attribute Lua files.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load default and custom attributes.
    lia.attribs.loadFromDir(lia.plugin.getDir() .. "/attribs")
    lia.attribs.loadFromDir("schema/attribs")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.attribs.register></a>lia.attribs.register(uniqueID, data)</summary>
<a id="liaattribsregister"></a>
<p>Register or update an attribute definition in the global list.</p>
<p>After loading an attribute file or when hot-reloading attributes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Attribute key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Fields like name, desc, OnSetup, setup, etc.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The stored attribute table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.attribs.register("strength", {
        name = "Strength",
        desc = "Improves melee damage and carry weight.",
        OnSetup = function(client, value)
            client:SetJumpPower(160 + value * 0.5)
        end
    })
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.attribs.setup></a>lia.attribs.setup(client)</summary>
<a id="liaattribssetup"></a>
<p>Run attribute setup logic for a character on the server.</p>
<p>On player spawn/character load to reapply attribute effects.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose character attributes are being applied.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerLoadedChar", "ApplyAttributeBonuses", function(ply)
        lia.attribs.setup(ply)
    end)
</code></pre>
</details>

---

