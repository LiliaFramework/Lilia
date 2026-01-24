# Flags Library

Character permission and access control system for the Lilia framework.

---

Overview

The flags library provides a comprehensive permission system for managing character abilities and access rights in the Lilia framework. It allows administrators to assign specific flags to characters that grant or restrict various gameplay features and tools. The library operates on both server and client sides, with the server handling flag assignment and callback execution during character spawning, while the client provides user interface elements for viewing and managing flags. Flags can have associated callbacks that execute when granted or removed, enabling dynamic behavior changes based on permission levels. The system includes built-in flags for common administrative tools like physgun, toolgun, and various spawn permissions. The library ensures proper flag validation and prevents duplicate flag assignments.

---

<details class="realm-shared">
<summary><a id=lia.flag.add></a>lia.flag.add(flag, Single, Single, desc, callback)</summary>
<a id="liaflagadd"></a>
<p>Register a flag with description and optional grant/remove callback.</p>
<p>During framework setup to define permission flags.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flag</span> Single-character flag id.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Single</span> character flag id.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Single</span> character flag id.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">desc</span> Localization key or plain description.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> function(client, isGiven) for grant/remove side effects.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.flag.add("B", "flagBuildMenu", function(client, isGiven)
        if isGiven then
            client:Give("weapon_physgun")
        else
            client:StripWeapon("weapon_physgun")
        end
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.flag.onSpawn></a>lia.flag.onSpawn(client)</summary>
<a id="liaflagonspawn"></a>
<p>Execute flag callbacks for a player on spawn, ensuring each flag runs once.</p>
<p>Automatically when characters spawn; can be hooked for reapplication.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose flags should be processed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerSpawn", "ApplyFlagWeapons", lia.flag.onSpawn)
</code></pre>
</details>

---

