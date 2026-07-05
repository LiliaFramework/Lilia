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

# Combat

This page documents hooks in the combat category.

---

<details class="realm-shared" id="function-canplayerthrowpunch">
<summary><span class="summary-main"><a id="CanPlayerThrowPunch"></a>CanPlayerThrowPunch(client)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/attributes/libraries/shared.lua#L55" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerthrowpunch"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may throw a punch with the hands weapon before cooldown and attack logic proceeds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|string|nil</a></span> Return false to block the punch. A second return value may provide the localized error key shown to the player. Returning nil allows the default behavior to continue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerThrowPunch", "liaExampleCanPlayerThrowPunch", function(client)
      if client:getNetVar("noPunching") then
          return false, "needMorePlaytimeBeforePunch"
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getdamagescale">
<summary><span class="summary-main"><a id="GetDamageScale"></a>GetDamageScale(hitgroup, dmgInfo, damageScale)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/hooks/server.lua#L761" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdamagescale"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override the damage multiplier before scaled damage is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> The Garry's Mod hitgroup being processed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> The damage information object being scaled.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> The current damage multiplier after Lilia's head and limb checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a numeric multiplier to replace the current damage scale. Returning nil allows the default behavior to continue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDamageScale", "liaExampleGetDamageScale", function(hitgroup, dmgInfo, damageScale)
      if hitgroup == HITGROUP_HEAD then
          return damageScale * 0.75
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-gethandsattackspeed">
<summary><span class="summary-main"><a id="GetHandsAttackSpeed"></a>GetHandsAttackSpeed(client, defaultDelay)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/entities/weapons/lia_hands/shared.lua#L36" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="gethandsattackspeed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to override the primary attack delay used by the hands weapon when punching.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player performing the punch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">defaultDelay</span> The base primary attack delay defined on the hands weapon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a numeric delay to override the default punch cooldown. Returning nil allows the default behavior to continue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetHandsAttackSpeed", "liaExampleGetHandsAttackSpeed", function(client, defaultDelay)
      if client:Crouching() then
          return defaultDelay * 0.9
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getplayerpunchdamage">
<summary><span class="summary-main"><a id="GetPlayerPunchDamage"></a>GetPlayerPunchDamage(client, damage, context)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/entities/weapons/lia_hands/shared.lua#L69" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerpunchdamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to override or mutate the damage dealt by a hands-weapon punch before the trace attack is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player performing the punch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damage</span> The current punch damage value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">context</span> Mutable context data containing the current `damage` field.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a numeric damage value to override the punch damage. Returning nil allows the current context damage to be used.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerPunchDamage", "liaExampleGetPlayerPunchDamage", function(client, damage, context)
      if client:InVehicle() then
          return 0
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getplayerpunchragdolltime">
<summary><span class="summary-main"><a id="GetPlayerPunchRagdollTime"></a>GetPlayerPunchRagdollTime(client, target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/entities/weapons/lia_hands/shared.lua#L105" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerpunchragdolltime"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to override how long a player stays ragdolled when a non-lethal punch would otherwise knock them out.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who threw the punch.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">target</span> The player who is about to be ragdolled by the punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a numeric ragdoll duration in seconds to override the configured default. Returning nil allows the default behavior to continue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerPunchRagdollTime", "liaExampleGetPlayerPunchRagdollTime", function(client, target)
      if target:isStaffOnDuty() then
          return 5
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerthrowpunch">
<summary><span class="summary-main"><a id="PlayerThrowPunch"></a>PlayerThrowPunch(client, trace)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/entities/weapons/lia_hands/shared.lua#L138" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerthrowpunch"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the hands weapon resolves its punch trace and applies any resulting damage or ragdoll effect.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who threw the punch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">trace</span> The trace result table used to resolve the punch hit.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerThrowPunch", "liaExamplePlayerThrowPunch", function(client, trace)
      if trace.Hit and IsValid(trace.Entity) then
          print(client:Nick(), "punched", trace.Entity:GetClass())
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postscaledamage">
<summary><span class="summary-main"><a id="PostScaleDamage"></a>PostScaleDamage(hitgroup, dmgInfo, damageScale)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/hooks/server.lua#L797" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postscaledamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the current damage scale has been applied to the damage info object.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> The Garry's Mod hitgroup that was processed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> The scaled damage information object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> The multiplier that was applied to the damage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostScaleDamage", "liaExamplePostScaleDamage", function(hitgroup, dmgInfo, damageScale)
      print("[Damage] Applied scale:", damageScale)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-prescaledamage">
<summary><span class="summary-main"><a id="PreScaleDamage"></a>PreScaleDamage(hitgroup, dmgInfo, damageScale)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/hooks/server.lua#L97" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="prescaledamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs immediately before scaled hitgroup damage is applied so modules can adjust the damage info or scale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Combat</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> The hitgroup being processed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> The mutable damage information object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> The scale that is about to be applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreScaleDamage", "liaExamplePreScaleDamage", function(hitgroup, dmgInfo, damageScale)
      if hitgroup == HITGROUP_HEAD then dmgInfo:ScaleDamage(0.9) end
  end)
</code></pre>
</div>

</div>
</details>

---

