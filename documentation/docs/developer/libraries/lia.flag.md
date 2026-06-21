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

# Flags

Flag helpers for registering character permission flags, storing flag metadata, reapplying flag callbacks on player spawn, and displaying available flags in the character information menu.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The flag library centralizes shared flag registration under `lia.flag`. Registered flags are stored in `lia.flag.list` with an optional localized description and callback. On the server, player spawn handling reapplies callbacks for each unique flag the player has. On the client, the information menu displays all registered flags and indicates whether the local character currently has each one.
</div>

---

<details class="realm-shared" id="function-liaflagadd">
<summary><span class="summary-main"><a id="lia.flag.add"></a>lia.flag.add(flag, desc, callback)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/flags.lua#L47" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaflagadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a character permission flag with an optional localized description and optional callback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flag</span> The single-character flag identifier to register.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">desc</span> <span class="optional">optional</span> The language token or description for the flag. When provided, it is resolved through lia.lang.resolveToken before being stored.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Optional function called when the flag is applied or removed by flag handling code. The callback receives the player and a boolean indicating whether the flag is being given.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.flag.add("p", "@flagPhysgun", function(client, isGiven)
      if isGiven then
          client:Give("weapon_physgun")
      else
          client:StripWeapon("weapon_physgun")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaflagonspawn">
<summary><span class="summary-main"><a id="lia.flag.onSpawn"></a>lia.flag.onSpawn(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/flags.lua#L75" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaflagonspawn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reapplies registered flag callbacks for every unique flag the player has when spawn handling runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player whose current flags should be processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.flag.onSpawn(client)
</code></pre>
</div>

</div>
</details>

---

