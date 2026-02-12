# Currency

In-game currency formatting, display, and management system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The currency library provides comprehensive functionality for managing in-game currency within the Lilia framework. It handles currency formatting, display, and physical money entity spawning.
The library operates on both server and client sides, with the server handling money entity creation and spawning, while the client handles currency display formatting.
It includes localization support for currency names and symbols, ensuring proper pluralization and formatting based on amount values.
The library integrates with the configuration system to allow customizable currency symbols and names.
</div>

---

<details class="realm-shared" id="function-liacurrencyget">
<summary><a id="lia.currency.get"></a>lia.currency.get(amount)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacurrencyget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Format a numeric amount into a localized currency string with the configured symbol and singular/plural name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever a currency amount needs to be shown to players or logged (UI, chat, logs, tooltips).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> Raw amount to format; must be a number.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Formatted amount with symbol prefix and the singular or plural currency name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  chat.AddText(L("youReceivedMoney", lia.currency.get(250)))
  lia.log.add(client, "moneyPickedUp", 250)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liacurrencyspawn">
<summary><a id="lia.currency.spawn"></a>lia.currency.spawn(pos, amount, angle)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacurrencyspawn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Spawn a physical money entity at a world position and assign it an amount.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server-side when creating droppable currency (player drops, rewards, refunds, scripted events).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> World position to spawn the money entity; required.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> Currency amount to store on the entity; must be non-negative.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle</a></span> <span class="parameter">angle</span> <span class="optional">optional</span> Optional spawn angles; defaults to `angle_zero` when omitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|nil</a></span> Created `lia_money` entity, or nil if input is invalid or entity creation fails.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnNPCKilled", "DropBountyCash", function(npc, attacker)
      if not IsValid(attacker) or not attacker:IsPlayer() then return end
      local money = lia.currency.spawn(npc:GetPos() + Vector(0, 0, 10), math.random(50, 150))
      if IsValid(money) then
          money:SetVelocity(VectorRand() * 80)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

